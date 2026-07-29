import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/integrazione_data.dart';

/// A supplement card on the phase detail screen: a red gradient header (info
/// button, title, product image), the monitoring label + `taken/total`,
/// a row of progress dots and the "mark as taken" button.
class IntegrazioneProductCard extends StatelessWidget {
  const IntegrazioneProductCard({
    super.key,
    required this.product,
    required this.onInfoTap,
    required this.onMarkTaken,
    required this.onUnmarkTaken,
  });

  final IntegrazioneProduct product;
  final VoidCallback onInfoTap;
  final VoidCallback onMarkTaken;

  /// Undoes today's intake — the "Preso oggi" CTA must be reversible.
  final VoidCallback onUnmarkTaken;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final total = product.durationDays;
    final taken = product.takenCount.clamp(0, total == 0 ? 0 : total);
    final takenToday = product.takenToday(DateTime.now());

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(product: product, onInfoTap: onInfoTap),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.spaceMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _monitoringLabel(l10n, total),
                        style: AppTypography.textTheme.titleMedium,
                      ),
                    ),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '$taken',
                            style: AppTypography.textTheme.titleMedium
                                ?.copyWith(
                                  color: AppColors.accent,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          TextSpan(
                            text: '/$total',
                            style: AppTypography.textTheme.titleMedium
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.spaceSm),
                _ProgressDots(taken: taken, total: total),
                const SizedBox(height: AppSpacing.spaceMd),
                _MarkTakenButton(
                  takenToday: takenToday,
                  label: takenToday
                      ? l10n.integrationTakenToday
                      : l10n.integrationMarkTaken,
                  onTap: takenToday ? onUnmarkTaken : onMarkTaken,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _monitoringLabel(AppLocalizations l10n, int days) {
    // Prefer whole weeks when the duration divides evenly (matches the mockup's
    // "Monitoraggio 2 settimane"); otherwise fall back to days.
    if (days > 0 && days % 7 == 0) {
      return l10n.integrationMonitoringWeeks(days ~/ 7);
    }
    return l10n.integrationMonitoringDays(days);
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.product, required this.onInfoTap});

  final IntegrazioneProduct product;
  final VoidCallback onInfoTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      decoration: BoxDecoration(
        gradient: AppColors.brandGradientVertical,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      padding: const EdgeInsets.all(AppSpacing.spaceMd),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoButton(onTap: onInfoTap),
                const Spacer(),
                Text(
                  product.title,
                  style: AppTypography.textTheme.titleLarge?.copyWith(
                    color: AppColors.neutralWhite,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.spaceSm),
          if (product.imageUrl != null)
            SizedBox(
              width: 100,
              child: Image.network(
                product.imageUrl!,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
            ),
        ],
      ),
    );
  }
}

class _InfoButton extends StatelessWidget {
  const _InfoButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: const BoxDecoration(
          color: AppColors.neutralWhite,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.info_outline,
          color: AppColors.accent,
          size: 20,
        ),
      ),
    );
  }
}

/// Row of small circles, filled up to [taken] out of [total].
class _ProgressDots extends StatelessWidget {
  const _ProgressDots({required this.taken, required this.total});

  final int taken;
  final int total;

  @override
  Widget build(BuildContext context) {
    if (total <= 0) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 4.0;
        // Size dots to fit the row width; clamp so they stay legible.
        final raw = (constraints.maxWidth - spacing * (total - 1)) / total;
        final size = raw.clamp(6.0, 16.0);
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: List.generate(total, (i) {
            final filled = i < taken;
            // The first not-yet-taken dot gets an outlined "next" style.
            final isNext = i == taken;
            return Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: filled ? AppColors.accent : AppColors.neutralWhite,
                border: Border.all(
                  color: (filled || isNext)
                      ? AppColors.accent
                      : AppColors.borderCard,
                  width: 1.5,
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

/// "Segna integrato come preso" / "Preso oggi" CTA, matching the Figma states:
/// an outlined red button before today's intake is logged, a solid red one
/// once it is. Both states stay tappable — the solid one undoes the intake,
/// so the action is always reversible rather than a one-way completion.
class _MarkTakenButton extends StatelessWidget {
  const _MarkTakenButton({
    required this.label,
    required this.takenToday,
    required this.onTap,
  });

  final String label;
  final bool takenToday;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textStyle = AppTypography.textTheme.titleSmall?.copyWith(
      fontWeight: FontWeight.w700,
    );

    final button = takenToday
        ? ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: AppColors.neutralWhite,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.spaceMd),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: textStyle?.copyWith(color: AppColors.neutralWhite),
                ),
                const SizedBox(width: AppSpacing.spaceXs),
                const Icon(
                  Icons.check,
                  size: 18,
                  color: AppColors.neutralWhite,
                ),
              ],
            ),
          )
        : OutlinedButton(
            onPressed: onTap,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.accent,
              side: const BorderSide(color: AppColors.accent),
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.spaceMd),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: textStyle?.copyWith(color: AppColors.accent),
                ),
                const SizedBox(width: AppSpacing.spaceXs),
                const Icon(Icons.check, size: 18, color: AppColors.accent),
              ],
            ),
          );

    return SizedBox(width: double.infinity, child: button);
  }
}
