import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../app/di.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_header.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/entities/path_area_detail.dart';
import 'cubit/path_detail_cubit.dart';

class PathStepScreen extends StatelessWidget {
  const PathStepScreen({
    super.key,
    required this.area,
    required this.stepId,
    this.step,
  });

  final String area;
  final String stepId;
  final PathStepItem? step;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocProvider(
      create: (_) => getIt<PathDetailCubit>()..load(area: area, l10n: l10n),
      child: _PathStepView(area: area, stepId: stepId, initialStep: step),
    );
  }
}

class _PathStepView extends StatelessWidget {
  const _PathStepView({
    required this.area,
    required this.stepId,
    this.initialStep,
  });

  final String area;
  final String stepId;
  final PathStepItem? initialStep;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppHeader(title: l10n.pathStepContentTitle, showBack: true),
          Expanded(
            child: BlocBuilder<PathDetailCubit, PathDetailState>(
              builder: (context, state) {
                final step = _resolveStep(state);

                if (step == null && state.status == PathDetailStatus.loading) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.accent),
                  );
                }

                if (step == null) {
                  return Center(
                    child: Text(
                      l10n.errorGeneric,
                      style: AppTypography.textTheme.bodyMedium,
                    ),
                  );
                }

                return _StepContent(step: step, area: area);
              },
            ),
          ),
        ],
      ),
    );
  }

  PathStepItem? _resolveStep(PathDetailState state) {
    if (initialStep != null && state.status != PathDetailStatus.loaded) {
      return initialStep;
    }
    final data = state.data;
    if (data == null) return initialStep;
    for (final group in data.timeframeGroups) {
      for (final step in group.steps) {
        if (step.id == stepId) return step;
      }
    }
    return initialStep;
  }
}

class _StepContent extends StatelessWidget {
  const _StepContent({required this.step, required this.area});

  final PathStepItem step;
  final String area;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ListView(
      padding: const EdgeInsets.only(bottom: AppSpacing.spaceXl),
      children: [
        // Keyed by step id so the WebView is not rebuilt when the cubit reloads
        // after a complete action on the same step.
        _StepMedia(key: ValueKey(step.id), step: step),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenGutter,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.spaceLg),
              Text(
                step.title,
                style: AppTypography.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.spaceSm),
              Text(
                step.timeframeTitle,
                style: AppTypography.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.spaceLg),
              _StatusLabel(step: step),
              const SizedBox(height: AppSpacing.spaceXl),
              if (!step.isCompleted && !step.isLocked)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _completeStep(context),
                    child: Text(l10n.pathStepComplete),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _completeStep(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<PathDetailCubit>();
    await cubit.completeStep(stepId: step.id, area: area, l10n: l10n);
    if (context.mounted) {
      context.pop(true);
    }
  }
}

/// Step media header: a Vimeo player (when the asset is a video) or an image.
///
/// Owns its own [WebViewController] for the whole lifetime of the widget and
/// disposes of it via the platform controller when removed from the tree. Give
/// it a stable [key] (e.g. the step id) so it survives unrelated rebuilds.
class _StepMedia extends StatefulWidget {
  const _StepMedia({super.key, required this.step});

  final PathStepItem step;

  @override
  State<_StepMedia> createState() => _StepMediaState();
}

class _StepMediaState extends State<_StepMedia> {
  static const double _mediaHeight = 250;

  WebViewController? _controller;

  @override
  void initState() {
    super.initState();
    final embedUrl = widget.step.asset.vimeoEmbedUrl;
    if (widget.step.asset.isVideo && embedUrl != null) {
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(AppColors.surface)
        ..loadRequest(Uri.parse(embedUrl));
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = widget.step.asset;
    final controller = _controller;

    if (controller != null) {
      return SizedBox(
        height: _mediaHeight,
        child: WebViewWidget(controller: controller),
      );
    }

    if (media.imageUrl != null) {
      return ClipRRect(
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(AppRadius.lg),
        ),
        child: Image.network(
          media.imageUrl!,
          height: _mediaHeight,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      );
    }

    return Container(
      height: _mediaHeight,
      color: AppColors.surface,
      child: const Center(
        child: Icon(Icons.image_not_supported, color: AppColors.textSecondary),
      ),
    );
  }
}

class _StatusLabel extends StatelessWidget {
  const _StatusLabel({required this.step});

  final PathStepItem step;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final String text;
    final Color color;

    if (step.isCompleted) {
      text = l10n.pathStepCompleted;
      color = AppColors.accent;
    } else if (step.isLocked) {
      text = l10n.pathStepLocked;
      color = AppColors.textSecondary;
    } else if (step.isCurrent) {
      text = l10n.pathStepCurrent;
      color = AppColors.accent;
    } else {
      text = l10n.pathStepStarted;
      color = AppColors.textSecondary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.spaceMd,
        vertical: AppSpacing.spaceXs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        text,
        style: AppTypography.textTheme.labelMedium?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
