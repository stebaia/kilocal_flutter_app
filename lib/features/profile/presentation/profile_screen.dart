import 'package:flutter/material.dart';
import 'package:kilocal_flutter_app/l10n/app_localizations.dart';

import '../../../core/theme/app_spacing.dart';
import 'widgets/profile_header_card.dart';
import 'widgets/profile_tile.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profileTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenGutter,
        ),
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.spaceMd),
            const ProfileHeaderCard(
              name: 'Mario Rossi',
              email: 'mario@example.com',
            ),
            const SizedBox(height: AppSpacing.spaceLg),
            ProfileTile(
              icon: Icons.straighten,
              title: 'Silhouette',
              onTap: () {},
            ),
            ProfileTile(
              icon: Icons.info_outline,
              title: 'Tipo corporeo',
              onTap: () {},
            ),
            ProfileTile(
              icon: Icons.notifications_outlined,
              title: 'Notifiche',
              onTap: () {},
            ),
            ProfileTile(
              icon: Icons.settings_outlined,
              title: 'Impostazioni',
              onTap: () {},
            ),
            const SizedBox(height: AppSpacing.spaceXl),
          ],
        ),
      ),
    );
  }
}
