import 'dart:async';

import 'package:fieldnotes_client/fieldnotes_client.dart';
import 'package:flutter/foundation.dart';

import '../../../data/repositories/fieldnote_repository.dart';

class NotificationViewModel extends ChangeNotifier {
  NotificationViewModel(this.repository);

  final FieldnoteRepository repository;
  List<NotificationItem> items = [];
  int unreadCount = 0;
  bool loading = false;
  bool loadingMore = false;
  bool hasMore = false;
  bool unreadOnly = false;
  Object? error;
  bool _disposed = false;
  int _request = 0;
  int _countRequest = 0;
  StreamSubscription<NotificationItem>? _subscription;
  Timer? _reconnect;
  Timer? _refreshDebounce;
  final live = ValueNotifier<NotificationItem?>(null);

  void start() {
    if (_disposed || _subscription != null) return;
    _subscription = repository.watchMyNotifications().listen(
      (item) {
        if (_disposed) return;
        items = [item, ...items.where((row) => row.id != item.id)];
        if (unreadOnly) {
          items = items.where((row) => row.readAt == null).toList();
        }
        _refreshDebounce?.cancel();
        _refreshDebounce = Timer(
          const Duration(milliseconds: 200),
          () => unawaited(refreshCount()),
        );
        live.value = item;
        _notify();
      },
      onError: (Object _) => _retry(),
      onDone: _retry,
      cancelOnError: true,
    );
  }

  void _retry() {
    if (_disposed) return;
    unawaited(_subscription?.cancel());
    _subscription = null;
    _reconnect?.cancel();
    _reconnect = Timer(const Duration(seconds: 3), () {
      start();
      unawaited(refreshCount());
    });
  }

  Future<void> refreshCount() async {
    final request = ++_countRequest;
    try {
      final count = await repository.unreadNotificationCount();
      if (_disposed || request != _countRequest) return;
      unreadCount = count;
      _notify();
    } catch (_) {
      // A badge failure must not block the rest of the app.
    }
  }

  Future<void> refresh() async {
    final request = ++_request;
    loading = true;
    error = null;
    _notify();
    try {
      final page = await repository.notifications(
        limit: 20,
        unreadOnly: unreadOnly,
      );
      if (_disposed || request != _request) return;
      items = page;
      hasMore = page.length == 20;
      await refreshCount();
    } catch (failure) {
      if (!_disposed && request == _request) error = failure;
    } finally {
      if (!_disposed && request == _request) {
        loading = false;
        _notify();
      }
    }
  }

  Future<void> loadMore() async {
    if (loading || loadingMore || !hasMore || items.isEmpty) return;
    final request = _request;
    loadingMore = true;
    error = null;
    _notify();
    try {
      final page = await repository.notifications(
        limit: 20,
        beforeId: items.last.id,
        unreadOnly: unreadOnly,
      );
      if (_disposed || request != _request) return;
      final known = items.map((item) => item.id).toSet();
      items = [...items, ...page.where((item) => !known.contains(item.id))];
      hasMore = page.length == 20;
    } catch (failure) {
      if (!_disposed && request == _request) error = failure;
    } finally {
      if (!_disposed) {
        loadingMore = false;
        _notify();
      }
    }
  }

  Future<void> filterUnread(bool value) async {
    unreadOnly = value;
    items = [];
    await refresh();
  }

  Future<void> markRead(NotificationItem item) async {
    await repository.markNotificationRead(
      item.id,
      throughChatMessageId: item.chatMessageId,
    );
    if (_disposed) return;
    if (item.kind == 'campaignChat') {
      final updated = await repository.notification(item.id);
      if (_disposed) return;
      if (updated != null) {
        items = items.map((row) => row.id == item.id ? updated : row).toList();
      }
    } else {
      items = items
          .map(
            (row) => row.id == item.id
                ? row.copyWith(readAt: DateTime.now().toUtc(), unreadCount: 0)
                : row,
          )
          .toList();
    }
    if (unreadOnly) items = items.where((row) => row.readAt == null).toList();
    await refreshCount();
    _notify();
  }

  Future<void> markAllRead() async {
    if (items.isEmpty) return;
    final snapshot = List<NotificationItem>.of(items);
    for (final item in snapshot.where(
      (row) => row.kind == 'campaignChat' && row.readAt == null,
    )) {
      await repository.markNotificationRead(
        item.id,
        throughChatMessageId: item.chatMessageId,
      );
    }
    final cutoff = snapshot
        .map((row) => row.id)
        .reduce((a, b) => a > b ? a : b);
    await repository.markNotificationsReadThrough(cutoff);
    if (!_disposed) await refresh();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _reconnect?.cancel();
    _refreshDebounce?.cancel();
    unawaited(_subscription?.cancel());
    live.dispose();
    ++_request;
    super.dispose();
  }
}
