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

abstract class Sponsorship
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  Sponsorship._({
    this.id,
    required this.campaignId,
    required this.sponsorAuthUserId,
    required this.amount,
    this.message,
    String? paymentProvider,
    String? paymentStatus,
    this.providerOrderId,
    this.providerPaymentId,
    this.verifiedAt,
    DateTime? createdAt,
  }) : paymentProvider = paymentProvider ?? 'razorpay',
       paymentStatus = paymentStatus ?? 'created',
       createdAt = createdAt ?? DateTime.now();

  factory Sponsorship({
    int? id,
    required int campaignId,
    required _is.UuidValue sponsorAuthUserId,
    required double amount,
    String? message,
    String? paymentProvider,
    String? paymentStatus,
    String? providerOrderId,
    String? providerPaymentId,
    DateTime? verifiedAt,
    DateTime? createdAt,
  }) = _SponsorshipImpl;

  factory Sponsorship.fromJson(Map<String, dynamic> jsonSerialization) {
    return Sponsorship(
      id: jsonSerialization['id'] as int?,
      campaignId: jsonSerialization['campaignId'] as int,
      sponsorAuthUserId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['sponsorAuthUserId'],
      ),
      amount: (jsonSerialization['amount'] as num).toDouble(),
      message: jsonSerialization['message'] as String?,
      paymentProvider: jsonSerialization['paymentProvider'] as String?,
      paymentStatus: jsonSerialization['paymentStatus'] as String?,
      providerOrderId: jsonSerialization['providerOrderId'] as String?,
      providerPaymentId: jsonSerialization['providerPaymentId'] as String?,
      verifiedAt: jsonSerialization['verifiedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['verifiedAt']),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  static final t = SponsorshipTable();

  static const db = SponsorshipRepository._();

  @override
  int? id;

  int campaignId;

  _is.UuidValue sponsorAuthUserId;

  double amount;

  String? message;

  String paymentProvider;

  String paymentStatus;

  String? providerOrderId;

  String? providerPaymentId;

  DateTime? verifiedAt;

  DateTime createdAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [Sponsorship]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  Sponsorship copyWith({
    int? id,
    int? campaignId,
    _is.UuidValue? sponsorAuthUserId,
    double? amount,
    String? message,
    String? paymentProvider,
    String? paymentStatus,
    String? providerOrderId,
    String? providerPaymentId,
    DateTime? verifiedAt,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Sponsorship',
      if (id != null) 'id': id,
      'campaignId': campaignId,
      'sponsorAuthUserId': sponsorAuthUserId.toJson(),
      'amount': amount,
      if (message != null) 'message': message,
      'paymentProvider': paymentProvider,
      'paymentStatus': paymentStatus,
      if (providerOrderId != null) 'providerOrderId': providerOrderId,
      if (providerPaymentId != null) 'providerPaymentId': providerPaymentId,
      if (verifiedAt != null) 'verifiedAt': verifiedAt?.toJson(),
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Sponsorship',
      if (id != null) 'id': id,
      'campaignId': campaignId,
      'sponsorAuthUserId': sponsorAuthUserId.toJson(),
      'amount': amount,
      if (message != null) 'message': message,
      'paymentProvider': paymentProvider,
      'paymentStatus': paymentStatus,
      if (providerOrderId != null) 'providerOrderId': providerOrderId,
      if (providerPaymentId != null) 'providerPaymentId': providerPaymentId,
      if (verifiedAt != null) 'verifiedAt': verifiedAt?.toJson(),
      'createdAt': createdAt.toJson(),
    };
  }

  static SponsorshipInclude include() {
    return SponsorshipInclude._();
  }

  static SponsorshipIncludeList includeList({
    _is.WhereExpressionBuilder<SponsorshipTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<SponsorshipTable>? orderBy,
    _is.OrderByListBuilder<SponsorshipTable>? orderByList,
    SponsorshipInclude? include,
  }) {
    return SponsorshipIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Sponsorship.t),
      orderByList: orderByList?.call(Sponsorship.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _SponsorshipImpl extends Sponsorship {
  _SponsorshipImpl({
    int? id,
    required int campaignId,
    required _is.UuidValue sponsorAuthUserId,
    required double amount,
    String? message,
    String? paymentProvider,
    String? paymentStatus,
    String? providerOrderId,
    String? providerPaymentId,
    DateTime? verifiedAt,
    DateTime? createdAt,
  }) : super._(
         id: id,
         campaignId: campaignId,
         sponsorAuthUserId: sponsorAuthUserId,
         amount: amount,
         message: message,
         paymentProvider: paymentProvider,
         paymentStatus: paymentStatus,
         providerOrderId: providerOrderId,
         providerPaymentId: providerPaymentId,
         verifiedAt: verifiedAt,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [Sponsorship]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  Sponsorship copyWith({
    Object? id = _Undefined,
    int? campaignId,
    _is.UuidValue? sponsorAuthUserId,
    double? amount,
    Object? message = _Undefined,
    String? paymentProvider,
    String? paymentStatus,
    Object? providerOrderId = _Undefined,
    Object? providerPaymentId = _Undefined,
    Object? verifiedAt = _Undefined,
    DateTime? createdAt,
  }) {
    return Sponsorship(
      id: id is int? ? id : this.id,
      campaignId: campaignId ?? this.campaignId,
      sponsorAuthUserId: sponsorAuthUserId ?? this.sponsorAuthUserId,
      amount: amount ?? this.amount,
      message: message is String? ? message : this.message,
      paymentProvider: paymentProvider ?? this.paymentProvider,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      providerOrderId: providerOrderId is String?
          ? providerOrderId
          : this.providerOrderId,
      providerPaymentId: providerPaymentId is String?
          ? providerPaymentId
          : this.providerPaymentId,
      verifiedAt: verifiedAt is DateTime? ? verifiedAt : this.verifiedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class SponsorshipUpdateTable extends _is.UpdateTable<SponsorshipTable> {
  SponsorshipUpdateTable(super.table);

  _is.ColumnValue<int, int> campaignId(int value) => _is.ColumnValue(
    table.campaignId,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> sponsorAuthUserId(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.sponsorAuthUserId,
    value,
  );

  _is.ColumnValue<double, double> amount(double value) => _is.ColumnValue(
    table.amount,
    value,
  );

  _is.ColumnValue<String, String> message(String? value) => _is.ColumnValue(
    table.message,
    value,
  );

  _is.ColumnValue<String, String> paymentProvider(String value) =>
      _is.ColumnValue(
        table.paymentProvider,
        value,
      );

  _is.ColumnValue<String, String> paymentStatus(String value) =>
      _is.ColumnValue(
        table.paymentStatus,
        value,
      );

  _is.ColumnValue<String, String> providerOrderId(String? value) =>
      _is.ColumnValue(
        table.providerOrderId,
        value,
      );

  _is.ColumnValue<String, String> providerPaymentId(String? value) =>
      _is.ColumnValue(
        table.providerPaymentId,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> verifiedAt(DateTime? value) =>
      _is.ColumnValue(
        table.verifiedAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );
}

class SponsorshipTable extends _is.Table<int?> {
  SponsorshipTable({super.tableRelation})
    : super(tableName: 'fieldnote_sponsorship') {
    updateTable = SponsorshipUpdateTable(this);
    campaignId = _is.ColumnInt(
      'campaignId',
      this,
    );
    sponsorAuthUserId = _is.ColumnUuid(
      'sponsorAuthUserId',
      this,
    );
    amount = _is.ColumnDouble(
      'amount',
      this,
    );
    message = _is.ColumnString(
      'message',
      this,
    );
    paymentProvider = _is.ColumnString(
      'paymentProvider',
      this,
      hasDefault: true,
    );
    paymentStatus = _is.ColumnString(
      'paymentStatus',
      this,
      hasDefault: true,
    );
    providerOrderId = _is.ColumnString(
      'providerOrderId',
      this,
    );
    providerPaymentId = _is.ColumnString(
      'providerPaymentId',
      this,
    );
    verifiedAt = _is.ColumnDateTime(
      'verifiedAt',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
      hasDefault: true,
    );
  }

  late final SponsorshipUpdateTable updateTable;

  late final _is.ColumnInt campaignId;

  late final _is.ColumnUuid sponsorAuthUserId;

  late final _is.ColumnDouble amount;

  late final _is.ColumnString message;

  late final _is.ColumnString paymentProvider;

  late final _is.ColumnString paymentStatus;

  late final _is.ColumnString providerOrderId;

  late final _is.ColumnString providerPaymentId;

  late final _is.ColumnDateTime verifiedAt;

  late final _is.ColumnDateTime createdAt;

  @override
  List<_is.Column> get columns => [
    id,
    campaignId,
    sponsorAuthUserId,
    amount,
    message,
    paymentProvider,
    paymentStatus,
    providerOrderId,
    providerPaymentId,
    verifiedAt,
    createdAt,
  ];
}

class SponsorshipInclude extends _is.IncludeObject {
  SponsorshipInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => Sponsorship.t;
}

class SponsorshipIncludeList extends _is.IncludeList {
  SponsorshipIncludeList._({
    _is.WhereExpressionBuilder<SponsorshipTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Sponsorship.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => Sponsorship.t;
}

class SponsorshipRepository {
  const SponsorshipRepository._();

  /// Returns a list of [Sponsorship]s matching the given query parameters.
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
  Future<List<Sponsorship>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<SponsorshipTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<SponsorshipTable>? orderBy,
    _is.OrderByListBuilder<SponsorshipTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<Sponsorship>(
      where: where?.call(Sponsorship.t),
      orderBy: orderBy?.call(Sponsorship.t),
      orderByList: orderByList?.call(Sponsorship.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [Sponsorship] matching the given query parameters.
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
  Future<Sponsorship?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<SponsorshipTable>? where,
    int? offset,
    _is.OrderByBuilder<SponsorshipTable>? orderBy,
    _is.OrderByListBuilder<SponsorshipTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<Sponsorship>(
      where: where?.call(Sponsorship.t),
      orderBy: orderBy?.call(Sponsorship.t),
      orderByList: orderByList?.call(Sponsorship.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [Sponsorship] by its [id] or null if no such row exists.
  Future<Sponsorship?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<Sponsorship>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [Sponsorship]s in the list and returns the inserted rows.
  ///
  /// The returned [Sponsorship]s will have their `id` fields set.
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
  Future<List<Sponsorship>> insert(
    _is.DatabaseSession session,
    List<Sponsorship> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<Sponsorship>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [Sponsorship] and returns the inserted row.
  ///
  /// The returned [Sponsorship] will have its `id` field set.
  Future<Sponsorship> insertRow(
    _is.DatabaseSession session,
    Sponsorship row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<Sponsorship>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [Sponsorship]s in the list and returns the resulting rows.
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
  /// The returned [Sponsorship]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Sponsorship>> upsert(
    _is.DatabaseSession session,
    List<Sponsorship> rows, {
    required _is.ColumnSelections<SponsorshipTable> conflictColumns,
    _is.ColumnSelections<SponsorshipTable>? updateColumns,
    _is.WhereExpressionBuilder<SponsorshipTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<Sponsorship>(
      rows,
      conflictColumns: conflictColumns(Sponsorship.t),
      updateColumns: updateColumns?.call(Sponsorship.t),
      updateWhere: updateWhere?.call(Sponsorship.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [Sponsorship] and returns the resulting row.
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
  /// The returned [Sponsorship] will have its `id` field set.
  Future<Sponsorship?> upsertRow(
    _is.DatabaseSession session,
    Sponsorship row, {
    required _is.ColumnSelections<SponsorshipTable> conflictColumns,
    _is.ColumnSelections<SponsorshipTable>? updateColumns,
    _is.WhereExpressionBuilder<SponsorshipTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<Sponsorship>(
      row,
      conflictColumns: conflictColumns(Sponsorship.t),
      updateColumns: updateColumns?.call(Sponsorship.t),
      updateWhere: updateWhere?.call(Sponsorship.t),
      transaction: transaction,
    );
  }

  /// Updates all [Sponsorship]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Sponsorship>> update(
    _is.DatabaseSession session,
    List<Sponsorship> rows, {
    _is.ColumnSelections<SponsorshipTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<Sponsorship>(
      rows,
      columns: columns?.call(Sponsorship.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [Sponsorship]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Sponsorship> updateRow(
    _is.DatabaseSession session,
    Sponsorship row, {
    _is.ColumnSelections<SponsorshipTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<Sponsorship>(
      row,
      columns: columns?.call(Sponsorship.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Sponsorship] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<Sponsorship?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<SponsorshipUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<Sponsorship>(
      id,
      columnValues: columnValues(Sponsorship.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [Sponsorship]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Sponsorship>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<SponsorshipUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<SponsorshipTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<SponsorshipTable>? orderBy,
    _is.OrderByListBuilder<SponsorshipTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<Sponsorship>(
      columnValues: columnValues(Sponsorship.t.updateTable),
      where: where(Sponsorship.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Sponsorship.t),
      orderByList: orderByList?.call(Sponsorship.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [Sponsorship]s in the list and returns the deleted rows.
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
  Future<List<Sponsorship>> delete(
    _is.DatabaseSession session,
    List<Sponsorship> rows, {
    _is.OrderByBuilder<SponsorshipTable>? orderBy,
    _is.OrderByListBuilder<SponsorshipTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<Sponsorship>(
      rows,
      orderBy: orderBy?.call(Sponsorship.t),
      orderByList: orderByList?.call(Sponsorship.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [Sponsorship].
  Future<Sponsorship> deleteRow(
    _is.DatabaseSession session,
    Sponsorship row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Sponsorship>(
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
  Future<List<Sponsorship>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<SponsorshipTable> where,
    _is.OrderByBuilder<SponsorshipTable>? orderBy,
    _is.OrderByListBuilder<SponsorshipTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<Sponsorship>(
      where: where(Sponsorship.t),
      orderBy: orderBy?.call(Sponsorship.t),
      orderByList: orderByList?.call(Sponsorship.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<SponsorshipTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<Sponsorship>(
      where: where?.call(Sponsorship.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [Sponsorship] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<SponsorshipTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<Sponsorship>(
      where: where(Sponsorship.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
