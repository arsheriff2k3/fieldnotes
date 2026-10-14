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
import 'package:fieldnotes_server/src/generated/protocol.dart' as _ix00qkn1;
import 'package:serverpod/serverpod.dart' as _is;

abstract class ManualPayoutRequest
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  ManualPayoutRequest._({
    this.id,
    required this.campaignId,
    required this.creatorAuthUserId,
    required this.clientRequestId,
    required this.sponsorshipIds,
    required this.grossAmountPaise,
    int? deductionPaise,
    required this.amountPaise,
    String? status,
    DateTime? requestedAt,
    DateTime? updatedAt,
    this.reviewedByAuthUserId,
    this.reviewedAt,
    this.settlementReference,
    this.payeeVerificationReference,
    this.reviewNote,
    this.bankTransferReference,
    this.paidAt,
  }) : deductionPaise = deductionPaise ?? 0,
       status = status ?? 'requested',
       requestedAt = requestedAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory ManualPayoutRequest({
    int? id,
    required int campaignId,
    required _is.UuidValue creatorAuthUserId,
    required String clientRequestId,
    required List<int> sponsorshipIds,
    required int grossAmountPaise,
    int? deductionPaise,
    required int amountPaise,
    String? status,
    DateTime? requestedAt,
    DateTime? updatedAt,
    _is.UuidValue? reviewedByAuthUserId,
    DateTime? reviewedAt,
    String? settlementReference,
    String? payeeVerificationReference,
    String? reviewNote,
    String? bankTransferReference,
    DateTime? paidAt,
  }) = _ManualPayoutRequestImpl;

  factory ManualPayoutRequest.fromJson(Map<String, dynamic> jsonSerialization) {
    return ManualPayoutRequest(
      id: jsonSerialization['id'] as int?,
      campaignId: jsonSerialization['campaignId'] as int,
      creatorAuthUserId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['creatorAuthUserId'],
      ),
      clientRequestId: jsonSerialization['clientRequestId'] as String,
      sponsorshipIds: _ix00qkn1.Protocol().deserialize<List<int>>(
        jsonSerialization['sponsorshipIds'],
      ),
      grossAmountPaise: jsonSerialization['grossAmountPaise'] as int,
      deductionPaise: jsonSerialization['deductionPaise'] as int?,
      amountPaise: jsonSerialization['amountPaise'] as int,
      status: jsonSerialization['status'] as String?,
      requestedAt: jsonSerialization['requestedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(
              jsonSerialization['requestedAt'],
            ),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
      reviewedByAuthUserId: jsonSerialization['reviewedByAuthUserId'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(
              jsonSerialization['reviewedByAuthUserId'],
            ),
      reviewedAt: jsonSerialization['reviewedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['reviewedAt']),
      settlementReference: jsonSerialization['settlementReference'] as String?,
      payeeVerificationReference:
          jsonSerialization['payeeVerificationReference'] as String?,
      reviewNote: jsonSerialization['reviewNote'] as String?,
      bankTransferReference:
          jsonSerialization['bankTransferReference'] as String?,
      paidAt: jsonSerialization['paidAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['paidAt']),
    );
  }

  static final t = ManualPayoutRequestTable();

  static const db = ManualPayoutRequestRepository._();

  @override
  int? id;

  int campaignId;

  _is.UuidValue creatorAuthUserId;

  String clientRequestId;

  List<int> sponsorshipIds;

  int grossAmountPaise;

  int deductionPaise;

  int amountPaise;

  String status;

  DateTime requestedAt;

  DateTime updatedAt;

  _is.UuidValue? reviewedByAuthUserId;

  DateTime? reviewedAt;

  String? settlementReference;

  String? payeeVerificationReference;

  String? reviewNote;

  String? bankTransferReference;

  DateTime? paidAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [ManualPayoutRequest]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  ManualPayoutRequest copyWith({
    int? id,
    int? campaignId,
    _is.UuidValue? creatorAuthUserId,
    String? clientRequestId,
    List<int>? sponsorshipIds,
    int? grossAmountPaise,
    int? deductionPaise,
    int? amountPaise,
    String? status,
    DateTime? requestedAt,
    DateTime? updatedAt,
    _is.UuidValue? reviewedByAuthUserId,
    DateTime? reviewedAt,
    String? settlementReference,
    String? payeeVerificationReference,
    String? reviewNote,
    String? bankTransferReference,
    DateTime? paidAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ManualPayoutRequest',
      if (id != null) 'id': id,
      'campaignId': campaignId,
      'creatorAuthUserId': creatorAuthUserId.toJson(),
      'clientRequestId': clientRequestId,
      'sponsorshipIds': sponsorshipIds.toJson(),
      'grossAmountPaise': grossAmountPaise,
      'deductionPaise': deductionPaise,
      'amountPaise': amountPaise,
      'status': status,
      'requestedAt': requestedAt.toJson(),
      'updatedAt': updatedAt.toJson(),
      if (reviewedByAuthUserId != null)
        'reviewedByAuthUserId': reviewedByAuthUserId?.toJson(),
      if (reviewedAt != null) 'reviewedAt': reviewedAt?.toJson(),
      if (settlementReference != null)
        'settlementReference': settlementReference,
      if (payeeVerificationReference != null)
        'payeeVerificationReference': payeeVerificationReference,
      if (reviewNote != null) 'reviewNote': reviewNote,
      if (bankTransferReference != null)
        'bankTransferReference': bankTransferReference,
      if (paidAt != null) 'paidAt': paidAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ManualPayoutRequest',
      if (id != null) 'id': id,
      'campaignId': campaignId,
      'creatorAuthUserId': creatorAuthUserId.toJson(),
      'clientRequestId': clientRequestId,
      'sponsorshipIds': sponsorshipIds.toJson(),
      'grossAmountPaise': grossAmountPaise,
      'deductionPaise': deductionPaise,
      'amountPaise': amountPaise,
      'status': status,
      'requestedAt': requestedAt.toJson(),
      'updatedAt': updatedAt.toJson(),
      if (reviewedByAuthUserId != null)
        'reviewedByAuthUserId': reviewedByAuthUserId?.toJson(),
      if (reviewedAt != null) 'reviewedAt': reviewedAt?.toJson(),
      if (settlementReference != null)
        'settlementReference': settlementReference,
      if (payeeVerificationReference != null)
        'payeeVerificationReference': payeeVerificationReference,
      if (reviewNote != null) 'reviewNote': reviewNote,
      if (bankTransferReference != null)
        'bankTransferReference': bankTransferReference,
      if (paidAt != null) 'paidAt': paidAt?.toJson(),
    };
  }

  static ManualPayoutRequestInclude include() {
    return ManualPayoutRequestInclude._();
  }

  static ManualPayoutRequestIncludeList includeList({
    _is.WhereExpressionBuilder<ManualPayoutRequestTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ManualPayoutRequestTable>? orderBy,
    _is.OrderByListBuilder<ManualPayoutRequestTable>? orderByList,
    ManualPayoutRequestInclude? include,
  }) {
    return ManualPayoutRequestIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ManualPayoutRequest.t),
      orderByList: orderByList?.call(ManualPayoutRequest.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ManualPayoutRequestImpl extends ManualPayoutRequest {
  _ManualPayoutRequestImpl({
    int? id,
    required int campaignId,
    required _is.UuidValue creatorAuthUserId,
    required String clientRequestId,
    required List<int> sponsorshipIds,
    required int grossAmountPaise,
    int? deductionPaise,
    required int amountPaise,
    String? status,
    DateTime? requestedAt,
    DateTime? updatedAt,
    _is.UuidValue? reviewedByAuthUserId,
    DateTime? reviewedAt,
    String? settlementReference,
    String? payeeVerificationReference,
    String? reviewNote,
    String? bankTransferReference,
    DateTime? paidAt,
  }) : super._(
         id: id,
         campaignId: campaignId,
         creatorAuthUserId: creatorAuthUserId,
         clientRequestId: clientRequestId,
         sponsorshipIds: sponsorshipIds,
         grossAmountPaise: grossAmountPaise,
         deductionPaise: deductionPaise,
         amountPaise: amountPaise,
         status: status,
         requestedAt: requestedAt,
         updatedAt: updatedAt,
         reviewedByAuthUserId: reviewedByAuthUserId,
         reviewedAt: reviewedAt,
         settlementReference: settlementReference,
         payeeVerificationReference: payeeVerificationReference,
         reviewNote: reviewNote,
         bankTransferReference: bankTransferReference,
         paidAt: paidAt,
       );

  /// Returns a shallow copy of this [ManualPayoutRequest]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  ManualPayoutRequest copyWith({
    Object? id = _Undefined,
    int? campaignId,
    _is.UuidValue? creatorAuthUserId,
    String? clientRequestId,
    List<int>? sponsorshipIds,
    int? grossAmountPaise,
    int? deductionPaise,
    int? amountPaise,
    String? status,
    DateTime? requestedAt,
    DateTime? updatedAt,
    Object? reviewedByAuthUserId = _Undefined,
    Object? reviewedAt = _Undefined,
    Object? settlementReference = _Undefined,
    Object? payeeVerificationReference = _Undefined,
    Object? reviewNote = _Undefined,
    Object? bankTransferReference = _Undefined,
    Object? paidAt = _Undefined,
  }) {
    return ManualPayoutRequest(
      id: id is int? ? id : this.id,
      campaignId: campaignId ?? this.campaignId,
      creatorAuthUserId: creatorAuthUserId ?? this.creatorAuthUserId,
      clientRequestId: clientRequestId ?? this.clientRequestId,
      sponsorshipIds:
          sponsorshipIds ?? this.sponsorshipIds.map((e0) => e0).toList(),
      grossAmountPaise: grossAmountPaise ?? this.grossAmountPaise,
      deductionPaise: deductionPaise ?? this.deductionPaise,
      amountPaise: amountPaise ?? this.amountPaise,
      status: status ?? this.status,
      requestedAt: requestedAt ?? this.requestedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      reviewedByAuthUserId: reviewedByAuthUserId is _is.UuidValue?
          ? reviewedByAuthUserId
          : this.reviewedByAuthUserId,
      reviewedAt: reviewedAt is DateTime? ? reviewedAt : this.reviewedAt,
      settlementReference: settlementReference is String?
          ? settlementReference
          : this.settlementReference,
      payeeVerificationReference: payeeVerificationReference is String?
          ? payeeVerificationReference
          : this.payeeVerificationReference,
      reviewNote: reviewNote is String? ? reviewNote : this.reviewNote,
      bankTransferReference: bankTransferReference is String?
          ? bankTransferReference
          : this.bankTransferReference,
      paidAt: paidAt is DateTime? ? paidAt : this.paidAt,
    );
  }
}

class ManualPayoutRequestUpdateTable
    extends _is.UpdateTable<ManualPayoutRequestTable> {
  ManualPayoutRequestUpdateTable(super.table);

  _is.ColumnValue<int, int> campaignId(int value) => _is.ColumnValue(
    table.campaignId,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> creatorAuthUserId(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.creatorAuthUserId,
    value,
  );

  _is.ColumnValue<String, String> clientRequestId(String value) =>
      _is.ColumnValue(
        table.clientRequestId,
        value,
      );

  _is.ColumnValue<List<int>, List<int>> sponsorshipIds(List<int> value) =>
      _is.ColumnValue(
        table.sponsorshipIds,
        value,
      );

  _is.ColumnValue<int, int> grossAmountPaise(int value) => _is.ColumnValue(
    table.grossAmountPaise,
    value,
  );

  _is.ColumnValue<int, int> deductionPaise(int value) => _is.ColumnValue(
    table.deductionPaise,
    value,
  );

  _is.ColumnValue<int, int> amountPaise(int value) => _is.ColumnValue(
    table.amountPaise,
    value,
  );

  _is.ColumnValue<String, String> status(String value) => _is.ColumnValue(
    table.status,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> requestedAt(DateTime value) =>
      _is.ColumnValue(
        table.requestedAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> updatedAt(DateTime value) =>
      _is.ColumnValue(
        table.updatedAt,
        value,
      );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> reviewedByAuthUserId(
    _is.UuidValue? value,
  ) => _is.ColumnValue(
    table.reviewedByAuthUserId,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> reviewedAt(DateTime? value) =>
      _is.ColumnValue(
        table.reviewedAt,
        value,
      );

  _is.ColumnValue<String, String> settlementReference(String? value) =>
      _is.ColumnValue(
        table.settlementReference,
        value,
      );

  _is.ColumnValue<String, String> payeeVerificationReference(String? value) =>
      _is.ColumnValue(
        table.payeeVerificationReference,
        value,
      );

  _is.ColumnValue<String, String> reviewNote(String? value) => _is.ColumnValue(
    table.reviewNote,
    value,
  );

  _is.ColumnValue<String, String> bankTransferReference(String? value) =>
      _is.ColumnValue(
        table.bankTransferReference,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> paidAt(DateTime? value) =>
      _is.ColumnValue(
        table.paidAt,
        value,
      );
}

class ManualPayoutRequestTable extends _is.Table<int?> {
  ManualPayoutRequestTable({super.tableRelation})
    : super(tableName: 'fieldnote_manual_payout_request') {
    updateTable = ManualPayoutRequestUpdateTable(this);
    campaignId = _is.ColumnInt(
      'campaignId',
      this,
    );
    creatorAuthUserId = _is.ColumnUuid(
      'creatorAuthUserId',
      this,
    );
    clientRequestId = _is.ColumnString(
      'clientRequestId',
      this,
    );
    sponsorshipIds = _is.ColumnSerializable<List<int>>(
      'sponsorshipIds',
      this,
    );
    grossAmountPaise = _is.ColumnInt(
      'grossAmountPaise',
      this,
    );
    deductionPaise = _is.ColumnInt(
      'deductionPaise',
      this,
      hasDefault: true,
    );
    amountPaise = _is.ColumnInt(
      'amountPaise',
      this,
    );
    status = _is.ColumnString(
      'status',
      this,
      hasDefault: true,
    );
    requestedAt = _is.ColumnDateTime(
      'requestedAt',
      this,
      hasDefault: true,
    );
    updatedAt = _is.ColumnDateTime(
      'updatedAt',
      this,
      hasDefault: true,
    );
    reviewedByAuthUserId = _is.ColumnUuid(
      'reviewedByAuthUserId',
      this,
    );
    reviewedAt = _is.ColumnDateTime(
      'reviewedAt',
      this,
    );
    settlementReference = _is.ColumnString(
      'settlementReference',
      this,
    );
    payeeVerificationReference = _is.ColumnString(
      'payeeVerificationReference',
      this,
    );
    reviewNote = _is.ColumnString(
      'reviewNote',
      this,
    );
    bankTransferReference = _is.ColumnString(
      'bankTransferReference',
      this,
    );
    paidAt = _is.ColumnDateTime(
      'paidAt',
      this,
    );
  }

  late final ManualPayoutRequestUpdateTable updateTable;

  late final _is.ColumnInt campaignId;

  late final _is.ColumnUuid creatorAuthUserId;

  late final _is.ColumnString clientRequestId;

  late final _is.ColumnSerializable<List<int>> sponsorshipIds;

  late final _is.ColumnInt grossAmountPaise;

  late final _is.ColumnInt deductionPaise;

  late final _is.ColumnInt amountPaise;

  late final _is.ColumnString status;

  late final _is.ColumnDateTime requestedAt;

  late final _is.ColumnDateTime updatedAt;

  late final _is.ColumnUuid reviewedByAuthUserId;

  late final _is.ColumnDateTime reviewedAt;

  late final _is.ColumnString settlementReference;

  late final _is.ColumnString payeeVerificationReference;

  late final _is.ColumnString reviewNote;

  late final _is.ColumnString bankTransferReference;

  late final _is.ColumnDateTime paidAt;

  @override
  List<_is.Column> get columns => [
    id,
    campaignId,
    creatorAuthUserId,
    clientRequestId,
    sponsorshipIds,
    grossAmountPaise,
    deductionPaise,
    amountPaise,
    status,
    requestedAt,
    updatedAt,
    reviewedByAuthUserId,
    reviewedAt,
    settlementReference,
    payeeVerificationReference,
    reviewNote,
    bankTransferReference,
    paidAt,
  ];
}

class ManualPayoutRequestInclude extends _is.IncludeObject {
  ManualPayoutRequestInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => ManualPayoutRequest.t;
}

class ManualPayoutRequestIncludeList extends _is.IncludeList {
  ManualPayoutRequestIncludeList._({
    _is.WhereExpressionBuilder<ManualPayoutRequestTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(ManualPayoutRequest.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => ManualPayoutRequest.t;
}

class ManualPayoutRequestRepository {
  const ManualPayoutRequestRepository._();

  /// Returns a list of [ManualPayoutRequest]s matching the given query parameters.
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
  Future<List<ManualPayoutRequest>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ManualPayoutRequestTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ManualPayoutRequestTable>? orderBy,
    _is.OrderByListBuilder<ManualPayoutRequestTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<ManualPayoutRequest>(
      where: where?.call(ManualPayoutRequest.t),
      orderBy: orderBy?.call(ManualPayoutRequest.t),
      orderByList: orderByList?.call(ManualPayoutRequest.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [ManualPayoutRequest] matching the given query parameters.
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
  Future<ManualPayoutRequest?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ManualPayoutRequestTable>? where,
    int? offset,
    _is.OrderByBuilder<ManualPayoutRequestTable>? orderBy,
    _is.OrderByListBuilder<ManualPayoutRequestTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<ManualPayoutRequest>(
      where: where?.call(ManualPayoutRequest.t),
      orderBy: orderBy?.call(ManualPayoutRequest.t),
      orderByList: orderByList?.call(ManualPayoutRequest.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [ManualPayoutRequest] by its [id] or null if no such row exists.
  Future<ManualPayoutRequest?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<ManualPayoutRequest>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [ManualPayoutRequest]s in the list and returns the inserted rows.
  ///
  /// The returned [ManualPayoutRequest]s will have their `id` fields set.
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
  Future<List<ManualPayoutRequest>> insert(
    _is.DatabaseSession session,
    List<ManualPayoutRequest> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<ManualPayoutRequest>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [ManualPayoutRequest] and returns the inserted row.
  ///
  /// The returned [ManualPayoutRequest] will have its `id` field set.
  Future<ManualPayoutRequest> insertRow(
    _is.DatabaseSession session,
    ManualPayoutRequest row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<ManualPayoutRequest>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [ManualPayoutRequest]s in the list and returns the resulting rows.
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
  /// The returned [ManualPayoutRequest]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ManualPayoutRequest>> upsert(
    _is.DatabaseSession session,
    List<ManualPayoutRequest> rows, {
    required _is.ColumnSelections<ManualPayoutRequestTable> conflictColumns,
    _is.ColumnSelections<ManualPayoutRequestTable>? updateColumns,
    _is.WhereExpressionBuilder<ManualPayoutRequestTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<ManualPayoutRequest>(
      rows,
      conflictColumns: conflictColumns(ManualPayoutRequest.t),
      updateColumns: updateColumns?.call(ManualPayoutRequest.t),
      updateWhere: updateWhere?.call(ManualPayoutRequest.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [ManualPayoutRequest] and returns the resulting row.
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
  /// The returned [ManualPayoutRequest] will have its `id` field set.
  Future<ManualPayoutRequest?> upsertRow(
    _is.DatabaseSession session,
    ManualPayoutRequest row, {
    required _is.ColumnSelections<ManualPayoutRequestTable> conflictColumns,
    _is.ColumnSelections<ManualPayoutRequestTable>? updateColumns,
    _is.WhereExpressionBuilder<ManualPayoutRequestTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<ManualPayoutRequest>(
      row,
      conflictColumns: conflictColumns(ManualPayoutRequest.t),
      updateColumns: updateColumns?.call(ManualPayoutRequest.t),
      updateWhere: updateWhere?.call(ManualPayoutRequest.t),
      transaction: transaction,
    );
  }

  /// Updates all [ManualPayoutRequest]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ManualPayoutRequest>> update(
    _is.DatabaseSession session,
    List<ManualPayoutRequest> rows, {
    _is.ColumnSelections<ManualPayoutRequestTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<ManualPayoutRequest>(
      rows,
      columns: columns?.call(ManualPayoutRequest.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [ManualPayoutRequest]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<ManualPayoutRequest> updateRow(
    _is.DatabaseSession session,
    ManualPayoutRequest row, {
    _is.ColumnSelections<ManualPayoutRequestTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<ManualPayoutRequest>(
      row,
      columns: columns?.call(ManualPayoutRequest.t),
      transaction: transaction,
    );
  }

  /// Updates a single [ManualPayoutRequest] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<ManualPayoutRequest?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<ManualPayoutRequestUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<ManualPayoutRequest>(
      id,
      columnValues: columnValues(ManualPayoutRequest.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [ManualPayoutRequest]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ManualPayoutRequest>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<ManualPayoutRequestUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<ManualPayoutRequestTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ManualPayoutRequestTable>? orderBy,
    _is.OrderByListBuilder<ManualPayoutRequestTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<ManualPayoutRequest>(
      columnValues: columnValues(ManualPayoutRequest.t.updateTable),
      where: where(ManualPayoutRequest.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ManualPayoutRequest.t),
      orderByList: orderByList?.call(ManualPayoutRequest.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [ManualPayoutRequest]s in the list and returns the deleted rows.
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
  Future<List<ManualPayoutRequest>> delete(
    _is.DatabaseSession session,
    List<ManualPayoutRequest> rows, {
    _is.OrderByBuilder<ManualPayoutRequestTable>? orderBy,
    _is.OrderByListBuilder<ManualPayoutRequestTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<ManualPayoutRequest>(
      rows,
      orderBy: orderBy?.call(ManualPayoutRequest.t),
      orderByList: orderByList?.call(ManualPayoutRequest.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [ManualPayoutRequest].
  Future<ManualPayoutRequest> deleteRow(
    _is.DatabaseSession session,
    ManualPayoutRequest row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<ManualPayoutRequest>(
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
  Future<List<ManualPayoutRequest>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<ManualPayoutRequestTable> where,
    _is.OrderByBuilder<ManualPayoutRequestTable>? orderBy,
    _is.OrderByListBuilder<ManualPayoutRequestTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<ManualPayoutRequest>(
      where: where(ManualPayoutRequest.t),
      orderBy: orderBy?.call(ManualPayoutRequest.t),
      orderByList: orderByList?.call(ManualPayoutRequest.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ManualPayoutRequestTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<ManualPayoutRequest>(
      where: where?.call(ManualPayoutRequest.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [ManualPayoutRequest] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<ManualPayoutRequestTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<ManualPayoutRequest>(
      where: where(ManualPayoutRequest.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
