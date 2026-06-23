import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Header bianco riutilizzabile che si estende dietro la status bar.
///
/// Mostra un titolo centrabile con stile fisso, un eventuale chevron di
/// "back" a sinistra e un'azione (icona) personalizzabile a destra.
class AppHeader extends StatelessWidget {
  /// Testo del titolo.
  final String title;

  /// Se `true` mostra il chevron di back a sinistra del titolo.
  ///
  /// Quando [onBack] è `null` viene usato `Navigator.maybePop`.
  final bool showBack;

  /// Callback invocata al tap sul chevron di back.
  final VoidCallback? onBack;

  /// Widget mostrato a destra (tipicamente un'icona).
  ///
  /// Se `null` non viene mostrata alcuna azione.
  final Widget? trailing;

  const AppHeader({
    required this.title,
    this.showBack = false,
    this.onBack,
    this.trailing,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.paddingOf(context).top;

    return Container(
      color: AppColors.surface,
      padding: EdgeInsets.only(
        top: statusBarHeight,
        left: AppSpacing.screenGutter,
        right: AppSpacing.screenGutter,
        bottom: AppSpacing.spaceMd,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                if (showBack)
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: onBack ?? () => Navigator.maybePop(context),
                    child: const Padding(
                      padding: EdgeInsets.only(right: AppSpacing.spaceXs),
                      child: Icon(
                        Icons.chevron_left,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                Flexible(
                  child: Text(
                    title,
                    style: AppTypography.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
