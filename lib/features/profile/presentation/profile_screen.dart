import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:kilocal_flutter_app/app/di.dart';
import 'package:kilocal_flutter_app/features/auth/domain/auth_repository.dart';
import 'package:kilocal_flutter_app/l10n/app_localizations.dart';

import '../../../core/network/token_store.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/hex_color.dart';
import '../../user/presentation/cubit/user_cubit.dart';
import 'cubit/avatar_upload_cubit.dart';
import 'widgets/avatar_picker.dart';
import 'widgets/profile_group_card.dart';
import 'widgets/profile_list_tile.dart';
import 'widgets/profile_section_label.dart';
import 'widgets/profile_type_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  /// Support inbox for "Contatta l'assistenza"; opens the device's mail app
  /// via a `mailto:` link rather than an in-app form.
  static const _supportEmail = 'info@kilocalprogram.it';

  Future<void> _contactSupport(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final uri = Uri(scheme: 'mailto', path: _supportEmail);
    // Simulators/emulators commonly have no mail app configured, which is not
    // the generic error case — tell the user how to reach support instead of
    // a bare "something went wrong, try again" that implies retrying helps.
    final launched = await canLaunchUrl(uri) && await launchUrl(uri);
    if (!launched && context.mounted) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.profileContactSupportNoMailApp)),
      );
    }
  }

  /// Confirms the intent to log out before actually doing so, so a stray tap
  /// on "Esci" doesn't sign the user out immediately.
  Future<void> _confirmLogout(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.profileLogoutConfirmTitle),
        content: Text(l10n.profileLogoutConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.profileLogoutConfirmCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              l10n.profileLogoutConfirmAction,
              style: const TextStyle(color: AppColors.accent),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await _performLogout(context);
    }
  }

  Future<void> _performLogout(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);

    try {
      await getIt<AuthRepository>().logout();
      if (context.mounted) {
        context.go('/login');
      }
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.errorGeneric)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final statusBarHeight = MediaQuery.paddingOf(context).top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColors.surface,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        // top: false — the status-bar filler below handles the top inset;
        // SafeArea guards only the bottom against the Android system nav bar.
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              // White filler behind the status bar.
              Container(color: AppColors.surface, height: statusBarHeight),
              // White header with title + avatar.
              Container(
                width: double.infinity,
                color: AppColors.surface,
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenGutter,
                  AppSpacing.spaceXs,
                  AppSpacing.screenGutter,
                  AppSpacing.spaceLg,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.profileTitle,
                        style: AppTypography.textTheme.headlineLarge,
                      ),
                    ),
                    const _ProfileAvatar(),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenGutter,
                    AppSpacing.spaceLg,
                    AppSpacing.screenGutter,
                    AppSpacing.spaceXl,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- Il mio Tipo ---
                      ProfileSectionLabel(text: l10n.profileMyTypeSection),
                      const SizedBox(height: AppSpacing.spaceSm),
                      BlocBuilder<UserCubit, UserState>(
                        bloc: getIt<UserCubit>(),
                        builder: (context, state) {
                          final biotype = state.details?.biotype;
                          final typeColor = colorFromHex(biotype?.mainColor);
                          return ProfileTypeCard(
                            label: biotype?.label ?? l10n.profileMyTypeValue,
                            iconUrl: biotype?.iconUrl,
                            cardColor: typeColor,
                            iconColor: typeColor,
                            onTap: () => context.push('/profile/type'),
                          );
                        },
                      ),
                      const SizedBox(height: AppSpacing.spaceLg),

                      // --- Nome categoria sezioni ---
                      ProfileSectionLabel(text: l10n.profileCategorySection),
                      const SizedBox(height: AppSpacing.spaceSm),
                      ProfileGroupCard(
                        tiles: [
                          ProfileListTile(
                            icon: Icons.description_outlined,
                            title: l10n.profilePersonalData,
                            onTap: () => context.push('/profile/personal-data'),
                          ),
                          ProfileListTile(
                            icon: Icons.description_outlined,
                            title: l10n.profileMyAccount,
                            onTap: () => context.push('/profile/account'),
                          ),
                          ProfileListTile(
                            icon: Icons.description_outlined,
                            title: l10n.profileFoodPreferences,
                            onTap: () =>
                                context.push('/profile/food-preferences'),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.spaceLg),

                      // --- Notifiche ---
                      // Commented out rather than removed: "Notifiche push"
                      // doesn't lead anywhere yet (no settings screen behind
                      // it), so the whole section is hidden until there's
                      // something for it to open.
                      // ProfileSectionLabel(
                      //   text: l10n.profileNotificationsSection,
                      // ),
                      // const SizedBox(height: AppSpacing.spaceSm),
                      // ProfileGroupCard(
                      //   tiles: [
                      //     ProfileListTile(
                      //       icon: Icons.description_outlined,
                      //       title: l10n.profilePushNotifications,
                      //       subtitle: l10n.profilePushNotificationsStatus,
                      //       onTap: () {},
                      //     ),
                      //   ],
                      // ),
                      // const SizedBox(height: AppSpacing.spaceLg),

                      // --- Assistenza ---
                      ProfileSectionLabel(text: l10n.profileSupportSection),
                      const SizedBox(height: AppSpacing.spaceSm),
                      ProfileGroupCard(
                        tiles: [
                          ProfileListTile(
                            icon: Icons.description_outlined,
                            title: l10n.profileContactSupport,
                            onTap: () => _contactSupport(context),
                          ),
                          ProfileListTile(
                            icon: Icons.logout,
                            title: l10n.profileLogout,
                            onTap: () => _confirmLogout(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.spaceLg),

                      // --- Versione app (non cliccabile) ---
                      ProfileSectionLabel(text: l10n.profileAppVersionSection),
                      const SizedBox(height: AppSpacing.spaceSm),
                      const ProfileGroupCard(tiles: [_ProfileAppVersionTile()]),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Non-clickable profile row showing the installed app version, read from
/// [PackageInfo]. Mirrors [ProfileListTile]'s layout (leading outlined icon +
/// title/subtitle) but has no trailing chevron and no tap handler.
class _ProfileAppVersionTile extends StatelessWidget {
  const _ProfileAppVersionTile();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.spaceSm),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline,
            size: 24,
            color: AppColors.textPrimary,
          ),
          const SizedBox(width: AppSpacing.spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.profileAppVersion,
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                FutureBuilder<PackageInfo>(
                  future: PackageInfo.fromPlatform(),
                  builder: (context, snapshot) {
                    final info = snapshot.data;
                    final version = info == null
                        ? '—'
                        : '${info.version} (${info.buildNumber})';
                    return Text(
                      l10n.profileAppVersionValue(version),
                      style: AppTypography.textTheme.labelMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Circular avatar shown in the profile header (top-right). Shows the user's
/// profile photo (`directus_users.avatar`) when available, otherwise a person
/// icon placeholder. Tapping opens the same camera/gallery picker as the "My
/// account" screen, so the header photo can be changed from here directly.
class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AvatarUploadCubit>(),
      child: BlocListener<AvatarUploadCubit, AvatarUploadState>(
        listenWhen: (prev, curr) => prev.status != curr.status,
        listener: handleAvatarUploadFeedback,
        child: BlocBuilder<AvatarUploadCubit, AvatarUploadState>(
          builder: (context, uploadState) {
            return GestureDetector(
              onTap: uploadState.isUploading
                  ? null
                  : () => showAvatarPicker(context),
              child: BlocBuilder<UserCubit, UserState>(
                bloc: getIt<UserCubit>(),
                builder: (context, state) {
                  final avatarUrl = state.user?.avatarUrl;
                  return Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.accentSoft,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: uploadState.isUploading
                        ? const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : avatarUrl == null
                        ? const _AvatarPlaceholder()
                        : _AvatarImage(url: avatarUrl),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Default person icon shown when there is no avatar or it fails to load.
class _AvatarPlaceholder extends StatelessWidget {
  const _AvatarPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Icon(Icons.person, color: AppColors.accent, size: 28);
  }
}

/// Loads the avatar image from the CMS with the Bearer token (Directus serves
/// user avatars only to authenticated requests), falling back to the person
/// placeholder while loading or on error.
class _AvatarImage extends StatelessWidget {
  const _AvatarImage({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: getIt<TokenStore>().accessToken,
      builder: (context, snapshot) {
        final token = snapshot.data;
        if (token == null) return const _AvatarPlaceholder();
        return Image.network(
          url,
          width: 44,
          height: 44,
          fit: BoxFit.cover,
          headers: {'Authorization': 'Bearer $token'},
          errorBuilder: (context, error, stackTrace) =>
              const _AvatarPlaceholder(),
          loadingBuilder: (context, child, progress) =>
              progress == null ? child : const _AvatarPlaceholder(),
        );
      },
    );
  }
}
