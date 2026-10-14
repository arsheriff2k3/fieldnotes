import 'dart:async';

import 'package:fieldnotes_client/fieldnotes_client.dart';
import 'package:fieldnotes_flutter/data/repositories/fieldnote_repository.dart';
import 'package:fieldnotes_flutter/data/services/firebase_push_service.dart';
import 'package:fieldnotes_flutter/l10n/app_localizations.dart';
import 'package:fieldnotes_flutter/ui/features/notifications/notification_view_model.dart';
import 'package:fieldnotes_flutter/ui/core/fieldnote_theme.dart';
import 'package:fieldnotes_flutter/ui/features/notifications/notifications_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

NotificationItem notice(int id) => NotificationItem(
  id: id,
  kind: 'campaignCancelled',
  title: 'Campaign cancelled',
  body: 'Do not travel. Your place has been released.',
  campaignId: 8,
  createdAt: DateTime.utc(2026, 10, 14),
);

class InboxRepository extends FieldnoteRepository {
  List<NotificationItem> rows = [notice(2), notice(1)];
  final updates = StreamController<NotificationItem>.broadcast();
  @override
  Stream<NotificationItem> watchMyNotifications() => updates.stream;
  @override
  Future<NotificationItem?> notification(int id) async =>
      rows.where((row) => row.id == id).firstOrNull;
  bool failRead = false;
  bool failLoad = false;
  int? cutoff;
  Completer<List<NotificationItem>>? pending;

  @override
  Future<List<NotificationItem>> notifications({
    int limit = 30,
    int? beforeId,
    bool unreadOnly = false,
  }) async {
    if (failLoad) throw StateError('offline');
    if (pending != null) return pending!.future;
    return rows
        .where(
          (row) =>
              (beforeId == null || row.id < beforeId) &&
              (!unreadOnly || row.readAt == null),
        )
        .take(limit)
        .toList();
  }

  @override
  Future<int> unreadNotificationCount() async => rows
      .where((row) => row.readAt == null)
      .fold<int>(0, (sum, row) => sum + row.unreadCount);
  @override
  Future<void> markNotificationRead(int id, {int? throughChatMessageId}) async {
    if (failRead) throw StateError('offline');
    rows = rows
        .map(
          (row) =>
              row.id == id ? row.copyWith(readAt: DateTime.now().toUtc()) : row,
        )
        .toList();
  }

  @override
  Future<void> markNotificationsReadThrough(int id) async {
    cutoff = id;
    rows.insert(
      0,
      notice(id + 1),
    ); // Arrival while the snapshot is being marked.
    rows = rows
        .map(
          (row) =>
              row.id <= id ? row.copyWith(readAt: DateTime.now().toUtc()) : row,
        )
        .toList();
  }
}

void main() {
  test(
    'live chat bursts replace a campaign group and update its unread count',
    () async {
      final repo = InboxRepository();
      final vm = NotificationViewModel(repo);
      vm.start();
      await vm.refresh();
      final group = NotificationItem(
        id: 9,
        kind: 'campaignChat',
        title: 'Neighborhood cleanup',
        body: 'Open discussion',
        campaignId: 8,
        createdAt: DateTime.utc(2026),
        unreadCount: 100,
        chatMessageId: 100,
      );
      repo.rows = [group];
      repo.updates.add(group.copyWith(unreadCount: 99, chatMessageId: 99));
      repo.updates.add(group);
      await Future<void>.delayed(const Duration(milliseconds: 250));
      expect(vm.items.where((row) => row.id == 9), hasLength(1));
      expect(vm.items.first.unreadCount, 100);
      expect(vm.unreadCount, 100);
      vm.dispose();
      await repo.updates.close();
    },
  );

  test(
    'reading a chat snapshot retains an incoming reply returned by server',
    () async {
      final repo = RacingChatRepository();
      final vm = NotificationViewModel(repo);
      await vm.refresh();
      await vm.markRead(vm.items.first);
      expect(repo.through, 100);
      expect(vm.items.first.unreadCount, 1);
      expect(vm.items.first.readAt, isNull);
      expect(vm.unreadCount, 1);
      vm.dispose();
    },
  );

  test('read failure keeps an item unread and badge count unchanged', () async {
    final repo = InboxRepository();
    final vm = NotificationViewModel(repo);
    await vm.refresh();
    repo.failRead = true;
    await expectLater(vm.markRead(vm.items.first), throwsStateError);
    expect(vm.items.first.readAt, isNull);
    expect(vm.unreadCount, 2);
    vm.dispose();
  });

  test(
    'mark all uses the displayed snapshot and preserves a new arrival',
    () async {
      final repo = InboxRepository();
      final vm = NotificationViewModel(repo);
      await vm.refresh();
      await vm.markAllRead();
      expect(repo.cutoff, 2);
      expect(vm.items.first.id, 3);
      expect(vm.items.first.readAt, isNull);
      expect(vm.unreadCount, 1);
      vm.dispose();
    },
  );

  test('a late response cannot notify a disposed inbox', () async {
    final repo = InboxRepository()..pending = Completer();
    final vm = NotificationViewModel(repo);
    final load = vm.refresh();
    vm.dispose();
    repo.pending!.complete([notice(1)]);
    await load;
    expect(vm.items, isEmpty);
  });

  test('pagination remains newest-first without duplicated IDs', () async {
    final repo = InboxRepository()
      ..rows = List.generate(25, (index) => notice(25 - index));
    final vm = NotificationViewModel(repo);
    await vm.refresh();
    expect(vm.items.length, 20);
    expect(vm.hasMore, isTrue);
    await vm.loadMore();
    expect(
      vm.items.map((row) => row.id),
      List.generate(25, (index) => 25 - index),
    );
    expect(vm.hasMore, isFalse);
    vm.dispose();
  });

  test('notification payload parser rejects malformed identifiers', () {
    for (final value in ['', 'abc', '0', '-1', null]) {
      expect(notificationIdFromData({'notificationId': value}), isNull);
    }
    expect(notificationIdFromData({'notificationId': '42'}), 42);
  });

  testWidgets(
    'grouped chat notification displays count and opens discussion directly',
    (tester) async {
      final repo = InboxRepository()
        ..rows = [
          NotificationItem(
            id: 9,
            kind: 'campaignChat',
            title: 'Neighborhood cleanup',
            body: 'Open discussion',
            campaignId: 8,
            createdAt: DateTime.utc(2026),
            unreadCount: 100,
            chatMessageId: 100,
          ),
        ];
      final vm = NotificationViewModel(repo);
      NotificationItem? opened;
      final navigator = GlobalKey<NavigatorState>();
      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navigator,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: Text('Home')),
        ),
      );
      unawaited(
        navigator.currentState!.push(
          MaterialPageRoute<void>(
            builder: (_) => NotificationsView(
              viewModel: vm,
              onOpen: (item) async {
                opened = item;
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('100 unread messages'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('notification-9')));
      await tester.pumpAndSettle();
      expect(opened?.campaignId, 8);
      expect(find.text('View activity'), findsNothing);
      expect(find.text('Home'), findsOneWidget);
      expect(vm.unreadCount, 0);
      await tester.pumpWidget(const SizedBox());
      vm.dispose();
    },
  );

  for (final width in [320.0, 1100.0]) {
    testWidgets('inbox renders and opens a notification at width $width', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final vm = NotificationViewModel(InboxRepository());
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: NotificationsView(viewModel: vm, onOpen: (_) async {}),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Notifications'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('notification-2')));
      await tester.pumpAndSettle();
      expect(find.text('View activity'), findsOneWidget);
      expect(vm.unreadCount, 1);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      vm.dispose();
    });
  }

  for (final locale in ['en', 'hi', 'ta']) {
    testWidgets('narrow dark inbox and details support large text in $locale', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final repo = InboxRepository();
      repo.rows = [
        notice(
          2,
        ).copyWith(body: List.filled(30, 'A long campaign update.').join(' ')),
      ];
      final vm = NotificationViewModel(repo);
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            brightness: Brightness.dark,
            extensions: const [FieldnoteColorsTheme.dark],
          ),
          locale: Locale(locale),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(2)),
            child: child!,
          ),
          home: NotificationsView(viewModel: vm, onOpen: (_) async {}),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('notification-2')),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await Scrollable.ensureVisible(
        tester.element(find.byKey(const ValueKey('notification-2'))),
        alignment: .5,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('notification-2')));
      await tester.pumpAndSettle();
      expect(find.byType(SelectableText), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      vm.dispose();
    });
  }

  testWidgets(
    'read-only inbox disables mark all and unread filter shows empty state',
    (tester) async {
      final repo = InboxRepository()
        ..rows = [notice(2).copyWith(readAt: DateTime.now())];
      final vm = NotificationViewModel(repo);
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: NotificationsView(viewModel: vm, onOpen: (_) async {}),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<TextButton>(find.byKey(const ValueKey('mark-all-read')))
            .onPressed,
        isNull,
      );
      await tester.tap(find.text('Unread'));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('notification-2')), findsNothing);
      expect(find.text('You have no unread notifications.'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      vm.dispose();
    },
  );

  testWidgets('offline inbox shows retry and recovers', (tester) async {
    final repo = InboxRepository()..failLoad = true;
    final vm = NotificationViewModel(repo);
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: NotificationsView(viewModel: vm, onOpen: (_) async {}),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Retry'), findsOneWidget);
    repo.failLoad = false;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('notification-2')), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    vm.dispose();
  });
}

class RacingChatRepository extends InboxRepository {
  RacingChatRepository() {
    rows = [
      NotificationItem(
        id: 9,
        kind: 'campaignChat',
        title: 'Cleanup',
        body: 'Open discussion',
        campaignId: 8,
        createdAt: DateTime.utc(2026),
        unreadCount: 100,
        chatMessageId: 100,
      ),
    ];
  }
  int? through;
  @override
  Future<void> markNotificationRead(int id, {int? throughChatMessageId}) async {
    through = throughChatMessageId;
    rows = [rows.single.copyWith(unreadCount: 1, chatMessageId: 101)];
  }
}
