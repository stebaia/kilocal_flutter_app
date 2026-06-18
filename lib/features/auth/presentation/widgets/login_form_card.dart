import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../l10n/app_localizations.dart';
import '../cubit/login_cubit.dart';

class LoginFormCard extends StatelessWidget {
  const LoginFormCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<LoginCubit, LoginState>(
      builder: (context, state) {
        return Column(
          children: [
            AppTextField(
              hint: l10n.registerEmail,
              onChanged: context.read<LoginCubit>().emailChanged,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: AppSpacing.spaceMd),
            AppTextField(
              hint: l10n.loginPassword,
              onChanged: context.read<LoginCubit>().passwordChanged,
              obscure: state.obscurePassword,
              toggleObscure: context
                  .read<LoginCubit>()
                  .togglePasswordVisibility,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => context.read<LoginCubit>().login(),
            ),
          ],
        );
      },
    );
  }
}
