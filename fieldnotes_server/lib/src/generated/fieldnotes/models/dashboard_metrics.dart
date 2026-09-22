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

abstract class DashboardMetrics
    implements _is.SerializableModel, _is.ProtocolSerialization {
  DashboardMetrics._({
    required this.campaignId,
    required this.expectedAssets,
    required this.observedAssets,
    required this.reviewedObservations,
    required this.pendingReview,
    required this.healthy,
    required this.stressed,
    required this.damaged,
    required this.dead,
    required this.missing,
    required this.uncertain,
    required this.openTasks,
    required this.completedTasks,
    required this.coveragePercent,
    required this.survivalPercent,
  });

  factory DashboardMetrics({
    required int campaignId,
    required int expectedAssets,
    required int observedAssets,
    required int reviewedObservations,
    required int pendingReview,
    required int healthy,
    required int stressed,
    required int damaged,
    required int dead,
    required int missing,
    required int uncertain,
    required int openTasks,
    required int completedTasks,
    required double coveragePercent,
    required double survivalPercent,
  }) = _DashboardMetricsImpl;

  factory DashboardMetrics.fromJson(Map<String, dynamic> jsonSerialization) {
    return DashboardMetrics(
      campaignId: jsonSerialization['campaignId'] as int,
      expectedAssets: jsonSerialization['expectedAssets'] as int,
      observedAssets: jsonSerialization['observedAssets'] as int,
      reviewedObservations: jsonSerialization['reviewedObservations'] as int,
      pendingReview: jsonSerialization['pendingReview'] as int,
      healthy: jsonSerialization['healthy'] as int,
      stressed: jsonSerialization['stressed'] as int,
      damaged: jsonSerialization['damaged'] as int,
      dead: jsonSerialization['dead'] as int,
      missing: jsonSerialization['missing'] as int,
      uncertain: jsonSerialization['uncertain'] as int,
      openTasks: jsonSerialization['openTasks'] as int,
      completedTasks: jsonSerialization['completedTasks'] as int,
      coveragePercent: (jsonSerialization['coveragePercent'] as num).toDouble(),
      survivalPercent: (jsonSerialization['survivalPercent'] as num).toDouble(),
    );
  }

  int campaignId;

  int expectedAssets;

  int observedAssets;

  int reviewedObservations;

  int pendingReview;

  int healthy;

  int stressed;

  int damaged;

  int dead;

  int missing;

  int uncertain;

  int openTasks;

  int completedTasks;

  double coveragePercent;

  double survivalPercent;

  /// Returns a shallow copy of this [DashboardMetrics]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  DashboardMetrics copyWith({
    int? campaignId,
    int? expectedAssets,
    int? observedAssets,
    int? reviewedObservations,
    int? pendingReview,
    int? healthy,
    int? stressed,
    int? damaged,
    int? dead,
    int? missing,
    int? uncertain,
    int? openTasks,
    int? completedTasks,
    double? coveragePercent,
    double? survivalPercent,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'DashboardMetrics',
      'campaignId': campaignId,
      'expectedAssets': expectedAssets,
      'observedAssets': observedAssets,
      'reviewedObservations': reviewedObservations,
      'pendingReview': pendingReview,
      'healthy': healthy,
      'stressed': stressed,
      'damaged': damaged,
      'dead': dead,
      'missing': missing,
      'uncertain': uncertain,
      'openTasks': openTasks,
      'completedTasks': completedTasks,
      'coveragePercent': coveragePercent,
      'survivalPercent': survivalPercent,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'DashboardMetrics',
      'campaignId': campaignId,
      'expectedAssets': expectedAssets,
      'observedAssets': observedAssets,
      'reviewedObservations': reviewedObservations,
      'pendingReview': pendingReview,
      'healthy': healthy,
      'stressed': stressed,
      'damaged': damaged,
      'dead': dead,
      'missing': missing,
      'uncertain': uncertain,
      'openTasks': openTasks,
      'completedTasks': completedTasks,
      'coveragePercent': coveragePercent,
      'survivalPercent': survivalPercent,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _DashboardMetricsImpl extends DashboardMetrics {
  _DashboardMetricsImpl({
    required int campaignId,
    required int expectedAssets,
    required int observedAssets,
    required int reviewedObservations,
    required int pendingReview,
    required int healthy,
    required int stressed,
    required int damaged,
    required int dead,
    required int missing,
    required int uncertain,
    required int openTasks,
    required int completedTasks,
    required double coveragePercent,
    required double survivalPercent,
  }) : super._(
         campaignId: campaignId,
         expectedAssets: expectedAssets,
         observedAssets: observedAssets,
         reviewedObservations: reviewedObservations,
         pendingReview: pendingReview,
         healthy: healthy,
         stressed: stressed,
         damaged: damaged,
         dead: dead,
         missing: missing,
         uncertain: uncertain,
         openTasks: openTasks,
         completedTasks: completedTasks,
         coveragePercent: coveragePercent,
         survivalPercent: survivalPercent,
       );

  /// Returns a shallow copy of this [DashboardMetrics]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  DashboardMetrics copyWith({
    int? campaignId,
    int? expectedAssets,
    int? observedAssets,
    int? reviewedObservations,
    int? pendingReview,
    int? healthy,
    int? stressed,
    int? damaged,
    int? dead,
    int? missing,
    int? uncertain,
    int? openTasks,
    int? completedTasks,
    double? coveragePercent,
    double? survivalPercent,
  }) {
    return DashboardMetrics(
      campaignId: campaignId ?? this.campaignId,
      expectedAssets: expectedAssets ?? this.expectedAssets,
      observedAssets: observedAssets ?? this.observedAssets,
      reviewedObservations: reviewedObservations ?? this.reviewedObservations,
      pendingReview: pendingReview ?? this.pendingReview,
      healthy: healthy ?? this.healthy,
      stressed: stressed ?? this.stressed,
      damaged: damaged ?? this.damaged,
      dead: dead ?? this.dead,
      missing: missing ?? this.missing,
      uncertain: uncertain ?? this.uncertain,
      openTasks: openTasks ?? this.openTasks,
      completedTasks: completedTasks ?? this.completedTasks,
      coveragePercent: coveragePercent ?? this.coveragePercent,
      survivalPercent: survivalPercent ?? this.survivalPercent,
    );
  }
}
