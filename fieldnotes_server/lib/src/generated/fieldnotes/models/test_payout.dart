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

abstract class TestPayout
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  TestPayout._({
    this.id,
    required this.campaignId,
    required this.sponsorshipId,
    required this.creatorAuthUserId,
    required this.amount,
    required this.sourcePaymentId,
    String? status,
    DateTime? simulatedAt,
  }) : status = status ?? 'simulated',
       simulatedAt = simulatedAt ?? DateTime.now();

  factory TestPayout({
    int? id,
    required int campaignId,
    required int sponsorshipId,
    required _is.UuidValue creatorAuthUserId,
    required double amount,
    required String sourcePaymentId,
    String? status,
    DateTime? simulatedAt,
  }) = _TestPayoutImpl;

  factory TestPayout.fromJson(Map<String, dynamic> jsonSerialization) {
    return TestPayout(
      id: jsonSerialization['id'] as int?,
      campaignId: jsonSerialization['campaignId'] as int,
      sponsorshipId: jsonSerialization['sponsorshipId'] as int,
      creatorAuthUserId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['creatorAuthUserId'],
      ),
      amount: (jsonSerialization['amount'] as num).toDouble(),
      sourcePaymentId: jsonSerialization['sourcePaymentId'] as String,
      status: jsonSerialization['status'] as String?,
      simulatedAt: jsonSerialization['simulatedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(
              jsonSerialization['simulatedAt'],
            ),
    );
  }

  static final t = TestPayoutTable();

  static const db = TestPayoutRepository._();

  @override
  int? id;

  int campaignId;

  int sponsorshipId;

  _is.UuidValue creatorAuthUserId;

  double amount;

  String sourcePaymentId;

  String status;

  DateTime simulatedAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [TestPayout]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  TestPayout copyWith({
    int? id,
    int? campaignId,
    int? sponsorshipId,
    _is.UuidValue? creatorAuthUserId,
    double? amount,
    String? sourcePaymentId,
    String? status,
    DateTime? simulatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'TestPayout',
      if (id != null) 'id': id,
      'campaignId': campaignId,
      'sponsorshipId': sponsorshipId,
      'creatorAuthUserId': creatorAuthUserId.toJson(),
      'amount': amount,
      'sourcePaymentId': sourcePaymentId,
      'status': status,
      'simulatedAt': simulatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'TestPayout',
      if (id != null) 'id': id,
      'campaignId': campaignId,
      'sponsorshipId': sponsorshipId,
      'creatorAuthUserId': creatorAuthUserId.toJson(),
      'amount': amount,
      'sourcePaymentId': sourcePaymentId,
      'status': status,
      'simulatedAt': simulatedAt.toJson(),
    };
  }

  static TestPayoutInclude include() {
    return TestPayoutInclude._();
  }

  static TestPayoutIncludeList includeList({
    _is.WhereExpressionBuilder<TestPayoutTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<TestPayoutTable>? orderBy,
    _is.OrderByListBuilder<TestPayoutTable>? orderByList,
    TestPayoutInclude? include,
  }) {
    return TestPayoutIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(TestPayout.t),
      orderByList: orderByList?.call(TestPayout.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _TestPayoutImpl extends TestPayout {
  _TestPayoutImpl({
    int? id,
    required int campaignId,
    required int sponsorshipId,
    required _is.UuidValue creatorAuthUserId,
    required double amount,
    required String sourcePaymentId,
    String? status,
    DateTime? simulatedAt,
  }) : super._(
         id: id,
         campaignId: campaignId,
         sponsorshipId: sponsorshipId,
         creatorAuthUserId: creatorAuthUserId,
         amount: amount,
         sourcePaymentId: sourcePaymentId,
         status: status,
         simulatedAt: simulatedAt,
       );

  /// Returns a shallow copy of this [TestPayout]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  TestPayout copyWith({
    Object? id = _Undefined,
    int? campaignId,
    int? sponsorshipId,
    _is.UuidValue? creatorAuthUserId,
    double? amount,
    String? sourcePaymentId,
    String? status,
    DateTime? simulatedAt,
  }) {
    return TestPayout(
      id: id is int? ? id : this.id,
      campaignId: campaignId ?? this.campaignId,
      sponsorshipId: sponsorshipId ?? this.sponsorshipId,
      creatorAuthUserId: creatorAuthUserId ?? this.creatorAuthUserId,
      amount: amount ?? this.amount,
      sourcePaymentId: sourcePaymentId ?? this.sourcePaymentId,
      status: status ?? this.status,
      simulatedAt: simulatedAt ?? this.simulatedAt,
    );
  }
}

class TestPayoutUpdateTable extends _is.UpdateTable<TestPayoutTable> {
  TestPayoutUpdateTable(super.table);

  _is.ColumnValue<int, int> campaignId(int value) => _is.ColumnValue(
    table.campaignId,
    value,
  );

  _is.ColumnValue<int, int> sponsorshipId(int value) => _is.ColumnValue(
    table.sponsorshipId,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> creatorAuthUserId(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.creatorAuthUserId,
    value,
  );

  _is.ColumnValue<double, double> amount(double value) => _is.ColumnValue(
    table.amount,
    value,
  );

  _is.ColumnValue<String, String> sourcePaymentId(String value) =>
      _is.ColumnValue(
        table.sourcePaymentId,
        value,
      );

  _is.ColumnValue<String, String> status(String value) => _is.ColumnValue(
    table.status,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> simulatedAt(DateTime value) =>
      _is.ColumnValue(
        table.simulatedAt,
        value,
      );
}

class TestPayoutTable extends _is.Table<int?> {
  TestPayoutTable({super.tableRelation})
    : super(tableName: 'fieldnote_test_payout') {
    updateTable = TestPayoutUpdateTable(this);
    campaignId = _is.ColumnInt(
      'campaignId',
      this,
    );
    sponsorshipId = _is.ColumnInt(
      'sponsorshipId',
      this,
    );
    creatorAuthUserId = _is.ColumnUuid(
      'creatorAuthUserId',
      this,
    );
    amount = _is.ColumnDouble(
      'amount',
      this,
    );
    sourcePaymentId = _is.ColumnString(
      'sourcePaymentId',
      this,
    );
    status = _is.ColumnString(
      'status',
      this,
      hasDefault: true,
    );
    simulatedAt = _is.ColumnDateTime(
      'simulatedAt',
      this,
      hasDefault: true,
    );
  }

  late final TestPayoutUpdateTable updateTable;

  late final _is.ColumnInt campaignId;

  late final _is.ColumnInt sponsorshipId;

  late final _is.ColumnUuid creatorAuthUserId;

  late final _is.ColumnDouble amount;

  late final _is.ColumnString sourcePaymentId;

  late final _is.ColumnString status;

  late final _is.ColumnDateTime simulatedAt;

  @override
  List<_is.Column> get columns => [
    id,
    campaignId,
    sponsorshipId,
    creatorAuthUserId,
    amount,
    sourcePaymentId,
    status,
    simulatedAt,
  ];
}

class TestPayoutInclude extends _is.IncludeObject {
  TestPayoutInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => TestPayout.t;
}

class TestPayoutIncludeList extends _is.IncludeList {
  TestPayoutIncludeList._({
    _is.WhereExpressionBuilder<TestPayoutTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(TestPayout.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => TestPayout.t;
}

class TestPayoutRepository {
  const TestPayoutRepository._();

  /// Returns a list of [TestPayout]s matching the given query parameters.
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
  Future<List<TestPayout>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<TestPayoutTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<TestPayoutTable>? orderBy,
    _is.OrderByListBuilder<TestPayoutTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<TestPayout>(
      where: where?.call(TestPayout.t),
      orderBy: orderBy?.call(TestPayout.t),
      orderByList: orderByList?.call(TestPayout.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [TestPayout] matching the given query parameters.
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
  Future<TestPayout?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<TestPayoutTable>? where,
    int? offset,
    _is.OrderByBuilder<TestPayoutTable>? orderBy,
    _is.OrderByListBuilder<TestPayoutTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<TestPayout>(
      where: where?.call(TestPayout.t),
      orderBy: orderBy?.call(TestPayout.t),
      orderByList: orderByList?.call(TestPayout.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [TestPayout] by its [id] or null if no such row exists.
  Future<TestPayout?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<TestPayout>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [TestPayout]s in the list and returns the inserted rows.
  ///
  /// The returned [TestPayout]s will have their `id` fields set.
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
  Future<List<TestPayout>> insert(
    _is.DatabaseSession session,
    List<TestPayout> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<TestPayout>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [TestPayout] and returns the inserted row.
  ///
  /// The returned [TestPayout] will have its `id` field set.
  Future<TestPayout> insertRow(
    _is.DatabaseSession session,
    TestPayout row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<TestPayout>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [TestPayout]s in the list and returns the resulting rows.
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
  /// The returned [TestPayout]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<TestPayout>> upsert(
    _is.DatabaseSession session,
    List<TestPayout> rows, {
    required _is.ColumnSelections<TestPayoutTable> conflictColumns,
    _is.ColumnSelections<TestPayoutTable>? updateColumns,
    _is.WhereExpressionBuilder<TestPayoutTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<TestPayout>(
      rows,
      conflictColumns: conflictColumns(TestPayout.t),
      updateColumns: updateColumns?.call(TestPayout.t),
      updateWhere: updateWhere?.call(TestPayout.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [TestPayout] and returns the resulting row.
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
  /// The returned [TestPayout] will have its `id` field set.
  Future<TestPayout?> upsertRow(
    _is.DatabaseSession session,
    TestPayout row, {
    required _is.ColumnSelections<TestPayoutTable> conflictColumns,
    _is.ColumnSelections<TestPayoutTable>? updateColumns,
    _is.WhereExpressionBuilder<TestPayoutTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<TestPayout>(
      row,
      conflictColumns: conflictColumns(TestPayout.t),
      updateColumns: updateColumns?.call(TestPayout.t),
      updateWhere: updateWhere?.call(TestPayout.t),
      transaction: transaction,
    );
  }

  /// Updates all [TestPayout]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<TestPayout>> update(
    _is.DatabaseSession session,
    List<TestPayout> rows, {
    _is.ColumnSelections<TestPayoutTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<TestPayout>(
      rows,
      columns: columns?.call(TestPayout.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [TestPayout]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<TestPayout> updateRow(
    _is.DatabaseSession session,
    TestPayout row, {
    _is.ColumnSelections<TestPayoutTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<TestPayout>(
      row,
      columns: columns?.call(TestPayout.t),
      transaction: transaction,
    );
  }

  /// Updates a single [TestPayout] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<TestPayout?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<TestPayoutUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<TestPayout>(
      id,
      columnValues: columnValues(TestPayout.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [TestPayout]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<TestPayout>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<TestPayoutUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<TestPayoutTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<TestPayoutTable>? orderBy,
    _is.OrderByListBuilder<TestPayoutTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<TestPayout>(
      columnValues: columnValues(TestPayout.t.updateTable),
      where: where(TestPayout.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(TestPayout.t),
      orderByList: orderByList?.call(TestPayout.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [TestPayout]s in the list and returns the deleted rows.
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
  Future<List<TestPayout>> delete(
    _is.DatabaseSession session,
    List<TestPayout> rows, {
    _is.OrderByBuilder<TestPayoutTable>? orderBy,
    _is.OrderByListBuilder<TestPayoutTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<TestPayout>(
      rows,
      orderBy: orderBy?.call(TestPayout.t),
      orderByList: orderByList?.call(TestPayout.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [TestPayout].
  Future<TestPayout> deleteRow(
    _is.DatabaseSession session,
    TestPayout row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<TestPayout>(
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
  Future<List<TestPayout>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<TestPayoutTable> where,
    _is.OrderByBuilder<TestPayoutTable>? orderBy,
    _is.OrderByListBuilder<TestPayoutTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<TestPayout>(
      where: where(TestPayout.t),
      orderBy: orderBy?.call(TestPayout.t),
      orderByList: orderByList?.call(TestPayout.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<TestPayoutTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<TestPayout>(
      where: where?.call(TestPayout.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [TestPayout] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<TestPayoutTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<TestPayout>(
      where: where(TestPayout.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
