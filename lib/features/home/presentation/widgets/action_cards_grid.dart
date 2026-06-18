import 'package:flutter/material.dart';

import '../../domain/entities/home_data.dart';
import 'action_card.dart';

class ActionCardsGrid extends StatelessWidget {
  const ActionCardsGrid({super.key, required this.cards});

  final List<HomeActionCard> cards;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: cards.asMap().entries.map((entry) {
        final index = entry.key;
        final card = entry.value;
        return Padding(
          padding: EdgeInsets.only(right: index == 0 ? 24 : 0),
          child: SizedBox(width: 159, child: ActionCard(card: card)),
        );
      }).toList(),
    );
  }
}
