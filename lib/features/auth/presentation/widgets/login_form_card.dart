import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kilocal_flutter_app/l10n/app_localizations.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../cubit/login_cubit.dart';
import 'login_submit_button.dart';

class LoginFormCard extends StatelessWidget {
  const LoginFormCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AppCard(
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
          const LoginSubmitButton(),
        ],
      ),
    );
  }
}
