import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';

/// Side-by-side comparison of two photos: [before] fills the frame and [after]
/// is revealed to the right of a draggable cursor.
///
/// Entirely client-side — the backend has no split endpoint, this is just a
/// clip driven by a drag ([[photo-gallery-schema]]).
class SplitImageView extends StatefulWidget {
  const SplitImageView({
    super.key,
    required this.beforeUrl,
    required this.afterUrl,
  });

  final String beforeUrl;
  final String afterUrl;

  @override
  State<SplitImageView> createState() => _SplitImageViewState();
}

class _SplitImageViewState extends State<SplitImageView> {
  /// Cursor position as a fraction of the width, starting at the middle.
  double _fraction = 0.5;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: AspectRatio(
        aspectRatio: 3 / 4,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;

            void updateFrom(Offset localPosition) {
              setState(
                () => _fraction = (localPosition.dx / width).clamp(0.0, 1.0),
              );
            }

            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onHorizontalDragUpdate: (d) => updateFrom(d.localPosition),
              onTapDown: (d) => updateFrom(d.localPosition),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _Photo(url: widget.beforeUrl),
                  // The "after" photo is clipped to the right of the cursor.
                  // Align(widthFactor:) would scale it; a rect clip keeps both
                  // images at the same size so the seam lines up.
                  ClipRect(
                    clipper: _RightOfCursor(_fraction),
                    child: _Photo(url: widget.afterUrl),
                  ),
                  Positioned(
                    left: width * _fraction - _handleRadius,
                    top: 0,
                    bottom: 0,
                    child: const _Cursor(),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

const double _handleRadius = 18;

class _RightOfCursor extends CustomClipper<Rect> {
  const _RightOfCursor(this.fraction);

  final double fraction;

  @override
  Rect getClip(Size size) =>
      Rect.fromLTRB(size.width * fraction, 0, size.width, size.height);

  @override
  bool shouldReclip(_RightOfCursor oldClipper) =>
      oldClipper.fraction != fraction;
}

/// The divider line with its round drag handle.
class _Cursor extends StatelessWidget {
  const _Cursor();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _handleRadius * 2,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(width: 2, color: AppColors.ink),
          Container(
            width: _handleRadius * 2,
            height: _handleRadius * 2,
            decoration: BoxDecoration(
              color: AppColors.neutralWhite,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.ink.withValues(alpha: 0.25),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Photo extends StatelessWidget {
  const _Photo({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      fit: BoxFit.cover,
      alignment: Alignment.topCenter,
      errorBuilder: (_, _, _) => Container(color: AppColors.divider),
    );
  }
}
