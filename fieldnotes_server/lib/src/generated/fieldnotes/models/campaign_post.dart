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

abstract class CampaignPost
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  CampaignPost._({
    this.id,
    required this.campaignId,
    required this.authorSponsorAuthUserId,
    required this.title,
    required this.body,
    this.photographPath,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory CampaignPost({
    int? id,
    required int campaignId,
    required _is.UuidValue authorSponsorAuthUserId,
    required String title,
    required String body,
    String? photographPath,
    DateTime? createdAt,
  }) = _CampaignPostImpl;

  factory CampaignPost.fromJson(Map<String, dynamic> jsonSerialization) {
    return CampaignPost(
      id: jsonSerialization['id'] as int?,
      campaignId: jsonSerialization['campaignId'] as int,
      authorSponsorAuthUserId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['authorSponsorAuthUserId'],
      ),
      title: jsonSerialization['title'] as String,
      body: jsonSerialization['body'] as String,
      photographPath: jsonSerialization['photographPath'] as String?,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  static final t = CampaignPostTable();

  static const db = CampaignPostRepository._();

  @override
  int? id;

  int campaignId;

  _is.UuidValue authorSponsorAuthUserId;

  String title;

  String body;

  String? photographPath;

  DateTime createdAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [CampaignPost]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CampaignPost copyWith({
    int? id,
    int? campaignId,
    _is.UuidValue? authorSponsorAuthUserId,
    String? title,
    String? body,
    String? photographPath,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'CampaignPost',
      if (id != null) 'id': id,
      'campaignId': campaignId,
      'authorSponsorAuthUserId': authorSponsorAuthUserId.toJson(),
      'title': title,
      'body': body,
      if (photographPath != null) 'photographPath': photographPath,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'CampaignPost',
      if (id != null) 'id': id,
      'campaignId': campaignId,
      'authorSponsorAuthUserId': authorSponsorAuthUserId.toJson(),
      'title': title,
      'body': body,
      if (photographPath != null) 'photographPath': photographPath,
      'createdAt': createdAt.toJson(),
    };
  }

  static CampaignPostInclude include() {
    return CampaignPostInclude._();
  }

  static CampaignPostIncludeList includeList({
    _is.WhereExpressionBuilder<CampaignPostTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CampaignPostTable>? orderBy,
    _is.OrderByListBuilder<CampaignPostTable>? orderByList,
    CampaignPostInclude? include,
  }) {
    return CampaignPostIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CampaignPost.t),
      orderByList: orderByList?.call(CampaignPost.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CampaignPostImpl extends CampaignPost {
  _CampaignPostImpl({
    int? id,
    required int campaignId,
    required _is.UuidValue authorSponsorAuthUserId,
    required String title,
    required String body,
    String? photographPath,
    DateTime? createdAt,
  }) : super._(
         id: id,
         campaignId: campaignId,
         authorSponsorAuthUserId: authorSponsorAuthUserId,
         title: title,
         body: body,
         photographPath: photographPath,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [CampaignPost]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CampaignPost copyWith({
    Object? id = _Undefined,
    int? campaignId,
    _is.UuidValue? authorSponsorAuthUserId,
    String? title,
    String? body,
    Object? photographPath = _Undefined,
    DateTime? createdAt,
  }) {
    return CampaignPost(
      id: id is int? ? id : this.id,
      campaignId: campaignId ?? this.campaignId,
      authorSponsorAuthUserId:
          authorSponsorAuthUserId ?? this.authorSponsorAuthUserId,
      title: title ?? this.title,
      body: body ?? this.body,
      photographPath: photographPath is String?
          ? photographPath
          : this.photographPath,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class CampaignPostUpdateTable extends _is.UpdateTable<CampaignPostTable> {
  CampaignPostUpdateTable(super.table);

  _is.ColumnValue<int, int> campaignId(int value) => _is.ColumnValue(
    table.campaignId,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> authorSponsorAuthUserId(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.authorSponsorAuthUserId,
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

  _is.ColumnValue<String, String> photographPath(String? value) =>
      _is.ColumnValue(
        table.photographPath,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );
}

class CampaignPostTable extends _is.Table<int?> {
  CampaignPostTable({super.tableRelation})
    : super(tableName: 'fieldnote_campaign_post') {
    updateTable = CampaignPostUpdateTable(this);
    campaignId = _is.ColumnInt(
      'campaignId',
      this,
    );
    authorSponsorAuthUserId = _is.ColumnUuid(
      'authorSponsorAuthUserId',
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
    photographPath = _is.ColumnString(
      'photographPath',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
      hasDefault: true,
    );
  }

  late final CampaignPostUpdateTable updateTable;

  late final _is.ColumnInt campaignId;

  late final _is.ColumnUuid authorSponsorAuthUserId;

  late final _is.ColumnString title;

  late final _is.ColumnString body;

  late final _is.ColumnString photographPath;

  late final _is.ColumnDateTime createdAt;

  @override
  List<_is.Column> get columns => [
    id,
    campaignId,
    authorSponsorAuthUserId,
    title,
    body,
    photographPath,
    createdAt,
  ];
}

class CampaignPostInclude extends _is.IncludeObject {
  CampaignPostInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => CampaignPost.t;
}

class CampaignPostIncludeList extends _is.IncludeList {
  CampaignPostIncludeList._({
    _is.WhereExpressionBuilder<CampaignPostTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(CampaignPost.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => CampaignPost.t;
}

class CampaignPostRepository {
  const CampaignPostRepository._();

  /// Returns a list of [CampaignPost]s matching the given query parameters.
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
  Future<List<CampaignPost>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CampaignPostTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CampaignPostTable>? orderBy,
    _is.OrderByListBuilder<CampaignPostTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<CampaignPost>(
      where: where?.call(CampaignPost.t),
      orderBy: orderBy?.call(CampaignPost.t),
      orderByList: orderByList?.call(CampaignPost.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [CampaignPost] matching the given query parameters.
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
  Future<CampaignPost?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CampaignPostTable>? where,
    int? offset,
    _is.OrderByBuilder<CampaignPostTable>? orderBy,
    _is.OrderByListBuilder<CampaignPostTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<CampaignPost>(
      where: where?.call(CampaignPost.t),
      orderBy: orderBy?.call(CampaignPost.t),
      orderByList: orderByList?.call(CampaignPost.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [CampaignPost] by its [id] or null if no such row exists.
  Future<CampaignPost?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<CampaignPost>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [CampaignPost]s in the list and returns the inserted rows.
  ///
  /// The returned [CampaignPost]s will have their `id` fields set.
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
  Future<List<CampaignPost>> insert(
    _is.DatabaseSession session,
    List<CampaignPost> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<CampaignPost>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [CampaignPost] and returns the inserted row.
  ///
  /// The returned [CampaignPost] will have its `id` field set.
  Future<CampaignPost> insertRow(
    _is.DatabaseSession session,
    CampaignPost row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<CampaignPost>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [CampaignPost]s in the list and returns the resulting rows.
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
  /// The returned [CampaignPost]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CampaignPost>> upsert(
    _is.DatabaseSession session,
    List<CampaignPost> rows, {
    required _is.ColumnSelections<CampaignPostTable> conflictColumns,
    _is.ColumnSelections<CampaignPostTable>? updateColumns,
    _is.WhereExpressionBuilder<CampaignPostTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<CampaignPost>(
      rows,
      conflictColumns: conflictColumns(CampaignPost.t),
      updateColumns: updateColumns?.call(CampaignPost.t),
      updateWhere: updateWhere?.call(CampaignPost.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [CampaignPost] and returns the resulting row.
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
  /// The returned [CampaignPost] will have its `id` field set.
  Future<CampaignPost?> upsertRow(
    _is.DatabaseSession session,
    CampaignPost row, {
    required _is.ColumnSelections<CampaignPostTable> conflictColumns,
    _is.ColumnSelections<CampaignPostTable>? updateColumns,
    _is.WhereExpressionBuilder<CampaignPostTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<CampaignPost>(
      row,
      conflictColumns: conflictColumns(CampaignPost.t),
      updateColumns: updateColumns?.call(CampaignPost.t),
      updateWhere: updateWhere?.call(CampaignPost.t),
      transaction: transaction,
    );
  }

  /// Updates all [CampaignPost]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CampaignPost>> update(
    _is.DatabaseSession session,
    List<CampaignPost> rows, {
    _is.ColumnSelections<CampaignPostTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<CampaignPost>(
      rows,
      columns: columns?.call(CampaignPost.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [CampaignPost]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<CampaignPost> updateRow(
    _is.DatabaseSession session,
    CampaignPost row, {
    _is.ColumnSelections<CampaignPostTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<CampaignPost>(
      row,
      columns: columns?.call(CampaignPost.t),
      transaction: transaction,
    );
  }

  /// Updates a single [CampaignPost] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<CampaignPost?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<CampaignPostUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<CampaignPost>(
      id,
      columnValues: columnValues(CampaignPost.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [CampaignPost]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CampaignPost>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<CampaignPostUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<CampaignPostTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CampaignPostTable>? orderBy,
    _is.OrderByListBuilder<CampaignPostTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<CampaignPost>(
      columnValues: columnValues(CampaignPost.t.updateTable),
      where: where(CampaignPost.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CampaignPost.t),
      orderByList: orderByList?.call(CampaignPost.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [CampaignPost]s in the list and returns the deleted rows.
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
  Future<List<CampaignPost>> delete(
    _is.DatabaseSession session,
    List<CampaignPost> rows, {
    _is.OrderByBuilder<CampaignPostTable>? orderBy,
    _is.OrderByListBuilder<CampaignPostTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<CampaignPost>(
      rows,
      orderBy: orderBy?.call(CampaignPost.t),
      orderByList: orderByList?.call(CampaignPost.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [CampaignPost].
  Future<CampaignPost> deleteRow(
    _is.DatabaseSession session,
    CampaignPost row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<CampaignPost>(
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
  Future<List<CampaignPost>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CampaignPostTable> where,
    _is.OrderByBuilder<CampaignPostTable>? orderBy,
    _is.OrderByListBuilder<CampaignPostTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<CampaignPost>(
      where: where(CampaignPost.t),
      orderBy: orderBy?.call(CampaignPost.t),
      orderByList: orderByList?.call(CampaignPost.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CampaignPostTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<CampaignPost>(
      where: where?.call(CampaignPost.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [CampaignPost] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CampaignPostTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<CampaignPost>(
      where: where(CampaignPost.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
