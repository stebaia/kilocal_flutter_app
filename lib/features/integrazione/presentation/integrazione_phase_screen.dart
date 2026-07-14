import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:toastification/toastification.dart';

import '../../../app/di.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_header.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/entities/integrazione_data.dart';
import 'cubit/integrazione_cubit.dart';
import 'widgets/integrazione_instructions_sheet.dart';
import 'widgets/integrazione_product_card.dart';

/// Detail of a single integrazione phase: one card per supplement with intake
/// tracking. Tapping a card opens the usage-instructions bottom sheet.
class IntegrazionePhaseScreen extends StatelessWidget {
  const IntegrazionePhaseScreen({super.key, required this.phaseId});

  final String phaseId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<IntegrazioneCubit>()..load(),
      child: _PhaseView(phaseId: phaseId),
    );
  }
}

class _PhaseView extends StatelessWidget {
  const _PhaseView({required this.phaseId});

  final String phaseId;

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
            BlocBuilder<IntegrazioneCubit, IntegrazioneState>(
              buildWhen: (a, b) => a.data != b.data,
              builder: (context, state) {
                final index = state.data?.phases.indexWhere(
                  (p) => p.id == phaseId,
                );
                final number = (index == null || index < 0) ? 1 : index + 1;
                return AppHeader(
                  title: l10n.integrationPhaseTitle(number),
                  showBack: true,
                );
              },
            ),
            Expanded(
              child: BlocConsumer<IntegrazioneCubit, IntegrazioneState>(
                listenWhen: (a, b) => a.error != b.error && b.error != null,
                listener: (context, state) {
                  toastification.show(
                    context: context,
                    type: ToastificationType.error,
                    style: ToastificationStyle.flat,
                    title: Text(l10n.integrationMarkTakenError),
                    autoCloseDuration: const Duration(seconds: 3),
                  );
                },
                builder: (context, state) {
                  switch (state.status) {
                    case IntegrazioneStatus.loading:
                    case IntegrazioneStatus.initial:
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.accent,
                        ),
                      );
                    case IntegrazioneStatus.error:
                      if (state.data == null) {
                        return Center(
                          child: Text(
                            l10n.errorGeneric,
                            style: AppTypography.textTheme.bodyMedium,
                          ),
                        );
                      }
                      return _PhaseProducts(
                        phaseId: phaseId,
                        data: state.data!,
                      );
                    case IntegrazioneStatus.loaded:
                      return _PhaseProducts(
                        phaseId: phaseId,
                        data: state.data!,
                      );
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

class _PhaseProducts extends StatelessWidget {
  const _PhaseProducts({required this.phaseId, required this.data});

  final String phaseId;
  final IntegrazioneData data;

  @override
  Widget build(BuildContext context) {
    final phase = data.phases.firstWhere(
      (p) => p.id == phaseId,
      orElse: () =>
          const IntegrazionePhase(id: '', title: '', sort: 0, products: []),
    );

    return ListView.separated(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenGutter,
        vertical: AppSpacing.spaceLg,
      ),
      itemCount: phase.products.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.spaceLg),
      itemBuilder: (context, index) {
        final product = phase.products[index];
        return IntegrazioneProductCard(
          product: product,
          onInfoTap: () => _openInstructions(context, product),
          onMarkTaken: () => _markTaken(context, product),
        );
      },
    );
  }

  void _openInstructions(BuildContext context, IntegrazioneProduct product) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (_) => IntegrazioneInstructionsSheet(product: product),
    );
  }

  Future<void> _markTaken(
    BuildContext context,
    IntegrazioneProduct product,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await context.read<IntegrazioneCubit>().markTakenToday(product);
      if (context.mounted) {
        toastification.show(
          context: context,
          type: ToastificationType.success,
          style: ToastificationStyle.flat,
          title: Text(l10n.integrationMarkedTaken),
          autoCloseDuration: const Duration(seconds: 2),
        );
      }
    } catch (_) {
      // The cubit re-emits an error state that the BlocConsumer listener turns
      // into a toast; keep a messenger fallback for safety.
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.integrationMarkTakenError)),
      );
    }
  }
}
