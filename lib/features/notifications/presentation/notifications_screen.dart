import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kilocal_flutter_app/l10n/app_localizations.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/mock_data_factory.dart';
import '../../../core/widgets/localized_bloc_loader.dart';
import 'cubit/notifications_cubit.dart';
import 'widgets/notification_list_item.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NotificationsCubit(),
      child: LocalizedBlocLoader<NotificationsCubit, NotificationsState>(
        load: (context, cubit) {
          final l10n = AppLocalizations.of(context)!;
          cubit.loadWithData(MockDataFactory.notifications(l10n));
        },
        child: const _NotificationsView(),
      ),
    );
  }
}

class _NotificationsView extends StatelessWidget {
  const _NotificationsView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.notificationsTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: show filter bottom sheet
            },
          ),
        ],
      ),
      body: BlocBuilder<NotificationsCubit, NotificationsState>(
        builder: (context, state) {
          if (state.status == NotificationsStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          final visible = state.items.where((i) => !i.archived).toList();

          if (visible.isEmpty) {
            return Center(
              child: Text(AppLocalizations.of(context)!.notificationsEmpty),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenGutter,
              vertical: AppSpacing.spaceMd,
            ),
            itemCount: visible.length,
            itemBuilder: (context, index) {
              final item = visible[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.spaceSm),
                child: NotificationListItem(item: item),
              );
            },
          );
        },
      ),
    );
  }
}
