import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kilocal_flutter_app/core/icons/app_icons.dart';
import 'package:kilocal_flutter_app/core/theme/theme.dart';
import 'package:kilocal_flutter_app/l10n/app_localizations.dart';

import '../../../app/di.dart';
import '../../../core/widgets/filter_bottom_sheet.dart';
import '../domain/entities/notification_item.dart';
import 'cubit/notifications_cubit.dart';
import 'widgets/notification_list_item.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<NotificationsCubit>()..load(),
      child: const _NotificationsView(),
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
            icon: AppIcon(AppIcons.filter, color: AppColors.textPrimary),
            onPressed: () => _showFilter(context),
          ),
        ],
      ),
      body: BlocBuilder<NotificationsCubit, NotificationsState>(
        builder: (context, state) {
          if (state.status == NotificationsStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == NotificationsStatus.error) {
            return Center(child: Text(l10n.errorGeneric));
          }

          final visible = _applyFilter(state.items, state.filter);

          if (visible.isEmpty) {
            return Center(child: Text(l10n.notificationsEmpty));
          }

          return ListView.separated(
            separatorBuilder: (context, index) => Divider(color: AppColors.divider,),
            itemCount: visible.length,
            itemBuilder: (context, index) {
              final item = visible[index];
              return NotificationListItem(item: item);
            },
          );
        },
      ),
    );
  }

  Future<void> _showFilter(BuildContext context) async {
    final cubit = context.read<NotificationsCubit>();
    final l10n = AppLocalizations.of(context)!;

    final options = [
      FilterOption(
        value: NotificationFilter.all,
        label: l10n.notificationsFilterAll,
      ),
      FilterOption(
        value: NotificationFilter.unread,
        label: l10n.notificationsFilterUnread,
      ),
      FilterOption(
        value: NotificationFilter.read,
        label: l10n.notificationsFilterRead,
      ),
      FilterOption(
        value: NotificationFilter.archived,
        label: l10n.notificationsFilterArchived,
      ),
    ];

    final selected = await FilterBottomSheet.show<NotificationFilter>(
      context: context,
      options: options,
      selected: cubit.state.filter,
    );

    if (selected != null && context.mounted) {
      await context.read<NotificationsCubit>().setFilter(selected);
    }
  }

  List<NotificationItem> _applyFilter(
    List<NotificationItem> items,
    NotificationFilter filter,
  ) {
    switch (filter) {
      case NotificationFilter.all:
        return items.where((i) => !i.archived).toList();
      case NotificationFilter.unread:
        return items.where((i) => !i.archived && !i.read).toList();
      case NotificationFilter.read:
        return items.where((i) => !i.archived && i.read).toList();
      case NotificationFilter.archived:
        return items.where((i) => i.archived).toList();
    }
  }
}
