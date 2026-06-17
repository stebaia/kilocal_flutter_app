import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kilocal_flutter_app/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/brand_gradient_background.dart';
import 'cubit/onboarding_cubit.dart';
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

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

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

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: BlocListener<OnboardingCubit, OnboardingState>(
        listenWhen: (prev, curr) => prev.currentPage != curr.currentPage,
        listener: (context, state) {
          _pageController.animateToPage(
            state.currentPage,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        child: BrandGradientBackground(
          showTopGlow: true,
          child: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: AppSpacing.spaceXl),
                const FlutterLogo(size: 200),
                const SizedBox(height: AppSpacing.spaceLg),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) =>
                        context.read<OnboardingCubit>().setPage(index),
                    itemCount: slides.length,
                    itemBuilder: (context, index) {
                      return OnboardingSlide(data: slides[index]);
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.spaceLg),
                BlocBuilder<OnboardingCubit, OnboardingState>(
                  builder: (context, state) {
                    return OnboardingPageIndicator(
                      itemCount: slides.length,
                      currentPage: state.currentPage,
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.spaceLg),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenGutter,
                  ),
                  child: BlocBuilder<OnboardingCubit, OnboardingState>(
                    builder: (context, state) {
                      return OnboardingCtaButton(
                        label: state.isLastPage
                            ? l10n.onboardingStart
                            : l10n.onboardingNext,
                        onPressed: () {
                          if (state.isLastPage) {
                            context.go('/login');
                          } else {
                            context.read<OnboardingCubit>().nextPage();
                          }
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.spaceXl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
