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
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import '../../fieldnotes/models/observation_condition.dart' as _iuuy06sg;
import '../../fieldnotes/models/review_outcome.dart' as _ibt01pur;

abstract class ReviewDecision
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
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
    required _isc.UuidValue reviewerAuthUserId,
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
      reviewerAuthUserId: _isc.UuidValueJsonExtension.fromJson(
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
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int observationId;

  _isc.UuidValue reviewerAuthUserId;

  _ibt01pur.ReviewOutcome outcome;

  _iuuy06sg.ObservationCondition previousCondition;

  _iuuy06sg.ObservationCondition finalCondition;

  String notes;

  DateTime createdAt;

  /// Returns a shallow copy of this [ReviewDecision]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  ReviewDecision copyWith({
    int? id,
    int? observationId,
    _isc.UuidValue? reviewerAuthUserId,
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

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ReviewDecisionImpl extends ReviewDecision {
  _ReviewDecisionImpl({
    int? id,
    required int observationId,
    required _isc.UuidValue reviewerAuthUserId,
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
  @_isc.useResult
  @override
  ReviewDecision copyWith({
    Object? id = _Undefined,
    int? observationId,
    _isc.UuidValue? reviewerAuthUserId,
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
