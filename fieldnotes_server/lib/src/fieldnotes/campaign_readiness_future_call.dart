import 'package:serverpod/serverpod.dart';

import 'services/fieldnote_sweep_service.dart';

/// The 5-minute sweep: readiness cutoffs, expiry refunds, completion,
/// payment reconciliation and the refund worker. Scheduled in `server.dart`.
class CampaignReadinessFutureCall extends FutureCall {
  Future<void> sweep(Session session) async {
    await const FieldnoteSweepService().run(session);
  }
}
