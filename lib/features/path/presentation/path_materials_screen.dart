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

/// Navigation args for [PathMaterialsScreen], passed via `GoRouterState.extra`.
///
/// [categories], when provided, are the tapped group's *official* categories
/// (`group.categories` from `GET /path/me/areas/{area}/steps`) and take
/// priority over the categories the materials repository derives from the
/// materials list — backend-confirmed authoritative source, since deriving
/// tabs from materials let a mistagged one surface a duplicate-titled
/// category tab (e.g. two "Scopri" chips). See [[statistics-feature-status]].
class PathMaterialsRouteArgs {
  const PathMaterialsRouteArgs({this.title, this.categories});

  final String? title;
  final List<PathMaterialCategory>? categories;
}

/// "Materiali Extra" hub for an area. Opened from the area detail's materials
/// row; receives the area's "Materiali" group id used to load the materials.
class PathMaterialsScreen extends StatelessWidget {
  const PathMaterialsScreen({
    super.key,
    required this.groupId,
    this.title,
    this.categories,
  });

  /// Id of the area's `is_percorso_main_tab: false` ("Materiali") group.
  final String groupId;

  /// Optional screen title; defaults to the localized "Materiali extra".
  final String? title;

  /// The group's official categories, when known — see [PathMaterialsRouteArgs].
  final List<PathMaterialCategory>? categories;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<PathMaterialsCubit>()..load(groupId: groupId),
      child: _PathMaterialsView(
        groupId: groupId,
        title: title,
        officialCategories: categories,
      ),
    );
  }
}

class _PathMaterialsView extends StatelessWidget {
  const _PathMaterialsView({
    required this.groupId,
    this.title,
    this.officialCategories,
  });

  final String groupId;
  final String? title;

  /// The tapped group's official categories, when known — takes priority over
  /// [PathMaterialsState.data]'s materials-derived ones.
  final List<PathMaterialCategory>? officialCategories;

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
                      return _MaterialsList(
                        state: state,
                        l10n: l10n,
                        groupId: groupId,
                        officialCategories: officialCategories,
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

  Future<void> _showFilter(BuildContext context, AppLocalizations l10n) async {
    final cubit = context.read<PathMaterialsCubit>();

    final options = [
      FilterOption(
        value: PathMaterialFilter.all,
        label: l10n.pathMaterialsFilterAll,
      ),
      FilterOption(
        value: PathMaterialFilter.toWatch,
        label: l10n.pathMaterialsFilterToWatch,
      ),
      FilterOption(
        value: PathMaterialFilter.watched,
        label: l10n.pathMaterialsFilterWatched,
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
  const _MaterialsList({
    required this.state,
    required this.l10n,
    required this.groupId,
    this.officialCategories,
  });

  final PathMaterialsState state;
  final AppLocalizations l10n;
  final String groupId;

  /// The tapped group's official categories, when known — see
  /// [PathMaterialsRouteArgs]. Falls back to the materials-derived ones (the
  /// old behavior) only when absent, e.g. a cold deep-link into this screen.
  final List<PathMaterialCategory>? officialCategories;

  @override
  Widget build(BuildContext context) {
    final data = state.data;
    final materials = state.visibleMaterials;
    final categories = officialCategories ?? data?.categories ?? const [];

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
            sliver: SliverList(delegate: _buildDelegate(context, materials)),
          ),
      ],
    );
  }

  /// Under [PathMaterialFilter.all], [materials] is already sorted
  /// not-yet-completed first (see [PathMaterialsState.visibleMaterials]), so
  /// the split point between the two status groups is just the index of the
  /// first completed item — this builds the "Da completare/leggere" /
  /// "Completata/letta" section headers around that split. Other filters show
  /// a single, header-less list since every card already shares that status.
  SliverChildDelegate _buildDelegate(
    BuildContext context,
    List<PathMaterial> materials,
  ) {
    if (state.filter != PathMaterialFilter.all) {
      return SliverChildBuilderDelegate(
        (context, index) => Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.spaceMd),
          child: _card(context, materials[index]),
        ),
        childCount: materials.length,
      );
    }

    final firstCompleted = materials.indexWhere((m) => m.isCompleted);
    final splitIndex = firstCompleted == -1 ? materials.length : firstCompleted;
    final hasToWatch = splitIndex > 0;
    final hasWatched = splitIndex < materials.length;

    final items = <Widget>[
      if (hasToWatch) _SectionHeader(title: l10n.pathMaterialsSectionToWatch),
      for (var i = 0; i < splitIndex; i++)
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.spaceMd),
          child: _card(context, materials[i]),
        ),
      if (hasToWatch && hasWatched) const SizedBox(height: AppSpacing.spaceLg),
      if (hasWatched) _SectionHeader(title: l10n.pathMaterialsSectionWatched),
      for (var i = splitIndex; i < materials.length; i++)
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.spaceMd),
          child: _card(context, materials[i]),
        ),
    ];

    return SliverChildBuilderDelegate(
      (context, index) => items[index],
      childCount: items.length,
    );
  }

  Widget _card(BuildContext context, PathMaterial material) {
    return PathMaterialCard(
      material: material,
      highlightCompleted: state.filter == PathMaterialFilter.all,
      onTap: () => _openDetail(context, material),
    );
  }

  Future<void> _openDetail(BuildContext context, PathMaterial material) async {
    // The category title is shown in the (text) detail header; pass the
    // currently-selected category's title.
    final categories = officialCategories ?? state.data?.categories ?? const [];
    String? categoryTitle;
    for (final c in categories) {
      if (c.id == state.selectedCategoryId) {
        categoryTitle = c.title;
        break;
      }
    }

    final cubit = context.read<PathMaterialsCubit>();
    final base = GoRouterState.of(context).uri.path;
    await context.push('$base/detail/${material.id}', extra: categoryTitle);
    // The detail's "Segna come completato" CTA may have just moved this
    // material from "Da vedere" to "Visti" — reload so the list/filter
    // reflects it without the user needing to leave and come back.
    await cubit.load(groupId: groupId);
  }
}

/// Bold uppercase caption above each status group under
/// [PathMaterialFilter.all] ("Da completare/leggere" / "Completata/letta").
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.spaceSm),
      child: Text(
        title.toUpperCase(),
        style: AppTypography.textTheme.labelLarge?.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}
