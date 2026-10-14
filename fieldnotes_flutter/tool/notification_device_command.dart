// Talks to an instrumented debug app through an ADB-forwarded VM service.
// VM-service URLs stay in the local, untracked configuration file.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_driver/flutter_driver.dart';

Future<void> main(List<String> args) async {
  final config =
      jsonDecode(await File(args[0]).readAsString()) as Map<String, dynamic>;
  final serviceUrl = config[args[1]] as String;
  // Firebase can start a background Dart isolate before the UI isolate after
  // process termination. Select the instrumented UI rather than the first main.
  final isolateNumber = await _driverIsolate(Uri.parse(serviceUrl));
  final driver = await FlutterDriver.connect(
    dartVmServiceUrl: serviceUrl,
    isolateNumber: isolateNumber,
    logCommunicationToFile: false,
  );
  try {
    final command = jsonDecode(args[2]) as Map<String, dynamic>;
    if (command['action'] == 'tapTooltip') {
      await driver.runUnsynchronized(
        () => driver.tap(
          find.byTooltip(command['label'] as String),
          timeout: const Duration(seconds: 15),
        ),
      );
      stdout.writeln(jsonEncode({'tapped': command['label']}));
    } else if (command['action'] == 'tapText') {
      await driver.runUnsynchronized(
        () => driver.tap(
          find.text(command['label'] as String),
          timeout: const Duration(seconds: 15),
        ),
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

Future<int> _driverIsolate(Uri base) async {
  final client = HttpClient();
  try {
    Future<Map<String, dynamic>> rpc(
      String method, [
      Map<String, String>? parameters,
    ]) async {
      final request = await client.getUrl(
        base.resolve(method).replace(queryParameters: parameters),
      );
      final response = await request.close();
      final json =
          jsonDecode(await response.transform(utf8.decoder).join())
              as Map<String, dynamic>;
      return json['result'] as Map<String, dynamic>;
    }

    final deadline = DateTime.now().add(const Duration(seconds: 15));
    while (DateTime.now().isBefore(deadline)) {
      final vm = await rpc('getVM');
      for (final ref in vm['isolates'] as List<dynamic>) {
        final id = ref['id'] as String;
        final isolate = await rpc('getIsolate', {'isolateId': id});
        if ((isolate['extensionRPCs'] as List<dynamic>? ?? []).contains(
          'ext.flutter.driver',
        )) {
          return int.parse(id.split('/').last);
        }
      }
      await Future<void>.delayed(const Duration(milliseconds: 200));
    }
    throw StateError('No instrumented UI instance found.');
  } finally {
    client.close(force: true);
  }
}
