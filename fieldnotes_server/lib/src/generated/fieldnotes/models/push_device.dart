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

/// Registration tokens are secrets and never returned to another client.
abstract class PushDevice
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  PushDevice._({
    this.id,
    required this.authUserId,
    required this.token,
    required this.tokenHash,
    required this.platform,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  factory PushDevice({
    int? id,
    required _is.UuidValue authUserId,
    required String token,
    required String tokenHash,
    required String platform,
    DateTime? updatedAt,
  }) = _PushDeviceImpl;

  factory PushDevice.fromJson(Map<String, dynamic> jsonSerialization) {
    return PushDevice(
      id: jsonSerialization['id'] as int?,
      authUserId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['authUserId'],
      ),
      token: jsonSerialization['token'] as String,
      tokenHash: jsonSerialization['tokenHash'] as String,
      platform: jsonSerialization['platform'] as String,
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  static final t = PushDeviceTable();

  static const db = PushDeviceRepository._();

  @override
  int? id;

  _is.UuidValue authUserId;

  String token;

  String tokenHash;

  String platform;

  DateTime updatedAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [PushDevice]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  PushDevice copyWith({
    int? id,
    _is.UuidValue? authUserId,
    String? token,
    String? tokenHash,
    String? platform,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PushDevice',
      if (id != null) 'id': id,
      'authUserId': authUserId.toJson(),
      'token': token,
      'tokenHash': tokenHash,
      'platform': platform,
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static PushDeviceInclude include() {
    return PushDeviceInclude._();
  }

  static PushDeviceIncludeList includeList({
    _is.WhereExpressionBuilder<PushDeviceTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PushDeviceTable>? orderBy,
    _is.OrderByListBuilder<PushDeviceTable>? orderByList,
    PushDeviceInclude? include,
  }) {
    return PushDeviceIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(PushDevice.t),
      orderByList: orderByList?.call(PushDevice.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _PushDeviceImpl extends PushDevice {
  _PushDeviceImpl({
    int? id,
    required _is.UuidValue authUserId,
    required String token,
    required String tokenHash,
    required String platform,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         authUserId: authUserId,
         token: token,
         tokenHash: tokenHash,
         platform: platform,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [PushDevice]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  PushDevice copyWith({
    Object? id = _Undefined,
    _is.UuidValue? authUserId,
    String? token,
    String? tokenHash,
    String? platform,
    DateTime? updatedAt,
  }) {
    return PushDevice(
      id: id is int? ? id : this.id,
      authUserId: authUserId ?? this.authUserId,
      token: token ?? this.token,
      tokenHash: tokenHash ?? this.tokenHash,
      platform: platform ?? this.platform,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class PushDeviceUpdateTable extends _is.UpdateTable<PushDeviceTable> {
  PushDeviceUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> authUserId(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.authUserId,
    value,
  );

  _is.ColumnValue<String, String> token(String value) => _is.ColumnValue(
    table.token,
    value,
  );

  _is.ColumnValue<String, String> tokenHash(String value) => _is.ColumnValue(
    table.tokenHash,
    value,
  );

  _is.ColumnValue<String, String> platform(String value) => _is.ColumnValue(
    table.platform,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> updatedAt(DateTime value) =>
      _is.ColumnValue(
        table.updatedAt,
        value,
      );
}

class PushDeviceTable extends _is.Table<int?> {
  PushDeviceTable({super.tableRelation})
    : super(tableName: 'fieldnote_push_device') {
    updateTable = PushDeviceUpdateTable(this);
    authUserId = _is.ColumnUuid(
      'authUserId',
      this,
    );
    token = _is.ColumnString(
      'token',
      this,
    );
    tokenHash = _is.ColumnString(
      'tokenHash',
      this,
    );
    platform = _is.ColumnString(
      'platform',
      this,
    );
    updatedAt = _is.ColumnDateTime(
      'updatedAt',
      this,
      hasDefault: true,
    );
  }

  late final PushDeviceUpdateTable updateTable;

  late final _is.ColumnUuid authUserId;

  late final _is.ColumnString token;

  late final _is.ColumnString tokenHash;

  late final _is.ColumnString platform;

  late final _is.ColumnDateTime updatedAt;

  @override
  List<_is.Column> get columns => [
    id,
    authUserId,
    token,
    tokenHash,
    platform,
    updatedAt,
  ];
}

class PushDeviceInclude extends _is.IncludeObject {
  PushDeviceInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => PushDevice.t;
}

class PushDeviceIncludeList extends _is.IncludeList {
  PushDeviceIncludeList._({
    _is.WhereExpressionBuilder<PushDeviceTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(PushDevice.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => PushDevice.t;
}

class PushDeviceRepository {
  const PushDeviceRepository._();

  /// Returns a list of [PushDevice]s matching the given query parameters.
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
  Future<List<PushDevice>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PushDeviceTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PushDeviceTable>? orderBy,
    _is.OrderByListBuilder<PushDeviceTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<PushDevice>(
      where: where?.call(PushDevice.t),
      orderBy: orderBy?.call(PushDevice.t),
      orderByList: orderByList?.call(PushDevice.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [PushDevice] matching the given query parameters.
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
  Future<PushDevice?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PushDeviceTable>? where,
    int? offset,
    _is.OrderByBuilder<PushDeviceTable>? orderBy,
    _is.OrderByListBuilder<PushDeviceTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<PushDevice>(
      where: where?.call(PushDevice.t),
      orderBy: orderBy?.call(PushDevice.t),
      orderByList: orderByList?.call(PushDevice.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [PushDevice] by its [id] or null if no such row exists.
  Future<PushDevice?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<PushDevice>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [PushDevice]s in the list and returns the inserted rows.
  ///
  /// The returned [PushDevice]s will have their `id` fields set.
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
  Future<List<PushDevice>> insert(
    _is.DatabaseSession session,
    List<PushDevice> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<PushDevice>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [PushDevice] and returns the inserted row.
  ///
  /// The returned [PushDevice] will have its `id` field set.
  Future<PushDevice> insertRow(
    _is.DatabaseSession session,
    PushDevice row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<PushDevice>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [PushDevice]s in the list and returns the resulting rows.
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
  /// The returned [PushDevice]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<PushDevice>> upsert(
    _is.DatabaseSession session,
    List<PushDevice> rows, {
    required _is.ColumnSelections<PushDeviceTable> conflictColumns,
    _is.ColumnSelections<PushDeviceTable>? updateColumns,
    _is.WhereExpressionBuilder<PushDeviceTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<PushDevice>(
      rows,
      conflictColumns: conflictColumns(PushDevice.t),
      updateColumns: updateColumns?.call(PushDevice.t),
      updateWhere: updateWhere?.call(PushDevice.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [PushDevice] and returns the resulting row.
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
  /// The returned [PushDevice] will have its `id` field set.
  Future<PushDevice?> upsertRow(
    _is.DatabaseSession session,
    PushDevice row, {
    required _is.ColumnSelections<PushDeviceTable> conflictColumns,
    _is.ColumnSelections<PushDeviceTable>? updateColumns,
    _is.WhereExpressionBuilder<PushDeviceTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<PushDevice>(
      row,
      conflictColumns: conflictColumns(PushDevice.t),
      updateColumns: updateColumns?.call(PushDevice.t),
      updateWhere: updateWhere?.call(PushDevice.t),
      transaction: transaction,
    );
  }

  /// Updates all [PushDevice]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<PushDevice>> update(
    _is.DatabaseSession session,
    List<PushDevice> rows, {
    _is.ColumnSelections<PushDeviceTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<PushDevice>(
      rows,
      columns: columns?.call(PushDevice.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [PushDevice]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<PushDevice> updateRow(
    _is.DatabaseSession session,
    PushDevice row, {
    _is.ColumnSelections<PushDeviceTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<PushDevice>(
      row,
      columns: columns?.call(PushDevice.t),
      transaction: transaction,
    );
  }

  /// Updates a single [PushDevice] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<PushDevice?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<PushDeviceUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<PushDevice>(
      id,
      columnValues: columnValues(PushDevice.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [PushDevice]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<PushDevice>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<PushDeviceUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<PushDeviceTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PushDeviceTable>? orderBy,
    _is.OrderByListBuilder<PushDeviceTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<PushDevice>(
      columnValues: columnValues(PushDevice.t.updateTable),
      where: where(PushDevice.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(PushDevice.t),
      orderByList: orderByList?.call(PushDevice.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [PushDevice]s in the list and returns the deleted rows.
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
  Future<List<PushDevice>> delete(
    _is.DatabaseSession session,
    List<PushDevice> rows, {
    _is.OrderByBuilder<PushDeviceTable>? orderBy,
    _is.OrderByListBuilder<PushDeviceTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<PushDevice>(
      rows,
      orderBy: orderBy?.call(PushDevice.t),
      orderByList: orderByList?.call(PushDevice.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [PushDevice].
  Future<PushDevice> deleteRow(
    _is.DatabaseSession session,
    PushDevice row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<PushDevice>(
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
  Future<List<PushDevice>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<PushDeviceTable> where,
    _is.OrderByBuilder<PushDeviceTable>? orderBy,
    _is.OrderByListBuilder<PushDeviceTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<PushDevice>(
      where: where(PushDevice.t),
      orderBy: orderBy?.call(PushDevice.t),
      orderByList: orderByList?.call(PushDevice.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PushDeviceTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<PushDevice>(
      where: where?.call(PushDevice.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [PushDevice] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<PushDeviceTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<PushDevice>(
      where: where(PushDevice.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
