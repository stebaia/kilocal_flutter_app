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
import 'cubit/register_cubit.dart';
import 'widgets/register_form_card.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<RegisterCubit>(),
      child: const _RegisterView(),
    );
  }
}

class _RegisterView extends StatelessWidget {
  const _RegisterView();

  String _mapRegisterError(AppLocalizations l10n, RegisterError error) {
    switch (error) {
      case RegisterError.missingFields:
        return l10n.registerErrorMissingFields;
      case RegisterError.passwordMismatch:
        return l10n.registerErrorPasswordMismatch;
      case RegisterError.conflict:
        return l10n.registerErrorConflict;
      case RegisterError.badRequest:
        return l10n.registerErrorBadRequest;
      case RegisterError.network:
        return l10n.registerErrorNetwork;
      case RegisterError.server:
        return l10n.registerErrorServer;
      case RegisterError.unknown:
        return l10n.registerErrorGeneric;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocListener<RegisterCubit, RegisterState>(
        listenWhen: (prev, curr) =>
            prev.status != curr.status || prev.error != curr.error,
        listener: (context, state) {
          if (state.status == RegisterStatus.success) {
            toastification.show(
              context: context,
              type: ToastificationType.success,
              style: ToastificationStyle.flat,
              autoCloseDuration: const Duration(seconds: 4),
              title: Text(l10n.registerSuccessTitle),
              description: Text(l10n.registerSuccessDescription),
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
              description: Text(_mapRegisterError(l10n, state.error!)),
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
                        l10n.registerTitle,
                        style: AppTypography.textTheme.headlineMedium?.copyWith(
                          color: AppColors.textPrimary,

                          fontSize: 32,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.spaceSm),
                      Text(
                        l10n.registerSubtitle,
                        style: AppTypography.textTheme.bodyLarge?.copyWith(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.spaceXl),
                      const RegisterFormCard(),
                      const SizedBox(height: AppSpacing.spaceXl),
                      _TermsRow(),
                      const SizedBox(height: AppSpacing.spaceXl),
                    ],
                  ),
                ),
              ),
              _RegisterBottomBar(),
            ],
          ),
        ),
      ),
    );
  }
}

class _TermsRow extends StatelessWidget {
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
          TextSpan(text: '${l10n.registerTermsPrefix} '),
          TextSpan(
            text: l10n.registerTermsLink,
            style: const TextStyle(
              color: AppColors.accent,
              decoration: TextDecoration.underline,
            ),
          ),
        ],
      ),
    );
  }
}

class _RegisterBottomBar extends StatelessWidget {
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
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => context.read<RegisterCubit>().register(),
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.registerButton,
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
            ),
            const SizedBox(height: AppSpacing.spaceLg),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  l10n.registerBottomPrompt,
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    color: AppColors.surface,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 4),
                TextButton(
                  onPressed: () => context.go('/login'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.surface,
                    padding: EdgeInsets.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    l10n.registerBottomLink,
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
