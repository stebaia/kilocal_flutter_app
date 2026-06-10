import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kilocal_flutter_app/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_card.dart';
import 'cubit/login_cubit.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginCubit(),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatelessWidget {
  const _LoginView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: BlocListener<LoginCubit, LoginState>(
        listenWhen: (prev, curr) => prev.status != curr.status,
        listener: (context, state) {
          if (state.status == LoginStatus.success) {
            context.go('/home');
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenGutter),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.spaceXl),
                Center(
                  child: Text(
                    l10n.appTitle,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.accent,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.spaceXl),
                Text(l10n.loginTitle, style: AppTypography.textTheme.headlineLarge),
                const SizedBox(height: AppSpacing.spaceLg),
                AppCard(
                  child: Column(
                    children: [
                      TextField(
                        onChanged: (v) => context.read<LoginCubit>().emailChanged(v),
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: l10n.loginEmail,
                          prefixIcon: const Icon(Icons.email_outlined),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.spaceMd),
                      TextField(
                        onChanged: (v) => context.read<LoginCubit>().passwordChanged(v),
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: l10n.loginPassword,
                          prefixIcon: const Icon(Icons.lock_outline),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.spaceSm),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          child: Text(l10n.loginForgotPassword),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.spaceSm),
                      SizedBox(
                        width: double.infinity,
                        child: BlocBuilder<LoginCubit, LoginState>(
                          builder: (context, state) {
                            return ElevatedButton(
                              onPressed: state.status == LoginStatus.submitting
                                  ? null
                                  : () => context.read<LoginCubit>().login(),
                              child: state.status == LoginStatus.submitting
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : Text(l10n.loginButton),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.spaceLg),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(l10n.loginNoAccount, style: AppTypography.textTheme.bodyMedium),
                    TextButton(
                      onPressed: () {},
                      child: Text(l10n.loginSignUp),
                    ),
                  ],
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