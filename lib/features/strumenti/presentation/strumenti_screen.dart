import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_header.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/entities/strumento.dart';
import 'widgets/strumento_card.dart';

/// Bottom-nav "Strumenti" tab: a list of red tool cards.
///
/// The catalogue is static (client-side); tapping a card launches its tool,
/// which for now routes to a "coming soon" placeholder.
class StrumentiScreen extends StatelessWidget {
  const StrumentiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final strumenti = _catalogue(l10n);

    return Scaffold(
      backgroundColor: AppColors.background,
      // top: false — AppHeader insets the status bar; SafeArea guards only the
      // bottom against the Android system navigation bar.
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppHeader(title: l10n.strumentiTitle),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.screenGutter),
                itemCount: strumenti.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.spaceMd),
                itemBuilder: (context, index) {
                  final strumento = strumenti[index];
                  return StrumentoCard(
                    strumento: strumento,
                    onTap: () =>
                        context.push('/strumenti/${strumento.id.name}'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// The fixed set of tools, with localized titles and bundled illustrations.
  List<Strumento> _catalogue(AppLocalizations l10n) => [
    Strumento(
      id: StrumentoId.promemoria,
      title: l10n.strumentiPromemoria,
      assetName: 'assets/strumenti/promemoria.png',
    ),
    Strumento(
      id: StrumentoId.timer,
      title: l10n.strumentiTimer,
      assetName: 'assets/strumenti/timer.png',
    ),
    Strumento(
      id: StrumentoId.glossario,
      title: l10n.strumentiGlossario,
      assetName: 'assets/strumenti/glossario.png',
    ),
    Strumento(
      id: StrumentoId.gallery,
      title: l10n.strumentiGallery,
      assetName: 'assets/strumenti/gallery.png',
    ),
  ];
}
