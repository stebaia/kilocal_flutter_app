import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:toastification/toastification.dart';

import '../../../app/di.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/arc_clipper.dart';
import '../../../l10n/app_localizations.dart';
import 'cubit/login_cubit.dart';
import 'widgets/login_form_card.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<LoginCubit>(),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatelessWidget {
  const _LoginView();

  String _mapLoginError(AppLocalizations l10n, LoginError error) {
    switch (error) {
      case LoginError.missingFields:
        return l10n.loginErrorMissingFields;
      case LoginError.invalidCredentials:
        return l10n.loginErrorUnauthorized;
      case LoginError.badRequest:
        return l10n.loginErrorBadRequest;
      case LoginError.network:
        return l10n.loginErrorNetwork;
      case LoginError.server:
        return l10n.loginErrorServer;
      case LoginError.unknown:
        return l10n.loginErrorGeneric;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // When the soft keyboard is open the viewport shrinks and the arc-clipped
    // bottom bar rides up over the last input. Hide it while typing; it comes
    // back as soon as the keyboard is dismissed.
    final isKeyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocListener<LoginCubit, LoginState>(
        listenWhen: (prev, curr) =>
            prev.status != curr.status || prev.error != curr.error,
        listener: (context, state) {
          if (state.status == LoginStatus.success) {
            context.go(state.route ?? '/home');
          } else if (state.error != null) {
            toastification.show(
              context: context,
              type: ToastificationType.error,
              style: ToastificationStyle.flat,
              autoCloseDuration: const Duration(seconds: 5),
              title: Text(l10n.errorTitle),
              description: Text(_mapLoginError(l10n, state.error!)),
              alignment: Alignment.topCenter,
            );
          }
        },
        child: GestureDetector(
          // Tapping outside the text fields dismisses the keyboard.
          onTap: () => FocusScope.of(context).unfocus(),
          child: SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.screenGutter,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: AppSpacing.spaceXl),
                        Text(
                          l10n.loginTitle,
                          style: AppTypography.textTheme.headlineMedium
                              ?.copyWith(
                                color: AppColors.textPrimary,
                                fontSize: 32,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: AppSpacing.spaceSm),
                        Text(
                          l10n.loginSubtitle,
                          style: AppTypography.textTheme.bodyLarge?.copyWith(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.spaceXl),
                        const LoginFormCard(),
                        const SizedBox(height: AppSpacing.spaceXl),
                        _ForgotPasswordRow(),
                        const SizedBox(height: AppSpacing.spaceXl),
                      ],
                    ),
                  ),
                ),
                if (!isKeyboardOpen) _LoginBottomBar(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ForgotPasswordRow extends StatefulWidget {
  @override
  State<_ForgotPasswordRow> createState() => _ForgotPasswordRowState();
}

class _ForgotPasswordRowState extends State<_ForgotPasswordRow> {
  late final TapGestureRecognizer _recognizer;

  @override
  void initState() {
    super.initState();
    _recognizer = TapGestureRecognizer()
      ..onTap = () => context.go('/forgot-password');
  }

  @override
  void dispose() {
    _recognizer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return RichText(
      text: TextSpan(
        style: AppTypography.textTheme.bodyMedium?.copyWith(
          color: AppColors.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        children: [
          TextSpan(text: '${l10n.loginForgotPrompt} '),
          TextSpan(
            text: l10n.loginForgotLink,
            style: const TextStyle(
              color: AppColors.accent,
              decoration: TextDecoration.underline,
            ),
            recognizer: _recognizer,
          ),
        ],
      ),
    );
  }
}

class _LoginBottomBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // The accent banner bleeds to the screen edge (the parent SafeArea has
    // bottom: false), so add the system bottom inset here to keep the sign-up
    // row clear of the Android navigation bar.
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;

    return ClipPath(
      clipper: const ArcClipper(),
      child: Container(
        color: AppColors.accent,
        padding: EdgeInsets.only(
          top: 70,
          left: AppSpacing.screenGutter,
          right: AppSpacing.screenGutter,
          bottom: 32 + bottomInset,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              height: 56,
              child: BlocBuilder<LoginCubit, LoginState>(
                buildWhen: (prev, curr) => prev.status != curr.status,
                builder: (context, state) {
                  final isSubmitting = state.status == LoginStatus.submitting;
                  return ElevatedButton(
                    onPressed: isSubmitting
                        ? null
                        : () => context.read<LoginCubit>().login(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.surface,
                      foregroundColor: AppColors.accent,
                      disabledBackgroundColor: AppColors.surface,
                      disabledForegroundColor: AppColors.accent,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.spaceMd,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.loginButton,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.accent,
                                  ),
                                ),
                              )
                            : Container(
                                width: 20,
                                height: 20,
                                decoration: const BoxDecoration(
                                  color: AppColors.accent,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.arrow_forward_ios,
                                  color: AppColors.surface,
                                  size: 12,
                                ),
                              ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.spaceLg),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  l10n.loginNoAccount,
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    color: AppColors.surface,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                TextButton(
                  onPressed: () => context.go('/signup'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.surface,
                    padding: EdgeInsets.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    l10n.loginSignUp,
                    style: const TextStyle(
                      decoration: TextDecoration.underline,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
