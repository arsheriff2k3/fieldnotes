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

/// One account deletion request (P0-6). Created by requestAccountDeletion and
/// executed by the outbox future call. The row keeps only the deleted auth
/// user id so the request stays idempotent; it never stores the anonymous id
/// that replaced the user in retained financial records.
///
/// status: pending | processing | completed | failed
abstract class AccountDeletionRequest
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  AccountDeletionRequest._({
    this.id,
    required this.authUserId,
    String? status,
    this.lastError,
    int? attempts,
    this.nextAttemptAt,
    DateTime? requestedAt,
    this.processedAt,
    this.completedAt,
    DateTime? updatedAt,
  }) : status = status ?? 'pending',
       attempts = attempts ?? 0,
       requestedAt = requestedAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory AccountDeletionRequest({
    int? id,
    required _is.UuidValue authUserId,
    String? status,
    String? lastError,
    int? attempts,
    DateTime? nextAttemptAt,
    DateTime? requestedAt,
    DateTime? processedAt,
    DateTime? completedAt,
    DateTime? updatedAt,
  }) = _AccountDeletionRequestImpl;

  factory AccountDeletionRequest.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return AccountDeletionRequest(
      id: jsonSerialization['id'] as int?,
      authUserId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['authUserId'],
      ),
      status: jsonSerialization['status'] as String?,
      lastError: jsonSerialization['lastError'] as String?,
      attempts: jsonSerialization['attempts'] as int?,
      nextAttemptAt: jsonSerialization['nextAttemptAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(
              jsonSerialization['nextAttemptAt'],
            ),
      requestedAt: jsonSerialization['requestedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(
              jsonSerialization['requestedAt'],
            ),
      processedAt: jsonSerialization['processedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(
              jsonSerialization['processedAt'],
            ),
      completedAt: jsonSerialization['completedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(
              jsonSerialization['completedAt'],
            ),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  static final t = AccountDeletionRequestTable();

  static const db = AccountDeletionRequestRepository._();

  @override
  int? id;

  _is.UuidValue authUserId;

  String status;

  /// Client-safe error code when the last attempt failed.
  String? lastError;

  int attempts;

  DateTime? nextAttemptAt;

  DateTime requestedAt;

  DateTime? processedAt;

  DateTime? completedAt;

  DateTime updatedAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [AccountDeletionRequest]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  AccountDeletionRequest copyWith({
    int? id,
    _is.UuidValue? authUserId,
    String? status,
    String? lastError,
    int? attempts,
    DateTime? nextAttemptAt,
    DateTime? requestedAt,
    DateTime? processedAt,
    DateTime? completedAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AccountDeletionRequest',
      if (id != null) 'id': id,
      'authUserId': authUserId.toJson(),
      'status': status,
      if (lastError != null) 'lastError': lastError,
      'attempts': attempts,
      if (nextAttemptAt != null) 'nextAttemptAt': nextAttemptAt?.toJson(),
      'requestedAt': requestedAt.toJson(),
      if (processedAt != null) 'processedAt': processedAt?.toJson(),
      if (completedAt != null) 'completedAt': completedAt?.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AccountDeletionRequest',
      if (id != null) 'id': id,
      'authUserId': authUserId.toJson(),
      'status': status,
      if (lastError != null) 'lastError': lastError,
      'attempts': attempts,
      if (nextAttemptAt != null) 'nextAttemptAt': nextAttemptAt?.toJson(),
      'requestedAt': requestedAt.toJson(),
      if (processedAt != null) 'processedAt': processedAt?.toJson(),
      if (completedAt != null) 'completedAt': completedAt?.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  static AccountDeletionRequestInclude include() {
    return AccountDeletionRequestInclude._();
  }

  static AccountDeletionRequestIncludeList includeList({
    _is.WhereExpressionBuilder<AccountDeletionRequestTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AccountDeletionRequestTable>? orderBy,
    _is.OrderByListBuilder<AccountDeletionRequestTable>? orderByList,
    AccountDeletionRequestInclude? include,
  }) {
    return AccountDeletionRequestIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(AccountDeletionRequest.t),
      orderByList: orderByList?.call(AccountDeletionRequest.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AccountDeletionRequestImpl extends AccountDeletionRequest {
  _AccountDeletionRequestImpl({
    int? id,
    required _is.UuidValue authUserId,
    String? status,
    String? lastError,
    int? attempts,
    DateTime? nextAttemptAt,
    DateTime? requestedAt,
    DateTime? processedAt,
    DateTime? completedAt,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         authUserId: authUserId,
         status: status,
         lastError: lastError,
         attempts: attempts,
         nextAttemptAt: nextAttemptAt,
         requestedAt: requestedAt,
         processedAt: processedAt,
         completedAt: completedAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [AccountDeletionRequest]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  AccountDeletionRequest copyWith({
    Object? id = _Undefined,
    _is.UuidValue? authUserId,
    String? status,
    Object? lastError = _Undefined,
    int? attempts,
    Object? nextAttemptAt = _Undefined,
    DateTime? requestedAt,
    Object? processedAt = _Undefined,
    Object? completedAt = _Undefined,
    DateTime? updatedAt,
  }) {
    return AccountDeletionRequest(
      id: id is int? ? id : this.id,
      authUserId: authUserId ?? this.authUserId,
      status: status ?? this.status,
      lastError: lastError is String? ? lastError : this.lastError,
      attempts: attempts ?? this.attempts,
      nextAttemptAt: nextAttemptAt is DateTime?
          ? nextAttemptAt
          : this.nextAttemptAt,
      requestedAt: requestedAt ?? this.requestedAt,
      processedAt: processedAt is DateTime? ? processedAt : this.processedAt,
      completedAt: completedAt is DateTime? ? completedAt : this.completedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class AccountDeletionRequestUpdateTable
    extends _is.UpdateTable<AccountDeletionRequestTable> {
  AccountDeletionRequestUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> authUserId(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.authUserId,
    value,
  );

  _is.ColumnValue<String, String> status(String value) => _is.ColumnValue(
    table.status,
    value,
  );

  _is.ColumnValue<String, String> lastError(String? value) => _is.ColumnValue(
    table.lastError,
    value,
  );

  _is.ColumnValue<int, int> attempts(int value) => _is.ColumnValue(
    table.attempts,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> nextAttemptAt(DateTime? value) =>
      _is.ColumnValue(
        table.nextAttemptAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> requestedAt(DateTime value) =>
      _is.ColumnValue(
        table.requestedAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> processedAt(DateTime? value) =>
      _is.ColumnValue(
        table.processedAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> completedAt(DateTime? value) =>
      _is.ColumnValue(
        table.completedAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> updatedAt(DateTime value) =>
      _is.ColumnValue(
        table.updatedAt,
        value,
      );
}

class AccountDeletionRequestTable extends _is.Table<int?> {
  AccountDeletionRequestTable({super.tableRelation})
    : super(tableName: 'fieldnote_account_deletion_request') {
    updateTable = AccountDeletionRequestUpdateTable(this);
    authUserId = _is.ColumnUuid(
      'authUserId',
      this,
    );
    status = _is.ColumnString(
      'status',
      this,
      hasDefault: true,
    );
    lastError = _is.ColumnString(
      'lastError',
      this,
    );
    attempts = _is.ColumnInt(
      'attempts',
      this,
      hasDefault: true,
    );
    nextAttemptAt = _is.ColumnDateTime(
      'nextAttemptAt',
      this,
    );
    requestedAt = _is.ColumnDateTime(
      'requestedAt',
      this,
      hasDefault: true,
    );
    processedAt = _is.ColumnDateTime(
      'processedAt',
      this,
    );
    completedAt = _is.ColumnDateTime(
      'completedAt',
      this,
    );
    updatedAt = _is.ColumnDateTime(
      'updatedAt',
      this,
      hasDefault: true,
    );
  }

  late final AccountDeletionRequestUpdateTable updateTable;

  late final _is.ColumnUuid authUserId;

  late final _is.ColumnString status;

  /// Client-safe error code when the last attempt failed.
  late final _is.ColumnString lastError;

  late final _is.ColumnInt attempts;

  late final _is.ColumnDateTime nextAttemptAt;

  late final _is.ColumnDateTime requestedAt;

  late final _is.ColumnDateTime processedAt;

  late final _is.ColumnDateTime completedAt;

  late final _is.ColumnDateTime updatedAt;

  @override
  List<_is.Column> get columns => [
    id,
    authUserId,
    status,
    lastError,
    attempts,
    nextAttemptAt,
    requestedAt,
    processedAt,
    completedAt,
    updatedAt,
  ];
}

class AccountDeletionRequestInclude extends _is.IncludeObject {
  AccountDeletionRequestInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => AccountDeletionRequest.t;
}

class AccountDeletionRequestIncludeList extends _is.IncludeList {
  AccountDeletionRequestIncludeList._({
    _is.WhereExpressionBuilder<AccountDeletionRequestTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(AccountDeletionRequest.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => AccountDeletionRequest.t;
}

class AccountDeletionRequestRepository {
  const AccountDeletionRequestRepository._();

  /// Returns a list of [AccountDeletionRequest]s matching the given query parameters.
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
  Future<List<AccountDeletionRequest>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AccountDeletionRequestTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AccountDeletionRequestTable>? orderBy,
    _is.OrderByListBuilder<AccountDeletionRequestTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<AccountDeletionRequest>(
      where: where?.call(AccountDeletionRequest.t),
      orderBy: orderBy?.call(AccountDeletionRequest.t),
      orderByList: orderByList?.call(AccountDeletionRequest.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [AccountDeletionRequest] matching the given query parameters.
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
  Future<AccountDeletionRequest?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AccountDeletionRequestTable>? where,
    int? offset,
    _is.OrderByBuilder<AccountDeletionRequestTable>? orderBy,
    _is.OrderByListBuilder<AccountDeletionRequestTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<AccountDeletionRequest>(
      where: where?.call(AccountDeletionRequest.t),
      orderBy: orderBy?.call(AccountDeletionRequest.t),
      orderByList: orderByList?.call(AccountDeletionRequest.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [AccountDeletionRequest] by its [id] or null if no such row exists.
  Future<AccountDeletionRequest?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<AccountDeletionRequest>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [AccountDeletionRequest]s in the list and returns the inserted rows.
  ///
  /// The returned [AccountDeletionRequest]s will have their `id` fields set.
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
  Future<List<AccountDeletionRequest>> insert(
    _is.DatabaseSession session,
    List<AccountDeletionRequest> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<AccountDeletionRequest>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [AccountDeletionRequest] and returns the inserted row.
  ///
  /// The returned [AccountDeletionRequest] will have its `id` field set.
  Future<AccountDeletionRequest> insertRow(
    _is.DatabaseSession session,
    AccountDeletionRequest row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<AccountDeletionRequest>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [AccountDeletionRequest]s in the list and returns the resulting rows.
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
  /// The returned [AccountDeletionRequest]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AccountDeletionRequest>> upsert(
    _is.DatabaseSession session,
    List<AccountDeletionRequest> rows, {
    required _is.ColumnSelections<AccountDeletionRequestTable> conflictColumns,
    _is.ColumnSelections<AccountDeletionRequestTable>? updateColumns,
    _is.WhereExpressionBuilder<AccountDeletionRequestTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<AccountDeletionRequest>(
      rows,
      conflictColumns: conflictColumns(AccountDeletionRequest.t),
      updateColumns: updateColumns?.call(AccountDeletionRequest.t),
      updateWhere: updateWhere?.call(AccountDeletionRequest.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [AccountDeletionRequest] and returns the resulting row.
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
  /// The returned [AccountDeletionRequest] will have its `id` field set.
  Future<AccountDeletionRequest?> upsertRow(
    _is.DatabaseSession session,
    AccountDeletionRequest row, {
    required _is.ColumnSelections<AccountDeletionRequestTable> conflictColumns,
    _is.ColumnSelections<AccountDeletionRequestTable>? updateColumns,
    _is.WhereExpressionBuilder<AccountDeletionRequestTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<AccountDeletionRequest>(
      row,
      conflictColumns: conflictColumns(AccountDeletionRequest.t),
      updateColumns: updateColumns?.call(AccountDeletionRequest.t),
      updateWhere: updateWhere?.call(AccountDeletionRequest.t),
      transaction: transaction,
    );
  }

  /// Updates all [AccountDeletionRequest]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AccountDeletionRequest>> update(
    _is.DatabaseSession session,
    List<AccountDeletionRequest> rows, {
    _is.ColumnSelections<AccountDeletionRequestTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<AccountDeletionRequest>(
      rows,
      columns: columns?.call(AccountDeletionRequest.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [AccountDeletionRequest]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<AccountDeletionRequest> updateRow(
    _is.DatabaseSession session,
    AccountDeletionRequest row, {
    _is.ColumnSelections<AccountDeletionRequestTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<AccountDeletionRequest>(
      row,
      columns: columns?.call(AccountDeletionRequest.t),
      transaction: transaction,
    );
  }

  /// Updates a single [AccountDeletionRequest] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<AccountDeletionRequest?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<AccountDeletionRequestUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<AccountDeletionRequest>(
      id,
      columnValues: columnValues(AccountDeletionRequest.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [AccountDeletionRequest]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AccountDeletionRequest>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<AccountDeletionRequestUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<AccountDeletionRequestTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AccountDeletionRequestTable>? orderBy,
    _is.OrderByListBuilder<AccountDeletionRequestTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<AccountDeletionRequest>(
      columnValues: columnValues(AccountDeletionRequest.t.updateTable),
      where: where(AccountDeletionRequest.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(AccountDeletionRequest.t),
      orderByList: orderByList?.call(AccountDeletionRequest.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [AccountDeletionRequest]s in the list and returns the deleted rows.
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
  Future<List<AccountDeletionRequest>> delete(
    _is.DatabaseSession session,
    List<AccountDeletionRequest> rows, {
    _is.OrderByBuilder<AccountDeletionRequestTable>? orderBy,
    _is.OrderByListBuilder<AccountDeletionRequestTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<AccountDeletionRequest>(
      rows,
      orderBy: orderBy?.call(AccountDeletionRequest.t),
      orderByList: orderByList?.call(AccountDeletionRequest.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [AccountDeletionRequest].
  Future<AccountDeletionRequest> deleteRow(
    _is.DatabaseSession session,
    AccountDeletionRequest row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<AccountDeletionRequest>(
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
  Future<List<AccountDeletionRequest>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<AccountDeletionRequestTable> where,
    _is.OrderByBuilder<AccountDeletionRequestTable>? orderBy,
    _is.OrderByListBuilder<AccountDeletionRequestTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<AccountDeletionRequest>(
      where: where(AccountDeletionRequest.t),
      orderBy: orderBy?.call(AccountDeletionRequest.t),
      orderByList: orderByList?.call(AccountDeletionRequest.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AccountDeletionRequestTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<AccountDeletionRequest>(
      where: where?.call(AccountDeletionRequest.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [AccountDeletionRequest] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<AccountDeletionRequestTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<AccountDeletionRequest>(
      where: where(AccountDeletionRequest.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
