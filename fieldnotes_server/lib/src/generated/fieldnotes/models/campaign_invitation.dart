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

/// An invitation from a campaign creator to an available volunteer. The
/// volunteer sees it privately in Matches and chooses whether to join.
abstract class CampaignInvitation
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  CampaignInvitation._({
    this.id,
    required this.campaignId,
    required this.volunteerAuthUserId,
    required this.sponsorAuthUserId,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory CampaignInvitation({
    int? id,
    required int campaignId,
    required _is.UuidValue volunteerAuthUserId,
    required _is.UuidValue sponsorAuthUserId,
    DateTime? createdAt,
  }) = _CampaignInvitationImpl;

  factory CampaignInvitation.fromJson(Map<String, dynamic> jsonSerialization) {
    return CampaignInvitation(
      id: jsonSerialization['id'] as int?,
      campaignId: jsonSerialization['campaignId'] as int,
      volunteerAuthUserId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['volunteerAuthUserId'],
      ),
      sponsorAuthUserId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['sponsorAuthUserId'],
      ),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  static final t = CampaignInvitationTable();

  static const db = CampaignInvitationRepository._();

  @override
  int? id;

  int campaignId;

  _is.UuidValue volunteerAuthUserId;

  _is.UuidValue sponsorAuthUserId;

  DateTime createdAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [CampaignInvitation]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CampaignInvitation copyWith({
    int? id,
    int? campaignId,
    _is.UuidValue? volunteerAuthUserId,
    _is.UuidValue? sponsorAuthUserId,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'CampaignInvitation',
      if (id != null) 'id': id,
      'campaignId': campaignId,
      'volunteerAuthUserId': volunteerAuthUserId.toJson(),
      'sponsorAuthUserId': sponsorAuthUserId.toJson(),
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'CampaignInvitation',
      if (id != null) 'id': id,
      'campaignId': campaignId,
      'volunteerAuthUserId': volunteerAuthUserId.toJson(),
      'sponsorAuthUserId': sponsorAuthUserId.toJson(),
      'createdAt': createdAt.toJson(),
    };
  }

  static CampaignInvitationInclude include() {
    return CampaignInvitationInclude._();
  }

  static CampaignInvitationIncludeList includeList({
    _is.WhereExpressionBuilder<CampaignInvitationTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CampaignInvitationTable>? orderBy,
    _is.OrderByListBuilder<CampaignInvitationTable>? orderByList,
    CampaignInvitationInclude? include,
  }) {
    return CampaignInvitationIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CampaignInvitation.t),
      orderByList: orderByList?.call(CampaignInvitation.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CampaignInvitationImpl extends CampaignInvitation {
  _CampaignInvitationImpl({
    int? id,
    required int campaignId,
    required _is.UuidValue volunteerAuthUserId,
    required _is.UuidValue sponsorAuthUserId,
    DateTime? createdAt,
  }) : super._(
         id: id,
         campaignId: campaignId,
         volunteerAuthUserId: volunteerAuthUserId,
         sponsorAuthUserId: sponsorAuthUserId,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [CampaignInvitation]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CampaignInvitation copyWith({
    Object? id = _Undefined,
    int? campaignId,
    _is.UuidValue? volunteerAuthUserId,
    _is.UuidValue? sponsorAuthUserId,
    DateTime? createdAt,
  }) {
    return CampaignInvitation(
      id: id is int? ? id : this.id,
      campaignId: campaignId ?? this.campaignId,
      volunteerAuthUserId: volunteerAuthUserId ?? this.volunteerAuthUserId,
      sponsorAuthUserId: sponsorAuthUserId ?? this.sponsorAuthUserId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class CampaignInvitationUpdateTable
    extends _is.UpdateTable<CampaignInvitationTable> {
  CampaignInvitationUpdateTable(super.table);

  _is.ColumnValue<int, int> campaignId(int value) => _is.ColumnValue(
    table.campaignId,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> volunteerAuthUserId(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.volunteerAuthUserId,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> sponsorAuthUserId(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.sponsorAuthUserId,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );
}

class CampaignInvitationTable extends _is.Table<int?> {
  CampaignInvitationTable({super.tableRelation})
    : super(tableName: 'fieldnote_campaign_invitation') {
    updateTable = CampaignInvitationUpdateTable(this);
    campaignId = _is.ColumnInt(
      'campaignId',
      this,
    );
    volunteerAuthUserId = _is.ColumnUuid(
      'volunteerAuthUserId',
      this,
    );
    sponsorAuthUserId = _is.ColumnUuid(
      'sponsorAuthUserId',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
      hasDefault: true,
    );
  }

  late final CampaignInvitationUpdateTable updateTable;

  late final _is.ColumnInt campaignId;

  late final _is.ColumnUuid volunteerAuthUserId;

  late final _is.ColumnUuid sponsorAuthUserId;

  late final _is.ColumnDateTime createdAt;

  @override
  List<_is.Column> get columns => [
    id,
    campaignId,
    volunteerAuthUserId,
    sponsorAuthUserId,
    createdAt,
  ];
}

class CampaignInvitationInclude extends _is.IncludeObject {
  CampaignInvitationInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => CampaignInvitation.t;
}

class CampaignInvitationIncludeList extends _is.IncludeList {
  CampaignInvitationIncludeList._({
    _is.WhereExpressionBuilder<CampaignInvitationTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(CampaignInvitation.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => CampaignInvitation.t;
}

class CampaignInvitationRepository {
  const CampaignInvitationRepository._();

  /// Returns a list of [CampaignInvitation]s matching the given query parameters.
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
  Future<List<CampaignInvitation>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CampaignInvitationTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CampaignInvitationTable>? orderBy,
    _is.OrderByListBuilder<CampaignInvitationTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<CampaignInvitation>(
      where: where?.call(CampaignInvitation.t),
      orderBy: orderBy?.call(CampaignInvitation.t),
      orderByList: orderByList?.call(CampaignInvitation.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [CampaignInvitation] matching the given query parameters.
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
  Future<CampaignInvitation?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CampaignInvitationTable>? where,
    int? offset,
    _is.OrderByBuilder<CampaignInvitationTable>? orderBy,
    _is.OrderByListBuilder<CampaignInvitationTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<CampaignInvitation>(
      where: where?.call(CampaignInvitation.t),
      orderBy: orderBy?.call(CampaignInvitation.t),
      orderByList: orderByList?.call(CampaignInvitation.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [CampaignInvitation] by its [id] or null if no such row exists.
  Future<CampaignInvitation?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<CampaignInvitation>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [CampaignInvitation]s in the list and returns the inserted rows.
  ///
  /// The returned [CampaignInvitation]s will have their `id` fields set.
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
  Future<List<CampaignInvitation>> insert(
    _is.DatabaseSession session,
    List<CampaignInvitation> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<CampaignInvitation>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [CampaignInvitation] and returns the inserted row.
  ///
  /// The returned [CampaignInvitation] will have its `id` field set.
  Future<CampaignInvitation> insertRow(
    _is.DatabaseSession session,
    CampaignInvitation row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<CampaignInvitation>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [CampaignInvitation]s in the list and returns the resulting rows.
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
  /// The returned [CampaignInvitation]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CampaignInvitation>> upsert(
    _is.DatabaseSession session,
    List<CampaignInvitation> rows, {
    required _is.ColumnSelections<CampaignInvitationTable> conflictColumns,
    _is.ColumnSelections<CampaignInvitationTable>? updateColumns,
    _is.WhereExpressionBuilder<CampaignInvitationTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<CampaignInvitation>(
      rows,
      conflictColumns: conflictColumns(CampaignInvitation.t),
      updateColumns: updateColumns?.call(CampaignInvitation.t),
      updateWhere: updateWhere?.call(CampaignInvitation.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [CampaignInvitation] and returns the resulting row.
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
  /// The returned [CampaignInvitation] will have its `id` field set.
  Future<CampaignInvitation?> upsertRow(
    _is.DatabaseSession session,
    CampaignInvitation row, {
    required _is.ColumnSelections<CampaignInvitationTable> conflictColumns,
    _is.ColumnSelections<CampaignInvitationTable>? updateColumns,
    _is.WhereExpressionBuilder<CampaignInvitationTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<CampaignInvitation>(
      row,
      conflictColumns: conflictColumns(CampaignInvitation.t),
      updateColumns: updateColumns?.call(CampaignInvitation.t),
      updateWhere: updateWhere?.call(CampaignInvitation.t),
      transaction: transaction,
    );
  }

  /// Updates all [CampaignInvitation]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CampaignInvitation>> update(
    _is.DatabaseSession session,
    List<CampaignInvitation> rows, {
    _is.ColumnSelections<CampaignInvitationTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<CampaignInvitation>(
      rows,
      columns: columns?.call(CampaignInvitation.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [CampaignInvitation]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<CampaignInvitation> updateRow(
    _is.DatabaseSession session,
    CampaignInvitation row, {
    _is.ColumnSelections<CampaignInvitationTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<CampaignInvitation>(
      row,
      columns: columns?.call(CampaignInvitation.t),
      transaction: transaction,
    );
  }

  /// Updates a single [CampaignInvitation] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<CampaignInvitation?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<CampaignInvitationUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<CampaignInvitation>(
      id,
      columnValues: columnValues(CampaignInvitation.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [CampaignInvitation]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CampaignInvitation>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<CampaignInvitationUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<CampaignInvitationTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CampaignInvitationTable>? orderBy,
    _is.OrderByListBuilder<CampaignInvitationTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<CampaignInvitation>(
      columnValues: columnValues(CampaignInvitation.t.updateTable),
      where: where(CampaignInvitation.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CampaignInvitation.t),
      orderByList: orderByList?.call(CampaignInvitation.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [CampaignInvitation]s in the list and returns the deleted rows.
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
  Future<List<CampaignInvitation>> delete(
    _is.DatabaseSession session,
    List<CampaignInvitation> rows, {
    _is.OrderByBuilder<CampaignInvitationTable>? orderBy,
    _is.OrderByListBuilder<CampaignInvitationTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<CampaignInvitation>(
      rows,
      orderBy: orderBy?.call(CampaignInvitation.t),
      orderByList: orderByList?.call(CampaignInvitation.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [CampaignInvitation].
  Future<CampaignInvitation> deleteRow(
    _is.DatabaseSession session,
    CampaignInvitation row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<CampaignInvitation>(
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
  Future<List<CampaignInvitation>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CampaignInvitationTable> where,
    _is.OrderByBuilder<CampaignInvitationTable>? orderBy,
    _is.OrderByListBuilder<CampaignInvitationTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<CampaignInvitation>(
      where: where(CampaignInvitation.t),
      orderBy: orderBy?.call(CampaignInvitation.t),
      orderByList: orderByList?.call(CampaignInvitation.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CampaignInvitationTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<CampaignInvitation>(
      where: where?.call(CampaignInvitation.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [CampaignInvitation] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CampaignInvitationTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<CampaignInvitation>(
      where: where(CampaignInvitation.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
