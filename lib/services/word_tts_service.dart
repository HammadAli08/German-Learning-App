import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'hugging_face_service.dart';

/// Plays a single German word.
/// If a Hugging Face token is set: calls mms-tts-deu, caches the WAV file in
/// Hive box 'word_audio' (word → file path), and plays from cache on repeat.
/// Falls back to device flutter_tts when the token is absent or the call fails.
class WordTtsService {
  static const _boxName = 'word_audio';

  final _tts = FlutterTts();
  final _player = AudioPlayer();
  bool _ttsInit = false;

  Box<String> get _box => Hive.box<String>(_boxName);

  Future<void> _initTts({double speed = 1.0}) async {
    final result = await _tts.setLanguage('de-DE');
    if (result != 1) await _tts.setLanguage('de');
    await _tts.setSpeechRate(speed * 0.85);
    await _tts.setVolume(1.0);
  }

  /// Speak [word] using the best available method.
  Future<void> speak(String word, {String? hfToken, double speed = 1.0}) async {
    if (word.trim().isEmpty) return;

    // 1. Check Hive cache for a previously generated file
    final cached = _box.get(word);
    if (cached != null) {
      final file = File(cached);
      if (await file.exists()) {
        await _playFile(cached, speed: speed);
        return;
      } else {
        // Stale cache entry — remove it
        await _box.delete(word);
      }
    }

    // 2. Try HF API if a token is present
    if (hfToken != null && hfToken.isNotEmpty) {
      try {
        final hf = HuggingFaceService(hfToken);
        final bytes = await hf.synthesizeSpeech(word);
        final dir = await getApplicationDocumentsDirectory();
        final safe = word.replaceAll(RegExp(r'[^\w]'), '_');
        final path = '${dir.path}/word_${safe}_${bytes.length}.wav';
        final file = File(path);
        await file.writeAsBytes(bytes);
        await _box.put(word, path);
        await _playFile(path, speed: speed);
        return;
      } catch (e) {
        debugPrint('[WordTts] HF API failed for "$word": $e — falling back to TTS');
      }
    }

    // 3. Device TTS fallback
    await _initTts(speed: speed);
    await _tts.awaitSpeakCompletion(true);
    await _tts.speak(word);
  }

  Future<void> _playFile(String path, {double speed = 1.0}) async {
    try {
      await _player.stop();
      await _player.setAudioSource(AudioSource.file(path));
      await _player.setSpeed(speed);
      await _player.play();
    } catch (e) {
      debugPrint('[WordTts] Playback failed: $e');
    }
  }

  void dispose() {
    _tts.stop();
    _player.dispose();
  }
}

// ── Riverpod provider ─────────────────────────────────────────────────────────

class WordTtsNotifier extends Notifier<String?> {
  // state = currently playing word, or null
  late final WordTtsService _service;
  static const _storage = FlutterSecureStorage();

  @override
  String? build() {
    _service = WordTtsService();
    ref.onDispose(_service.dispose);
    return null;
  }

  Future<void> speak(String word) async {
    if (state != null) return; // already playing
    state = word;
    try {
      final token = await _storage.read(key: 'hf_api_token') ?? '';
      final settings = ref.read(settingsProvider).valueOrNull;
      final speed = settings?.defaultPlaybackSpeed ?? 1.0;
      await _service.speak(word, hfToken: token.isEmpty ? null : token, speed: speed);
    } finally {
      state = null;
    }
  }
}

final wordTtsProvider = NotifierProvider<WordTtsNotifier, String?>(
  WordTtsNotifier.new,
);
