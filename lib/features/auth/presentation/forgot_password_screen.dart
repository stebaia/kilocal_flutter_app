import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:toastification/toastification.dart';

import '../../../app/di.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/arc_clipper.dart';
import '../../../l10n/app_localizations.dart';
import 'cubit/forgot_password_cubit.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ForgotPasswordCubit>(),
      child: const _ForgotPasswordView(),
    );
  }
}

class _ForgotPasswordView extends StatelessWidget {
  const _ForgotPasswordView();

  String _mapError(AppLocalizations l10n, ForgotPasswordError error) {
    switch (error) {
      case ForgotPasswordError.missingEmail:
        return l10n.forgotPasswordErrorMissingEmail;
      case ForgotPasswordError.badRequest:
        return l10n.forgotPasswordErrorBadRequest;
      case ForgotPasswordError.network:
        return l10n.forgotPasswordErrorNetwork;
      case ForgotPasswordError.server:
        return l10n.forgotPasswordErrorServer;
      case ForgotPasswordError.unknown:
        return l10n.forgotPasswordErrorGeneric;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocListener<ForgotPasswordCubit, ForgotPasswordState>(
        listenWhen: (prev, curr) =>
            prev.status != curr.status || prev.error != curr.error,
        listener: (context, state) {
          if (state.status == ForgotPasswordStatus.success) {
            toastification.show(
              context: context,
              type: ToastificationType.success,
              style: ToastificationStyle.flat,
              autoCloseDuration: const Duration(seconds: 5),
              title: Text(l10n.forgotPasswordSuccessTitle),
              description: Text(l10n.forgotPasswordSuccessDescription),
              alignment: Alignment.topCenter,
            );
            context.go('/login');
          } else if (state.error != null) {
            toastification.show(
              context: context,
              type: ToastificationType.error,
              style: ToastificationStyle.flat,
              autoCloseDuration: const Duration(seconds: 5),
              title: Text(l10n.errorTitle),
              description: Text(_mapError(l10n, state.error!)),
              alignment: Alignment.topCenter,
            );
          }
        },
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
                        l10n.forgotPasswordTitle,
                        style: AppTypography.textTheme.headlineMedium?.copyWith(
                          color: AppColors.textPrimary,
                          fontSize: 32,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.spaceSm),
                      Text(
                        l10n.forgotPasswordSubtitle,
                        style: AppTypography.textTheme.bodyLarge?.copyWith(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.spaceXl),
                      const _ForgotPasswordForm(),
                      const SizedBox(height: AppSpacing.spaceXl),
                    ],
                  ),
                ),
              ),
              _ForgotPasswordBottomBar(),
            ],
          ),
        ),
      ),
    );
  }
}

class _ForgotPasswordForm extends StatelessWidget {
  const _ForgotPasswordForm();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AppTextField(
      hint: l10n.registerEmail,
      onChanged: context.read<ForgotPasswordCubit>().emailChanged,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.done,
      onSubmitted: (_) => context.read<ForgotPasswordCubit>().submit(),
    );
  }
}

class _ForgotPasswordBottomBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ClipPath(
      clipper: const ArcClipper(),
      child: Container(
        color: AppColors.accent,
        padding: const EdgeInsets.only(
          top: 70,
          left: AppSpacing.screenGutter,
          right: AppSpacing.screenGutter,
          bottom: 32,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BlocBuilder<ForgotPasswordCubit, ForgotPasswordState>(
              buildWhen: (prev, curr) => prev.status != curr.status,
              builder: (context, state) {
                final submitting =
                    state.status == ForgotPasswordStatus.submitting;
                return SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: submitting
                        ? null
                        : () => context.read<ForgotPasswordCubit>().submit(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.surface,
                      foregroundColor: AppColors.accent,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.spaceMd,
                      ),
                    ),
                    child: submitting
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: AppColors.accent,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                l10n.forgotPasswordButton,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Container(
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
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.spaceLg),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  l10n.forgotPasswordBackPrompt,
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    color: AppColors.surface,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                TextButton(
                  onPressed: () => context.go('/login'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.surface,
                    padding: EdgeInsets.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    l10n.forgotPasswordBackLink,
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
