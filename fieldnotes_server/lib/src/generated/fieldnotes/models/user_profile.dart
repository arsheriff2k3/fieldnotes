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
import '../../fieldnotes/models/account_role.dart' as _i52iup9o;

abstract class FieldnoteUserProfile
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  FieldnoteUserProfile._({
    this.id,
    required this.authUserId,
    required this.role,
    required this.displayName,
    this.sponsorType,
    this.organizationName,
    this.contactPhone,
    required this.city,
    this.locationAddress,
    this.locationPlaceId,
    this.locationLatitude,
    this.locationLongitude,
    required this.interests,
    required this.skills,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory FieldnoteUserProfile({
    int? id,
    required _is.UuidValue authUserId,
    required _i52iup9o.AccountRole role,
    required String displayName,
    String? sponsorType,
    String? organizationName,
    String? contactPhone,
    required String city,
    String? locationAddress,
    String? locationPlaceId,
    double? locationLatitude,
    double? locationLongitude,
    required String interests,
    required String skills,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _FieldnoteUserProfileImpl;

  factory FieldnoteUserProfile.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return FieldnoteUserProfile(
      id: jsonSerialization['id'] as int?,
      authUserId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['authUserId'],
      ),
      role: _i52iup9o.AccountRole.fromJson(
        (jsonSerialization['role'] as String),
      ),
      displayName: jsonSerialization['displayName'] as String,
      sponsorType: jsonSerialization['sponsorType'] as String?,
      organizationName: jsonSerialization['organizationName'] as String?,
      contactPhone: jsonSerialization['contactPhone'] as String?,
      city: jsonSerialization['city'] as String,
      locationAddress: jsonSerialization['locationAddress'] as String?,
      locationPlaceId: jsonSerialization['locationPlaceId'] as String?,
      locationLatitude: (jsonSerialization['locationLatitude'] as num?)
          ?.toDouble(),
      locationLongitude: (jsonSerialization['locationLongitude'] as num?)
          ?.toDouble(),
      interests: jsonSerialization['interests'] as String,
      skills: jsonSerialization['skills'] as String,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  static final t = FieldnoteUserProfileTable();

  static const db = FieldnoteUserProfileRepository._();

  @override
  int? id;

  _is.UuidValue authUserId;

  _i52iup9o.AccountRole role;

  String displayName;

  String? sponsorType;

  String? organizationName;

  String? contactPhone;

  String city;

  String? locationAddress;

  String? locationPlaceId;

  double? locationLatitude;

  double? locationLongitude;

  String interests;

  String skills;

  DateTime createdAt;

  DateTime updatedAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [FieldnoteUserProfile]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  FieldnoteUserProfile copyWith({
    int? id,
    _is.UuidValue? authUserId,
    _i52iup9o.AccountRole? role,
    String? displayName,
    String? sponsorType,
    String? organizationName,
    String? contactPhone,
    String? city,
    String? locationAddress,
    String? locationPlaceId,
    double? locationLatitude,
    double? locationLongitude,
    String? interests,
    String? skills,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'FieldnoteUserProfile',
      if (id != null) 'id': id,
      'authUserId': authUserId.toJson(),
      'role': role.toJson(),
      'displayName': displayName,
      if (sponsorType != null) 'sponsorType': sponsorType,
      if (organizationName != null) 'organizationName': organizationName,
      if (contactPhone != null) 'contactPhone': contactPhone,
      'city': city,
      if (locationAddress != null) 'locationAddress': locationAddress,
      if (locationPlaceId != null) 'locationPlaceId': locationPlaceId,
      if (locationLatitude != null) 'locationLatitude': locationLatitude,
      if (locationLongitude != null) 'locationLongitude': locationLongitude,
      'interests': interests,
      'skills': skills,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'FieldnoteUserProfile',
      if (id != null) 'id': id,
      'authUserId': authUserId.toJson(),
      'role': role.toJson(),
      'displayName': displayName,
      if (sponsorType != null) 'sponsorType': sponsorType,
      if (organizationName != null) 'organizationName': organizationName,
      if (contactPhone != null) 'contactPhone': contactPhone,
      'city': city,
      if (locationAddress != null) 'locationAddress': locationAddress,
      if (locationPlaceId != null) 'locationPlaceId': locationPlaceId,
      if (locationLatitude != null) 'locationLatitude': locationLatitude,
      if (locationLongitude != null) 'locationLongitude': locationLongitude,
      'interests': interests,
      'skills': skills,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  static FieldnoteUserProfileInclude include() {
    return FieldnoteUserProfileInclude._();
  }

  static FieldnoteUserProfileIncludeList includeList({
    _is.WhereExpressionBuilder<FieldnoteUserProfileTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<FieldnoteUserProfileTable>? orderBy,
    _is.OrderByListBuilder<FieldnoteUserProfileTable>? orderByList,
    FieldnoteUserProfileInclude? include,
  }) {
    return FieldnoteUserProfileIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(FieldnoteUserProfile.t),
      orderByList: orderByList?.call(FieldnoteUserProfile.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _FieldnoteUserProfileImpl extends FieldnoteUserProfile {
  _FieldnoteUserProfileImpl({
    int? id,
    required _is.UuidValue authUserId,
    required _i52iup9o.AccountRole role,
    required String displayName,
    String? sponsorType,
    String? organizationName,
    String? contactPhone,
    required String city,
    String? locationAddress,
    String? locationPlaceId,
    double? locationLatitude,
    double? locationLongitude,
    required String interests,
    required String skills,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         authUserId: authUserId,
         role: role,
         displayName: displayName,
         sponsorType: sponsorType,
         organizationName: organizationName,
         contactPhone: contactPhone,
         city: city,
         locationAddress: locationAddress,
         locationPlaceId: locationPlaceId,
         locationLatitude: locationLatitude,
         locationLongitude: locationLongitude,
         interests: interests,
         skills: skills,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [FieldnoteUserProfile]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  FieldnoteUserProfile copyWith({
    Object? id = _Undefined,
    _is.UuidValue? authUserId,
    _i52iup9o.AccountRole? role,
    String? displayName,
    Object? sponsorType = _Undefined,
    Object? organizationName = _Undefined,
    Object? contactPhone = _Undefined,
    String? city,
    Object? locationAddress = _Undefined,
    Object? locationPlaceId = _Undefined,
    Object? locationLatitude = _Undefined,
    Object? locationLongitude = _Undefined,
    String? interests,
    String? skills,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FieldnoteUserProfile(
      id: id is int? ? id : this.id,
      authUserId: authUserId ?? this.authUserId,
      role: role ?? this.role,
      displayName: displayName ?? this.displayName,
      sponsorType: sponsorType is String? ? sponsorType : this.sponsorType,
      organizationName: organizationName is String?
          ? organizationName
          : this.organizationName,
      contactPhone: contactPhone is String? ? contactPhone : this.contactPhone,
      city: city ?? this.city,
      locationAddress: locationAddress is String?
          ? locationAddress
          : this.locationAddress,
      locationPlaceId: locationPlaceId is String?
          ? locationPlaceId
          : this.locationPlaceId,
      locationLatitude: locationLatitude is double?
          ? locationLatitude
          : this.locationLatitude,
      locationLongitude: locationLongitude is double?
          ? locationLongitude
          : this.locationLongitude,
      interests: interests ?? this.interests,
      skills: skills ?? this.skills,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class FieldnoteUserProfileUpdateTable
    extends _is.UpdateTable<FieldnoteUserProfileTable> {
  FieldnoteUserProfileUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> authUserId(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.authUserId,
    value,
  );

  _is.ColumnValue<_i52iup9o.AccountRole, _i52iup9o.AccountRole> role(
    _i52iup9o.AccountRole value,
  ) => _is.ColumnValue(
    table.role,
    value,
  );

  _is.ColumnValue<String, String> displayName(String value) => _is.ColumnValue(
    table.displayName,
    value,
  );

  _is.ColumnValue<String, String> sponsorType(String? value) => _is.ColumnValue(
    table.sponsorType,
    value,
  );

  _is.ColumnValue<String, String> organizationName(String? value) =>
      _is.ColumnValue(
        table.organizationName,
        value,
      );

  _is.ColumnValue<String, String> contactPhone(String? value) =>
      _is.ColumnValue(
        table.contactPhone,
        value,
      );

  _is.ColumnValue<String, String> city(String value) => _is.ColumnValue(
    table.city,
    value,
  );

  _is.ColumnValue<String, String> locationAddress(String? value) =>
      _is.ColumnValue(
        table.locationAddress,
        value,
      );

  _is.ColumnValue<String, String> locationPlaceId(String? value) =>
      _is.ColumnValue(
        table.locationPlaceId,
        value,
      );

  _is.ColumnValue<double, double> locationLatitude(double? value) =>
      _is.ColumnValue(
        table.locationLatitude,
        value,
      );

  _is.ColumnValue<double, double> locationLongitude(double? value) =>
      _is.ColumnValue(
        table.locationLongitude,
        value,
      );

  _is.ColumnValue<String, String> interests(String value) => _is.ColumnValue(
    table.interests,
    value,
  );

  _is.ColumnValue<String, String> skills(String value) => _is.ColumnValue(
    table.skills,
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

class FieldnoteUserProfileTable extends _is.Table<int?> {
  FieldnoteUserProfileTable({super.tableRelation})
    : super(tableName: 'fieldnote_user_profile') {
    updateTable = FieldnoteUserProfileUpdateTable(this);
    authUserId = _is.ColumnUuid(
      'authUserId',
      this,
    );
    role = _is.ColumnEnum(
      'role',
      this,
      _is.EnumSerialization.byName,
    );
    displayName = _is.ColumnString(
      'displayName',
      this,
    );
    sponsorType = _is.ColumnString(
      'sponsorType',
      this,
    );
    organizationName = _is.ColumnString(
      'organizationName',
      this,
    );
    contactPhone = _is.ColumnString(
      'contactPhone',
      this,
    );
    city = _is.ColumnString(
      'city',
      this,
    );
    locationAddress = _is.ColumnString(
      'locationAddress',
      this,
    );
    locationPlaceId = _is.ColumnString(
      'locationPlaceId',
      this,
    );
    locationLatitude = _is.ColumnDouble(
      'locationLatitude',
      this,
    );
    locationLongitude = _is.ColumnDouble(
      'locationLongitude',
      this,
    );
    interests = _is.ColumnString(
      'interests',
      this,
    );
    skills = _is.ColumnString(
      'skills',
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

  late final FieldnoteUserProfileUpdateTable updateTable;

  late final _is.ColumnUuid authUserId;

  late final _is.ColumnEnum<_i52iup9o.AccountRole> role;

  late final _is.ColumnString displayName;

  late final _is.ColumnString sponsorType;

  late final _is.ColumnString organizationName;

  late final _is.ColumnString contactPhone;

  late final _is.ColumnString city;

  late final _is.ColumnString locationAddress;

  late final _is.ColumnString locationPlaceId;

  late final _is.ColumnDouble locationLatitude;

  late final _is.ColumnDouble locationLongitude;

  late final _is.ColumnString interests;

  late final _is.ColumnString skills;

  late final _is.ColumnDateTime createdAt;

  late final _is.ColumnDateTime updatedAt;

  @override
  List<_is.Column> get columns => [
    id,
    authUserId,
    role,
    displayName,
    sponsorType,
    organizationName,
    contactPhone,
    city,
    locationAddress,
    locationPlaceId,
    locationLatitude,
    locationLongitude,
    interests,
    skills,
    createdAt,
    updatedAt,
  ];
}

class FieldnoteUserProfileInclude extends _is.IncludeObject {
  FieldnoteUserProfileInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => FieldnoteUserProfile.t;
}

class FieldnoteUserProfileIncludeList extends _is.IncludeList {
  FieldnoteUserProfileIncludeList._({
    _is.WhereExpressionBuilder<FieldnoteUserProfileTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(FieldnoteUserProfile.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => FieldnoteUserProfile.t;
}

class FieldnoteUserProfileRepository {
  const FieldnoteUserProfileRepository._();

  /// Returns a list of [FieldnoteUserProfile]s matching the given query parameters.
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
  Future<List<FieldnoteUserProfile>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<FieldnoteUserProfileTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<FieldnoteUserProfileTable>? orderBy,
    _is.OrderByListBuilder<FieldnoteUserProfileTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<FieldnoteUserProfile>(
      where: where?.call(FieldnoteUserProfile.t),
      orderBy: orderBy?.call(FieldnoteUserProfile.t),
      orderByList: orderByList?.call(FieldnoteUserProfile.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [FieldnoteUserProfile] matching the given query parameters.
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
  Future<FieldnoteUserProfile?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<FieldnoteUserProfileTable>? where,
    int? offset,
    _is.OrderByBuilder<FieldnoteUserProfileTable>? orderBy,
    _is.OrderByListBuilder<FieldnoteUserProfileTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<FieldnoteUserProfile>(
      where: where?.call(FieldnoteUserProfile.t),
      orderBy: orderBy?.call(FieldnoteUserProfile.t),
      orderByList: orderByList?.call(FieldnoteUserProfile.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [FieldnoteUserProfile] by its [id] or null if no such row exists.
  Future<FieldnoteUserProfile?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<FieldnoteUserProfile>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [FieldnoteUserProfile]s in the list and returns the inserted rows.
  ///
  /// The returned [FieldnoteUserProfile]s will have their `id` fields set.
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
  Future<List<FieldnoteUserProfile>> insert(
    _is.DatabaseSession session,
    List<FieldnoteUserProfile> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<FieldnoteUserProfile>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [FieldnoteUserProfile] and returns the inserted row.
  ///
  /// The returned [FieldnoteUserProfile] will have its `id` field set.
  Future<FieldnoteUserProfile> insertRow(
    _is.DatabaseSession session,
    FieldnoteUserProfile row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<FieldnoteUserProfile>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [FieldnoteUserProfile]s in the list and returns the resulting rows.
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
  /// The returned [FieldnoteUserProfile]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<FieldnoteUserProfile>> upsert(
    _is.DatabaseSession session,
    List<FieldnoteUserProfile> rows, {
    required _is.ColumnSelections<FieldnoteUserProfileTable> conflictColumns,
    _is.ColumnSelections<FieldnoteUserProfileTable>? updateColumns,
    _is.WhereExpressionBuilder<FieldnoteUserProfileTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<FieldnoteUserProfile>(
      rows,
      conflictColumns: conflictColumns(FieldnoteUserProfile.t),
      updateColumns: updateColumns?.call(FieldnoteUserProfile.t),
      updateWhere: updateWhere?.call(FieldnoteUserProfile.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [FieldnoteUserProfile] and returns the resulting row.
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
  /// The returned [FieldnoteUserProfile] will have its `id` field set.
  Future<FieldnoteUserProfile?> upsertRow(
    _is.DatabaseSession session,
    FieldnoteUserProfile row, {
    required _is.ColumnSelections<FieldnoteUserProfileTable> conflictColumns,
    _is.ColumnSelections<FieldnoteUserProfileTable>? updateColumns,
    _is.WhereExpressionBuilder<FieldnoteUserProfileTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<FieldnoteUserProfile>(
      row,
      conflictColumns: conflictColumns(FieldnoteUserProfile.t),
      updateColumns: updateColumns?.call(FieldnoteUserProfile.t),
      updateWhere: updateWhere?.call(FieldnoteUserProfile.t),
      transaction: transaction,
    );
  }

  /// Updates all [FieldnoteUserProfile]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<FieldnoteUserProfile>> update(
    _is.DatabaseSession session,
    List<FieldnoteUserProfile> rows, {
    _is.ColumnSelections<FieldnoteUserProfileTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<FieldnoteUserProfile>(
      rows,
      columns: columns?.call(FieldnoteUserProfile.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [FieldnoteUserProfile]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<FieldnoteUserProfile> updateRow(
    _is.DatabaseSession session,
    FieldnoteUserProfile row, {
    _is.ColumnSelections<FieldnoteUserProfileTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<FieldnoteUserProfile>(
      row,
      columns: columns?.call(FieldnoteUserProfile.t),
      transaction: transaction,
    );
  }

  /// Updates a single [FieldnoteUserProfile] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<FieldnoteUserProfile?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<FieldnoteUserProfileUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<FieldnoteUserProfile>(
      id,
      columnValues: columnValues(FieldnoteUserProfile.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [FieldnoteUserProfile]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<FieldnoteUserProfile>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<FieldnoteUserProfileUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<FieldnoteUserProfileTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<FieldnoteUserProfileTable>? orderBy,
    _is.OrderByListBuilder<FieldnoteUserProfileTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<FieldnoteUserProfile>(
      columnValues: columnValues(FieldnoteUserProfile.t.updateTable),
      where: where(FieldnoteUserProfile.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(FieldnoteUserProfile.t),
      orderByList: orderByList?.call(FieldnoteUserProfile.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [FieldnoteUserProfile]s in the list and returns the deleted rows.
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
  Future<List<FieldnoteUserProfile>> delete(
    _is.DatabaseSession session,
    List<FieldnoteUserProfile> rows, {
    _is.OrderByBuilder<FieldnoteUserProfileTable>? orderBy,
    _is.OrderByListBuilder<FieldnoteUserProfileTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<FieldnoteUserProfile>(
      rows,
      orderBy: orderBy?.call(FieldnoteUserProfile.t),
      orderByList: orderByList?.call(FieldnoteUserProfile.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [FieldnoteUserProfile].
  Future<FieldnoteUserProfile> deleteRow(
    _is.DatabaseSession session,
    FieldnoteUserProfile row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<FieldnoteUserProfile>(
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
  Future<List<FieldnoteUserProfile>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<FieldnoteUserProfileTable> where,
    _is.OrderByBuilder<FieldnoteUserProfileTable>? orderBy,
    _is.OrderByListBuilder<FieldnoteUserProfileTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<FieldnoteUserProfile>(
      where: where(FieldnoteUserProfile.t),
      orderBy: orderBy?.call(FieldnoteUserProfile.t),
      orderByList: orderByList?.call(FieldnoteUserProfile.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<FieldnoteUserProfileTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<FieldnoteUserProfile>(
      where: where?.call(FieldnoteUserProfile.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [FieldnoteUserProfile] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<FieldnoteUserProfileTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<FieldnoteUserProfile>(
      where: where(FieldnoteUserProfile.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
