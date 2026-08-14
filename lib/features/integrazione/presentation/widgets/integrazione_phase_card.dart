import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/integrazione_data.dart';
import '../../../../../core/widgets/cms_image.dart';

/// Large phase card on the integrazione list.
///
/// Shows the "Fase N" pill, the phase's product illustration(s) inside a white
/// circle on a red gradient, and a white footer with the product title. When
/// [isLocked] the card is dimmed, a lock badge is shown and the footer reads
/// "Completa prima la fase N".
class IntegrazionePhaseCard extends StatelessWidget {
  const IntegrazionePhaseCard({
    super.key,
    required this.phase,
    required this.phaseNumber,
    required this.isLocked,
    required this.unlockAfterPhase,
    this.onTap,
  });

  final IntegrazionePhase phase;
  final int phaseNumber;
  final bool isLocked;

  /// Phase number the user must complete first (shown when locked).
  final int unlockAfterPhase;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final footerText = isLocked
        ? l10n.integrationCompletePhaseFirst(unlockAfterPhase)
        : _titleFor(phase);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: AppShadows.card,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 200,
              decoration: BoxDecoration(
                gradient: isLocked
                    ? _lockedGradient
                    : AppColors.brandGradientVertical,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Product illustration inside a soft circle.
                  Container(
                    width: 150,
                    height: 150,
                    decoration: const BoxDecoration(
                      color: AppColors.neutralWhite,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(AppSpacing.spaceMd),
                    child: _PhaseImages(
                      products: phase.products,
                      dimmed: isLocked,
                    ),
                  ),
                  // "Fase N" pill at the top.
                  Positioned(
                    top: AppSpacing.spaceMd,
                    child: _PhasePill(number: phaseNumber),
                  ),
                  if (isLocked) const _LockBadge(),
                ],
              ),
            ),
            // White footer with title / lock hint.
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.spaceMd,
                vertical: AppSpacing.spaceMd,
              ),
              color: AppColors.surface,
              child: Text(
                footerText,
                textAlign: TextAlign.center,
                style: AppTypography.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isLocked
                      ? AppColors.textSecondary
                      : AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _titleFor(IntegrazionePhase phase) {
    // The card headline is the phase's single product name, or a joined list.
    if (phase.products.length == 1) return phase.products.first.title;
    if (phase.products.isEmpty) return phase.title;
    return phase.products.map((p) => p.title).join(' + ');
  }

  static const _lockedGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF7A1A2B), Color(0xFF5C1420)],
  );
}

class _PhasePill extends StatelessWidget {
  const _PhasePill({required this.number});

  final int number;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.spaceMd,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: AppColors.neutralWhite,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        l10n.integrationPhaseLabel(number),
        style: AppTypography.textTheme.labelLarge?.copyWith(
          color: AppColors.accent,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _LockBadge extends StatelessWidget {
  const _LockBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: const BoxDecoration(
        color: AppColors.neutralWhite,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.lock_outline, color: AppColors.textPrimary),
    );
  }
}

/// Renders one or more product images side by side inside the circle.
class _PhaseImages extends StatelessWidget {
  const _PhaseImages({required this.products, required this.dimmed});

  final List<IntegrazioneProduct> products;
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    final withImages = products
        .where((p) => p.imageUrl != null)
        .toList(growable: false);
    if (withImages.isEmpty) {
      return const Icon(
        Icons.medication_outlined,
        color: AppColors.accent,
        size: 40,
      );
    }

    final images = withImages
        .take(3)
        .map(
          (p) => Flexible(
            child: CmsImage(
              p.imageUrl!,
              fit: BoxFit.contain,
              errorBuilder: (_) => const Icon(
                Icons.medication_outlined,
                color: AppColors.accent,
                size: 32,
              ),
            ),
          ),
        )
        .toList();

    final row = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: images,
    );

    return dimmed ? Opacity(opacity: 0.5, child: row) : row;
  }
}
