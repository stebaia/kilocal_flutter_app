import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import 'survey_cta_button.dart';

/// The kit actions under the Starter Kit card on the biotype result screen.
///
/// "Vai allo shop" opens `kit_shop_url` from the submit response. The button is
/// omitted when it has no destination, so the row degrades instead of showing a
/// dead control.
///
/// **No "Inserisci prova d'acquisto" here.** It looks like it belongs — the web
/// design shows it — but the proof of purchase is collected by the `starter_kit`
/// survey, which `profile_status` sends the user to next. An unlock button here
/// would be both redundant and wrong: it opens the restricted-access sheet,
/// whose `PATCH /profile` jumps straight to `active` and would skip the
/// `starter_kit` survey entirely. It also sat beside "Fine", reading as
/// mandatory while being optional. See `wiki/survey.md`.
///
/// TODO(backend): "Trova una Farmacia Kilocal Point" has no confirmed
/// destination yet — the web survey links out to a store locator, but no URL
/// exists in the CMS contract and the `pharmacies` collection has no public
/// finder page. Hidden until backend supplies one (see wiki/survey.md).
class SurveyResultActions extends StatelessWidget {
  const SurveyResultActions({
    super.key,
    this.kitShopUrl,
    this.pharmacyFinderUrl,
  });

  final String? kitShopUrl;
  final String? pharmacyFinderUrl;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final buttons = <Widget>[
      if (_uri(pharmacyFinderUrl) case final uri?)
        SurveyCtaButton.outlined(
          label: l10n.surveyFindPharmacy,
          onPressed: () => launchUrl(uri, mode: LaunchMode.externalApplication),
        ),
      if (_uri(kitShopUrl) case final uri?)
        SurveyCtaButton.outlined(
          label: l10n.surveyGoToShop,
          onPressed: () => launchUrl(uri, mode: LaunchMode.externalApplication),
        ),
    ];

    return Column(
      children: [
        for (final (i, button) in buttons.indexed) ...[
          if (i > 0) const SizedBox(height: AppSpacing.spaceSm),
          button,
        ],
      ],
    );
  }

  Uri? _uri(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    final uri = Uri.tryParse(raw);
    return (uri != null && uri.hasScheme) ? uri : null;
  }
}
