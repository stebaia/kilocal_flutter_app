import 'package:flutter/material.dart';

import '../../domain/entities/home_data.dart';
import 'action_card.dart';

class ActionCardsGrid extends StatelessWidget {
  const ActionCardsGrid({super.key, required this.cards});

  final List<HomeActionCard> cards;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 165,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: cards.length,
        separatorBuilder: (_, _) => const SizedBox(width: 16),
        itemBuilder: (_, index) =>
            SizedBox(width: 159, child: ActionCard(card: cards[index])),
      ),
    );
  }
}
