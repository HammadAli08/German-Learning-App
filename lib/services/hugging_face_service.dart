import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../data/models/translation_result.dart';

/// Custom error for pipeline failures
class HFApiException implements Exception {
  final String message;
  final int? statusCode;
  final String stage;

  const HFApiException({
    required this.message,
    required this.stage,
    this.statusCode,
  });

  @override
  String toString() => 'HFApiException[$stage]: $message (HTTP $statusCode)';
}

/// Hugging Face Inference Router service.
/// All API calls go directly from the phone to HF — no backend.
class HuggingFaceService {
  static const _baseUrl = 'https://router.huggingface.co';
  static const _whisperUrl = '$_baseUrl/hf-inference/models/openai/whisper-large-v3';
  static const _chatUrl = '$_baseUrl/v1/chat/completions';
  static const _helsinkiUrl = '$_baseUrl/hf-inference/models/Helsinki-NLP/opus-mt-en-de';

  /// TTS models tried in order — suno/bark is NOT supported by hf-inference.
  /// facebook/mms-tts-deu is the German MMS-TTS model supported by hf-inference.
  static const _ttsUrls = [
    '$_baseUrl/hf-inference/models/facebook/mms-tts-deu',
    '$_baseUrl/hf-inference/models/facebook/mms-tts-eng', // English fallback
  ];

  /// Ordered fallback chain — tries each model in sequence
  static const _llmModels = [
    'Qwen/Qwen2.5-72B-Instruct',
    'meta-llama/Llama-3.3-70B-Instruct',
    'mistralai/Mistral-Small-24B-Instruct-2501',
  ];

  late final Dio _dio;

  HuggingFaceService(String token) {
    _dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 90),
      headers: {'Authorization': 'Bearer $token'},
    ));
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Stage 1: Speech → Text (Whisper)
  // ──────────────────────────────────────────────────────────────────────────

  /// OpenAI-compatible transcription endpoint — supports `language` parameter
  /// to force German transcription regardless of the speaker's accent.
  static const _whisperTranscriptionUrl = '$_baseUrl/v1/audio/transcriptions';

  /// Detects non-Latin script (Arabic, Devanagari, etc.) that indicates
  /// Whisper misidentified the language.
  static final _nonLatinPattern = RegExp(
    r'[\u0600-\u06FF'   // Arabic (Urdu uses this)
    r'\u0900-\u097F'    // Devanagari (Hindi)
    r'\u0980-\u09FF'    // Bengali
    r'\u0A00-\u0A7F'    // Gurmukhi
    r'\u4E00-\u9FFF'    // CJK
    r'\u3040-\u309F'    // Hiragana
    r'\u30A0-\u30FF'    // Katakana
    r'\uAC00-\uD7AF]', // Korean
  );

  Future<String> transcribeAudio(Uint8List bytes) async {
    const stage = 'Transcribing';

    // ── Attempt 1: OpenAI-compatible endpoint with language=de ────────────
    try {
      final transcript = await _transcribeWithLanguage(bytes, stage);
      if (!_nonLatinPattern.hasMatch(transcript)) {
        return transcript;
      }
      debugPrint('[$stage] Non-Latin script detected in transcript, retrying...');
    } catch (e) {
      debugPrint('[$stage] OpenAI-compat endpoint failed: $e — falling back');
    }

    // ── Attempt 2: Legacy raw-bytes endpoint (fallback) ──────────────────
    try {
      final transcript = await _transcribeLegacy(bytes, stage);
      if (!_nonLatinPattern.hasMatch(transcript)) {
        return transcript;
      }
      // Both attempts returned non-German script — return with warning
      debugPrint('[$stage] Both attempts returned non-Latin script');
      return transcript;
    } catch (e) {
      throw HFApiException(
        stage: stage,
        message: 'Could not transcribe audio. Please try again.',
      );
    }
  }

  /// Uses the OpenAI-compatible `/v1/audio/transcriptions` endpoint
  /// which accepts a `language` parameter to force German.
  Future<String> _transcribeWithLanguage(Uint8List bytes, String stage) async {
    return _withRetry(stage, () async {
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(bytes, filename: 'audio.wav'),
        'model': 'openai/whisper-large-v3',
        'language': 'de',
        'response_format': 'json',
      });

      final response = await _dio.post<dynamic>(
        _whisperTranscriptionUrl,
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
          responseType: ResponseType.json,
        ),
      );
      final data = response.data;
      if (data is Map && data.containsKey('text')) {
        return data['text'] as String;
      }
      throw HFApiException(stage: stage, message: 'Unexpected Whisper response: $data');
    });
  }

  /// Legacy raw-bytes Whisper endpoint (no language forcing).
  Future<String> _transcribeLegacy(Uint8List bytes, String stage) async {
    return _withRetry(stage, () async {
      final response = await _dio.post<dynamic>(
        _whisperUrl,
        data: bytes,
        options: Options(
          headers: {'Content-Type': 'audio/wav'},
          responseType: ResponseType.json,
        ),
      );
      final data = response.data;
      if (data is Map && data.containsKey('text')) {
        return data['text'] as String;
      }
      throw HFApiException(stage: stage, message: 'Unexpected Whisper response: $data');
    });
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Stage 2a: Full LLM tutoring with ordered model fallback
  // ──────────────────────────────────────────────────────────────────────────
  Future<TranslationResult> translateWithTutor(String englishText) async {
    const stage = 'Translating';
    const systemPrompt =
        'You are a German language tutor helping an English speaking beginner who has never studied '
        'German before. Given an English sentence, respond with only valid JSON in this exact shape, '
        'no extra text: { "german_informal": "the natural German translation using du", '
        '"german_formal": "the same meaning using Sie, for formal situations", '
        '"word_gloss": [ { "de": "German word", "en": "its English meaning" }, ... '
        'in the order the German words appear in german_informal ], '
        '"grammar_note": "one short sentence pointing out the single most useful grammar point in '
        'this sentence for a beginner, such as word order, case, or verb position", '
        '"alternate_phrasing": "one other natural way a German speaker might say the same thing" } '
        'Keep every field short. Write for someone who has zero prior German knowledge.';

    Exception? lastError;

    for (final model in _llmModels) {
      try {
        return await _withRetry(stage, () async {
          final response = await _dio.post<dynamic>(
            _chatUrl,
            data: jsonEncode({
              'model': model,
              'messages': [
                {'role': 'system', 'content': systemPrompt},
                {'role': 'user', 'content': englishText},
              ],
            }),
            options: Options(
              headers: {'Content-Type': 'application/json'},
              responseType: ResponseType.json,
            ),
          );
          final raw = response.data;
          final content = raw['choices'][0]['message']['content'] as String;
          final jsonMap = _extractJson(content);
          return TranslationResult.fromLlmJson(
            englishText: englishText,
            json: jsonMap,
          );
        });
      } catch (e) {
        debugPrint('LLM model $model failed: $e — trying next model');
        lastError = e is Exception ? e : Exception(e.toString());
      }
    }

    throw HFApiException(
      stage: stage,
      message: 'All translation models failed. Last error: $lastError',
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Stage 2b: Lightweight Helsinki-NLP translate (no gloss/grammar)
  // ──────────────────────────────────────────────────────────────────────────
  Future<TranslationResult> translateLightweight(String englishText) async {
    const stage = 'Translating';
    return _withRetry(stage, () async {
      final response = await _dio.post<dynamic>(
        _helsinkiUrl,
        data: jsonEncode({'inputs': englishText}),
        options: Options(
          headers: {'Content-Type': 'application/json'},
          responseType: ResponseType.json,
        ),
      );
      final data = response.data;
      if (data is! List || data.isEmpty || data[0] is! Map) {
        throw HFApiException(
          stage: stage,
          message: 'Unexpected translation response format: $data',
        );
      }
      final first = data[0] as Map;
      final translationText = first['translation_text'] as String? ?? '';
      if (translationText.isEmpty) {
        throw HFApiException(
          stage: stage,
          message: 'Translation returned empty result.',
        );
      }
      return TranslationResult.lightweight(
        englishText: englishText,
        germanInformal: translationText,
      );
    });
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Stage 3: German Text → Speech (facebook/mms-tts-deu with fallback)
  // ──────────────────────────────────────────────────────────────────────────
  Future<Uint8List> synthesizeSpeech(String germanText) async {
    const stage = 'Generating audio';
    Exception? lastError;

    for (final ttsUrl in _ttsUrls) {
      try {
        return await _withRetry(stage, () async {
          final response = await _dio.post<List<int>>(
            ttsUrl,
            data: jsonEncode({'inputs': germanText}),
            options: Options(
              headers: {'Content-Type': 'application/json'},
              responseType: ResponseType.bytes,
            ),
          );
          return Uint8List.fromList(response.data!);
        });
      } catch (e) {
        debugPrint('[TTS] Model $ttsUrl failed: $e — trying next TTS model');
        lastError = e is Exception ? e : Exception(e.toString());
      }
    }

    throw HFApiException(
      stage: stage,
      message: 'All TTS models failed. Last error: $lastError',
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Internal helpers
  // ──────────────────────────────────────────────────────────────────────────

  /// One automatic retry after a short delay before surfacing the error.
  Future<T> _withRetry<T>(String stage, Future<T> Function() call) async {
    try {
      return await call();
    } on DioException catch (e) {
      final code = e.response?.statusCode;
      final bodyStr = _responseBody(e);
      debugPrint('[$stage] HTTP ${code ?? "—"} failed$bodyStr');

      if (code == 503 || code == 429 || e.type == DioExceptionType.connectionTimeout) {
        debugPrint('[$stage] Retrying after transient error (HTTP $code)...');
        await Future.delayed(const Duration(seconds: 5));
        try {
          return await call();
        } on DioException catch (e2) {
          throw HFApiException(
            stage: stage,
            message: _friendlyMessage(e2),
            statusCode: e2.response?.statusCode,
          );
        }
      }
      throw HFApiException(
        stage: stage,
        message: _friendlyMessage(e),
        statusCode: code,
      );
    }
  }

  String _responseBody(DioException e) {
    final data = e.response?.data;
    if (data == null) return '';
    if (data is String) return data;
    try {
      return jsonEncode(data);
    } catch (_) {
      return data.toString();
    }
  }

  String _friendlyMessage(DioException e) {
    final code = e.response?.statusCode;
    final body = _responseBody(e);
    final suffix = body.isNotEmpty ? '\nServer response: $body' : '';
    return switch (code) {
      503 => 'The AI model is warming up. Please wait a moment and try again.$suffix',
      401 => 'Invalid Hugging Face token. Please check your token in Settings.$suffix',
      429 => 'Too many requests. Please wait a moment and try again.$suffix',
      _ => switch (e.type) {
          DioExceptionType.connectionTimeout ||
          DioExceptionType.receiveTimeout =>
            'Connection timed out. Check your internet connection and try again.',
          _ => 'Network error (HTTP ${code ?? "?"}): ${e.message ?? "Unknown error"}$suffix',
        },
    };
  }

  /// Extracts a JSON object from LLM output that may contain prose or markdown fences.
  Map<String, dynamic> _extractJson(String text) {
    // Strip markdown code fences
    var cleaned = text
        .replaceAll(RegExp(r'```json', multiLine: true), '')
        .replaceAll(RegExp(r'```', multiLine: true), '')
        .trim();

    // Find the outermost { }
    final start = cleaned.indexOf('{');
    final end = cleaned.lastIndexOf('}');
    if (start == -1 || end == -1 || end <= start) {
      throw const HFApiException(
        stage: 'Translating',
        message: 'Could not parse the translation response. Please try again.',
      );
    }
    cleaned = cleaned.substring(start, end + 1);
    try {
      return jsonDecode(cleaned) as Map<String, dynamic>;
    } catch (_) {
      throw const HFApiException(
        stage: 'Translating',
        message: 'Received an unexpected response format. Please try again.',
      );
    }
  }
}
