import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';

/// White rounded card that groups several [ProfileListTile]s, drawing inset
/// hairline dividers between consecutive tiles.
class ProfileGroupCard extends StatelessWidget {
  const ProfileGroupCard({super.key, required this.tiles});

  final List<Widget> tiles;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    for (var i = 0; i < tiles.length; i++) {
      children.add(tiles[i]);
      if (i != tiles.length - 1) {
        children.add(
          const Padding(
            // Inset so the divider aligns with the title, clearing the icon.
            padding: EdgeInsets.only(left: 40),
            child: Divider(height: 1, thickness: 1, color: AppColors.divider),
          ),
        );
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spaceMd),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}
