import 'dart:math' as math;

import 'package:serverpod/serverpod.dart';

import '../../generated/protocol.dart';

/// A per-user, per-action fixed window: at most [limit] calls per [window].
class RateLimitPolicy {
  const RateLimitPolicy(this.action, this.limit, this.window);

  final String action;
  final int limit;
  final Duration window;
}

/// A-3 limits. Constants rather than config: they protect billed providers
/// and abuse-prone actions, and are generous for a real person.
abstract final class RateLimits {
  static const campaignChat = RateLimitPolicy(
    'campaignChat',
    30,
    Duration(minutes: 1),
  );
  static const pushRegistration = RateLimitPolicy(
    'pushRegistration',
    120,
    Duration(hours: 1),
  );
  static const proposeCampaign = RateLimitPolicy(
    'proposeCampaign',
    20,
    Duration(hours: 1),
  );
  static const transcribeDictation = RateLimitPolicy(
    'transcribeDictation',
    30,
    Duration(hours: 1),
  );
  static const analyzeCompletion = RateLimitPolicy(
    'analyzeCompletion',
    20,
    Duration(hours: 1),
  );

  /// Places autocomplete, place details, geocoding and routes share one
  /// budget. Autocomplete is debounced client-side at 350 ms.
  static const maps = RateLimitPolicy('maps', 600, Duration(hours: 1));

  /// Matching prices up to 100 destinations with the billed Routes API.
  static const matches = RateLimitPolicy('matches', 240, Duration(hours: 1));
  static const createOrder = RateLimitPolicy(
    'createRazorpayOrder',
    20,
    Duration(hours: 1),
  );
  static const shareAndInvite = RateLimitPolicy(
    'shareAndInvite',
    60,
    Duration(hours: 1),
  );
  static const accountDeletion = RateLimitPolicy(
    'requestAccountDeletion',
    5,
    Duration(days: 1),
  );
  static const dataExport = RateLimitPolicy(
    'exportMyData',
    10,
    Duration(days: 1),
  );
}

/// Database-backed fixed-window limiter. One atomic upsert per call, so it is
/// correct across any number of server instances without Redis.
class RateLimiter {
  const RateLimiter();

  /// Counts one call and throws `rate_limited` (with `retryAfterSeconds`)
  /// when the window's budget is spent.
  Future<void> hit(
    Session session,
    UuidValue authUserId,
    RateLimitPolicy policy, {
    DateTime? now,
  }) async {
    final clock = (now ?? DateTime.now()).toUtc();
    final windowMs = policy.window.inMilliseconds;
    final start = DateTime.fromMillisecondsSinceEpoch(
      clock.millisecondsSinceEpoch - clock.millisecondsSinceEpoch % windowMs,
      isUtc: true,
    );
    final result = await session.db.unsafeQuery(
      'INSERT INTO "fieldnote_rate_limit_bucket" '
      '("authUserId", "action", "windowStart", "hits") '
      'VALUES (@user::uuid, @action, @window::timestamp, 1) '
      'ON CONFLICT ("authUserId", "action", "windowStart") DO UPDATE '
      'SET "hits" = "fieldnote_rate_limit_bucket"."hits" + 1 '
      'RETURNING "hits"',
      parameters: QueryParameters.named({
        'user': authUserId.uuid,
        'action': policy.action,
        'window': start.toIso8601String(),
      }),
    );
    final hits = result.first.first as int;
    if (hits <= policy.limit) return;
    final retryAfter = math.max(
      1,
      start.add(policy.window).difference(clock).inSeconds,
    );
    throw FieldnoteException(
      message: 'Too many requests. Try again in ${_describe(retryAfter)}.',
      code: 'rate_limited',
      retryAfterSeconds: retryAfter,
    );
  }

  /// Deletes windows older than a day. Called by the outbox sweep.
  Future<int> purgeExpired(Session session, {DateTime? now}) async {
    final cutoff = (now ?? DateTime.now().toUtc()).subtract(
      const Duration(days: 2),
    );
    final deleted = await RateLimitBucket.db.deleteWhere(
      session,
      where: (t) => t.windowStart < cutoff,
    );
    return deleted.length;
  }

  static String _describe(int seconds) {
    if (seconds < 90) return '$seconds seconds';
    if (seconds < 5400) return '${(seconds / 60).ceil()} minutes';
    return '${(seconds / 3600).ceil()} hours';
  }
}
