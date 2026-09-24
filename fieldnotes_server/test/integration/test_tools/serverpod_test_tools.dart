/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member
// ignore_for_file: no_leading_underscores_for_local_identifiers

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _ida;
import 'dart:io' as _idi;
import 'dart:typed_data' as _idt;
import 'package:fieldnotes_server/src/generated/fieldnotes/models/audit_event.dart'
    as _i3lt536m;
import 'package:fieldnotes_server/src/generated/fieldnotes/models/campaign.dart'
    as _iuzdi22u;
import 'package:fieldnotes_server/src/generated/fieldnotes/models/campaign_live_update.dart'
    as _ijl5nqyg;
import 'package:fieldnotes_server/src/generated/fieldnotes/models/campaign_map_overview.dart'
    as _idftstcm;
import 'package:fieldnotes_server/src/generated/fieldnotes/models/campaign_match.dart'
    as _i3ipc266;
import 'package:fieldnotes_server/src/generated/fieldnotes/models/campaign_participation.dart'
    as _i363uv3e;
import 'package:fieldnotes_server/src/generated/fieldnotes/models/campaign_post.dart'
    as _id4uw0jw;
import 'package:fieldnotes_server/src/generated/fieldnotes/models/campaign_proposal.dart'
    as _imistozd;
import 'package:fieldnotes_server/src/generated/fieldnotes/models/campaign_reach.dart'
    as _i7sn891l;
import 'package:fieldnotes_server/src/generated/fieldnotes/models/completion_evidence.dart'
    as _iwy2dzi1;
import 'package:fieldnotes_server/src/generated/fieldnotes/models/completion_proposal.dart'
    as _i7asx8cy;
import 'package:fieldnotes_server/src/generated/fieldnotes/models/impact_summary.dart'
    as _igdptf07;
import 'package:fieldnotes_server/src/generated/fieldnotes/models/legal_consent.dart'
    as _id1317s7;
import 'package:fieldnotes_server/src/generated/fieldnotes/models/place_suggestion.dart'
    as _i18eudx8;
import 'package:fieldnotes_server/src/generated/fieldnotes/models/razorpay_checkout_order.dart'
    as _i6ia46xm;
import 'package:fieldnotes_server/src/generated/fieldnotes/models/resolved_place.dart'
    as _i7kx1qhs;
import 'package:fieldnotes_server/src/generated/fieldnotes/models/sponsorship.dart'
    as _iwnubjux;
import 'package:fieldnotes_server/src/generated/fieldnotes/models/trust_center_summary.dart'
    as _i3103swi;
import 'package:fieldnotes_server/src/generated/fieldnotes/models/user_profile.dart'
    as _iwhpwl59;
import 'package:fieldnotes_server/src/generated/fieldnotes/models/volunteer_availability.dart'
    as _i5cnujyk;
import 'package:fieldnotes_server/src/generated/greetings/greeting.dart'
    as _iah5jf45;
import 'package:serverpod/serverpod.dart' as _is;
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as _iacs;
import 'package:serverpod_test/serverpod_test.dart' as _ist;
import 'package:fieldnotes_server/src/generated/protocol.dart';
import 'package:fieldnotes_server/src/generated/endpoints.dart';
export 'package:serverpod_test/serverpod_test_public_exports.dart';

/// Creates a new test group that takes a callback that can be used to write tests.
/// The callback has two parameters: `sessionBuilder` and `endpoints`.
/// `sessionBuilder` is used to build a `Session` object that represents the server state during an endpoint call and is used to set up scenarios.
/// `endpoints` contains all your Serverpod endpoints and lets you call them:
/// ```dart
/// withServerpod('Given Example endpoint', (sessionBuilder, endpoints) {
///   test('when calling `hello` then should return greeting', () async {
///     final greeting = await endpoints.example.hello(sessionBuilder, 'Michael');
///     expect(greeting, 'Hello Michael');
///   });
/// });
/// ```
///
/// **Configuration options**
///
/// [applyMigrations] Whether pending migrations should be applied when starting Serverpod. Defaults to `true`
///
/// [enableSessionLogging] Whether session logging should be enabled. Defaults to `false`
///
/// [rollbackDatabase] Options for when to rollback the database during the test lifecycle.
/// By default `withServerpod` does all database operations inside a transaction that is rolled back after each `test` case.
/// Just like the following enum describes, the behavior of the automatic rollbacks can be configured:
/// ```dart
/// /// Options for when to rollback the database during the test lifecycle.
/// enum RollbackDatabase {
///   /// After each test. This is the default.
///   afterEach,
///
///   /// After all tests.
///   afterAll,
///
///   /// Disable rolling back the database.
///   disabled,
/// }
/// ```
///
/// [runMode] The run mode that Serverpod should be running in. Defaults to `test`.
///
/// [serverpodLoggingMode] The logging mode used when creating Serverpod. Defaults to `ServerpodLoggingMode.normal`
///
/// [serverpodStartTimeout] The timeout to use when starting Serverpod, which connects to the database among other things. Defaults to `Duration(seconds: 120)`.
///
/// [testServerOutputMode] Options for controlling test server output during test execution. Defaults to `TestServerOutputMode.normal`.
/// ```dart
/// /// Options for controlling test server output during test execution.
/// enum TestServerOutputMode {
///   /// Default mode - only stderr is printed (stdout suppressed).
///   /// This hides normal startup/shutdown logs while preserving error messages.
///   normal,
///
///   /// All logging - both stdout and stderr are printed.
///   /// Useful for debugging when you need to see all server output.
///   verbose,
///
///   /// No logging - both stdout and stderr are suppressed.
///   /// Completely silent mode, useful when you don't want any server output.
///   silent,
/// }
/// ```
///
/// [configOverride] A function to override the server configuration. This function is called with
/// the default server configuration after it is loaded from the config/ directory
/// and before it is used to start the server. Use this to override particular
/// settings in the server configuration.
///
/// [databaseInterceptor] Optional interceptor that replaces the default database for each session.
/// See [Serverpod.databaseInterceptor] for more information.
///
/// [testGroupTagsOverride] By default Serverpod test tools tags the `withServerpod` test group with `"integration"`.
/// This is to provide a simple way to only run unit or integration tests.
/// This property allows this tag to be overridden to something else. Defaults to `['integration']`.
///
/// [experimentalFeatures] Optionally specify experimental features. See [Serverpod] for more information.
///
/// [serverDirectory] The server package directory `config/<runMode>.yaml`, `config/passwords.yaml`,
/// and `migrations/<module>/...` are resolved against. Defaults to
/// [Directory.current] at the time the test boots. Pass this when the test
/// isolate's cwd is not the server package root (e.g. running tests from a
/// workspace parent directory) so config and migrations are still loaded
/// from the right place.
@_ist.isTestGroup
void withServerpod(
  String testGroupName,
  _ist.TestClosure<TestEndpoints> testClosure, {
  bool? applyMigrations,
  _is.ServerpodConfig Function(_is.ServerpodConfig)? configOverride,
  _is.DatabaseInterceptor? databaseInterceptor,
  bool? enableSessionLogging,
  _is.ExperimentalFeatures? experimentalFeatures,
  _ist.RollbackDatabase? rollbackDatabase,
  String? runMode,
  _is.RuntimeParametersListBuilder? runtimeParametersBuilder,
  _idi.Directory? serverDirectory,
  _is.ServerpodLoggingMode? serverpodLoggingMode,
  Duration? serverpodStartTimeout,
  List<String>? testGroupTagsOverride,
  _ist.TestServerOutputMode? testServerOutputMode,
}) {
  _ist.buildWithServerpod<_InternalTestEndpoints>(
    testGroupName,
    _ist.TestServerpod(
      testEndpoints: _InternalTestEndpoints(),
      endpoints: Endpoints(),
      serializationManager: Protocol(),
      runMode: runMode,
      applyMigrations: applyMigrations,
      isDatabaseEnabled: true,
      serverpodLoggingMode: serverpodLoggingMode,
      testServerOutputMode: testServerOutputMode,
      serverDirectory: serverDirectory,
      experimentalFeatures: experimentalFeatures,
      configOverride: configOverride,
      runtimeParametersBuilder: runtimeParametersBuilder,
      databaseInterceptor: databaseInterceptor,
    ),
    maybeRollbackDatabase: rollbackDatabase,
    maybeEnableSessionLogging: enableSessionLogging,
    maybeTestGroupTagsOverride: testGroupTagsOverride,
    maybeServerpodStartTimeout: serverpodStartTimeout,
    maybeTestServerOutputMode: testServerOutputMode,
  )(testClosure);
}

class TestEndpoints {
  late final _EmailIdpEndpoint emailIdp;

  late final _JwtRefreshEndpoint jwtRefresh;

  late final _FieldnoteEndpoint fieldnote;

  late final _GreetingEndpoint greeting;
}

class _InternalTestEndpoints extends TestEndpoints
    implements _ist.InternalTestEndpoints {
  @override
  void initialize(
    _is.SerializationManager serializationManager,
    _is.EndpointDispatch endpoints,
  ) {
    emailIdp = _EmailIdpEndpoint(
      endpoints,
      serializationManager,
    );
    jwtRefresh = _JwtRefreshEndpoint(
      endpoints,
      serializationManager,
    );
    fieldnote = _FieldnoteEndpoint(
      endpoints,
      serializationManager,
    );
    greeting = _GreetingEndpoint(
      endpoints,
      serializationManager,
    );
  }
}

class _EmailIdpEndpoint {
  _EmailIdpEndpoint(
    this._endpointDispatch,
    this._serializationManager,
  );

  final _is.EndpointDispatch _endpointDispatch;

  final _is.SerializationManager _serializationManager;

  _ida.Future<_iacs.AuthSuccess> login(
    _ist.TestSessionBuilder sessionBuilder, {
    required String email,
    required String password,
  }) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'emailIdp',
            method: 'login',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'emailIdp',
          methodName: 'login',
          parameters: _ist.testObjectToJson({
            'email': email,
            'password': password,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<_iacs.AuthSuccess>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_is.UuidValue> startRegistration(
    _ist.TestSessionBuilder sessionBuilder, {
    required String email,
  }) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'emailIdp',
            method: 'startRegistration',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'emailIdp',
          methodName: 'startRegistration',
          parameters: _ist.testObjectToJson({'email': email}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<_is.UuidValue>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<String> verifyRegistrationCode(
    _ist.TestSessionBuilder sessionBuilder, {
    required _is.UuidValue accountRequestId,
    required String verificationCode,
  }) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'emailIdp',
            method: 'verifyRegistrationCode',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'emailIdp',
          methodName: 'verifyRegistrationCode',
          parameters: _ist.testObjectToJson({
            'accountRequestId': accountRequestId,
            'verificationCode': verificationCode,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<String>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_iacs.AuthSuccess> finishRegistration(
    _ist.TestSessionBuilder sessionBuilder, {
    required String registrationToken,
    required String password,
  }) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'emailIdp',
            method: 'finishRegistration',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'emailIdp',
          methodName: 'finishRegistration',
          parameters: _ist.testObjectToJson({
            'registrationToken': registrationToken,
            'password': password,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<_iacs.AuthSuccess>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_is.UuidValue> startPasswordReset(
    _ist.TestSessionBuilder sessionBuilder, {
    required String email,
  }) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'emailIdp',
            method: 'startPasswordReset',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'emailIdp',
          methodName: 'startPasswordReset',
          parameters: _ist.testObjectToJson({'email': email}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<_is.UuidValue>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<String> verifyPasswordResetCode(
    _ist.TestSessionBuilder sessionBuilder, {
    required _is.UuidValue passwordResetRequestId,
    required String verificationCode,
  }) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'emailIdp',
            method: 'verifyPasswordResetCode',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'emailIdp',
          methodName: 'verifyPasswordResetCode',
          parameters: _ist.testObjectToJson({
            'passwordResetRequestId': passwordResetRequestId,
            'verificationCode': verificationCode,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<String>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<void> finishPasswordReset(
    _ist.TestSessionBuilder sessionBuilder, {
    required String finishPasswordResetToken,
    required String newPassword,
  }) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'emailIdp',
            method: 'finishPasswordReset',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'emailIdp',
          methodName: 'finishPasswordReset',
          parameters: _ist.testObjectToJson({
            'finishPasswordResetToken': finishPasswordResetToken,
            'newPassword': newPassword,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<void>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<bool> hasAccount(_ist.TestSessionBuilder sessionBuilder) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'emailIdp',
            method: 'hasAccount',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'emailIdp',
          methodName: 'hasAccount',
          parameters: _ist.testObjectToJson({}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<bool>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }
}

class _JwtRefreshEndpoint {
  _JwtRefreshEndpoint(
    this._endpointDispatch,
    this._serializationManager,
  );

  final _is.EndpointDispatch _endpointDispatch;

  final _is.SerializationManager _serializationManager;

  _ida.Future<_iacs.AuthSuccess> refreshAccessToken(
    _ist.TestSessionBuilder sessionBuilder, {
    String? refreshToken,
  }) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'jwtRefresh',
            method: 'refreshAccessToken',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'jwtRefresh',
          methodName: 'refreshAccessToken',
          parameters: _ist.testObjectToJson({'refreshToken': refreshToken}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<_iacs.AuthSuccess>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }
}

class _FieldnoteEndpoint {
  _FieldnoteEndpoint(
    this._endpointDispatch,
    this._serializationManager,
  );

  final _is.EndpointDispatch _endpointDispatch;

  final _is.SerializationManager _serializationManager;

  _ida.Future<_iwhpwl59.FieldnoteUserProfile?> getMyProfile(
    _ist.TestSessionBuilder sessionBuilder,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'fieldnote',
            method: 'getMyProfile',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'fieldnote',
          methodName: 'getMyProfile',
          parameters: _ist.testObjectToJson({}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<_iwhpwl59.FieldnoteUserProfile?>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_id1317s7.LegalConsent?> getMyLegalConsent(
    _ist.TestSessionBuilder sessionBuilder,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'fieldnote',
            method: 'getMyLegalConsent',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'fieldnote',
          methodName: 'getMyLegalConsent',
          parameters: _ist.testObjectToJson({}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<_id1317s7.LegalConsent?>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_id1317s7.LegalConsent> acceptLegalConsent(
    _ist.TestSessionBuilder sessionBuilder,
    bool locationConsent,
    bool aiProcessingConsent,
    bool evidenceSharingConsent,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'fieldnote',
            method: 'acceptLegalConsent',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'fieldnote',
          methodName: 'acceptLegalConsent',
          parameters: _ist.testObjectToJson({
            'locationConsent': locationConsent,
            'aiProcessingConsent': aiProcessingConsent,
            'evidenceSharingConsent': evidenceSharingConsent,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<_id1317s7.LegalConsent>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_i3103swi.TrustCenterSummary> getTrustCenter(
    _ist.TestSessionBuilder sessionBuilder,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'fieldnote',
            method: 'getTrustCenter',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'fieldnote',
          methodName: 'getTrustCenter',
          parameters: _ist.testObjectToJson({}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<_i3103swi.TrustCenterSummary>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<String> exportMyData(
    _ist.TestSessionBuilder sessionBuilder,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'fieldnote',
            method: 'exportMyData',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'fieldnote',
          methodName: 'exportMyData',
          parameters: _ist.testObjectToJson({}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<String>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_i3lt536m.AuditEvent> requestAccountDeletion(
    _ist.TestSessionBuilder sessionBuilder,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'fieldnote',
            method: 'requestAccountDeletion',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'fieldnote',
          methodName: 'requestAccountDeletion',
          parameters: _ist.testObjectToJson({}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<_i3lt536m.AuditEvent>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_iwhpwl59.FieldnoteUserProfile> completeSponsorProfile(
    _ist.TestSessionBuilder sessionBuilder,
    String displayName,
    String sponsorType,
    String? organizationName,
    String city,
    String? cityPlaceId,
    List<String> interests,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'fieldnote',
            method: 'completeSponsorProfile',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'fieldnote',
          methodName: 'completeSponsorProfile',
          parameters: _ist.testObjectToJson({
            'displayName': displayName,
            'sponsorType': sponsorType,
            'organizationName': organizationName,
            'city': city,
            'cityPlaceId': cityPlaceId,
            'interests': interests,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<_iwhpwl59.FieldnoteUserProfile>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_iwhpwl59.FieldnoteUserProfile> completeVolunteerProfile(
    _ist.TestSessionBuilder sessionBuilder,
    String displayName,
    String city,
    List<String> interests,
    List<String> skills,
    bool isAvailable,
    bool availableToday,
    List<int> weekdays,
    int startMinutes,
    int endMinutes,
    double maximumTravelKm,
    double? latitude,
    double? longitude,
    String locationLabel,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'fieldnote',
            method: 'completeVolunteerProfile',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'fieldnote',
          methodName: 'completeVolunteerProfile',
          parameters: _ist.testObjectToJson({
            'displayName': displayName,
            'city': city,
            'interests': interests,
            'skills': skills,
            'isAvailable': isAvailable,
            'availableToday': availableToday,
            'weekdays': weekdays,
            'startMinutes': startMinutes,
            'endMinutes': endMinutes,
            'maximumTravelKm': maximumTravelKm,
            'latitude': latitude,
            'longitude': longitude,
            'locationLabel': locationLabel,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<_iwhpwl59.FieldnoteUserProfile>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_iwhpwl59.FieldnoteUserProfile> updateMyProfile(
    _ist.TestSessionBuilder sessionBuilder,
    String displayName,
    String? sponsorType,
    String? organizationName,
    String city,
    String? cityPlaceId,
    List<String> interests,
    List<String> skills,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'fieldnote',
            method: 'updateMyProfile',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'fieldnote',
          methodName: 'updateMyProfile',
          parameters: _ist.testObjectToJson({
            'displayName': displayName,
            'sponsorType': sponsorType,
            'organizationName': organizationName,
            'city': city,
            'cityPlaceId': cityPlaceId,
            'interests': interests,
            'skills': skills,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<_iwhpwl59.FieldnoteUserProfile>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_i5cnujyk.VolunteerAvailability?> getMyAvailability(
    _ist.TestSessionBuilder sessionBuilder,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'fieldnote',
            method: 'getMyAvailability',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'fieldnote',
          methodName: 'getMyAvailability',
          parameters: _ist.testObjectToJson({}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<_i5cnujyk.VolunteerAvailability?>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_i5cnujyk.VolunteerAvailability> updateAvailability(
    _ist.TestSessionBuilder sessionBuilder,
    bool isAvailable,
    bool availableToday,
    List<int> weekdays,
    int startMinutes,
    int endMinutes,
    double maximumTravelKm,
    double? latitude,
    double? longitude,
    String locationLabel,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'fieldnote',
            method: 'updateAvailability',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'fieldnote',
          methodName: 'updateAvailability',
          parameters: _ist.testObjectToJson({
            'isAvailable': isAvailable,
            'availableToday': availableToday,
            'weekdays': weekdays,
            'startMinutes': startMinutes,
            'endMinutes': endMinutes,
            'maximumTravelKm': maximumTravelKm,
            'latitude': latitude,
            'longitude': longitude,
            'locationLabel': locationLabel,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<_i5cnujyk.VolunteerAvailability>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<String> transcribeDictation(
    _ist.TestSessionBuilder sessionBuilder,
    _idt.ByteData audio,
    String fileName,
    String mimeType,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'fieldnote',
            method: 'transcribeDictation',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'fieldnote',
          methodName: 'transcribeDictation',
          parameters: _ist.testObjectToJson({
            'audio': audio,
            'fileName': fileName,
            'mimeType': mimeType,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<String>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_imistozd.CampaignProposal> proposeCampaign(
    _ist.TestSessionBuilder sessionBuilder,
    String prompt,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'fieldnote',
            method: 'proposeCampaign',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'fieldnote',
          methodName: 'proposeCampaign',
          parameters: _ist.testObjectToJson({'prompt': prompt}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<_imistozd.CampaignProposal>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_iuzdi22u.Campaign> createCampaignFromProposal(
    _ist.TestSessionBuilder sessionBuilder,
    _imistozd.CampaignProposal proposal,
    double latitude,
    double longitude,
    String? locationName,
    double? geofenceMeters,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'fieldnote',
            method: 'createCampaignFromProposal',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'fieldnote',
          methodName: 'createCampaignFromProposal',
          parameters: _ist.testObjectToJson({
            'proposal': proposal,
            'latitude': latitude,
            'longitude': longitude,
            'locationName': locationName,
            'geofenceMeters': geofenceMeters,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<_iuzdi22u.Campaign>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<List<_iuzdi22u.Campaign>> listCampaigns(
    _ist.TestSessionBuilder sessionBuilder,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'fieldnote',
            method: 'listCampaigns',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'fieldnote',
          methodName: 'listCampaigns',
          parameters: _ist.testObjectToJson({}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<List<_iuzdi22u.Campaign>>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<List<_iuzdi22u.Campaign>> listMyCreatedCampaigns(
    _ist.TestSessionBuilder sessionBuilder,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'fieldnote',
            method: 'listMyCreatedCampaigns',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'fieldnote',
          methodName: 'listMyCreatedCampaigns',
          parameters: _ist.testObjectToJson({}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<List<_iuzdi22u.Campaign>>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<bool> isCitySearchAvailable(
    _ist.TestSessionBuilder sessionBuilder,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'fieldnote',
            method: 'isCitySearchAvailable',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'fieldnote',
          methodName: 'isCitySearchAvailable',
          parameters: _ist.testObjectToJson({}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<bool>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<List<_i18eudx8.PlaceSuggestion>> searchCities(
    _ist.TestSessionBuilder sessionBuilder,
    String query,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'fieldnote',
            method: 'searchCities',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'fieldnote',
          methodName: 'searchCities',
          parameters: _ist.testObjectToJson({'query': query}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<List<_i18eudx8.PlaceSuggestion>>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<List<_i18eudx8.PlaceSuggestion>> searchSponsorLocations(
    _ist.TestSessionBuilder sessionBuilder,
    String query,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'fieldnote',
            method: 'searchSponsorLocations',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'fieldnote',
          methodName: 'searchSponsorLocations',
          parameters: _ist.testObjectToJson({'query': query}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<List<_i18eudx8.PlaceSuggestion>>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<bool> isPlaceSearchAvailable(
    _ist.TestSessionBuilder sessionBuilder,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'fieldnote',
            method: 'isPlaceSearchAvailable',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'fieldnote',
          methodName: 'isPlaceSearchAvailable',
          parameters: _ist.testObjectToJson({}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<bool>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<List<_i18eudx8.PlaceSuggestion>> searchPlaces(
    _ist.TestSessionBuilder sessionBuilder,
    String query,
    double? biasLatitude,
    double? biasLongitude,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'fieldnote',
            method: 'searchPlaces',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'fieldnote',
          methodName: 'searchPlaces',
          parameters: _ist.testObjectToJson({
            'query': query,
            'biasLatitude': biasLatitude,
            'biasLongitude': biasLongitude,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<List<_i18eudx8.PlaceSuggestion>>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_i7kx1qhs.ResolvedPlace> resolvePlace(
    _ist.TestSessionBuilder sessionBuilder,
    String placeId,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'fieldnote',
            method: 'resolvePlace',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'fieldnote',
          methodName: 'resolvePlace',
          parameters: _ist.testObjectToJson({'placeId': placeId}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<_i7kx1qhs.ResolvedPlace>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_i7kx1qhs.ResolvedPlace?> describeCoordinates(
    _ist.TestSessionBuilder sessionBuilder,
    double latitude,
    double longitude,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'fieldnote',
            method: 'describeCoordinates',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'fieldnote',
          methodName: 'describeCoordinates',
          parameters: _ist.testObjectToJson({
            'latitude': latitude,
            'longitude': longitude,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<_i7kx1qhs.ResolvedPlace?>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_i7sn891l.CampaignReach> previewCampaignReach(
    _ist.TestSessionBuilder sessionBuilder,
    double latitude,
    double longitude,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'fieldnote',
            method: 'previewCampaignReach',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'fieldnote',
          methodName: 'previewCampaignReach',
          parameters: _ist.testObjectToJson({
            'latitude': latitude,
            'longitude': longitude,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<_i7sn891l.CampaignReach>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_idftstcm.CampaignMapOverview> getCampaignMap(
    _ist.TestSessionBuilder sessionBuilder,
    int campaignId,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'fieldnote',
            method: 'getCampaignMap',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'fieldnote',
          methodName: 'getCampaignMap',
          parameters: _ist.testObjectToJson({'campaignId': campaignId}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<_idftstcm.CampaignMapOverview>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_i6ia46xm.RazorpayCheckoutOrder> createRazorpayOrder(
    _ist.TestSessionBuilder sessionBuilder,
    int campaignId,
    double amount,
    String? message,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'fieldnote',
            method: 'createRazorpayOrder',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'fieldnote',
          methodName: 'createRazorpayOrder',
          parameters: _ist.testObjectToJson({
            'campaignId': campaignId,
            'amount': amount,
            'message': message,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<_i6ia46xm.RazorpayCheckoutOrder>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_iwnubjux.Sponsorship> verifyRazorpayPayment(
    _ist.TestSessionBuilder sessionBuilder,
    int sponsorshipId,
    String orderId,
    String paymentId,
    String signature,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'fieldnote',
            method: 'verifyRazorpayPayment',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'fieldnote',
          methodName: 'verifyRazorpayPayment',
          parameters: _ist.testObjectToJson({
            'sponsorshipId': sponsorshipId,
            'orderId': orderId,
            'paymentId': paymentId,
            'signature': signature,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<_iwnubjux.Sponsorship>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_iwnubjux.Sponsorship> recordRazorpayFailure(
    _ist.TestSessionBuilder sessionBuilder,
    int sponsorshipId,
    String reason,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'fieldnote',
            method: 'recordRazorpayFailure',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'fieldnote',
          methodName: 'recordRazorpayFailure',
          parameters: _ist.testObjectToJson({
            'sponsorshipId': sponsorshipId,
            'reason': reason,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<_iwnubjux.Sponsorship>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<List<_iwnubjux.Sponsorship>> listMySponsorships(
    _ist.TestSessionBuilder sessionBuilder,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'fieldnote',
            method: 'listMySponsorships',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'fieldnote',
          methodName: 'listMySponsorships',
          parameters: _ist.testObjectToJson({}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<List<_iwnubjux.Sponsorship>>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<List<_i3ipc266.CampaignMatch>> getCampaignMatches(
    _ist.TestSessionBuilder sessionBuilder,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'fieldnote',
            method: 'getCampaignMatches',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'fieldnote',
          methodName: 'getCampaignMatches',
          parameters: _ist.testObjectToJson({}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<List<_i3ipc266.CampaignMatch>>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_i363uv3e.CampaignParticipation> joinCampaign(
    _ist.TestSessionBuilder sessionBuilder,
    int campaignId,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'fieldnote',
            method: 'joinCampaign',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'fieldnote',
          methodName: 'joinCampaign',
          parameters: _ist.testObjectToJson({'campaignId': campaignId}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<_i363uv3e.CampaignParticipation>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<List<_i363uv3e.CampaignParticipation>> listMyParticipations(
    _ist.TestSessionBuilder sessionBuilder,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'fieldnote',
            method: 'listMyParticipations',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'fieldnote',
          methodName: 'listMyParticipations',
          parameters: _ist.testObjectToJson({}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<List<_i363uv3e.CampaignParticipation>>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_i363uv3e.CampaignParticipation> checkIn(
    _ist.TestSessionBuilder sessionBuilder,
    int participationId,
    double latitude,
    double longitude,
    double accuracyMeters,
    bool deviceReportedMock,
    bool explicitDemo,
    DateTime capturedAt,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'fieldnote',
            method: 'checkIn',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'fieldnote',
          methodName: 'checkIn',
          parameters: _ist.testObjectToJson({
            'participationId': participationId,
            'latitude': latitude,
            'longitude': longitude,
            'accuracyMeters': accuracyMeters,
            'deviceReportedMock': deviceReportedMock,
            'explicitDemo': explicitDemo,
            'capturedAt': capturedAt,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<_i363uv3e.CampaignParticipation>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_i7asx8cy.CompletionProposal> analyzeCompletion(
    _ist.TestSessionBuilder sessionBuilder,
    int participationId,
    String note,
    _idt.ByteData? photograph,
    String? photographMimeType,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'fieldnote',
            method: 'analyzeCompletion',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'fieldnote',
          methodName: 'analyzeCompletion',
          parameters: _ist.testObjectToJson({
            'participationId': participationId,
            'note': note,
            'photograph': photograph,
            'photographMimeType': photographMimeType,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<_i7asx8cy.CompletionProposal>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<String> getEvidenceUploadDescription(
    _ist.TestSessionBuilder sessionBuilder,
    int participationId,
    String extension,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'fieldnote',
            method: 'getEvidenceUploadDescription',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'fieldnote',
          methodName: 'getEvidenceUploadDescription',
          parameters: _ist.testObjectToJson({
            'participationId': participationId,
            'extension': extension,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<String>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_iwy2dzi1.CompletionEvidence> completeParticipation(
    _ist.TestSessionBuilder sessionBuilder,
    int participationId,
    String photoExtension,
    String originalNote,
    String confirmedSummary,
    List<String> structuredResults,
    double latitude,
    double longitude,
    double accuracyMeters,
    bool deviceReportedMock,
    bool explicitDemo,
    DateTime capturedAt,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'fieldnote',
            method: 'completeParticipation',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'fieldnote',
          methodName: 'completeParticipation',
          parameters: _ist.testObjectToJson({
            'participationId': participationId,
            'photoExtension': photoExtension,
            'originalNote': originalNote,
            'confirmedSummary': confirmedSummary,
            'structuredResults': structuredResults,
            'latitude': latitude,
            'longitude': longitude,
            'accuracyMeters': accuracyMeters,
            'deviceReportedMock': deviceReportedMock,
            'explicitDemo': explicitDemo,
            'capturedAt': capturedAt,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<_iwy2dzi1.CompletionEvidence>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<String> getEvidenceDownloadUrl(
    _ist.TestSessionBuilder sessionBuilder,
    int evidenceId,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'fieldnote',
            method: 'getEvidenceDownloadUrl',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'fieldnote',
          methodName: 'getEvidenceDownloadUrl',
          parameters: _ist.testObjectToJson({'evidenceId': evidenceId}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<String>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_igdptf07.ImpactSummary> getImpact(
    _ist.TestSessionBuilder sessionBuilder,
    int campaignId,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'fieldnote',
            method: 'getImpact',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'fieldnote',
          methodName: 'getImpact',
          parameters: _ist.testObjectToJson({'campaignId': campaignId}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<_igdptf07.ImpactSummary>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_id4uw0jw.CampaignPost> createCampaignPost(
    _ist.TestSessionBuilder sessionBuilder,
    int campaignId,
    String title,
    String body,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'fieldnote',
            method: 'createCampaignPost',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'fieldnote',
          methodName: 'createCampaignPost',
          parameters: _ist.testObjectToJson({
            'campaignId': campaignId,
            'title': title,
            'body': body,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<_id4uw0jw.CampaignPost>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<List<_id4uw0jw.CampaignPost>> listCampaignPosts(
    _ist.TestSessionBuilder sessionBuilder,
    int campaignId,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'fieldnote',
            method: 'listCampaignPosts',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'fieldnote',
          methodName: 'listCampaignPosts',
          parameters: _ist.testObjectToJson({'campaignId': campaignId}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<List<_id4uw0jw.CampaignPost>>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Stream<_ijl5nqyg.CampaignLiveUpdate> watchCampaign(
    _ist.TestSessionBuilder sessionBuilder,
    int campaignId,
  ) {
    var _localTestStreamManager =
        _ist.TestStreamManager<_ijl5nqyg.CampaignLiveUpdate>();
    _ist.callStreamFunctionAndHandleExceptions(
      () async {
        var _localUniqueSession =
            (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
              endpoint: 'fieldnote',
              method: 'watchCampaign',
            );
        var _localCallContext = await _endpointDispatch
            .getMethodStreamCallContext(
              createSessionCallback: (_) => _localUniqueSession,
              endpointPath: 'fieldnote',
              methodName: 'watchCampaign',
              arguments: {'campaignId': campaignId},
              requestedInputStreams: [],
              serializationManager: _serializationManager,
            );
        await _localTestStreamManager.callStreamMethod(
          _localCallContext,
          _localUniqueSession,
          {},
        );
      },
      _localTestStreamManager.outputStreamController,
    );
    return _localTestStreamManager.outputStreamController.stream;
  }
}

class _GreetingEndpoint {
  _GreetingEndpoint(
    this._endpointDispatch,
    this._serializationManager,
  );

  final _is.EndpointDispatch _endpointDispatch;

  final _is.SerializationManager _serializationManager;

  _ida.Future<_iah5jf45.Greeting> hello(
    _ist.TestSessionBuilder sessionBuilder,
    String name,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'greeting',
            method: 'hello',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'greeting',
          methodName: 'hello',
          parameters: _ist.testObjectToJson({'name': name}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<_iah5jf45.Greeting>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }
}
