import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

/// Manages all audio I/O: recording with [record] and playback with [just_audio].
class AudioService {
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();

  // ──────────────────────────────────────────────────────────────────────────
  // Recording
  // ──────────────────────────────────────────────────────────────────────────

  Future<bool> hasPermission() => _recorder.hasPermission();

  /// Start recording to a WAV file.
  Future<void> startRecording() async {
    String? path;
    if (!kIsWeb) {
      final dir = await getApplicationDocumentsDirectory();
      path = '${dir.path}/gl_recording_${DateTime.now().millisecondsSinceEpoch}.wav';
    }

    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.wav,
        sampleRate: 16000, // Whisper expects 16kHz
        numChannels: 1,    // Mono
        bitRate: 256000,
      ),
      path: path ?? '',
    );
  }

  /// Stop recording and return the audio bytes.
  /// On mobile reads the temp file; on web fetches the blob URL.
  Future<Uint8List?> stopRecordingBytes() async {
    final path = await _recorder.stop();
    if (path == null) return null;

    if (kIsWeb) {
      final response = await Dio().get<List<int>>(
        path,
        options: Options(responseType: ResponseType.bytes),
      );
      return response.data != null ? Uint8List.fromList(response.data!) : null;
    }

    return File(path).readAsBytes();
  }

  Future<bool> get isRecording => _recorder.isRecording();

  // ──────────────────────────────────────────────────────────────────────────
  // Playback
  // ──────────────────────────────────────────────────────────────────────────

  /// Save WAV bytes to a temp file and return its path.
  Future<String> saveAudioBytes(Uint8List bytes, {String? name}) async {
    final filename = name ?? 'gl_tts_${DateTime.now().millisecondsSinceEpoch}.wav';

    if (kIsWeb) {
      final base64Str = base64Encode(bytes);
      return 'data:audio/wav;base64,$base64Str';
    }

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$filename');
    await file.writeAsBytes(bytes);
    return file.path;
  }

  /// Play audio from a file path at the given speed (1.0 = normal, 0.5 = half).
  Future<void> playFile(String filePath, {double speed = 1.0}) async {
    try {
      await _player.stop();
      if (kIsWeb) {
        await _player.setAudioSource(AudioSource.uri(Uri.parse(filePath)));
      } else {
        final file = File(filePath);
        if (!await file.exists()) {
          debugPrint('[AudioService] File not found: $filePath');
          return;
        }
        await _player.setAudioSource(AudioSource.file(filePath));
      }
      await _player.setSpeed(speed);
      await _player.play();
    } catch (e) {
      debugPrint('[AudioService] Playback failed: $e');
    }
  }

  Future<void> stopPlayback() => _player.stop();

  Stream<PlayerState> get playerStateStream => _player.playerStateStream;

  // ──────────────────────────────────────────────────────────────────────────
  // Cleanup
  // ──────────────────────────────────────────────────────────────────────────
  Future<void> dispose() async {
    await _recorder.dispose();
    _player.dispose();
  }

  /// Delete old recording and TTS audio files from the documents directory.
  /// Keeps only the most recent [keepCount] files per prefix.
  static Future<void> cleanOldAudioFiles({int keepCount = 50}) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final files = await dir.list().toList();
      // Group by prefix: gl_recording_* and gl_tts_*
      for (final prefix in ['gl_recording_', 'gl_tts_']) {
        final matching = files
            .where((f) => f is File && f.path.contains(prefix))
            .cast<File>()
            .toList()
          ..sort((a, b) => b.path.compareTo(a.path)); // newest first
        if (matching.length <= keepCount) continue;
        for (final file in matching.skip(keepCount)) {
          await file.delete();
        }
      }
    } catch (e) {
      debugPrint('[AudioService] Cleanup error: $e');
    }
  }
}
