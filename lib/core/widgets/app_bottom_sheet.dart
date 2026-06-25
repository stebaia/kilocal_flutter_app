import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

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
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenGutter,
                ),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenGutter,
                ),
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

/// Bottom sheet with the fixed brand-red header and an arbitrary [child] body.
///
/// Unlike [AppBottomSheet] (white header with a close button, for info/filter
/// drawers), this variant always shows the red gradient header with a
/// configurable [title]. The body is a fully custom widget supplied by the
/// caller; it is *not* wrapped in a scroll view, so the content owns its own
/// layout. Returns whatever the [child] pops the sheet with.
class AppBrandBottomSheet extends StatelessWidget {
  const AppBrandBottomSheet({
    super.key,
    required this.title,
    required this.child,
  });

  /// Configurable header text.
  final String title;

  /// Custom body rendered under the brand header.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _BrandHeader(title: title),
          Flexible(child: child),
        ],
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenGutter,
        AppSpacing.spaceXl,
        AppSpacing.screenGutter,
        AppSpacing.spaceLg,
      ),
      decoration: const BoxDecoration(
        gradient: AppColors.brandGradient,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      child: Text(
        title,
        style: AppTypography.textTheme.titleMedium?.copyWith(
          color: AppColors.neutralWhite,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Shows an [AppBrandBottomSheet]: brand-red header + custom [child] body.
Future<T?> showAppBrandBottomSheet<T>(
  BuildContext context, {
  required String title,
  required Widget child,
  bool isScrollControlled = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
    ),
    builder: (_) => AppBrandBottomSheet(title: title, child: child),
  );
}
