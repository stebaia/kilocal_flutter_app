import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/brand_gradient_background.dart';
import 'cubit/splash_cubit.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SplashCubit()..initialize(),
      child: const _SplashView(),
    );
  }
}

class _SplashView extends StatelessWidget {
  const _SplashView();

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: BlocListener<SplashCubit, SplashState>(
        listenWhen: (prev, curr) => prev.status != curr.status,
        listener: (context, state) {
          if (state.status == SplashStatus.ready && state.route != null) {
            context.go(state.route!);
          }
        },
        child: const BrandGradientBackground(
          showTopGlow: true,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Placeholder for the 3D meditating figure asset.
                // Replace with Image.asset('assets/images/splash_figure.png') once available.
                FlutterLogo(size: 180),
                SizedBox(height: 24),
                CircularProgressIndicator(color: AppColors.neutralWhite),
              ],
            ),
          ),
        ),
      ),
    );
  }
}