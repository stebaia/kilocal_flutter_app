import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kilocal_flutter_app/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/notification_item.dart';
import '../cubit/notifications_cubit.dart';

class NotificationListItem extends StatelessWidget {
  const NotificationListItem({super.key, required this.item});

  final NotificationItem item;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return  Container(
          color: item.read ? null : AppColors.unreadBackground,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenGutter,
              vertical: AppSpacing.spaceMd,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Avatar(category: item.category),
                    const SizedBox(width: AppSpacing.spaceMd),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        item.title,
                                        style: AppTypography
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              fontWeight: item.read
                                                  ? FontWeight.w500
                                                  : FontWeight.w700,
                                            ),
                                      ),
                                    ),
                                    
                                  ],
                                ),
                              ),
                              const SizedBox(width: AppSpacing.spaceSm),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    _relativeTime(item.timestamp),
                                    style: AppTypography.textTheme.labelSmall
                                        ?.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                  ),
                                  const SizedBox(height: AppSpacing.space2xs),
                                  _MoreButton(itemId: item.id),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.space2xs),
                          Html(
                            data: item.body,
                            style: {
                              'body': Style(
                                margin: Margins.zero,
                                padding: HtmlPaddings.zero,
                                color: AppColors.textSecondary,
                                fontSize: FontSize(
                                  AppTypography
                                          .textTheme
                                          .labelMedium
                                          ?.fontSize ??
                                      14,
                                ),
                              ),
                            },
                          ),
                          if (item.imageUrl != null) ...[
                            const SizedBox(height: AppSpacing.spaceSm),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              child: Image.network(
                                item.imageUrl!,
                                width: double.infinity,
                                height: 160,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ],
                          if (item.ctas.isNotEmpty) ...[
                            const SizedBox(height: AppSpacing.spaceMd),
                            Wrap(
                              spacing: AppSpacing.spaceSm,
                              runSpacing: AppSpacing.spaceSm,
                              children: [
                                for (var i = 0; i < item.ctas.length; i++)
                                  _CtaButton(
                                    cta: item.ctas[i],
                                    filled: i == 0,
                                    fallbackLabel: l10n.benefitDetails,
                                  ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                
                Divider(height: 1, color: AppColors.divider),
              ],
            ),
          ),
        
    );
  }

  String _relativeTime(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inMinutes < 1) return 'Ora';
    if (diff.inHours < 1) return '${diff.inMinutes}m';
    if (diff.inDays < 1) return '${diff.inHours}h';
    if (diff.inDays < 30) return '${diff.inDays}g';
    if (diff.inDays < 365) return '${diff.inDays ~/ 30}m';
    return '${diff.inDays ~/ 365}a';
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({this.category});

  final String? category;

  @override
  Widget build(BuildContext context) {
    final data = _categoryData(category);

    return CircleAvatar(
      radius: 24,
      backgroundColor: data.background,
      child: data.icon != null
          ? Icon(data.icon, color: data.foreground, size: 22)
          : Text(
              data.label,
              style: AppTypography.textTheme.titleSmall?.copyWith(
                color: data.foreground,
                fontWeight: FontWeight.bold,
              ),
            ),
    );
  }

  _CategoryStyle _categoryData(String? category) {
    const foreground = Colors.white;
    const background = AppColors.accent;

    final normalized = category?.toLowerCase().trim() ?? '';

    if (normalized.contains('aliment') || normalized.contains('nutrition')) {
      return const _CategoryStyle(
        icon: Icons.restaurant,
        foreground: foreground,
        background: background,
      );
    }
    if (normalized.contains('allen') || normalized.contains('training')) {
      return const _CategoryStyle(
        icon: Icons.fitness_center,
        foreground: foreground,
        background: background,
      );
    }
    if (normalized.contains('beness') || normalized.contains('well')) {
      return const _CategoryStyle(
        icon: Icons.spa,
        foreground: foreground,
        background: background,
      );
    }
    if (normalized.contains('integr') || normalized.contains('kit')) {
      return const _CategoryStyle(
        icon: Icons.hourglass_empty,
        foreground: foreground,
        background: background,
      );
    }
    if (normalized.contains('kilo') || normalized == 'k') {
      return const _CategoryStyle(
        label: 'K',
        foreground: foreground,
        background: background,
      );
    }

    return const _CategoryStyle(
      icon: Icons.notifications_outlined,
      foreground: foreground,
      background: background,
    );
  }
}

class _CategoryStyle {
  const _CategoryStyle({
    this.icon,
    this.label = '',
    required this.foreground,
    required this.background,
  });

  final IconData? icon;
  final String label;
  final Color foreground;
  final Color background;
}

class _MoreButton extends StatelessWidget {
  const _MoreButton({required this.itemId});

  final String itemId;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showOptions(context),
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: const Padding(
        padding: EdgeInsets.all(AppSpacing.space2xs),
        child: Icon(Icons.more_horiz, color: AppColors.textSecondary, size: 20),
      ),
    );
  }

  void _showOptions(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final renderBox = context.findRenderObject() as RenderBox?;
    final overlay =
        Navigator.of(context).overlay?.context.findRenderObject() as RenderBox?;

    final offset =
        renderBox?.localToGlobal(Offset.zero, ancestor: overlay) ?? Offset.zero;
    final size = renderBox?.size ?? Size.zero;

    showMenu<void>(
      context: context,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy + size.height,
        overlay?.size.width ?? 0 - offset.dx - size.width,
        overlay?.size.height ?? 0 - offset.dy,
      ),
      items: [
        PopupMenuItem(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          onTap: () => context.read<NotificationsCubit>().archive(itemId),
          child: Row(
            children: [
              SvgPicture.asset(
                'assets/icons/archive.svg',
                width: 20,
                height: 20,
              ),
              const SizedBox(width: 10),
              Text(
                l10n.notificationArchive,
                style: AppTypography.textTheme.labelLarge?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CtaButton extends StatelessWidget {
  const _CtaButton({
    required this.cta,
    required this.filled,
    required this.fallbackLabel,
  });

  final NotificationCta cta;
  final bool filled;
  final String fallbackLabel;

  @override
  Widget build(BuildContext context) {
    final label = cta.label.isNotEmpty ? cta.label : fallbackLabel;

    return OutlinedButton(
      onPressed: () => _openUrl(context, cta.url),
      style: OutlinedButton.styleFrom(
        foregroundColor: filled ? Colors.white : AppColors.accent,
        backgroundColor: filled ? AppColors.accent : Colors.transparent,
        side: const BorderSide(color: AppColors.accent),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.spaceMd,
          vertical: AppSpacing.spaceSm,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.chevron_left, size: 16),
          Text(label),
          const Icon(Icons.chevron_right, size: 16),
        ],
      ),
    );
  }

  Future<void> _openUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    final canLaunch = await canLaunchUrl(uri);
    if (!canLaunch) return;

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
