import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app/di.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_header.dart';
import '../../../l10n/app_localizations.dart';
import '../../user/domain/app_user.dart';
import '../../user/domain/user_details.dart';
import '../../user/presentation/cubit/user_cubit.dart';
import '../domain/entities/cms_form.dart';
import '../domain/entities/profile_page.dart';
import 'cubit/avatar_upload_cubit.dart';
import 'cubit/profile_page_cubit.dart';
import 'cubit/profile_update_cubit.dart';
import 'widgets/cms_form_view.dart';
import 'widgets/profile_avatar_editor.dart';

/// Single profile form screen (`dashboard-profile`): renders one tab of the CMS
/// `private_sec_profile` block identified by [tabId] (e.g. personal data, food
/// preferences or account settings) as a standalone form, pre-filled from the
/// session and submitted via `PATCH /profile`. See [[profile-cms-pages-schema]].
class ProfileFormScreen extends StatelessWidget {
  const ProfileFormScreen({super.key, required this.tabId, this.fallbackTitle});

  final String tabId;

  /// Title shown while the page loads, before the CMS tab title is known.
  final String? fallbackTitle;

  static const _pageInternalName = 'dashboard-profile';

  /// CMS tab id of the "My account" tab, which hosts the avatar editor.
  static const _accountTabId = '4';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColors.surface,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => getIt<ProfilePageCubit>()..load(_pageInternalName),
          ),
          BlocProvider(create: (_) => getIt<ProfileUpdateCubit>()),
          if (tabId == _accountTabId)
            BlocProvider(create: (_) => getIt<AvatarUploadCubit>()),
        ],
        child: BlocBuilder<ProfilePageCubit, ProfilePageState>(
          builder: (context, state) {
            final tab = _tabFor(state.page);

            return Scaffold(
              backgroundColor: AppColors.background,
              // top: false — AppHeader insets the status bar; SafeArea guards
              // only the bottom against the Android system navigation bar.
              body: SafeArea(
                top: false,
                child: Column(
                  children: [
                    AppHeader(
                      title: tab?.title ?? fallbackTitle ?? '',
                      showBack: true,
                    ),
                    Expanded(child: _body(context, state, tab, l10n)),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _body(
    BuildContext context,
    ProfilePageState state,
    ProfileFormTab? tab,
    AppLocalizations l10n,
  ) {
    if (state.status == ProfilePageStatus.loading ||
        state.status == ProfilePageStatus.initial) {
      return const Center(child: CircularProgressIndicator());
    }
    final form = tab?.form;
    if (form == null || form.fields.isEmpty) {
      return _Message(text: l10n.errorGeneric);
    }
    return _FormBody(form: form, showAvatarEditor: tabId == _accountTabId);
  }

  ProfileFormTab? _tabFor(ProfilePage? page) {
    final section = page?.sections
        .whereType<ProfilePageFormTabsSection>()
        .firstOrNull;
    return section?.tabs.where((t) => t.id == tabId).firstOrNull;
  }
}

class _FormBody extends StatelessWidget {
  const _FormBody({required this.form, this.showAvatarEditor = false});

  final CmsForm form;

  /// When true, renders the tappable avatar editor above the form (account tab).
  final bool showAvatarEditor;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocListener<ProfileUpdateCubit, ProfileUpdateState>(
      listenWhen: (prev, curr) => prev.status != curr.status,
      listener: (context, state) {
        final messenger = ScaffoldMessenger.of(context);
        if (state.status == ProfileUpdateStatus.success) {
          messenger.showSnackBar(SnackBar(content: Text(l10n.profileSaved)));
          context.read<ProfileUpdateCubit>().reset();
        } else if (state.status == ProfileUpdateStatus.error) {
          messenger.showSnackBar(SnackBar(content: Text(l10n.errorGeneric)));
          context.read<ProfileUpdateCubit>().reset();
        }
      },
      child: BlocBuilder<UserCubit, UserState>(
        bloc: getIt<UserCubit>(),
        builder: (context, userState) {
          final initialValues = _initialValues(
            form,
            userState.user,
            userState.details,
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.screenGutter),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (showAvatarEditor) const ProfileAvatarEditor(),
                BlocBuilder<ProfileUpdateCubit, ProfileUpdateState>(
                  builder: (context, updateState) {
                    return CmsFormView(
                      form: form,
                      initialValues: initialValues,
                      submitting: updateState.isSubmitting,
                      onSubmit: (values) => context
                          .read<ProfileUpdateCubit>()
                          .submit(_toProfileBody(values)),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Pre-fills each form field from the session, resolving values across
  /// `directus_users` (name/email), `user_details` (gender, food prefs) and
  /// `user_addresses` (phone, address).
  Map<String, dynamic> _initialValues(
    CmsForm form,
    AppUser? user,
    UserDetails? details,
  ) {
    final address = details?.addresses?.firstOrNull;
    final values = <String, dynamic>{};
    for (final field in form.fields) {
      values[field.key] = switch (field.key) {
        'first_name' => user?.firstName,
        'last_name' => user?.lastName,
        'email' => user?.email,
        'gender' => details?.gender,
        'phone' => address?.phone,
        'province' => address?.province,
        'city' => address?.city,
        'zip_code' || 'zip' => address?.zip,
        'address' => address?.address,
        'intolleranze' => details?.intolleranze,
        'allergie' => details?.allergie,
        'dieta' => details?.dieta,
        _ => null,
      };
    }
    return values;
  }

  /// Maps rendered form values to the `PATCH /profile` body, translating the CMS
  /// key `zip_code` to the API field `zip` ([[profilo]]).
  Map<String, dynamic> _toProfileBody(Map<String, dynamic> values) {
    final body = <String, dynamic>{};
    values.forEach((key, value) {
      final apiKey = key == 'zip_code' ? 'zip' : key;
      body[apiKey] = value;
    });
    return body;
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.spaceLg),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: AppTypography.textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
