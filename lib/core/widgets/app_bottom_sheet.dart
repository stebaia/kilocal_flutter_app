import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Reusable bottom sheet scaffold used for info drawers ("Tendina info")
/// and filter modals ("Modale filtri") across the app.
///
/// Provide [title] and [child] content; the sheet handles the drag handle,
/// rounded top corners, and safe-area padding.
class AppBottomSheet extends StatelessWidget {
  const AppBottomSheet({
    super.key,
    this.title,
    required this.child,
    this.showDragHandle = true,
  });

  final String? title;
  final Widget child;
  final bool showDragHandle;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(top: AppSpacing.spaceSm),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showDragHandle)
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
              ),
            if (showDragHandle) const SizedBox(height: AppSpacing.spaceMd),
            if (title != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenGutter),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title!,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
            if (title != null) const SizedBox(height: AppSpacing.spaceSm),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenGutter),
                child: child,
              ),
            ),
            const SizedBox(height: AppSpacing.spaceMd),
          ],
        ),
      ),
    );
  }
}

/// Shows an [AppBottomSheet] via showModalBottomSheet with the app's standard shape.
Future<T?> showAppBottomSheet<T>({
  required BuildContext context,
  String? title,
  required Widget child,
  bool showDragHandle = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
    ),
    builder: (_) => AppBottomSheet(
      title: title,
      showDragHandle: showDragHandle,
      child: child,
    ),
  );
}