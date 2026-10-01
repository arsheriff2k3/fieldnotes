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

/// Append-only consent history (T-2). LegalConsent keeps the current state;
/// every accept and withdraw also appends one row here. On account deletion
/// the rows are kept with an anonymous id as the legal record.
///
/// action: accepted | withdrawn
abstract class LegalConsentHistory
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  LegalConsentHistory._({
    this.id,
    required this.authUserId,
    required this.action,
    required this.privacyPolicyVersion,
    required this.termsVersion,
    required this.locationConsent,
    required this.aiProcessingConsent,
    required this.evidenceSharingConsent,
    DateTime? recordedAt,
  }) : recordedAt = recordedAt ?? DateTime.now();

  factory LegalConsentHistory({
    int? id,
    required _is.UuidValue authUserId,
    required String action,
    required String privacyPolicyVersion,
    required String termsVersion,
    required bool locationConsent,
    required bool aiProcessingConsent,
    required bool evidenceSharingConsent,
    DateTime? recordedAt,
  }) = _LegalConsentHistoryImpl;

  factory LegalConsentHistory.fromJson(Map<String, dynamic> jsonSerialization) {
    return LegalConsentHistory(
      id: jsonSerialization['id'] as int?,
      authUserId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['authUserId'],
      ),
      action: jsonSerialization['action'] as String,
      privacyPolicyVersion: jsonSerialization['privacyPolicyVersion'] as String,
      termsVersion: jsonSerialization['termsVersion'] as String,
      locationConsent: _is.BoolJsonExtension.fromJson(
        jsonSerialization['locationConsent'],
      ),
      aiProcessingConsent: _is.BoolJsonExtension.fromJson(
        jsonSerialization['aiProcessingConsent'],
      ),
      evidenceSharingConsent: _is.BoolJsonExtension.fromJson(
        jsonSerialization['evidenceSharingConsent'],
      ),
      recordedAt: jsonSerialization['recordedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['recordedAt']),
    );
  }

  static final t = LegalConsentHistoryTable();

  static const db = LegalConsentHistoryRepository._();

  @override
  int? id;

  _is.UuidValue authUserId;

  String action;

  String privacyPolicyVersion;

  String termsVersion;

  bool locationConsent;

  bool aiProcessingConsent;

  bool evidenceSharingConsent;

  DateTime recordedAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [LegalConsentHistory]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  LegalConsentHistory copyWith({
    int? id,
    _is.UuidValue? authUserId,
    String? action,
    String? privacyPolicyVersion,
    String? termsVersion,
    bool? locationConsent,
    bool? aiProcessingConsent,
    bool? evidenceSharingConsent,
    DateTime? recordedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'LegalConsentHistory',
      if (id != null) 'id': id,
      'authUserId': authUserId.toJson(),
      'action': action,
      'privacyPolicyVersion': privacyPolicyVersion,
      'termsVersion': termsVersion,
      'locationConsent': locationConsent,
      'aiProcessingConsent': aiProcessingConsent,
      'evidenceSharingConsent': evidenceSharingConsent,
      'recordedAt': recordedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'LegalConsentHistory',
      if (id != null) 'id': id,
      'authUserId': authUserId.toJson(),
      'action': action,
      'privacyPolicyVersion': privacyPolicyVersion,
      'termsVersion': termsVersion,
      'locationConsent': locationConsent,
      'aiProcessingConsent': aiProcessingConsent,
      'evidenceSharingConsent': evidenceSharingConsent,
      'recordedAt': recordedAt.toJson(),
    };
  }

  static LegalConsentHistoryInclude include() {
    return LegalConsentHistoryInclude._();
  }

  static LegalConsentHistoryIncludeList includeList({
    _is.WhereExpressionBuilder<LegalConsentHistoryTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<LegalConsentHistoryTable>? orderBy,
    _is.OrderByListBuilder<LegalConsentHistoryTable>? orderByList,
    LegalConsentHistoryInclude? include,
  }) {
    return LegalConsentHistoryIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(LegalConsentHistory.t),
      orderByList: orderByList?.call(LegalConsentHistory.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _LegalConsentHistoryImpl extends LegalConsentHistory {
  _LegalConsentHistoryImpl({
    int? id,
    required _is.UuidValue authUserId,
    required String action,
    required String privacyPolicyVersion,
    required String termsVersion,
    required bool locationConsent,
    required bool aiProcessingConsent,
    required bool evidenceSharingConsent,
    DateTime? recordedAt,
  }) : super._(
         id: id,
         authUserId: authUserId,
         action: action,
         privacyPolicyVersion: privacyPolicyVersion,
         termsVersion: termsVersion,
         locationConsent: locationConsent,
         aiProcessingConsent: aiProcessingConsent,
         evidenceSharingConsent: evidenceSharingConsent,
         recordedAt: recordedAt,
       );

  /// Returns a shallow copy of this [LegalConsentHistory]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  LegalConsentHistory copyWith({
    Object? id = _Undefined,
    _is.UuidValue? authUserId,
    String? action,
    String? privacyPolicyVersion,
    String? termsVersion,
    bool? locationConsent,
    bool? aiProcessingConsent,
    bool? evidenceSharingConsent,
    DateTime? recordedAt,
  }) {
    return LegalConsentHistory(
      id: id is int? ? id : this.id,
      authUserId: authUserId ?? this.authUserId,
      action: action ?? this.action,
      privacyPolicyVersion: privacyPolicyVersion ?? this.privacyPolicyVersion,
      termsVersion: termsVersion ?? this.termsVersion,
      locationConsent: locationConsent ?? this.locationConsent,
      aiProcessingConsent: aiProcessingConsent ?? this.aiProcessingConsent,
      evidenceSharingConsent:
          evidenceSharingConsent ?? this.evidenceSharingConsent,
      recordedAt: recordedAt ?? this.recordedAt,
    );
  }
}

class LegalConsentHistoryUpdateTable
    extends _is.UpdateTable<LegalConsentHistoryTable> {
  LegalConsentHistoryUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> authUserId(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.authUserId,
    value,
  );

  _is.ColumnValue<String, String> action(String value) => _is.ColumnValue(
    table.action,
    value,
  );

  _is.ColumnValue<String, String> privacyPolicyVersion(String value) =>
      _is.ColumnValue(
        table.privacyPolicyVersion,
        value,
      );

  _is.ColumnValue<String, String> termsVersion(String value) => _is.ColumnValue(
    table.termsVersion,
    value,
  );

  _is.ColumnValue<bool, bool> locationConsent(bool value) => _is.ColumnValue(
    table.locationConsent,
    value,
  );

  _is.ColumnValue<bool, bool> aiProcessingConsent(bool value) =>
      _is.ColumnValue(
        table.aiProcessingConsent,
        value,
      );

  _is.ColumnValue<bool, bool> evidenceSharingConsent(bool value) =>
      _is.ColumnValue(
        table.evidenceSharingConsent,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> recordedAt(DateTime value) =>
      _is.ColumnValue(
        table.recordedAt,
        value,
      );
}

class LegalConsentHistoryTable extends _is.Table<int?> {
  LegalConsentHistoryTable({super.tableRelation})
    : super(tableName: 'fieldnote_legal_consent_history') {
    updateTable = LegalConsentHistoryUpdateTable(this);
    authUserId = _is.ColumnUuid(
      'authUserId',
      this,
    );
    action = _is.ColumnString(
      'action',
      this,
    );
    privacyPolicyVersion = _is.ColumnString(
      'privacyPolicyVersion',
      this,
    );
    termsVersion = _is.ColumnString(
      'termsVersion',
      this,
    );
    locationConsent = _is.ColumnBool(
      'locationConsent',
      this,
    );
    aiProcessingConsent = _is.ColumnBool(
      'aiProcessingConsent',
      this,
    );
    evidenceSharingConsent = _is.ColumnBool(
      'evidenceSharingConsent',
      this,
    );
    recordedAt = _is.ColumnDateTime(
      'recordedAt',
      this,
      hasDefault: true,
    );
  }

  late final LegalConsentHistoryUpdateTable updateTable;

  late final _is.ColumnUuid authUserId;

  late final _is.ColumnString action;

  late final _is.ColumnString privacyPolicyVersion;

  late final _is.ColumnString termsVersion;

  late final _is.ColumnBool locationConsent;

  late final _is.ColumnBool aiProcessingConsent;

  late final _is.ColumnBool evidenceSharingConsent;

  late final _is.ColumnDateTime recordedAt;

  @override
  List<_is.Column> get columns => [
    id,
    authUserId,
    action,
    privacyPolicyVersion,
    termsVersion,
    locationConsent,
    aiProcessingConsent,
    evidenceSharingConsent,
    recordedAt,
  ];
}

class LegalConsentHistoryInclude extends _is.IncludeObject {
  LegalConsentHistoryInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => LegalConsentHistory.t;
}

class LegalConsentHistoryIncludeList extends _is.IncludeList {
  LegalConsentHistoryIncludeList._({
    _is.WhereExpressionBuilder<LegalConsentHistoryTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(LegalConsentHistory.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => LegalConsentHistory.t;
}

class LegalConsentHistoryRepository {
  const LegalConsentHistoryRepository._();

  /// Returns a list of [LegalConsentHistory]s matching the given query parameters.
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
  Future<List<LegalConsentHistory>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<LegalConsentHistoryTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<LegalConsentHistoryTable>? orderBy,
    _is.OrderByListBuilder<LegalConsentHistoryTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<LegalConsentHistory>(
      where: where?.call(LegalConsentHistory.t),
      orderBy: orderBy?.call(LegalConsentHistory.t),
      orderByList: orderByList?.call(LegalConsentHistory.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [LegalConsentHistory] matching the given query parameters.
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
  Future<LegalConsentHistory?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<LegalConsentHistoryTable>? where,
    int? offset,
    _is.OrderByBuilder<LegalConsentHistoryTable>? orderBy,
    _is.OrderByListBuilder<LegalConsentHistoryTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<LegalConsentHistory>(
      where: where?.call(LegalConsentHistory.t),
      orderBy: orderBy?.call(LegalConsentHistory.t),
      orderByList: orderByList?.call(LegalConsentHistory.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [LegalConsentHistory] by its [id] or null if no such row exists.
  Future<LegalConsentHistory?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<LegalConsentHistory>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [LegalConsentHistory]s in the list and returns the inserted rows.
  ///
  /// The returned [LegalConsentHistory]s will have their `id` fields set.
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
  Future<List<LegalConsentHistory>> insert(
    _is.DatabaseSession session,
    List<LegalConsentHistory> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<LegalConsentHistory>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [LegalConsentHistory] and returns the inserted row.
  ///
  /// The returned [LegalConsentHistory] will have its `id` field set.
  Future<LegalConsentHistory> insertRow(
    _is.DatabaseSession session,
    LegalConsentHistory row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<LegalConsentHistory>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [LegalConsentHistory]s in the list and returns the resulting rows.
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
  /// The returned [LegalConsentHistory]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<LegalConsentHistory>> upsert(
    _is.DatabaseSession session,
    List<LegalConsentHistory> rows, {
    required _is.ColumnSelections<LegalConsentHistoryTable> conflictColumns,
    _is.ColumnSelections<LegalConsentHistoryTable>? updateColumns,
    _is.WhereExpressionBuilder<LegalConsentHistoryTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<LegalConsentHistory>(
      rows,
      conflictColumns: conflictColumns(LegalConsentHistory.t),
      updateColumns: updateColumns?.call(LegalConsentHistory.t),
      updateWhere: updateWhere?.call(LegalConsentHistory.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [LegalConsentHistory] and returns the resulting row.
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
  /// The returned [LegalConsentHistory] will have its `id` field set.
  Future<LegalConsentHistory?> upsertRow(
    _is.DatabaseSession session,
    LegalConsentHistory row, {
    required _is.ColumnSelections<LegalConsentHistoryTable> conflictColumns,
    _is.ColumnSelections<LegalConsentHistoryTable>? updateColumns,
    _is.WhereExpressionBuilder<LegalConsentHistoryTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<LegalConsentHistory>(
      row,
      conflictColumns: conflictColumns(LegalConsentHistory.t),
      updateColumns: updateColumns?.call(LegalConsentHistory.t),
      updateWhere: updateWhere?.call(LegalConsentHistory.t),
      transaction: transaction,
    );
  }

  /// Updates all [LegalConsentHistory]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<LegalConsentHistory>> update(
    _is.DatabaseSession session,
    List<LegalConsentHistory> rows, {
    _is.ColumnSelections<LegalConsentHistoryTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<LegalConsentHistory>(
      rows,
      columns: columns?.call(LegalConsentHistory.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [LegalConsentHistory]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<LegalConsentHistory> updateRow(
    _is.DatabaseSession session,
    LegalConsentHistory row, {
    _is.ColumnSelections<LegalConsentHistoryTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<LegalConsentHistory>(
      row,
      columns: columns?.call(LegalConsentHistory.t),
      transaction: transaction,
    );
  }

  /// Updates a single [LegalConsentHistory] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<LegalConsentHistory?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<LegalConsentHistoryUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<LegalConsentHistory>(
      id,
      columnValues: columnValues(LegalConsentHistory.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [LegalConsentHistory]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<LegalConsentHistory>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<LegalConsentHistoryUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<LegalConsentHistoryTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<LegalConsentHistoryTable>? orderBy,
    _is.OrderByListBuilder<LegalConsentHistoryTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<LegalConsentHistory>(
      columnValues: columnValues(LegalConsentHistory.t.updateTable),
      where: where(LegalConsentHistory.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(LegalConsentHistory.t),
      orderByList: orderByList?.call(LegalConsentHistory.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [LegalConsentHistory]s in the list and returns the deleted rows.
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
  Future<List<LegalConsentHistory>> delete(
    _is.DatabaseSession session,
    List<LegalConsentHistory> rows, {
    _is.OrderByBuilder<LegalConsentHistoryTable>? orderBy,
    _is.OrderByListBuilder<LegalConsentHistoryTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<LegalConsentHistory>(
      rows,
      orderBy: orderBy?.call(LegalConsentHistory.t),
      orderByList: orderByList?.call(LegalConsentHistory.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [LegalConsentHistory].
  Future<LegalConsentHistory> deleteRow(
    _is.DatabaseSession session,
    LegalConsentHistory row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<LegalConsentHistory>(
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
  Future<List<LegalConsentHistory>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<LegalConsentHistoryTable> where,
    _is.OrderByBuilder<LegalConsentHistoryTable>? orderBy,
    _is.OrderByListBuilder<LegalConsentHistoryTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<LegalConsentHistory>(
      where: where(LegalConsentHistory.t),
      orderBy: orderBy?.call(LegalConsentHistory.t),
      orderByList: orderByList?.call(LegalConsentHistory.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<LegalConsentHistoryTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<LegalConsentHistory>(
      where: where?.call(LegalConsentHistory.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [LegalConsentHistory] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<LegalConsentHistoryTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<LegalConsentHistory>(
      where: where(LegalConsentHistory.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
