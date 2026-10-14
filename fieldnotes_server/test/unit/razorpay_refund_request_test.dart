import 'dart:convert';
import 'dart:io';

import 'package:fieldnotes_server/src/fieldnotes/services/razorpay_payment_service.dart';
import 'package:test/test.dart';

/// Item 4: the refund request uses only Razorpay's documented
/// `POST /v1/payments/:id/refund` body fields and no idempotency header.
void main() {
  late HttpServer server;
  final requests =
      <({String method, String path, HttpHeaders headers, String body})>[];

  setUp(() async {
    requests.clear();
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((request) async {
      final body = await utf8.decoder.bind(request).join();
      requests.add((
        method: request.method,
        path: request.uri.path,
        headers: request.headers,
        body: body,
      ));
      request.response.headers.contentType = ContentType.json;
      request.response.write(
        request.method == 'POST'
            ? jsonEncode({
                'id': 'rfnd_local',
                'payment_id': 'pay_local',
                'amount': 12345,
                'status': 'pending',
                'receipt': 'fn_refund_7',
                'notes': {'fieldnote_refund_id': '7'},
              })
            : jsonEncode({
                'items': [
                  {
                    'id': 'rfnd_local',
                    'payment_id': 'pay_local',
                    'amount': 12345,
                    'status': 'processed',
                    'receipt': 'fn_refund_7',
                    'notes': {'fieldnote_refund_id': '7'},
                  },
                ],
              }),
      );
      await request.response.close();
    });
  });

  tearDown(() => server.close(force: true));

  test('creates refunds with documented fields only', () async {
    final service = RazorpayPaymentService(
      apiBase: 'http://127.0.0.1:${server.port}/v1',
    );
    const credentials = RazorpayCredentials(
      keyId: 'rzp_test_local',
      keySecret: 'local_secret',
    );
    final created = await service.createRefund(
      credentials: credentials,
      paymentId: 'pay_local',
      amountPaise: 12345,
      receipt: 'fn_refund_7',
      notes: const {'fieldnote_refund_id': '7'},
    );
    expect(created.id, 'rfnd_local');
    expect(created.receipt, 'fn_refund_7');

    final post = requests.single;
    expect(post.method, 'POST');
    expect(post.path, '/v1/payments/pay_local/refund');
    expect(post.headers.value('X-Refund-Idempotency'), isNull);
    expect(post.headers.value('X-Idempotency-Key'), isNull);
    final body = jsonDecode(post.body) as Map<String, dynamic>;
    expect(body.keys.toSet(), {'amount', 'speed', 'receipt', 'notes'});
    expect(body['amount'], 12345);
    expect(body['receipt'], 'fn_refund_7');

    final listed = await service.listPaymentRefunds(
      credentials: credentials,
      paymentId: 'pay_local',
    );
    expect(requests.last.path, '/v1/payments/pay_local/refunds');
    expect(listed.single.notes['fieldnote_refund_id'], '7');
    expect(listed.single.status, 'processed');
  });
}
