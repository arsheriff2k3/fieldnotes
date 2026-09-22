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

abstract class CompletionEvidence
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  CompletionEvidence._({
    this.id,
    required this.participationId,
    this.photographPath,
    required this.originalNote,
    required this.confirmedSummary,
    required this.structuredResults,
    required this.latitude,
    required this.longitude,
    required this.locationAccuracyMeters,
    String? locationIntegrityStatus,
    String? locationIntegrityReasons,
    bool? locationIsDemo,
    String? moderationStatus,
    DateTime? submittedAt,
  }) : locationIntegrityStatus = locationIntegrityStatus ?? 'verified',
       locationIntegrityReasons =
           locationIntegrityReasons ?? 'Location checks passed',
       locationIsDemo = locationIsDemo ?? false,
       moderationStatus = moderationStatus ?? 'passed',
       submittedAt = submittedAt ?? DateTime.now();

  factory CompletionEvidence({
    int? id,
    required int participationId,
    String? photographPath,
    required String originalNote,
    required String confirmedSummary,
    required String structuredResults,
    required double latitude,
    required double longitude,
    required double locationAccuracyMeters,
    String? locationIntegrityStatus,
    String? locationIntegrityReasons,
    bool? locationIsDemo,
    String? moderationStatus,
    DateTime? submittedAt,
  }) = _CompletionEvidenceImpl;

  factory CompletionEvidence.fromJson(Map<String, dynamic> jsonSerialization) {
    return CompletionEvidence(
      id: jsonSerialization['id'] as int?,
      participationId: jsonSerialization['participationId'] as int,
      photographPath: jsonSerialization['photographPath'] as String?,
      originalNote: jsonSerialization['originalNote'] as String,
      confirmedSummary: jsonSerialization['confirmedSummary'] as String,
      structuredResults: jsonSerialization['structuredResults'] as String,
      latitude: (jsonSerialization['latitude'] as num).toDouble(),
      longitude: (jsonSerialization['longitude'] as num).toDouble(),
      locationAccuracyMeters:
          (jsonSerialization['locationAccuracyMeters'] as num).toDouble(),
      locationIntegrityStatus:
          jsonSerialization['locationIntegrityStatus'] as String?,
      locationIntegrityReasons:
          jsonSerialization['locationIntegrityReasons'] as String?,
      locationIsDemo: jsonSerialization['locationIsDemo'] == null
          ? null
          : _is.BoolJsonExtension.fromJson(jsonSerialization['locationIsDemo']),
      moderationStatus: jsonSerialization['moderationStatus'] as String?,
      submittedAt: jsonSerialization['submittedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(
              jsonSerialization['submittedAt'],
            ),
    );
  }

  static final t = CompletionEvidenceTable();

  static const db = CompletionEvidenceRepository._();

  @override
  int? id;

  int participationId;

  String? photographPath;

  String originalNote;

  String confirmedSummary;

  String structuredResults;

  double latitude;

  double longitude;

  double locationAccuracyMeters;

  String locationIntegrityStatus;

  String locationIntegrityReasons;

  bool locationIsDemo;

  String moderationStatus;

  DateTime submittedAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [CompletionEvidence]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CompletionEvidence copyWith({
    int? id,
    int? participationId,
    String? photographPath,
    String? originalNote,
    String? confirmedSummary,
    String? structuredResults,
    double? latitude,
    double? longitude,
    double? locationAccuracyMeters,
    String? locationIntegrityStatus,
    String? locationIntegrityReasons,
    bool? locationIsDemo,
    String? moderationStatus,
    DateTime? submittedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'CompletionEvidence',
      if (id != null) 'id': id,
      'participationId': participationId,
      if (photographPath != null) 'photographPath': photographPath,
      'originalNote': originalNote,
      'confirmedSummary': confirmedSummary,
      'structuredResults': structuredResults,
      'latitude': latitude,
      'longitude': longitude,
      'locationAccuracyMeters': locationAccuracyMeters,
      'locationIntegrityStatus': locationIntegrityStatus,
      'locationIntegrityReasons': locationIntegrityReasons,
      'locationIsDemo': locationIsDemo,
      'moderationStatus': moderationStatus,
      'submittedAt': submittedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'CompletionEvidence',
      if (id != null) 'id': id,
      'participationId': participationId,
      if (photographPath != null) 'photographPath': photographPath,
      'originalNote': originalNote,
      'confirmedSummary': confirmedSummary,
      'structuredResults': structuredResults,
      'latitude': latitude,
      'longitude': longitude,
      'locationAccuracyMeters': locationAccuracyMeters,
      'locationIntegrityStatus': locationIntegrityStatus,
      'locationIntegrityReasons': locationIntegrityReasons,
      'locationIsDemo': locationIsDemo,
      'moderationStatus': moderationStatus,
      'submittedAt': submittedAt.toJson(),
    };
  }

  static CompletionEvidenceInclude include() {
    return CompletionEvidenceInclude._();
  }

  static CompletionEvidenceIncludeList includeList({
    _is.WhereExpressionBuilder<CompletionEvidenceTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CompletionEvidenceTable>? orderBy,
    _is.OrderByListBuilder<CompletionEvidenceTable>? orderByList,
    CompletionEvidenceInclude? include,
  }) {
    return CompletionEvidenceIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CompletionEvidence.t),
      orderByList: orderByList?.call(CompletionEvidence.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CompletionEvidenceImpl extends CompletionEvidence {
  _CompletionEvidenceImpl({
    int? id,
    required int participationId,
    String? photographPath,
    required String originalNote,
    required String confirmedSummary,
    required String structuredResults,
    required double latitude,
    required double longitude,
    required double locationAccuracyMeters,
    String? locationIntegrityStatus,
    String? locationIntegrityReasons,
    bool? locationIsDemo,
    String? moderationStatus,
    DateTime? submittedAt,
  }) : super._(
         id: id,
         participationId: participationId,
         photographPath: photographPath,
         originalNote: originalNote,
         confirmedSummary: confirmedSummary,
         structuredResults: structuredResults,
         latitude: latitude,
         longitude: longitude,
         locationAccuracyMeters: locationAccuracyMeters,
         locationIntegrityStatus: locationIntegrityStatus,
         locationIntegrityReasons: locationIntegrityReasons,
         locationIsDemo: locationIsDemo,
         moderationStatus: moderationStatus,
         submittedAt: submittedAt,
       );

  /// Returns a shallow copy of this [CompletionEvidence]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CompletionEvidence copyWith({
    Object? id = _Undefined,
    int? participationId,
    Object? photographPath = _Undefined,
    String? originalNote,
    String? confirmedSummary,
    String? structuredResults,
    double? latitude,
    double? longitude,
    double? locationAccuracyMeters,
    String? locationIntegrityStatus,
    String? locationIntegrityReasons,
    bool? locationIsDemo,
    String? moderationStatus,
    DateTime? submittedAt,
  }) {
    return CompletionEvidence(
      id: id is int? ? id : this.id,
      participationId: participationId ?? this.participationId,
      photographPath: photographPath is String?
          ? photographPath
          : this.photographPath,
      originalNote: originalNote ?? this.originalNote,
      confirmedSummary: confirmedSummary ?? this.confirmedSummary,
      structuredResults: structuredResults ?? this.structuredResults,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationAccuracyMeters:
          locationAccuracyMeters ?? this.locationAccuracyMeters,
      locationIntegrityStatus:
          locationIntegrityStatus ?? this.locationIntegrityStatus,
      locationIntegrityReasons:
          locationIntegrityReasons ?? this.locationIntegrityReasons,
      locationIsDemo: locationIsDemo ?? this.locationIsDemo,
      moderationStatus: moderationStatus ?? this.moderationStatus,
      submittedAt: submittedAt ?? this.submittedAt,
    );
  }
}

class CompletionEvidenceUpdateTable
    extends _is.UpdateTable<CompletionEvidenceTable> {
  CompletionEvidenceUpdateTable(super.table);

  _is.ColumnValue<int, int> participationId(int value) => _is.ColumnValue(
    table.participationId,
    value,
  );

  _is.ColumnValue<String, String> photographPath(String? value) =>
      _is.ColumnValue(
        table.photographPath,
        value,
      );

  _is.ColumnValue<String, String> originalNote(String value) => _is.ColumnValue(
    table.originalNote,
    value,
  );

  _is.ColumnValue<String, String> confirmedSummary(String value) =>
      _is.ColumnValue(
        table.confirmedSummary,
        value,
      );

  _is.ColumnValue<String, String> structuredResults(String value) =>
      _is.ColumnValue(
        table.structuredResults,
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

  _is.ColumnValue<double, double> locationAccuracyMeters(double value) =>
      _is.ColumnValue(
        table.locationAccuracyMeters,
        value,
      );

  _is.ColumnValue<String, String> locationIntegrityStatus(String value) =>
      _is.ColumnValue(
        table.locationIntegrityStatus,
        value,
      );

  _is.ColumnValue<String, String> locationIntegrityReasons(String value) =>
      _is.ColumnValue(
        table.locationIntegrityReasons,
        value,
      );

  _is.ColumnValue<bool, bool> locationIsDemo(bool value) => _is.ColumnValue(
    table.locationIsDemo,
    value,
  );

  _is.ColumnValue<String, String> moderationStatus(String value) =>
      _is.ColumnValue(
        table.moderationStatus,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> submittedAt(DateTime value) =>
      _is.ColumnValue(
        table.submittedAt,
        value,
      );
}

class CompletionEvidenceTable extends _is.Table<int?> {
  CompletionEvidenceTable({super.tableRelation})
    : super(tableName: 'fieldnote_completion_evidence') {
    updateTable = CompletionEvidenceUpdateTable(this);
    participationId = _is.ColumnInt(
      'participationId',
      this,
    );
    photographPath = _is.ColumnString(
      'photographPath',
      this,
    );
    originalNote = _is.ColumnString(
      'originalNote',
      this,
    );
    confirmedSummary = _is.ColumnString(
      'confirmedSummary',
      this,
    );
    structuredResults = _is.ColumnString(
      'structuredResults',
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
    locationAccuracyMeters = _is.ColumnDouble(
      'locationAccuracyMeters',
      this,
    );
    locationIntegrityStatus = _is.ColumnString(
      'locationIntegrityStatus',
      this,
      hasDefault: true,
    );
    locationIntegrityReasons = _is.ColumnString(
      'locationIntegrityReasons',
      this,
      hasDefault: true,
    );
    locationIsDemo = _is.ColumnBool(
      'locationIsDemo',
      this,
      hasDefault: true,
    );
    moderationStatus = _is.ColumnString(
      'moderationStatus',
      this,
      hasDefault: true,
    );
    submittedAt = _is.ColumnDateTime(
      'submittedAt',
      this,
      hasDefault: true,
    );
  }

  late final CompletionEvidenceUpdateTable updateTable;

  late final _is.ColumnInt participationId;

  late final _is.ColumnString photographPath;

  late final _is.ColumnString originalNote;

  late final _is.ColumnString confirmedSummary;

  late final _is.ColumnString structuredResults;

  late final _is.ColumnDouble latitude;

  late final _is.ColumnDouble longitude;

  late final _is.ColumnDouble locationAccuracyMeters;

  late final _is.ColumnString locationIntegrityStatus;

  late final _is.ColumnString locationIntegrityReasons;

  late final _is.ColumnBool locationIsDemo;

  late final _is.ColumnString moderationStatus;

  late final _is.ColumnDateTime submittedAt;

  @override
  List<_is.Column> get columns => [
    id,
    participationId,
    photographPath,
    originalNote,
    confirmedSummary,
    structuredResults,
    latitude,
    longitude,
    locationAccuracyMeters,
    locationIntegrityStatus,
    locationIntegrityReasons,
    locationIsDemo,
    moderationStatus,
    submittedAt,
  ];
}

class CompletionEvidenceInclude extends _is.IncludeObject {
  CompletionEvidenceInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => CompletionEvidence.t;
}

class CompletionEvidenceIncludeList extends _is.IncludeList {
  CompletionEvidenceIncludeList._({
    _is.WhereExpressionBuilder<CompletionEvidenceTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(CompletionEvidence.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => CompletionEvidence.t;
}

class CompletionEvidenceRepository {
  const CompletionEvidenceRepository._();

  /// Returns a list of [CompletionEvidence]s matching the given query parameters.
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
  Future<List<CompletionEvidence>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CompletionEvidenceTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CompletionEvidenceTable>? orderBy,
    _is.OrderByListBuilder<CompletionEvidenceTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<CompletionEvidence>(
      where: where?.call(CompletionEvidence.t),
      orderBy: orderBy?.call(CompletionEvidence.t),
      orderByList: orderByList?.call(CompletionEvidence.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [CompletionEvidence] matching the given query parameters.
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
  Future<CompletionEvidence?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CompletionEvidenceTable>? where,
    int? offset,
    _is.OrderByBuilder<CompletionEvidenceTable>? orderBy,
    _is.OrderByListBuilder<CompletionEvidenceTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<CompletionEvidence>(
      where: where?.call(CompletionEvidence.t),
      orderBy: orderBy?.call(CompletionEvidence.t),
      orderByList: orderByList?.call(CompletionEvidence.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [CompletionEvidence] by its [id] or null if no such row exists.
  Future<CompletionEvidence?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<CompletionEvidence>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [CompletionEvidence]s in the list and returns the inserted rows.
  ///
  /// The returned [CompletionEvidence]s will have their `id` fields set.
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
  Future<List<CompletionEvidence>> insert(
    _is.DatabaseSession session,
    List<CompletionEvidence> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<CompletionEvidence>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [CompletionEvidence] and returns the inserted row.
  ///
  /// The returned [CompletionEvidence] will have its `id` field set.
  Future<CompletionEvidence> insertRow(
    _is.DatabaseSession session,
    CompletionEvidence row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<CompletionEvidence>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [CompletionEvidence]s in the list and returns the resulting rows.
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
  /// The returned [CompletionEvidence]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CompletionEvidence>> upsert(
    _is.DatabaseSession session,
    List<CompletionEvidence> rows, {
    required _is.ColumnSelections<CompletionEvidenceTable> conflictColumns,
    _is.ColumnSelections<CompletionEvidenceTable>? updateColumns,
    _is.WhereExpressionBuilder<CompletionEvidenceTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<CompletionEvidence>(
      rows,
      conflictColumns: conflictColumns(CompletionEvidence.t),
      updateColumns: updateColumns?.call(CompletionEvidence.t),
      updateWhere: updateWhere?.call(CompletionEvidence.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [CompletionEvidence] and returns the resulting row.
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
  /// The returned [CompletionEvidence] will have its `id` field set.
  Future<CompletionEvidence?> upsertRow(
    _is.DatabaseSession session,
    CompletionEvidence row, {
    required _is.ColumnSelections<CompletionEvidenceTable> conflictColumns,
    _is.ColumnSelections<CompletionEvidenceTable>? updateColumns,
    _is.WhereExpressionBuilder<CompletionEvidenceTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<CompletionEvidence>(
      row,
      conflictColumns: conflictColumns(CompletionEvidence.t),
      updateColumns: updateColumns?.call(CompletionEvidence.t),
      updateWhere: updateWhere?.call(CompletionEvidence.t),
      transaction: transaction,
    );
  }

  /// Updates all [CompletionEvidence]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CompletionEvidence>> update(
    _is.DatabaseSession session,
    List<CompletionEvidence> rows, {
    _is.ColumnSelections<CompletionEvidenceTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<CompletionEvidence>(
      rows,
      columns: columns?.call(CompletionEvidence.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [CompletionEvidence]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<CompletionEvidence> updateRow(
    _is.DatabaseSession session,
    CompletionEvidence row, {
    _is.ColumnSelections<CompletionEvidenceTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<CompletionEvidence>(
      row,
      columns: columns?.call(CompletionEvidence.t),
      transaction: transaction,
    );
  }

  /// Updates a single [CompletionEvidence] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<CompletionEvidence?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<CompletionEvidenceUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<CompletionEvidence>(
      id,
      columnValues: columnValues(CompletionEvidence.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [CompletionEvidence]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CompletionEvidence>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<CompletionEvidenceUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<CompletionEvidenceTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CompletionEvidenceTable>? orderBy,
    _is.OrderByListBuilder<CompletionEvidenceTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<CompletionEvidence>(
      columnValues: columnValues(CompletionEvidence.t.updateTable),
      where: where(CompletionEvidence.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CompletionEvidence.t),
      orderByList: orderByList?.call(CompletionEvidence.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [CompletionEvidence]s in the list and returns the deleted rows.
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
  Future<List<CompletionEvidence>> delete(
    _is.DatabaseSession session,
    List<CompletionEvidence> rows, {
    _is.OrderByBuilder<CompletionEvidenceTable>? orderBy,
    _is.OrderByListBuilder<CompletionEvidenceTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<CompletionEvidence>(
      rows,
      orderBy: orderBy?.call(CompletionEvidence.t),
      orderByList: orderByList?.call(CompletionEvidence.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [CompletionEvidence].
  Future<CompletionEvidence> deleteRow(
    _is.DatabaseSession session,
    CompletionEvidence row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<CompletionEvidence>(
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
  Future<List<CompletionEvidence>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CompletionEvidenceTable> where,
    _is.OrderByBuilder<CompletionEvidenceTable>? orderBy,
    _is.OrderByListBuilder<CompletionEvidenceTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<CompletionEvidence>(
      where: where(CompletionEvidence.t),
      orderBy: orderBy?.call(CompletionEvidence.t),
      orderByList: orderByList?.call(CompletionEvidence.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CompletionEvidenceTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<CompletionEvidence>(
      where: where?.call(CompletionEvidence.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [CompletionEvidence] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CompletionEvidenceTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<CompletionEvidence>(
      where: where(CompletionEvidence.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
