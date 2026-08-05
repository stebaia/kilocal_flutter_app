import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app/di.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/hex_color.dart';
import '../../../core/widgets/app_header.dart';
import '../../../l10n/app_localizations.dart';
import '../../user/presentation/cubit/user_cubit.dart';
import 'cubit/profile_kit_cubit.dart';
import 'domain_ext.dart';
import 'widgets/profile_kit_content_card.dart';
import 'widgets/profile_kit_product_tabs.dart';

/// "Integrazione e prodotti" screen: the kit's supplement products shown one at
/// a time, selectable via a row of pill tabs at the top (one per product). Each
/// product renders the same pink content card (image, "Come agisce…", CTA).
/// Opened from the second product tile on the biotype detail screen.
class ProfileKitProductsScreen extends StatelessWidget {
  const ProfileKitProductsScreen({super.key, required this.kitId});

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
        child: const _ProfileKitProductsView(),
      ),
    );
  }
}

class _ProfileKitProductsView extends StatefulWidget {
  const _ProfileKitProductsView();

  @override
  State<_ProfileKitProductsView> createState() =>
      _ProfileKitProductsViewState();
}

class _ProfileKitProductsViewState extends State<_ProfileKitProductsView> {
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Same biotype color source as ProfileTypeScreen, so the product card
    // tint matches the Tipo the user is currently looking at.
    final accentColor = colorFromHex(
      getIt<UserCubit>().state.details?.biotype?.mainColor,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      // top: false — AppHeader insets the status bar; SafeArea guards only the
      // bottom against the Android system navigation bar.
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            AppHeader(title: l10n.profileTypeSupplements, showBack: true),
            Expanded(
              child: BlocBuilder<ProfileKitCubit, ProfileKitState>(
                builder: (context, state) =>
                    _body(context, state, l10n, accentColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _body(
    BuildContext context,
    ProfileKitState state,
    AppLocalizations l10n,
    Color? accentColor,
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
        final products = state.kit?.products ?? const [];
        if (products.isEmpty) {
          return Center(
            child: Text(
              l10n.profileKitEmpty,
              style: AppTypography.textTheme.bodyMedium,
            ),
          );
        }
        // Keep the selection in range if the product list shrinks.
        final index = _selected.clamp(0, products.length - 1);
        final product = products[index];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.spaceMd),
            ProfileKitProductTabs(
              titles: products.map((p) => p.title).toList(),
              selectedIndex: index,
              onSelected: (i) => setState(() => _selected = i),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenGutter,
                  AppSpacing.spaceLg,
                  AppSpacing.screenGutter,
                  AppSpacing.spaceXl,
                ),
                child: ProfileKitContentCard(
                  title: product.title,
                  description: product.description,
                  imageUrl: product.imageUrl,
                  cta: product.cta,
                  ctaLabel: l10n.profileKitBuy,
                  onCtaTap: product.cta.launchable(context),
                  accentColor: accentColor,
                ),
              ),
            ),
          ],
        );
    }
  }
}
