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

abstract class PaymentWebhookEvent
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  PaymentWebhookEvent._({
    this.id,
    String? provider,
    required this.eventId,
    required this.eventType,
    required this.payloadSha256,
    String? status,
    this.detail,
    int? attempts,
    DateTime? receivedAt,
    this.processedAt,
  }) : provider = provider ?? 'razorpay',
       status = status ?? 'received',
       attempts = attempts ?? 1,
       receivedAt = receivedAt ?? DateTime.now();

  factory PaymentWebhookEvent({
    int? id,
    String? provider,
    required String eventId,
    required String eventType,
    required String payloadSha256,
    String? status,
    String? detail,
    int? attempts,
    DateTime? receivedAt,
    DateTime? processedAt,
  }) = _PaymentWebhookEventImpl;

  factory PaymentWebhookEvent.fromJson(Map<String, dynamic> jsonSerialization) {
    return PaymentWebhookEvent(
      id: jsonSerialization['id'] as int?,
      provider: jsonSerialization['provider'] as String?,
      eventId: jsonSerialization['eventId'] as String,
      eventType: jsonSerialization['eventType'] as String,
      payloadSha256: jsonSerialization['payloadSha256'] as String,
      status: jsonSerialization['status'] as String?,
      detail: jsonSerialization['detail'] as String?,
      attempts: jsonSerialization['attempts'] as int?,
      receivedAt: jsonSerialization['receivedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['receivedAt']),
      processedAt: jsonSerialization['processedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(
              jsonSerialization['processedAt'],
            ),
    );
  }

  static final t = PaymentWebhookEventTable();

  static const db = PaymentWebhookEventRepository._();

  @override
  int? id;

  String provider;

  String eventId;

  String eventType;

  String payloadSha256;

  String status;

  String? detail;

  int attempts;

  DateTime receivedAt;

  DateTime? processedAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [PaymentWebhookEvent]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  PaymentWebhookEvent copyWith({
    int? id,
    String? provider,
    String? eventId,
    String? eventType,
    String? payloadSha256,
    String? status,
    String? detail,
    int? attempts,
    DateTime? receivedAt,
    DateTime? processedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PaymentWebhookEvent',
      if (id != null) 'id': id,
      'provider': provider,
      'eventId': eventId,
      'eventType': eventType,
      'payloadSha256': payloadSha256,
      'status': status,
      if (detail != null) 'detail': detail,
      'attempts': attempts,
      'receivedAt': receivedAt.toJson(),
      if (processedAt != null) 'processedAt': processedAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'PaymentWebhookEvent',
      if (id != null) 'id': id,
      'provider': provider,
      'eventId': eventId,
      'eventType': eventType,
      'payloadSha256': payloadSha256,
      'status': status,
      if (detail != null) 'detail': detail,
      'attempts': attempts,
      'receivedAt': receivedAt.toJson(),
      if (processedAt != null) 'processedAt': processedAt?.toJson(),
    };
  }

  static PaymentWebhookEventInclude include() {
    return PaymentWebhookEventInclude._();
  }

  static PaymentWebhookEventIncludeList includeList({
    _is.WhereExpressionBuilder<PaymentWebhookEventTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PaymentWebhookEventTable>? orderBy,
    _is.OrderByListBuilder<PaymentWebhookEventTable>? orderByList,
    PaymentWebhookEventInclude? include,
  }) {
    return PaymentWebhookEventIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(PaymentWebhookEvent.t),
      orderByList: orderByList?.call(PaymentWebhookEvent.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _PaymentWebhookEventImpl extends PaymentWebhookEvent {
  _PaymentWebhookEventImpl({
    int? id,
    String? provider,
    required String eventId,
    required String eventType,
    required String payloadSha256,
    String? status,
    String? detail,
    int? attempts,
    DateTime? receivedAt,
    DateTime? processedAt,
  }) : super._(
         id: id,
         provider: provider,
         eventId: eventId,
         eventType: eventType,
         payloadSha256: payloadSha256,
         status: status,
         detail: detail,
         attempts: attempts,
         receivedAt: receivedAt,
         processedAt: processedAt,
       );

  /// Returns a shallow copy of this [PaymentWebhookEvent]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  PaymentWebhookEvent copyWith({
    Object? id = _Undefined,
    String? provider,
    String? eventId,
    String? eventType,
    String? payloadSha256,
    String? status,
    Object? detail = _Undefined,
    int? attempts,
    DateTime? receivedAt,
    Object? processedAt = _Undefined,
  }) {
    return PaymentWebhookEvent(
      id: id is int? ? id : this.id,
      provider: provider ?? this.provider,
      eventId: eventId ?? this.eventId,
      eventType: eventType ?? this.eventType,
      payloadSha256: payloadSha256 ?? this.payloadSha256,
      status: status ?? this.status,
      detail: detail is String? ? detail : this.detail,
      attempts: attempts ?? this.attempts,
      receivedAt: receivedAt ?? this.receivedAt,
      processedAt: processedAt is DateTime? ? processedAt : this.processedAt,
    );
  }
}

class PaymentWebhookEventUpdateTable
    extends _is.UpdateTable<PaymentWebhookEventTable> {
  PaymentWebhookEventUpdateTable(super.table);

  _is.ColumnValue<String, String> provider(String value) => _is.ColumnValue(
    table.provider,
    value,
  );

  _is.ColumnValue<String, String> eventId(String value) => _is.ColumnValue(
    table.eventId,
    value,
  );

  _is.ColumnValue<String, String> eventType(String value) => _is.ColumnValue(
    table.eventType,
    value,
  );

  _is.ColumnValue<String, String> payloadSha256(String value) =>
      _is.ColumnValue(
        table.payloadSha256,
        value,
      );

  _is.ColumnValue<String, String> status(String value) => _is.ColumnValue(
    table.status,
    value,
  );

  _is.ColumnValue<String, String> detail(String? value) => _is.ColumnValue(
    table.detail,
    value,
  );

  _is.ColumnValue<int, int> attempts(int value) => _is.ColumnValue(
    table.attempts,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> receivedAt(DateTime value) =>
      _is.ColumnValue(
        table.receivedAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> processedAt(DateTime? value) =>
      _is.ColumnValue(
        table.processedAt,
        value,
      );
}

class PaymentWebhookEventTable extends _is.Table<int?> {
  PaymentWebhookEventTable({super.tableRelation})
    : super(tableName: 'fieldnote_payment_webhook_event') {
    updateTable = PaymentWebhookEventUpdateTable(this);
    provider = _is.ColumnString(
      'provider',
      this,
      hasDefault: true,
    );
    eventId = _is.ColumnString(
      'eventId',
      this,
    );
    eventType = _is.ColumnString(
      'eventType',
      this,
    );
    payloadSha256 = _is.ColumnString(
      'payloadSha256',
      this,
    );
    status = _is.ColumnString(
      'status',
      this,
      hasDefault: true,
    );
    detail = _is.ColumnString(
      'detail',
      this,
    );
    attempts = _is.ColumnInt(
      'attempts',
      this,
      hasDefault: true,
    );
    receivedAt = _is.ColumnDateTime(
      'receivedAt',
      this,
      hasDefault: true,
    );
    processedAt = _is.ColumnDateTime(
      'processedAt',
      this,
    );
  }

  late final PaymentWebhookEventUpdateTable updateTable;

  late final _is.ColumnString provider;

  late final _is.ColumnString eventId;

  late final _is.ColumnString eventType;

  late final _is.ColumnString payloadSha256;

  late final _is.ColumnString status;

  late final _is.ColumnString detail;

  late final _is.ColumnInt attempts;

  late final _is.ColumnDateTime receivedAt;

  late final _is.ColumnDateTime processedAt;

  @override
  List<_is.Column> get columns => [
    id,
    provider,
    eventId,
    eventType,
    payloadSha256,
    status,
    detail,
    attempts,
    receivedAt,
    processedAt,
  ];
}

class PaymentWebhookEventInclude extends _is.IncludeObject {
  PaymentWebhookEventInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => PaymentWebhookEvent.t;
}

class PaymentWebhookEventIncludeList extends _is.IncludeList {
  PaymentWebhookEventIncludeList._({
    _is.WhereExpressionBuilder<PaymentWebhookEventTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(PaymentWebhookEvent.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => PaymentWebhookEvent.t;
}

class PaymentWebhookEventRepository {
  const PaymentWebhookEventRepository._();

  /// Returns a list of [PaymentWebhookEvent]s matching the given query parameters.
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
  Future<List<PaymentWebhookEvent>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PaymentWebhookEventTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PaymentWebhookEventTable>? orderBy,
    _is.OrderByListBuilder<PaymentWebhookEventTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<PaymentWebhookEvent>(
      where: where?.call(PaymentWebhookEvent.t),
      orderBy: orderBy?.call(PaymentWebhookEvent.t),
      orderByList: orderByList?.call(PaymentWebhookEvent.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [PaymentWebhookEvent] matching the given query parameters.
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
  Future<PaymentWebhookEvent?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PaymentWebhookEventTable>? where,
    int? offset,
    _is.OrderByBuilder<PaymentWebhookEventTable>? orderBy,
    _is.OrderByListBuilder<PaymentWebhookEventTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<PaymentWebhookEvent>(
      where: where?.call(PaymentWebhookEvent.t),
      orderBy: orderBy?.call(PaymentWebhookEvent.t),
      orderByList: orderByList?.call(PaymentWebhookEvent.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [PaymentWebhookEvent] by its [id] or null if no such row exists.
  Future<PaymentWebhookEvent?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<PaymentWebhookEvent>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [PaymentWebhookEvent]s in the list and returns the inserted rows.
  ///
  /// The returned [PaymentWebhookEvent]s will have their `id` fields set.
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
  Future<List<PaymentWebhookEvent>> insert(
    _is.DatabaseSession session,
    List<PaymentWebhookEvent> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<PaymentWebhookEvent>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [PaymentWebhookEvent] and returns the inserted row.
  ///
  /// The returned [PaymentWebhookEvent] will have its `id` field set.
  Future<PaymentWebhookEvent> insertRow(
    _is.DatabaseSession session,
    PaymentWebhookEvent row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<PaymentWebhookEvent>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [PaymentWebhookEvent]s in the list and returns the resulting rows.
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
  /// The returned [PaymentWebhookEvent]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<PaymentWebhookEvent>> upsert(
    _is.DatabaseSession session,
    List<PaymentWebhookEvent> rows, {
    required _is.ColumnSelections<PaymentWebhookEventTable> conflictColumns,
    _is.ColumnSelections<PaymentWebhookEventTable>? updateColumns,
    _is.WhereExpressionBuilder<PaymentWebhookEventTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<PaymentWebhookEvent>(
      rows,
      conflictColumns: conflictColumns(PaymentWebhookEvent.t),
      updateColumns: updateColumns?.call(PaymentWebhookEvent.t),
      updateWhere: updateWhere?.call(PaymentWebhookEvent.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [PaymentWebhookEvent] and returns the resulting row.
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
  /// The returned [PaymentWebhookEvent] will have its `id` field set.
  Future<PaymentWebhookEvent?> upsertRow(
    _is.DatabaseSession session,
    PaymentWebhookEvent row, {
    required _is.ColumnSelections<PaymentWebhookEventTable> conflictColumns,
    _is.ColumnSelections<PaymentWebhookEventTable>? updateColumns,
    _is.WhereExpressionBuilder<PaymentWebhookEventTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<PaymentWebhookEvent>(
      row,
      conflictColumns: conflictColumns(PaymentWebhookEvent.t),
      updateColumns: updateColumns?.call(PaymentWebhookEvent.t),
      updateWhere: updateWhere?.call(PaymentWebhookEvent.t),
      transaction: transaction,
    );
  }

  /// Updates all [PaymentWebhookEvent]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<PaymentWebhookEvent>> update(
    _is.DatabaseSession session,
    List<PaymentWebhookEvent> rows, {
    _is.ColumnSelections<PaymentWebhookEventTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<PaymentWebhookEvent>(
      rows,
      columns: columns?.call(PaymentWebhookEvent.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [PaymentWebhookEvent]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<PaymentWebhookEvent> updateRow(
    _is.DatabaseSession session,
    PaymentWebhookEvent row, {
    _is.ColumnSelections<PaymentWebhookEventTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<PaymentWebhookEvent>(
      row,
      columns: columns?.call(PaymentWebhookEvent.t),
      transaction: transaction,
    );
  }

  /// Updates a single [PaymentWebhookEvent] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<PaymentWebhookEvent?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<PaymentWebhookEventUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<PaymentWebhookEvent>(
      id,
      columnValues: columnValues(PaymentWebhookEvent.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [PaymentWebhookEvent]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<PaymentWebhookEvent>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<PaymentWebhookEventUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<PaymentWebhookEventTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PaymentWebhookEventTable>? orderBy,
    _is.OrderByListBuilder<PaymentWebhookEventTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<PaymentWebhookEvent>(
      columnValues: columnValues(PaymentWebhookEvent.t.updateTable),
      where: where(PaymentWebhookEvent.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(PaymentWebhookEvent.t),
      orderByList: orderByList?.call(PaymentWebhookEvent.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [PaymentWebhookEvent]s in the list and returns the deleted rows.
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
  Future<List<PaymentWebhookEvent>> delete(
    _is.DatabaseSession session,
    List<PaymentWebhookEvent> rows, {
    _is.OrderByBuilder<PaymentWebhookEventTable>? orderBy,
    _is.OrderByListBuilder<PaymentWebhookEventTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<PaymentWebhookEvent>(
      rows,
      orderBy: orderBy?.call(PaymentWebhookEvent.t),
      orderByList: orderByList?.call(PaymentWebhookEvent.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [PaymentWebhookEvent].
  Future<PaymentWebhookEvent> deleteRow(
    _is.DatabaseSession session,
    PaymentWebhookEvent row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<PaymentWebhookEvent>(
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
  Future<List<PaymentWebhookEvent>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<PaymentWebhookEventTable> where,
    _is.OrderByBuilder<PaymentWebhookEventTable>? orderBy,
    _is.OrderByListBuilder<PaymentWebhookEventTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<PaymentWebhookEvent>(
      where: where(PaymentWebhookEvent.t),
      orderBy: orderBy?.call(PaymentWebhookEvent.t),
      orderByList: orderByList?.call(PaymentWebhookEvent.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PaymentWebhookEventTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<PaymentWebhookEvent>(
      where: where?.call(PaymentWebhookEvent.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [PaymentWebhookEvent] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<PaymentWebhookEventTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<PaymentWebhookEvent>(
      where: where(PaymentWebhookEvent.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
