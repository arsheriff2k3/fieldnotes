import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Database storage after endpoint reload', (
    sessionBuilder,
    endpoints,
  ) {
    test(
      'restores upload and download routes after connectors are cleared',
      () async {
        final server = sessionBuilder.build().server;
        expect(
          server.serverpod.storage['private'],
          isA<DatabaseCloudStorage>(),
        );

        // Match Server.injectIn's hot-reload lifecycle, including the reset of
        // manually registered connectors.
        server.endpoints.connectors.clear();
        server.endpoints.modules.clear();
        server.endpoints.initializeEndpoints(server);

        final storage = server.endpoints.getConnectorByName(
          'serverpod_cloud_storage',
        );
        expect(storage, isNotNull);
        expect(
          storage!.methodConnectors.keys,
          containsAll([
            'upload',
            'temporaryFile',
            'file',
          ]),
        );
        expect(storage.endpoint.requireLogin, isFalse);
        expect(server.endpoints.getConnectorByName('fieldnote'), isNotNull);

        // Use a separate session so the HTTP request can see the upload token
        // outside the test session's rollback transaction.
        final session = await server.serverpod.createSession(
          enableLogging: false,
        );
        final http = HttpClient();
        const path = 'tests/storage-hot-reload/photo.jpg';
        final bytes = Uint8List.fromList([0xff, 0xd8, 0xff, 0xd9]);
        try {
          final description =
              jsonDecode(
                    await session.storage.createUploadDescription(
                      storageId: 'private',
                      path: path,
                    ),
                  )
                  as Map<String, dynamic>;
          final url = Uri.parse(description['url'] as String).replace(
            port: server.port,
          );
          final request = await http.postUrl(url);
          request.headers.contentType = ContentType.binary;
          request.contentLength = bytes.length;
          request.add(bytes);
          final response = await request.close();
          expect(response.statusCode, HttpStatus.ok);
          expect(await response.transform(utf8.decoder).join(), 'true');
          expect(
            await session.storage.verifyUpload(
              storageId: 'private',
              path: path,
            ),
            isTrue,
          );
          final stored = await session.storage.retrieveFile(
            storageId: 'private',
            path: path,
          );
          expect(Uint8List.sublistView(stored), bytes);
        } finally {
          http.close(force: true);
          await session.storage.deleteFile(storageId: 'private', path: path);
          await session.close();
        }
      },
    );
  });
}
