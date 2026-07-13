import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:go_router/go_router.dart';

import '../../../app/di.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/hex_color.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/cms_svg_icon.dart';
import '../../../l10n/app_localizations.dart';
import '../../user/domain/user_details.dart';
import '../../user/presentation/cubit/user_cubit.dart';
import 'cubit/profile_page_cubit.dart';
import '../domain/entities/profile_page.dart';
import 'widgets/profile_product_tile.dart';
import 'widgets/profile_section_label.dart';
import 'widgets/profile_type_characteristics_card.dart';

/// "Il mio Tipo" detail screen ("Le tue caratteristiche") opened from the
/// profile type card.
///
/// The biotype (`user_details.profile`, see [[profiles-biotype-schema]]) comes
/// from the session-wide [UserCubit]; the section titles and percorsi block come
/// from the CMS `dashboard-type` page ([[profile-cms-pages-schema]]) via
/// [ProfilePageCubit].
class ProfileTypeScreen extends StatelessWidget {
  const ProfileTypeScreen({super.key});

  static const _pageInternalName = 'dashboard-type';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColors.surface,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: BlocProvider(
        create: (_) => getIt<ProfilePageCubit>()..load(_pageInternalName),
        child: BlocBuilder<UserCubit, UserState>(
          bloc: getIt<UserCubit>(),
          builder: (context, state) {
            final biotype = state.details?.biotype;
            final title =
                biotype?.header(l10n.profileMyTypeSection) ??
                l10n.profileTypeUnknown;

            return Scaffold(
              backgroundColor: AppColors.background,
              body: Column(
                children: [
                  AppHeader(
                    title: title,
                    showBack: true,
                    trailing: _TypeBadge(
                      iconUrl: biotype?.iconUrl,
                      badgeColor: colorFromHex(biotype?.mainColor),
                    ),
                  ),
                  Expanded(
                    child: biotype == null
                        ? _EmptyState(message: l10n.errorGeneric)
                        : _Content(biotype: biotype, l10n: l10n),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.biotype, required this.l10n});

  final Biotype biotype;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    // The kit assigned to the biotype (`user_details.profile.kit.id`) drives the
    // two product cards; null when the profile has no kit yet.
    final kitId = biotype.kit?.id;
    return BlocBuilder<ProfilePageCubit, ProfilePageState>(
      builder: (context, pageState) {
        final page = pageState.page;
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenGutter,
            AppSpacing.spaceLg,
            AppSpacing.screenGutter,
            AppSpacing.spaceXl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section header from the CMS `private_page_type` block, falling
              // back to a static label.
              ProfileSectionLabel(
                text: _titleSection(page) ?? l10n.profileMyTypeSection,
              ),
              const SizedBox(height: AppSpacing.spaceSm),
              // Biotype description — HTML markup from the CMS
              // `content`/`content_f` field, shown when populated.
              if (biotype.description != null &&
                  biotype.description!.isNotEmpty) ...[
                Html(
                  data: biotype.description,
                  style: {
                    'body': Style(
                      margin: Margins.zero,
                      padding: HtmlPaddings.zero,
                      color: AppColors.textSecondary,
                      fontSize: FontSize(
                        AppTypography.textTheme.bodyMedium?.fontSize ?? 14,
                      ),
                      lineHeight: const LineHeight(1.5),
                    ),
                  },
                ),
                const SizedBox(height: AppSpacing.spaceSm),
              ],
              ProfileTypeCharacteristicsCard(
                title: l10n.profileTypeCharacteristics,
                ctaLabel: l10n.profileTypeDiscoverMore,
                silhouetteAssetName: biotype.silhouetteAssetName,
                gradientColors: _gradientFor(biotype),
                // "Scopri di più" opens the percorsi detail screen (the CMS
                // `private_sec_percorsi` block with the path-category grid).
                onTap: () => context.push('/profile/type/percorsi'),
              ),
              const SizedBox(height: AppSpacing.spaceLg),
              ProfileSectionLabel(text: l10n.profileTypeProductsSection),
              const SizedBox(height: AppSpacing.spaceSm),
              ProfileProductTile(
                icon: Icons.menu_book_outlined,
                title: biotype.kit?.title ?? l10n.profileTypeMyKit,
                badgeColor: colorFromHex(biotype.mainColor),
                // "Il mio Kit" opens the kit plan card ("Kit tipo N").
                onTap: kitId == null
                    ? null
                    : () => context.push('/profile/type/kit/$kitId'),
              ),
              const SizedBox(height: AppSpacing.spaceSm),
              ProfileProductTile(
                icon: Icons.medication_outlined,
                title: l10n.profileTypeSupplements,
                badgeColor: colorFromHex(biotype.mainColor),
                // "Integrazione e prodotti" opens the kit's supplement products.
                onTap: kitId == null
                    ? null
                    : () => context.push('/profile/type/products/$kitId'),
              ),
            ],
          ),
        );
      },
    );
  }

  String? _titleSection(ProfilePage? page) {
    final section = page?.sections
        .whereType<ProfilePageTitleSection>()
        .firstOrNull;
    return section?.title;
  }

  /// Builds the characteristics-card gradient from the biotype colors when both
  /// are provided by the CMS, otherwise falls back to the brand gradient.
  List<Color>? _gradientFor(Biotype biotype) {
    final main = colorFromHex(biotype.mainColor);
    final secondary = colorFromHex(biotype.secondaryColor);
    if (main == null || secondary == null) return null;
    return [main, secondary];
  }
}

/// Small circular biotype badge shown at the top-right of the header.
class _TypeBadge extends StatelessWidget {
  const _TypeBadge({this.iconUrl, this.badgeColor});

  final String? iconUrl;

  /// Badge background (`main_color`). Falls back to the brand gradient.
  final Color? badgeColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: badgeColor,
        gradient: badgeColor == null ? AppColors.brandGradient : null,
      ),
      alignment: Alignment.center,
      child: CmsSvgIcon(
        url: iconUrl,
        size: 20,
        color: AppColors.neutralWhite,
        fallback: const Icon(
          Icons.water_drop_outlined,
          color: AppColors.neutralWhite,
          size: 20,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.spaceLg),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: AppTypography.textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
