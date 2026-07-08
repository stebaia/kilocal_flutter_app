import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app/di.dart';
import '../../../core/icons/app_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_header.dart';
import '../../../l10n/app_localizations.dart';
import '../../statistics/presentation/statistics_screen.dart';
import '../domain/entities/integrazione_data.dart';
import 'cubit/integrazione_cubit.dart';
import 'widgets/integrazione_phase_card.dart';

/// Detail screen for the "Integrazione" (supplements) area.
///
/// Unlike the other three path areas, integrazione is phase-based and backed by
/// GraphQL, so it does NOT reuse `PathAreaDetailScreen` / `/path/*/steps`.
class IntegrazioneScreen extends StatelessWidget {
  const IntegrazioneScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<IntegrazioneCubit>()..load(),
      child: const _IntegrazioneView(),
    );
  }
}

class _IntegrazioneView extends StatelessWidget {
  const _IntegrazioneView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppHeader(
            title: l10n.areaIntegration,
            showBack: true,
            trailing: GestureDetector(
              onTap: () => context.push(StatisticsScreen.route),
              child: const AppIcon(
                AppIcons.chart,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<IntegrazioneCubit, IntegrazioneState>(
              builder: (context, state) {
                switch (state.status) {
                  case IntegrazioneStatus.loading:
                  case IntegrazioneStatus.initial:
                    return const Center(
                      child: CircularProgressIndicator(color: AppColors.accent),
                    );
                  case IntegrazioneStatus.error:
                    return Center(
                      child: Text(
                        l10n.errorGeneric,
                        style: AppTypography.textTheme.bodyMedium,
                      ),
                    );
                  case IntegrazioneStatus.loaded:
                    final data = state.data;
                    if (data == null || data.phases.isEmpty) {
                      return Center(
                        child: Text(
                          l10n.integrationEmpty,
                          style: AppTypography.textTheme.bodyMedium,
                        ),
                      );
                    }
                    return _IntegrazioneContent(data: data);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _IntegrazioneContent extends StatelessWidget {
  const _IntegrazioneContent({required this.data});

  final IntegrazioneData data;

  @override
  Widget build(BuildContext context) {
    final phases = data.phases;

    return ListView.separated(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenGutter,
        vertical: AppSpacing.spaceLg,
      ),
      itemCount: phases.length,
      separatorBuilder: (_, _) =>
          const SizedBox(height: AppSpacing.spaceLg),
      itemBuilder: (context, index) {
        final phase = phases[index];
        final locked = data.isPhaseLocked(index);
        return IntegrazionePhaseCard(
          phase: phase,
          phaseNumber: index + 1,
          isLocked: locked,
          // "Completa prima la fase N" points at the active phase to unlock.
          unlockAfterPhase: data.activeIndex + 1,
          onTap: locked
              ? null
              : () => context.push('/path/integrazione/phase/${phase.id}'),
        );
      },
    );
  }
}
