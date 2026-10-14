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

abstract class CampaignChatMessage
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  CampaignChatMessage._({
    this.id,
    required this.campaignId,
    required this.senderAuthUserId,
    required this.senderDisplayName,
    required this.senderIsCreator,
    required this.body,
    required this.clientRequestId,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory CampaignChatMessage({
    int? id,
    required int campaignId,
    required _is.UuidValue senderAuthUserId,
    required String senderDisplayName,
    required bool senderIsCreator,
    required String body,
    required String clientRequestId,
    DateTime? createdAt,
  }) = _CampaignChatMessageImpl;

  factory CampaignChatMessage.fromJson(Map<String, dynamic> jsonSerialization) {
    return CampaignChatMessage(
      id: jsonSerialization['id'] as int?,
      campaignId: jsonSerialization['campaignId'] as int,
      senderAuthUserId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['senderAuthUserId'],
      ),
      senderDisplayName: jsonSerialization['senderDisplayName'] as String,
      senderIsCreator: _is.BoolJsonExtension.fromJson(
        jsonSerialization['senderIsCreator'],
      ),
      body: jsonSerialization['body'] as String,
      clientRequestId: jsonSerialization['clientRequestId'] as String,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  static final t = CampaignChatMessageTable();

  static const db = CampaignChatMessageRepository._();

  @override
  int? id;

  int campaignId;

  _is.UuidValue senderAuthUserId;

  String senderDisplayName;

  bool senderIsCreator;

  String body;

  String clientRequestId;

  DateTime createdAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [CampaignChatMessage]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CampaignChatMessage copyWith({
    int? id,
    int? campaignId,
    _is.UuidValue? senderAuthUserId,
    String? senderDisplayName,
    bool? senderIsCreator,
    String? body,
    String? clientRequestId,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'CampaignChatMessage',
      if (id != null) 'id': id,
      'campaignId': campaignId,
      'senderAuthUserId': senderAuthUserId.toJson(),
      'senderDisplayName': senderDisplayName,
      'senderIsCreator': senderIsCreator,
      'body': body,
      'clientRequestId': clientRequestId,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'CampaignChatMessage',
      if (id != null) 'id': id,
      'campaignId': campaignId,
      'senderAuthUserId': senderAuthUserId.toJson(),
      'senderDisplayName': senderDisplayName,
      'senderIsCreator': senderIsCreator,
      'body': body,
      'clientRequestId': clientRequestId,
      'createdAt': createdAt.toJson(),
    };
  }

  static CampaignChatMessageInclude include() {
    return CampaignChatMessageInclude._();
  }

  static CampaignChatMessageIncludeList includeList({
    _is.WhereExpressionBuilder<CampaignChatMessageTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CampaignChatMessageTable>? orderBy,
    _is.OrderByListBuilder<CampaignChatMessageTable>? orderByList,
    CampaignChatMessageInclude? include,
  }) {
    return CampaignChatMessageIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CampaignChatMessage.t),
      orderByList: orderByList?.call(CampaignChatMessage.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CampaignChatMessageImpl extends CampaignChatMessage {
  _CampaignChatMessageImpl({
    int? id,
    required int campaignId,
    required _is.UuidValue senderAuthUserId,
    required String senderDisplayName,
    required bool senderIsCreator,
    required String body,
    required String clientRequestId,
    DateTime? createdAt,
  }) : super._(
         id: id,
         campaignId: campaignId,
         senderAuthUserId: senderAuthUserId,
         senderDisplayName: senderDisplayName,
         senderIsCreator: senderIsCreator,
         body: body,
         clientRequestId: clientRequestId,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [CampaignChatMessage]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CampaignChatMessage copyWith({
    Object? id = _Undefined,
    int? campaignId,
    _is.UuidValue? senderAuthUserId,
    String? senderDisplayName,
    bool? senderIsCreator,
    String? body,
    String? clientRequestId,
    DateTime? createdAt,
  }) {
    return CampaignChatMessage(
      id: id is int? ? id : this.id,
      campaignId: campaignId ?? this.campaignId,
      senderAuthUserId: senderAuthUserId ?? this.senderAuthUserId,
      senderDisplayName: senderDisplayName ?? this.senderDisplayName,
      senderIsCreator: senderIsCreator ?? this.senderIsCreator,
      body: body ?? this.body,
      clientRequestId: clientRequestId ?? this.clientRequestId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class CampaignChatMessageUpdateTable
    extends _is.UpdateTable<CampaignChatMessageTable> {
  CampaignChatMessageUpdateTable(super.table);

  _is.ColumnValue<int, int> campaignId(int value) => _is.ColumnValue(
    table.campaignId,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> senderAuthUserId(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.senderAuthUserId,
    value,
  );

  _is.ColumnValue<String, String> senderDisplayName(String value) =>
      _is.ColumnValue(
        table.senderDisplayName,
        value,
      );

  _is.ColumnValue<bool, bool> senderIsCreator(bool value) => _is.ColumnValue(
    table.senderIsCreator,
    value,
  );

  _is.ColumnValue<String, String> body(String value) => _is.ColumnValue(
    table.body,
    value,
  );

  _is.ColumnValue<String, String> clientRequestId(String value) =>
      _is.ColumnValue(
        table.clientRequestId,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );
}

class CampaignChatMessageTable extends _is.Table<int?> {
  CampaignChatMessageTable({super.tableRelation})
    : super(tableName: 'fieldnote_campaign_chat_message') {
    updateTable = CampaignChatMessageUpdateTable(this);
    campaignId = _is.ColumnInt(
      'campaignId',
      this,
    );
    senderAuthUserId = _is.ColumnUuid(
      'senderAuthUserId',
      this,
    );
    senderDisplayName = _is.ColumnString(
      'senderDisplayName',
      this,
    );
    senderIsCreator = _is.ColumnBool(
      'senderIsCreator',
      this,
    );
    body = _is.ColumnString(
      'body',
      this,
    );
    clientRequestId = _is.ColumnString(
      'clientRequestId',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
      hasDefault: true,
    );
  }

  late final CampaignChatMessageUpdateTable updateTable;

  late final _is.ColumnInt campaignId;

  late final _is.ColumnUuid senderAuthUserId;

  late final _is.ColumnString senderDisplayName;

  late final _is.ColumnBool senderIsCreator;

  late final _is.ColumnString body;

  late final _is.ColumnString clientRequestId;

  late final _is.ColumnDateTime createdAt;

  @override
  List<_is.Column> get columns => [
    id,
    campaignId,
    senderAuthUserId,
    senderDisplayName,
    senderIsCreator,
    body,
    clientRequestId,
    createdAt,
  ];
}

class CampaignChatMessageInclude extends _is.IncludeObject {
  CampaignChatMessageInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => CampaignChatMessage.t;
}

class CampaignChatMessageIncludeList extends _is.IncludeList {
  CampaignChatMessageIncludeList._({
    _is.WhereExpressionBuilder<CampaignChatMessageTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(CampaignChatMessage.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => CampaignChatMessage.t;
}

class CampaignChatMessageRepository {
  const CampaignChatMessageRepository._();

  /// Returns a list of [CampaignChatMessage]s matching the given query parameters.
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
  Future<List<CampaignChatMessage>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CampaignChatMessageTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CampaignChatMessageTable>? orderBy,
    _is.OrderByListBuilder<CampaignChatMessageTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<CampaignChatMessage>(
      where: where?.call(CampaignChatMessage.t),
      orderBy: orderBy?.call(CampaignChatMessage.t),
      orderByList: orderByList?.call(CampaignChatMessage.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [CampaignChatMessage] matching the given query parameters.
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
  Future<CampaignChatMessage?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CampaignChatMessageTable>? where,
    int? offset,
    _is.OrderByBuilder<CampaignChatMessageTable>? orderBy,
    _is.OrderByListBuilder<CampaignChatMessageTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<CampaignChatMessage>(
      where: where?.call(CampaignChatMessage.t),
      orderBy: orderBy?.call(CampaignChatMessage.t),
      orderByList: orderByList?.call(CampaignChatMessage.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [CampaignChatMessage] by its [id] or null if no such row exists.
  Future<CampaignChatMessage?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<CampaignChatMessage>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [CampaignChatMessage]s in the list and returns the inserted rows.
  ///
  /// The returned [CampaignChatMessage]s will have their `id` fields set.
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
  Future<List<CampaignChatMessage>> insert(
    _is.DatabaseSession session,
    List<CampaignChatMessage> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<CampaignChatMessage>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [CampaignChatMessage] and returns the inserted row.
  ///
  /// The returned [CampaignChatMessage] will have its `id` field set.
  Future<CampaignChatMessage> insertRow(
    _is.DatabaseSession session,
    CampaignChatMessage row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<CampaignChatMessage>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [CampaignChatMessage]s in the list and returns the resulting rows.
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
  /// The returned [CampaignChatMessage]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CampaignChatMessage>> upsert(
    _is.DatabaseSession session,
    List<CampaignChatMessage> rows, {
    required _is.ColumnSelections<CampaignChatMessageTable> conflictColumns,
    _is.ColumnSelections<CampaignChatMessageTable>? updateColumns,
    _is.WhereExpressionBuilder<CampaignChatMessageTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<CampaignChatMessage>(
      rows,
      conflictColumns: conflictColumns(CampaignChatMessage.t),
      updateColumns: updateColumns?.call(CampaignChatMessage.t),
      updateWhere: updateWhere?.call(CampaignChatMessage.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [CampaignChatMessage] and returns the resulting row.
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
  /// The returned [CampaignChatMessage] will have its `id` field set.
  Future<CampaignChatMessage?> upsertRow(
    _is.DatabaseSession session,
    CampaignChatMessage row, {
    required _is.ColumnSelections<CampaignChatMessageTable> conflictColumns,
    _is.ColumnSelections<CampaignChatMessageTable>? updateColumns,
    _is.WhereExpressionBuilder<CampaignChatMessageTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<CampaignChatMessage>(
      row,
      conflictColumns: conflictColumns(CampaignChatMessage.t),
      updateColumns: updateColumns?.call(CampaignChatMessage.t),
      updateWhere: updateWhere?.call(CampaignChatMessage.t),
      transaction: transaction,
    );
  }

  /// Updates all [CampaignChatMessage]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CampaignChatMessage>> update(
    _is.DatabaseSession session,
    List<CampaignChatMessage> rows, {
    _is.ColumnSelections<CampaignChatMessageTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<CampaignChatMessage>(
      rows,
      columns: columns?.call(CampaignChatMessage.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [CampaignChatMessage]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<CampaignChatMessage> updateRow(
    _is.DatabaseSession session,
    CampaignChatMessage row, {
    _is.ColumnSelections<CampaignChatMessageTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<CampaignChatMessage>(
      row,
      columns: columns?.call(CampaignChatMessage.t),
      transaction: transaction,
    );
  }

  /// Updates a single [CampaignChatMessage] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<CampaignChatMessage?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<CampaignChatMessageUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<CampaignChatMessage>(
      id,
      columnValues: columnValues(CampaignChatMessage.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [CampaignChatMessage]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CampaignChatMessage>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<CampaignChatMessageUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<CampaignChatMessageTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CampaignChatMessageTable>? orderBy,
    _is.OrderByListBuilder<CampaignChatMessageTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<CampaignChatMessage>(
      columnValues: columnValues(CampaignChatMessage.t.updateTable),
      where: where(CampaignChatMessage.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CampaignChatMessage.t),
      orderByList: orderByList?.call(CampaignChatMessage.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [CampaignChatMessage]s in the list and returns the deleted rows.
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
  Future<List<CampaignChatMessage>> delete(
    _is.DatabaseSession session,
    List<CampaignChatMessage> rows, {
    _is.OrderByBuilder<CampaignChatMessageTable>? orderBy,
    _is.OrderByListBuilder<CampaignChatMessageTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<CampaignChatMessage>(
      rows,
      orderBy: orderBy?.call(CampaignChatMessage.t),
      orderByList: orderByList?.call(CampaignChatMessage.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [CampaignChatMessage].
  Future<CampaignChatMessage> deleteRow(
    _is.DatabaseSession session,
    CampaignChatMessage row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<CampaignChatMessage>(
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
  Future<List<CampaignChatMessage>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CampaignChatMessageTable> where,
    _is.OrderByBuilder<CampaignChatMessageTable>? orderBy,
    _is.OrderByListBuilder<CampaignChatMessageTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<CampaignChatMessage>(
      where: where(CampaignChatMessage.t),
      orderBy: orderBy?.call(CampaignChatMessage.t),
      orderByList: orderByList?.call(CampaignChatMessage.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CampaignChatMessageTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<CampaignChatMessage>(
      where: where?.call(CampaignChatMessage.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [CampaignChatMessage] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CampaignChatMessageTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<CampaignChatMessage>(
      where: where(CampaignChatMessage.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
