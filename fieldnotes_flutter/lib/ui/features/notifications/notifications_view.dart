import 'package:fieldnotes_client/fieldnotes_client.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../data/services/firebase_push_service.dart';
import '../../../l10n/l10n.dart';
import '../../core/fieldnote_theme.dart';
import 'notification_view_model.dart';

class NotificationsView extends StatefulWidget {
  const NotificationsView({
    super.key,
    required this.viewModel,
    required this.onOpen,
  });
  final NotificationViewModel viewModel;
  final Future<void> Function(NotificationItem) onOpen;

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  bool _enabling = false;
  bool _marking = false;
  int? _opening;
  bool _reading = false;

  @override
  void initState() {
    super.initState();
    widget.viewModel.refresh();
  }

  void _failure() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.notificationsActionFailed)),
    );
  }

  Future<void> _enablePush() async {
    setState(() => _enabling = true);
    try {
      await FirebasePushService.instance.enable();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.notificationsPushEnabled)),
        );
      }
    } catch (_) {
      _failure();
    } finally {
      if (mounted) setState(() => _enabling = false);
    }
  }

  Future<void> _open(NotificationItem item) async {
    if (_opening != null) return;
    setState(() {
      _opening = item.id;
      _reading = true;
    });
    try {
      await widget.viewModel.markRead(item);
      if (!mounted) return;
      setState(() => _reading = false);
      if (item.kind == 'campaignChat') {
        Navigator.pop(context);
        await widget.onOpen(item);
        return;
      }
      final open = await showNotificationDetails(context, item);
      if (open == true && mounted) {
        Navigator.pop(context);
        await widget.onOpen(item);
      }
    } catch (_) {
      _failure();
    } finally {
      if (mounted) setState(() => _opening = null);
    }
  }

  Future<void> _markAll() async {
    if (_marking) return;
    setState(() => _marking = true);
    try {
      await widget.viewModel.markAllRead();
    } catch (_) {
      _failure();
    } finally {
      if (mounted) setState(() => _marking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.fieldnoteColors;
    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(title: Text(l10n.notificationsTitle)),
      body: SafeArea(
        top: false,
        child: ListenableBuilder(
          listenable: widget.viewModel,
          builder: (context, _) {
            final vm = widget.viewModel;
            final entries = <Object>[];
            String? previousDay;
            for (final item in vm.items) {
              final day = _dayLabel(context, item.createdAt);
              if (day != previousDay) entries.add(day);
              entries.add(item);
              previousDay = day;
            }
            return RefreshIndicator(
              onRefresh: vm.refresh,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: _width(
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              vm.unreadCount == 0
                                  ? l10n.notificationsCaughtUpTitle
                                  : l10n.notificationsUnreadCount(
                                      vm.unreadCount,
                                    ),
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              l10n.notificationsSubtitle,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 20),
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final tabs = SegmentedButton<bool>(
                                  showSelectedIcon: false,
                                  segments: [
                                    ButtonSegment(
                                      value: false,
                                      label: Text(l10n.notificationsAll),
                                    ),
                                    ButtonSegment(
                                      value: true,
                                      label: Text(l10n.notificationsUnread),
                                    ),
                                  ],
                                  selected: {vm.unreadOnly},
                                  onSelectionChanged:
                                      _marking || _opening != null
                                      ? null
                                      : (value) =>
                                            vm.filterUnread(value.single),
                                  style: SegmentedButton.styleFrom(
                                    minimumSize: const Size(72, 48),
                                    selectedBackgroundColor: colors.forestFill,
                                    selectedForegroundColor: colors.onFill,
                                    backgroundColor: colors.paper,
                                    side: BorderSide(
                                      color: colors.ink.withValues(alpha: .12),
                                    ),
                                  ),
                                );
                                final mark = TextButton.icon(
                                  key: const ValueKey('mark-all-read'),
                                  onPressed:
                                      _marking ||
                                          vm.loading ||
                                          vm.unreadCount == 0 ||
                                          vm.items.isEmpty ||
                                          _opening != null
                                      ? null
                                      : _markAll,
                                  icon: _marking
                                      ? const _Spinner()
                                      : const Icon(
                                          Icons.done_all_rounded,
                                          size: 20,
                                        ),
                                  label: Text(l10n.notificationsMarkAllRead),
                                );
                                // Wrap naturally for translated labels and larger accessibility text.
                                return Wrap(
                                  spacing: 12,
                                  runSpacing: 8,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [tabs, mark],
                                );
                              },
                            ),
                            if (FirebasePushService.instance.available &&
                                !FirebasePushService.instance.enabled) ...[
                              const SizedBox(height: 20),
                              _NoticePanel(
                                icon: Icons.notifications_active_outlined,
                                title: l10n.notificationsStayUpdated,
                                message:
                                    l10n.notificationsEnablePushDescription,
                                action: OutlinedButton.icon(
                                  onPressed: _enabling ? null : _enablePush,
                                  icon: _enabling
                                      ? const _Spinner()
                                      : const Icon(
                                          Icons.add_alert_outlined,
                                          size: 18,
                                        ),
                                  label: Text(l10n.notificationsEnablePush),
                                ),
                              ),
                            ],
                            if (vm.error != null) ...[
                              const SizedBox(height: 16),
                              _NoticePanel(
                                icon: Icons.cloud_off_outlined,
                                title: l10n.notificationsConnectionTitle,
                                message: l10n.notificationsLoadFailed,
                                action: TextButton.icon(
                                  onPressed: vm.loading ? null : vm.refresh,
                                  icon: const Icon(Icons.refresh_rounded),
                                  label: Text(l10n.notificationsRetry),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (vm.loading)
                    SliverToBoxAdapter(
                      child: _width(
                        const LinearProgressIndicator(minHeight: 2),
                      ),
                    ),
                  if (!vm.loading && vm.items.isEmpty && vm.error == null)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _width(
                        Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: colors.mist,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  vm.unreadOnly
                                      ? Icons.done_all_rounded
                                      : Icons.notifications_none_rounded,
                                  size: 40,
                                  color: colors.forest,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                vm.unreadOnly
                                    ? l10n.notificationsCaughtUpTitle
                                    : l10n.notificationsEmptyTitle,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                vm.unreadOnly
                                    ? l10n.notificationsAllCaughtUp
                                    : l10n.notificationsEmpty,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  SliverList.builder(
                    itemCount: entries.length,
                    itemBuilder: (context, index) {
                      final entry = entries[index];
                      if (entry is String) {
                        return _width(
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
                            child: Text(
                              entry,
                              style: Theme.of(context).textTheme.labelLarge
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                        );
                      }
                      final item = entry as NotificationItem;
                      return _width(
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                          child: _NotificationCard(
                            item: item,
                            busy: _reading && _opening == item.id,
                            onTap: _opening == null ? () => _open(item) : null,
                          ),
                        ),
                      );
                    },
                  ),
                  if (vm.hasMore)
                    SliverToBoxAdapter(
                      child: _width(
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Center(
                            child: OutlinedButton.icon(
                              onPressed: vm.loadingMore || vm.loading
                                  ? null
                                  : vm.loadMore,
                              icon: vm.loadingMore
                                  ? const _Spinner()
                                  : const Icon(Icons.expand_more_rounded),
                              label: Text(l10n.notificationsLoadMore),
                            ),
                          ),
                        ),
                      ),
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

Widget _width(Widget child) => Center(
  child: ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 760),
    child: SizedBox(width: double.infinity, child: child),
  ),
);

String _dayLabel(BuildContext context, DateTime instant) {
  final date = instant.toLocal();
  final now = DateTime.now();
  final day = DateTime(date.year, date.month, date.day);
  final today = DateTime(now.year, now.month, now.day);
  if (day == today) return context.l10n.notificationsToday;
  if (day == DateTime(today.year, today.month, today.day - 1)) {
    return context.l10n.notificationsYesterday;
  }
  return DateFormat.yMMMd(context.l10n.localeName).format(date);
}

({IconData icon, Color color, String label}) _eventStyle(
  BuildContext context,
  String kind,
) {
  final c = context.fieldnoteColors;
  final l = context.l10n;
  return switch (kind) {
    'campaignChat' => (
      icon: Icons.forum_outlined,
      color: c.forest,
      label: l.campaignDiscussionTitle,
    ),
    'invitationReceived' => (
      icon: Icons.mail_outline_rounded,
      color: c.forest,
      label: l.notificationsCategoryInvitation,
    ),
    'volunteerJoined' || 'volunteerLeft' => (
      icon: Icons.groups_outlined,
      color: c.forest,
      label: l.notificationsCategoryTeam,
    ),
    'volunteerCheckedIn' => (
      icon: Icons.location_on_outlined,
      color: c.forest,
      label: l.notificationsCategoryCheckIn,
    ),
    'paymentVerified' || 'refundProcessed' => (
      icon: Icons.account_balance_wallet_outlined,
      color: c.forest,
      label: l.notificationsCategoryPayment,
    ),
    'evidenceSubmitted' || 'evidenceApproved' => (
      icon: Icons.task_alt_rounded,
      color: c.forest,
      label: l.notificationsCategoryEvidence,
    ),
    'evidenceRejected' => (
      icon: Icons.assignment_late_outlined,
      color: c.clay,
      label: l.notificationsCategoryEvidence,
    ),
    'campaignCancelled' || 'campaignExpired' => (
      icon: Icons.event_busy_outlined,
      color: c.danger,
      label: l.notificationsCategoryCampaign,
    ),
    'campaignPostponed' || 'campaignRevised' => (
      icon: Icons.edit_calendar_outlined,
      color: c.clay,
      label: l.notificationsCategoryCampaign,
    ),
    _ => (
      icon: Icons.event_available_outlined,
      color: c.forest,
      label: l.notificationsCategoryCampaign,
    ),
  };
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.item,
    required this.busy,
    required this.onTap,
  });
  final NotificationItem item;
  final bool busy;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.fieldnoteColors;
    final style = _eventStyle(context, item.kind);
    final unread = item.readAt == null;
    final date = DateFormat.jm(
      context.l10n.localeName,
    ).format(item.createdAt.toLocal());
    return Semantics(
      button: true,
      label: unread ? context.l10n.notificationsUnread : null,
      child: Material(
        color: unread ? c.raised : c.paper,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: unread
                ? c.forest.withValues(alpha: .3)
                : c.ink.withValues(alpha: .08),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          key: ValueKey('notification-${item.id}'),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: style.color.withValues(alpha: .1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(style.icon, color: style.color, size: 23),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            style.label,
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(
                                  color: style.color,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          Text(
                            date,
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                          if (unread && item.kind == 'campaignChat')
                            Text(
                              context.l10n.campaignChatUnread(item.unreadCount),
                              style: Theme.of(context).textTheme.labelMedium
                                  ?.copyWith(
                                    color: c.forest,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          if (unread)
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: c.forest,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item.title,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: unread
                              ? FontWeight.w700
                              : FontWeight.w500,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.body.replaceAll(RegExp(r'\s+'), ' ').trim(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(height: 1.45),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: busy
                      ? const _Spinner()
                      : Icon(
                          Icons.chevron_right_rounded,
                          size: 20,
                          color: c.ink.withValues(alpha: .45),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NoticePanel extends StatelessWidget {
  const _NoticePanel({
    required this.icon,
    required this.title,
    required this.message,
    required this.action,
  });
  final IconData icon;
  final String title;
  final String message;
  final Widget action;

  @override
  Widget build(BuildContext context) {
    final c = context.fieldnoteColors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.paper,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.ink.withValues(alpha: .1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: c.forest, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(message, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 8),
                action,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Spinner extends StatelessWidget {
  const _Spinner();
  @override
  Widget build(BuildContext context) => const SizedBox.square(
    dimension: 18,
    child: CircularProgressIndicator(strokeWidth: 2),
  );
}

/// Shared by inbox cards and native push taps so details have one presentation.
Future<bool?> showNotificationDetails(
  BuildContext context,
  NotificationItem item,
) {
  final panel = _NotificationDetails(item: item);
  if (MediaQuery.sizeOf(context).width >= 600) {
    return showDialog<bool>(
      context: context,
      builder: (_) => Dialog(
        clipBehavior: Clip.antiAlias,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: panel,
        ),
      ),
    );
  }
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (_) => panel,
  );
}

class _NotificationDetails extends StatelessWidget {
  const _NotificationDetails({required this.item});
  final NotificationItem item;

  @override
  Widget build(BuildContext context) {
    final style = _eventStyle(context, item.kind);
    final l10n = context.l10n;
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * .85,
      ),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 12, 8),
              child: Row(
                children: [
                  Icon(style.icon, color: style.color),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      style.label,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: style.color,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: l10n.notificationsClose,
                    onPressed: () => Navigator.pop(context, false),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w700, height: 1.25),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      DateFormat.yMMMd(
                        l10n.localeName,
                      ).add_jm().format(item.createdAt.toLocal()),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 24),
                    SelectableText(
                      item.body,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(height: 1.6),
                    ),
                  ],
                ),
              ),
            ),
            if (item.campaignId != null)
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
                  child: FilledButton.icon(
                    onPressed: () => Navigator.pop(context, true),
                    icon: const Icon(Icons.arrow_forward_rounded),
                    label: Text(l10n.notificationsViewActivity),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
