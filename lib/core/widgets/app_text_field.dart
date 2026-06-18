import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Reusable rounded text field used across auth and form screens.
///
/// Supports an optional password visibility toggle and configurable keyboard
/// and text-input actions.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.hint,
    required this.onChanged,
    this.keyboardType,
    this.obscure = false,
    this.toggleObscure,
    this.textInputAction,
    this.onSubmitted,
  });

  final String hint;
  final ValueChanged<String> onChanged;
  final TextInputType? keyboardType;
  final bool obscure;
  final VoidCallback? toggleObscure;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      keyboardType: keyboardType,
      obscureText: obscure,
      textInputAction: textInputAction,
      onSubmitted: onSubmitted,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.spaceMd,
          vertical: AppSpacing.spaceMd,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.borderCard),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.borderCard),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.accent),
        ),
        suffixIcon: toggleObscure != null
            ? IconButton(
                icon: Icon(
                  obscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.textSecondary,
                ),
                onPressed: toggleObscure,
              )
            : null,
      ),
    );
  }
}
