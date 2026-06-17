import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/home_data.dart';
import 'action_card.dart';

class ActionCardsGrid extends StatelessWidget {
  const ActionCardsGrid({super.key, required this.cards});

  final List<HomeActionCard> cards;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: cards.map((card) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: card == cards.first ? AppSpacing.spaceSm : 0,
            ),
            child: ActionCard(card: card),
          ),
        );
      }).toList(),
    );
  }
}
