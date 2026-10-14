// Talks to an instrumented debug app through an ADB-forwarded VM service.
// VM-service URLs stay in the local, untracked configuration file.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_driver/flutter_driver.dart';

Future<void> main(List<String> args) async {
  final config =
      jsonDecode(await File(args[0]).readAsString()) as Map<String, dynamic>;
  final driver = await FlutterDriver.connect(
    dartVmServiceUrl: config[args[1]] as String,
  );
  try {
    final command = jsonDecode(args[2]) as Map<String, dynamic>;
    if (command['action'] == 'tapTooltip') {
      await driver.tap(
        find.byTooltip(command['label'] as String),
        timeout: const Duration(seconds: 15),
      );
      stdout.writeln(jsonEncode({'tapped': command['label']}));
    } else if (command['action'] == 'tapText') {
      await driver.tap(
        find.text(command['label'] as String),
        timeout: const Duration(seconds: 15),
      );
      stdout.writeln(jsonEncode({'tapped': command['label']}));
    } else if (command['action'] == 'waitText') {
      await driver.waitFor(
        find.text(command['label'] as String),
        timeout: const Duration(seconds: 15),
      );
      stdout.writeln(jsonEncode({'visible': command['label']}));
    } else {
      stdout.writeln(
        await driver.requestData(
          jsonEncode(command),
          timeout: const Duration(seconds: 30),
        ),
      );
    }
  } finally {
    await driver.close();
  }
}
