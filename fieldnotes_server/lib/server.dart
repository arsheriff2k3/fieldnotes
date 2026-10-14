import 'dart:io';

import 'package:serverpod_auth_idp_server/core.dart';
import 'package:serverpod_auth_idp_server/providers/email.dart';
import 'package:serverpod_cloud_storage/serverpod_cloud_storage.dart';

import 'src/cache_busting.dart';
import 'src/fieldnotes/services/fieldnote_time.dart';
import 'src/auth/verification_email_sender.dart';
import 'src/generated/serverpod.dart';
import 'src/web/routes/app_config_route.dart';
import 'src/web/routes/campaign_share_route.dart';
import 'src/web/routes/razorpay_webhook_route.dart';
import 'src/web/routes/well_known_routes.dart';

/// The starting point of the Serverpod server.
void run(List<String> args) async {
  // Load the IANA tz database once for DST-aware volunteer times.
  FieldnoteTime.ensureInitialized();

  // Initialize Serverpod. The generated Serverpod class is already connected
  // with your project's generated code.
  final pod = Serverpod(args);

  // Initialize authentication services for the server.
  // Token managers will be used to validate and issue authentication keys,
  // and the identity providers will be the authentication options available for users.
  pod.initializeAuthServices(
    tokenManagerBuilders: [
      // Use JWT for authentication keys towards the server.
      JwtConfigFromPasswords(),
    ],
    identityProviderBuilders: [
      // Signup and password-reset codes go to the address supplied by the
      // user. Normal email/password sign-in does not issue a code.
      EmailIdpConfigFromPasswords(
        sendRegistrationVerificationCode:
            (
              session, {
              required email,
              required accountRequestId,
              required verificationCode,
              required transaction,
            }) => VerificationEmailSender.sendRegistration(
              session,
              email: email,
              code: verificationCode,
            ),
        sendPasswordResetVerificationCode:
            (
              session, {
              required email,
              required passwordResetRequestId,
              required verificationCode,
              required transaction,
            }) async {
              try {
                await VerificationEmailSender.sendPasswordReset(
                  session,
                  email: email,
                  code: verificationCode,
                );
              } catch (_) {
                // Password-reset requests must not reveal whether an account
                // exists. The sender logs the delivery failure on the server.
              }
            },
      ),
    ],
  );

  // Serve all files in the web/static relative directory under /web.
  // These are used by the default web page.
  pod.webServer.addRoute(
    StaticRoute.withCacheBusting(cacheBustingConfig),
    cacheBustingConfig.mountPrefix,
  );

  // Setup the app config route.
  // We build this configuration based on the servers api url and serve it to
  // the flutter app.
  pod.webServer.addRoute(
    AppConfigRoute(apiConfig: pod.config.apiServer),
    '/assets/assets/config.json',
  );

  final isDevelopment = pod.runMode == ServerpodRunMode.development;

  // `/c/<shareSlug>` (and legacy `/c/<id>`); 404 for non-open campaigns.
  pod.webServer.addRoute(
    CampaignShareRoute(allowApkDownload: isDevelopment),
    '/c/:id',
  );

  // Razorpay payment and refund events (signature-verified, de-duplicated).
  pod.webServer.addRoute(RazorpayWebhookRoute(), '/webhooks/razorpay');

  // Legal documents with a short cache so policy updates reach clients in
  // minutes. `/web/legal/*.html` stays available but is cached for a year.
  for (final document in const ['privacy', 'terms']) {
    pod.webServer.addRoute(
      StaticRoute.file(
        File(Uri(path: 'web/static/legal/$document.html').toFilePath()),
        cacheControlFactory: StaticRoute.public(
          maxAge: const Duration(minutes: 5),
        ),
      ),
      '/legal/$document',
    );
  }

  // App Links / Universal Links verification (404 until configured by env).
  pod.webServer.addRoute(
    WellKnownRoute(WellKnownDocuments.assetLinks),
    '/.well-known/assetlinks.json',
  );
  pod.webServer.addRoute(
    WellKnownRoute(WellKnownDocuments.appleAppSiteAssociation),
    '/.well-known/apple-app-site-association',
  );

  // Development only: serve the locally built APK from the campaign link's
  // host. Release builds link to the store listing instead (R-4).
  final fieldnoteApk = File(fieldnoteApkFilePath);
  if (isDevelopment && fieldnoteApk.existsSync()) {
    pod.webServer.addRoute(
      StaticRoute.file(
        fieldnoteApk,
        cacheControlFactory: StaticRoute.noStore(),
      ),
      '/download/fieldnote.apk',
    );
  }

  // Checks if the flutter web app has been built and serves it if it has.
  final appDir = Directory(Uri(path: 'web/app').toFilePath());
  if (appDir.existsSync()) {
    // Serve the flutter web app under /.
    pod.webServer.addRoute(
      FlutterRoute(
        appDir,
        // If building the Flutter app with WASM, set the below parameter to
        // true and add the --wasm flag to the flutter build command.
        enableWasmHeaders: false,
      ),
      '/',
    );
  } else {
    // If the flutter web app has not been built, serve the build app page.
    final defaultRoute = StaticRoute.file(
      File(
        Uri(path: 'web/pages/build_flutter_app.html').toFilePath(),
      ),
    );

    pod.webServer.addMiddleware(
      FallbackMiddleware(
        fallback: defaultRoute,
        on: (response) => response.statusCode == 404,
      ).call,
      '/',
    );

    pod.webServer.addRoute(
      defaultRoute,
      '/**',
    );
  }

  // Configure cloud storage.
  // This setup works with Serverpod Cloud without extra configuration.
  // If you want to use a custom provider for cloud storage, replace these
  // with your preferred provider.
  pod.addCloudStorage(
    await ServerpodCloudProvider.private(
      fallback: () => DatabaseCloudStorage('private'),
    ),
  );
  pod.addCloudStorage(
    await ServerpodCloudProvider.public(
      fallback: () => DatabaseCloudStorage('public'),
    ),
  );

  // Start the server.
  await pod.start();
  // The sweep owns readiness cutoffs, expiry refunds, campaign completion,
  // payment reconciliation and the refund worker. It is re-registered on
  // every boot so exactly one recurring schedule exists.
  await pod.futureCalls.cancel('campaign-readiness-sweep');
  await pod.futureCalls
      .callRecurring(identifier: 'campaign-readiness-sweep')
      .every(const Duration(minutes: 5))
      .campaignReadiness
      .sweep();
  await pod.futureCalls
      .callWithDelay(const Duration(seconds: 1))
      .campaignReadiness
      .sweep();
  // Account deletions, transactional email and rate-limit cleanup.
  await pod.futureCalls.cancel('fieldnote-outbox');
  await pod.futureCalls
      .callRecurring(identifier: 'fieldnote-outbox')
      .every(const Duration(minutes: 1))
      .fieldnoteOutbox
      .run();
}
