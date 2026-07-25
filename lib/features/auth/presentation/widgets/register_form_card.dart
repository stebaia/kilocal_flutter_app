import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../l10n/app_localizations.dart';
import '../cubit/register_cubit.dart';

class RegisterFormCard extends StatelessWidget {
  const RegisterFormCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<RegisterCubit, RegisterState>(
      builder: (context, state) {
        return Column(
          children: [
            AppTextField(
              hint: l10n.registerFirstName,
              onChanged: context.read<RegisterCubit>().firstNameChanged,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: AppSpacing.spaceLg),
            AppTextField(
              hint: l10n.registerLastName,
              onChanged: context.read<RegisterCubit>().lastNameChanged,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: AppSpacing.spaceLg),
            AppTextField(
              hint: l10n.registerEmail,
              onChanged: context.read<RegisterCubit>().emailChanged,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: AppSpacing.spaceLg),
            AppTextField(
              hint: l10n.registerPassword,
              onChanged: context.read<RegisterCubit>().passwordChanged,
              obscure: state.obscurePassword,
              toggleObscure: context
                  .read<RegisterCubit>()
                  .togglePasswordVisibility,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: AppSpacing.spaceLg),
            AppTextField(
              hint: l10n.registerPasswordConfirm,
              onChanged: context.read<RegisterCubit>().passwordConfirmChanged,
              obscure: state.obscurePasswordConfirm,
              toggleObscure: context
                  .read<RegisterCubit>()
                  .togglePasswordConfirmVisibility,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => context.read<RegisterCubit>().register(),
            ),
          ],
        );
      },
    );
  }
}
