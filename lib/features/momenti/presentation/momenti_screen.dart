import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kilocal_flutter_app/l10n/app_localizations.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/mock_data_factory.dart';
import '../../../core/widgets/app_card.dart';
import 'cubit/momenti_cubit.dart';

class MomentiScreen extends StatelessWidget {
  const MomentiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final l10n = AppLocalizations.of(context)!;
        return MomentiCubit(initialData: MockDataFactory.momenti(l10n))..load();
      },
      child: const _MomentiView(),
    );
  }
}

class _MomentiView extends StatelessWidget {
  const _MomentiView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Momenti'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              // TODO: show info bottom sheet
            },
          ),
        ],
      ),
      body: BlocBuilder<MomentiCubit, MomentiState>(
        builder: (context, state) {
          if (state.status == MomentiStatus.loading || state.data == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = state.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenGutter),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.spaceMd),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  child: Image.network(
                    data.heroImageUrl,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: AppSpacing.spaceLg),
                Text(data.title, style: AppTypography.textTheme.headlineLarge),
                const SizedBox(height: AppSpacing.spaceMd),
                Text(data.body, style: AppTypography.textTheme.bodyMedium),
                const SizedBox(height: AppSpacing.spaceLg),
                Text('Meccanica', style: AppTypography.textTheme.titleMedium),
                const SizedBox(height: AppSpacing.spaceSm),
                ...data.meccanica.map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.spaceSm),
                    child: AppCard(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.spaceSm,
                              vertical: AppSpacing.space2xs,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.accentSoft,
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                            ),
                            child: Text(
                              item.day,
                              style: const TextStyle(
                                color: AppColors.accent,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.spaceMd),
                          Expanded(
                            child: Text(item.description, style: AppTypography.textTheme.bodyMedium),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: AppSpacing.spaceXl),
              ],
            ),
          );
        },
      ),
    );
  }
}