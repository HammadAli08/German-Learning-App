import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Wraps [FlutterTts] to speak German text using the device's built-in
/// TTS engine. No network calls, no API keys, no 400 errors.
class TtsService {
  final FlutterTts _tts = FlutterTts();
  bool _initialized = false;

  /// Must be called once before [speak]. Safe to call multiple times.
  Future<void> init() async {
    if (_initialized) return;

    // Prefer de-DE; some devices only have the root 'de' locale.
    final result = await _tts.setLanguage('de-DE');
    if (result != 1) {
      debugPrint('[TtsService] de-DE not available, falling back to de');
      await _tts.setLanguage('de');
    }

    await _tts.setSpeechRate(0.85); // slightly slower for learners
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
    _initialized = true;
  }

  /// Speak [text] in German and wait for completion.
  Future<void> speak(String text) async {
    await init();
    await _tts.awaitSpeakCompletion(true);
    await _tts.speak(text);
  }

  /// Speak at a custom rate. [speed] matches the app's playback speed setting
  /// (0.5 = slow, 1.0 = normal).
  Future<void> speakAtSpeed(String text, double speed) async {
    await init();
    await _tts.setSpeechRate(speed * 0.85); // scale to a comfortable range
    await _tts.awaitSpeakCompletion(true);
    await _tts.speak(text);
    await _tts.setSpeechRate(0.85); // reset to default
  }

  Future<void> stop() => _tts.stop();

  void dispose() => _tts.stop();
}
