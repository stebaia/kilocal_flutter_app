import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kilocal_flutter_app/l10n/app_localizations.dart';

import '../cubit/login_cubit.dart';

class LoginSubmitButton extends StatelessWidget {
  const LoginSubmitButton({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SizedBox(
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
    );
  }
}
