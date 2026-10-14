import 'dart:async';
import 'dart:developer' as developer;

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'client.dart';
import 'data/services/map_config_service.dart';
import 'data/services/campaign_link_service.dart';
import 'data/services/firebase_push_service.dart';
import 'l10n/app_localizations.dart';
import 'screens/sign_in_screen.dart';
import 'ui/core/fieldnote_theme.dart';
import 'ui/features/shell/app_shell.dart';

/// Logs an uncaught error. No crash-reporting vendor is used; this is the
/// single place to add one later.
void logUncaughtError(Object error, StackTrace? stack, {String? context}) {
  final label = context == null
      ? 'Uncaught error'
      : 'Uncaught error ($context)';
  developer.log(
    label,
    name: 'fieldnote',
    error: error,
    stackTrace: stack,
    level: 1000,
  );
  debugPrint('$label: $error');
}

void installErrorHooks() {
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    logUncaughtError(
      details.exception,
      details.stack,
      context: details.context?.toDescription() ?? 'framework',
    );
  };
  // Errors outside the framework (async gaps, platform channels). This is
  // the recommended replacement for wrapping runApp in runZonedGuarded.
  PlatformDispatcher.instance.onError = (error, stack) {
    logUncaughtError(error, stack, context: 'platform');
    return true;
  };
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  installErrorHooks();
  final appLinks = AppLinks();
  await initializeClient();
  // Loads the Maps client key and, on web, the Maps JavaScript API. Never
  // throws; a missing key just leaves every map on its fallback panel.
  await MapConfig.load();
  await FirebasePushService.instance.initialize();
  runApp(MyApp(appLinks: appLinks));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, required this.appLinks});

  final AppLinks appLinks;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ValueNotifier<CampaignLinkTarget?> _linkedCampaign = ValueNotifier(
    null,
  );
  StreamSubscription<Uri>? _linkSubscription;
  Uri? _lastLink;
  DateTime? _lastLinkAt;

  @override
  void initState() {
    super.initState();
    _linkSubscription = widget.appLinks.uriLinkStream.listen(_handleLink);
    unawaited(_loadInitialLink());
  }

  Future<void> _loadInitialLink() async {
    try {
      final uri = await widget.appLinks.getInitialLink();
      if (mounted && uri != null) _handleLink(uri);
    } catch (_) {
      // Opening the home screen still works if the platform has no initial link.
    }
  }

  void _handleLink(Uri uri) {
    final target = campaignLinkFromDeepLink(uri);
    if (target == null) return;
    final now = DateTime.now();
    if (_lastLink == uri &&
        _lastLinkAt != null &&
        now.difference(_lastLinkAt!) < const Duration(seconds: 3)) {
      return;
    }
    _lastLink = uri;
    _lastLinkAt = now;
    _linkedCampaign.value = target;
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    _linkedCampaign.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FieldNote Teams AI',
      debugShowCheckedModeBanner: false,
      theme: buildFieldnoteTheme(),
      darkTheme: buildFieldnoteDarkTheme(),
      themeMode: ThemeMode.system,
      // App strings come from lib/l10n/*.arb; the global delegates translate
      // framework strings (dialog buttons, tooltips, date pickers).
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) =>
          OrientationPolicy(child: child ?? const SizedBox.shrink()),
      home: SignInScreen(
        child: AppShell(campaignLink: _linkedCampaign),
      ),
    );
  }
}

/// Locks phones to portrait; tablets (shortest side >= 600), web and desktop
/// may rotate freely. Decided from MediaQuery, so it runs after the first
/// frame rather than before runApp.
class OrientationPolicy extends StatefulWidget {
  const OrientationPolicy({super.key, required this.child});

  final Widget child;

  @override
  State<OrientationPolicy> createState() => _OrientationPolicyState();
}

class _OrientationPolicyState extends State<OrientationPolicy> {
  bool? _portraitOnly;

  static bool get _isMobilePlatform =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isMobilePlatform) return;
    final shortestSide = MediaQuery.sizeOf(context).shortestSide;
    if (shortestSide == 0) return;
    final portraitOnly = shortestSide < 600;
    if (portraitOnly == _portraitOnly) return;
    _portraitOnly = portraitOnly;
    unawaited(
      SystemChrome.setPreferredOrientations(
        portraitOnly ? const [DeviceOrientation.portraitUp] : const [],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
