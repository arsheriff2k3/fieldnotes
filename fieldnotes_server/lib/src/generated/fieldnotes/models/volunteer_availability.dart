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

abstract class VolunteerAvailability
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  VolunteerAvailability._({
    this.id,
    required this.volunteerAuthUserId,
    bool? isAvailable,
    bool? availableToday,
    required this.weekdays,
    required this.startMinutes,
    required this.endMinutes,
    required this.maximumTravelKm,
    this.latitude,
    this.longitude,
    required this.locationLabel,
    this.timezone,
    this.utcOffsetMinutes,
    this.availableTodayDate,
    DateTime? updatedAt,
  }) : isAvailable = isAvailable ?? true,
       availableToday = availableToday ?? false,
       updatedAt = updatedAt ?? DateTime.now();

  factory VolunteerAvailability({
    int? id,
    required _is.UuidValue volunteerAuthUserId,
    bool? isAvailable,
    bool? availableToday,
    required String weekdays,
    required int startMinutes,
    required int endMinutes,
    required double maximumTravelKm,
    double? latitude,
    double? longitude,
    required String locationLabel,
    String? timezone,
    int? utcOffsetMinutes,
    String? availableTodayDate,
    DateTime? updatedAt,
  }) = _VolunteerAvailabilityImpl;

  factory VolunteerAvailability.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return VolunteerAvailability(
      id: jsonSerialization['id'] as int?,
      volunteerAuthUserId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['volunteerAuthUserId'],
      ),
      isAvailable: jsonSerialization['isAvailable'] == null
          ? null
          : _is.BoolJsonExtension.fromJson(jsonSerialization['isAvailable']),
      availableToday: jsonSerialization['availableToday'] == null
          ? null
          : _is.BoolJsonExtension.fromJson(jsonSerialization['availableToday']),
      weekdays: jsonSerialization['weekdays'] as String,
      startMinutes: jsonSerialization['startMinutes'] as int,
      endMinutes: jsonSerialization['endMinutes'] as int,
      maximumTravelKm: (jsonSerialization['maximumTravelKm'] as num).toDouble(),
      latitude: (jsonSerialization['latitude'] as num?)?.toDouble(),
      longitude: (jsonSerialization['longitude'] as num?)?.toDouble(),
      locationLabel: jsonSerialization['locationLabel'] as String,
      timezone: jsonSerialization['timezone'] as String?,
      utcOffsetMinutes: jsonSerialization['utcOffsetMinutes'] as int?,
      availableTodayDate: jsonSerialization['availableTodayDate'] as String?,
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  static final t = VolunteerAvailabilityTable();

  static const db = VolunteerAvailabilityRepository._();

  @override
  int? id;

  _is.UuidValue volunteerAuthUserId;

  bool isAvailable;

  bool availableToday;

  String weekdays;

  int startMinutes;

  int endMinutes;

  double maximumTravelKm;

  double? latitude;

  double? longitude;

  String locationLabel;

  String? timezone;

  int? utcOffsetMinutes;

  String? availableTodayDate;

  DateTime updatedAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [VolunteerAvailability]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  VolunteerAvailability copyWith({
    int? id,
    _is.UuidValue? volunteerAuthUserId,
    bool? isAvailable,
    bool? availableToday,
    String? weekdays,
    int? startMinutes,
    int? endMinutes,
    double? maximumTravelKm,
    double? latitude,
    double? longitude,
    String? locationLabel,
    String? timezone,
    int? utcOffsetMinutes,
    String? availableTodayDate,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'VolunteerAvailability',
      if (id != null) 'id': id,
      'volunteerAuthUserId': volunteerAuthUserId.toJson(),
      'isAvailable': isAvailable,
      'availableToday': availableToday,
      'weekdays': weekdays,
      'startMinutes': startMinutes,
      'endMinutes': endMinutes,
      'maximumTravelKm': maximumTravelKm,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      'locationLabel': locationLabel,
      if (timezone != null) 'timezone': timezone,
      if (utcOffsetMinutes != null) 'utcOffsetMinutes': utcOffsetMinutes,
      if (availableTodayDate != null) 'availableTodayDate': availableTodayDate,
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'VolunteerAvailability',
      if (id != null) 'id': id,
      'volunteerAuthUserId': volunteerAuthUserId.toJson(),
      'isAvailable': isAvailable,
      'availableToday': availableToday,
      'weekdays': weekdays,
      'startMinutes': startMinutes,
      'endMinutes': endMinutes,
      'maximumTravelKm': maximumTravelKm,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      'locationLabel': locationLabel,
      if (timezone != null) 'timezone': timezone,
      if (utcOffsetMinutes != null) 'utcOffsetMinutes': utcOffsetMinutes,
      if (availableTodayDate != null) 'availableTodayDate': availableTodayDate,
      'updatedAt': updatedAt.toJson(),
    };
  }

  static VolunteerAvailabilityInclude include() {
    return VolunteerAvailabilityInclude._();
  }

  static VolunteerAvailabilityIncludeList includeList({
    _is.WhereExpressionBuilder<VolunteerAvailabilityTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<VolunteerAvailabilityTable>? orderBy,
    _is.OrderByListBuilder<VolunteerAvailabilityTable>? orderByList,
    VolunteerAvailabilityInclude? include,
  }) {
    return VolunteerAvailabilityIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(VolunteerAvailability.t),
      orderByList: orderByList?.call(VolunteerAvailability.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _VolunteerAvailabilityImpl extends VolunteerAvailability {
  _VolunteerAvailabilityImpl({
    int? id,
    required _is.UuidValue volunteerAuthUserId,
    bool? isAvailable,
    bool? availableToday,
    required String weekdays,
    required int startMinutes,
    required int endMinutes,
    required double maximumTravelKm,
    double? latitude,
    double? longitude,
    required String locationLabel,
    String? timezone,
    int? utcOffsetMinutes,
    String? availableTodayDate,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         volunteerAuthUserId: volunteerAuthUserId,
         isAvailable: isAvailable,
         availableToday: availableToday,
         weekdays: weekdays,
         startMinutes: startMinutes,
         endMinutes: endMinutes,
         maximumTravelKm: maximumTravelKm,
         latitude: latitude,
         longitude: longitude,
         locationLabel: locationLabel,
         timezone: timezone,
         utcOffsetMinutes: utcOffsetMinutes,
         availableTodayDate: availableTodayDate,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [VolunteerAvailability]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  VolunteerAvailability copyWith({
    Object? id = _Undefined,
    _is.UuidValue? volunteerAuthUserId,
    bool? isAvailable,
    bool? availableToday,
    String? weekdays,
    int? startMinutes,
    int? endMinutes,
    double? maximumTravelKm,
    Object? latitude = _Undefined,
    Object? longitude = _Undefined,
    String? locationLabel,
    Object? timezone = _Undefined,
    Object? utcOffsetMinutes = _Undefined,
    Object? availableTodayDate = _Undefined,
    DateTime? updatedAt,
  }) {
    return VolunteerAvailability(
      id: id is int? ? id : this.id,
      volunteerAuthUserId: volunteerAuthUserId ?? this.volunteerAuthUserId,
      isAvailable: isAvailable ?? this.isAvailable,
      availableToday: availableToday ?? this.availableToday,
      weekdays: weekdays ?? this.weekdays,
      startMinutes: startMinutes ?? this.startMinutes,
      endMinutes: endMinutes ?? this.endMinutes,
      maximumTravelKm: maximumTravelKm ?? this.maximumTravelKm,
      latitude: latitude is double? ? latitude : this.latitude,
      longitude: longitude is double? ? longitude : this.longitude,
      locationLabel: locationLabel ?? this.locationLabel,
      timezone: timezone is String? ? timezone : this.timezone,
      utcOffsetMinutes: utcOffsetMinutes is int?
          ? utcOffsetMinutes
          : this.utcOffsetMinutes,
      availableTodayDate: availableTodayDate is String?
          ? availableTodayDate
          : this.availableTodayDate,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class VolunteerAvailabilityUpdateTable
    extends _is.UpdateTable<VolunteerAvailabilityTable> {
  VolunteerAvailabilityUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> volunteerAuthUserId(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.volunteerAuthUserId,
    value,
  );

  _is.ColumnValue<bool, bool> isAvailable(bool value) => _is.ColumnValue(
    table.isAvailable,
    value,
  );

  _is.ColumnValue<bool, bool> availableToday(bool value) => _is.ColumnValue(
    table.availableToday,
    value,
  );

  _is.ColumnValue<String, String> weekdays(String value) => _is.ColumnValue(
    table.weekdays,
    value,
  );

  _is.ColumnValue<int, int> startMinutes(int value) => _is.ColumnValue(
    table.startMinutes,
    value,
  );

  _is.ColumnValue<int, int> endMinutes(int value) => _is.ColumnValue(
    table.endMinutes,
    value,
  );

  _is.ColumnValue<double, double> maximumTravelKm(double value) =>
      _is.ColumnValue(
        table.maximumTravelKm,
        value,
      );

  _is.ColumnValue<double, double> latitude(double? value) => _is.ColumnValue(
    table.latitude,
    value,
  );

  _is.ColumnValue<double, double> longitude(double? value) => _is.ColumnValue(
    table.longitude,
    value,
  );

  _is.ColumnValue<String, String> locationLabel(String value) =>
      _is.ColumnValue(
        table.locationLabel,
        value,
      );

  _is.ColumnValue<String, String> timezone(String? value) => _is.ColumnValue(
    table.timezone,
    value,
  );

  _is.ColumnValue<int, int> utcOffsetMinutes(int? value) => _is.ColumnValue(
    table.utcOffsetMinutes,
    value,
  );

  _is.ColumnValue<String, String> availableTodayDate(String? value) =>
      _is.ColumnValue(
        table.availableTodayDate,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> updatedAt(DateTime value) =>
      _is.ColumnValue(
        table.updatedAt,
        value,
      );
}

class VolunteerAvailabilityTable extends _is.Table<int?> {
  VolunteerAvailabilityTable({super.tableRelation})
    : super(tableName: 'fieldnote_volunteer_availability') {
    updateTable = VolunteerAvailabilityUpdateTable(this);
    volunteerAuthUserId = _is.ColumnUuid(
      'volunteerAuthUserId',
      this,
    );
    isAvailable = _is.ColumnBool(
      'isAvailable',
      this,
      hasDefault: true,
    );
    availableToday = _is.ColumnBool(
      'availableToday',
      this,
      hasDefault: true,
    );
    weekdays = _is.ColumnString(
      'weekdays',
      this,
    );
    startMinutes = _is.ColumnInt(
      'startMinutes',
      this,
    );
    endMinutes = _is.ColumnInt(
      'endMinutes',
      this,
    );
    maximumTravelKm = _is.ColumnDouble(
      'maximumTravelKm',
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
    locationLabel = _is.ColumnString(
      'locationLabel',
      this,
    );
    timezone = _is.ColumnString(
      'timezone',
      this,
    );
    utcOffsetMinutes = _is.ColumnInt(
      'utcOffsetMinutes',
      this,
    );
    availableTodayDate = _is.ColumnString(
      'availableTodayDate',
      this,
    );
    updatedAt = _is.ColumnDateTime(
      'updatedAt',
      this,
      hasDefault: true,
    );
  }

  late final VolunteerAvailabilityUpdateTable updateTable;

  late final _is.ColumnUuid volunteerAuthUserId;

  late final _is.ColumnBool isAvailable;

  late final _is.ColumnBool availableToday;

  late final _is.ColumnString weekdays;

  late final _is.ColumnInt startMinutes;

  late final _is.ColumnInt endMinutes;

  late final _is.ColumnDouble maximumTravelKm;

  late final _is.ColumnDouble latitude;

  late final _is.ColumnDouble longitude;

  late final _is.ColumnString locationLabel;

  late final _is.ColumnString timezone;

  late final _is.ColumnInt utcOffsetMinutes;

  late final _is.ColumnString availableTodayDate;

  late final _is.ColumnDateTime updatedAt;

  @override
  List<_is.Column> get columns => [
    id,
    volunteerAuthUserId,
    isAvailable,
    availableToday,
    weekdays,
    startMinutes,
    endMinutes,
    maximumTravelKm,
    latitude,
    longitude,
    locationLabel,
    timezone,
    utcOffsetMinutes,
    availableTodayDate,
    updatedAt,
  ];
}

class VolunteerAvailabilityInclude extends _is.IncludeObject {
  VolunteerAvailabilityInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => VolunteerAvailability.t;
}

class VolunteerAvailabilityIncludeList extends _is.IncludeList {
  VolunteerAvailabilityIncludeList._({
    _is.WhereExpressionBuilder<VolunteerAvailabilityTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(VolunteerAvailability.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => VolunteerAvailability.t;
}

class VolunteerAvailabilityRepository {
  const VolunteerAvailabilityRepository._();

  /// Returns a list of [VolunteerAvailability]s matching the given query parameters.
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
  Future<List<VolunteerAvailability>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<VolunteerAvailabilityTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<VolunteerAvailabilityTable>? orderBy,
    _is.OrderByListBuilder<VolunteerAvailabilityTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<VolunteerAvailability>(
      where: where?.call(VolunteerAvailability.t),
      orderBy: orderBy?.call(VolunteerAvailability.t),
      orderByList: orderByList?.call(VolunteerAvailability.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [VolunteerAvailability] matching the given query parameters.
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
  Future<VolunteerAvailability?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<VolunteerAvailabilityTable>? where,
    int? offset,
    _is.OrderByBuilder<VolunteerAvailabilityTable>? orderBy,
    _is.OrderByListBuilder<VolunteerAvailabilityTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<VolunteerAvailability>(
      where: where?.call(VolunteerAvailability.t),
      orderBy: orderBy?.call(VolunteerAvailability.t),
      orderByList: orderByList?.call(VolunteerAvailability.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [VolunteerAvailability] by its [id] or null if no such row exists.
  Future<VolunteerAvailability?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<VolunteerAvailability>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [VolunteerAvailability]s in the list and returns the inserted rows.
  ///
  /// The returned [VolunteerAvailability]s will have their `id` fields set.
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
  Future<List<VolunteerAvailability>> insert(
    _is.DatabaseSession session,
    List<VolunteerAvailability> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<VolunteerAvailability>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [VolunteerAvailability] and returns the inserted row.
  ///
  /// The returned [VolunteerAvailability] will have its `id` field set.
  Future<VolunteerAvailability> insertRow(
    _is.DatabaseSession session,
    VolunteerAvailability row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<VolunteerAvailability>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [VolunteerAvailability]s in the list and returns the resulting rows.
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
  /// The returned [VolunteerAvailability]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<VolunteerAvailability>> upsert(
    _is.DatabaseSession session,
    List<VolunteerAvailability> rows, {
    required _is.ColumnSelections<VolunteerAvailabilityTable> conflictColumns,
    _is.ColumnSelections<VolunteerAvailabilityTable>? updateColumns,
    _is.WhereExpressionBuilder<VolunteerAvailabilityTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<VolunteerAvailability>(
      rows,
      conflictColumns: conflictColumns(VolunteerAvailability.t),
      updateColumns: updateColumns?.call(VolunteerAvailability.t),
      updateWhere: updateWhere?.call(VolunteerAvailability.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [VolunteerAvailability] and returns the resulting row.
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
  /// The returned [VolunteerAvailability] will have its `id` field set.
  Future<VolunteerAvailability?> upsertRow(
    _is.DatabaseSession session,
    VolunteerAvailability row, {
    required _is.ColumnSelections<VolunteerAvailabilityTable> conflictColumns,
    _is.ColumnSelections<VolunteerAvailabilityTable>? updateColumns,
    _is.WhereExpressionBuilder<VolunteerAvailabilityTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<VolunteerAvailability>(
      row,
      conflictColumns: conflictColumns(VolunteerAvailability.t),
      updateColumns: updateColumns?.call(VolunteerAvailability.t),
      updateWhere: updateWhere?.call(VolunteerAvailability.t),
      transaction: transaction,
    );
  }

  /// Updates all [VolunteerAvailability]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<VolunteerAvailability>> update(
    _is.DatabaseSession session,
    List<VolunteerAvailability> rows, {
    _is.ColumnSelections<VolunteerAvailabilityTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<VolunteerAvailability>(
      rows,
      columns: columns?.call(VolunteerAvailability.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [VolunteerAvailability]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<VolunteerAvailability> updateRow(
    _is.DatabaseSession session,
    VolunteerAvailability row, {
    _is.ColumnSelections<VolunteerAvailabilityTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<VolunteerAvailability>(
      row,
      columns: columns?.call(VolunteerAvailability.t),
      transaction: transaction,
    );
  }

  /// Updates a single [VolunteerAvailability] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<VolunteerAvailability?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<VolunteerAvailabilityUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<VolunteerAvailability>(
      id,
      columnValues: columnValues(VolunteerAvailability.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [VolunteerAvailability]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<VolunteerAvailability>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<VolunteerAvailabilityUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<VolunteerAvailabilityTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<VolunteerAvailabilityTable>? orderBy,
    _is.OrderByListBuilder<VolunteerAvailabilityTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<VolunteerAvailability>(
      columnValues: columnValues(VolunteerAvailability.t.updateTable),
      where: where(VolunteerAvailability.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(VolunteerAvailability.t),
      orderByList: orderByList?.call(VolunteerAvailability.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [VolunteerAvailability]s in the list and returns the deleted rows.
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
  Future<List<VolunteerAvailability>> delete(
    _is.DatabaseSession session,
    List<VolunteerAvailability> rows, {
    _is.OrderByBuilder<VolunteerAvailabilityTable>? orderBy,
    _is.OrderByListBuilder<VolunteerAvailabilityTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<VolunteerAvailability>(
      rows,
      orderBy: orderBy?.call(VolunteerAvailability.t),
      orderByList: orderByList?.call(VolunteerAvailability.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [VolunteerAvailability].
  Future<VolunteerAvailability> deleteRow(
    _is.DatabaseSession session,
    VolunteerAvailability row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<VolunteerAvailability>(
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
  Future<List<VolunteerAvailability>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<VolunteerAvailabilityTable> where,
    _is.OrderByBuilder<VolunteerAvailabilityTable>? orderBy,
    _is.OrderByListBuilder<VolunteerAvailabilityTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<VolunteerAvailability>(
      where: where(VolunteerAvailability.t),
      orderBy: orderBy?.call(VolunteerAvailability.t),
      orderByList: orderByList?.call(VolunteerAvailability.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<VolunteerAvailabilityTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<VolunteerAvailability>(
      where: where?.call(VolunteerAvailability.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [VolunteerAvailability] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<VolunteerAvailabilityTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<VolunteerAvailability>(
      where: where(VolunteerAvailability.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
