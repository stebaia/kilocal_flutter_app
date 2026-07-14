import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kilocal_flutter_app/features/profile/presentation/widgets/profile_type_percorsi_sheet.dart';

import '../../../app/di.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/hex_color.dart';
import '../../../core/widgets/app_header.dart';
import '../../../l10n/app_localizations.dart';
import '../../user/domain/user_details.dart';
import '../../user/presentation/cubit/user_cubit.dart';
import '../data/biotype_texts_loader.dart';
import 'widgets/biotype_body_map_card.dart';
import 'widgets/biotype_body_points.dart';
import 'widgets/biotype_point_sheet.dart';
import 'widgets/profile_type_percorsi_grid.dart';

/// "Scopri di più" screen opened from the biotype characteristics card
/// ("Le tue caratteristiche"): the interactive biotype body map plus the
/// path-category shortcuts. See [[profile-cms-pages-schema]].
class ProfileTypePercorsiScreen extends StatelessWidget {
  const ProfileTypePercorsiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColors.surface,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            AppHeader(title: l10n.profileTypeCharacteristics, showBack: true),
            // top: false — AppHeader already insets for the status bar; here we
            // only guard the bottom against the Android system navigation bar.
            Expanded(
              child: SafeArea(
                top: false,
                child: BlocBuilder<UserCubit, UserState>(
                  bloc: getIt<UserCubit>(),
                  builder: (context, state) {
                    final details = state.details;
                    final biotype = details?.biotype;
                    if (biotype == null) return const SizedBox.shrink();

                    final accent =
                        colorFromHex(biotype.mainColor) ?? AppColors.accent;
                    final isFemale = details!.isFemale;

                    return FutureBuilder<BiotypeTexts?>(
                      future: getIt<BiotypeTextsLoader>().forBiotype(
                        number: biotype.number,
                        isFemale: isFemale,
                      ),
                      builder: (context, snapshot) {
                        final texts = snapshot.data;
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.screenGutter,
                            AppSpacing.spaceLg,
                            AppSpacing.screenGutter,
                            AppSpacing.spaceLg,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Body map takes 4/5 of the available height, the
                              // category buttons the remaining 1/5, with no gap.
                              Expanded(
                                flex: 4,
                                child: _BiotypeBodyMap(
                                  biotype: biotype,
                                  isFemale: isFemale,
                                  accentColor: accent,
                                  texts: texts,
                                  l10n: l10n,
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Align(
                                  alignment: Alignment.topCenter,
                                  child: ProfileTypePercorsiGrid(
                                    accentColor: accent,
                                    areaTexts: texts?.areas ?? const {},
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The interactive body-map card ("Il tuo punto di partenza"): the dot-free
/// biotype silhouette overlaid with clickable dots. Each dot opens a sheet with
/// its zone text, joined to the dot by index ([BiotypeTexts.points] is ordered
/// to match the dot positions).
class _BiotypeBodyMap extends StatelessWidget {
  const _BiotypeBodyMap({
    required this.biotype,
    required this.isFemale,
    required this.accentColor,
    required this.texts,
    required this.l10n,
  });

  final Biotype biotype;
  final bool isFemale;
  final Color accentColor;
  final BiotypeTexts? texts;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final points = biotypeBodyPointsFor(
      number: biotype.number,
      isFemale: isFemale,
    );
    final pointTexts = texts?.points ?? const [];

    return BiotypeBodyMapCard(
      title: l10n.profileTypeStartingPoint(biotype.displayName),
      accentColor: accentColor,
      silhouetteAssetName: biotype.silhouetteCleanAssetName,
      silhouetteAspect: isFemale
          ? BiotypeBodyMapCard.womanSilhouetteAspect
          : BiotypeBodyMapCard.manSilhouetteAspect,
      points: points,
      onPointTap: (point) {
        final index = points.indexOf(point);
        final text = index >= 0 && index < pointTexts.length
            ? pointTexts[index]
            : null;
        showProfileTypePercorsiSheet(
          context,
          area: '',
          title: text!.title,
          body: text.body,
          accentColor: accentColor,
        );
      },
    );
  }
}
