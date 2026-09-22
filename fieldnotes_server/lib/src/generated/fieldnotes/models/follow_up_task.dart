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
import '../../fieldnotes/models/task_status.dart' as _iqhuwlzt;

abstract class FollowUpTask
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  FollowUpTask._({
    this.id,
    required this.campaignId,
    this.observationId,
    this.assetId,
    required this.title,
    required this.description,
    this.assigneeAuthUserId,
    this.dueAt,
    required this.status,
    required this.createdBy,
    this.completionNote,
    this.completedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory FollowUpTask({
    int? id,
    required int campaignId,
    int? observationId,
    int? assetId,
    required String title,
    required String description,
    _is.UuidValue? assigneeAuthUserId,
    DateTime? dueAt,
    required _iqhuwlzt.TaskStatus status,
    required _is.UuidValue createdBy,
    String? completionNote,
    DateTime? completedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _FollowUpTaskImpl;

  factory FollowUpTask.fromJson(Map<String, dynamic> jsonSerialization) {
    return FollowUpTask(
      id: jsonSerialization['id'] as int?,
      campaignId: jsonSerialization['campaignId'] as int,
      observationId: jsonSerialization['observationId'] as int?,
      assetId: jsonSerialization['assetId'] as int?,
      title: jsonSerialization['title'] as String,
      description: jsonSerialization['description'] as String,
      assigneeAuthUserId: jsonSerialization['assigneeAuthUserId'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(
              jsonSerialization['assigneeAuthUserId'],
            ),
      dueAt: jsonSerialization['dueAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['dueAt']),
      status: _iqhuwlzt.TaskStatus.fromJson(
        (jsonSerialization['status'] as String),
      ),
      createdBy: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['createdBy'],
      ),
      completionNote: jsonSerialization['completionNote'] as String?,
      completedAt: jsonSerialization['completedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(
              jsonSerialization['completedAt'],
            ),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  static final t = FollowUpTaskTable();

  static const db = FollowUpTaskRepository._();

  @override
  int? id;

  int campaignId;

  int? observationId;

  int? assetId;

  String title;

  String description;

  _is.UuidValue? assigneeAuthUserId;

  DateTime? dueAt;

  _iqhuwlzt.TaskStatus status;

  _is.UuidValue createdBy;

  String? completionNote;

  DateTime? completedAt;

  DateTime createdAt;

  DateTime updatedAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [FollowUpTask]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  FollowUpTask copyWith({
    int? id,
    int? campaignId,
    int? observationId,
    int? assetId,
    String? title,
    String? description,
    _is.UuidValue? assigneeAuthUserId,
    DateTime? dueAt,
    _iqhuwlzt.TaskStatus? status,
    _is.UuidValue? createdBy,
    String? completionNote,
    DateTime? completedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'FollowUpTask',
      if (id != null) 'id': id,
      'campaignId': campaignId,
      if (observationId != null) 'observationId': observationId,
      if (assetId != null) 'assetId': assetId,
      'title': title,
      'description': description,
      if (assigneeAuthUserId != null)
        'assigneeAuthUserId': assigneeAuthUserId?.toJson(),
      if (dueAt != null) 'dueAt': dueAt?.toJson(),
      'status': status.toJson(),
      'createdBy': createdBy.toJson(),
      if (completionNote != null) 'completionNote': completionNote,
      if (completedAt != null) 'completedAt': completedAt?.toJson(),
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'FollowUpTask',
      if (id != null) 'id': id,
      'campaignId': campaignId,
      if (observationId != null) 'observationId': observationId,
      if (assetId != null) 'assetId': assetId,
      'title': title,
      'description': description,
      if (assigneeAuthUserId != null)
        'assigneeAuthUserId': assigneeAuthUserId?.toJson(),
      if (dueAt != null) 'dueAt': dueAt?.toJson(),
      'status': status.toJson(),
      'createdBy': createdBy.toJson(),
      if (completionNote != null) 'completionNote': completionNote,
      if (completedAt != null) 'completedAt': completedAt?.toJson(),
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  static FollowUpTaskInclude include() {
    return FollowUpTaskInclude._();
  }

  static FollowUpTaskIncludeList includeList({
    _is.WhereExpressionBuilder<FollowUpTaskTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<FollowUpTaskTable>? orderBy,
    _is.OrderByListBuilder<FollowUpTaskTable>? orderByList,
    FollowUpTaskInclude? include,
  }) {
    return FollowUpTaskIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(FollowUpTask.t),
      orderByList: orderByList?.call(FollowUpTask.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _FollowUpTaskImpl extends FollowUpTask {
  _FollowUpTaskImpl({
    int? id,
    required int campaignId,
    int? observationId,
    int? assetId,
    required String title,
    required String description,
    _is.UuidValue? assigneeAuthUserId,
    DateTime? dueAt,
    required _iqhuwlzt.TaskStatus status,
    required _is.UuidValue createdBy,
    String? completionNote,
    DateTime? completedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         campaignId: campaignId,
         observationId: observationId,
         assetId: assetId,
         title: title,
         description: description,
         assigneeAuthUserId: assigneeAuthUserId,
         dueAt: dueAt,
         status: status,
         createdBy: createdBy,
         completionNote: completionNote,
         completedAt: completedAt,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [FollowUpTask]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  FollowUpTask copyWith({
    Object? id = _Undefined,
    int? campaignId,
    Object? observationId = _Undefined,
    Object? assetId = _Undefined,
    String? title,
    String? description,
    Object? assigneeAuthUserId = _Undefined,
    Object? dueAt = _Undefined,
    _iqhuwlzt.TaskStatus? status,
    _is.UuidValue? createdBy,
    Object? completionNote = _Undefined,
    Object? completedAt = _Undefined,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FollowUpTask(
      id: id is int? ? id : this.id,
      campaignId: campaignId ?? this.campaignId,
      observationId: observationId is int? ? observationId : this.observationId,
      assetId: assetId is int? ? assetId : this.assetId,
      title: title ?? this.title,
      description: description ?? this.description,
      assigneeAuthUserId: assigneeAuthUserId is _is.UuidValue?
          ? assigneeAuthUserId
          : this.assigneeAuthUserId,
      dueAt: dueAt is DateTime? ? dueAt : this.dueAt,
      status: status ?? this.status,
      createdBy: createdBy ?? this.createdBy,
      completionNote: completionNote is String?
          ? completionNote
          : this.completionNote,
      completedAt: completedAt is DateTime? ? completedAt : this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class FollowUpTaskUpdateTable extends _is.UpdateTable<FollowUpTaskTable> {
  FollowUpTaskUpdateTable(super.table);

  _is.ColumnValue<int, int> campaignId(int value) => _is.ColumnValue(
    table.campaignId,
    value,
  );

  _is.ColumnValue<int, int> observationId(int? value) => _is.ColumnValue(
    table.observationId,
    value,
  );

  _is.ColumnValue<int, int> assetId(int? value) => _is.ColumnValue(
    table.assetId,
    value,
  );

  _is.ColumnValue<String, String> title(String value) => _is.ColumnValue(
    table.title,
    value,
  );

  _is.ColumnValue<String, String> description(String value) => _is.ColumnValue(
    table.description,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> assigneeAuthUserId(
    _is.UuidValue? value,
  ) => _is.ColumnValue(
    table.assigneeAuthUserId,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> dueAt(DateTime? value) => _is.ColumnValue(
    table.dueAt,
    value,
  );

  _is.ColumnValue<_iqhuwlzt.TaskStatus, _iqhuwlzt.TaskStatus> status(
    _iqhuwlzt.TaskStatus value,
  ) => _is.ColumnValue(
    table.status,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> createdBy(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.createdBy,
    value,
  );

  _is.ColumnValue<String, String> completionNote(String? value) =>
      _is.ColumnValue(
        table.completionNote,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> completedAt(DateTime? value) =>
      _is.ColumnValue(
        table.completedAt,
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

class FollowUpTaskTable extends _is.Table<int?> {
  FollowUpTaskTable({super.tableRelation})
    : super(tableName: 'fieldnote_follow_up_task') {
    updateTable = FollowUpTaskUpdateTable(this);
    campaignId = _is.ColumnInt(
      'campaignId',
      this,
    );
    observationId = _is.ColumnInt(
      'observationId',
      this,
    );
    assetId = _is.ColumnInt(
      'assetId',
      this,
    );
    title = _is.ColumnString(
      'title',
      this,
    );
    description = _is.ColumnString(
      'description',
      this,
    );
    assigneeAuthUserId = _is.ColumnUuid(
      'assigneeAuthUserId',
      this,
    );
    dueAt = _is.ColumnDateTime(
      'dueAt',
      this,
    );
    status = _is.ColumnEnum(
      'status',
      this,
      _is.EnumSerialization.byName,
    );
    createdBy = _is.ColumnUuid(
      'createdBy',
      this,
    );
    completionNote = _is.ColumnString(
      'completionNote',
      this,
    );
    completedAt = _is.ColumnDateTime(
      'completedAt',
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

  late final FollowUpTaskUpdateTable updateTable;

  late final _is.ColumnInt campaignId;

  late final _is.ColumnInt observationId;

  late final _is.ColumnInt assetId;

  late final _is.ColumnString title;

  late final _is.ColumnString description;

  late final _is.ColumnUuid assigneeAuthUserId;

  late final _is.ColumnDateTime dueAt;

  late final _is.ColumnEnum<_iqhuwlzt.TaskStatus> status;

  late final _is.ColumnUuid createdBy;

  late final _is.ColumnString completionNote;

  late final _is.ColumnDateTime completedAt;

  late final _is.ColumnDateTime createdAt;

  late final _is.ColumnDateTime updatedAt;

  @override
  List<_is.Column> get columns => [
    id,
    campaignId,
    observationId,
    assetId,
    title,
    description,
    assigneeAuthUserId,
    dueAt,
    status,
    createdBy,
    completionNote,
    completedAt,
    createdAt,
    updatedAt,
  ];
}

class FollowUpTaskInclude extends _is.IncludeObject {
  FollowUpTaskInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => FollowUpTask.t;
}

class FollowUpTaskIncludeList extends _is.IncludeList {
  FollowUpTaskIncludeList._({
    _is.WhereExpressionBuilder<FollowUpTaskTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(FollowUpTask.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => FollowUpTask.t;
}

class FollowUpTaskRepository {
  const FollowUpTaskRepository._();

  /// Returns a list of [FollowUpTask]s matching the given query parameters.
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
  Future<List<FollowUpTask>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<FollowUpTaskTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<FollowUpTaskTable>? orderBy,
    _is.OrderByListBuilder<FollowUpTaskTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<FollowUpTask>(
      where: where?.call(FollowUpTask.t),
      orderBy: orderBy?.call(FollowUpTask.t),
      orderByList: orderByList?.call(FollowUpTask.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [FollowUpTask] matching the given query parameters.
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
  Future<FollowUpTask?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<FollowUpTaskTable>? where,
    int? offset,
    _is.OrderByBuilder<FollowUpTaskTable>? orderBy,
    _is.OrderByListBuilder<FollowUpTaskTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<FollowUpTask>(
      where: where?.call(FollowUpTask.t),
      orderBy: orderBy?.call(FollowUpTask.t),
      orderByList: orderByList?.call(FollowUpTask.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [FollowUpTask] by its [id] or null if no such row exists.
  Future<FollowUpTask?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<FollowUpTask>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [FollowUpTask]s in the list and returns the inserted rows.
  ///
  /// The returned [FollowUpTask]s will have their `id` fields set.
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
  Future<List<FollowUpTask>> insert(
    _is.DatabaseSession session,
    List<FollowUpTask> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<FollowUpTask>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [FollowUpTask] and returns the inserted row.
  ///
  /// The returned [FollowUpTask] will have its `id` field set.
  Future<FollowUpTask> insertRow(
    _is.DatabaseSession session,
    FollowUpTask row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<FollowUpTask>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [FollowUpTask]s in the list and returns the resulting rows.
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
  /// The returned [FollowUpTask]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<FollowUpTask>> upsert(
    _is.DatabaseSession session,
    List<FollowUpTask> rows, {
    required _is.ColumnSelections<FollowUpTaskTable> conflictColumns,
    _is.ColumnSelections<FollowUpTaskTable>? updateColumns,
    _is.WhereExpressionBuilder<FollowUpTaskTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<FollowUpTask>(
      rows,
      conflictColumns: conflictColumns(FollowUpTask.t),
      updateColumns: updateColumns?.call(FollowUpTask.t),
      updateWhere: updateWhere?.call(FollowUpTask.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [FollowUpTask] and returns the resulting row.
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
  /// The returned [FollowUpTask] will have its `id` field set.
  Future<FollowUpTask?> upsertRow(
    _is.DatabaseSession session,
    FollowUpTask row, {
    required _is.ColumnSelections<FollowUpTaskTable> conflictColumns,
    _is.ColumnSelections<FollowUpTaskTable>? updateColumns,
    _is.WhereExpressionBuilder<FollowUpTaskTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<FollowUpTask>(
      row,
      conflictColumns: conflictColumns(FollowUpTask.t),
      updateColumns: updateColumns?.call(FollowUpTask.t),
      updateWhere: updateWhere?.call(FollowUpTask.t),
      transaction: transaction,
    );
  }

  /// Updates all [FollowUpTask]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<FollowUpTask>> update(
    _is.DatabaseSession session,
    List<FollowUpTask> rows, {
    _is.ColumnSelections<FollowUpTaskTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<FollowUpTask>(
      rows,
      columns: columns?.call(FollowUpTask.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [FollowUpTask]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<FollowUpTask> updateRow(
    _is.DatabaseSession session,
    FollowUpTask row, {
    _is.ColumnSelections<FollowUpTaskTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<FollowUpTask>(
      row,
      columns: columns?.call(FollowUpTask.t),
      transaction: transaction,
    );
  }

  /// Updates a single [FollowUpTask] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<FollowUpTask?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<FollowUpTaskUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<FollowUpTask>(
      id,
      columnValues: columnValues(FollowUpTask.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [FollowUpTask]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<FollowUpTask>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<FollowUpTaskUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<FollowUpTaskTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<FollowUpTaskTable>? orderBy,
    _is.OrderByListBuilder<FollowUpTaskTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<FollowUpTask>(
      columnValues: columnValues(FollowUpTask.t.updateTable),
      where: where(FollowUpTask.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(FollowUpTask.t),
      orderByList: orderByList?.call(FollowUpTask.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [FollowUpTask]s in the list and returns the deleted rows.
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
  Future<List<FollowUpTask>> delete(
    _is.DatabaseSession session,
    List<FollowUpTask> rows, {
    _is.OrderByBuilder<FollowUpTaskTable>? orderBy,
    _is.OrderByListBuilder<FollowUpTaskTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<FollowUpTask>(
      rows,
      orderBy: orderBy?.call(FollowUpTask.t),
      orderByList: orderByList?.call(FollowUpTask.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [FollowUpTask].
  Future<FollowUpTask> deleteRow(
    _is.DatabaseSession session,
    FollowUpTask row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<FollowUpTask>(
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
  Future<List<FollowUpTask>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<FollowUpTaskTable> where,
    _is.OrderByBuilder<FollowUpTaskTable>? orderBy,
    _is.OrderByListBuilder<FollowUpTaskTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<FollowUpTask>(
      where: where(FollowUpTask.t),
      orderBy: orderBy?.call(FollowUpTask.t),
      orderByList: orderByList?.call(FollowUpTask.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<FollowUpTaskTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<FollowUpTask>(
      where: where?.call(FollowUpTask.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [FollowUpTask] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<FollowUpTaskTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<FollowUpTask>(
      where: where(FollowUpTask.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
