import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kilocal_flutter_app/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/brand_gradient_background.dart';
import 'cubit/onboarding_cubit.dart';

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
      _SlideData(title: l10n.onboardingTitle1, body: l10n.onboardingBody1),
      _SlideData(title: l10n.onboardingTitle2, body: l10n.onboardingBody2),
      _SlideData(title: l10n.onboardingTitle3, body: l10n.onboardingBody3),
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
                    onPageChanged: (index) => context.read<OnboardingCubit>().setPage(index),
                    itemCount: slides.length,
                    itemBuilder: (context, index) {
                      final slide = slides[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spaceLg),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              slide.title,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                color: AppColors.neutralWhite,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.spaceMd),
                            Text(
                              slide.body,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 16,
                                color: AppColors.neutralWhite,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.spaceLg),
                BlocBuilder<OnboardingCubit, OnboardingState>(
                  builder: (context, state) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(slides.length, (index) {
                        final isActive = index == state.currentPage;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: isActive ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: isActive
                                ? AppColors.neutralWhite
                                : AppColors.neutralWhite.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                          ),
                        );
                      }),
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.spaceLg),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenGutter),
                  child: BlocBuilder<OnboardingCubit, OnboardingState>(
                    builder: (context, state) {
                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (state.isLastPage) {
                              context.go('/login');
                            } else {
                              context.read<OnboardingCubit>().nextPage();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.neutralWhite,
                            foregroundColor: AppColors.brandPink,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadius.pill),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: AppSpacing.spaceMd),
                          ),
                          child: Text(
                            state.isLastPage ? l10n.onboardingStart : l10n.onboardingNext,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ),
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

class _SlideData {
  const _SlideData({required this.title, required this.body});

  final String title;
  final String body;
}