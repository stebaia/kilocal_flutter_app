import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:kilocal_flutter_app/l10n/app_localizations.dart';

import '../../../app/di.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_header.dart';
import '../domain/entities/momenti_data.dart';
import 'cubit/momenti_cubit.dart';
import 'widgets/momenti_hero_image.dart';

class MomentiScreen extends StatelessWidget {
  const MomentiScreen({super.key, this.momentId});

  /// Optional moment id coming from the route. When `null` (or the `home`
  /// placeholder), the currently-active moment is loaded.
  final String? momentId;

  @override
  Widget build(BuildContext context) {
    final id = (momentId == null || momentId == 'home') ? null : momentId;
    return BlocProvider(
      create: (_) => getIt<MomentiCubit>()..load(id: id),
      child: const _MomentiView(),
    );
  }
}

class _MomentiView extends StatelessWidget {
  const _MomentiView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.surface,
      // top: false — AppHeader insets the status bar; SafeArea guards only the
      // bottom against the Android system navigation bar.
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppHeader(
              title: l10n.momentiTitle,
              showBack: true,
              
            ),
            Expanded(
              child: BlocBuilder<MomentiCubit, MomentiState>(
                builder: (context, state) {
                  switch (state.status) {
                    case MomentiStatus.initial:
                    case MomentiStatus.loading:
                      return const Center(child: CircularProgressIndicator());
                    case MomentiStatus.error:
                      return Center(child: Text(l10n.momentiEmpty));
                    case MomentiStatus.loaded:
                      final data = state.data;
                      if (data == null) {
                        return Center(child: Text(l10n.momentiEmpty));
                      }
                      return _MomentiContent(data: data);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MomentiContent extends StatelessWidget {
  const _MomentiContent({required this.data});

  final MomentiData data;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenGutter),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.spaceMd),
          if (data.heroImageUrl != null)
            MomentiHeroImage(imageUrl: data.heroImageUrl!),
          const SizedBox(height: AppSpacing.spaceLg),
          Text(data.title, style: AppTypography.textTheme.headlineLarge),
          const SizedBox(height: AppSpacing.spaceMd),
          Html(
            data: data.description,
            style: {
              'body': Style(
                margin: Margins.zero,
                padding: HtmlPaddings.zero,
                color: AppColors.textSecondary,
                fontSize: FontSize(
                  AppTypography.textTheme.bodyMedium?.fontSize ?? 14,
                ),
                lineHeight: const LineHeight(1.5),
              ),
              'h1, h2, h3, h4, h5, h6, strong, b': Style(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            },
          ),
          const SizedBox(height: AppSpacing.spaceXl),
        ],
      ),
    );
  }
}
