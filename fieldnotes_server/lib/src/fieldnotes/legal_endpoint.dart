import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import 'fieldnote_endpoint.dart';
import 'services/fieldnote_config.dart';

/// Public, read-only legal metadata. Login is not required so the signup
/// screen can link the current documents before an account exists.
class LegalEndpoint extends Endpoint {
  @override
  bool get requireLogin => false;

  /// Current policy versions, their public URLs and the consents that
  /// `acceptLegalConsent` requires. URLs are built from the web server's
  /// public host (`SERVERPOD_WEB_SERVER_PUBLIC_HOST`) or
  /// `FIELDNOTE_LINK_BASE_URL`, and point at the short-cache `/legal/*`
  /// routes so policy updates reach clients within minutes.
  Future<LegalPolicies> getLegalPolicies(Session session) async {
    final base = FieldnoteConfig.publicWebBaseUrl(session.serverpod);
    return LegalPolicies(
      privacyPolicyVersion: FieldnoteEndpoint.privacyPolicyVersion,
      termsVersion: FieldnoteEndpoint.termsVersion,
      privacyPolicyUrl: '$base/legal/privacy',
      termsUrl: '$base/legal/terms',
      requiredConsents: FieldnoteEndpoint.requiredConsents,
    );
  }
}
