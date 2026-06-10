import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kilocal_flutter_app/l10n/app_localizations.dart';

import '../../../core/utils/mock_data_factory.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/circular_progress.dart';
import 'cubit/home_cubit.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final l10n = AppLocalizations.of(context)!;
        return HomeCubit(initialData: MockDataFactory.homeData(l10n))..load();
      },
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.push('/notifications'),
          ),
        ],
      ),
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          if (state.status == HomeStatus.loading || state.data == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = state.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenGutter),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.spaceMd),
                // Greeting card
                AppCard(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.homeGreeting(data.userName),
                              style: AppTypography.textTheme.titleMedium,
                            ),
                            const SizedBox(height: AppSpacing.space2xs),
                            Text(
                              l10n.homeProgress,
                              style: AppTypography.textTheme.labelMedium,
                            ),
                          ],
                        ),
                      ),
                      CircularProgress(value: data.overallProgress),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.spaceLg),
                // Quick cards
                Text(l10n.homeQuickLinks, style: AppTypography.textTheme.titleMedium),
                const SizedBox(height: AppSpacing.spaceSm),
                Row(
                  children: data.quickCards.map((card) {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: AppCard(
                          onTap: () {},
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(card.icon, style: const TextStyle(fontSize: 24)),
                              const SizedBox(height: AppSpacing.spaceXs),
                              Text(card.title, style: AppTypography.textTheme.bodyMedium),
                              if (card.subtitle != null)
                                Text(card.subtitle!, style: AppTypography.textTheme.labelMedium),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppSpacing.spaceLg),
                // Hero carousel
                Text(l10n.homeHeroTitle, style: AppTypography.textTheme.titleMedium),
                const SizedBox(height: AppSpacing.spaceSm),
                SizedBox(
                  height: 180,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: data.heroItems.length,
                    separatorBuilder: (context, index) => const SizedBox(width: AppSpacing.spaceSm),
                    itemBuilder: (context, index) {
                      final hero = data.heroItems[index];
                      return SizedBox(
                        width: 280,
                        child: AppCard(
                          padding: EdgeInsets.zero,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.network(hero.imageUrl, fit: BoxFit.cover),
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(AppSpacing.spaceMd),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.transparent,
                                          Colors.black.withValues(alpha: 0.7),
                                        ],
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          hero.title,
                                          style: const TextStyle(
                                            color: AppColors.neutralWhite,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        if (hero.subtitle != null)
                                          Text(
                                            hero.subtitle!,
                                            style: const TextStyle(
                                              color: AppColors.neutralWhite,
                                              fontSize: 12,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.spaceXl),
              ],
            ),
          );
        },
      ),
    );
  }
}