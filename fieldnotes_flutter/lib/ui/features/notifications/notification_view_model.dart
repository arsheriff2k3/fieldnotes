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
    await repository.markNotificationRead(item.id);
    if (_disposed) return;
    items = items
        .map(
          (row) => row.id == item.id && row.readAt == null
              ? row.copyWith(readAt: DateTime.now().toUtc())
              : row,
        )
        .toList();
    if (unreadOnly) items = items.where((row) => row.readAt == null).toList();
    await refreshCount();
    _notify();
  }

  Future<void> markAllRead() async {
    if (items.isEmpty) return;
    final cutoff = items.first.id;
    await repository.markNotificationsReadThrough(cutoff);
    if (!_disposed) await refresh();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    ++_request;
    super.dispose();
  }
}
