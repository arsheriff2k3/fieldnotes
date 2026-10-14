import 'package:serverpod/serverpod.dart';
import 'services/in_app_notification_service.dart';

class CampaignChatPushFutureCall extends FutureCall {
  Future<void> deliver(Session session) async {
    await const InAppNotificationService().deliverDue(session);
  }
}
