import 'dart:math' as math;

import 'package:fieldnotes_client/fieldnotes_client.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../data/repositories/fieldnote_repository.dart';
import '../../../l10n/l10n.dart';
import '../../core/fieldnote_map.dart';
import '../../core/fieldnote_theme.dart';
import '../../core/in_app_maps.dart';
import '../../core/widgets.dart';

/// The sponsor's live proof map for one campaign.
///
/// Every check-in and every piece of evidence is already stored with
/// coordinates, an accuracy figure, and a location-integrity verdict; until
/// now a sponsor only ever saw those as a text badge. Drawing them against the
/// published geofence is the most direct answer to "did this work actually
/// happen where it was funded to happen?".
class CampaignProofMap extends StatefulWidget {
  const CampaignProofMap({
    super.key,
    required this.repository,
    required this.campaign,
    required this.refreshToken,
  });

  final FieldnoteRepository repository;
  final Campaign campaign;

  /// Any change reloads the pins. Wired to the live update stream so a new
  /// check-in appears without a manual refresh.
  final Object? refreshToken;

  @override
  State<CampaignProofMap> createState() => _CampaignProofMapState();
}

class _CampaignProofMapState extends State<CampaignProofMap> {
  CampaignMapOverview? _overview;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(CampaignProofMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshToken != widget.refreshToken ||
        oldWidget.campaign.id != widget.campaign.id) {
      _load();
    }
  }

  Future<void> _load() async {
    final id = widget.campaign.id;
    if (id == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final overview = await widget.repository.campaignMap(id);
      if (mounted) setState(() => _overview = overview);
    } on FieldnoteException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } on Object {
      if (mounted) {
        setState(() => _error = context.l10n.sponsorCampaignMapLoadFailed);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final overview = _overview;
    final campaignPoint = LatLng(
      widget.campaign.latitude,
      widget.campaign.longitude,
    );
    if (_error != null) {
      return MapUnavailableNotice(message: _error);
    }
    final pins = overview?.pins ?? const <CampaignMapPin>[];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.sponsorCampaignMapTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            if (_loading)
              const SizedBox.square(
                dimension: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
          ],
        ),
        const SizedBox(height: FieldnoteSpacing.sm),
        FieldnoteMap(
          target: campaignPoint,
          zoom: zoomForRadius(widget.campaign.geofenceMeters),
          height: 300,
          semanticLabel: l10n.sponsorCampaignMapSemantics,
          fitBounds: [
            campaignPoint,
            for (final pin in pins) LatLng(pin.latitude, pin.longitude),
          ],
          markers: {
            Marker(
              markerId: const MarkerId('campaign'),
              position: campaignPoint,
              icon: BitmapDescriptor.defaultMarkerWithHue(
                FieldnoteMapPalette.campaign,
              ),
              infoWindow: InfoWindow(
                title: widget.campaign.name,
                snippet: widget.campaign.locationName,
              ),
            ),
            for (final pin in pins)
              Marker(
                markerId: MarkerId('${pin.kind}-${pin.participationId}'),
                position: LatLng(pin.latitude, pin.longitude),
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  pin.kind == 'evidence' && !pin.isDemo
                      ? FieldnoteMapPalette.evidence
                      : FieldnoteMapPalette.forIntegrity(
                          pin.integrityStatus,
                          isDemo: pin.isDemo,
                        ),
                ),
                infoWindow: InfoWindow(
                  title: pin.isDemo
                      ? pin.kind == 'evidence'
                            ? l10n.sponsorCampaignMapPinUnverifiedEvidence
                            : l10n.sponsorCampaignMapPinUnverifiedCheckIn
                      : pin.kind == 'evidence'
                      ? l10n.sponsorCampaignMapPinEvidence
                      : l10n.sponsorCampaignMapPinCheckIn,
                  snippet: l10n.sponsorCampaignMapPinSnippet(
                    pin.distanceMeters.round(),
                    pin.accuracyMeters.round(),
                  ),
                ),
              ),
          },
          circles: {
            radiusCircle(
              id: 'geofence',
              center: campaignPoint,
              radiusMeters: widget.campaign.geofenceMeters,
            ),
            for (final pin in pins)
              if (pin.accuracyMeters > 0)
                radiusCircle(
                  id: 'accuracy-${pin.kind}-${pin.participationId}',
                  center: LatLng(pin.latitude, pin.longitude),
                  radiusMeters: pin.accuracyMeters,
                  color: pin.isDemo
                      ? FieldnoteColors.clay
                      : FieldnoteColors.moss,
                  strokeWidth: 1,
                ),
          },
          fallback: MapUnavailableNotice(
            message: l10n.sponsorCampaignMapFallback(
              pins.length,
              widget.campaign.geofenceMeters.round(),
            ),
          ),
        ),
        const SizedBox(height: FieldnoteSpacing.sm),
        MapLegend(
          entries: [
            (
              color: FieldnoteColors.forest,
              label: l10n.sponsorCampaignMapLegendCampaign,
            ),
            (
              color: const Color(0xFF8E5BD4),
              label: l10n.sponsorCampaignMapLegendEvidence,
            ),
            (
              color: FieldnoteColors.clay,
              label: l10n.sponsorCampaignMapLegendUnverified,
            ),
          ],
        ),
        if (overview != null) ...[
          const SizedBox(height: FieldnoteSpacing.sm),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              StatusPill(
                label: l10n.sponsorCampaignMapJoinedCount(overview.joinedCount),
                color: context.fieldnoteColors.moss,
                icon: Icons.how_to_reg_outlined,
              ),
              StatusPill(
                label: l10n.sponsorCampaignMapCheckedInCount(
                  overview.checkedInCount,
                ),
                color: context.fieldnoteColors.forest,
                icon: Icons.gps_fixed,
              ),
              StatusPill(
                label: l10n.sponsorCampaignMapCompletedCount(
                  overview.completedCount,
                ),
                color: context.fieldnoteColors.forest,
                icon: Icons.verified_outlined,
              ),
              if (overview.demoCount > 0)
                StatusPill(
                  label: l10n.sponsorCampaignMapUnverifiedCount(
                    overview.demoCount,
                  ),
                  color: context.fieldnoteColors.clay,
                  icon: Icons.science_outlined,
                ),
            ],
          ),
          if (overview.demoCount > 0) ...[
            const SizedBox(height: FieldnoteSpacing.xs),
            Text(
              l10n.sponsorCampaignMapLegacyNote,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
        const SizedBox(height: FieldnoteSpacing.sm),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () => Navigator.of(context).push<void>(
              MaterialPageRoute(
                builder: (_) => PlaceMapScreen(
                  title: widget.campaign.locationName,
                  latitude: widget.campaign.latitude,
                  longitude: widget.campaign.longitude,
                  geofenceMeters: widget.campaign.geofenceMeters,
                ),
              ),
            ),
            icon: const Icon(Icons.map_outlined, size: 18),
            label: Text(l10n.sponsorCampaignMapViewPin),
          ),
        ),
      ],
    );
  }
}

/// The provenance of a single piece of evidence, shown when a sponsor taps an
/// evidence tile.
///
/// This is the trust surface the app already claimed in its Trust Center but
/// could only assert in prose: the evidence pin, the GPS accuracy it was
/// captured with, and the geofence it had to fall inside.
class EvidenceProvenanceSheet extends StatelessWidget {
  const EvidenceProvenanceSheet({
    super.key,
    required this.evidence,
    required this.campaign,
    this.reviewPanel,
  });

  final CompletionEvidence evidence;
  final Campaign campaign;

  /// Sponsor approve/reject controls, shown for the campaign creator.
  final Widget? reviewPanel;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final evidencePoint = LatLng(evidence.latitude, evidence.longitude);
    final campaignPoint = LatLng(campaign.latitude, campaign.longitude);
    final distance = _distanceMeters(
      evidence.latitude,
      evidence.longitude,
      campaign.latitude,
      campaign.longitude,
    );
    return SafeArea(
      child: SingleChildScrollView(
        padding: FieldnoteSpacing.sheetPadding(context),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeading(
              eyebrow: l10n.sponsorCampaignMapProvenanceEyebrow,
              title: l10n.sponsorCampaignMapProvenanceTitle,
              description: evidence.confirmedSummary,
            ),
            const SizedBox(height: FieldnoteSpacing.md),
            FieldnoteMap(
              target: evidencePoint,
              zoom: zoomForRadius(campaign.geofenceMeters),
              height: 240,
              interactive: false,
              semanticLabel: l10n.sponsorCampaignMapProvenanceSemantics,
              fitBounds: [evidencePoint, campaignPoint],
              markers: {
                Marker(
                  markerId: const MarkerId('campaign'),
                  position: campaignPoint,
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    FieldnoteMapPalette.campaign,
                  ),
                  infoWindow: InfoWindow(title: campaign.locationName),
                ),
                Marker(
                  markerId: const MarkerId('evidence'),
                  position: evidencePoint,
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    evidence.locationIsDemo
                        ? FieldnoteMapPalette.demo
                        : FieldnoteMapPalette.evidence,
                  ),
                ),
              },
              circles: {
                radiusCircle(
                  id: 'geofence',
                  center: campaignPoint,
                  radiusMeters: campaign.geofenceMeters,
                ),
                radiusCircle(
                  id: 'accuracy',
                  center: evidencePoint,
                  radiusMeters: evidence.locationAccuracyMeters,
                  color: evidence.locationIsDemo
                      ? FieldnoteColors.clay
                      : FieldnoteColors.moss,
                  strokeWidth: 1,
                ),
              },
              fallback: MapUnavailableNotice(
                message: l10n.sponsorCampaignMapProvenanceFallback(
                  distance.round(),
                  evidence.locationAccuracyMeters.round(),
                ),
              ),
            ),
            const SizedBox(height: FieldnoteSpacing.md),
            StatusPill(
              label: evidence.locationIsDemo
                  ? l10n.sponsorCampaignMapLegacyLocation
                  : l10n.sponsorCampaignMapLocationIntegrity(
                      evidence.locationIntegrityStatus,
                    ),
              color: evidence.locationIsDemo
                  ? context.fieldnoteColors.clay
                  : context.fieldnoteColors.forest,
              icon: evidence.locationIsDemo
                  ? Icons.science_outlined
                  : Icons.gps_fixed,
            ),
            const SizedBox(height: FieldnoteSpacing.md),
            _fact(
              context,
              Icons.straighten,
              l10n.sponsorCampaignMapDistanceFact(
                distance.round(),
                campaign.geofenceMeters.round(),
              ),
            ),
            _fact(
              context,
              Icons.gps_fixed,
              l10n.sponsorCampaignMapAccuracyFact(
                evidence.locationAccuracyMeters.round(),
              ),
            ),
            _fact(
              context,
              Icons.schedule,
              DateFormat.MMMEd(
                context.localeTag,
              ).add_jm().format(evidence.submittedAt.toLocal()),
            ),
            const SizedBox(height: FieldnoteSpacing.sm),
            Text(
              l10n.sponsorCampaignMapServerChecks,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: FieldnoteSpacing.xs),
            ...evidence.locationIntegrityReasons
                .split('|')
                .map((reason) => reason.trim())
                .where((reason) => reason.isNotEmpty)
                .map(
                  (reason) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 17,
                          color: context.fieldnoteColors.moss,
                        ),
                        const SizedBox(width: FieldnoteSpacing.xs),
                        Expanded(child: Text(reason)),
                      ],
                    ),
                  ),
                ),
            const SizedBox(height: FieldnoteSpacing.md),
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).push<void>(
                MaterialPageRoute(
                  builder: (_) => PlaceMapScreen(
                    title: l10n.sponsorCampaignMapEvidenceLocation,
                    latitude: evidence.latitude,
                    longitude: evidence.longitude,
                  ),
                ),
              ),
              icon: const Icon(Icons.map_outlined),
              label: Text(l10n.sponsorCampaignMapViewEvidence),
            ),
            if (reviewPanel != null) ...[
              const Divider(height: 32),
              reviewPanel!,
            ],
          ],
        ),
      ),
    );
  }

  Widget _fact(BuildContext context, IconData icon, String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: context.fieldnoteColors.moss),
        const SizedBox(width: FieldnoteSpacing.xs),
        Expanded(child: Text(text)),
      ],
    ),
  );
}

/// Haversine distance, matching the server's own geofence arithmetic so the
/// figure a sponsor reads here is the one the server enforced.
double _distanceMeters(double lat1, double lon1, double lat2, double lon2) {
  const radius = 6371000.0;
  double toRadians(double degrees) => degrees * math.pi / 180;
  final phi1 = toRadians(lat1);
  final phi2 = toRadians(lat2);
  final sinPhi = math.sin(toRadians(lat2 - lat1) / 2);
  final sinLambda = math.sin(toRadians(lon2 - lon1) / 2);
  final a =
      sinPhi * sinPhi + math.cos(phi1) * math.cos(phi2) * sinLambda * sinLambda;
  return radius * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
}
