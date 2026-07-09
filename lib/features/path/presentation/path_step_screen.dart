import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../app/di.dart';
import '../../../core/icons/app_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../l10n/app_localizations.dart';
import '../data/system_timer_service.dart';
import '../data/vimeo_oembed_service.dart';
import '../domain/entities/path_area_detail.dart';
import 'cubit/path_detail_cubit.dart';
import 'widgets/path_activities_sheet.dart';
import 'widgets/path_timer_pill.dart';
import 'widgets/path_timer_sheet.dart';

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

class _PathStepView extends StatefulWidget {
  const _PathStepView({
    required this.area,
    required this.stepId,
    this.initialStep,
  });

  final String area;
  final String stepId;
  final PathStepItem? initialStep;

  @override
  State<_PathStepView> createState() => _PathStepViewState();
}

class _PathStepViewState extends State<_PathStepView> {
  // Lives for the whole screen so the running timer survives sheet dismissals.
  final _timerController = PathTimerController(
    systemTimer: getIt<SystemTimerService>(),
  );

  @override
  void dispose() {
    _timerController.dispose();
    super.dispose();
  }

  String get area => widget.area;
  String get stepId => widget.stepId;
  PathStepItem? get initialStep => widget.initialStep;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.surface,
      // The header floats over the media, so the body extends to the top edge.
      body: BlocBuilder<PathDetailCubit, PathDetailState>(
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

          return Stack(
            children: [
              _StepContent(
                step: step,
                area: area,
                siblings: _siblingsOf(state, step),
                timerController: _timerController,
              ),
              // Persistent running-timer pill, above the bottom edge.
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: SafeArea(
                  child: PathTimerPill(controller: _timerController),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// All steps in the same timeframe as [step], used by the activities sheet.
  List<PathStepItem> _siblingsOf(PathDetailState state, PathStepItem step) {
    final data = state.data;
    if (data == null) return [step];
    for (final group in data.timeframeGroups) {
      if (group.steps.any((s) => s.id == step.id)) return group.steps;
    }
    return [step];
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
  const _StepContent({
    required this.step,
    required this.area,
    required this.siblings,
    required this.timerController,
  });

  final PathStepItem step;
  final String area;
  final List<PathStepItem> siblings;
  final PathTimerController timerController;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final description = step.description;

    return ListView(
      padding: const EdgeInsets.only(bottom: AppSpacing.spaceXl),
      children: [
        // Keyed by step id so the WebView is not rebuilt when the cubit reloads
        // after a complete action on the same step.
        _StepMedia(
          key: ValueKey(step.id),
          step: step,
          area: area,
          siblings: siblings,
          timerController: timerController,
        ),
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
              // Long body (HTML markup from the backend `content` field),
              // shown only when populated.
              if (description != null && description.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.spaceMd),
                Html(
                  data: description,
                  style: {
                    'body': Style(
                      margin: Margins.zero,
                      padding: HtmlPaddings.zero,
                      color: AppColors.textSecondary,
                      fontSize: FontSize(
                        AppTypography.textTheme.bodyMedium?.fontSize ?? 14,
                      ),
                      lineHeight: const LineHeight(1.5),
                    ),
                  },
                ),
              ],
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
  const _StepMedia({
    super.key,
    required this.step,
    required this.area,
    required this.siblings,
    required this.timerController,
  });

  final PathStepItem step;
  final String area;
  final List<PathStepItem> siblings;
  final PathTimerController timerController;

  @override
  State<_StepMedia> createState() => _StepMediaState();
}

class _StepMediaState extends State<_StepMedia> {
  static const double _mediaHeight = 417;

  /// oEmbed poster + duration for the video; null until fetched (or no video).
  VimeoOembed? _oembed;

  /// Once the user taps play we mount the Vimeo WebView and keep it mounted.
  WebViewController? _controller;

  bool get _isVideo =>
      widget.step.asset.isVideo && widget.step.asset.vimeoEmbedUrl != null;

  @override
  void initState() {
    super.initState();
    if (_isVideo) {
      _fetchOembed();
    }
  }

  Future<void> _fetchOembed() async {
    final url = widget.step.asset.vimeoUrl;
    if (url == null) return;
    final data = await getIt<VimeoOembedService>().fetch(url);
    if (mounted) setState(() => _oembed = data);
  }

  void _play() {
    final embedUrl = widget.step.asset.vimeoEmbedUrl;
    if (embedUrl == null) return;
    // Autoplay so the tap on the custom poster starts the video immediately.
    final autoplayUrl = Uri.parse(embedUrl).replace(
      queryParameters: {
        ...Uri.parse(embedUrl).queryParameters,
        'autoplay': '1',
      },
    );

    setState(() {
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(Colors.black)
        ..loadRequest(autoplayUrl);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _mediaHeight,
      width: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _buildSurface(),
            // The top bar (back + activities) stays visible over the player.
            _MediaTopBar(siblings: widget.siblings, step: widget.step,isActivities: widget.area == 'alimentazione' ),
            // The timer tools are hidden once the native player takes over,
            // and never shown in the nutrition area.
            if (_controller == null && widget.area != 'alimentazione')
              _MediaBottomTools(timerController: widget.timerController),
          ],
        ),
      ),
    );
  }

  /// The media itself: native player (once playing), custom poster, image, or
  /// a placeholder.
  Widget _buildSurface() {
    final media = widget.step.asset;
    final controller = _controller;

    if (controller != null) {
      return WebViewWidget(controller: controller);
    }

    if (_isVideo) {
      return _VideoPoster(
        thumbnailUrl: _oembed?.thumbnailUrl,
        duration: _oembed?.duration,
        height: _mediaHeight,
        onPlay: _play,
      );
    }

    if (media.imageUrl != null) {
      return Image.network(media.imageUrl!, fit: BoxFit.cover);
    }

    return Container(
      color: AppColors.surface,
      child: const Center(
        child: Icon(Icons.image_not_supported, color: AppColors.textSecondary),
      ),
    );
  }
}

/// Top overlay on the media: back button (left) + activities button (right).
class _MediaTopBar extends StatelessWidget {
  const _MediaTopBar({required this.siblings, required this.step, required this.isActivities});

  final List<PathStepItem> siblings;
  final PathStepItem step;
  final bool isActivities;

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.paddingOf(context).top;
    return Positioned(
      top: statusBarHeight + AppSpacing.spaceSm,
      left: AppSpacing.screenGutter,
      right: AppSpacing.screenGutter,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _RoundButton(
            dark: true,
            child: const Icon(Icons.chevron_left, color: Colors.white),
            onTap: () => Navigator.maybePop(context),
          ),
          _RoundButton(
            color: AppColors.accent,
            child: AppIcon(
              isActivities ? AppIcons.activities : AppIcons.training,
              size: 22,
              color: Colors.white,
            ),
            onTap: () => _openActivities(context),
          ),
        ],
      ),
    );
  }

  Future<void> _openActivities(BuildContext context) async {
    final area = GoRouterState.of(context).pathParameters['area'] ?? '';
    final selected = await showPathActivitiesSheet(
      context,
      steps: siblings,
      currentStepId: step.id,
    );
    if (selected != null && selected.id != step.id && context.mounted) {
      // Replace the current step with the chosen one.
      context.pushReplacement(
        '/path/$area/step/${selected.id}',
        extra: selected,
      );
    }
  }
}

/// Bottom-left overlay: the two timer tools.
class _MediaBottomTools extends StatelessWidget {
  const _MediaBottomTools({required this.timerController});

  final PathTimerController timerController;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: AppSpacing.screenGutter,
      bottom: AppSpacing.spaceMd,
      child: Row(
        children: [
          _RoundButton(
            child: SvgPicture.asset(
              'assets/icons/timer_set.svg',
              width: 20,
              height: 20,
            ),
            onTap: () => _openTimer(context),
          ),
          const SizedBox(width: AppSpacing.spaceSm),
          _RoundButton(
            child: SvgPicture.asset(
              'assets/icons/timer_calendar.svg',
              width: 20,
              height: 20,
            ),
            onTap: () => _openTimer(context),
          ),
        ],
      ),
    );
  }

  Future<void> _openTimer(BuildContext context) async {
    final duration = await showPathTimerSheet(context);
    if (duration != null) timerController.start(duration);
  }
}

/// Circular overlay button used across the media surface.
class _RoundButton extends StatelessWidget {
  const _RoundButton({
    required this.child,
    required this.onTap,
    this.dark = false,
    this.color,
  });

  final Widget child;
  final VoidCallback onTap;
  final bool dark;

  /// Explicit background color; overrides [dark] when provided.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color:
              color ??
              (dark ? Colors.black.withValues(alpha: 0.4) : Colors.white),
          shape: BoxShape.circle,
        ),
        child: Center(child: child),
      ),
    );
  }
}

/// Custom video poster shown before playback: thumbnail, centered play button,
/// and a duration badge — matching the design instead of Vimeo's native frame.
class _VideoPoster extends StatelessWidget {
  const _VideoPoster({
    required this.thumbnailUrl,
    required this.duration,
    required this.height,
    required this.onPlay,
  });

  final String? thumbnailUrl;
  final Duration? duration;
  final double height;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPlay,
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (thumbnailUrl != null)
              Image.network(
                thumbnailUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(color: Colors.black12),
              )
            else
              Container(color: Colors.black12),
            // Scrim so the play button stays legible over bright frames.
            const DecoratedBox(
              decoration: BoxDecoration(color: Colors.black26),
            ),
            const Center(
              child: Icon(
                Icons.play_circle_fill,
                color: Colors.white,
                size: 64,
              ),
            ),
            if (duration != null)
              Positioned(
                right: AppSpacing.spaceMd,
                bottom: AppSpacing.spaceMd,
                child: _DurationBadge(duration: duration!),
              ),
          ],
        ),
      ),
    );
  }
}

class _DurationBadge extends StatelessWidget {
  const _DurationBadge({required this.duration});

  final Duration duration;

  String _format() {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.spaceSm,
        vertical: AppSpacing.spaceXs,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        l10n.pathStepVideoDuration(_format()),
        style: AppTypography.textTheme.labelSmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
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
