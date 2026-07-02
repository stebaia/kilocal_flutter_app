import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app/di.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_header.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/entities/profile_page.dart';
import 'cubit/profile_page_cubit.dart';
import 'widgets/profile_type_percorsi_grid.dart';

/// "Scopri di più" screen opened from the biotype characteristics card. Shows
/// the CMS `private_sec_percorsi` block of `dashboard-type`: an intro line plus
/// the path-category shortcuts. See [[profile-cms-pages-schema]].
class ProfileTypePercorsiScreen extends StatelessWidget {
  const ProfileTypePercorsiScreen({super.key});

  static const _pageInternalName = 'dashboard-type';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColors.surface,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: BlocProvider(
        create: (_) => getIt<ProfilePageCubit>()..load(_pageInternalName),
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: Column(
            children: [
              AppHeader(title: l10n.profileTypeCharacteristics, showBack: true),
              Expanded(
                child: BlocBuilder<ProfilePageCubit, ProfilePageState>(
                  builder: (context, state) {
                    final percorsi = state.page?.sections
                        .whereType<ProfilePagePercorsiSection>()
                        .firstOrNull;

                    return SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.screenGutter,
                        AppSpacing.spaceLg,
                        AppSpacing.screenGutter,
                        AppSpacing.spaceXl,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (percorsi?.intro case final intro?
                              when intro.isNotEmpty) ...[
                            Text(
                              intro,
                              style: AppTypography.textTheme.bodyMedium
                                  ?.copyWith(color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: AppSpacing.spaceLg),
                          ],
                          const ProfileTypePercorsiGrid(),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
