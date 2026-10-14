import 'package:fieldnotes_client/fieldnotes_client.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../data/services/firebase_push_service.dart';
import '../../../l10n/l10n.dart';
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
  bool _opening = false;

  @override
  void initState() {
    super.initState();
    widget.viewModel.refresh();
  }

  void _failure() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.notificationsActionFailed)),
      );
    }
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
    if (_opening) return;
    _opening = true;
    try {
      await widget.viewModel.markRead(item);
      if (!mounted) return;
      final l10n = context.l10n;
      final open = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(item.title),
          content: SingleChildScrollView(child: Text(item.body)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.notificationsClose),
            ),
            if (item.campaignId != null)
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(l10n.notificationsViewActivity),
              ),
          ],
        ),
      );
      if (open == true && mounted) {
        Navigator.pop(context);
        await widget.onOpen(item);
      }
    } catch (_) {
      _failure();
    } finally {
      _opening = false;
    }
  }

  Future<void> _markAll() async {
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
    return Scaffold(
      appBar: AppBar(title: Text(l10n.notificationsTitle)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: ListenableBuilder(
              listenable: widget.viewModel,
              builder: (context, _) {
                final vm = widget.viewModel;
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          FilterChip(
                            label: Text(l10n.notificationsUnreadOnly),
                            selected: vm.unreadOnly,
                            onSelected: vm.filterUnread,
                          ),
                          TextButton(
                            onPressed: _marking || vm.items.isEmpty
                                ? null
                                : _markAll,
                            child: Text(l10n.notificationsMarkAllRead),
                          ),
                          OutlinedButton.icon(
                            onPressed:
                                _enabling ||
                                    !FirebasePushService.instance.available
                                ? null
                                : _enablePush,
                            icon: const Icon(
                              Icons.notifications_active_outlined,
                            ),
                            label: Text(l10n.notificationsEnablePush),
                          ),
                        ],
                      ),
                    ),
                    if (!FirebasePushService.instance.available)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(l10n.notificationsPushUnavailable),
                      ),
                    if (vm.loading) const LinearProgressIndicator(),
                    if (vm.error != null)
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Text(l10n.notificationsLoadFailed),
                            TextButton(
                              onPressed: vm.refresh,
                              child: Text(l10n.notificationsRetry),
                            ),
                          ],
                        ),
                      ),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: vm.refresh,
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            if (!vm.loading &&
                                vm.items.isEmpty &&
                                vm.error == null)
                              Padding(
                                padding: const EdgeInsets.all(32),
                                child: Text(
                                  vm.unreadOnly
                                      ? l10n.notificationsAllCaughtUp
                                      : l10n.notificationsEmpty,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            for (final item in vm.items)
                              ListTile(
                                key: ValueKey('notification-${item.id}'),
                                leading: Icon(
                                  item.readAt == null
                                      ? Icons.markunread_outlined
                                      : Icons.drafts_outlined,
                                ),
                                title: Text(
                                  item.title,
                                  style: TextStyle(
                                    fontWeight: item.readAt == null
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                                subtitle: Text(
                                  '${item.body}\n${DateFormat.yMMMd(l10n.localeName).add_jm().format(item.createdAt.toLocal())}',
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                onTap: () => _open(item),
                              ),
                            if (vm.hasMore)
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: TextButton(
                                  onPressed: vm.loadingMore
                                      ? null
                                      : vm.loadMore,
                                  child: Text(l10n.notificationsLoadMore),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
