import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app/di.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../l10n/app_localizations.dart';
import 'cubit/change_password_cubit.dart';

/// "Change password" screen, reached from the "My account" form.
///
/// Asks only for the new password and its confirmation: the API sets the
/// password from the access token alone and cannot verify the current one, so a
/// current-password field would be a client-side check only. See
/// [ChangePasswordCubit].
class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColors.surface,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: BlocProvider(
        create: (_) => getIt<ChangePasswordCubit>(),
        child: Scaffold(
          backgroundColor: AppColors.background,
          // top: false — AppHeader insets the status bar; SafeArea guards only
          // the bottom against the Android system navigation bar.
          body: SafeArea(
            top: false,
            child: Column(
              children: [
                AppHeader(title: l10n.profileChangePassword, showBack: true),
                const Expanded(child: _Body()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocListener<ChangePasswordCubit, ChangePasswordState>(
      listenWhen: (prev, curr) => prev.status != curr.status,
      listener: (context, state) {
        if (state.status == ChangePasswordStatus.success) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.profilePasswordUpdated)));
          context.pop();
        } else if (state.status == ChangePasswordStatus.error) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.profilePasswordError)));
          context.read<ChangePasswordCubit>().reset();
        }
      },
      child: BlocBuilder<ChangePasswordCubit, ChangePasswordState>(
        builder: (context, state) {
          final cubit = context.read<ChangePasswordCubit>();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.screenGutter),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.profileChangePasswordHint,
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.spaceLg),
                AppTextField(
                  hint: l10n.profileNewPassword,
                  obscure: state.obscurePassword,
                  toggleObscure: cubit.toggleObscurePassword,
                  textInputAction: TextInputAction.next,
                  onChanged: cubit.passwordChanged,
                ),
                const SizedBox(height: AppSpacing.spaceMd),
                AppTextField(
                  hint: l10n.profileConfirmPassword,
                  obscure: state.obscureConfirmPassword,
                  toggleObscure: cubit.toggleObscureConfirmPassword,
                  textInputAction: TextInputAction.done,
                  onChanged: cubit.confirmPasswordChanged,
                  onSubmitted: (_) => cubit.submit(),
                ),
                if (state.validation != null) ...[
                  const SizedBox(height: AppSpacing.spaceSm),
                  _ValidationText(validation: state.validation!),
                ],
                const SizedBox(height: AppSpacing.spaceLg),
                ElevatedButton(
                  onPressed: state.canSubmit ? cubit.submit : null,
                  child: state.isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.profileChangePasswordSubmit),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ValidationText extends StatelessWidget {
  const _ValidationText({required this.validation});

  final ChangePasswordValidation validation;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final text = switch (validation) {
      ChangePasswordValidation.tooShort => l10n.profilePasswordTooShort(
        ChangePasswordCubit.minPasswordLength,
      ),
      ChangePasswordValidation.mismatch => l10n.profilePasswordMismatch,
    };

    return Text(
      text,
      style: AppTypography.textTheme.labelMedium?.copyWith(
        color: Theme.of(context).colorScheme.error,
      ),
    );
  }
}
