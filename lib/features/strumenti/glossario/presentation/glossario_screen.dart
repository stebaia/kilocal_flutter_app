import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../l10n/app_localizations.dart';
import 'cubit/glossario_cubit.dart';
import 'widgets/glossario_entry_card.dart';
import 'widgets/glossario_letter_grid.dart';

/// Strumenti > Glossario: searchable list of terms with an A-Z filter and
/// expandable definitions.
class GlossarioScreen extends StatelessWidget {
  const GlossarioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<GlossarioCubit>()..load(),
      child: const _GlossarioView(),
    );
  }
}

class _GlossarioView extends StatefulWidget {
  const _GlossarioView();

  @override
  State<_GlossarioView> createState() => _GlossarioViewState();
}

class _GlossarioViewState extends State<_GlossarioView> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<GlossarioCubit, GlossarioState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            top: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppHeader(
                  title: state.content.title ?? l10n.strumentiGlossario,
                  showBack: true,
                ),
                Expanded(child: _body(context, state)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _body(BuildContext context, GlossarioState state) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<GlossarioCubit>();

    if (state.status == GlossarioStatus.loading ||
        state.status == GlossarioStatus.initial) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == GlossarioStatus.error) {
      return _Message(
        text: l10n.glossarioLoadError,
        action: TextButton(onPressed: cubit.load, child: Text(l10n.retry)),
      );
    }

    if (state.content.isToolBlocked) {
      return _Message(text: l10n.galleryToolBlocked);
    }

    final results = state.results;
    final available = state.entries.map((e) => e.initial).toSet();

    // One scroll view: the letter grid scrolls away with the results rather
    // than pinning a large block to the top of a small screen.
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenGutter,
            AppSpacing.spaceLg,
            AppSpacing.screenGutter,
            0,
          ),
          sliver: SliverList.list(
            children: [
              _SearchBar(
                controller: _searchController,
                hint: state.content.searchPlaceholder ?? l10n.glossarioSearchHint,
                onSubmitted: cubit.search,
              ),
              const SizedBox(height: AppSpacing.spaceLg),
              const Divider(height: 1, color: AppColors.divider),
              const SizedBox(height: AppSpacing.spaceLg),
              GlossarioLetterGrid(
                selected: state.query.isEmpty ? state.letter : null,
                available: available,
                onSelected: (letter) {
                  // Selecting a letter cancels the search, so clear the field
                  // too or it would contradict the results below.
                  _searchController.clear();
                  cubit.selectLetter(letter);
                },
              ),
              const SizedBox(height: AppSpacing.spaceLg),
              Text(
                l10n.glossarioResults,
                style: AppTypography.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.spaceXs),
              const Divider(height: 1, color: AppColors.divider),
              const SizedBox(height: AppSpacing.spaceMd),
            ],
          ),
        ),
        if (results.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.screenGutter),
              child: Text(
                l10n.glossarioEmpty,
                textAlign: TextAlign.center,
                style: AppTypography.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenGutter,
              0,
              AppSpacing.screenGutter,
              AppSpacing.spaceXl,
            ),
            sliver: SliverList.separated(
              itemCount: results.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: AppSpacing.spaceSm),
              itemBuilder: (context, index) {
                final entry = results[index];
                return GlossarioEntryCard(
                  entry: entry,
                  isExpanded: state.expandedId == entry.id,
                  onTap: () => cubit.toggleExpanded(entry.id),
                );
              },
            ),
          ),
      ],
    );
  }
}

/// Search field plus the dark "Cerca" pill.
class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.hint,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            textInputAction: TextInputAction.search,
            onSubmitted: onSubmitted,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTypography.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
              filled: true,
              fillColor: AppColors.surface,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.spaceMd,
                vertical: AppSpacing.spaceSm,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                borderSide: const BorderSide(color: AppColors.borderCard),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                borderSide: const BorderSide(color: AppColors.borderCard),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                borderSide: const BorderSide(color: AppColors.accent),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.spaceSm),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.ink,
            foregroundColor: AppColors.neutralWhite,
            // The app theme makes buttons full-width (minimumSize
            // Size.fromHeight = infinite width). Inside a Row, whose non-flex
            // children get unbounded width, that forces an infinite layout and
            // takes the whole screen down — so pin a finite minimum here.
            minimumSize: const Size(0, 44),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.spaceMd,
              vertical: AppSpacing.spaceSm + 2,
            ),
          ),
          iconAlignment: IconAlignment.end,
          icon: const Icon(Icons.search, size: 18),
          onPressed: () => onSubmitted(controller.text),
          label: Text(l10n.glossarioSearch),
        ),
      ],
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.text, this.action});

  final String text;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenGutter),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              textAlign: TextAlign.center,
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            if (action != null) ...[
              const SizedBox(height: AppSpacing.spaceMd),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
