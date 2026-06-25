import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/phrase_model.dart';
import '../data/models/translation_result.dart';
import '../services/audio_service.dart';
import '../services/hugging_face_service.dart';
import '../services/tts_service.dart';
import 'settings_provider.dart';

/// Represents which stage the pipeline is currently in.
enum PipelineStage {
  idle,
  recording,
  transcribing,
  translating,
  generatingAudio,
  done,
  error,
}

class PipelineState {
  final PipelineStage stage;
  final TranslationResult? result;
  final String? errorMessage;
  final String? transcript;

  const PipelineState({
    this.stage = PipelineStage.idle,
    this.result,
    this.errorMessage,
    this.transcript,
  });

  PipelineState copyWith({
    PipelineStage? stage,
    TranslationResult? result,
    String? errorMessage,
    String? transcript,
  }) =>
      PipelineState(
        stage: stage ?? this.stage,
        result: result ?? this.result,
        errorMessage: errorMessage ?? this.errorMessage,
        transcript: transcript ?? this.transcript,
      );

  String get stageLabel => switch (stage) {
        PipelineStage.idle => '',
        PipelineStage.recording => 'Recording…',
        PipelineStage.transcribing => 'Transcribing',
        PipelineStage.translating => 'Translating',
        PipelineStage.generatingAudio => 'Generating audio',
        PipelineStage.done => '',
        PipelineStage.error => 'Error',
      };

  bool get isLoading => stage == PipelineStage.transcribing ||
      stage == PipelineStage.translating ||
      stage == PipelineStage.generatingAudio;
}

class PipelineNotifier extends Notifier<PipelineState> {
  final AudioService _audio = AudioService();
  final TtsService _tts = TtsService();

  @override
  PipelineState build() {
    ref.onDispose(() async {
      await _audio.dispose();
      _tts.dispose();
    });
    return const PipelineState();
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Recording lifecycle
  // ──────────────────────────────────────────────────────────────────────────
  Future<void> startRecording() async {
    final hasPermission = await _audio.hasPermission();
    if (!hasPermission) {
      state = state.copyWith(
        stage: PipelineStage.error,
        errorMessage: 'Microphone permission denied. Please allow access in Settings.',
      );
      return;
    }
    await _audio.startRecording();
    state = state.copyWith(stage: PipelineStage.recording, errorMessage: null);
  }

  Future<void> stopRecordingAndProcess() async {
    final audioBytes = await _audio.stopRecordingBytes();
    if (audioBytes == null) {
      state = state.copyWith(
        stage: PipelineStage.error,
        errorMessage: 'Recording failed. Please try again.',
      );
      return;
    }
    await _runPipeline(audioBytes);
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Full 5-stage pipeline
  // ──────────────────────────────────────────────────────────────────────────
  Future<void> _runPipeline(Uint8List audioBytes) async {
    final settings = ref.read(settingsProvider).valueOrNull;
    final token = settings?.token ?? '';

    if (token.isEmpty) {
      state = state.copyWith(
        stage: PipelineStage.error,
        errorMessage: 'No Hugging Face token set. Please add your token in Settings.',
      );
      return;
    }

    final hf = HuggingFaceService(token);

    try {
      // Stage 1: STT
      state = state.copyWith(stage: PipelineStage.transcribing);
      final transcript = await hf.transcribeAudio(audioBytes);
      state = state.copyWith(transcript: transcript);

      // Stage 2: Translation
      state = state.copyWith(stage: PipelineStage.translating);
      TranslationResult result;
      if (settings?.lightweightMode ?? false) {
        result = await hf.translateLightweight(transcript);
      } else {
        result = await hf.translateWithTutor(transcript);
      }

      // Stage 3: TTS — device-native, no API call
      state = state.copyWith(stage: PipelineStage.generatingAudio);
      final targetText = (settings?.formalDefault ?? false)
          ? result.germanFormal
          : result.germanInformal;

      final speed = settings?.defaultPlaybackSpeed ?? 1.0;
      await _tts.speakAtSpeed(targetText, speed);

      state = PipelineState(stage: PipelineStage.done, result: result, transcript: transcript);
    } on HFApiException catch (e) {
      state = state.copyWith(
        stage: PipelineStage.error,
        errorMessage: e.message,
      );
    } catch (e, stack) {
      debugPrint('[Pipeline] Unhandled error in _runPipeline: $e\n$stack');
      state = state.copyWith(
        stage: PipelineStage.error,
        errorMessage: 'Unexpected error: ${e.toString()}',
      );
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Audio playback — uses device TTS, no audio file needed
  // ──────────────────────────────────────────────────────────────────────────
  /// Speak [germanText] at [speed]. Called by the Play / Play Slowly buttons
  /// on the result screen, passing whichever variant (formal/informal) the
  /// user is currently viewing.
  Future<void> playResult({String? germanText, double? speed}) async {
    final text = germanText ?? state.result?.germanInformal ?? '';
    if (text.isEmpty) return;
    final settings = ref.read(settingsProvider).valueOrNull;
    final playSpeed = speed ?? settings?.defaultPlaybackSpeed ?? 1.0;
    await _tts.speakAtSpeed(text, playSpeed);
  }

  Future<void> playPhrasePath(String path, {double speed = 1.0}) async {
    await _audio.playFile(path, speed: speed);
  }

  Future<void> playPhrase(PhraseModel phrase, {double speed = 1.0}) async {
    final path = phrase.cachedAudioPath;
    if (!kIsWeb && path != null && await File(path).exists()) {
      await _audio.playFile(path, speed: speed);
    } else {
      await _tts.speakAtSpeed(phrase.germanInformal, speed);
    }
  }

  void reset() => state = const PipelineState();
}

final pipelineProvider = NotifierProvider<PipelineNotifier, PipelineState>(
  PipelineNotifier.new,
);
