import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kilocal_flutter_app/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/di.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_header.dart';
import 'cubit/benefits_cubit.dart';
import 'widgets/benefit_hero_card.dart';
import 'widgets/benefit_list_tile.dart';

class BenefitsScreen extends StatelessWidget {
  const BenefitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<BenefitsCubit>()..load(),
      child: const _BenefitsView(),
    );
  }
}

class _BenefitsView extends StatelessWidget {
  const _BenefitsView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppHeader(title: l10n.benefitsTitle, showBack: true),
          Expanded(
            child: BlocBuilder<BenefitsCubit, BenefitsState>(
              builder: (context, state) {
                switch (state.status) {
                  case BenefitsStatus.initial:
                  case BenefitsStatus.loading:
                    return const Center(child: CircularProgressIndicator());
                  case BenefitsStatus.error:
                    return Center(child: Text(l10n.benefitsEmpty));
                  case BenefitsStatus.loaded:
                    if (state.benefits.isEmpty) {
                      return Center(child: Text(l10n.benefitsEmpty));
                    }
                    return _BenefitsList(state: state);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _BenefitsList extends StatelessWidget {
  const _BenefitsList({required this.state});

  final BenefitsState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final primary = state.primaryPartners;
    final secondary = state.secondaryPartners;

    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenGutter,
        vertical: AppSpacing.spaceMd,
      ),
      children: [
        if (primary.isNotEmpty) ...[
          _SectionHeader(label: l10n.benefitsPrimaryPartners),
          for (final benefit in primary)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.spaceSm),
              child: BenefitHeroCard(
                benefit: benefit,
                detailsLabel: l10n.benefitViewDetails,
                onDetailsPressed: benefit.ctaUrl != null
                    ? () => _openUrl(benefit.ctaUrl!)
                    : null,
              ),
            ),
        ],
        if (secondary.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.spaceMd),
          _SectionHeader(label: l10n.benefitsSecondaryPartners),
          for (final benefit in secondary)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.spaceSm),
              child: BenefitListTile(
                benefit: benefit,
                onTap: benefit.ctaUrl != null
                    ? () => _openUrl(benefit.ctaUrl!)
                    : null,
              ),
            ),
        ],
      ],
    );
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.spaceSm),
      child: Text(
        label,
        style: AppTypography.textTheme.labelMedium?.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
