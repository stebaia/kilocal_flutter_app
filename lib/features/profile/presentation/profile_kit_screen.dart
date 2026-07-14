import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app/di.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_header.dart';
import '../../../l10n/app_localizations.dart';
import 'cubit/profile_kit_cubit.dart';
import 'domain_ext.dart';
import 'widgets/profile_kit_content_card.dart';

/// "Il mio Kit" screen ("Kit tipo N"): the plan card for the kit assigned to the
/// user's profile — image, HTML plan copy ("Piano Lipolisi…") and a buy CTA.
/// Opened from the first product tile on the biotype detail screen.
class ProfileKitScreen extends StatelessWidget {
  const ProfileKitScreen({super.key, required this.kitId});

  final String kitId;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColors.surface,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: BlocProvider(
        create: (_) => getIt<ProfileKitCubit>()..load(kitId),
        child: const _ProfileKitView(),
      ),
    );
  }
}

class _ProfileKitView extends StatelessWidget {
  const _ProfileKitView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocBuilder<ProfileKitCubit, ProfileKitState>(
        builder: (context, state) {
          final kit = state.kit;
          final title = kit?.typeLabel != null
              ? l10n.profileKitTitle(kit!.typeLabel!)
              : l10n.profileTypeMyKit;

          // top: false — AppHeader insets the status bar; SafeArea guards only
          // the bottom against the Android system navigation bar.
          return SafeArea(
            top: false,
            child: Column(
              children: [
                AppHeader(title: title, showBack: true),
                Expanded(child: _body(context, state, l10n)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _body(
    BuildContext context,
    ProfileKitState state,
    AppLocalizations l10n,
  ) {
    switch (state.status) {
      case ProfileKitStatus.loading:
      case ProfileKitStatus.initial:
        return const Center(
          child: CircularProgressIndicator(color: AppColors.accent),
        );
      case ProfileKitStatus.error:
        return Center(
          child: Text(
            l10n.errorGeneric,
            style: AppTypography.textTheme.bodyMedium,
          ),
        );
      case ProfileKitStatus.loaded:
        final kit = state.kit;
        if (kit == null) {
          return Center(
            child: Text(
              l10n.profileKitEmpty,
              style: AppTypography.textTheme.bodyMedium,
            ),
          );
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenGutter,
            AppSpacing.spaceLg,
            AppSpacing.screenGutter,
            AppSpacing.spaceXl,
          ),
          child: ProfileKitContentCard(
            title: kit.planTitle ?? kit.typeLabel ?? l10n.profileTypeMyKit,
            description: kit.description,
            imageUrl: kit.imageUrl,
            cta: kit.cta,
            ctaLabel: l10n.profileKitBuy,
            onCtaTap: kit.cta.launchable(context),
          ),
        );
    }
  }
}
