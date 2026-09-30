import 'package:mailer/mailer.dart' as mailer;
import 'package:mailer/smtp_server.dart';
import 'package:serverpod/serverpod.dart';

/// Delivers Serverpod's existing email verification codes through Gmail SMTP.
/// The sender account and app password stay in Serverpod's password store.
class VerificationEmailSender {
  static const _deliveryTimeout = Duration(seconds: 15);

  static Future<void> sendRegistration(
    Session session, {
    required String email,
    required String code,
  }) => _send(
    session,
    email: email,
    code: code,
    purpose: 'signup',
  );

  static Future<void> sendPasswordReset(
    Session session, {
    required String email,
    required String code,
  }) => _send(
    session,
    email: email,
    code: code,
    purpose: 'password reset',
  );

  static Future<void> _send(
    Session session, {
    required String email,
    required String code,
    required String purpose,
  }) async {
    try {
      final sender = Serverpod.instance.getPassword('smtpUsername')?.trim();
      final appPassword = Serverpod.instance.getPassword('smtpAppPassword');
      if (sender == null ||
          sender.isEmpty ||
          appPassword == null ||
          appPassword.isEmpty) {
        throw StateError('Email delivery is not configured on the server.');
      }

      final message = mailer.Message()
        ..from = mailer.Address(sender, 'FieldNote')
        ..recipients.add(email)
        ..subject = purpose == 'signup'
            ? 'Your FieldNote signup code'
            : 'Your FieldNote password reset code'
        ..text =
            'Your FieldNote $purpose code is: $code\n\n'
            'It expires in 15 minutes. If you did not request this code, '
            'you can ignore this email.';

      await mailer.send(
        message,
        gmail(sender, appPassword),
        timeout: _deliveryTimeout,
      );
    } catch (error, stackTrace) {
      session.log(
        'Could not deliver FieldNote $purpose email to $email.',
        level: LogLevel.error,
        exception: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
