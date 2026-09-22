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

abstract class Asset implements _is.TableRow<int?>, _is.ProtocolSerialization {
  Asset._({
    this.id,
    required this.campaignId,
    required this.externalId,
    this.species,
    this.plantedAt,
    required this.latitude,
    required this.longitude,
    this.notes,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Asset({
    int? id,
    required int campaignId,
    required String externalId,
    String? species,
    DateTime? plantedAt,
    required double latitude,
    required double longitude,
    String? notes,
    DateTime? createdAt,
  }) = _AssetImpl;

  factory Asset.fromJson(Map<String, dynamic> jsonSerialization) {
    return Asset(
      id: jsonSerialization['id'] as int?,
      campaignId: jsonSerialization['campaignId'] as int,
      externalId: jsonSerialization['externalId'] as String,
      species: jsonSerialization['species'] as String?,
      plantedAt: jsonSerialization['plantedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['plantedAt']),
      latitude: (jsonSerialization['latitude'] as num).toDouble(),
      longitude: (jsonSerialization['longitude'] as num).toDouble(),
      notes: jsonSerialization['notes'] as String?,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  static final t = AssetTable();

  static const db = AssetRepository._();

  @override
  int? id;

  int campaignId;

  String externalId;

  String? species;

  DateTime? plantedAt;

  double latitude;

  double longitude;

  String? notes;

  DateTime createdAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [Asset]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  Asset copyWith({
    int? id,
    int? campaignId,
    String? externalId,
    String? species,
    DateTime? plantedAt,
    double? latitude,
    double? longitude,
    String? notes,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Asset',
      if (id != null) 'id': id,
      'campaignId': campaignId,
      'externalId': externalId,
      if (species != null) 'species': species,
      if (plantedAt != null) 'plantedAt': plantedAt?.toJson(),
      'latitude': latitude,
      'longitude': longitude,
      if (notes != null) 'notes': notes,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Asset',
      if (id != null) 'id': id,
      'campaignId': campaignId,
      'externalId': externalId,
      if (species != null) 'species': species,
      if (plantedAt != null) 'plantedAt': plantedAt?.toJson(),
      'latitude': latitude,
      'longitude': longitude,
      if (notes != null) 'notes': notes,
      'createdAt': createdAt.toJson(),
    };
  }

  static AssetInclude include() {
    return AssetInclude._();
  }

  static AssetIncludeList includeList({
    _is.WhereExpressionBuilder<AssetTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AssetTable>? orderBy,
    _is.OrderByListBuilder<AssetTable>? orderByList,
    AssetInclude? include,
  }) {
    return AssetIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Asset.t),
      orderByList: orderByList?.call(Asset.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AssetImpl extends Asset {
  _AssetImpl({
    int? id,
    required int campaignId,
    required String externalId,
    String? species,
    DateTime? plantedAt,
    required double latitude,
    required double longitude,
    String? notes,
    DateTime? createdAt,
  }) : super._(
         id: id,
         campaignId: campaignId,
         externalId: externalId,
         species: species,
         plantedAt: plantedAt,
         latitude: latitude,
         longitude: longitude,
         notes: notes,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [Asset]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  Asset copyWith({
    Object? id = _Undefined,
    int? campaignId,
    String? externalId,
    Object? species = _Undefined,
    Object? plantedAt = _Undefined,
    double? latitude,
    double? longitude,
    Object? notes = _Undefined,
    DateTime? createdAt,
  }) {
    return Asset(
      id: id is int? ? id : this.id,
      campaignId: campaignId ?? this.campaignId,
      externalId: externalId ?? this.externalId,
      species: species is String? ? species : this.species,
      plantedAt: plantedAt is DateTime? ? plantedAt : this.plantedAt,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      notes: notes is String? ? notes : this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class AssetUpdateTable extends _is.UpdateTable<AssetTable> {
  AssetUpdateTable(super.table);

  _is.ColumnValue<int, int> campaignId(int value) => _is.ColumnValue(
    table.campaignId,
    value,
  );

  _is.ColumnValue<String, String> externalId(String value) => _is.ColumnValue(
    table.externalId,
    value,
  );

  _is.ColumnValue<String, String> species(String? value) => _is.ColumnValue(
    table.species,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> plantedAt(DateTime? value) =>
      _is.ColumnValue(
        table.plantedAt,
        value,
      );

  _is.ColumnValue<double, double> latitude(double value) => _is.ColumnValue(
    table.latitude,
    value,
  );

  _is.ColumnValue<double, double> longitude(double value) => _is.ColumnValue(
    table.longitude,
    value,
  );

  _is.ColumnValue<String, String> notes(String? value) => _is.ColumnValue(
    table.notes,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );
}

class AssetTable extends _is.Table<int?> {
  AssetTable({super.tableRelation}) : super(tableName: 'fieldnote_asset') {
    updateTable = AssetUpdateTable(this);
    campaignId = _is.ColumnInt(
      'campaignId',
      this,
    );
    externalId = _is.ColumnString(
      'externalId',
      this,
    );
    species = _is.ColumnString(
      'species',
      this,
    );
    plantedAt = _is.ColumnDateTime(
      'plantedAt',
      this,
    );
    latitude = _is.ColumnDouble(
      'latitude',
      this,
    );
    longitude = _is.ColumnDouble(
      'longitude',
      this,
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

  late final AssetUpdateTable updateTable;

  late final _is.ColumnInt campaignId;

  late final _is.ColumnString externalId;

  late final _is.ColumnString species;

  late final _is.ColumnDateTime plantedAt;

  late final _is.ColumnDouble latitude;

  late final _is.ColumnDouble longitude;

  late final _is.ColumnString notes;

  late final _is.ColumnDateTime createdAt;

  @override
  List<_is.Column> get columns => [
    id,
    campaignId,
    externalId,
    species,
    plantedAt,
    latitude,
    longitude,
    notes,
    createdAt,
  ];
}

class AssetInclude extends _is.IncludeObject {
  AssetInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => Asset.t;
}

class AssetIncludeList extends _is.IncludeList {
  AssetIncludeList._({
    _is.WhereExpressionBuilder<AssetTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Asset.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => Asset.t;
}

class AssetRepository {
  const AssetRepository._();

  /// Returns a list of [Asset]s matching the given query parameters.
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
  Future<List<Asset>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AssetTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AssetTable>? orderBy,
    _is.OrderByListBuilder<AssetTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<Asset>(
      where: where?.call(Asset.t),
      orderBy: orderBy?.call(Asset.t),
      orderByList: orderByList?.call(Asset.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [Asset] matching the given query parameters.
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
  Future<Asset?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AssetTable>? where,
    int? offset,
    _is.OrderByBuilder<AssetTable>? orderBy,
    _is.OrderByListBuilder<AssetTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<Asset>(
      where: where?.call(Asset.t),
      orderBy: orderBy?.call(Asset.t),
      orderByList: orderByList?.call(Asset.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [Asset] by its [id] or null if no such row exists.
  Future<Asset?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<Asset>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [Asset]s in the list and returns the inserted rows.
  ///
  /// The returned [Asset]s will have their `id` fields set.
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
  Future<List<Asset>> insert(
    _is.DatabaseSession session,
    List<Asset> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<Asset>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [Asset] and returns the inserted row.
  ///
  /// The returned [Asset] will have its `id` field set.
  Future<Asset> insertRow(
    _is.DatabaseSession session,
    Asset row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<Asset>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [Asset]s in the list and returns the resulting rows.
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
  /// The returned [Asset]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Asset>> upsert(
    _is.DatabaseSession session,
    List<Asset> rows, {
    required _is.ColumnSelections<AssetTable> conflictColumns,
    _is.ColumnSelections<AssetTable>? updateColumns,
    _is.WhereExpressionBuilder<AssetTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<Asset>(
      rows,
      conflictColumns: conflictColumns(Asset.t),
      updateColumns: updateColumns?.call(Asset.t),
      updateWhere: updateWhere?.call(Asset.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [Asset] and returns the resulting row.
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
  /// The returned [Asset] will have its `id` field set.
  Future<Asset?> upsertRow(
    _is.DatabaseSession session,
    Asset row, {
    required _is.ColumnSelections<AssetTable> conflictColumns,
    _is.ColumnSelections<AssetTable>? updateColumns,
    _is.WhereExpressionBuilder<AssetTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<Asset>(
      row,
      conflictColumns: conflictColumns(Asset.t),
      updateColumns: updateColumns?.call(Asset.t),
      updateWhere: updateWhere?.call(Asset.t),
      transaction: transaction,
    );
  }

  /// Updates all [Asset]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Asset>> update(
    _is.DatabaseSession session,
    List<Asset> rows, {
    _is.ColumnSelections<AssetTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<Asset>(
      rows,
      columns: columns?.call(Asset.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [Asset]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Asset> updateRow(
    _is.DatabaseSession session,
    Asset row, {
    _is.ColumnSelections<AssetTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<Asset>(
      row,
      columns: columns?.call(Asset.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Asset] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<Asset?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<AssetUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<Asset>(
      id,
      columnValues: columnValues(Asset.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [Asset]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Asset>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<AssetUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<AssetTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AssetTable>? orderBy,
    _is.OrderByListBuilder<AssetTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<Asset>(
      columnValues: columnValues(Asset.t.updateTable),
      where: where(Asset.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Asset.t),
      orderByList: orderByList?.call(Asset.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [Asset]s in the list and returns the deleted rows.
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
  Future<List<Asset>> delete(
    _is.DatabaseSession session,
    List<Asset> rows, {
    _is.OrderByBuilder<AssetTable>? orderBy,
    _is.OrderByListBuilder<AssetTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<Asset>(
      rows,
      orderBy: orderBy?.call(Asset.t),
      orderByList: orderByList?.call(Asset.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [Asset].
  Future<Asset> deleteRow(
    _is.DatabaseSession session,
    Asset row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Asset>(
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
  Future<List<Asset>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<AssetTable> where,
    _is.OrderByBuilder<AssetTable>? orderBy,
    _is.OrderByListBuilder<AssetTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<Asset>(
      where: where(Asset.t),
      orderBy: orderBy?.call(Asset.t),
      orderByList: orderByList?.call(Asset.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AssetTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<Asset>(
      where: where?.call(Asset.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [Asset] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<AssetTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<Asset>(
      where: where(Asset.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
