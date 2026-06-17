import 'package:flutter/material.dart';
import 'package:kilocal_flutter_app/l10n/app_localizations.dart';

import '../../../core/theme/app_spacing.dart';
import 'widgets/benefit_card.dart';

class BenefitsScreen extends StatelessWidget {
  const BenefitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final partners = ['Twitch', 'Spotify', 'Refeego', 'Nike'];
    final codes = ['TWITCH10', 'SPOT20', 'REFEEGO5', 'NIKE15'];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.benefitsTitle)),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenGutter,
          vertical: AppSpacing.spaceMd,
        ),
        itemCount: partners.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.spaceSm),
            child: BenefitCard(
              partner: partners[index],
              code: codes[index],
              detailsLabel: l10n.benefitDetails,
            ),
          );
        },
      ),
    );
  }
}
