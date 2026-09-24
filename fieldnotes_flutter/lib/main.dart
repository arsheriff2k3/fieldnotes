import 'package:flutter/material.dart';

import 'client.dart';
import 'data/services/map_config_service.dart';
import 'screens/sign_in_screen.dart';
import 'ui/core/fieldnote_theme.dart';
import 'ui/features/shell/app_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeClient();
  // Loads the Maps client key and, on web, the Maps JavaScript API. Never
  // throws; a missing key just leaves every map on its fallback panel.
  await MapConfig.load();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FieldNote Teams AI',
      debugShowCheckedModeBanner: false,
      theme: buildFieldnoteTheme(),
      home: const SignInScreen(child: AppShell()),
    );
  }
}
