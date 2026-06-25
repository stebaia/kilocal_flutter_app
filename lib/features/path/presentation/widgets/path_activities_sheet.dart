import 'package:flutter/material.dart';

import '../../../../app/di.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/vimeo_oembed_service.dart';
import '../../domain/entities/path_area_detail.dart';

/// Bottom sheet listing the activities (steps) of a timeframe, with the active
/// step highlighted. Tapping a step closes the sheet and returns it.
Future<PathStepItem?> showPathActivitiesSheet(
  BuildContext context, {
  required List<PathStepItem> steps,
  required String currentStepId,
}) {
  return showModalBottomSheet<PathStepItem>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
    ),
    builder: (_) =>
        _PathActivitiesSheet(steps: steps, currentStepId: currentStepId),
  );
}

class _PathActivitiesSheet extends StatelessWidget {
  const _PathActivitiesSheet({
    required this.steps,
    required this.currentStepId,
  });

  final List<PathStepItem> steps;
  final String currentStepId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenGutter,
                AppSpacing.spaceLg,
                AppSpacing.screenGutter,
                AppSpacing.spaceSm,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.pathActivitiesTitle,
                    style: AppTypography.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    l10n.pathActivitiesTotal(steps.length),
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.divider),
            Expanded(
              child: ListView.separated(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenGutter,
                  vertical: AppSpacing.spaceMd,
                ),
                itemCount: steps.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.spaceMd),
                itemBuilder: (context, index) {
                  final step = steps[index];
                  return _ActivityCard(
                    index: index + 1,
                    step: step,
                    onTap: step.isLocked
                        ? null
                        : () => Navigator.of(context).pop(step),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.index, required this.step, this.onTap});

  final int index;
  final PathStepItem step;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDone = step.isCompleted;
    final background = isDone ? AppColors.accentSoft : AppColors.background;

    return Opacity(
      opacity: step.isLocked ? 0.6 : 1,
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.spaceSm),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _IndexBadge(index: index),
                const SizedBox(width: AppSpacing.spaceMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _DurationLabel(step: step),
                      const SizedBox(height: 2),
                      Text(
                        step.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.spaceSm),
                      _ProgressLine(step: step),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.spaceSm),
                _TrailingStatus(step: step),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IndexBadge extends StatelessWidget {
  const _IndexBadge({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      alignment: Alignment.center,
      child: Text(
        '$index',
        style: AppTypography.textTheme.headlineSmall?.copyWith(
          color: AppColors.neutralWhite,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Fetches the step video duration lazily via Vimeo oEmbed.
class _DurationLabel extends StatefulWidget {
  const _DurationLabel({required this.step});

  final PathStepItem step;

  @override
  State<_DurationLabel> createState() => _DurationLabelState();
}

class _DurationLabelState extends State<_DurationLabel> {
  String? _label;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    final url = widget.step.asset.vimeoUrl;
    if (url == null || !widget.step.asset.isVideo) return;
    final data = await getIt<VimeoOembedService>().fetch(url);
    final d = data?.duration;
    if (d != null && mounted) {
      final m = d.inMinutes;
      final s = (d.inSeconds % 60).toString().padLeft(2, '0');
      setState(() => _label = '$m:$s min');
    }
  }

  @override
  Widget build(BuildContext context) {
    final label = _label;
    if (label == null) return const SizedBox.shrink();
    return Text(
      label,
      style: AppTypography.textTheme.labelSmall?.copyWith(
        color: AppColors.textSecondary,
      ),
    );
  }
}

class _ProgressLine extends StatelessWidget {
  const _ProgressLine({required this.step});

  final PathStepItem step;

  @override
  Widget build(BuildContext context) {
    // A step is binary (done / not done): the backend exposes no per-step
    // percentage, so the bar is full when completed and empty otherwise.
    final double value = step.isCompleted ? 1 : 0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: LinearProgressIndicator(
        value: value,
        minHeight: 4,
        backgroundColor: AppColors.divider,
        valueColor: const AlwaysStoppedAnimation(AppColors.accent),
      ),
    );
  }
}

class _TrailingStatus extends StatelessWidget {
  const _TrailingStatus({required this.step});

  final PathStepItem step;

  @override
  Widget build(BuildContext context) {
    if (step.isCompleted) {
      return const Icon(Icons.check, size: 20, color: AppColors.accent);
    }
    if (step.isLocked) {
      return const Icon(
        Icons.lock_outline,
        size: 20,
        color: AppColors.textSecondary,
      );
    }
    if (step.isCurrent) {
      return const Icon(
        Icons.play_circle_fill,
        size: 20,
        color: AppColors.accent,
      );
    }
    return const SizedBox(width: 20);
  }
}
