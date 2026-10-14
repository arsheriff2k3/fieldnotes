import 'dart:async';

import 'package:fieldnotes_client/fieldnotes_client.dart';
import 'package:flutter/foundation.dart';

import '../../../data/repositories/fieldnote_repository.dart';

class CampaignDiscussionModel extends ChangeNotifier {
  CampaignDiscussionModel(this.repository, this.campaignId);

  final FieldnoteRepository repository;
  final int campaignId;
  final _messages = <int, CampaignChatMessage>{};
  StreamSubscription<CampaignChatEvent>? _subscription;
  Timer? _reconnect;
  bool _disposed = false;
  bool _syncing = false;
  bool _loadingOlder = false;
  int? _syncedThrough;
  int? _oldestLoaded;
  String? _pendingBody;
  String? _pendingRequest;
  bool get loadingOlder => _loadingOlder;

  bool connected = false;
  bool readOnly = true;
  bool loading = true;
  bool sending = false;
  bool accessDenied = false;
  bool hasOlder = false;
  Object? error;

  List<CampaignChatMessage> get messages =>
      _messages.values.toList()..sort((a, b) => b.id!.compareTo(a.id!));

  void start() {
    if (_disposed || accessDenied || _subscription != null) return;
    _subscription = repository
        .watchCampaignChat(campaignId)
        .listen(
          (event) {
            if (_disposed || accessDenied) return;
            connected = true;
            readOnly = event.readOnly;
            if (event.message case final message?) {
              _messages[message.id!] = message;
            }
            _notify();
            // The first event confirms subscription before we fetch history.
            // Heartbeats also recover a saved message whose broadcast failed.
            unawaited(_sync());
          },
          onError: _streamFailed,
          onDone: () => _streamFailed(null),
          cancelOnError: true,
        );
  }

  bool _isAccessError(Object? failure) =>
      failure is FieldnoteException &&
      {
        'chat_forbidden',
        'campaign_not_found',
        'unauthenticated',
        'profile_required',
      }.contains(failure.code);

  void _deny(Object failure) {
    accessDenied = true;
    connected = false;
    loading = false;
    error = failure;
    _messages.clear();
    _reconnect?.cancel();
    unawaited(_subscription?.cancel());
    _subscription = null;
    _notify();
  }

  void _streamFailed(Object? failure) {
    if (_disposed || accessDenied) return;
    if (_isAccessError(failure)) {
      _deny(failure!);
      return;
    }
    connected = false;
    error = failure;
    final old = _subscription;
    _subscription = null;
    unawaited(old?.cancel());
    _reconnect?.cancel();
    _reconnect = Timer(const Duration(seconds: 3), start);
    _notify();
  }

  Future<void> _sync() async {
    if (_syncing || _disposed || accessDenied) return;
    _syncing = true;
    try {
      if (_syncedThrough == null) {
        final page = await repository.campaignMessages(campaignId);
        if (_disposed || accessDenied) return;
        for (final message in page) {
          _messages[message.id!] = message;
        }
        _syncedThrough = page.isEmpty ? 0 : page.first.id!;
        _oldestLoaded = page.isEmpty ? null : page.last.id!;
        hasOlder = page.length == 50;
      } else {
        while (!_disposed && !accessDenied) {
          final page = await repository.campaignMessages(
            campaignId,
            afterId: _syncedThrough,
            limit: 100,
          );
          if (_disposed || accessDenied) return;
          for (final message in page) {
            _messages[message.id!] = message;
          }
          if (page.isNotEmpty) _syncedThrough = page.last.id!;
          if (page.length < 100) break;
        }
      }
      error = null;
      loading = false;
    } catch (failure) {
      if (_isAccessError(failure)) {
        _deny(failure);
      } else {
        error = failure;
        loading = false;
      }
    } finally {
      _syncing = false;
      _notify();
    }
  }

  Future<void> loadOlder() async {
    if (_loadingOlder || !hasOlder || _oldestLoaded == null || accessDenied) {
      return;
    }
    _loadingOlder = true;
    _notify();
    try {
      final page = await repository.campaignMessages(
        campaignId,
        beforeId: _oldestLoaded,
      );
      if (_disposed || accessDenied) return;
      for (final message in page) {
        _messages[message.id!] = message;
      }
      if (page.isNotEmpty) _oldestLoaded = page.last.id!;
      hasOlder = page.length == 50;
    } catch (failure) {
      if (_isAccessError(failure)) {
        _deny(failure);
      } else {
        error = failure;
      }
    } finally {
      _loadingOlder = false;
      _notify();
    }
  }

  Future<bool> send(String body) async {
    final text = body.trim();
    if (sending || readOnly || accessDenied || !connected || text.isEmpty) {
      return false;
    }
    if (_pendingBody != text) {
      _pendingBody = text;
      _pendingRequest = const Uuid().v4();
    }
    sending = true;
    error = null;
    _notify();
    try {
      final message = await repository.sendCampaignMessage(
        campaignId,
        text,
        _pendingRequest!,
      );
      if (_disposed || accessDenied) return false;
      _messages[message.id!] = message;
      _pendingBody = null;
      _pendingRequest = null;
      return true;
    } catch (failure) {
      if (_isAccessError(failure)) {
        _deny(failure);
      } else {
        error = failure;
        if (failure is FieldnoteException && failure.code == 'chat_read_only') {
          readOnly = true;
        }
      }
      return false;
    } finally {
      sending = false;
      _notify();
    }
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _reconnect?.cancel();
    unawaited(_subscription?.cancel());
    super.dispose();
  }
}
