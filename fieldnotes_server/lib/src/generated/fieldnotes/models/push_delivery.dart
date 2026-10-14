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

/// One durable push attempt sequence per inbox item and registered device.
abstract class PushDelivery
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  PushDelivery._({
    this.id,
    required this.notificationId,
    required this.deviceId,
    required this.recipientAuthUserId,
    String? status,
    int? attempts,
    this.nextAttemptAt,
    this.lastError,
    DateTime? createdAt,
    this.sentAt,
  }) : status = status ?? 'pending',
       attempts = attempts ?? 0,
       createdAt = createdAt ?? DateTime.now();

  factory PushDelivery({
    int? id,
    required int notificationId,
    required int deviceId,
    required _is.UuidValue recipientAuthUserId,
    String? status,
    int? attempts,
    DateTime? nextAttemptAt,
    String? lastError,
    DateTime? createdAt,
    DateTime? sentAt,
  }) = _PushDeliveryImpl;

  factory PushDelivery.fromJson(Map<String, dynamic> jsonSerialization) {
    return PushDelivery(
      id: jsonSerialization['id'] as int?,
      notificationId: jsonSerialization['notificationId'] as int,
      deviceId: jsonSerialization['deviceId'] as int,
      recipientAuthUserId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['recipientAuthUserId'],
      ),
      status: jsonSerialization['status'] as String?,
      attempts: jsonSerialization['attempts'] as int?,
      nextAttemptAt: jsonSerialization['nextAttemptAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(
              jsonSerialization['nextAttemptAt'],
            ),
      lastError: jsonSerialization['lastError'] as String?,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      sentAt: jsonSerialization['sentAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['sentAt']),
    );
  }

  static final t = PushDeliveryTable();

  static const db = PushDeliveryRepository._();

  @override
  int? id;

  int notificationId;

  int deviceId;

  _is.UuidValue recipientAuthUserId;

  String status;

  int attempts;

  DateTime? nextAttemptAt;

  String? lastError;

  DateTime createdAt;

  DateTime? sentAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [PushDelivery]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  PushDelivery copyWith({
    int? id,
    int? notificationId,
    int? deviceId,
    _is.UuidValue? recipientAuthUserId,
    String? status,
    int? attempts,
    DateTime? nextAttemptAt,
    String? lastError,
    DateTime? createdAt,
    DateTime? sentAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PushDelivery',
      if (id != null) 'id': id,
      'notificationId': notificationId,
      'deviceId': deviceId,
      'recipientAuthUserId': recipientAuthUserId.toJson(),
      'status': status,
      'attempts': attempts,
      if (nextAttemptAt != null) 'nextAttemptAt': nextAttemptAt?.toJson(),
      if (lastError != null) 'lastError': lastError,
      'createdAt': createdAt.toJson(),
      if (sentAt != null) 'sentAt': sentAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static PushDeliveryInclude include() {
    return PushDeliveryInclude._();
  }

  static PushDeliveryIncludeList includeList({
    _is.WhereExpressionBuilder<PushDeliveryTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PushDeliveryTable>? orderBy,
    _is.OrderByListBuilder<PushDeliveryTable>? orderByList,
    PushDeliveryInclude? include,
  }) {
    return PushDeliveryIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(PushDelivery.t),
      orderByList: orderByList?.call(PushDelivery.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _PushDeliveryImpl extends PushDelivery {
  _PushDeliveryImpl({
    int? id,
    required int notificationId,
    required int deviceId,
    required _is.UuidValue recipientAuthUserId,
    String? status,
    int? attempts,
    DateTime? nextAttemptAt,
    String? lastError,
    DateTime? createdAt,
    DateTime? sentAt,
  }) : super._(
         id: id,
         notificationId: notificationId,
         deviceId: deviceId,
         recipientAuthUserId: recipientAuthUserId,
         status: status,
         attempts: attempts,
         nextAttemptAt: nextAttemptAt,
         lastError: lastError,
         createdAt: createdAt,
         sentAt: sentAt,
       );

  /// Returns a shallow copy of this [PushDelivery]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  PushDelivery copyWith({
    Object? id = _Undefined,
    int? notificationId,
    int? deviceId,
    _is.UuidValue? recipientAuthUserId,
    String? status,
    int? attempts,
    Object? nextAttemptAt = _Undefined,
    Object? lastError = _Undefined,
    DateTime? createdAt,
    Object? sentAt = _Undefined,
  }) {
    return PushDelivery(
      id: id is int? ? id : this.id,
      notificationId: notificationId ?? this.notificationId,
      deviceId: deviceId ?? this.deviceId,
      recipientAuthUserId: recipientAuthUserId ?? this.recipientAuthUserId,
      status: status ?? this.status,
      attempts: attempts ?? this.attempts,
      nextAttemptAt: nextAttemptAt is DateTime?
          ? nextAttemptAt
          : this.nextAttemptAt,
      lastError: lastError is String? ? lastError : this.lastError,
      createdAt: createdAt ?? this.createdAt,
      sentAt: sentAt is DateTime? ? sentAt : this.sentAt,
    );
  }
}

class PushDeliveryUpdateTable extends _is.UpdateTable<PushDeliveryTable> {
  PushDeliveryUpdateTable(super.table);

  _is.ColumnValue<int, int> notificationId(int value) => _is.ColumnValue(
    table.notificationId,
    value,
  );

  _is.ColumnValue<int, int> deviceId(int value) => _is.ColumnValue(
    table.deviceId,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> recipientAuthUserId(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.recipientAuthUserId,
    value,
  );

  _is.ColumnValue<String, String> status(String value) => _is.ColumnValue(
    table.status,
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

  _is.ColumnValue<String, String> lastError(String? value) => _is.ColumnValue(
    table.lastError,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> sentAt(DateTime? value) =>
      _is.ColumnValue(
        table.sentAt,
        value,
      );
}

class PushDeliveryTable extends _is.Table<int?> {
  PushDeliveryTable({super.tableRelation})
    : super(tableName: 'fieldnote_push_delivery') {
    updateTable = PushDeliveryUpdateTable(this);
    notificationId = _is.ColumnInt(
      'notificationId',
      this,
    );
    deviceId = _is.ColumnInt(
      'deviceId',
      this,
    );
    recipientAuthUserId = _is.ColumnUuid(
      'recipientAuthUserId',
      this,
    );
    status = _is.ColumnString(
      'status',
      this,
      hasDefault: true,
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
    lastError = _is.ColumnString(
      'lastError',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
      hasDefault: true,
    );
    sentAt = _is.ColumnDateTime(
      'sentAt',
      this,
    );
  }

  late final PushDeliveryUpdateTable updateTable;

  late final _is.ColumnInt notificationId;

  late final _is.ColumnInt deviceId;

  late final _is.ColumnUuid recipientAuthUserId;

  late final _is.ColumnString status;

  late final _is.ColumnInt attempts;

  late final _is.ColumnDateTime nextAttemptAt;

  late final _is.ColumnString lastError;

  late final _is.ColumnDateTime createdAt;

  late final _is.ColumnDateTime sentAt;

  @override
  List<_is.Column> get columns => [
    id,
    notificationId,
    deviceId,
    recipientAuthUserId,
    status,
    attempts,
    nextAttemptAt,
    lastError,
    createdAt,
    sentAt,
  ];
}

class PushDeliveryInclude extends _is.IncludeObject {
  PushDeliveryInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => PushDelivery.t;
}

class PushDeliveryIncludeList extends _is.IncludeList {
  PushDeliveryIncludeList._({
    _is.WhereExpressionBuilder<PushDeliveryTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(PushDelivery.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => PushDelivery.t;
}

class PushDeliveryRepository {
  const PushDeliveryRepository._();

  /// Returns a list of [PushDelivery]s matching the given query parameters.
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
  Future<List<PushDelivery>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PushDeliveryTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PushDeliveryTable>? orderBy,
    _is.OrderByListBuilder<PushDeliveryTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<PushDelivery>(
      where: where?.call(PushDelivery.t),
      orderBy: orderBy?.call(PushDelivery.t),
      orderByList: orderByList?.call(PushDelivery.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [PushDelivery] matching the given query parameters.
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
  Future<PushDelivery?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PushDeliveryTable>? where,
    int? offset,
    _is.OrderByBuilder<PushDeliveryTable>? orderBy,
    _is.OrderByListBuilder<PushDeliveryTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<PushDelivery>(
      where: where?.call(PushDelivery.t),
      orderBy: orderBy?.call(PushDelivery.t),
      orderByList: orderByList?.call(PushDelivery.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [PushDelivery] by its [id] or null if no such row exists.
  Future<PushDelivery?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<PushDelivery>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [PushDelivery]s in the list and returns the inserted rows.
  ///
  /// The returned [PushDelivery]s will have their `id` fields set.
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
  Future<List<PushDelivery>> insert(
    _is.DatabaseSession session,
    List<PushDelivery> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<PushDelivery>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [PushDelivery] and returns the inserted row.
  ///
  /// The returned [PushDelivery] will have its `id` field set.
  Future<PushDelivery> insertRow(
    _is.DatabaseSession session,
    PushDelivery row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<PushDelivery>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [PushDelivery]s in the list and returns the resulting rows.
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
  /// The returned [PushDelivery]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<PushDelivery>> upsert(
    _is.DatabaseSession session,
    List<PushDelivery> rows, {
    required _is.ColumnSelections<PushDeliveryTable> conflictColumns,
    _is.ColumnSelections<PushDeliveryTable>? updateColumns,
    _is.WhereExpressionBuilder<PushDeliveryTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<PushDelivery>(
      rows,
      conflictColumns: conflictColumns(PushDelivery.t),
      updateColumns: updateColumns?.call(PushDelivery.t),
      updateWhere: updateWhere?.call(PushDelivery.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [PushDelivery] and returns the resulting row.
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
  /// The returned [PushDelivery] will have its `id` field set.
  Future<PushDelivery?> upsertRow(
    _is.DatabaseSession session,
    PushDelivery row, {
    required _is.ColumnSelections<PushDeliveryTable> conflictColumns,
    _is.ColumnSelections<PushDeliveryTable>? updateColumns,
    _is.WhereExpressionBuilder<PushDeliveryTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<PushDelivery>(
      row,
      conflictColumns: conflictColumns(PushDelivery.t),
      updateColumns: updateColumns?.call(PushDelivery.t),
      updateWhere: updateWhere?.call(PushDelivery.t),
      transaction: transaction,
    );
  }

  /// Updates all [PushDelivery]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<PushDelivery>> update(
    _is.DatabaseSession session,
    List<PushDelivery> rows, {
    _is.ColumnSelections<PushDeliveryTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<PushDelivery>(
      rows,
      columns: columns?.call(PushDelivery.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [PushDelivery]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<PushDelivery> updateRow(
    _is.DatabaseSession session,
    PushDelivery row, {
    _is.ColumnSelections<PushDeliveryTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<PushDelivery>(
      row,
      columns: columns?.call(PushDelivery.t),
      transaction: transaction,
    );
  }

  /// Updates a single [PushDelivery] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<PushDelivery?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<PushDeliveryUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<PushDelivery>(
      id,
      columnValues: columnValues(PushDelivery.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [PushDelivery]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<PushDelivery>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<PushDeliveryUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<PushDeliveryTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PushDeliveryTable>? orderBy,
    _is.OrderByListBuilder<PushDeliveryTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<PushDelivery>(
      columnValues: columnValues(PushDelivery.t.updateTable),
      where: where(PushDelivery.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(PushDelivery.t),
      orderByList: orderByList?.call(PushDelivery.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [PushDelivery]s in the list and returns the deleted rows.
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
  Future<List<PushDelivery>> delete(
    _is.DatabaseSession session,
    List<PushDelivery> rows, {
    _is.OrderByBuilder<PushDeliveryTable>? orderBy,
    _is.OrderByListBuilder<PushDeliveryTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<PushDelivery>(
      rows,
      orderBy: orderBy?.call(PushDelivery.t),
      orderByList: orderByList?.call(PushDelivery.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [PushDelivery].
  Future<PushDelivery> deleteRow(
    _is.DatabaseSession session,
    PushDelivery row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<PushDelivery>(
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
  Future<List<PushDelivery>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<PushDeliveryTable> where,
    _is.OrderByBuilder<PushDeliveryTable>? orderBy,
    _is.OrderByListBuilder<PushDeliveryTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<PushDelivery>(
      where: where(PushDelivery.t),
      orderBy: orderBy?.call(PushDelivery.t),
      orderByList: orderByList?.call(PushDelivery.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PushDeliveryTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<PushDelivery>(
      where: where?.call(PushDelivery.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [PushDelivery] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<PushDeliveryTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<PushDelivery>(
      where: where(PushDelivery.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
