import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:kilocal_flutter_app/l10n/app_localizations.dart';

import '../../../core/icons/app_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/mock_data_factory.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/circular_progress.dart';
import '../../../core/widgets/localized_bloc_loader.dart';
import '../../home/domain/entities/home_data.dart';
import 'cubit/home_cubit.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeCubit(),
      child: LocalizedBlocLoader<HomeCubit, HomeState>(
        load: (context, cubit) {
          final l10n = AppLocalizations.of(context)!;
          cubit.loadWithData(MockDataFactory.homeData(l10n));
        },
        child: const _HomeView(),
      ),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            if (state.status == HomeStatus.loading || state.data == null) {
              return const Center(child: CircularProgressIndicator());
            }

            final data = state.data!;
            final dateLabel = DateFormat('EEEE d MMMM', Localizations.localeOf(context).languageCode).format(data.currentDate);

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenGutter),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.spaceMd),
                  _HomeHeader(dateLabel: dateLabel, userName: data.userName),
                  const SizedBox(height: AppSpacing.spaceLg),
                  _ContinuePathCard(item: data.continuePath),
                  const SizedBox(height: AppSpacing.spaceLg),
                  _MonthStatsCard(stats: data.monthStats),
                  const SizedBox(height: AppSpacing.spaceLg),
                  _ActionCardsGrid(cards: data.actionCards),
                  const SizedBox(height: AppSpacing.spaceXl),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.dateLabel, required this.userName});

  final String dateLabel;
  final String userName;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dateLabel,
                style: AppTypography.textTheme.labelMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.space2xs),
              Text(
                l10n.homeGreeting(userName),
                style: AppTypography.textTheme.headlineLarge,
              ),
            ],
          ),
        ),
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              color: AppColors.textPrimary,
              onPressed: () => context.push('/notifications'),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ContinuePathCard extends StatelessWidget {
  const _ContinuePathCard({required this.item});

  final ContinuePathItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        gradient: AppColors.brandGradient,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Stack(
          children: [
            // Decorative ribbon at the bottom-left.
            Positioned(
              bottom: -30,
              left: -20,
              child: Transform.rotate(
                angle: -0.4,
                child: Container(
                  width: 140,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.neutralWhite.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(40),
                  ),
                ),
              ),
            ),
            // White text box on the left.
            Positioned(
              top: AppSpacing.spaceLg,
              left: AppSpacing.spaceMd,
              child: Container(
                width: 180,
                padding: const EdgeInsets.all(AppSpacing.spaceMd),
                decoration: BoxDecoration(
                  color: AppColors.neutralWhite,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Text(
                  item.title,
                  style: AppTypography.textTheme.bodyMedium,
                ),
              ),
            ),
            // Hero image on the right, slightly overflowing the top edge.
            Positioned(
              top: -16,
              right: -16,
              bottom: 0,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(AppRadius.lg),
                  bottomRight: Radius.circular(AppRadius.lg),
                  topLeft: Radius.circular(AppRadius.lg),
                ),
                child: Image.network(
                  item.imageUrl,
                  width: 210,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Bottom-right CTA.
            Positioned(
              bottom: AppSpacing.spaceMd,
              right: AppSpacing.spaceMd,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.subtitle,
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                      color: AppColors.neutralWhite,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.spaceSm),
                  AppIcon(
                    AppIcons.play,
                    size: 24,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MonthStatsCard extends StatelessWidget {
  const _MonthStatsCard({required this.stats});

  final MonthStats stats;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AppCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stats.monthLabel,
                  style: AppTypography.textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.spaceXs),
                Text(
                  stats.description,
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.spaceMd),
                GestureDetector(
                  onTap: () => context.push('/statistics'),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n.homeSeeStatistics,
                        style: AppTypography.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.spaceXs),
                      const Icon(
                        Icons.chevron_right,
                        size: 18,
                        color: AppColors.textPrimary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          CircularProgress(
            value: stats.progress,
            size: 90,
            strokeWidth: 8,
          ),
        ],
      ),
    );
  }
}

class _ActionCardsGrid extends StatelessWidget {
  const _ActionCardsGrid({required this.cards});

  final List<HomeActionCard> cards;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: cards.map((card) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: card == cards.first ? AppSpacing.spaceSm : 0,
            ),
            child: _ActionCard(card: card),
          ),
        );
      }).toList(),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({required this.card});

  final HomeActionCard card;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(card.route),
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          gradient: AppColors.brandGradient,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: AppShadows.card,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Stack(
            children: [
              // Top-center illustration.
              Positioned(
                top: AppSpacing.spaceMd,
                left: 0,
                right: 0,
                child: Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    child: Image.network(
                      card.imageUrl,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              // Bottom-left title.
              Positioned(
                bottom: AppSpacing.spaceMd,
                left: AppSpacing.spaceMd,
                child: Text(
                  card.title,
                  style: AppTypography.textTheme.titleMedium?.copyWith(
                    color: AppColors.neutralWhite,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              // Bottom-right play icon.
              Positioned(
                bottom: AppSpacing.spaceMd,
                right: AppSpacing.spaceMd,
                child: AppIcon(
                  AppIcons.play,
                  size: 24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
