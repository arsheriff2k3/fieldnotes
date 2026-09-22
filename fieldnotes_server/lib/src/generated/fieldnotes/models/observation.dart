/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod/serverpod.dart' as _is;
import '../../fieldnotes/models/ai_confidence.dart' as _i364pgf2;
import '../../fieldnotes/models/observation_condition.dart' as _iuuy06sg;
import '../../fieldnotes/models/review_state.dart' as _i926tkng;

abstract class Observation
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  Observation._({
    this.id,
    required this.clientId,
    required this.campaignId,
    this.assetId,
    required this.observerAuthUserId,
    required this.capturedAt,
    required this.latitude,
    required this.longitude,
    required this.accuracyMeters,
    required this.originalNote,
    this.species,
    required this.condition,
    required this.issues,
    required this.recommendedFollowUp,
    required this.aiConfidence,
    required this.aiRationale,
    required this.reviewState,
    this.possibleDuplicateAssetId,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Observation({
    int? id,
    required String clientId,
    required int campaignId,
    int? assetId,
    required _is.UuidValue observerAuthUserId,
    required DateTime capturedAt,
    required double latitude,
    required double longitude,
    required double accuracyMeters,
    required String originalNote,
    String? species,
    required _iuuy06sg.ObservationCondition condition,
    required String issues,
    required String recommendedFollowUp,
    required _i364pgf2.AiConfidence aiConfidence,
    required String aiRationale,
    required _i926tkng.ReviewState reviewState,
    int? possibleDuplicateAssetId,
    DateTime? createdAt,
  }) = _ObservationImpl;

  factory Observation.fromJson(Map<String, dynamic> jsonSerialization) {
    return Observation(
      id: jsonSerialization['id'] as int?,
      clientId: jsonSerialization['clientId'] as String,
      campaignId: jsonSerialization['campaignId'] as int,
      assetId: jsonSerialization['assetId'] as int?,
      observerAuthUserId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['observerAuthUserId'],
      ),
      capturedAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['capturedAt'],
      ),
      latitude: (jsonSerialization['latitude'] as num).toDouble(),
      longitude: (jsonSerialization['longitude'] as num).toDouble(),
      accuracyMeters: (jsonSerialization['accuracyMeters'] as num).toDouble(),
      originalNote: jsonSerialization['originalNote'] as String,
      species: jsonSerialization['species'] as String?,
      condition: _iuuy06sg.ObservationCondition.fromJson(
        (jsonSerialization['condition'] as String),
      ),
      issues: jsonSerialization['issues'] as String,
      recommendedFollowUp: jsonSerialization['recommendedFollowUp'] as String,
      aiConfidence: _i364pgf2.AiConfidence.fromJson(
        (jsonSerialization['aiConfidence'] as String),
      ),
      aiRationale: jsonSerialization['aiRationale'] as String,
      reviewState: _i926tkng.ReviewState.fromJson(
        (jsonSerialization['reviewState'] as String),
      ),
      possibleDuplicateAssetId:
          jsonSerialization['possibleDuplicateAssetId'] as int?,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  static final t = ObservationTable();

  static const db = ObservationRepository._();

  @override
  int? id;

  String clientId;

  int campaignId;

  int? assetId;

  _is.UuidValue observerAuthUserId;

  DateTime capturedAt;

  double latitude;

  double longitude;

  double accuracyMeters;

  String originalNote;

  String? species;

  _iuuy06sg.ObservationCondition condition;

  String issues;

  String recommendedFollowUp;

  _i364pgf2.AiConfidence aiConfidence;

  String aiRationale;

  _i926tkng.ReviewState reviewState;

  int? possibleDuplicateAssetId;

  DateTime createdAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [Observation]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  Observation copyWith({
    int? id,
    String? clientId,
    int? campaignId,
    int? assetId,
    _is.UuidValue? observerAuthUserId,
    DateTime? capturedAt,
    double? latitude,
    double? longitude,
    double? accuracyMeters,
    String? originalNote,
    String? species,
    _iuuy06sg.ObservationCondition? condition,
    String? issues,
    String? recommendedFollowUp,
    _i364pgf2.AiConfidence? aiConfidence,
    String? aiRationale,
    _i926tkng.ReviewState? reviewState,
    int? possibleDuplicateAssetId,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Observation',
      if (id != null) 'id': id,
      'clientId': clientId,
      'campaignId': campaignId,
      if (assetId != null) 'assetId': assetId,
      'observerAuthUserId': observerAuthUserId.toJson(),
      'capturedAt': capturedAt.toJson(),
      'latitude': latitude,
      'longitude': longitude,
      'accuracyMeters': accuracyMeters,
      'originalNote': originalNote,
      if (species != null) 'species': species,
      'condition': condition.toJson(),
      'issues': issues,
      'recommendedFollowUp': recommendedFollowUp,
      'aiConfidence': aiConfidence.toJson(),
      'aiRationale': aiRationale,
      'reviewState': reviewState.toJson(),
      if (possibleDuplicateAssetId != null)
        'possibleDuplicateAssetId': possibleDuplicateAssetId,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Observation',
      if (id != null) 'id': id,
      'clientId': clientId,
      'campaignId': campaignId,
      if (assetId != null) 'assetId': assetId,
      'observerAuthUserId': observerAuthUserId.toJson(),
      'capturedAt': capturedAt.toJson(),
      'latitude': latitude,
      'longitude': longitude,
      'accuracyMeters': accuracyMeters,
      'originalNote': originalNote,
      if (species != null) 'species': species,
      'condition': condition.toJson(),
      'issues': issues,
      'recommendedFollowUp': recommendedFollowUp,
      'aiConfidence': aiConfidence.toJson(),
      'aiRationale': aiRationale,
      'reviewState': reviewState.toJson(),
      if (possibleDuplicateAssetId != null)
        'possibleDuplicateAssetId': possibleDuplicateAssetId,
      'createdAt': createdAt.toJson(),
    };
  }

  static ObservationInclude include() {
    return ObservationInclude._();
  }

  static ObservationIncludeList includeList({
    _is.WhereExpressionBuilder<ObservationTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ObservationTable>? orderBy,
    _is.OrderByListBuilder<ObservationTable>? orderByList,
    ObservationInclude? include,
  }) {
    return ObservationIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Observation.t),
      orderByList: orderByList?.call(Observation.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ObservationImpl extends Observation {
  _ObservationImpl({
    int? id,
    required String clientId,
    required int campaignId,
    int? assetId,
    required _is.UuidValue observerAuthUserId,
    required DateTime capturedAt,
    required double latitude,
    required double longitude,
    required double accuracyMeters,
    required String originalNote,
    String? species,
    required _iuuy06sg.ObservationCondition condition,
    required String issues,
    required String recommendedFollowUp,
    required _i364pgf2.AiConfidence aiConfidence,
    required String aiRationale,
    required _i926tkng.ReviewState reviewState,
    int? possibleDuplicateAssetId,
    DateTime? createdAt,
  }) : super._(
         id: id,
         clientId: clientId,
         campaignId: campaignId,
         assetId: assetId,
         observerAuthUserId: observerAuthUserId,
         capturedAt: capturedAt,
         latitude: latitude,
         longitude: longitude,
         accuracyMeters: accuracyMeters,
         originalNote: originalNote,
         species: species,
         condition: condition,
         issues: issues,
         recommendedFollowUp: recommendedFollowUp,
         aiConfidence: aiConfidence,
         aiRationale: aiRationale,
         reviewState: reviewState,
         possibleDuplicateAssetId: possibleDuplicateAssetId,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [Observation]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  Observation copyWith({
    Object? id = _Undefined,
    String? clientId,
    int? campaignId,
    Object? assetId = _Undefined,
    _is.UuidValue? observerAuthUserId,
    DateTime? capturedAt,
    double? latitude,
    double? longitude,
    double? accuracyMeters,
    String? originalNote,
    Object? species = _Undefined,
    _iuuy06sg.ObservationCondition? condition,
    String? issues,
    String? recommendedFollowUp,
    _i364pgf2.AiConfidence? aiConfidence,
    String? aiRationale,
    _i926tkng.ReviewState? reviewState,
    Object? possibleDuplicateAssetId = _Undefined,
    DateTime? createdAt,
  }) {
    return Observation(
      id: id is int? ? id : this.id,
      clientId: clientId ?? this.clientId,
      campaignId: campaignId ?? this.campaignId,
      assetId: assetId is int? ? assetId : this.assetId,
      observerAuthUserId: observerAuthUserId ?? this.observerAuthUserId,
      capturedAt: capturedAt ?? this.capturedAt,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      accuracyMeters: accuracyMeters ?? this.accuracyMeters,
      originalNote: originalNote ?? this.originalNote,
      species: species is String? ? species : this.species,
      condition: condition ?? this.condition,
      issues: issues ?? this.issues,
      recommendedFollowUp: recommendedFollowUp ?? this.recommendedFollowUp,
      aiConfidence: aiConfidence ?? this.aiConfidence,
      aiRationale: aiRationale ?? this.aiRationale,
      reviewState: reviewState ?? this.reviewState,
      possibleDuplicateAssetId: possibleDuplicateAssetId is int?
          ? possibleDuplicateAssetId
          : this.possibleDuplicateAssetId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class ObservationUpdateTable extends _is.UpdateTable<ObservationTable> {
  ObservationUpdateTable(super.table);

  _is.ColumnValue<String, String> clientId(String value) => _is.ColumnValue(
    table.clientId,
    value,
  );

  _is.ColumnValue<int, int> campaignId(int value) => _is.ColumnValue(
    table.campaignId,
    value,
  );

  _is.ColumnValue<int, int> assetId(int? value) => _is.ColumnValue(
    table.assetId,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> observerAuthUserId(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.observerAuthUserId,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> capturedAt(DateTime value) =>
      _is.ColumnValue(
        table.capturedAt,
        value,
      );

  _is.ColumnValue<double, double> latitude(double value) => _is.ColumnValue(
    table.latitude,
    value,
  );

  _is.ColumnValue<double, double> longitude(double value) => _is.ColumnValue(
    table.longitude,
    value,
  );

  _is.ColumnValue<double, double> accuracyMeters(double value) =>
      _is.ColumnValue(
        table.accuracyMeters,
        value,
      );

  _is.ColumnValue<String, String> originalNote(String value) => _is.ColumnValue(
    table.originalNote,
    value,
  );

  _is.ColumnValue<String, String> species(String? value) => _is.ColumnValue(
    table.species,
    value,
  );

  _is.ColumnValue<
    _iuuy06sg.ObservationCondition,
    _iuuy06sg.ObservationCondition
  >
  condition(_iuuy06sg.ObservationCondition value) => _is.ColumnValue(
    table.condition,
    value,
  );

  _is.ColumnValue<String, String> issues(String value) => _is.ColumnValue(
    table.issues,
    value,
  );

  _is.ColumnValue<String, String> recommendedFollowUp(String value) =>
      _is.ColumnValue(
        table.recommendedFollowUp,
        value,
      );

  _is.ColumnValue<_i364pgf2.AiConfidence, _i364pgf2.AiConfidence> aiConfidence(
    _i364pgf2.AiConfidence value,
  ) => _is.ColumnValue(
    table.aiConfidence,
    value,
  );

  _is.ColumnValue<String, String> aiRationale(String value) => _is.ColumnValue(
    table.aiRationale,
    value,
  );

  _is.ColumnValue<_i926tkng.ReviewState, _i926tkng.ReviewState> reviewState(
    _i926tkng.ReviewState value,
  ) => _is.ColumnValue(
    table.reviewState,
    value,
  );

  _is.ColumnValue<int, int> possibleDuplicateAssetId(int? value) =>
      _is.ColumnValue(
        table.possibleDuplicateAssetId,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );
}

class ObservationTable extends _is.Table<int?> {
  ObservationTable({super.tableRelation})
    : super(tableName: 'fieldnote_observation') {
    updateTable = ObservationUpdateTable(this);
    clientId = _is.ColumnString(
      'clientId',
      this,
    );
    campaignId = _is.ColumnInt(
      'campaignId',
      this,
    );
    assetId = _is.ColumnInt(
      'assetId',
      this,
    );
    observerAuthUserId = _is.ColumnUuid(
      'observerAuthUserId',
      this,
    );
    capturedAt = _is.ColumnDateTime(
      'capturedAt',
      this,
    );
    latitude = _is.ColumnDouble(
      'latitude',
      this,
    );
    longitude = _is.ColumnDouble(
      'longitude',
      this,
    );
    accuracyMeters = _is.ColumnDouble(
      'accuracyMeters',
      this,
    );
    originalNote = _is.ColumnString(
      'originalNote',
      this,
    );
    species = _is.ColumnString(
      'species',
      this,
    );
    condition = _is.ColumnEnum(
      'condition',
      this,
      _is.EnumSerialization.byName,
    );
    issues = _is.ColumnString(
      'issues',
      this,
    );
    recommendedFollowUp = _is.ColumnString(
      'recommendedFollowUp',
      this,
    );
    aiConfidence = _is.ColumnEnum(
      'aiConfidence',
      this,
      _is.EnumSerialization.byName,
    );
    aiRationale = _is.ColumnString(
      'aiRationale',
      this,
    );
    reviewState = _is.ColumnEnum(
      'reviewState',
      this,
      _is.EnumSerialization.byName,
    );
    possibleDuplicateAssetId = _is.ColumnInt(
      'possibleDuplicateAssetId',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
      hasDefault: true,
    );
  }

  late final ObservationUpdateTable updateTable;

  late final _is.ColumnString clientId;

  late final _is.ColumnInt campaignId;

  late final _is.ColumnInt assetId;

  late final _is.ColumnUuid observerAuthUserId;

  late final _is.ColumnDateTime capturedAt;

  late final _is.ColumnDouble latitude;

  late final _is.ColumnDouble longitude;

  late final _is.ColumnDouble accuracyMeters;

  late final _is.ColumnString originalNote;

  late final _is.ColumnString species;

  late final _is.ColumnEnum<_iuuy06sg.ObservationCondition> condition;

  late final _is.ColumnString issues;

  late final _is.ColumnString recommendedFollowUp;

  late final _is.ColumnEnum<_i364pgf2.AiConfidence> aiConfidence;

  late final _is.ColumnString aiRationale;

  late final _is.ColumnEnum<_i926tkng.ReviewState> reviewState;

  late final _is.ColumnInt possibleDuplicateAssetId;

  late final _is.ColumnDateTime createdAt;

  @override
  List<_is.Column> get columns => [
    id,
    clientId,
    campaignId,
    assetId,
    observerAuthUserId,
    capturedAt,
    latitude,
    longitude,
    accuracyMeters,
    originalNote,
    species,
    condition,
    issues,
    recommendedFollowUp,
    aiConfidence,
    aiRationale,
    reviewState,
    possibleDuplicateAssetId,
    createdAt,
  ];
}

class ObservationInclude extends _is.IncludeObject {
  ObservationInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => Observation.t;
}

class ObservationIncludeList extends _is.IncludeList {
  ObservationIncludeList._({
    _is.WhereExpressionBuilder<ObservationTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Observation.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => Observation.t;
}

class ObservationRepository {
  const ObservationRepository._();

  /// Returns a list of [Observation]s matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order of the items use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// The maximum number of items can be set by [limit]. If no limit is set,
  /// all items matching the query will be returned.
  ///
  /// [offset] defines how many items to skip, after which [limit] (or all)
  /// items are read from the database.
  ///
  /// ```dart
  /// var persons = await Persons.db.find(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.firstName,
  ///   limit: 100,
  /// );
  /// ```
  Future<List<Observation>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ObservationTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ObservationTable>? orderBy,
    _is.OrderByListBuilder<ObservationTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<Observation>(
      where: where?.call(Observation.t),
      orderBy: orderBy?.call(Observation.t),
      orderByList: orderByList?.call(Observation.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [Observation] matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// [offset] defines how many items to skip, after which the next one will be picked.
  ///
  /// ```dart
  /// var youngestPerson = await Persons.db.findFirstRow(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.age,
  /// );
  /// ```
  Future<Observation?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ObservationTable>? where,
    int? offset,
    _is.OrderByBuilder<ObservationTable>? orderBy,
    _is.OrderByListBuilder<ObservationTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<Observation>(
      where: where?.call(Observation.t),
      orderBy: orderBy?.call(Observation.t),
      orderByList: orderByList?.call(Observation.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [Observation] by its [id] or null if no such row exists.
  Future<Observation?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<Observation>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [Observation]s in the list and returns the inserted rows.
  ///
  /// The returned [Observation]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  ///
  /// If [noReturn] is set to `true`, the inserted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Observation>> insert(
    _is.DatabaseSession session,
    List<Observation> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<Observation>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [Observation] and returns the inserted row.
  ///
  /// The returned [Observation] will have its `id` field set.
  Future<Observation> insertRow(
    _is.DatabaseSession session,
    Observation row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<Observation>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [Observation]s in the list and returns the resulting rows.
  ///
  /// If a row conflicts on the given [conflictColumns], the existing row is
  /// updated with the new values. Otherwise, a new row is inserted.
  ///
  /// If [updateColumns] is provided, only those columns will be updated on
  /// conflict. If null, all non-conflict, non-id columns are updated.
  ///
  /// If [updateWhere] is provided, the update only applies to rows matching the
  /// given expression. Conflicting rows that don't match are skipped and not
  /// returned, so the resulting list may be shorter than [rows].
  ///
  /// The returned [Observation]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Observation>> upsert(
    _is.DatabaseSession session,
    List<Observation> rows, {
    required _is.ColumnSelections<ObservationTable> conflictColumns,
    _is.ColumnSelections<ObservationTable>? updateColumns,
    _is.WhereExpressionBuilder<ObservationTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<Observation>(
      rows,
      conflictColumns: conflictColumns(Observation.t),
      updateColumns: updateColumns?.call(Observation.t),
      updateWhere: updateWhere?.call(Observation.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [Observation] and returns the resulting row.
  ///
  /// If the row conflicts on the given [conflictColumns], the existing row is
  /// updated. Otherwise, a new row is inserted.
  ///
  /// If [updateColumns] is provided, only those columns will be updated on
  /// conflict. If null, all non-conflict, non-id columns are updated.
  ///
  /// If [updateWhere] is provided, the update only applies when the existing
  /// row matches the expression. Returns `null` if no row was affected — for
  /// example when [updateWhere] does not match the conflicting row.
  ///
  /// The returned [Observation] will have its `id` field set.
  Future<Observation?> upsertRow(
    _is.DatabaseSession session,
    Observation row, {
    required _is.ColumnSelections<ObservationTable> conflictColumns,
    _is.ColumnSelections<ObservationTable>? updateColumns,
    _is.WhereExpressionBuilder<ObservationTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<Observation>(
      row,
      conflictColumns: conflictColumns(Observation.t),
      updateColumns: updateColumns?.call(Observation.t),
      updateWhere: updateWhere?.call(Observation.t),
      transaction: transaction,
    );
  }

  /// Updates all [Observation]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Observation>> update(
    _is.DatabaseSession session,
    List<Observation> rows, {
    _is.ColumnSelections<ObservationTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<Observation>(
      rows,
      columns: columns?.call(Observation.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [Observation]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Observation> updateRow(
    _is.DatabaseSession session,
    Observation row, {
    _is.ColumnSelections<ObservationTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<Observation>(
      row,
      columns: columns?.call(Observation.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Observation] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<Observation?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<ObservationUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<Observation>(
      id,
      columnValues: columnValues(Observation.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [Observation]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Observation>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<ObservationUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<ObservationTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ObservationTable>? orderBy,
    _is.OrderByListBuilder<ObservationTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<Observation>(
      columnValues: columnValues(Observation.t.updateTable),
      where: where(Observation.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Observation.t),
      orderByList: orderByList?.call(Observation.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [Observation]s in the list and returns the deleted rows.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  ///
  /// If [noReturn] is set to `true`, the deleted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Observation>> delete(
    _is.DatabaseSession session,
    List<Observation> rows, {
    _is.OrderByBuilder<ObservationTable>? orderBy,
    _is.OrderByListBuilder<ObservationTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<Observation>(
      rows,
      orderBy: orderBy?.call(Observation.t),
      orderByList: orderByList?.call(Observation.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [Observation].
  Future<Observation> deleteRow(
    _is.DatabaseSession session,
    Observation row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Observation>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// If [noReturn] is set to `true`, the deleted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Observation>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<ObservationTable> where,
    _is.OrderByBuilder<ObservationTable>? orderBy,
    _is.OrderByListBuilder<ObservationTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<Observation>(
      where: where(Observation.t),
      orderBy: orderBy?.call(Observation.t),
      orderByList: orderByList?.call(Observation.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ObservationTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<Observation>(
      where: where?.call(Observation.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [Observation] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<ObservationTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<Observation>(
      where: where(Observation.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
