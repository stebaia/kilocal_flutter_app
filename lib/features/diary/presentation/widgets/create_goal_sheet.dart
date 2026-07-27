import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/diary_goal.dart';
import '../../domain/entities/goal_category.dart';

/// Sheet to create a new **personal** goal (content + category + optional date).
/// Returns a [DiaryGoalInput], or `null` if cancelled.
///
/// [categories] come from the `goal_categories` catalog (loaded by the cubit).
Future<DiaryGoalInput?> showCreateGoalSheet(
  BuildContext context, {
  required List<GoalCategory> categories,
}) {
  return showModalBottomSheet<DiaryGoalInput>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
    ),
    builder: (context) => _CreateGoalSheet(categories: categories),
  );
}

/// Sheet to **edit** an existing personal goal: same layout as create, but
/// pre-filled from [goal] and titled "Modifica traguardo". Returns the edited
/// [DiaryGoalInput], or `null` if cancelled.
Future<DiaryGoalInput?> showEditGoalSheet(
  BuildContext context, {
  required DiaryGoal goal,
  required List<GoalCategory> categories,
}) {
  return showModalBottomSheet<DiaryGoalInput>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
    ),
    builder: (context) =>
        _CreateGoalSheet(categories: categories, initial: goal),
  );
}

class _CreateGoalSheet extends StatefulWidget {
  const _CreateGoalSheet({required this.categories, this.initial});

  final List<GoalCategory> categories;

  /// When set, the sheet is in edit mode: fields are pre-filled from this
  /// goal and the title/behavior switches to "Modifica traguardo".
  final DiaryGoal? initial;

  @override
  State<_CreateGoalSheet> createState() => _CreateGoalSheetState();
}

class _CreateGoalSheetState extends State<_CreateGoalSheet> {
  late final _controller = TextEditingController(
    text: widget.initial?.content ?? '',
  );
  DateTime? _dueDate;
  GoalCategory? _category;

  bool get _isEdit => widget.initial != null;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _dueDate = initial?.dueDate;
    if (initial?.category != null) {
      _category = widget.categories
          .where((c) => c.id == initial!.category)
          .firstOrNull;
    }
    _category ??= widget.categories.isNotEmpty ? widget.categories.first : null;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _canSave => _controller.text.trim().isNotEmpty && _category != null;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.spaceLg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isEdit ? l10n.diaryGoalEditTitle : l10n.diaryGoalCreateTitle,
                style: AppTypography.textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.spaceMd),
              TextField(
                controller: _controller,
                autofocus: true,
                minLines: 1,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: l10n.diaryGoalContentHint,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
                onChanged: (_) => setState(() {}),
              ),
              if (widget.categories.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.spaceMd),
                Text(
                  l10n.diaryGoalCategory,
                  style: AppTypography.textTheme.labelMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.spaceXs),
                Wrap(
                  spacing: AppSpacing.spaceXs,
                  runSpacing: AppSpacing.spaceXs,
                  children: [
                    for (final category in widget.categories)
                      _CategoryChip(
                        label: category.title,
                        isSelected: _category?.id == category.id,
                        onTap: () => setState(() => _category = category),
                      ),
                  ],
                ),
              ],
              const SizedBox(height: AppSpacing.spaceMd),
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.spaceSm,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 18,
                        color: AppColors.accent,
                      ),
                      const SizedBox(width: AppSpacing.spaceXs),
                      Text(
                        _dueDate == null
                            ? l10n.diaryGoalPickDate
                            : _formatDate(_dueDate!),
                        style: AppTypography.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.spaceMd),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.accent,
                  ),
                  onPressed: _canSave ? _submit : null,
                  child: Text(l10n.diaryGoalSave),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 5)),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  void _submit() {
    Navigator.of(context).pop(
      DiaryGoalInput(
        content: _controller.text.trim(),
        dueDate: _dueDate,
        category: _category?.id,
        relatedGoal: widget.initial?.relatedGoal,
      ),
    );
  }

  static String _formatDate(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    return '$d/$m/${date.year}';
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.spaceMd,
          vertical: AppSpacing.spaceXs,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent : AppColors.background,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(
            color: isSelected ? AppColors.accent : AppColors.borderCard,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.textTheme.labelMedium?.copyWith(
            color: isSelected ? AppColors.surface : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
