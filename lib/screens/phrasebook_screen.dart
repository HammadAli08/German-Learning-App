import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../data/models/phrase_model.dart';
import '../providers/phrasebook_provider.dart';
import '../providers/pipeline_provider.dart';
import '../widgets/hairline_divider.dart';
import 'result_screen.dart';

class PhrasebookScreen extends ConsumerStatefulWidget {
  const PhrasebookScreen({super.key});

  @override
  ConsumerState<PhrasebookScreen> createState() => _PhrasebookScreenState();
}

class _PhrasebookScreenState extends ConsumerState<PhrasebookScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allPhrases = ref.watch(phrasebookProvider);
    final displayed = _query.isEmpty
        ? allPhrases
        : allPhrases.where((p) {
            final q = _query.toLowerCase();
            return p.englishText.toLowerCase().contains(q) ||
                p.germanInformal.toLowerCase().contains(q);
          }).toList();

    return Scaffold(
      backgroundColor: AppColors.paper,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
              child: Text('Phrasebook', style: AppTextStyles.screenTitle(size: 22)),
            ),

            // ── Search ───────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _query = v),
                style: AppTextStyles.body(size: 15),
                decoration: InputDecoration(
                  hintText: 'Search phrases…',
                  hintStyle:
                      AppTextStyles.body(size: 15, color: AppColors.inkMuted),
                  prefixIcon:
                      const Icon(Icons.search, color: AppColors.inkMuted, size: 20),
                  suffixIcon: _query.isNotEmpty
                      ? GestureDetector(
                          onTap: () {
                            _searchController.clear();
                            setState(() => _query = '');
                          },
                          child: const Icon(Icons.close,
                              color: AppColors.inkMuted, size: 18),
                        )
                      : null,
                  border: const UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.hairline),
                  ),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.hairline),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.cobalt, width: 2),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),
            const HairlineDivider(),

            // ── List ─────────────────────────────────────────────────────
            if (displayed.isEmpty)
              Expanded(
                child: Center(
                  child: Text(
                    _query.isEmpty
                        ? 'No saved phrases yet.\nRecord something to get started.'
                        : 'No phrases match "$_query".',
                    style: AppTextStyles.body(
                        size: 14, color: AppColors.inkMuted),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.separated(
                  itemCount: displayed.length,
                  separatorBuilder: (_, __) => const HairlineDivider(),
                  itemBuilder: (context, i) =>
                      _PhraseRow(phrase: displayed[i]),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PhraseRow extends ConsumerWidget {
  final PhraseModel phrase;

  const _PhraseRow({required this.phrase});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: ValueKey(phrase.key),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        color: AppColors.brick.withValues(alpha: 0.12),
        child: const Icon(Icons.delete_outline, color: AppColors.brick, size: 22),
      ),
      confirmDismiss: (_) => _confirmDelete(context),
      onDismissed: (_) {
        ref.read(phrasebookProvider.notifier).deletePhrase(phrase);
      },
      child: ListTile(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ResultScreen(phrase: phrase),
            ),
          );
        },
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        title: Text(
          phrase.englishText,
          style: AppTextStyles.body(size: 14, color: AppColors.ink),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(
            phrase.germanInformal,
            style: AppTextStyles.screenTitle(size: 14).copyWith(
              color: AppColors.ink,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        trailing: GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ResultScreen(phrase: phrase),
              ),
            );
          },
          child: const Icon(
            Icons.play_circle_outline_rounded,
            color: AppColors.cobalt,
            size: 28,
          ),
        ),
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: AppColors.paper,
            title: Text('Delete phrase?',
                style: AppTextStyles.screenTitle(size: 16)),
            content: Text(
              'This will remove "${phrase.englishText}" from your phrasebook.',
              style: AppTextStyles.body(size: 14),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: Text('Cancel',
                    style: AppTextStyles.bodyMedium(
                        size: 14, color: AppColors.inkMuted)),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: Text('Delete',
                    style: AppTextStyles.bodyMedium(
                        size: 14, color: AppColors.brick)),
              ),
            ],
          ),
        ) ??
        false;
  }
}
