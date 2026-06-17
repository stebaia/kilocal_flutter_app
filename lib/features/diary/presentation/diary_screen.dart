import 'package:flutter/material.dart';
import 'package:kilocal_flutter_app/l10n/app_localizations.dart';

import '../../../core/theme/app_spacing.dart';
import 'widgets/diary_entry_card.dart';

class DiaryScreen extends StatelessWidget {
  const DiaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.diaryTitle)),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenGutter,
          vertical: AppSpacing.spaceMd,
        ),
        itemCount: 6,
        itemBuilder: (context, index) {
          final isCompleted = index % 2 == 0;
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.spaceSm),
            child: DiaryEntryCard(
              title: 'Attività giorno ${index + 1}',
              subtitle: isCompleted ? l10n.diaryCompleted : l10n.diaryPending,
              isCompleted: isCompleted,
            ),
          );
        },
      ),
    );
  }
}
