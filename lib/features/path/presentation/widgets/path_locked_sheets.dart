import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di.dart';
import '../../../../core/icons/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_bottom_sheet.dart';
import '../../../../l10n/app_localizations.dart';
import '../cubit/program_unlock_cubit.dart';

/// Shows the "Contenuto bloccato" sheet for a restricted user tapping a locked
/// path area. Offers dismiss ("Ho capito") or, if the user already bought the
/// starter kit, continue to the [showProgramUnlockSheet] barcode sheet.
Future<void> showPathLockedSheet(
  BuildContext context, {
  required String areaTitle,
}) async {
  final l10n = AppLocalizations.of(context)!;
  final wantsUnlock = await showAppBrandBottomSheet<bool>(
    context,
    title: l10n.pathLockedTitle,
    child: _LockedInfoBody(),
  );
  if (wantsUnlock == true && context.mounted) {
    await showProgramUnlockSheet(context);
  }
}

/// The "Sblocca il programma" sheet: enter the starter-kit barcode and unlock.
Future<void> showProgramUnlockSheet(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  return showAppBrandBottomSheet<void>(
    context,
    title: l10n.pathUnlockTitle,
    child: BlocProvider(
      create: (_) => getIt<ProgramUnlockCubit>(),
      child: const _UnlockBody(),
    ),
  );
}

/// Dark circular lock badge shown at the top of both sheets.
class _LockBadge extends StatelessWidget {
  const _LockBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: const BoxDecoration(
        color: AppColors.ink,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: const AppIcon(
        AppIcons.lock,
        size: 26,
        color: AppColors.neutralWhite,
      ),
    );
  }
}

class _LockedInfoBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenGutter,
        AppSpacing.spaceLg,
        AppSpacing.screenGutter,
        AppSpacing.spaceMd,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _LockBadge(),
          const SizedBox(height: AppSpacing.spaceLg),
          Text(
            l10n.pathLockedBody,
            textAlign: TextAlign.center,
            style: AppTypography.textTheme.bodyLarge?.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.spaceLg),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: AppSpacing.spaceLg),
          SizedBox(
            height: 45,
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppColors.accent),
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.pathLockedUnderstood,  style: AppTypography.textTheme.bodyMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(height: AppSpacing.spaceSm),
          SizedBox(
            height: 45,
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.accent,
                side: const BorderSide(color: AppColors.accent),
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.pathLockedBoughtKit,),
            ),
          ),
        ],
      ),
    );
  }
}

class _UnlockBody extends StatefulWidget {
  const _UnlockBody();

  @override
  State<_UnlockBody> createState() => _UnlockBodyState();
}

class _UnlockBodyState extends State<_UnlockBody> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    context.read<ProgramUnlockCubit>().submitCode(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocListener<ProgramUnlockCubit, ProgramUnlockState>(
      listenWhen: (prev, curr) => prev.status != curr.status,
      listener: (context, state) {
        if (state.status == ProgramUnlockStatus.unlocked) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.pathUnlockSuccess)),
          );
        }
      },
      child: Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.screenGutter,
          right: AppSpacing.screenGutter,
          top: AppSpacing.spaceLg,
          bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.spaceMd,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _LockBadge(),
            const SizedBox(height: AppSpacing.spaceLg),
            Text(
              l10n.pathUnlockInstructions,
              textAlign: TextAlign.center,
              style: AppTypography.textTheme.bodyLarge?.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.spaceLg),
            const Divider(height: 1, color: AppColors.divider),
            const SizedBox(height: AppSpacing.spaceLg),
            BlocBuilder<ProgramUnlockCubit, ProgramUnlockState>(
              builder: (context, state) {
                final errorText = _errorText(l10n, state.status);
                return Column(
                  children: [
                    TextField(
                      
                      controller: _controller,
                      textCapitalization: TextCapitalization.characters,
                      textInputAction: TextInputAction.done,
                      enabled: !state.isSubmitting,
                      onChanged: (_) {
                        if (state.status != ProgramUnlockStatus.editing) {
                          context.read<ProgramUnlockCubit>().reset();
                        }
                      },
                      onSubmitted: (_) => _submit(),
                      inputFormatters: [
                        UpperCaseTextFormatter(),
                        LengthLimitingTextInputFormatter(10),
                      ],
                      decoration: InputDecoration(
                        
                        hintText: l10n.pathUnlockCodeHint,
                        errorText: errorText,
                        filled: true,
                        fillColor: AppColors.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                          borderSide: const BorderSide(
                            color: AppColors.borderCard,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                          borderSide: const BorderSide(
                            color: AppColors.borderCard,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                          borderSide: const BorderSide(color: AppColors.accent),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.spaceLg,
                          vertical: AppSpacing.spaceMd,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.spaceMd),
                    SizedBox(
                      height: 45,
                      width: double.infinity,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.ink,
                        ),
                        onPressed: state.isSubmitting ? null : _submit,
                        child: state.isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.neutralWhite,
                                ),
                              )
                            : Text(l10n.pathUnlockSubmit),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Maps a terminal error status to the inline error message under the field.
  String? _errorText(AppLocalizations l10n, ProgramUnlockStatus status) {
    switch (status) {
      case ProgramUnlockStatus.invalidCode:
        return l10n.pathUnlockInvalidCode;
      case ProgramUnlockStatus.unlockUnavailable:
        return l10n.pathUnlockUnavailable;
      case ProgramUnlockStatus.error:
        return l10n.errorGeneric;
      case ProgramUnlockStatus.editing:
      case ProgramUnlockStatus.submitting:
      case ProgramUnlockStatus.unlocked:
        return null;
    }
  }
}

/// Forces typed input to upper case so it matches the stored barcodes.
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}
