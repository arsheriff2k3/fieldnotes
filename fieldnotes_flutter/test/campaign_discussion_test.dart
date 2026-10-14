import 'dart:async';

import 'package:fieldnotes_client/fieldnotes_client.dart';
import 'package:fieldnotes_flutter/data/repositories/fieldnote_repository.dart';
import 'package:fieldnotes_flutter/ui/features/discussion/campaign_discussion_model.dart';
import 'package:fieldnotes_flutter/ui/features/discussion/campaign_discussion_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

final userId = UuidValue.fromString('880e8400-e29b-41d4-a716-446655440001');
CampaignChatMessage message(int id, {String? body}) => CampaignChatMessage(
  id: id,
  campaignId: 1,
  senderAuthUserId: userId,
  senderDisplayName: 'Volunteer',
  senderIsCreator: false,
  body: body ?? 'Message $id',
  clientRequestId: 'message-$id',
  createdAt: DateTime.utc(2026, 10, 14),
);

class DiscussionRepository extends FieldnoteRepository {
  final controllers = <StreamController<CampaignChatEvent>>[];
  final saved = <CampaignChatMessage>[];
  final requestIds = <String>[];
  final afterQueries = <int>[];
  bool failNextSend = false;
  Completer<List<CampaignChatMessage>>? initialPage;

  @override
  Stream<CampaignChatEvent> watchCampaignChat(int campaignId) {
    final controller = StreamController<CampaignChatEvent>();
    controllers.add(controller);
    return controller.stream;
  }

  void ready({bool readOnly = false}) => controllers.last.add(
    CampaignChatEvent(campaignId: 1, readOnly: readOnly),
  );

  @override
  Future<List<CampaignChatMessage>> campaignMessages(
    int campaignId, {
    int? beforeId,
    int? afterId,
    int limit = 50,
  }) async {
    if (afterId != null) afterQueries.add(afterId);
    if (initialPage != null && beforeId == null && afterId == null) {
      return initialPage!.future;
    }
    final rows = saved
        .where(
          (m) =>
              (beforeId == null || m.id! < beforeId) &&
              (afterId == null || m.id! > afterId),
        )
        .toList();
    rows.sort(
      (a, b) =>
          afterId == null ? b.id!.compareTo(a.id!) : a.id!.compareTo(b.id!),
    );
    return rows.take(limit).toList();
  }

  @override
  Future<CampaignChatMessage> sendCampaignMessage(
    int campaignId,
    String body,
    String requestId,
  ) async {
    requestIds.add(requestId);
    if (failNextSend) {
      failNextSend = false;
      throw TimeoutException('Lost response');
    }
    final sent = message(saved.length + 1, body: body);
    saved.add(sent);
    controllers.last.add(
      CampaignChatEvent(campaignId: 1, readOnly: false, message: sent),
    );
    return sent;
  }
}

void main() {
  testWidgets(
    'live messages arriving during initial history are retained and deduplicated',
    (tester) async {
      final repository = DiscussionRepository()..initialPage = Completer();
      final model = CampaignDiscussionModel(repository, 1)..start();
      addTearDown(model.dispose);
      repository.ready();
      await tester.pump();
      repository.controllers.last.add(
        CampaignChatEvent(campaignId: 1, readOnly: false, message: message(2)),
      );
      repository.initialPage!.complete([message(1), message(2)]);
      await tester.pump();
      expect(model.messages.map((m) => m.id), [2, 1]);
      expect(model.loading, isFalse);
    },
  );

  testWidgets(
    'a send retry reuses its request id and successful sends start a new request',
    (tester) async {
      final repository = DiscussionRepository();
      final model = CampaignDiscussionModel(repository, 1)..start();
      addTearDown(model.dispose);
      repository.ready();
      await tester.pump();
      repository.failNextSend = true;
      expect(await model.send('Where do we meet?'), isFalse);
      expect(await model.send('Where do we meet?'), isTrue);
      expect(repository.requestIds[0], repository.requestIds[1]);
      expect(await model.send('Where do we meet?'), isTrue);
      expect(repository.requestIds[2], isNot(repository.requestIds[1]));
      await tester.pump();
      expect(model.messages, hasLength(2));
    },
  );

  testWidgets('reconnect recovers multiple pages of missed history', (
    tester,
  ) async {
    final repository = DiscussionRepository()..saved.add(message(1));
    final model = CampaignDiscussionModel(repository, 1)..start();
    addTearDown(model.dispose);
    repository.ready();
    await tester.pump();
    unawaited(repository.controllers.last.close());
    await tester.pump();
    repository.saved.addAll(List.generate(204, (i) => message(i + 2)));
    await tester.pump(const Duration(seconds: 3));
    expect(repository.controllers, hasLength(2));
    repository.ready();
    await tester.pump();
    expect(model.messages, hasLength(205));
    expect(repository.afterQueries, containsAllInOrder([1, 101, 201]));
  });

  testWidgets(
    'revoked access clears displayed messages and stops reconnecting',
    (tester) async {
      final repository = DiscussionRepository()..saved.add(message(1));
      final model = CampaignDiscussionModel(repository, 1)..start();
      addTearDown(model.dispose);
      repository.ready();
      await tester.pump();
      repository.controllers.last.addError(
        FieldnoteException(code: 'chat_forbidden', message: 'Left campaign'),
      );
      await tester.pump();
      expect(model.accessDenied, isTrue);
      expect(model.messages, isEmpty);
      await tester.pump(const Duration(seconds: 4));
      expect(repository.controllers, hasLength(1));
    },
  );

  final campaign = Campaign(
    id: 1,
    organizationId: 1,
    name: 'Neighborhood cleanup',
    description: 'Help nearby',
    locationName: 'Park',
    startsAt: DateTime.utc(2026, 10, 15),
    status: CampaignStatus.active,
    createdBy: UuidValue.fromString('880e8400-e29b-41d4-a716-446655440000'),
  );

  testWidgets(
    'discussion fits a narrow screen and volunteers can send a shared message',
    (tester) async {
      tester.view.physicalSize = const Size(360, 740);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final repository = DiscussionRepository();
      await tester.pumpWidget(
        MaterialApp(
          home: CampaignDiscussionView(
            campaign: campaign,
            repository: repository,
            currentUserId: userId,
          ),
        ),
      );
      repository.ready();
      await tester.pump();
      await tester.enterText(
        find.byType(TextField),
        'Does anyone have gloves?',
      );
      await tester.tap(find.byTooltip('Send message'));
      await tester.pump();
      expect(find.text('Does anyone have gloves?'), findsOneWidget);
      expect(find.text('You · Volunteer'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets('closed campaigns display history without a composer', (
    tester,
  ) async {
    final repository = DiscussionRepository()..saved.add(message(1));
    await tester.pumpWidget(
      MaterialApp(
        home: CampaignDiscussionView(
          campaign: campaign,
          repository: repository,
          currentUserId: userId,
        ),
      ),
    );
    repository.ready(readOnly: true);
    await tester.pump();
    expect(find.text('Message 1'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
    expect(
      find.text('This campaign is closed. You can still read the discussion.'),
      findsOneWidget,
    );
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
