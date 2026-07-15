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
import 'widgets/profile_product_tile.dart';
import 'widgets/profile_section_label.dart';
import 'widgets/profile_type_characteristics_card.dart';

/// "Il mio Tipo" detail screen ("Le tue caratteristiche") opened from the
/// profile type card.
///
/// The biotype (`user_details.profile`, see [[profiles-biotype-schema]]) comes
/// from the session-wide [UserCubit]. The percorsi block and kit products live
/// on their own routes opened from the cards below.
class ProfileTypeScreen extends StatelessWidget {
  const ProfileTypeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColors.surface,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: BlocBuilder<UserCubit, UserState>(
        bloc: getIt<UserCubit>(),
        builder: (context, state) {
          final biotype = state.details?.biotype;
          final title =
              biotype?.header(l10n.profileMyTypeSection) ??
              l10n.profileTypeUnknown;

          return Scaffold(
            backgroundColor: AppColors.background,
            // top: false — AppHeader insets the status bar; SafeArea guards
            // only the bottom against the Android system navigation bar.
            body: SafeArea(
              top: false,
              child: Column(
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
            ),
          );
        },
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
          // Biotype description — HTML markup from the CMS
          // `content`/`content_f` field, shown when populated.
          if (biotype.description != null &&
              biotype.description!.isNotEmpty) ...[
            _BiotypeDescriptionHtml(html: biotype.description!),
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

/// Renders the biotype description HTML (`profiles.translations.content` /
/// `content_f`, see [[profiles-biotype-schema]]).
///
/// The CMS copy mixes plain paragraphs, `<h3>` headings, `<strong>`/`<b>` runs
/// and `<br>` breaks, plus HTML entities (`&agrave;`, `&ldquo;`, …). We style
/// each tag explicitly so headings and bold runs keep their emphasis: applying
/// only a `body` `fontSize` would flatten the `em`-relative heading sizes and
/// wash out the visual hierarchy the CMS author intended.
class _BiotypeDescriptionHtml extends StatelessWidget {
  const _BiotypeDescriptionHtml({required this.html});

  final String html;

  @override
  Widget build(BuildContext context) {
    final baseSize = AppTypography.textTheme.bodyMedium?.fontSize ?? 14;
    return Html(
      data: html,
      shrinkWrap: true,
      style: {
        'body': Style(
          margin: Margins.zero,
          padding: HtmlPaddings.zero,
          color: AppColors.textSecondary,
          fontSize: FontSize(baseSize),
          lineHeight: const LineHeight(1.5),
        ),
        'p': Style(
          margin: Margins.only(bottom: AppSpacing.spaceSm),
          padding: HtmlPaddings.zero,
        ),
        // Paragraph/heading emphasis: force the heading tags to a fixed size
        // and bold weight so they stand out from the body copy regardless of
        // the CMS markup variant.
        'h1': _headingStyle(baseSize + 6),
        'h2': _headingStyle(baseSize + 4),
        'h3': _headingStyle(baseSize + 2),
        'strong': Style(
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        'b': Style(
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      },
    );
  }

  Style _headingStyle(double size) => Style(
    margin: Margins.only(bottom: AppSpacing.spaceXs),
    padding: HtmlPaddings.zero,
    fontSize: FontSize(size),
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    lineHeight: const LineHeight(1.3),
  );
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
