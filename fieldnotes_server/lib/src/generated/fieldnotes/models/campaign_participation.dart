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
import '../../fieldnotes/models/participation_status.dart' as _ie4rmtud;

abstract class CampaignParticipation
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  CampaignParticipation._({
    this.id,
    required this.campaignId,
    required this.volunteerAuthUserId,
    required this.status,
    int? confirmedRevision,
    DateTime? joinedAt,
    this.checkedInAt,
    this.completedAt,
    this.checkInLatitude,
    this.checkInLongitude,
    this.checkInAccuracyMeters,
    this.locationIntegrityStatus,
    this.locationIntegrityReasons,
    bool? locationIsDemo,
    this.leftAt,
    this.resolvedAt,
    this.evidenceUploadPath,
    this.aiAnalyzedAt,
  }) : confirmedRevision = confirmedRevision ?? 0,
       joinedAt = joinedAt ?? DateTime.now(),
       locationIsDemo = locationIsDemo ?? false;

  factory CampaignParticipation({
    int? id,
    required int campaignId,
    required _is.UuidValue volunteerAuthUserId,
    required _ie4rmtud.ParticipationStatus status,
    int? confirmedRevision,
    DateTime? joinedAt,
    DateTime? checkedInAt,
    DateTime? completedAt,
    double? checkInLatitude,
    double? checkInLongitude,
    double? checkInAccuracyMeters,
    String? locationIntegrityStatus,
    String? locationIntegrityReasons,
    bool? locationIsDemo,
    DateTime? leftAt,
    DateTime? resolvedAt,
    String? evidenceUploadPath,
    DateTime? aiAnalyzedAt,
  }) = _CampaignParticipationImpl;

  factory CampaignParticipation.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CampaignParticipation(
      id: jsonSerialization['id'] as int?,
      campaignId: jsonSerialization['campaignId'] as int,
      volunteerAuthUserId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['volunteerAuthUserId'],
      ),
      status: _ie4rmtud.ParticipationStatus.fromJson(
        (jsonSerialization['status'] as String),
      ),
      confirmedRevision: jsonSerialization['confirmedRevision'] as int?,
      joinedAt: jsonSerialization['joinedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['joinedAt']),
      checkedInAt: jsonSerialization['checkedInAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(
              jsonSerialization['checkedInAt'],
            ),
      completedAt: jsonSerialization['completedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(
              jsonSerialization['completedAt'],
            ),
      checkInLatitude: (jsonSerialization['checkInLatitude'] as num?)
          ?.toDouble(),
      checkInLongitude: (jsonSerialization['checkInLongitude'] as num?)
          ?.toDouble(),
      checkInAccuracyMeters:
          (jsonSerialization['checkInAccuracyMeters'] as num?)?.toDouble(),
      locationIntegrityStatus:
          jsonSerialization['locationIntegrityStatus'] as String?,
      locationIntegrityReasons:
          jsonSerialization['locationIntegrityReasons'] as String?,
      locationIsDemo: jsonSerialization['locationIsDemo'] == null
          ? null
          : _is.BoolJsonExtension.fromJson(jsonSerialization['locationIsDemo']),
      leftAt: jsonSerialization['leftAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['leftAt']),
      resolvedAt: jsonSerialization['resolvedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['resolvedAt']),
      evidenceUploadPath: jsonSerialization['evidenceUploadPath'] as String?,
      aiAnalyzedAt: jsonSerialization['aiAnalyzedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(
              jsonSerialization['aiAnalyzedAt'],
            ),
    );
  }

  static final t = CampaignParticipationTable();

  static const db = CampaignParticipationRepository._();

  @override
  int? id;

  int campaignId;

  _is.UuidValue volunteerAuthUserId;

  _ie4rmtud.ParticipationStatus status;

  int confirmedRevision;

  DateTime joinedAt;

  DateTime? checkedInAt;

  DateTime? completedAt;

  double? checkInLatitude;

  double? checkInLongitude;

  double? checkInAccuracyMeters;

  String? locationIntegrityStatus;

  String? locationIntegrityReasons;

  bool locationIsDemo;

  DateTime? leftAt;

  DateTime? resolvedAt;

  String? evidenceUploadPath;

  DateTime? aiAnalyzedAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [CampaignParticipation]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CampaignParticipation copyWith({
    int? id,
    int? campaignId,
    _is.UuidValue? volunteerAuthUserId,
    _ie4rmtud.ParticipationStatus? status,
    int? confirmedRevision,
    DateTime? joinedAt,
    DateTime? checkedInAt,
    DateTime? completedAt,
    double? checkInLatitude,
    double? checkInLongitude,
    double? checkInAccuracyMeters,
    String? locationIntegrityStatus,
    String? locationIntegrityReasons,
    bool? locationIsDemo,
    DateTime? leftAt,
    DateTime? resolvedAt,
    String? evidenceUploadPath,
    DateTime? aiAnalyzedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'CampaignParticipation',
      if (id != null) 'id': id,
      'campaignId': campaignId,
      'volunteerAuthUserId': volunteerAuthUserId.toJson(),
      'status': status.toJson(),
      'confirmedRevision': confirmedRevision,
      'joinedAt': joinedAt.toJson(),
      if (checkedInAt != null) 'checkedInAt': checkedInAt?.toJson(),
      if (completedAt != null) 'completedAt': completedAt?.toJson(),
      if (checkInLatitude != null) 'checkInLatitude': checkInLatitude,
      if (checkInLongitude != null) 'checkInLongitude': checkInLongitude,
      if (checkInAccuracyMeters != null)
        'checkInAccuracyMeters': checkInAccuracyMeters,
      if (locationIntegrityStatus != null)
        'locationIntegrityStatus': locationIntegrityStatus,
      if (locationIntegrityReasons != null)
        'locationIntegrityReasons': locationIntegrityReasons,
      'locationIsDemo': locationIsDemo,
      if (leftAt != null) 'leftAt': leftAt?.toJson(),
      if (resolvedAt != null) 'resolvedAt': resolvedAt?.toJson(),
      if (evidenceUploadPath != null) 'evidenceUploadPath': evidenceUploadPath,
      if (aiAnalyzedAt != null) 'aiAnalyzedAt': aiAnalyzedAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'CampaignParticipation',
      if (id != null) 'id': id,
      'campaignId': campaignId,
      'volunteerAuthUserId': volunteerAuthUserId.toJson(),
      'status': status.toJson(),
      'confirmedRevision': confirmedRevision,
      'joinedAt': joinedAt.toJson(),
      if (checkedInAt != null) 'checkedInAt': checkedInAt?.toJson(),
      if (completedAt != null) 'completedAt': completedAt?.toJson(),
      if (checkInLatitude != null) 'checkInLatitude': checkInLatitude,
      if (checkInLongitude != null) 'checkInLongitude': checkInLongitude,
      if (checkInAccuracyMeters != null)
        'checkInAccuracyMeters': checkInAccuracyMeters,
      if (locationIntegrityStatus != null)
        'locationIntegrityStatus': locationIntegrityStatus,
      if (locationIntegrityReasons != null)
        'locationIntegrityReasons': locationIntegrityReasons,
      'locationIsDemo': locationIsDemo,
      if (leftAt != null) 'leftAt': leftAt?.toJson(),
      if (resolvedAt != null) 'resolvedAt': resolvedAt?.toJson(),
      if (evidenceUploadPath != null) 'evidenceUploadPath': evidenceUploadPath,
      if (aiAnalyzedAt != null) 'aiAnalyzedAt': aiAnalyzedAt?.toJson(),
    };
  }

  static CampaignParticipationInclude include() {
    return CampaignParticipationInclude._();
  }

  static CampaignParticipationIncludeList includeList({
    _is.WhereExpressionBuilder<CampaignParticipationTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CampaignParticipationTable>? orderBy,
    _is.OrderByListBuilder<CampaignParticipationTable>? orderByList,
    CampaignParticipationInclude? include,
  }) {
    return CampaignParticipationIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CampaignParticipation.t),
      orderByList: orderByList?.call(CampaignParticipation.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CampaignParticipationImpl extends CampaignParticipation {
  _CampaignParticipationImpl({
    int? id,
    required int campaignId,
    required _is.UuidValue volunteerAuthUserId,
    required _ie4rmtud.ParticipationStatus status,
    int? confirmedRevision,
    DateTime? joinedAt,
    DateTime? checkedInAt,
    DateTime? completedAt,
    double? checkInLatitude,
    double? checkInLongitude,
    double? checkInAccuracyMeters,
    String? locationIntegrityStatus,
    String? locationIntegrityReasons,
    bool? locationIsDemo,
    DateTime? leftAt,
    DateTime? resolvedAt,
    String? evidenceUploadPath,
    DateTime? aiAnalyzedAt,
  }) : super._(
         id: id,
         campaignId: campaignId,
         volunteerAuthUserId: volunteerAuthUserId,
         status: status,
         confirmedRevision: confirmedRevision,
         joinedAt: joinedAt,
         checkedInAt: checkedInAt,
         completedAt: completedAt,
         checkInLatitude: checkInLatitude,
         checkInLongitude: checkInLongitude,
         checkInAccuracyMeters: checkInAccuracyMeters,
         locationIntegrityStatus: locationIntegrityStatus,
         locationIntegrityReasons: locationIntegrityReasons,
         locationIsDemo: locationIsDemo,
         leftAt: leftAt,
         resolvedAt: resolvedAt,
         evidenceUploadPath: evidenceUploadPath,
         aiAnalyzedAt: aiAnalyzedAt,
       );

  /// Returns a shallow copy of this [CampaignParticipation]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CampaignParticipation copyWith({
    Object? id = _Undefined,
    int? campaignId,
    _is.UuidValue? volunteerAuthUserId,
    _ie4rmtud.ParticipationStatus? status,
    int? confirmedRevision,
    DateTime? joinedAt,
    Object? checkedInAt = _Undefined,
    Object? completedAt = _Undefined,
    Object? checkInLatitude = _Undefined,
    Object? checkInLongitude = _Undefined,
    Object? checkInAccuracyMeters = _Undefined,
    Object? locationIntegrityStatus = _Undefined,
    Object? locationIntegrityReasons = _Undefined,
    bool? locationIsDemo,
    Object? leftAt = _Undefined,
    Object? resolvedAt = _Undefined,
    Object? evidenceUploadPath = _Undefined,
    Object? aiAnalyzedAt = _Undefined,
  }) {
    return CampaignParticipation(
      id: id is int? ? id : this.id,
      campaignId: campaignId ?? this.campaignId,
      volunteerAuthUserId: volunteerAuthUserId ?? this.volunteerAuthUserId,
      status: status ?? this.status,
      confirmedRevision: confirmedRevision ?? this.confirmedRevision,
      joinedAt: joinedAt ?? this.joinedAt,
      checkedInAt: checkedInAt is DateTime? ? checkedInAt : this.checkedInAt,
      completedAt: completedAt is DateTime? ? completedAt : this.completedAt,
      checkInLatitude: checkInLatitude is double?
          ? checkInLatitude
          : this.checkInLatitude,
      checkInLongitude: checkInLongitude is double?
          ? checkInLongitude
          : this.checkInLongitude,
      checkInAccuracyMeters: checkInAccuracyMeters is double?
          ? checkInAccuracyMeters
          : this.checkInAccuracyMeters,
      locationIntegrityStatus: locationIntegrityStatus is String?
          ? locationIntegrityStatus
          : this.locationIntegrityStatus,
      locationIntegrityReasons: locationIntegrityReasons is String?
          ? locationIntegrityReasons
          : this.locationIntegrityReasons,
      locationIsDemo: locationIsDemo ?? this.locationIsDemo,
      leftAt: leftAt is DateTime? ? leftAt : this.leftAt,
      resolvedAt: resolvedAt is DateTime? ? resolvedAt : this.resolvedAt,
      evidenceUploadPath: evidenceUploadPath is String?
          ? evidenceUploadPath
          : this.evidenceUploadPath,
      aiAnalyzedAt: aiAnalyzedAt is DateTime?
          ? aiAnalyzedAt
          : this.aiAnalyzedAt,
    );
  }
}

class CampaignParticipationUpdateTable
    extends _is.UpdateTable<CampaignParticipationTable> {
  CampaignParticipationUpdateTable(super.table);

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

  _is.ColumnValue<_ie4rmtud.ParticipationStatus, _ie4rmtud.ParticipationStatus>
  status(_ie4rmtud.ParticipationStatus value) => _is.ColumnValue(
    table.status,
    value,
  );

  _is.ColumnValue<int, int> confirmedRevision(int value) => _is.ColumnValue(
    table.confirmedRevision,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> joinedAt(DateTime value) =>
      _is.ColumnValue(
        table.joinedAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> checkedInAt(DateTime? value) =>
      _is.ColumnValue(
        table.checkedInAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> completedAt(DateTime? value) =>
      _is.ColumnValue(
        table.completedAt,
        value,
      );

  _is.ColumnValue<double, double> checkInLatitude(double? value) =>
      _is.ColumnValue(
        table.checkInLatitude,
        value,
      );

  _is.ColumnValue<double, double> checkInLongitude(double? value) =>
      _is.ColumnValue(
        table.checkInLongitude,
        value,
      );

  _is.ColumnValue<double, double> checkInAccuracyMeters(double? value) =>
      _is.ColumnValue(
        table.checkInAccuracyMeters,
        value,
      );

  _is.ColumnValue<String, String> locationIntegrityStatus(String? value) =>
      _is.ColumnValue(
        table.locationIntegrityStatus,
        value,
      );

  _is.ColumnValue<String, String> locationIntegrityReasons(String? value) =>
      _is.ColumnValue(
        table.locationIntegrityReasons,
        value,
      );

  _is.ColumnValue<bool, bool> locationIsDemo(bool value) => _is.ColumnValue(
    table.locationIsDemo,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> leftAt(DateTime? value) =>
      _is.ColumnValue(
        table.leftAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> resolvedAt(DateTime? value) =>
      _is.ColumnValue(
        table.resolvedAt,
        value,
      );

  _is.ColumnValue<String, String> evidenceUploadPath(String? value) =>
      _is.ColumnValue(
        table.evidenceUploadPath,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> aiAnalyzedAt(DateTime? value) =>
      _is.ColumnValue(
        table.aiAnalyzedAt,
        value,
      );
}

class CampaignParticipationTable extends _is.Table<int?> {
  CampaignParticipationTable({super.tableRelation})
    : super(tableName: 'fieldnote_campaign_participation') {
    updateTable = CampaignParticipationUpdateTable(this);
    campaignId = _is.ColumnInt(
      'campaignId',
      this,
    );
    volunteerAuthUserId = _is.ColumnUuid(
      'volunteerAuthUserId',
      this,
    );
    status = _is.ColumnEnum(
      'status',
      this,
      _is.EnumSerialization.byName,
    );
    confirmedRevision = _is.ColumnInt(
      'confirmedRevision',
      this,
      hasDefault: true,
    );
    joinedAt = _is.ColumnDateTime(
      'joinedAt',
      this,
      hasDefault: true,
    );
    checkedInAt = _is.ColumnDateTime(
      'checkedInAt',
      this,
    );
    completedAt = _is.ColumnDateTime(
      'completedAt',
      this,
    );
    checkInLatitude = _is.ColumnDouble(
      'checkInLatitude',
      this,
    );
    checkInLongitude = _is.ColumnDouble(
      'checkInLongitude',
      this,
    );
    checkInAccuracyMeters = _is.ColumnDouble(
      'checkInAccuracyMeters',
      this,
    );
    locationIntegrityStatus = _is.ColumnString(
      'locationIntegrityStatus',
      this,
    );
    locationIntegrityReasons = _is.ColumnString(
      'locationIntegrityReasons',
      this,
    );
    locationIsDemo = _is.ColumnBool(
      'locationIsDemo',
      this,
      hasDefault: true,
    );
    leftAt = _is.ColumnDateTime(
      'leftAt',
      this,
    );
    resolvedAt = _is.ColumnDateTime(
      'resolvedAt',
      this,
    );
    evidenceUploadPath = _is.ColumnString(
      'evidenceUploadPath',
      this,
    );
    aiAnalyzedAt = _is.ColumnDateTime(
      'aiAnalyzedAt',
      this,
    );
  }

  late final CampaignParticipationUpdateTable updateTable;

  late final _is.ColumnInt campaignId;

  late final _is.ColumnUuid volunteerAuthUserId;

  late final _is.ColumnEnum<_ie4rmtud.ParticipationStatus> status;

  late final _is.ColumnInt confirmedRevision;

  late final _is.ColumnDateTime joinedAt;

  late final _is.ColumnDateTime checkedInAt;

  late final _is.ColumnDateTime completedAt;

  late final _is.ColumnDouble checkInLatitude;

  late final _is.ColumnDouble checkInLongitude;

  late final _is.ColumnDouble checkInAccuracyMeters;

  late final _is.ColumnString locationIntegrityStatus;

  late final _is.ColumnString locationIntegrityReasons;

  late final _is.ColumnBool locationIsDemo;

  late final _is.ColumnDateTime leftAt;

  late final _is.ColumnDateTime resolvedAt;

  late final _is.ColumnString evidenceUploadPath;

  late final _is.ColumnDateTime aiAnalyzedAt;

  @override
  List<_is.Column> get columns => [
    id,
    campaignId,
    volunteerAuthUserId,
    status,
    confirmedRevision,
    joinedAt,
    checkedInAt,
    completedAt,
    checkInLatitude,
    checkInLongitude,
    checkInAccuracyMeters,
    locationIntegrityStatus,
    locationIntegrityReasons,
    locationIsDemo,
    leftAt,
    resolvedAt,
    evidenceUploadPath,
    aiAnalyzedAt,
  ];
}

class CampaignParticipationInclude extends _is.IncludeObject {
  CampaignParticipationInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => CampaignParticipation.t;
}

class CampaignParticipationIncludeList extends _is.IncludeList {
  CampaignParticipationIncludeList._({
    _is.WhereExpressionBuilder<CampaignParticipationTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(CampaignParticipation.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => CampaignParticipation.t;
}

class CampaignParticipationRepository {
  const CampaignParticipationRepository._();

  /// Returns a list of [CampaignParticipation]s matching the given query parameters.
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
  Future<List<CampaignParticipation>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CampaignParticipationTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CampaignParticipationTable>? orderBy,
    _is.OrderByListBuilder<CampaignParticipationTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<CampaignParticipation>(
      where: where?.call(CampaignParticipation.t),
      orderBy: orderBy?.call(CampaignParticipation.t),
      orderByList: orderByList?.call(CampaignParticipation.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [CampaignParticipation] matching the given query parameters.
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
  Future<CampaignParticipation?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CampaignParticipationTable>? where,
    int? offset,
    _is.OrderByBuilder<CampaignParticipationTable>? orderBy,
    _is.OrderByListBuilder<CampaignParticipationTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<CampaignParticipation>(
      where: where?.call(CampaignParticipation.t),
      orderBy: orderBy?.call(CampaignParticipation.t),
      orderByList: orderByList?.call(CampaignParticipation.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [CampaignParticipation] by its [id] or null if no such row exists.
  Future<CampaignParticipation?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<CampaignParticipation>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [CampaignParticipation]s in the list and returns the inserted rows.
  ///
  /// The returned [CampaignParticipation]s will have their `id` fields set.
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
  Future<List<CampaignParticipation>> insert(
    _is.DatabaseSession session,
    List<CampaignParticipation> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<CampaignParticipation>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [CampaignParticipation] and returns the inserted row.
  ///
  /// The returned [CampaignParticipation] will have its `id` field set.
  Future<CampaignParticipation> insertRow(
    _is.DatabaseSession session,
    CampaignParticipation row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<CampaignParticipation>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [CampaignParticipation]s in the list and returns the resulting rows.
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
  /// The returned [CampaignParticipation]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CampaignParticipation>> upsert(
    _is.DatabaseSession session,
    List<CampaignParticipation> rows, {
    required _is.ColumnSelections<CampaignParticipationTable> conflictColumns,
    _is.ColumnSelections<CampaignParticipationTable>? updateColumns,
    _is.WhereExpressionBuilder<CampaignParticipationTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<CampaignParticipation>(
      rows,
      conflictColumns: conflictColumns(CampaignParticipation.t),
      updateColumns: updateColumns?.call(CampaignParticipation.t),
      updateWhere: updateWhere?.call(CampaignParticipation.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [CampaignParticipation] and returns the resulting row.
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
  /// The returned [CampaignParticipation] will have its `id` field set.
  Future<CampaignParticipation?> upsertRow(
    _is.DatabaseSession session,
    CampaignParticipation row, {
    required _is.ColumnSelections<CampaignParticipationTable> conflictColumns,
    _is.ColumnSelections<CampaignParticipationTable>? updateColumns,
    _is.WhereExpressionBuilder<CampaignParticipationTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<CampaignParticipation>(
      row,
      conflictColumns: conflictColumns(CampaignParticipation.t),
      updateColumns: updateColumns?.call(CampaignParticipation.t),
      updateWhere: updateWhere?.call(CampaignParticipation.t),
      transaction: transaction,
    );
  }

  /// Updates all [CampaignParticipation]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CampaignParticipation>> update(
    _is.DatabaseSession session,
    List<CampaignParticipation> rows, {
    _is.ColumnSelections<CampaignParticipationTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<CampaignParticipation>(
      rows,
      columns: columns?.call(CampaignParticipation.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [CampaignParticipation]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<CampaignParticipation> updateRow(
    _is.DatabaseSession session,
    CampaignParticipation row, {
    _is.ColumnSelections<CampaignParticipationTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<CampaignParticipation>(
      row,
      columns: columns?.call(CampaignParticipation.t),
      transaction: transaction,
    );
  }

  /// Updates a single [CampaignParticipation] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<CampaignParticipation?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<CampaignParticipationUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<CampaignParticipation>(
      id,
      columnValues: columnValues(CampaignParticipation.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [CampaignParticipation]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CampaignParticipation>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<CampaignParticipationUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<CampaignParticipationTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CampaignParticipationTable>? orderBy,
    _is.OrderByListBuilder<CampaignParticipationTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<CampaignParticipation>(
      columnValues: columnValues(CampaignParticipation.t.updateTable),
      where: where(CampaignParticipation.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CampaignParticipation.t),
      orderByList: orderByList?.call(CampaignParticipation.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [CampaignParticipation]s in the list and returns the deleted rows.
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
  Future<List<CampaignParticipation>> delete(
    _is.DatabaseSession session,
    List<CampaignParticipation> rows, {
    _is.OrderByBuilder<CampaignParticipationTable>? orderBy,
    _is.OrderByListBuilder<CampaignParticipationTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<CampaignParticipation>(
      rows,
      orderBy: orderBy?.call(CampaignParticipation.t),
      orderByList: orderByList?.call(CampaignParticipation.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [CampaignParticipation].
  Future<CampaignParticipation> deleteRow(
    _is.DatabaseSession session,
    CampaignParticipation row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<CampaignParticipation>(
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
  Future<List<CampaignParticipation>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CampaignParticipationTable> where,
    _is.OrderByBuilder<CampaignParticipationTable>? orderBy,
    _is.OrderByListBuilder<CampaignParticipationTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<CampaignParticipation>(
      where: where(CampaignParticipation.t),
      orderBy: orderBy?.call(CampaignParticipation.t),
      orderByList: orderByList?.call(CampaignParticipation.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CampaignParticipationTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<CampaignParticipation>(
      where: where?.call(CampaignParticipation.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [CampaignParticipation] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CampaignParticipationTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<CampaignParticipation>(
      where: where(CampaignParticipation.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
