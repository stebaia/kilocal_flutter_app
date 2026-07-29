import 'package:flutter/material.dart';

import '../../domain/entities/home_data.dart';
import 'action_card.dart';

class ActionCardsGrid extends StatelessWidget {
  const ActionCardsGrid({super.key, required this.cards});

  final List<HomeActionCard> cards;

  static const _cardWidth = 159.0;
  static const _cardGap = 16.0;

  @override
  Widget build(BuildContext context) {
    final fixedContentWidth =
        cards.length * _cardWidth + (cards.length - 1) * _cardGap;

    return SizedBox(
      height: 165,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Cards fit at their normal fixed width (tablets, wide phones):
          // center them instead of leaving them left-aligned with a phantom
          // scrollbar over dead space.
          if (fixedContentWidth <= constraints.maxWidth) {
            return Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < cards.length; i++) ...[
                    if (i > 0) const SizedBox(width: _cardGap),
                    SizedBox(
                      width: _cardWidth,
                      child: ActionCard(card: cards[i]),
                    ),
                  ],
                ],
              ),
            );
          }

          // Narrow screens: with only a couple of cards, shrink them to fit
          // evenly instead of clipping the last one at the screen edge —
          // both must stay fully visible without requiring a swipe.
          if (cards.length <= 2) {
            return Row(
              children: [
                for (var i = 0; i < cards.length; i++) ...[
                  if (i > 0) const SizedBox(width: _cardGap),
                  Expanded(child: ActionCard(card: cards[i])),
                ],
              ],
            );
          }

          // 3+ cards on a narrow screen: shrinking every card to fit would
          // make them illegibly small, so scroll instead, with a visible
          // side scrollbar as the swipe affordance.
          return Scrollbar(
            thumbVisibility: true,
            trackVisibility: false,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: cards.length,
              separatorBuilder: (_, _) => const SizedBox(width: _cardGap),
              itemBuilder: (_, index) => SizedBox(
                width: _cardWidth,
                child: ActionCard(card: cards[index]),
              ),
            ),
          );
        },
      ),
    );
  }
}
