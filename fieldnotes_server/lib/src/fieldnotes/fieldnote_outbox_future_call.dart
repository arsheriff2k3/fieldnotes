import 'package:serverpod/serverpod.dart';

import 'services/fieldnote_sweep_service.dart';

/// Runs every minute (scheduled in `server.dart`): executes pending account
/// deletions, delivers queued transactional email and purges old rate-limit
/// windows.
class FieldnoteOutboxFutureCall extends FutureCall {
  Future<void> run(Session session) async {
    await const FieldnoteOutboxService().run(session);
  }
}
