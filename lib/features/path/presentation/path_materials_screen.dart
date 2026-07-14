import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app/di.dart';
import '../../../core/icons/app_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/filter_bottom_sheet.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/entities/path_material.dart';
import 'cubit/path_materials_cubit.dart';
import 'widgets/path_material_card.dart';
import 'widgets/path_material_category_tabs.dart';

/// "Materiali Extra" hub for an area. Opened from the area detail's materials
/// row; receives the area's "Materiali" group id used to load the materials.
class PathMaterialsScreen extends StatelessWidget {
  const PathMaterialsScreen({super.key, required this.groupId, this.title});

  /// Id of the area's `is_percorso_main_tab: false` ("Materiali") group.
  final String groupId;

  /// Optional screen title; defaults to the localized "Materiali extra".
  final String? title;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<PathMaterialsCubit>()..load(groupId: groupId),
      child: _PathMaterialsView(title: title),
    );
  }
}

class _PathMaterialsView extends StatelessWidget {
  const _PathMaterialsView({this.title});

  final String? title;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      // top: false — AppHeader insets the status bar; SafeArea guards only the
      // bottom against the Android system navigation bar.
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppHeader(
              title: title ?? l10n.pathMaterialsTitle,
              showBack: true,
              trailing: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _showFilter(context, l10n),
                child: const AppIcon(
                  AppIcons.filter,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Expanded(
              child: BlocBuilder<PathMaterialsCubit, PathMaterialsState>(
                builder: (context, state) {
                  switch (state.status) {
                    case PathMaterialsStatus.initial:
                    case PathMaterialsStatus.loading:
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.accent,
                        ),
                      );
                    case PathMaterialsStatus.error:
                      return Center(
                        child: Text(
                          l10n.errorGeneric,
                          style: AppTypography.textTheme.bodyMedium,
                        ),
                      );
                    case PathMaterialsStatus.loaded:
                      return _MaterialsList(state: state, l10n: l10n);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showFilter(BuildContext context, AppLocalizations l10n) async {
    final cubit = context.read<PathMaterialsCubit>();

    final options = [
      FilterOption(
        value: PathMaterialFilter.available,
        label: l10n.pathMaterialsFilterAvailable,
      ),
      FilterOption(
        value: PathMaterialFilter.completed,
        label: l10n.pathMaterialsFilterCompleted,
      ),
      FilterOption(
        value: PathMaterialFilter.unavailable,
        label: l10n.pathMaterialsFilterUnavailable,
      ),
    ];

    final selected = await FilterBottomSheet.show<PathMaterialFilter>(
      context: context,
      options: options,
      selected: cubit.state.filter,
    );

    if (selected != null) {
      cubit.setFilter(selected);
    }
  }
}

class _MaterialsList extends StatelessWidget {
  const _MaterialsList({required this.state, required this.l10n});

  final PathMaterialsState state;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final data = state.data;
    final materials = state.visibleMaterials;
    final categories = data?.categories ?? const [];

    return CustomScrollView(
      slivers: [
        if (categories.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenGutter,
                AppSpacing.spaceMd,
                AppSpacing.screenGutter,
                AppSpacing.spaceSm,
              ),
              child: PathMaterialCategoryTabs(
                categories: categories,
                selectedId: state.selectedCategoryId,
                onSelected: context.read<PathMaterialsCubit>().selectCategory,
              ),
            ),
          ),
        if (materials.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Text(
                l10n.pathMaterialsEmpty,
                style: AppTypography.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenGutter,
              AppSpacing.spaceXs,
              AppSpacing.screenGutter,
              AppSpacing.spaceXl,
            ),
            sliver: SliverList.separated(
              itemCount: materials.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: AppSpacing.spaceMd),
              itemBuilder: (context, index) {
                final material = materials[index];
                return PathMaterialCard(
                  material: material,
                  onTap: () => _openDetail(context, material),
                );
              },
            ),
          ),
      ],
    );
  }

  void _openDetail(BuildContext context, PathMaterial material) {
    // The category title is shown in the (text) detail header; pass the
    // currently-selected category's title.
    final categories = state.data?.categories ?? const [];
    String? categoryTitle;
    for (final c in categories) {
      if (c.id == state.selectedCategoryId) {
        categoryTitle = c.title;
        break;
      }
    }

    final base = GoRouterState.of(context).uri.path;
    context.push('$base/detail/${material.id}', extra: categoryTitle);
  }
}
