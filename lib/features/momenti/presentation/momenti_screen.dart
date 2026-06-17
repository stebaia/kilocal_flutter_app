import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kilocal_flutter_app/l10n/app_localizations.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/mock_data_factory.dart';
import '../../../core/widgets/localized_bloc_loader.dart';
import 'cubit/momenti_cubit.dart';
import 'widgets/momenti_hero_image.dart';
import 'widgets/momenti_meccanica_card.dart';

class MomentiScreen extends StatelessWidget {
  const MomentiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MomentiCubit(),
      child: LocalizedBlocLoader<MomentiCubit, MomentiState>(
        load: (context, cubit) {
          final l10n = AppLocalizations.of(context)!;
          cubit.loadWithData(MockDataFactory.momenti(l10n));
        },
        child: const _MomentiView(),
      ),
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
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenGutter,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.spaceMd),
                MomentiHeroImage(imageUrl: data.heroImageUrl),
                const SizedBox(height: AppSpacing.spaceLg),
                Text(data.title, style: AppTypography.textTheme.headlineLarge),
                const SizedBox(height: AppSpacing.spaceMd),
                Text(data.body, style: AppTypography.textTheme.bodyMedium),
                const SizedBox(height: AppSpacing.spaceLg),
                Text('Meccanica', style: AppTypography.textTheme.titleMedium),
                const SizedBox(height: AppSpacing.spaceSm),
                ...data.meccanica.map(
                  (item) => MomentiMeccanicaCard(item: item),
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
