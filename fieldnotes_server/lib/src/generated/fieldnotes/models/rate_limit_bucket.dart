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

/// Fixed-window counter for one user and action (A-3). Shared by every
/// server instance through the database. Old windows are purged by the sweep.
abstract class RateLimitBucket
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  RateLimitBucket._({
    this.id,
    required this.authUserId,
    required this.action,
    required this.windowStart,
    int? hits,
  }) : hits = hits ?? 0;

  factory RateLimitBucket({
    int? id,
    required _is.UuidValue authUserId,
    required String action,
    required DateTime windowStart,
    int? hits,
  }) = _RateLimitBucketImpl;

  factory RateLimitBucket.fromJson(Map<String, dynamic> jsonSerialization) {
    return RateLimitBucket(
      id: jsonSerialization['id'] as int?,
      authUserId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['authUserId'],
      ),
      action: jsonSerialization['action'] as String,
      windowStart: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['windowStart'],
      ),
      hits: jsonSerialization['hits'] as int?,
    );
  }

  static final t = RateLimitBucketTable();

  static const db = RateLimitBucketRepository._();

  @override
  int? id;

  _is.UuidValue authUserId;

  String action;

  DateTime windowStart;

  int hits;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [RateLimitBucket]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  RateLimitBucket copyWith({
    int? id,
    _is.UuidValue? authUserId,
    String? action,
    DateTime? windowStart,
    int? hits,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'RateLimitBucket',
      if (id != null) 'id': id,
      'authUserId': authUserId.toJson(),
      'action': action,
      'windowStart': windowStart.toJson(),
      'hits': hits,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static RateLimitBucketInclude include() {
    return RateLimitBucketInclude._();
  }

  static RateLimitBucketIncludeList includeList({
    _is.WhereExpressionBuilder<RateLimitBucketTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<RateLimitBucketTable>? orderBy,
    _is.OrderByListBuilder<RateLimitBucketTable>? orderByList,
    RateLimitBucketInclude? include,
  }) {
    return RateLimitBucketIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(RateLimitBucket.t),
      orderByList: orderByList?.call(RateLimitBucket.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _RateLimitBucketImpl extends RateLimitBucket {
  _RateLimitBucketImpl({
    int? id,
    required _is.UuidValue authUserId,
    required String action,
    required DateTime windowStart,
    int? hits,
  }) : super._(
         id: id,
         authUserId: authUserId,
         action: action,
         windowStart: windowStart,
         hits: hits,
       );

  /// Returns a shallow copy of this [RateLimitBucket]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  RateLimitBucket copyWith({
    Object? id = _Undefined,
    _is.UuidValue? authUserId,
    String? action,
    DateTime? windowStart,
    int? hits,
  }) {
    return RateLimitBucket(
      id: id is int? ? id : this.id,
      authUserId: authUserId ?? this.authUserId,
      action: action ?? this.action,
      windowStart: windowStart ?? this.windowStart,
      hits: hits ?? this.hits,
    );
  }
}

class RateLimitBucketUpdateTable extends _is.UpdateTable<RateLimitBucketTable> {
  RateLimitBucketUpdateTable(super.table);

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

  _is.ColumnValue<DateTime, DateTime> windowStart(DateTime value) =>
      _is.ColumnValue(
        table.windowStart,
        value,
      );

  _is.ColumnValue<int, int> hits(int value) => _is.ColumnValue(
    table.hits,
    value,
  );
}

class RateLimitBucketTable extends _is.Table<int?> {
  RateLimitBucketTable({super.tableRelation})
    : super(tableName: 'fieldnote_rate_limit_bucket') {
    updateTable = RateLimitBucketUpdateTable(this);
    authUserId = _is.ColumnUuid(
      'authUserId',
      this,
    );
    action = _is.ColumnString(
      'action',
      this,
    );
    windowStart = _is.ColumnDateTime(
      'windowStart',
      this,
    );
    hits = _is.ColumnInt(
      'hits',
      this,
      hasDefault: true,
    );
  }

  late final RateLimitBucketUpdateTable updateTable;

  late final _is.ColumnUuid authUserId;

  late final _is.ColumnString action;

  late final _is.ColumnDateTime windowStart;

  late final _is.ColumnInt hits;

  @override
  List<_is.Column> get columns => [
    id,
    authUserId,
    action,
    windowStart,
    hits,
  ];
}

class RateLimitBucketInclude extends _is.IncludeObject {
  RateLimitBucketInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => RateLimitBucket.t;
}

class RateLimitBucketIncludeList extends _is.IncludeList {
  RateLimitBucketIncludeList._({
    _is.WhereExpressionBuilder<RateLimitBucketTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(RateLimitBucket.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => RateLimitBucket.t;
}

class RateLimitBucketRepository {
  const RateLimitBucketRepository._();

  /// Returns a list of [RateLimitBucket]s matching the given query parameters.
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
  Future<List<RateLimitBucket>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<RateLimitBucketTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<RateLimitBucketTable>? orderBy,
    _is.OrderByListBuilder<RateLimitBucketTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<RateLimitBucket>(
      where: where?.call(RateLimitBucket.t),
      orderBy: orderBy?.call(RateLimitBucket.t),
      orderByList: orderByList?.call(RateLimitBucket.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [RateLimitBucket] matching the given query parameters.
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
  Future<RateLimitBucket?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<RateLimitBucketTable>? where,
    int? offset,
    _is.OrderByBuilder<RateLimitBucketTable>? orderBy,
    _is.OrderByListBuilder<RateLimitBucketTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<RateLimitBucket>(
      where: where?.call(RateLimitBucket.t),
      orderBy: orderBy?.call(RateLimitBucket.t),
      orderByList: orderByList?.call(RateLimitBucket.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [RateLimitBucket] by its [id] or null if no such row exists.
  Future<RateLimitBucket?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<RateLimitBucket>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [RateLimitBucket]s in the list and returns the inserted rows.
  ///
  /// The returned [RateLimitBucket]s will have their `id` fields set.
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
  Future<List<RateLimitBucket>> insert(
    _is.DatabaseSession session,
    List<RateLimitBucket> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<RateLimitBucket>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [RateLimitBucket] and returns the inserted row.
  ///
  /// The returned [RateLimitBucket] will have its `id` field set.
  Future<RateLimitBucket> insertRow(
    _is.DatabaseSession session,
    RateLimitBucket row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<RateLimitBucket>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [RateLimitBucket]s in the list and returns the resulting rows.
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
  /// The returned [RateLimitBucket]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<RateLimitBucket>> upsert(
    _is.DatabaseSession session,
    List<RateLimitBucket> rows, {
    required _is.ColumnSelections<RateLimitBucketTable> conflictColumns,
    _is.ColumnSelections<RateLimitBucketTable>? updateColumns,
    _is.WhereExpressionBuilder<RateLimitBucketTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<RateLimitBucket>(
      rows,
      conflictColumns: conflictColumns(RateLimitBucket.t),
      updateColumns: updateColumns?.call(RateLimitBucket.t),
      updateWhere: updateWhere?.call(RateLimitBucket.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [RateLimitBucket] and returns the resulting row.
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
  /// The returned [RateLimitBucket] will have its `id` field set.
  Future<RateLimitBucket?> upsertRow(
    _is.DatabaseSession session,
    RateLimitBucket row, {
    required _is.ColumnSelections<RateLimitBucketTable> conflictColumns,
    _is.ColumnSelections<RateLimitBucketTable>? updateColumns,
    _is.WhereExpressionBuilder<RateLimitBucketTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<RateLimitBucket>(
      row,
      conflictColumns: conflictColumns(RateLimitBucket.t),
      updateColumns: updateColumns?.call(RateLimitBucket.t),
      updateWhere: updateWhere?.call(RateLimitBucket.t),
      transaction: transaction,
    );
  }

  /// Updates all [RateLimitBucket]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<RateLimitBucket>> update(
    _is.DatabaseSession session,
    List<RateLimitBucket> rows, {
    _is.ColumnSelections<RateLimitBucketTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<RateLimitBucket>(
      rows,
      columns: columns?.call(RateLimitBucket.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [RateLimitBucket]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<RateLimitBucket> updateRow(
    _is.DatabaseSession session,
    RateLimitBucket row, {
    _is.ColumnSelections<RateLimitBucketTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<RateLimitBucket>(
      row,
      columns: columns?.call(RateLimitBucket.t),
      transaction: transaction,
    );
  }

  /// Updates a single [RateLimitBucket] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<RateLimitBucket?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<RateLimitBucketUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<RateLimitBucket>(
      id,
      columnValues: columnValues(RateLimitBucket.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [RateLimitBucket]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<RateLimitBucket>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<RateLimitBucketUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<RateLimitBucketTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<RateLimitBucketTable>? orderBy,
    _is.OrderByListBuilder<RateLimitBucketTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<RateLimitBucket>(
      columnValues: columnValues(RateLimitBucket.t.updateTable),
      where: where(RateLimitBucket.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(RateLimitBucket.t),
      orderByList: orderByList?.call(RateLimitBucket.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [RateLimitBucket]s in the list and returns the deleted rows.
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
  Future<List<RateLimitBucket>> delete(
    _is.DatabaseSession session,
    List<RateLimitBucket> rows, {
    _is.OrderByBuilder<RateLimitBucketTable>? orderBy,
    _is.OrderByListBuilder<RateLimitBucketTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<RateLimitBucket>(
      rows,
      orderBy: orderBy?.call(RateLimitBucket.t),
      orderByList: orderByList?.call(RateLimitBucket.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [RateLimitBucket].
  Future<RateLimitBucket> deleteRow(
    _is.DatabaseSession session,
    RateLimitBucket row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<RateLimitBucket>(
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
  Future<List<RateLimitBucket>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<RateLimitBucketTable> where,
    _is.OrderByBuilder<RateLimitBucketTable>? orderBy,
    _is.OrderByListBuilder<RateLimitBucketTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<RateLimitBucket>(
      where: where(RateLimitBucket.t),
      orderBy: orderBy?.call(RateLimitBucket.t),
      orderByList: orderByList?.call(RateLimitBucket.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<RateLimitBucketTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<RateLimitBucket>(
      where: where?.call(RateLimitBucket.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [RateLimitBucket] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<RateLimitBucketTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<RateLimitBucket>(
      where: where(RateLimitBucket.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
