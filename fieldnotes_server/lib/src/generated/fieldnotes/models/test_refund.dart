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

abstract class TestRefund
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  TestRefund._({
    this.id,
    required this.campaignId,
    required this.sponsorshipId,
    required this.amount,
    String? status,
    String? reason,
    bool? testMode,
    int? attempts,
    this.providerRefundId,
    this.lastError,
    this.nextAttemptAt,
    this.processedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : status = status ?? 'pending',
       reason = reason ?? 'campaign_cancelled',
       testMode = testMode ?? true,
       attempts = attempts ?? 0,
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory TestRefund({
    int? id,
    required int campaignId,
    required int sponsorshipId,
    required double amount,
    String? status,
    String? reason,
    bool? testMode,
    int? attempts,
    String? providerRefundId,
    String? lastError,
    DateTime? nextAttemptAt,
    DateTime? processedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _TestRefundImpl;

  factory TestRefund.fromJson(Map<String, dynamic> jsonSerialization) {
    return TestRefund(
      id: jsonSerialization['id'] as int?,
      campaignId: jsonSerialization['campaignId'] as int,
      sponsorshipId: jsonSerialization['sponsorshipId'] as int,
      amount: (jsonSerialization['amount'] as num).toDouble(),
      status: jsonSerialization['status'] as String?,
      reason: jsonSerialization['reason'] as String?,
      testMode: jsonSerialization['testMode'] == null
          ? null
          : _is.BoolJsonExtension.fromJson(jsonSerialization['testMode']),
      attempts: jsonSerialization['attempts'] as int?,
      providerRefundId: jsonSerialization['providerRefundId'] as String?,
      lastError: jsonSerialization['lastError'] as String?,
      nextAttemptAt: jsonSerialization['nextAttemptAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(
              jsonSerialization['nextAttemptAt'],
            ),
      processedAt: jsonSerialization['processedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(
              jsonSerialization['processedAt'],
            ),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  static final t = TestRefundTable();

  static const db = TestRefundRepository._();

  @override
  int? id;

  int campaignId;

  int sponsorshipId;

  double amount;

  String status;

  String reason;

  bool testMode;

  int attempts;

  String? providerRefundId;

  String? lastError;

  DateTime? nextAttemptAt;

  DateTime? processedAt;

  DateTime createdAt;

  DateTime updatedAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [TestRefund]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  TestRefund copyWith({
    int? id,
    int? campaignId,
    int? sponsorshipId,
    double? amount,
    String? status,
    String? reason,
    bool? testMode,
    int? attempts,
    String? providerRefundId,
    String? lastError,
    DateTime? nextAttemptAt,
    DateTime? processedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'TestRefund',
      if (id != null) 'id': id,
      'campaignId': campaignId,
      'sponsorshipId': sponsorshipId,
      'amount': amount,
      'status': status,
      'reason': reason,
      'testMode': testMode,
      'attempts': attempts,
      if (providerRefundId != null) 'providerRefundId': providerRefundId,
      if (lastError != null) 'lastError': lastError,
      if (nextAttemptAt != null) 'nextAttemptAt': nextAttemptAt?.toJson(),
      if (processedAt != null) 'processedAt': processedAt?.toJson(),
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'TestRefund',
      if (id != null) 'id': id,
      'campaignId': campaignId,
      'sponsorshipId': sponsorshipId,
      'amount': amount,
      'status': status,
      'reason': reason,
      'testMode': testMode,
      'attempts': attempts,
      if (providerRefundId != null) 'providerRefundId': providerRefundId,
      if (lastError != null) 'lastError': lastError,
      if (nextAttemptAt != null) 'nextAttemptAt': nextAttemptAt?.toJson(),
      if (processedAt != null) 'processedAt': processedAt?.toJson(),
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  static TestRefundInclude include() {
    return TestRefundInclude._();
  }

  static TestRefundIncludeList includeList({
    _is.WhereExpressionBuilder<TestRefundTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<TestRefundTable>? orderBy,
    _is.OrderByListBuilder<TestRefundTable>? orderByList,
    TestRefundInclude? include,
  }) {
    return TestRefundIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(TestRefund.t),
      orderByList: orderByList?.call(TestRefund.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _TestRefundImpl extends TestRefund {
  _TestRefundImpl({
    int? id,
    required int campaignId,
    required int sponsorshipId,
    required double amount,
    String? status,
    String? reason,
    bool? testMode,
    int? attempts,
    String? providerRefundId,
    String? lastError,
    DateTime? nextAttemptAt,
    DateTime? processedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         campaignId: campaignId,
         sponsorshipId: sponsorshipId,
         amount: amount,
         status: status,
         reason: reason,
         testMode: testMode,
         attempts: attempts,
         providerRefundId: providerRefundId,
         lastError: lastError,
         nextAttemptAt: nextAttemptAt,
         processedAt: processedAt,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [TestRefund]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  TestRefund copyWith({
    Object? id = _Undefined,
    int? campaignId,
    int? sponsorshipId,
    double? amount,
    String? status,
    String? reason,
    bool? testMode,
    int? attempts,
    Object? providerRefundId = _Undefined,
    Object? lastError = _Undefined,
    Object? nextAttemptAt = _Undefined,
    Object? processedAt = _Undefined,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TestRefund(
      id: id is int? ? id : this.id,
      campaignId: campaignId ?? this.campaignId,
      sponsorshipId: sponsorshipId ?? this.sponsorshipId,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      reason: reason ?? this.reason,
      testMode: testMode ?? this.testMode,
      attempts: attempts ?? this.attempts,
      providerRefundId: providerRefundId is String?
          ? providerRefundId
          : this.providerRefundId,
      lastError: lastError is String? ? lastError : this.lastError,
      nextAttemptAt: nextAttemptAt is DateTime?
          ? nextAttemptAt
          : this.nextAttemptAt,
      processedAt: processedAt is DateTime? ? processedAt : this.processedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class TestRefundUpdateTable extends _is.UpdateTable<TestRefundTable> {
  TestRefundUpdateTable(super.table);

  _is.ColumnValue<int, int> campaignId(int value) => _is.ColumnValue(
    table.campaignId,
    value,
  );

  _is.ColumnValue<int, int> sponsorshipId(int value) => _is.ColumnValue(
    table.sponsorshipId,
    value,
  );

  _is.ColumnValue<double, double> amount(double value) => _is.ColumnValue(
    table.amount,
    value,
  );

  _is.ColumnValue<String, String> status(String value) => _is.ColumnValue(
    table.status,
    value,
  );

  _is.ColumnValue<String, String> reason(String value) => _is.ColumnValue(
    table.reason,
    value,
  );

  _is.ColumnValue<bool, bool> testMode(bool value) => _is.ColumnValue(
    table.testMode,
    value,
  );

  _is.ColumnValue<int, int> attempts(int value) => _is.ColumnValue(
    table.attempts,
    value,
  );

  _is.ColumnValue<String, String> providerRefundId(String? value) =>
      _is.ColumnValue(
        table.providerRefundId,
        value,
      );

  _is.ColumnValue<String, String> lastError(String? value) => _is.ColumnValue(
    table.lastError,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> nextAttemptAt(DateTime? value) =>
      _is.ColumnValue(
        table.nextAttemptAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> processedAt(DateTime? value) =>
      _is.ColumnValue(
        table.processedAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> updatedAt(DateTime value) =>
      _is.ColumnValue(
        table.updatedAt,
        value,
      );
}

class TestRefundTable extends _is.Table<int?> {
  TestRefundTable({super.tableRelation})
    : super(tableName: 'fieldnote_test_refund') {
    updateTable = TestRefundUpdateTable(this);
    campaignId = _is.ColumnInt(
      'campaignId',
      this,
    );
    sponsorshipId = _is.ColumnInt(
      'sponsorshipId',
      this,
    );
    amount = _is.ColumnDouble(
      'amount',
      this,
    );
    status = _is.ColumnString(
      'status',
      this,
      hasDefault: true,
    );
    reason = _is.ColumnString(
      'reason',
      this,
      hasDefault: true,
    );
    testMode = _is.ColumnBool(
      'testMode',
      this,
      hasDefault: true,
    );
    attempts = _is.ColumnInt(
      'attempts',
      this,
      hasDefault: true,
    );
    providerRefundId = _is.ColumnString(
      'providerRefundId',
      this,
    );
    lastError = _is.ColumnString(
      'lastError',
      this,
    );
    nextAttemptAt = _is.ColumnDateTime(
      'nextAttemptAt',
      this,
    );
    processedAt = _is.ColumnDateTime(
      'processedAt',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
      hasDefault: true,
    );
    updatedAt = _is.ColumnDateTime(
      'updatedAt',
      this,
      hasDefault: true,
    );
  }

  late final TestRefundUpdateTable updateTable;

  late final _is.ColumnInt campaignId;

  late final _is.ColumnInt sponsorshipId;

  late final _is.ColumnDouble amount;

  late final _is.ColumnString status;

  late final _is.ColumnString reason;

  late final _is.ColumnBool testMode;

  late final _is.ColumnInt attempts;

  late final _is.ColumnString providerRefundId;

  late final _is.ColumnString lastError;

  late final _is.ColumnDateTime nextAttemptAt;

  late final _is.ColumnDateTime processedAt;

  late final _is.ColumnDateTime createdAt;

  late final _is.ColumnDateTime updatedAt;

  @override
  List<_is.Column> get columns => [
    id,
    campaignId,
    sponsorshipId,
    amount,
    status,
    reason,
    testMode,
    attempts,
    providerRefundId,
    lastError,
    nextAttemptAt,
    processedAt,
    createdAt,
    updatedAt,
  ];
}

class TestRefundInclude extends _is.IncludeObject {
  TestRefundInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => TestRefund.t;
}

class TestRefundIncludeList extends _is.IncludeList {
  TestRefundIncludeList._({
    _is.WhereExpressionBuilder<TestRefundTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(TestRefund.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => TestRefund.t;
}

class TestRefundRepository {
  const TestRefundRepository._();

  /// Returns a list of [TestRefund]s matching the given query parameters.
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
  Future<List<TestRefund>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<TestRefundTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<TestRefundTable>? orderBy,
    _is.OrderByListBuilder<TestRefundTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<TestRefund>(
      where: where?.call(TestRefund.t),
      orderBy: orderBy?.call(TestRefund.t),
      orderByList: orderByList?.call(TestRefund.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [TestRefund] matching the given query parameters.
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
  Future<TestRefund?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<TestRefundTable>? where,
    int? offset,
    _is.OrderByBuilder<TestRefundTable>? orderBy,
    _is.OrderByListBuilder<TestRefundTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<TestRefund>(
      where: where?.call(TestRefund.t),
      orderBy: orderBy?.call(TestRefund.t),
      orderByList: orderByList?.call(TestRefund.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [TestRefund] by its [id] or null if no such row exists.
  Future<TestRefund?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<TestRefund>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [TestRefund]s in the list and returns the inserted rows.
  ///
  /// The returned [TestRefund]s will have their `id` fields set.
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
  Future<List<TestRefund>> insert(
    _is.DatabaseSession session,
    List<TestRefund> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<TestRefund>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [TestRefund] and returns the inserted row.
  ///
  /// The returned [TestRefund] will have its `id` field set.
  Future<TestRefund> insertRow(
    _is.DatabaseSession session,
    TestRefund row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<TestRefund>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [TestRefund]s in the list and returns the resulting rows.
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
  /// The returned [TestRefund]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<TestRefund>> upsert(
    _is.DatabaseSession session,
    List<TestRefund> rows, {
    required _is.ColumnSelections<TestRefundTable> conflictColumns,
    _is.ColumnSelections<TestRefundTable>? updateColumns,
    _is.WhereExpressionBuilder<TestRefundTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<TestRefund>(
      rows,
      conflictColumns: conflictColumns(TestRefund.t),
      updateColumns: updateColumns?.call(TestRefund.t),
      updateWhere: updateWhere?.call(TestRefund.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [TestRefund] and returns the resulting row.
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
  /// The returned [TestRefund] will have its `id` field set.
  Future<TestRefund?> upsertRow(
    _is.DatabaseSession session,
    TestRefund row, {
    required _is.ColumnSelections<TestRefundTable> conflictColumns,
    _is.ColumnSelections<TestRefundTable>? updateColumns,
    _is.WhereExpressionBuilder<TestRefundTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<TestRefund>(
      row,
      conflictColumns: conflictColumns(TestRefund.t),
      updateColumns: updateColumns?.call(TestRefund.t),
      updateWhere: updateWhere?.call(TestRefund.t),
      transaction: transaction,
    );
  }

  /// Updates all [TestRefund]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<TestRefund>> update(
    _is.DatabaseSession session,
    List<TestRefund> rows, {
    _is.ColumnSelections<TestRefundTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<TestRefund>(
      rows,
      columns: columns?.call(TestRefund.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [TestRefund]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<TestRefund> updateRow(
    _is.DatabaseSession session,
    TestRefund row, {
    _is.ColumnSelections<TestRefundTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<TestRefund>(
      row,
      columns: columns?.call(TestRefund.t),
      transaction: transaction,
    );
  }

  /// Updates a single [TestRefund] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<TestRefund?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<TestRefundUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<TestRefund>(
      id,
      columnValues: columnValues(TestRefund.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [TestRefund]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<TestRefund>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<TestRefundUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<TestRefundTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<TestRefundTable>? orderBy,
    _is.OrderByListBuilder<TestRefundTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<TestRefund>(
      columnValues: columnValues(TestRefund.t.updateTable),
      where: where(TestRefund.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(TestRefund.t),
      orderByList: orderByList?.call(TestRefund.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [TestRefund]s in the list and returns the deleted rows.
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
  Future<List<TestRefund>> delete(
    _is.DatabaseSession session,
    List<TestRefund> rows, {
    _is.OrderByBuilder<TestRefundTable>? orderBy,
    _is.OrderByListBuilder<TestRefundTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<TestRefund>(
      rows,
      orderBy: orderBy?.call(TestRefund.t),
      orderByList: orderByList?.call(TestRefund.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [TestRefund].
  Future<TestRefund> deleteRow(
    _is.DatabaseSession session,
    TestRefund row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<TestRefund>(
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
  Future<List<TestRefund>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<TestRefundTable> where,
    _is.OrderByBuilder<TestRefundTable>? orderBy,
    _is.OrderByListBuilder<TestRefundTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<TestRefund>(
      where: where(TestRefund.t),
      orderBy: orderBy?.call(TestRefund.t),
      orderByList: orderByList?.call(TestRefund.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<TestRefundTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<TestRefund>(
      where: where?.call(TestRefund.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [TestRefund] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<TestRefundTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<TestRefund>(
      where: where(TestRefund.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
