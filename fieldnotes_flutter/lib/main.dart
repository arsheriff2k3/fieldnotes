import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'client.dart';
import 'data/services/map_config_service.dart';
import 'data/services/campaign_link_service.dart';
import 'screens/sign_in_screen.dart';
import 'ui/core/fieldnote_theme.dart';
import 'ui/features/shell/app_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appLinks = AppLinks();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  await initializeClient();
  // Loads the Maps client key and, on web, the Maps JavaScript API. Never
  // throws; a missing key just leaves every map on its fallback panel.
  await MapConfig.load();
  runApp(MyApp(appLinks: appLinks));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, required this.appLinks});

  final AppLinks appLinks;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ValueNotifier<int?> _linkedCampaignId = ValueNotifier(null);
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
    final id = campaignIdFromDeepLink(uri);
    if (id == null) return;
    final now = DateTime.now();
    if (_lastLink == uri &&
        _lastLinkAt != null &&
        now.difference(_lastLinkAt!) < const Duration(seconds: 3)) {
      return;
    }
    _lastLink = uri;
    _lastLinkAt = now;
    _linkedCampaignId.value = id;
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    _linkedCampaignId.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FieldNote Teams AI',
      debugShowCheckedModeBanner: false,
      theme: buildFieldnoteTheme(),
      home: SignInScreen(
        child: AppShell(campaignLink: _linkedCampaignId),
      ),
    );
  }
}
