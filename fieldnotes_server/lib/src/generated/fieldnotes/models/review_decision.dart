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
import '../../fieldnotes/models/observation_condition.dart' as _iuuy06sg;
import '../../fieldnotes/models/review_outcome.dart' as _ibt01pur;

abstract class ReviewDecision
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  ReviewDecision._({
    this.id,
    required this.observationId,
    required this.reviewerAuthUserId,
    required this.outcome,
    required this.previousCondition,
    required this.finalCondition,
    required this.notes,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory ReviewDecision({
    int? id,
    required int observationId,
    required _is.UuidValue reviewerAuthUserId,
    required _ibt01pur.ReviewOutcome outcome,
    required _iuuy06sg.ObservationCondition previousCondition,
    required _iuuy06sg.ObservationCondition finalCondition,
    required String notes,
    DateTime? createdAt,
  }) = _ReviewDecisionImpl;

  factory ReviewDecision.fromJson(Map<String, dynamic> jsonSerialization) {
    return ReviewDecision(
      id: jsonSerialization['id'] as int?,
      observationId: jsonSerialization['observationId'] as int,
      reviewerAuthUserId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['reviewerAuthUserId'],
      ),
      outcome: _ibt01pur.ReviewOutcome.fromJson(
        (jsonSerialization['outcome'] as String),
      ),
      previousCondition: _iuuy06sg.ObservationCondition.fromJson(
        (jsonSerialization['previousCondition'] as String),
      ),
      finalCondition: _iuuy06sg.ObservationCondition.fromJson(
        (jsonSerialization['finalCondition'] as String),
      ),
      notes: jsonSerialization['notes'] as String,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  static final t = ReviewDecisionTable();

  static const db = ReviewDecisionRepository._();

  @override
  int? id;

  int observationId;

  _is.UuidValue reviewerAuthUserId;

  _ibt01pur.ReviewOutcome outcome;

  _iuuy06sg.ObservationCondition previousCondition;

  _iuuy06sg.ObservationCondition finalCondition;

  String notes;

  DateTime createdAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [ReviewDecision]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  ReviewDecision copyWith({
    int? id,
    int? observationId,
    _is.UuidValue? reviewerAuthUserId,
    _ibt01pur.ReviewOutcome? outcome,
    _iuuy06sg.ObservationCondition? previousCondition,
    _iuuy06sg.ObservationCondition? finalCondition,
    String? notes,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ReviewDecision',
      if (id != null) 'id': id,
      'observationId': observationId,
      'reviewerAuthUserId': reviewerAuthUserId.toJson(),
      'outcome': outcome.toJson(),
      'previousCondition': previousCondition.toJson(),
      'finalCondition': finalCondition.toJson(),
      'notes': notes,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ReviewDecision',
      if (id != null) 'id': id,
      'observationId': observationId,
      'reviewerAuthUserId': reviewerAuthUserId.toJson(),
      'outcome': outcome.toJson(),
      'previousCondition': previousCondition.toJson(),
      'finalCondition': finalCondition.toJson(),
      'notes': notes,
      'createdAt': createdAt.toJson(),
    };
  }

  static ReviewDecisionInclude include() {
    return ReviewDecisionInclude._();
  }

  static ReviewDecisionIncludeList includeList({
    _is.WhereExpressionBuilder<ReviewDecisionTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ReviewDecisionTable>? orderBy,
    _is.OrderByListBuilder<ReviewDecisionTable>? orderByList,
    ReviewDecisionInclude? include,
  }) {
    return ReviewDecisionIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ReviewDecision.t),
      orderByList: orderByList?.call(ReviewDecision.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ReviewDecisionImpl extends ReviewDecision {
  _ReviewDecisionImpl({
    int? id,
    required int observationId,
    required _is.UuidValue reviewerAuthUserId,
    required _ibt01pur.ReviewOutcome outcome,
    required _iuuy06sg.ObservationCondition previousCondition,
    required _iuuy06sg.ObservationCondition finalCondition,
    required String notes,
    DateTime? createdAt,
  }) : super._(
         id: id,
         observationId: observationId,
         reviewerAuthUserId: reviewerAuthUserId,
         outcome: outcome,
         previousCondition: previousCondition,
         finalCondition: finalCondition,
         notes: notes,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [ReviewDecision]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  ReviewDecision copyWith({
    Object? id = _Undefined,
    int? observationId,
    _is.UuidValue? reviewerAuthUserId,
    _ibt01pur.ReviewOutcome? outcome,
    _iuuy06sg.ObservationCondition? previousCondition,
    _iuuy06sg.ObservationCondition? finalCondition,
    String? notes,
    DateTime? createdAt,
  }) {
    return ReviewDecision(
      id: id is int? ? id : this.id,
      observationId: observationId ?? this.observationId,
      reviewerAuthUserId: reviewerAuthUserId ?? this.reviewerAuthUserId,
      outcome: outcome ?? this.outcome,
      previousCondition: previousCondition ?? this.previousCondition,
      finalCondition: finalCondition ?? this.finalCondition,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class ReviewDecisionUpdateTable extends _is.UpdateTable<ReviewDecisionTable> {
  ReviewDecisionUpdateTable(super.table);

  _is.ColumnValue<int, int> observationId(int value) => _is.ColumnValue(
    table.observationId,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> reviewerAuthUserId(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.reviewerAuthUserId,
    value,
  );

  _is.ColumnValue<_ibt01pur.ReviewOutcome, _ibt01pur.ReviewOutcome> outcome(
    _ibt01pur.ReviewOutcome value,
  ) => _is.ColumnValue(
    table.outcome,
    value,
  );

  _is.ColumnValue<
    _iuuy06sg.ObservationCondition,
    _iuuy06sg.ObservationCondition
  >
  previousCondition(_iuuy06sg.ObservationCondition value) => _is.ColumnValue(
    table.previousCondition,
    value,
  );

  _is.ColumnValue<
    _iuuy06sg.ObservationCondition,
    _iuuy06sg.ObservationCondition
  >
  finalCondition(_iuuy06sg.ObservationCondition value) => _is.ColumnValue(
    table.finalCondition,
    value,
  );

  _is.ColumnValue<String, String> notes(String value) => _is.ColumnValue(
    table.notes,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );
}

class ReviewDecisionTable extends _is.Table<int?> {
  ReviewDecisionTable({super.tableRelation})
    : super(tableName: 'fieldnote_review_decision') {
    updateTable = ReviewDecisionUpdateTable(this);
    observationId = _is.ColumnInt(
      'observationId',
      this,
    );
    reviewerAuthUserId = _is.ColumnUuid(
      'reviewerAuthUserId',
      this,
    );
    outcome = _is.ColumnEnum(
      'outcome',
      this,
      _is.EnumSerialization.byName,
    );
    previousCondition = _is.ColumnEnum(
      'previousCondition',
      this,
      _is.EnumSerialization.byName,
    );
    finalCondition = _is.ColumnEnum(
      'finalCondition',
      this,
      _is.EnumSerialization.byName,
    );
    notes = _is.ColumnString(
      'notes',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
      hasDefault: true,
    );
  }

  late final ReviewDecisionUpdateTable updateTable;

  late final _is.ColumnInt observationId;

  late final _is.ColumnUuid reviewerAuthUserId;

  late final _is.ColumnEnum<_ibt01pur.ReviewOutcome> outcome;

  late final _is.ColumnEnum<_iuuy06sg.ObservationCondition> previousCondition;

  late final _is.ColumnEnum<_iuuy06sg.ObservationCondition> finalCondition;

  late final _is.ColumnString notes;

  late final _is.ColumnDateTime createdAt;

  @override
  List<_is.Column> get columns => [
    id,
    observationId,
    reviewerAuthUserId,
    outcome,
    previousCondition,
    finalCondition,
    notes,
    createdAt,
  ];
}

class ReviewDecisionInclude extends _is.IncludeObject {
  ReviewDecisionInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => ReviewDecision.t;
}

class ReviewDecisionIncludeList extends _is.IncludeList {
  ReviewDecisionIncludeList._({
    _is.WhereExpressionBuilder<ReviewDecisionTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(ReviewDecision.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => ReviewDecision.t;
}

class ReviewDecisionRepository {
  const ReviewDecisionRepository._();

  /// Returns a list of [ReviewDecision]s matching the given query parameters.
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
  Future<List<ReviewDecision>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ReviewDecisionTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ReviewDecisionTable>? orderBy,
    _is.OrderByListBuilder<ReviewDecisionTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<ReviewDecision>(
      where: where?.call(ReviewDecision.t),
      orderBy: orderBy?.call(ReviewDecision.t),
      orderByList: orderByList?.call(ReviewDecision.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [ReviewDecision] matching the given query parameters.
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
  Future<ReviewDecision?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ReviewDecisionTable>? where,
    int? offset,
    _is.OrderByBuilder<ReviewDecisionTable>? orderBy,
    _is.OrderByListBuilder<ReviewDecisionTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<ReviewDecision>(
      where: where?.call(ReviewDecision.t),
      orderBy: orderBy?.call(ReviewDecision.t),
      orderByList: orderByList?.call(ReviewDecision.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [ReviewDecision] by its [id] or null if no such row exists.
  Future<ReviewDecision?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<ReviewDecision>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [ReviewDecision]s in the list and returns the inserted rows.
  ///
  /// The returned [ReviewDecision]s will have their `id` fields set.
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
  Future<List<ReviewDecision>> insert(
    _is.DatabaseSession session,
    List<ReviewDecision> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<ReviewDecision>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [ReviewDecision] and returns the inserted row.
  ///
  /// The returned [ReviewDecision] will have its `id` field set.
  Future<ReviewDecision> insertRow(
    _is.DatabaseSession session,
    ReviewDecision row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<ReviewDecision>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [ReviewDecision]s in the list and returns the resulting rows.
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
  /// The returned [ReviewDecision]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ReviewDecision>> upsert(
    _is.DatabaseSession session,
    List<ReviewDecision> rows, {
    required _is.ColumnSelections<ReviewDecisionTable> conflictColumns,
    _is.ColumnSelections<ReviewDecisionTable>? updateColumns,
    _is.WhereExpressionBuilder<ReviewDecisionTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<ReviewDecision>(
      rows,
      conflictColumns: conflictColumns(ReviewDecision.t),
      updateColumns: updateColumns?.call(ReviewDecision.t),
      updateWhere: updateWhere?.call(ReviewDecision.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [ReviewDecision] and returns the resulting row.
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
  /// The returned [ReviewDecision] will have its `id` field set.
  Future<ReviewDecision?> upsertRow(
    _is.DatabaseSession session,
    ReviewDecision row, {
    required _is.ColumnSelections<ReviewDecisionTable> conflictColumns,
    _is.ColumnSelections<ReviewDecisionTable>? updateColumns,
    _is.WhereExpressionBuilder<ReviewDecisionTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<ReviewDecision>(
      row,
      conflictColumns: conflictColumns(ReviewDecision.t),
      updateColumns: updateColumns?.call(ReviewDecision.t),
      updateWhere: updateWhere?.call(ReviewDecision.t),
      transaction: transaction,
    );
  }

  /// Updates all [ReviewDecision]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ReviewDecision>> update(
    _is.DatabaseSession session,
    List<ReviewDecision> rows, {
    _is.ColumnSelections<ReviewDecisionTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<ReviewDecision>(
      rows,
      columns: columns?.call(ReviewDecision.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [ReviewDecision]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<ReviewDecision> updateRow(
    _is.DatabaseSession session,
    ReviewDecision row, {
    _is.ColumnSelections<ReviewDecisionTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<ReviewDecision>(
      row,
      columns: columns?.call(ReviewDecision.t),
      transaction: transaction,
    );
  }

  /// Updates a single [ReviewDecision] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<ReviewDecision?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<ReviewDecisionUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<ReviewDecision>(
      id,
      columnValues: columnValues(ReviewDecision.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [ReviewDecision]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ReviewDecision>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<ReviewDecisionUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<ReviewDecisionTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ReviewDecisionTable>? orderBy,
    _is.OrderByListBuilder<ReviewDecisionTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<ReviewDecision>(
      columnValues: columnValues(ReviewDecision.t.updateTable),
      where: where(ReviewDecision.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ReviewDecision.t),
      orderByList: orderByList?.call(ReviewDecision.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [ReviewDecision]s in the list and returns the deleted rows.
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
  Future<List<ReviewDecision>> delete(
    _is.DatabaseSession session,
    List<ReviewDecision> rows, {
    _is.OrderByBuilder<ReviewDecisionTable>? orderBy,
    _is.OrderByListBuilder<ReviewDecisionTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<ReviewDecision>(
      rows,
      orderBy: orderBy?.call(ReviewDecision.t),
      orderByList: orderByList?.call(ReviewDecision.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [ReviewDecision].
  Future<ReviewDecision> deleteRow(
    _is.DatabaseSession session,
    ReviewDecision row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<ReviewDecision>(
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
  Future<List<ReviewDecision>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<ReviewDecisionTable> where,
    _is.OrderByBuilder<ReviewDecisionTable>? orderBy,
    _is.OrderByListBuilder<ReviewDecisionTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<ReviewDecision>(
      where: where(ReviewDecision.t),
      orderBy: orderBy?.call(ReviewDecision.t),
      orderByList: orderByList?.call(ReviewDecision.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ReviewDecisionTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<ReviewDecision>(
      where: where?.call(ReviewDecision.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [ReviewDecision] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<ReviewDecisionTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<ReviewDecision>(
      where: where(ReviewDecision.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
