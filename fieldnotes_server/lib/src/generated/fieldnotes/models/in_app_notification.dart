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

/// Private inbox. Only NotificationItem DTOs cross the RPC boundary.
abstract class InAppNotification
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  InAppNotification._({
    this.id,
    required this.recipientAuthUserId,
    required this.kind,
    required this.dedupeKey,
    required this.title,
    required this.body,
    this.campaignId,
    DateTime? createdAt,
    this.readAt,
    int? unreadCount,
    this.chatMessageId,
  }) : createdAt = createdAt ?? DateTime.now(),
       unreadCount = unreadCount ?? 1;

  factory InAppNotification({
    int? id,
    required _is.UuidValue recipientAuthUserId,
    required String kind,
    required String dedupeKey,
    required String title,
    required String body,
    int? campaignId,
    DateTime? createdAt,
    DateTime? readAt,
    int? unreadCount,
    int? chatMessageId,
  }) = _InAppNotificationImpl;

  factory InAppNotification.fromJson(Map<String, dynamic> jsonSerialization) {
    return InAppNotification(
      id: jsonSerialization['id'] as int?,
      recipientAuthUserId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['recipientAuthUserId'],
      ),
      kind: jsonSerialization['kind'] as String,
      dedupeKey: jsonSerialization['dedupeKey'] as String,
      title: jsonSerialization['title'] as String,
      body: jsonSerialization['body'] as String,
      campaignId: jsonSerialization['campaignId'] as int?,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      readAt: jsonSerialization['readAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['readAt']),
      unreadCount: jsonSerialization['unreadCount'] as int?,
      chatMessageId: jsonSerialization['chatMessageId'] as int?,
    );
  }

  static final t = InAppNotificationTable();

  static const db = InAppNotificationRepository._();

  @override
  int? id;

  _is.UuidValue recipientAuthUserId;

  String kind;

  String dedupeKey;

  String title;

  String body;

  int? campaignId;

  DateTime createdAt;

  DateTime? readAt;

  int unreadCount;

  int? chatMessageId;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [InAppNotification]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  InAppNotification copyWith({
    int? id,
    _is.UuidValue? recipientAuthUserId,
    String? kind,
    String? dedupeKey,
    String? title,
    String? body,
    int? campaignId,
    DateTime? createdAt,
    DateTime? readAt,
    int? unreadCount,
    int? chatMessageId,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'InAppNotification',
      if (id != null) 'id': id,
      'recipientAuthUserId': recipientAuthUserId.toJson(),
      'kind': kind,
      'dedupeKey': dedupeKey,
      'title': title,
      'body': body,
      if (campaignId != null) 'campaignId': campaignId,
      'createdAt': createdAt.toJson(),
      if (readAt != null) 'readAt': readAt?.toJson(),
      'unreadCount': unreadCount,
      if (chatMessageId != null) 'chatMessageId': chatMessageId,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static InAppNotificationInclude include() {
    return InAppNotificationInclude._();
  }

  static InAppNotificationIncludeList includeList({
    _is.WhereExpressionBuilder<InAppNotificationTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<InAppNotificationTable>? orderBy,
    _is.OrderByListBuilder<InAppNotificationTable>? orderByList,
    InAppNotificationInclude? include,
  }) {
    return InAppNotificationIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(InAppNotification.t),
      orderByList: orderByList?.call(InAppNotification.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _InAppNotificationImpl extends InAppNotification {
  _InAppNotificationImpl({
    int? id,
    required _is.UuidValue recipientAuthUserId,
    required String kind,
    required String dedupeKey,
    required String title,
    required String body,
    int? campaignId,
    DateTime? createdAt,
    DateTime? readAt,
    int? unreadCount,
    int? chatMessageId,
  }) : super._(
         id: id,
         recipientAuthUserId: recipientAuthUserId,
         kind: kind,
         dedupeKey: dedupeKey,
         title: title,
         body: body,
         campaignId: campaignId,
         createdAt: createdAt,
         readAt: readAt,
         unreadCount: unreadCount,
         chatMessageId: chatMessageId,
       );

  /// Returns a shallow copy of this [InAppNotification]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  InAppNotification copyWith({
    Object? id = _Undefined,
    _is.UuidValue? recipientAuthUserId,
    String? kind,
    String? dedupeKey,
    String? title,
    String? body,
    Object? campaignId = _Undefined,
    DateTime? createdAt,
    Object? readAt = _Undefined,
    int? unreadCount,
    Object? chatMessageId = _Undefined,
  }) {
    return InAppNotification(
      id: id is int? ? id : this.id,
      recipientAuthUserId: recipientAuthUserId ?? this.recipientAuthUserId,
      kind: kind ?? this.kind,
      dedupeKey: dedupeKey ?? this.dedupeKey,
      title: title ?? this.title,
      body: body ?? this.body,
      campaignId: campaignId is int? ? campaignId : this.campaignId,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt is DateTime? ? readAt : this.readAt,
      unreadCount: unreadCount ?? this.unreadCount,
      chatMessageId: chatMessageId is int? ? chatMessageId : this.chatMessageId,
    );
  }
}

class InAppNotificationUpdateTable
    extends _is.UpdateTable<InAppNotificationTable> {
  InAppNotificationUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> recipientAuthUserId(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.recipientAuthUserId,
    value,
  );

  _is.ColumnValue<String, String> kind(String value) => _is.ColumnValue(
    table.kind,
    value,
  );

  _is.ColumnValue<String, String> dedupeKey(String value) => _is.ColumnValue(
    table.dedupeKey,
    value,
  );

  _is.ColumnValue<String, String> title(String value) => _is.ColumnValue(
    table.title,
    value,
  );

  _is.ColumnValue<String, String> body(String value) => _is.ColumnValue(
    table.body,
    value,
  );

  _is.ColumnValue<int, int> campaignId(int? value) => _is.ColumnValue(
    table.campaignId,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> readAt(DateTime? value) =>
      _is.ColumnValue(
        table.readAt,
        value,
      );

  _is.ColumnValue<int, int> unreadCount(int value) => _is.ColumnValue(
    table.unreadCount,
    value,
  );

  _is.ColumnValue<int, int> chatMessageId(int? value) => _is.ColumnValue(
    table.chatMessageId,
    value,
  );
}

class InAppNotificationTable extends _is.Table<int?> {
  InAppNotificationTable({super.tableRelation})
    : super(tableName: 'fieldnote_in_app_notification') {
    updateTable = InAppNotificationUpdateTable(this);
    recipientAuthUserId = _is.ColumnUuid(
      'recipientAuthUserId',
      this,
    );
    kind = _is.ColumnString(
      'kind',
      this,
    );
    dedupeKey = _is.ColumnString(
      'dedupeKey',
      this,
    );
    title = _is.ColumnString(
      'title',
      this,
    );
    body = _is.ColumnString(
      'body',
      this,
    );
    campaignId = _is.ColumnInt(
      'campaignId',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
      hasDefault: true,
    );
    readAt = _is.ColumnDateTime(
      'readAt',
      this,
    );
    unreadCount = _is.ColumnInt(
      'unreadCount',
      this,
      hasDefault: true,
    );
    chatMessageId = _is.ColumnInt(
      'chatMessageId',
      this,
    );
  }

  late final InAppNotificationUpdateTable updateTable;

  late final _is.ColumnUuid recipientAuthUserId;

  late final _is.ColumnString kind;

  late final _is.ColumnString dedupeKey;

  late final _is.ColumnString title;

  late final _is.ColumnString body;

  late final _is.ColumnInt campaignId;

  late final _is.ColumnDateTime createdAt;

  late final _is.ColumnDateTime readAt;

  late final _is.ColumnInt unreadCount;

  late final _is.ColumnInt chatMessageId;

  @override
  List<_is.Column> get columns => [
    id,
    recipientAuthUserId,
    kind,
    dedupeKey,
    title,
    body,
    campaignId,
    createdAt,
    readAt,
    unreadCount,
    chatMessageId,
  ];
}

class InAppNotificationInclude extends _is.IncludeObject {
  InAppNotificationInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => InAppNotification.t;
}

class InAppNotificationIncludeList extends _is.IncludeList {
  InAppNotificationIncludeList._({
    _is.WhereExpressionBuilder<InAppNotificationTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(InAppNotification.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => InAppNotification.t;
}

class InAppNotificationRepository {
  const InAppNotificationRepository._();

  /// Returns a list of [InAppNotification]s matching the given query parameters.
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
  Future<List<InAppNotification>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<InAppNotificationTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<InAppNotificationTable>? orderBy,
    _is.OrderByListBuilder<InAppNotificationTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<InAppNotification>(
      where: where?.call(InAppNotification.t),
      orderBy: orderBy?.call(InAppNotification.t),
      orderByList: orderByList?.call(InAppNotification.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [InAppNotification] matching the given query parameters.
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
  Future<InAppNotification?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<InAppNotificationTable>? where,
    int? offset,
    _is.OrderByBuilder<InAppNotificationTable>? orderBy,
    _is.OrderByListBuilder<InAppNotificationTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<InAppNotification>(
      where: where?.call(InAppNotification.t),
      orderBy: orderBy?.call(InAppNotification.t),
      orderByList: orderByList?.call(InAppNotification.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [InAppNotification] by its [id] or null if no such row exists.
  Future<InAppNotification?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<InAppNotification>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [InAppNotification]s in the list and returns the inserted rows.
  ///
  /// The returned [InAppNotification]s will have their `id` fields set.
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
  Future<List<InAppNotification>> insert(
    _is.DatabaseSession session,
    List<InAppNotification> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<InAppNotification>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [InAppNotification] and returns the inserted row.
  ///
  /// The returned [InAppNotification] will have its `id` field set.
  Future<InAppNotification> insertRow(
    _is.DatabaseSession session,
    InAppNotification row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<InAppNotification>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [InAppNotification]s in the list and returns the resulting rows.
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
  /// The returned [InAppNotification]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<InAppNotification>> upsert(
    _is.DatabaseSession session,
    List<InAppNotification> rows, {
    required _is.ColumnSelections<InAppNotificationTable> conflictColumns,
    _is.ColumnSelections<InAppNotificationTable>? updateColumns,
    _is.WhereExpressionBuilder<InAppNotificationTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<InAppNotification>(
      rows,
      conflictColumns: conflictColumns(InAppNotification.t),
      updateColumns: updateColumns?.call(InAppNotification.t),
      updateWhere: updateWhere?.call(InAppNotification.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [InAppNotification] and returns the resulting row.
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
  /// The returned [InAppNotification] will have its `id` field set.
  Future<InAppNotification?> upsertRow(
    _is.DatabaseSession session,
    InAppNotification row, {
    required _is.ColumnSelections<InAppNotificationTable> conflictColumns,
    _is.ColumnSelections<InAppNotificationTable>? updateColumns,
    _is.WhereExpressionBuilder<InAppNotificationTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<InAppNotification>(
      row,
      conflictColumns: conflictColumns(InAppNotification.t),
      updateColumns: updateColumns?.call(InAppNotification.t),
      updateWhere: updateWhere?.call(InAppNotification.t),
      transaction: transaction,
    );
  }

  /// Updates all [InAppNotification]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<InAppNotification>> update(
    _is.DatabaseSession session,
    List<InAppNotification> rows, {
    _is.ColumnSelections<InAppNotificationTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<InAppNotification>(
      rows,
      columns: columns?.call(InAppNotification.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [InAppNotification]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<InAppNotification> updateRow(
    _is.DatabaseSession session,
    InAppNotification row, {
    _is.ColumnSelections<InAppNotificationTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<InAppNotification>(
      row,
      columns: columns?.call(InAppNotification.t),
      transaction: transaction,
    );
  }

  /// Updates a single [InAppNotification] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<InAppNotification?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<InAppNotificationUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<InAppNotification>(
      id,
      columnValues: columnValues(InAppNotification.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [InAppNotification]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<InAppNotification>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<InAppNotificationUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<InAppNotificationTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<InAppNotificationTable>? orderBy,
    _is.OrderByListBuilder<InAppNotificationTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<InAppNotification>(
      columnValues: columnValues(InAppNotification.t.updateTable),
      where: where(InAppNotification.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(InAppNotification.t),
      orderByList: orderByList?.call(InAppNotification.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [InAppNotification]s in the list and returns the deleted rows.
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
  Future<List<InAppNotification>> delete(
    _is.DatabaseSession session,
    List<InAppNotification> rows, {
    _is.OrderByBuilder<InAppNotificationTable>? orderBy,
    _is.OrderByListBuilder<InAppNotificationTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<InAppNotification>(
      rows,
      orderBy: orderBy?.call(InAppNotification.t),
      orderByList: orderByList?.call(InAppNotification.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [InAppNotification].
  Future<InAppNotification> deleteRow(
    _is.DatabaseSession session,
    InAppNotification row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<InAppNotification>(
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
  Future<List<InAppNotification>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<InAppNotificationTable> where,
    _is.OrderByBuilder<InAppNotificationTable>? orderBy,
    _is.OrderByListBuilder<InAppNotificationTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<InAppNotification>(
      where: where(InAppNotification.t),
      orderBy: orderBy?.call(InAppNotification.t),
      orderByList: orderByList?.call(InAppNotification.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<InAppNotificationTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<InAppNotification>(
      where: where?.call(InAppNotification.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [InAppNotification] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<InAppNotificationTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<InAppNotification>(
      where: where(InAppNotification.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
