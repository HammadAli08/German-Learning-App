import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../providers/settings_provider.dart';
import '../widgets/hairline_divider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _tokenController = TextEditingController();
  bool _tokenVisible = false;

  @override
  void initState() {
    super.initState();
    final token = ref.read(settingsProvider).valueOrNull?.token ?? '';
    _tokenController.text = token;
  }

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider).valueOrNull ?? const AppSettings();

    return Scaffold(
      backgroundColor: AppColors.paper,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
              child: Text('Settings', style: AppTextStyles.screenTitle(size: 22)),
            ),
            const HairlineDivider(),
            Expanded(
              child: ListView(
                children: [
                  // ── HF Token ────────────────────────────────────────────
                  const _SectionHeader(label: 'Hugging Face'),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Personal Access Token',
                            style: AppTextStyles.body(size: 14, color: AppColors.inkMuted)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _tokenController,
                          obscureText: !_tokenVisible,
                          style: AppTextStyles.body(size: 14),
                          onSubmitted: (v) =>
                              ref.read(settingsProvider.notifier).setToken(v.trim()),
                          decoration: InputDecoration(
                            hintText: 'hf_…',
                            hintStyle: AppTextStyles.body(size: 14, color: AppColors.inkMuted),
                            suffixIcon: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(_tokenVisible
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                      size: 18, color: AppColors.inkMuted),
                                  onPressed: () =>
                                      setState(() => _tokenVisible = !_tokenVisible),
                                ),
                                TextButton(
                                  onPressed: () => ref
                                      .read(settingsProvider.notifier)
                                      .setToken(_tokenController.text.trim()),
                                  child: Text('Save',
                                      style: AppTextStyles.bodyMedium(
                                          size: 13, color: AppColors.cobalt)),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Get a free token at huggingface.co/settings/tokens',
                          style: AppTextStyles.label(size: 12, color: AppColors.inkMuted),
                        ),
                      ],
                    ),
                  ),

                  const HairlineDivider(),

                  // ── Translation ──────────────────────────────────────────
                  const _SectionHeader(label: 'Translation'),
                  _ToggleRow(
                    label: 'Formal German as default',
                    sublabel: 'Uses Sie instead of du',
                    value: settings.formalDefault,
                    onChanged: (v) =>
                        ref.read(settingsProvider.notifier).setFormalDefault(v),
                  ),
                  const HairlineDivider(indent: 24),
                  _ToggleRow(
                    label: 'Lightweight mode',
                    sublabel: 'Faster, no grammar notes or gloss',
                    value: settings.lightweightMode,
                    onChanged: (v) =>
                        ref.read(settingsProvider.notifier).setLightweightMode(v),
                  ),

                  const HairlineDivider(),

                  // ── Playback ─────────────────────────────────────────────
                  const _SectionHeader(label: 'Playback'),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Default speed',
                            style: AppTextStyles.body(size: 14, color: AppColors.ink)),
                        const SizedBox(height: 12),
                        _SpeedSegmentedControl(
                          value: settings.defaultPlaybackSpeed,
                          onChanged: (v) => ref
                              .read(settingsProvider.notifier)
                              .setDefaultPlaybackSpeed(v),
                        ),
                      ],
                    ),
                  ),

                  const HairlineDivider(),

                  // ── Practice ─────────────────────────────────────────────
                  const _SectionHeader(label: 'Practice'),
                  _ToggleRow(
                    label: 'Prompt before saving',
                    sublabel: 'Asks if you want to practice first',
                    value: settings.requirePracticeBeforeSave,
                    onChanged: (v) => ref
                        .read(settingsProvider.notifier)
                        .setRequirePractice(v),
                  ),

                  const HairlineDivider(),
                  const SizedBox(height: 32),

                  // ── About ────────────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'GermanLoop v1.0\nAll API calls go directly to Hugging Face. No data is stored on any server.',
                      style: AppTextStyles.label(size: 12, color: AppColors.inkMuted),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
      child: Text(label,
          style: AppTextStyles.label(size: 11, color: AppColors.inkMuted)
              .copyWith(letterSpacing: 0.8)),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String label;
  final String sublabel;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.label,
    required this.sublabel,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.body(size: 14, color: AppColors.ink)),
                Text(sublabel, style: AppTextStyles.label(size: 12, color: AppColors.inkMuted)),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _SpeedSegmentedControl extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;

  const _SpeedSegmentedControl({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final options = [0.5, 0.75, 1.0];
    final labels = ['0.5×', '0.75×', '1×'];

    return Row(
      children: [
        for (int i = 0; i < options.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          GestureDetector(
            onTap: () => onChanged(options[i]),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: value == options[i] ? AppColors.cobalt : Colors.transparent,
                border: Border.all(
                  color: value == options[i] ? AppColors.cobalt : AppColors.hairline,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                labels[i],
                style: AppTextStyles.bodyMedium(
                  size: 13,
                  color: value == options[i] ? Colors.white : AppColors.inkMuted,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
