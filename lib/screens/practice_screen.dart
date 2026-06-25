import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../data/models/translation_result.dart';
import '../providers/settings_provider.dart';
import '../services/audio_service.dart';
import '../services/hugging_face_service.dart';
import '../widgets/hairline_divider.dart';
import '../widgets/record_button.dart';

class PracticeScreen extends ConsumerStatefulWidget {
  final TranslationResult result;

  const PracticeScreen({super.key, required this.result});

  @override
  ConsumerState<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends ConsumerState<PracticeScreen> {
  final AudioService _audio = AudioService();

  bool _isRecording = false;
  bool _isProcessing = false;
  String? _errorMessage;
  List<_WordMatch>? _matches;
  double? _score;

  @override
  void dispose() {
    _audio.dispose(); // fire-and-forget, disposed in background
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final targetPhrase = widget.result.germanInformal;

    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(
        backgroundColor: AppColors.paper,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.ink),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Practice', style: AppTextStyles.screenTitle(size: 18)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),

              // ── Target phrase ──────────────────────────────────────────
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Say this in German:',
                  style: AppTextStyles.label(size: 13, color: AppColors.inkMuted),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  targetPhrase,
                  style: AppTextStyles.germanPhrase(size: 22),
                ),
              ),

              const SizedBox(height: 32),
              const HairlineDivider(),
              const SizedBox(height: 32),

              // ── Record button ──────────────────────────────────────────
              RecordButton(
                isRecording: _isRecording,
                isLoading: _isProcessing,
                size: 72,
                onTap: _isProcessing ? null : _handleRecordTap,
              ),

              const SizedBox(height: 16),

              if (_isProcessing)
                Text(
                  'Analysing your pronunciation…',
                  style: AppTextStyles.label(size: 13, color: AppColors.cobalt),
                )
              else if (!_isRecording)
                Text(
                  'Tap to record your attempt',
                  style: AppTextStyles.label(size: 13, color: AppColors.inkMuted),
                ),

              const SizedBox(height: 32),

              // ── Results ────────────────────────────────────────────────
              if (_errorMessage != null)
                Text(
                  _errorMessage!,
                  style: AppTextStyles.body(size: 13, color: AppColors.brick),
                  textAlign: TextAlign.center,
                ),

              if (_matches != null && _score != null) ...[
                // Score
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${_score!.round()}%',
                      style: AppTextStyles.scoreDisplay(size: 40).copyWith(
                        color: _score! >= 75
                            ? AppColors.teal
                            : _score! >= 40
                                ? AppColors.mustard
                                : AppColors.brick,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('match',
                        style: AppTextStyles.body(
                            size: 15, color: AppColors.inkMuted)),
                  ],
                ),

                const SizedBox(height: 16),

                // Word-by-word comparison
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _matches!
                      .map((m) => Text(
                            m.word,
                            style: AppTextStyles.practiceWord(
                              size: 16,
                              color: m.matched ? AppColors.teal : AppColors.brick,
                            ),
                          ))
                      .toList(),
                ),

                const SizedBox(height: 24),

                // Try again button
                TextButton(
                  onPressed: _resetPractice,
                  child: Text(
                    'Try again',
                    style:
                        AppTextStyles.bodyMedium(size: 15, color: AppColors.cobalt),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleRecordTap() async {
    if (_isRecording) {
      // Stop and process
      setState(() {
        _isRecording = false;
        _isProcessing = true;
        _errorMessage = null;
      });

      final bytes = await _audio.stopRecordingBytes();
      if (bytes == null) {
        setState(() {
          _isProcessing = false;
          _errorMessage = 'Recording failed. Please try again.';
        });
        return;
      }

      await _processAttempt(bytes);
    } else {
      // Start recording
      final hasPermission = await _audio.hasPermission();
      if (!hasPermission) {
        setState(() => _errorMessage = 'Microphone permission denied.');
        return;
      }
      setState(() {
        _isRecording = true;
        _matches = null;
        _score = null;
      });
      await _audio.startRecording();
    }
  }

  Future<void> _processAttempt(Uint8List bytes) async {
    final settings = ref.read(settingsProvider).valueOrNull;
    final token = settings?.token ?? '';
    if (token.isEmpty) {
      setState(() {
        _isProcessing = false;
        _errorMessage = 'No Hugging Face token set. Please add it in Settings.';
      });
      return;
    }

    try {
      final hf = HuggingFaceService(token);
      final transcript = await hf.transcribeAudio(bytes);
      final matches = _compareTranscript(
        transcript,
        widget.result.germanInformal,
      );
      final score = matches.isEmpty
          ? 0.0
          : matches.where((m) => m.matched).length / matches.length * 100;

      setState(() {
        _isProcessing = false;
        _matches = matches;
        _score = score;
      });
    } on HFApiException catch (e) {
      setState(() {
        _isProcessing = false;
        _errorMessage = e.message;
      });
    } catch (_) {
      setState(() {
        _isProcessing = false;
        _errorMessage = 'Could not analyze your attempt. Please try again.';
      });
    }
  }

  /// Word-level edit distance comparison.
  List<_WordMatch> _compareTranscript(String attempt, String target) {
    final attemptWords = _normalize(attempt);
    final targetWords = _normalize(target);

    return targetWords.asMap().entries.map((entry) {
      final i = entry.key;
      final word = entry.value;
      final matched = i < attemptWords.length &&
          _wordsSimilar(attemptWords[i], word);
      return _WordMatch(word: word, matched: matched);
    }).toList();
  }

  List<String> _normalize(String s) => s
      .toLowerCase()
      .replaceAll(RegExp(r'[^\w\s]'), '')
      .split(RegExp(r'\s+'))
      .where((w) => w.isNotEmpty)
      .toList();

  bool _wordsSimilar(String a, String b) {
    if (a == b) return true;
    if (a.isEmpty || b.isEmpty) return false;
    // Allow minor edit distance (Levenshtein ≤ 2)
    return _levenshtein(a, b) <= 2;
  }

  int _levenshtein(String s, String t) {
    if (s == t) return 0;
    if (s.isEmpty) return t.length;
    if (t.isEmpty) return s.length;
    final d = List.generate(s.length + 1, (i) => List.filled(t.length + 1, 0));
    for (int i = 0; i <= s.length; i++) {
      d[i][0] = i;
    }
    for (int j = 0; j <= t.length; j++) {
      d[0][j] = j;
    }
    for (int i = 1; i <= s.length; i++) {
      for (int j = 1; j <= t.length; j++) {
        d[i][j] = s[i - 1] == t[j - 1]
            ? d[i - 1][j - 1]
            : 1 + [d[i - 1][j], d[i][j - 1], d[i - 1][j - 1]].reduce((a, b) => a < b ? a : b);
      }
    }
    return d[s.length][t.length];
  }

  void _resetPractice() {
    setState(() {
      _matches = null;
      _score = null;
      _errorMessage = null;
    });
  }
}

class _WordMatch {
  final String word;
  final bool matched;

  const _WordMatch({required this.word, required this.matched});
}
