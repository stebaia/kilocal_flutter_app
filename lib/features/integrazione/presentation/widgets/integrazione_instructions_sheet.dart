import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/di.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../survey/presentation/widgets/survey_html.dart';
import '../../data/integrazione_reminder_service.dart';
import '../../domain/entities/integrazione_data.dart';
import '../../domain/entities/reminder_offset.dart';
import 'integrazione_reminder_sheets.dart';

/// Bottom sheet with a supplement's usage instructions, dosage/timing, planned
/// dates and an "enable reminder" action (a client-side local notification).
class IntegrazioneInstructionsSheet extends StatelessWidget {
  const IntegrazioneInstructionsSheet({super.key, required this.product});

  final IntegrazioneProduct product;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tracking = product.tracking;
    final dateFormat = DateFormat('dd/MM/yy');

    return SafeArea(
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        maxChildSize: 0.92,
        minChildSize: 0.4,
        builder: (context, scrollController) {
          return Column(
            children: [
              const _SheetGrabber(),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.spaceLg,
                    AppSpacing.spaceSm,
                    AppSpacing.spaceLg,
                    AppSpacing.spaceLg,
                  ),
                  children: [
                    _SectionTitle(l10n.integrationInstructionsTitle),
                    const SizedBox(height: AppSpacing.spaceSm),
                    if (_has(product.timing))
                      SurveyHtml(html: product.timing!, lineHeight: 1.4),
                    if (_has(product.instructions)) ...[
                      const SizedBox(height: AppSpacing.spaceSm),
                      SurveyHtml(html: product.instructions!, lineHeight: 1.4),
                    ],
                    if (_has(product.description)) ...[
                      const SizedBox(height: AppSpacing.spaceMd),
                      SurveyHtml(html: product.description!, lineHeight: 1.4),
                    ],
                    if (tracking?.startedOn != null ||
                        tracking?.expectedToEndOn != null) ...[
                      const SizedBox(height: AppSpacing.spaceLg),
                      _SectionTitle(l10n.integrationInstructionsTitle),
                      const SizedBox(height: AppSpacing.spaceSm),
                      if (tracking?.startedOn != null)
                        _DateRow(
                          label: l10n.integrationStartDate,
                          value: dateFormat.format(tracking!.startedOn!),
                        ),
                      if (tracking?.expectedToEndOn != null)
                        _DateRow(
                          label: l10n.integrationExpectedEndDate,
                          value: dateFormat.format(tracking!.expectedToEndOn!),
                        ),
                    ],
                    if (_has(product.avvertenze)) ...[
                      const SizedBox(height: AppSpacing.spaceMd),
                      SurveyHtml(html: product.avvertenze!, lineHeight: 1.4),
                    ],
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.spaceLg),
                child: _ReminderButton(product: product),
              ),
            ],
          );
        },
      ),
    );
  }

  static bool _has(String? s) => s != null && s.trim().isNotEmpty;
}

class _SheetGrabber extends StatelessWidget {
  const _SheetGrabber();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.spaceSm),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: AppColors.borderCard,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          style: AppTypography.textTheme.titleMedium?.copyWith(
            color: AppColors.accent,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        const Divider(height: 1, color: AppColors.borderCard),
      ],
    );
  }
}

class _DateRow extends StatelessWidget {
  const _DateRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.textTheme.bodyMedium),
          Text(
            value,
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReminderButton extends StatefulWidget {
  const _ReminderButton({required this.product});

  final IntegrazioneProduct product;

  @override
  State<_ReminderButton> createState() => _ReminderButtonState();
}

class _ReminderButtonState extends State<_ReminderButton> {
  final IntegrazioneReminderService _service =
      getIt<IntegrazioneReminderService>();

  ActiveReminder? _active;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final active = await _service.getReminder(widget.product.id);
    if (mounted) {
      setState(() {
        _active = active;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final active = _active;

    // Solid red "active" button when a reminder exists; outlined "enable" button
    // otherwise. Keep the outlined look while the pending state is still loading.
    if (active != null) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _loading ? null : _openFlow,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: AppColors.neutralWhite,
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.spaceMd),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
          ),
          child: Text(
            l10n.integrationReminderActiveLabel(
              reminderOffsetShortLabel(l10n, active.offset),
            ),
            style: AppTypography.textTheme.titleSmall?.copyWith(
              color: AppColors.neutralWhite,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: _loading ? null : _openFlow,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.accent,
          side: const BorderSide(color: AppColors.accent),
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.spaceMd),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
        ),
        child: Text(
          l10n.integrationEnableReminder,
          style: AppTypography.textTheme.titleSmall?.copyWith(
            color: AppColors.accent,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Future<void> _openFlow() async {
    // Opens the reminder flow (add, or edit/delete if one is already set), then
    // refreshes so the button reflects the new state.
    await showIntegrazioneReminderFlow(
      context,
      service: _service,
      product: widget.product,
    );
    await _refresh();
  }
}
