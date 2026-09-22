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
import '../../fieldnotes/models/campaign_status.dart' as _i4m9p8sf;

abstract class Campaign
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  Campaign._({
    this.id,
    required this.organizationId,
    required this.name,
    required this.description,
    required this.locationName,
    required this.startsAt,
    this.endsAt,
    required this.status,
    required this.createdBy,
    double? fundingGoal,
    double? sponsoredAmount,
    double? latitude,
    double? longitude,
    double? geofenceMeters,
    int? volunteerCapacity,
    String? requiredSkills,
    String? checklist,
    String? evidenceInstructions,
    String? tags,
    bool? aiGenerated,
    this.coverImagePath,
    this.publishedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : fundingGoal = fundingGoal ?? 0.0,
       sponsoredAmount = sponsoredAmount ?? 0.0,
       latitude = latitude ?? 18.5204,
       longitude = longitude ?? 73.8567,
       geofenceMeters = geofenceMeters ?? 200.0,
       volunteerCapacity = volunteerCapacity ?? 10,
       requiredSkills = requiredSkills ?? '',
       checklist = checklist ?? '',
       evidenceInstructions = evidenceInstructions ?? '',
       tags = tags ?? '',
       aiGenerated = aiGenerated ?? false,
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory Campaign({
    int? id,
    required int organizationId,
    required String name,
    required String description,
    required String locationName,
    required DateTime startsAt,
    DateTime? endsAt,
    required _i4m9p8sf.CampaignStatus status,
    required _is.UuidValue createdBy,
    double? fundingGoal,
    double? sponsoredAmount,
    double? latitude,
    double? longitude,
    double? geofenceMeters,
    int? volunteerCapacity,
    String? requiredSkills,
    String? checklist,
    String? evidenceInstructions,
    String? tags,
    bool? aiGenerated,
    String? coverImagePath,
    DateTime? publishedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _CampaignImpl;

  factory Campaign.fromJson(Map<String, dynamic> jsonSerialization) {
    return Campaign(
      id: jsonSerialization['id'] as int?,
      organizationId: jsonSerialization['organizationId'] as int,
      name: jsonSerialization['name'] as String,
      description: jsonSerialization['description'] as String,
      locationName: jsonSerialization['locationName'] as String,
      startsAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['startsAt'],
      ),
      endsAt: jsonSerialization['endsAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['endsAt']),
      status: _i4m9p8sf.CampaignStatus.fromJson(
        (jsonSerialization['status'] as String),
      ),
      createdBy: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['createdBy'],
      ),
      fundingGoal: (jsonSerialization['fundingGoal'] as num?)?.toDouble(),
      sponsoredAmount: (jsonSerialization['sponsoredAmount'] as num?)
          ?.toDouble(),
      latitude: (jsonSerialization['latitude'] as num?)?.toDouble(),
      longitude: (jsonSerialization['longitude'] as num?)?.toDouble(),
      geofenceMeters: (jsonSerialization['geofenceMeters'] as num?)?.toDouble(),
      volunteerCapacity: jsonSerialization['volunteerCapacity'] as int?,
      requiredSkills: jsonSerialization['requiredSkills'] as String?,
      checklist: jsonSerialization['checklist'] as String?,
      evidenceInstructions:
          jsonSerialization['evidenceInstructions'] as String?,
      tags: jsonSerialization['tags'] as String?,
      aiGenerated: jsonSerialization['aiGenerated'] == null
          ? null
          : _is.BoolJsonExtension.fromJson(jsonSerialization['aiGenerated']),
      coverImagePath: jsonSerialization['coverImagePath'] as String?,
      publishedAt: jsonSerialization['publishedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(
              jsonSerialization['publishedAt'],
            ),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  static final t = CampaignTable();

  static const db = CampaignRepository._();

  @override
  int? id;

  int organizationId;

  String name;

  String description;

  String locationName;

  DateTime startsAt;

  DateTime? endsAt;

  _i4m9p8sf.CampaignStatus status;

  _is.UuidValue createdBy;

  double fundingGoal;

  double sponsoredAmount;

  double latitude;

  double longitude;

  double geofenceMeters;

  int volunteerCapacity;

  String requiredSkills;

  String checklist;

  String evidenceInstructions;

  String tags;

  bool aiGenerated;

  String? coverImagePath;

  DateTime? publishedAt;

  DateTime createdAt;

  DateTime updatedAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [Campaign]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  Campaign copyWith({
    int? id,
    int? organizationId,
    String? name,
    String? description,
    String? locationName,
    DateTime? startsAt,
    DateTime? endsAt,
    _i4m9p8sf.CampaignStatus? status,
    _is.UuidValue? createdBy,
    double? fundingGoal,
    double? sponsoredAmount,
    double? latitude,
    double? longitude,
    double? geofenceMeters,
    int? volunteerCapacity,
    String? requiredSkills,
    String? checklist,
    String? evidenceInstructions,
    String? tags,
    bool? aiGenerated,
    String? coverImagePath,
    DateTime? publishedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Campaign',
      if (id != null) 'id': id,
      'organizationId': organizationId,
      'name': name,
      'description': description,
      'locationName': locationName,
      'startsAt': startsAt.toJson(),
      if (endsAt != null) 'endsAt': endsAt?.toJson(),
      'status': status.toJson(),
      'createdBy': createdBy.toJson(),
      'fundingGoal': fundingGoal,
      'sponsoredAmount': sponsoredAmount,
      'latitude': latitude,
      'longitude': longitude,
      'geofenceMeters': geofenceMeters,
      'volunteerCapacity': volunteerCapacity,
      'requiredSkills': requiredSkills,
      'checklist': checklist,
      'evidenceInstructions': evidenceInstructions,
      'tags': tags,
      'aiGenerated': aiGenerated,
      if (coverImagePath != null) 'coverImagePath': coverImagePath,
      if (publishedAt != null) 'publishedAt': publishedAt?.toJson(),
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Campaign',
      if (id != null) 'id': id,
      'organizationId': organizationId,
      'name': name,
      'description': description,
      'locationName': locationName,
      'startsAt': startsAt.toJson(),
      if (endsAt != null) 'endsAt': endsAt?.toJson(),
      'status': status.toJson(),
      'createdBy': createdBy.toJson(),
      'fundingGoal': fundingGoal,
      'sponsoredAmount': sponsoredAmount,
      'latitude': latitude,
      'longitude': longitude,
      'geofenceMeters': geofenceMeters,
      'volunteerCapacity': volunteerCapacity,
      'requiredSkills': requiredSkills,
      'checklist': checklist,
      'evidenceInstructions': evidenceInstructions,
      'tags': tags,
      'aiGenerated': aiGenerated,
      if (coverImagePath != null) 'coverImagePath': coverImagePath,
      if (publishedAt != null) 'publishedAt': publishedAt?.toJson(),
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  static CampaignInclude include() {
    return CampaignInclude._();
  }

  static CampaignIncludeList includeList({
    _is.WhereExpressionBuilder<CampaignTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CampaignTable>? orderBy,
    _is.OrderByListBuilder<CampaignTable>? orderByList,
    CampaignInclude? include,
  }) {
    return CampaignIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Campaign.t),
      orderByList: orderByList?.call(Campaign.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CampaignImpl extends Campaign {
  _CampaignImpl({
    int? id,
    required int organizationId,
    required String name,
    required String description,
    required String locationName,
    required DateTime startsAt,
    DateTime? endsAt,
    required _i4m9p8sf.CampaignStatus status,
    required _is.UuidValue createdBy,
    double? fundingGoal,
    double? sponsoredAmount,
    double? latitude,
    double? longitude,
    double? geofenceMeters,
    int? volunteerCapacity,
    String? requiredSkills,
    String? checklist,
    String? evidenceInstructions,
    String? tags,
    bool? aiGenerated,
    String? coverImagePath,
    DateTime? publishedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         organizationId: organizationId,
         name: name,
         description: description,
         locationName: locationName,
         startsAt: startsAt,
         endsAt: endsAt,
         status: status,
         createdBy: createdBy,
         fundingGoal: fundingGoal,
         sponsoredAmount: sponsoredAmount,
         latitude: latitude,
         longitude: longitude,
         geofenceMeters: geofenceMeters,
         volunteerCapacity: volunteerCapacity,
         requiredSkills: requiredSkills,
         checklist: checklist,
         evidenceInstructions: evidenceInstructions,
         tags: tags,
         aiGenerated: aiGenerated,
         coverImagePath: coverImagePath,
         publishedAt: publishedAt,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [Campaign]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  Campaign copyWith({
    Object? id = _Undefined,
    int? organizationId,
    String? name,
    String? description,
    String? locationName,
    DateTime? startsAt,
    Object? endsAt = _Undefined,
    _i4m9p8sf.CampaignStatus? status,
    _is.UuidValue? createdBy,
    double? fundingGoal,
    double? sponsoredAmount,
    double? latitude,
    double? longitude,
    double? geofenceMeters,
    int? volunteerCapacity,
    String? requiredSkills,
    String? checklist,
    String? evidenceInstructions,
    String? tags,
    bool? aiGenerated,
    Object? coverImagePath = _Undefined,
    Object? publishedAt = _Undefined,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Campaign(
      id: id is int? ? id : this.id,
      organizationId: organizationId ?? this.organizationId,
      name: name ?? this.name,
      description: description ?? this.description,
      locationName: locationName ?? this.locationName,
      startsAt: startsAt ?? this.startsAt,
      endsAt: endsAt is DateTime? ? endsAt : this.endsAt,
      status: status ?? this.status,
      createdBy: createdBy ?? this.createdBy,
      fundingGoal: fundingGoal ?? this.fundingGoal,
      sponsoredAmount: sponsoredAmount ?? this.sponsoredAmount,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      geofenceMeters: geofenceMeters ?? this.geofenceMeters,
      volunteerCapacity: volunteerCapacity ?? this.volunteerCapacity,
      requiredSkills: requiredSkills ?? this.requiredSkills,
      checklist: checklist ?? this.checklist,
      evidenceInstructions: evidenceInstructions ?? this.evidenceInstructions,
      tags: tags ?? this.tags,
      aiGenerated: aiGenerated ?? this.aiGenerated,
      coverImagePath: coverImagePath is String?
          ? coverImagePath
          : this.coverImagePath,
      publishedAt: publishedAt is DateTime? ? publishedAt : this.publishedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class CampaignUpdateTable extends _is.UpdateTable<CampaignTable> {
  CampaignUpdateTable(super.table);

  _is.ColumnValue<int, int> organizationId(int value) => _is.ColumnValue(
    table.organizationId,
    value,
  );

  _is.ColumnValue<String, String> name(String value) => _is.ColumnValue(
    table.name,
    value,
  );

  _is.ColumnValue<String, String> description(String value) => _is.ColumnValue(
    table.description,
    value,
  );

  _is.ColumnValue<String, String> locationName(String value) => _is.ColumnValue(
    table.locationName,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> startsAt(DateTime value) =>
      _is.ColumnValue(
        table.startsAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> endsAt(DateTime? value) =>
      _is.ColumnValue(
        table.endsAt,
        value,
      );

  _is.ColumnValue<_i4m9p8sf.CampaignStatus, _i4m9p8sf.CampaignStatus> status(
    _i4m9p8sf.CampaignStatus value,
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

  _is.ColumnValue<double, double> fundingGoal(double value) => _is.ColumnValue(
    table.fundingGoal,
    value,
  );

  _is.ColumnValue<double, double> sponsoredAmount(double value) =>
      _is.ColumnValue(
        table.sponsoredAmount,
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

  _is.ColumnValue<double, double> geofenceMeters(double value) =>
      _is.ColumnValue(
        table.geofenceMeters,
        value,
      );

  _is.ColumnValue<int, int> volunteerCapacity(int value) => _is.ColumnValue(
    table.volunteerCapacity,
    value,
  );

  _is.ColumnValue<String, String> requiredSkills(String value) =>
      _is.ColumnValue(
        table.requiredSkills,
        value,
      );

  _is.ColumnValue<String, String> checklist(String value) => _is.ColumnValue(
    table.checklist,
    value,
  );

  _is.ColumnValue<String, String> evidenceInstructions(String value) =>
      _is.ColumnValue(
        table.evidenceInstructions,
        value,
      );

  _is.ColumnValue<String, String> tags(String value) => _is.ColumnValue(
    table.tags,
    value,
  );

  _is.ColumnValue<bool, bool> aiGenerated(bool value) => _is.ColumnValue(
    table.aiGenerated,
    value,
  );

  _is.ColumnValue<String, String> coverImagePath(String? value) =>
      _is.ColumnValue(
        table.coverImagePath,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> publishedAt(DateTime? value) =>
      _is.ColumnValue(
        table.publishedAt,
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

class CampaignTable extends _is.Table<int?> {
  CampaignTable({super.tableRelation})
    : super(tableName: 'fieldnote_campaign') {
    updateTable = CampaignUpdateTable(this);
    organizationId = _is.ColumnInt(
      'organizationId',
      this,
    );
    name = _is.ColumnString(
      'name',
      this,
    );
    description = _is.ColumnString(
      'description',
      this,
    );
    locationName = _is.ColumnString(
      'locationName',
      this,
    );
    startsAt = _is.ColumnDateTime(
      'startsAt',
      this,
    );
    endsAt = _is.ColumnDateTime(
      'endsAt',
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
    fundingGoal = _is.ColumnDouble(
      'fundingGoal',
      this,
      hasDefault: true,
    );
    sponsoredAmount = _is.ColumnDouble(
      'sponsoredAmount',
      this,
      hasDefault: true,
    );
    latitude = _is.ColumnDouble(
      'latitude',
      this,
      hasDefault: true,
    );
    longitude = _is.ColumnDouble(
      'longitude',
      this,
      hasDefault: true,
    );
    geofenceMeters = _is.ColumnDouble(
      'geofenceMeters',
      this,
      hasDefault: true,
    );
    volunteerCapacity = _is.ColumnInt(
      'volunteerCapacity',
      this,
      hasDefault: true,
    );
    requiredSkills = _is.ColumnString(
      'requiredSkills',
      this,
      hasDefault: true,
    );
    checklist = _is.ColumnString(
      'checklist',
      this,
      hasDefault: true,
    );
    evidenceInstructions = _is.ColumnString(
      'evidenceInstructions',
      this,
      hasDefault: true,
    );
    tags = _is.ColumnString(
      'tags',
      this,
      hasDefault: true,
    );
    aiGenerated = _is.ColumnBool(
      'aiGenerated',
      this,
      hasDefault: true,
    );
    coverImagePath = _is.ColumnString(
      'coverImagePath',
      this,
    );
    publishedAt = _is.ColumnDateTime(
      'publishedAt',
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

  late final CampaignUpdateTable updateTable;

  late final _is.ColumnInt organizationId;

  late final _is.ColumnString name;

  late final _is.ColumnString description;

  late final _is.ColumnString locationName;

  late final _is.ColumnDateTime startsAt;

  late final _is.ColumnDateTime endsAt;

  late final _is.ColumnEnum<_i4m9p8sf.CampaignStatus> status;

  late final _is.ColumnUuid createdBy;

  late final _is.ColumnDouble fundingGoal;

  late final _is.ColumnDouble sponsoredAmount;

  late final _is.ColumnDouble latitude;

  late final _is.ColumnDouble longitude;

  late final _is.ColumnDouble geofenceMeters;

  late final _is.ColumnInt volunteerCapacity;

  late final _is.ColumnString requiredSkills;

  late final _is.ColumnString checklist;

  late final _is.ColumnString evidenceInstructions;

  late final _is.ColumnString tags;

  late final _is.ColumnBool aiGenerated;

  late final _is.ColumnString coverImagePath;

  late final _is.ColumnDateTime publishedAt;

  late final _is.ColumnDateTime createdAt;

  late final _is.ColumnDateTime updatedAt;

  @override
  List<_is.Column> get columns => [
    id,
    organizationId,
    name,
    description,
    locationName,
    startsAt,
    endsAt,
    status,
    createdBy,
    fundingGoal,
    sponsoredAmount,
    latitude,
    longitude,
    geofenceMeters,
    volunteerCapacity,
    requiredSkills,
    checklist,
    evidenceInstructions,
    tags,
    aiGenerated,
    coverImagePath,
    publishedAt,
    createdAt,
    updatedAt,
  ];
}

class CampaignInclude extends _is.IncludeObject {
  CampaignInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => Campaign.t;
}

class CampaignIncludeList extends _is.IncludeList {
  CampaignIncludeList._({
    _is.WhereExpressionBuilder<CampaignTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Campaign.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => Campaign.t;
}

class CampaignRepository {
  const CampaignRepository._();

  /// Returns a list of [Campaign]s matching the given query parameters.
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
  Future<List<Campaign>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CampaignTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CampaignTable>? orderBy,
    _is.OrderByListBuilder<CampaignTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<Campaign>(
      where: where?.call(Campaign.t),
      orderBy: orderBy?.call(Campaign.t),
      orderByList: orderByList?.call(Campaign.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [Campaign] matching the given query parameters.
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
  Future<Campaign?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CampaignTable>? where,
    int? offset,
    _is.OrderByBuilder<CampaignTable>? orderBy,
    _is.OrderByListBuilder<CampaignTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<Campaign>(
      where: where?.call(Campaign.t),
      orderBy: orderBy?.call(Campaign.t),
      orderByList: orderByList?.call(Campaign.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [Campaign] by its [id] or null if no such row exists.
  Future<Campaign?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<Campaign>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [Campaign]s in the list and returns the inserted rows.
  ///
  /// The returned [Campaign]s will have their `id` fields set.
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
  Future<List<Campaign>> insert(
    _is.DatabaseSession session,
    List<Campaign> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<Campaign>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [Campaign] and returns the inserted row.
  ///
  /// The returned [Campaign] will have its `id` field set.
  Future<Campaign> insertRow(
    _is.DatabaseSession session,
    Campaign row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<Campaign>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [Campaign]s in the list and returns the resulting rows.
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
  /// The returned [Campaign]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Campaign>> upsert(
    _is.DatabaseSession session,
    List<Campaign> rows, {
    required _is.ColumnSelections<CampaignTable> conflictColumns,
    _is.ColumnSelections<CampaignTable>? updateColumns,
    _is.WhereExpressionBuilder<CampaignTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<Campaign>(
      rows,
      conflictColumns: conflictColumns(Campaign.t),
      updateColumns: updateColumns?.call(Campaign.t),
      updateWhere: updateWhere?.call(Campaign.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [Campaign] and returns the resulting row.
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
  /// The returned [Campaign] will have its `id` field set.
  Future<Campaign?> upsertRow(
    _is.DatabaseSession session,
    Campaign row, {
    required _is.ColumnSelections<CampaignTable> conflictColumns,
    _is.ColumnSelections<CampaignTable>? updateColumns,
    _is.WhereExpressionBuilder<CampaignTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<Campaign>(
      row,
      conflictColumns: conflictColumns(Campaign.t),
      updateColumns: updateColumns?.call(Campaign.t),
      updateWhere: updateWhere?.call(Campaign.t),
      transaction: transaction,
    );
  }

  /// Updates all [Campaign]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Campaign>> update(
    _is.DatabaseSession session,
    List<Campaign> rows, {
    _is.ColumnSelections<CampaignTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<Campaign>(
      rows,
      columns: columns?.call(Campaign.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [Campaign]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Campaign> updateRow(
    _is.DatabaseSession session,
    Campaign row, {
    _is.ColumnSelections<CampaignTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<Campaign>(
      row,
      columns: columns?.call(Campaign.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Campaign] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<Campaign?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<CampaignUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<Campaign>(
      id,
      columnValues: columnValues(Campaign.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [Campaign]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Campaign>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<CampaignUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<CampaignTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CampaignTable>? orderBy,
    _is.OrderByListBuilder<CampaignTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<Campaign>(
      columnValues: columnValues(Campaign.t.updateTable),
      where: where(Campaign.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Campaign.t),
      orderByList: orderByList?.call(Campaign.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [Campaign]s in the list and returns the deleted rows.
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
  Future<List<Campaign>> delete(
    _is.DatabaseSession session,
    List<Campaign> rows, {
    _is.OrderByBuilder<CampaignTable>? orderBy,
    _is.OrderByListBuilder<CampaignTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<Campaign>(
      rows,
      orderBy: orderBy?.call(Campaign.t),
      orderByList: orderByList?.call(Campaign.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [Campaign].
  Future<Campaign> deleteRow(
    _is.DatabaseSession session,
    Campaign row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Campaign>(
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
  Future<List<Campaign>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CampaignTable> where,
    _is.OrderByBuilder<CampaignTable>? orderBy,
    _is.OrderByListBuilder<CampaignTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<Campaign>(
      where: where(Campaign.t),
      orderBy: orderBy?.call(Campaign.t),
      orderByList: orderByList?.call(Campaign.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CampaignTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<Campaign>(
      where: where?.call(Campaign.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [Campaign] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CampaignTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<Campaign>(
      where: where(Campaign.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
