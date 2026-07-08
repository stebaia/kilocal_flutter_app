import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kilocal_flutter_app/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import 'cubit/onboarding_cubit.dart';
import 'widgets/onboarding_arrow_button.dart';
import 'widgets/onboarding_cta_button.dart';
import 'widgets/onboarding_page_indicator.dart';
import 'widgets/onboarding_slide.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OnboardingCubit(),
      child: const _OnboardingView(),
    );
  }
}

class _OnboardingView extends StatefulWidget {
  const _OnboardingView();

  @override
  State<_OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<_OnboardingView> {
  late final PageController _pageController;

  /// Continuous page position (e.g. 1.4 mid-swipe). Drives the red-fill
  /// animation so the last page fades the white panel out smoothly.
  double _page = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pageController.addListener(_onScroll);
  }

  void _onScroll() {
    setState(() => _page = _pageController.page ?? 0);
  }

  @override
  void dispose() {
    _pageController.removeListener(_onScroll);
    _pageController.dispose();
    super.dispose();
  }

  void _goToLogin() => context.go('/login');

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final slides = [
      OnboardingSlideData(
        title: l10n.onboardingTitle1,
        body: l10n.onboardingBody1,
      ),
      OnboardingSlideData(
        title: l10n.onboardingTitle2,
        body: l10n.onboardingBody2,
      ),
      OnboardingSlideData(
        title: l10n.onboardingTitle3,
        body: l10n.onboardingBody3,
      ),
    ];

    final lastIndex = slides.length - 1;
    // 0 on the content steps, 1 when fully on the last (all-red) step.
    final redProgress = (_page - (lastIndex - 1)).clamp(0.0, 1.0);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: BlocListener<OnboardingCubit, OnboardingState>(
        listenWhen: (prev, curr) => prev.currentPage != curr.currentPage,
        listener: (context, state) {
          _pageController.animateToPage(
            state.currentPage,
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOut,
          );
        },
        child: Scaffold(
          // Full-bleed brand red behind everything; the white lower panel sits
          // on top and shrinks away as we approach the last step.
          backgroundColor: AppColors.brandPink,
          body: Stack(
            children: [
              const Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(gradient: AppColors.brandGradient),
                ),
              ),
              // White lower panel with a convex (dome) top edge, fading out on
              // the final step.
              Positioned.fill(
                child: _WhitePanel(redProgress: redProgress),
              ),
              SafeArea(
                child: Column(
                  children: [
                    _TopBar(onSkip: _goToLogin),
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        onPageChanged: (index) =>
                            context.read<OnboardingCubit>().setPage(index),
                        itemCount: slides.length,
                        itemBuilder: (context, index) {
                          return _SlideContent(
                            data: slides[index],
                            onRed: index == lastIndex,
                          );
                        },
                      ),
                    ),
                    BlocBuilder<OnboardingCubit, OnboardingState>(
                      builder: (context, state) {
                        return _BottomNav(
                          state: state,
                          slideCount: slides.length,
                          startLabel: l10n.onboardingStart,
                        );
                      },
                    ),
                    const SizedBox(height: AppSpacing.spaceLg),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The white dome panel that covers the lower ~55% of the screen on the content
/// steps and slides down out of view (revealing full red) on the last step.
class _WhitePanel extends StatelessWidget {
  const _WhitePanel({required this.redProgress});

  /// 0 = panel fully in place, 1 = panel gone (all red).
  final double redProgress;

  @override
  Widget build(BuildContext context) {
    // The panel occupies the bottom ~58% of the screen on the content steps and
    // shrinks to nothing on the last (all-red) step.
    final heightFactor = (0.58 * (1 - redProgress)).clamp(0.0, 0.58);

    return Align(
      alignment: Alignment.bottomCenter,
      child: FractionallySizedBox(
        widthFactor: 1,
        heightFactor: heightFactor,
        child: Opacity(
          opacity: (1 - redProgress).clamp(0.0, 1.0),
          child: ClipPath(
            clipper: const OnboardingDomeClipper(),
            child: Container(color: AppColors.surface),
          ),
        ),
      ),
    );
  }
}

class _SlideContent extends StatelessWidget {
  const _SlideContent({required this.data, required this.onRed});

  final OnboardingSlideData data;
  final bool onRed;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 3,
          child: Center(
            child: Image.asset(
              'assets/zen.png',
              height: 200,
              fit: BoxFit.contain,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Align(
            alignment: Alignment.topCenter,
            child: OnboardingSlideText(data: data, onRed: onRed),
          ),
        ),
      ],
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onSkip});

  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spaceSm),
      child: Align(
        alignment: Alignment.centerRight,
        child: TextButton(
          onPressed: onSkip,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.neutralWhite,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            l10n.onboardingSkip,
            style: const TextStyle(
              color: AppColors.neutralWhite,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({
    required this.state,
    required this.slideCount,
    required this.startLabel,
  });

  final OnboardingState state;
  final int slideCount;
  final String startLabel;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<OnboardingCubit>();
    final isLast = state.isLastPage;
    final isFirst = state.currentPage == 0;

    // Left slot: nothing on the first step, back arrow otherwise.
    final Widget leftSlot = isFirst
        ? const SizedBox(width: 36, height: 36)
        : OnboardingArrowButton(
            icon: Icons.arrow_back_ios_new,
            light: isLast,
            onPressed: cubit.previousPage,
          );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenGutter),
      child: Row(
        children: [
          leftSlot,
          Expanded(
            child: isLast
                ? const SizedBox.shrink()
                : Center(
                    child: OnboardingPageIndicator(
                      itemCount: slideCount,
                      currentPage: state.currentPage,
                      color: AppColors.accent,
                    ),
                  ),
          ),
          if (isLast)
            IntrinsicWidth(
              child: OnboardingCtaButton(
                label: startLabel,
                onPressed: () => context.go('/login'),
              ),
            )
          else
            OnboardingArrowButton(
              icon: Icons.arrow_forward_ios,
              onPressed: cubit.nextPage,
            ),
        ],
      ),
    );
  }
}
