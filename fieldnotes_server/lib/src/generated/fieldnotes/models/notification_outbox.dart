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

/// One transactional email (A-9). Rows are written by the business action and
/// delivered by the outbox future call, so SMTP never blocks or fails the
/// action. (recipientAuthUserId, dedupeKey) is unique: one email per event per
/// user. The address is looked up at send time; [toEmail] is only set for the
/// account-deletion notice, whose auth user no longer exists, and is cleared
/// once the row is final.
///
/// status: pending | sent | skipped | failed
abstract class NotificationOutbox
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  NotificationOutbox._({
    this.id,
    required this.recipientAuthUserId,
    required this.kind,
    required this.dedupeKey,
    required this.subject,
    required this.bodyText,
    required this.bodyHtml,
    this.toEmail,
    String? status,
    int? attempts,
    this.lastError,
    this.nextAttemptAt,
    DateTime? createdAt,
    this.sentAt,
  }) : status = status ?? 'pending',
       attempts = attempts ?? 0,
       createdAt = createdAt ?? DateTime.now();

  factory NotificationOutbox({
    int? id,
    required _is.UuidValue recipientAuthUserId,
    required String kind,
    required String dedupeKey,
    required String subject,
    required String bodyText,
    required String bodyHtml,
    String? toEmail,
    String? status,
    int? attempts,
    String? lastError,
    DateTime? nextAttemptAt,
    DateTime? createdAt,
    DateTime? sentAt,
  }) = _NotificationOutboxImpl;

  factory NotificationOutbox.fromJson(Map<String, dynamic> jsonSerialization) {
    return NotificationOutbox(
      id: jsonSerialization['id'] as int?,
      recipientAuthUserId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['recipientAuthUserId'],
      ),
      kind: jsonSerialization['kind'] as String,
      dedupeKey: jsonSerialization['dedupeKey'] as String,
      subject: jsonSerialization['subject'] as String,
      bodyText: jsonSerialization['bodyText'] as String,
      bodyHtml: jsonSerialization['bodyHtml'] as String,
      toEmail: jsonSerialization['toEmail'] as String?,
      status: jsonSerialization['status'] as String?,
      attempts: jsonSerialization['attempts'] as int?,
      lastError: jsonSerialization['lastError'] as String?,
      nextAttemptAt: jsonSerialization['nextAttemptAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(
              jsonSerialization['nextAttemptAt'],
            ),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      sentAt: jsonSerialization['sentAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['sentAt']),
    );
  }

  static final t = NotificationOutboxTable();

  static const db = NotificationOutboxRepository._();

  @override
  int? id;

  _is.UuidValue recipientAuthUserId;

  String kind;

  String dedupeKey;

  String subject;

  String bodyText;

  String bodyHtml;

  String? toEmail;

  String status;

  int attempts;

  String? lastError;

  DateTime? nextAttemptAt;

  DateTime createdAt;

  DateTime? sentAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [NotificationOutbox]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  NotificationOutbox copyWith({
    int? id,
    _is.UuidValue? recipientAuthUserId,
    String? kind,
    String? dedupeKey,
    String? subject,
    String? bodyText,
    String? bodyHtml,
    String? toEmail,
    String? status,
    int? attempts,
    String? lastError,
    DateTime? nextAttemptAt,
    DateTime? createdAt,
    DateTime? sentAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'NotificationOutbox',
      if (id != null) 'id': id,
      'recipientAuthUserId': recipientAuthUserId.toJson(),
      'kind': kind,
      'dedupeKey': dedupeKey,
      'subject': subject,
      'bodyText': bodyText,
      'bodyHtml': bodyHtml,
      if (toEmail != null) 'toEmail': toEmail,
      'status': status,
      'attempts': attempts,
      if (lastError != null) 'lastError': lastError,
      if (nextAttemptAt != null) 'nextAttemptAt': nextAttemptAt?.toJson(),
      'createdAt': createdAt.toJson(),
      if (sentAt != null) 'sentAt': sentAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static NotificationOutboxInclude include() {
    return NotificationOutboxInclude._();
  }

  static NotificationOutboxIncludeList includeList({
    _is.WhereExpressionBuilder<NotificationOutboxTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<NotificationOutboxTable>? orderBy,
    _is.OrderByListBuilder<NotificationOutboxTable>? orderByList,
    NotificationOutboxInclude? include,
  }) {
    return NotificationOutboxIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(NotificationOutbox.t),
      orderByList: orderByList?.call(NotificationOutbox.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _NotificationOutboxImpl extends NotificationOutbox {
  _NotificationOutboxImpl({
    int? id,
    required _is.UuidValue recipientAuthUserId,
    required String kind,
    required String dedupeKey,
    required String subject,
    required String bodyText,
    required String bodyHtml,
    String? toEmail,
    String? status,
    int? attempts,
    String? lastError,
    DateTime? nextAttemptAt,
    DateTime? createdAt,
    DateTime? sentAt,
  }) : super._(
         id: id,
         recipientAuthUserId: recipientAuthUserId,
         kind: kind,
         dedupeKey: dedupeKey,
         subject: subject,
         bodyText: bodyText,
         bodyHtml: bodyHtml,
         toEmail: toEmail,
         status: status,
         attempts: attempts,
         lastError: lastError,
         nextAttemptAt: nextAttemptAt,
         createdAt: createdAt,
         sentAt: sentAt,
       );

  /// Returns a shallow copy of this [NotificationOutbox]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  NotificationOutbox copyWith({
    Object? id = _Undefined,
    _is.UuidValue? recipientAuthUserId,
    String? kind,
    String? dedupeKey,
    String? subject,
    String? bodyText,
    String? bodyHtml,
    Object? toEmail = _Undefined,
    String? status,
    int? attempts,
    Object? lastError = _Undefined,
    Object? nextAttemptAt = _Undefined,
    DateTime? createdAt,
    Object? sentAt = _Undefined,
  }) {
    return NotificationOutbox(
      id: id is int? ? id : this.id,
      recipientAuthUserId: recipientAuthUserId ?? this.recipientAuthUserId,
      kind: kind ?? this.kind,
      dedupeKey: dedupeKey ?? this.dedupeKey,
      subject: subject ?? this.subject,
      bodyText: bodyText ?? this.bodyText,
      bodyHtml: bodyHtml ?? this.bodyHtml,
      toEmail: toEmail is String? ? toEmail : this.toEmail,
      status: status ?? this.status,
      attempts: attempts ?? this.attempts,
      lastError: lastError is String? ? lastError : this.lastError,
      nextAttemptAt: nextAttemptAt is DateTime?
          ? nextAttemptAt
          : this.nextAttemptAt,
      createdAt: createdAt ?? this.createdAt,
      sentAt: sentAt is DateTime? ? sentAt : this.sentAt,
    );
  }
}

class NotificationOutboxUpdateTable
    extends _is.UpdateTable<NotificationOutboxTable> {
  NotificationOutboxUpdateTable(super.table);

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

  _is.ColumnValue<String, String> subject(String value) => _is.ColumnValue(
    table.subject,
    value,
  );

  _is.ColumnValue<String, String> bodyText(String value) => _is.ColumnValue(
    table.bodyText,
    value,
  );

  _is.ColumnValue<String, String> bodyHtml(String value) => _is.ColumnValue(
    table.bodyHtml,
    value,
  );

  _is.ColumnValue<String, String> toEmail(String? value) => _is.ColumnValue(
    table.toEmail,
    value,
  );

  _is.ColumnValue<String, String> status(String value) => _is.ColumnValue(
    table.status,
    value,
  );

  _is.ColumnValue<int, int> attempts(int value) => _is.ColumnValue(
    table.attempts,
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

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> sentAt(DateTime? value) =>
      _is.ColumnValue(
        table.sentAt,
        value,
      );
}

class NotificationOutboxTable extends _is.Table<int?> {
  NotificationOutboxTable({super.tableRelation})
    : super(tableName: 'fieldnote_notification_outbox') {
    updateTable = NotificationOutboxUpdateTable(this);
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
    subject = _is.ColumnString(
      'subject',
      this,
    );
    bodyText = _is.ColumnString(
      'bodyText',
      this,
    );
    bodyHtml = _is.ColumnString(
      'bodyHtml',
      this,
    );
    toEmail = _is.ColumnString(
      'toEmail',
      this,
    );
    status = _is.ColumnString(
      'status',
      this,
      hasDefault: true,
    );
    attempts = _is.ColumnInt(
      'attempts',
      this,
      hasDefault: true,
    );
    lastError = _is.ColumnString(
      'lastError',
      this,
    );
    nextAttemptAt = _is.ColumnDateTime(
      'nextAttemptAt',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
      hasDefault: true,
    );
    sentAt = _is.ColumnDateTime(
      'sentAt',
      this,
    );
  }

  late final NotificationOutboxUpdateTable updateTable;

  late final _is.ColumnUuid recipientAuthUserId;

  late final _is.ColumnString kind;

  late final _is.ColumnString dedupeKey;

  late final _is.ColumnString subject;

  late final _is.ColumnString bodyText;

  late final _is.ColumnString bodyHtml;

  late final _is.ColumnString toEmail;

  late final _is.ColumnString status;

  late final _is.ColumnInt attempts;

  late final _is.ColumnString lastError;

  late final _is.ColumnDateTime nextAttemptAt;

  late final _is.ColumnDateTime createdAt;

  late final _is.ColumnDateTime sentAt;

  @override
  List<_is.Column> get columns => [
    id,
    recipientAuthUserId,
    kind,
    dedupeKey,
    subject,
    bodyText,
    bodyHtml,
    toEmail,
    status,
    attempts,
    lastError,
    nextAttemptAt,
    createdAt,
    sentAt,
  ];
}

class NotificationOutboxInclude extends _is.IncludeObject {
  NotificationOutboxInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => NotificationOutbox.t;
}

class NotificationOutboxIncludeList extends _is.IncludeList {
  NotificationOutboxIncludeList._({
    _is.WhereExpressionBuilder<NotificationOutboxTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(NotificationOutbox.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => NotificationOutbox.t;
}

class NotificationOutboxRepository {
  const NotificationOutboxRepository._();

  /// Returns a list of [NotificationOutbox]s matching the given query parameters.
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
  Future<List<NotificationOutbox>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<NotificationOutboxTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<NotificationOutboxTable>? orderBy,
    _is.OrderByListBuilder<NotificationOutboxTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<NotificationOutbox>(
      where: where?.call(NotificationOutbox.t),
      orderBy: orderBy?.call(NotificationOutbox.t),
      orderByList: orderByList?.call(NotificationOutbox.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [NotificationOutbox] matching the given query parameters.
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
  Future<NotificationOutbox?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<NotificationOutboxTable>? where,
    int? offset,
    _is.OrderByBuilder<NotificationOutboxTable>? orderBy,
    _is.OrderByListBuilder<NotificationOutboxTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<NotificationOutbox>(
      where: where?.call(NotificationOutbox.t),
      orderBy: orderBy?.call(NotificationOutbox.t),
      orderByList: orderByList?.call(NotificationOutbox.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [NotificationOutbox] by its [id] or null if no such row exists.
  Future<NotificationOutbox?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<NotificationOutbox>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [NotificationOutbox]s in the list and returns the inserted rows.
  ///
  /// The returned [NotificationOutbox]s will have their `id` fields set.
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
  Future<List<NotificationOutbox>> insert(
    _is.DatabaseSession session,
    List<NotificationOutbox> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<NotificationOutbox>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [NotificationOutbox] and returns the inserted row.
  ///
  /// The returned [NotificationOutbox] will have its `id` field set.
  Future<NotificationOutbox> insertRow(
    _is.DatabaseSession session,
    NotificationOutbox row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<NotificationOutbox>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [NotificationOutbox]s in the list and returns the resulting rows.
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
  /// The returned [NotificationOutbox]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<NotificationOutbox>> upsert(
    _is.DatabaseSession session,
    List<NotificationOutbox> rows, {
    required _is.ColumnSelections<NotificationOutboxTable> conflictColumns,
    _is.ColumnSelections<NotificationOutboxTable>? updateColumns,
    _is.WhereExpressionBuilder<NotificationOutboxTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<NotificationOutbox>(
      rows,
      conflictColumns: conflictColumns(NotificationOutbox.t),
      updateColumns: updateColumns?.call(NotificationOutbox.t),
      updateWhere: updateWhere?.call(NotificationOutbox.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [NotificationOutbox] and returns the resulting row.
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
  /// The returned [NotificationOutbox] will have its `id` field set.
  Future<NotificationOutbox?> upsertRow(
    _is.DatabaseSession session,
    NotificationOutbox row, {
    required _is.ColumnSelections<NotificationOutboxTable> conflictColumns,
    _is.ColumnSelections<NotificationOutboxTable>? updateColumns,
    _is.WhereExpressionBuilder<NotificationOutboxTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<NotificationOutbox>(
      row,
      conflictColumns: conflictColumns(NotificationOutbox.t),
      updateColumns: updateColumns?.call(NotificationOutbox.t),
      updateWhere: updateWhere?.call(NotificationOutbox.t),
      transaction: transaction,
    );
  }

  /// Updates all [NotificationOutbox]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<NotificationOutbox>> update(
    _is.DatabaseSession session,
    List<NotificationOutbox> rows, {
    _is.ColumnSelections<NotificationOutboxTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<NotificationOutbox>(
      rows,
      columns: columns?.call(NotificationOutbox.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [NotificationOutbox]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<NotificationOutbox> updateRow(
    _is.DatabaseSession session,
    NotificationOutbox row, {
    _is.ColumnSelections<NotificationOutboxTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<NotificationOutbox>(
      row,
      columns: columns?.call(NotificationOutbox.t),
      transaction: transaction,
    );
  }

  /// Updates a single [NotificationOutbox] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<NotificationOutbox?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<NotificationOutboxUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<NotificationOutbox>(
      id,
      columnValues: columnValues(NotificationOutbox.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [NotificationOutbox]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<NotificationOutbox>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<NotificationOutboxUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<NotificationOutboxTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<NotificationOutboxTable>? orderBy,
    _is.OrderByListBuilder<NotificationOutboxTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<NotificationOutbox>(
      columnValues: columnValues(NotificationOutbox.t.updateTable),
      where: where(NotificationOutbox.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(NotificationOutbox.t),
      orderByList: orderByList?.call(NotificationOutbox.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [NotificationOutbox]s in the list and returns the deleted rows.
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
  Future<List<NotificationOutbox>> delete(
    _is.DatabaseSession session,
    List<NotificationOutbox> rows, {
    _is.OrderByBuilder<NotificationOutboxTable>? orderBy,
    _is.OrderByListBuilder<NotificationOutboxTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<NotificationOutbox>(
      rows,
      orderBy: orderBy?.call(NotificationOutbox.t),
      orderByList: orderByList?.call(NotificationOutbox.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [NotificationOutbox].
  Future<NotificationOutbox> deleteRow(
    _is.DatabaseSession session,
    NotificationOutbox row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<NotificationOutbox>(
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
  Future<List<NotificationOutbox>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<NotificationOutboxTable> where,
    _is.OrderByBuilder<NotificationOutboxTable>? orderBy,
    _is.OrderByListBuilder<NotificationOutboxTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<NotificationOutbox>(
      where: where(NotificationOutbox.t),
      orderBy: orderBy?.call(NotificationOutbox.t),
      orderByList: orderByList?.call(NotificationOutbox.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<NotificationOutboxTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<NotificationOutbox>(
      where: where?.call(NotificationOutbox.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [NotificationOutbox] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<NotificationOutboxTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<NotificationOutbox>(
      where: where(NotificationOutbox.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
