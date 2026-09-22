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

abstract class LegalConsent
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  LegalConsent._({
    this.id,
    required this.authUserId,
    required this.privacyPolicyVersion,
    required this.termsVersion,
    required this.locationConsent,
    required this.aiProcessingConsent,
    required this.evidenceSharingConsent,
    DateTime? acceptedAt,
    DateTime? updatedAt,
  }) : acceptedAt = acceptedAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory LegalConsent({
    int? id,
    required _is.UuidValue authUserId,
    required String privacyPolicyVersion,
    required String termsVersion,
    required bool locationConsent,
    required bool aiProcessingConsent,
    required bool evidenceSharingConsent,
    DateTime? acceptedAt,
    DateTime? updatedAt,
  }) = _LegalConsentImpl;

  factory LegalConsent.fromJson(Map<String, dynamic> jsonSerialization) {
    return LegalConsent(
      id: jsonSerialization['id'] as int?,
      authUserId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['authUserId'],
      ),
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
      acceptedAt: jsonSerialization['acceptedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['acceptedAt']),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  static final t = LegalConsentTable();

  static const db = LegalConsentRepository._();

  @override
  int? id;

  _is.UuidValue authUserId;

  String privacyPolicyVersion;

  String termsVersion;

  bool locationConsent;

  bool aiProcessingConsent;

  bool evidenceSharingConsent;

  DateTime acceptedAt;

  DateTime updatedAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [LegalConsent]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  LegalConsent copyWith({
    int? id,
    _is.UuidValue? authUserId,
    String? privacyPolicyVersion,
    String? termsVersion,
    bool? locationConsent,
    bool? aiProcessingConsent,
    bool? evidenceSharingConsent,
    DateTime? acceptedAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'LegalConsent',
      if (id != null) 'id': id,
      'authUserId': authUserId.toJson(),
      'privacyPolicyVersion': privacyPolicyVersion,
      'termsVersion': termsVersion,
      'locationConsent': locationConsent,
      'aiProcessingConsent': aiProcessingConsent,
      'evidenceSharingConsent': evidenceSharingConsent,
      'acceptedAt': acceptedAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'LegalConsent',
      if (id != null) 'id': id,
      'authUserId': authUserId.toJson(),
      'privacyPolicyVersion': privacyPolicyVersion,
      'termsVersion': termsVersion,
      'locationConsent': locationConsent,
      'aiProcessingConsent': aiProcessingConsent,
      'evidenceSharingConsent': evidenceSharingConsent,
      'acceptedAt': acceptedAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  static LegalConsentInclude include() {
    return LegalConsentInclude._();
  }

  static LegalConsentIncludeList includeList({
    _is.WhereExpressionBuilder<LegalConsentTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<LegalConsentTable>? orderBy,
    _is.OrderByListBuilder<LegalConsentTable>? orderByList,
    LegalConsentInclude? include,
  }) {
    return LegalConsentIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(LegalConsent.t),
      orderByList: orderByList?.call(LegalConsent.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _LegalConsentImpl extends LegalConsent {
  _LegalConsentImpl({
    int? id,
    required _is.UuidValue authUserId,
    required String privacyPolicyVersion,
    required String termsVersion,
    required bool locationConsent,
    required bool aiProcessingConsent,
    required bool evidenceSharingConsent,
    DateTime? acceptedAt,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         authUserId: authUserId,
         privacyPolicyVersion: privacyPolicyVersion,
         termsVersion: termsVersion,
         locationConsent: locationConsent,
         aiProcessingConsent: aiProcessingConsent,
         evidenceSharingConsent: evidenceSharingConsent,
         acceptedAt: acceptedAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [LegalConsent]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  LegalConsent copyWith({
    Object? id = _Undefined,
    _is.UuidValue? authUserId,
    String? privacyPolicyVersion,
    String? termsVersion,
    bool? locationConsent,
    bool? aiProcessingConsent,
    bool? evidenceSharingConsent,
    DateTime? acceptedAt,
    DateTime? updatedAt,
  }) {
    return LegalConsent(
      id: id is int? ? id : this.id,
      authUserId: authUserId ?? this.authUserId,
      privacyPolicyVersion: privacyPolicyVersion ?? this.privacyPolicyVersion,
      termsVersion: termsVersion ?? this.termsVersion,
      locationConsent: locationConsent ?? this.locationConsent,
      aiProcessingConsent: aiProcessingConsent ?? this.aiProcessingConsent,
      evidenceSharingConsent:
          evidenceSharingConsent ?? this.evidenceSharingConsent,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class LegalConsentUpdateTable extends _is.UpdateTable<LegalConsentTable> {
  LegalConsentUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> authUserId(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.authUserId,
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

  _is.ColumnValue<DateTime, DateTime> acceptedAt(DateTime value) =>
      _is.ColumnValue(
        table.acceptedAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> updatedAt(DateTime value) =>
      _is.ColumnValue(
        table.updatedAt,
        value,
      );
}

class LegalConsentTable extends _is.Table<int?> {
  LegalConsentTable({super.tableRelation})
    : super(tableName: 'fieldnote_legal_consent') {
    updateTable = LegalConsentUpdateTable(this);
    authUserId = _is.ColumnUuid(
      'authUserId',
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
    acceptedAt = _is.ColumnDateTime(
      'acceptedAt',
      this,
      hasDefault: true,
    );
    updatedAt = _is.ColumnDateTime(
      'updatedAt',
      this,
      hasDefault: true,
    );
  }

  late final LegalConsentUpdateTable updateTable;

  late final _is.ColumnUuid authUserId;

  late final _is.ColumnString privacyPolicyVersion;

  late final _is.ColumnString termsVersion;

  late final _is.ColumnBool locationConsent;

  late final _is.ColumnBool aiProcessingConsent;

  late final _is.ColumnBool evidenceSharingConsent;

  late final _is.ColumnDateTime acceptedAt;

  late final _is.ColumnDateTime updatedAt;

  @override
  List<_is.Column> get columns => [
    id,
    authUserId,
    privacyPolicyVersion,
    termsVersion,
    locationConsent,
    aiProcessingConsent,
    evidenceSharingConsent,
    acceptedAt,
    updatedAt,
  ];
}

class LegalConsentInclude extends _is.IncludeObject {
  LegalConsentInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => LegalConsent.t;
}

class LegalConsentIncludeList extends _is.IncludeList {
  LegalConsentIncludeList._({
    _is.WhereExpressionBuilder<LegalConsentTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(LegalConsent.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => LegalConsent.t;
}

class LegalConsentRepository {
  const LegalConsentRepository._();

  /// Returns a list of [LegalConsent]s matching the given query parameters.
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
  Future<List<LegalConsent>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<LegalConsentTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<LegalConsentTable>? orderBy,
    _is.OrderByListBuilder<LegalConsentTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<LegalConsent>(
      where: where?.call(LegalConsent.t),
      orderBy: orderBy?.call(LegalConsent.t),
      orderByList: orderByList?.call(LegalConsent.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [LegalConsent] matching the given query parameters.
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
  Future<LegalConsent?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<LegalConsentTable>? where,
    int? offset,
    _is.OrderByBuilder<LegalConsentTable>? orderBy,
    _is.OrderByListBuilder<LegalConsentTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<LegalConsent>(
      where: where?.call(LegalConsent.t),
      orderBy: orderBy?.call(LegalConsent.t),
      orderByList: orderByList?.call(LegalConsent.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [LegalConsent] by its [id] or null if no such row exists.
  Future<LegalConsent?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<LegalConsent>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [LegalConsent]s in the list and returns the inserted rows.
  ///
  /// The returned [LegalConsent]s will have their `id` fields set.
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
  Future<List<LegalConsent>> insert(
    _is.DatabaseSession session,
    List<LegalConsent> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<LegalConsent>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [LegalConsent] and returns the inserted row.
  ///
  /// The returned [LegalConsent] will have its `id` field set.
  Future<LegalConsent> insertRow(
    _is.DatabaseSession session,
    LegalConsent row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<LegalConsent>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [LegalConsent]s in the list and returns the resulting rows.
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
  /// The returned [LegalConsent]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<LegalConsent>> upsert(
    _is.DatabaseSession session,
    List<LegalConsent> rows, {
    required _is.ColumnSelections<LegalConsentTable> conflictColumns,
    _is.ColumnSelections<LegalConsentTable>? updateColumns,
    _is.WhereExpressionBuilder<LegalConsentTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<LegalConsent>(
      rows,
      conflictColumns: conflictColumns(LegalConsent.t),
      updateColumns: updateColumns?.call(LegalConsent.t),
      updateWhere: updateWhere?.call(LegalConsent.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [LegalConsent] and returns the resulting row.
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
  /// The returned [LegalConsent] will have its `id` field set.
  Future<LegalConsent?> upsertRow(
    _is.DatabaseSession session,
    LegalConsent row, {
    required _is.ColumnSelections<LegalConsentTable> conflictColumns,
    _is.ColumnSelections<LegalConsentTable>? updateColumns,
    _is.WhereExpressionBuilder<LegalConsentTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<LegalConsent>(
      row,
      conflictColumns: conflictColumns(LegalConsent.t),
      updateColumns: updateColumns?.call(LegalConsent.t),
      updateWhere: updateWhere?.call(LegalConsent.t),
      transaction: transaction,
    );
  }

  /// Updates all [LegalConsent]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<LegalConsent>> update(
    _is.DatabaseSession session,
    List<LegalConsent> rows, {
    _is.ColumnSelections<LegalConsentTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<LegalConsent>(
      rows,
      columns: columns?.call(LegalConsent.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [LegalConsent]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<LegalConsent> updateRow(
    _is.DatabaseSession session,
    LegalConsent row, {
    _is.ColumnSelections<LegalConsentTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<LegalConsent>(
      row,
      columns: columns?.call(LegalConsent.t),
      transaction: transaction,
    );
  }

  /// Updates a single [LegalConsent] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<LegalConsent?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<LegalConsentUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<LegalConsent>(
      id,
      columnValues: columnValues(LegalConsent.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [LegalConsent]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<LegalConsent>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<LegalConsentUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<LegalConsentTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<LegalConsentTable>? orderBy,
    _is.OrderByListBuilder<LegalConsentTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<LegalConsent>(
      columnValues: columnValues(LegalConsent.t.updateTable),
      where: where(LegalConsent.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(LegalConsent.t),
      orderByList: orderByList?.call(LegalConsent.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [LegalConsent]s in the list and returns the deleted rows.
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
  Future<List<LegalConsent>> delete(
    _is.DatabaseSession session,
    List<LegalConsent> rows, {
    _is.OrderByBuilder<LegalConsentTable>? orderBy,
    _is.OrderByListBuilder<LegalConsentTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<LegalConsent>(
      rows,
      orderBy: orderBy?.call(LegalConsent.t),
      orderByList: orderByList?.call(LegalConsent.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [LegalConsent].
  Future<LegalConsent> deleteRow(
    _is.DatabaseSession session,
    LegalConsent row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<LegalConsent>(
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
  Future<List<LegalConsent>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<LegalConsentTable> where,
    _is.OrderByBuilder<LegalConsentTable>? orderBy,
    _is.OrderByListBuilder<LegalConsentTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<LegalConsent>(
      where: where(LegalConsent.t),
      orderBy: orderBy?.call(LegalConsent.t),
      orderByList: orderByList?.call(LegalConsent.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<LegalConsentTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<LegalConsent>(
      where: where?.call(LegalConsent.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [LegalConsent] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<LegalConsentTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<LegalConsent>(
      where: where(LegalConsent.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
