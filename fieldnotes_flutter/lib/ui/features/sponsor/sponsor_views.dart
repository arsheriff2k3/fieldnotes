import 'dart:async';
import 'dart:typed_data';

import 'package:fieldnotes_client/fieldnotes_client.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:record/record.dart';

import '../../../data/audio/wav_encoder.dart';
import '../../../data/repositories/fieldnote_repository.dart';
import '../../../data/services/device_location_service.dart';
import '../../../data/services/campaign_link_service.dart';
import '../../../l10n/l10n.dart';
import '../../core/error_messages.dart';
import '../../core/fieldnote_theme.dart';
import '../../core/location_picker.dart';
import '../../core/widgets.dart';
import '../shell/fieldnote_view_model.dart';
import 'campaign_map_view.dart';
import 'campaign_pin_picker.dart';
import 'payout_view.dart';
import 'campaign_readiness_view.dart';
import 'campaign_volunteer_reach_view.dart';
import 'campaign_post_dialog.dart';
import 'payment_history_view.dart';
import 'sponsor_checkout.dart';
import 'sponsor_formatting.dart';

class SponsorDiscoverView extends StatelessWidget {
  const SponsorDiscoverView({super.key, required this.viewModel});

  final FieldnoteViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              FieldnoteSpacing.pageGutter(context),
              FieldnoteSpacing.md,
              FieldnoteSpacing.pageGutter(context),
              10,
            ),
            child: SectionHeading(
              eyebrow: context.l10n.sponsorEyebrow,
              title: context.l10n.sponsorDiscoverTitle,
            ),
          ),
          FieldnoteSectionTabs(
            compact: true,
            tabs: [
              FieldnoteSectionTab(
                context.l10n.sponsorDiscoverTabAll,
                Icons.explore_outlined,
              ),
              FieldnoteSectionTab(
                context.l10n.sponsorDiscoverTabYours,
                Icons.folder_open_outlined,
              ),
              FieldnoteSectionTab(
                context.l10n.sponsorDiscoverTabCreate,
                Icons.add_circle_outline,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Expanded(
            child: TabBarView(
              children: [
                _allCampaigns(context),
                _yourCampaigns(context),
                _createCampaign(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _allCampaigns(BuildContext context) => RefreshIndicator(
    onRefresh: viewModel.refresh,
    child: FieldnotePageList(
      key: const PageStorageKey('sponsor-all-campaigns'),
      top: 12,
      children: [
        Text(
          context.l10n.sponsorDiscoverLocalCount(viewModel.campaigns.length),
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: context.fieldnoteColors.ink.withValues(alpha: .72),
          ),
        ),
        const SizedBox(height: 12),
        if (viewModel.campaigns.isEmpty)
          EmptyPanel(
            icon: Icons.explore_outlined,
            title: context.l10n.sponsorDiscoverEmptyTitle,
            message: context.l10n.sponsorDiscoverEmptyMessage,
          )
        else
          ResponsiveCardGrid(
            children: [
              for (final campaign in viewModel.campaigns)
                Builder(
                  builder: (context) {
                    final remaining = campaignRemainingPaise(campaign);
                    return CampaignCard(
                      campaign: campaign,
                      showFunding: true,
                      actionLabel: remaining > 0
                          ? context.l10n.sponsorDiscoverSponsorAction
                          : context.l10n.sponsorDiscoverFullyFunded,
                      onAction: remaining > 0
                          ? () => openSponsorCheckout(
                              context,
                              viewModel,
                              campaign,
                            )
                          : null,
                    );
                  },
                ),
            ],
          ),
      ],
    ),
  );

  Widget _yourCampaigns(BuildContext context) => RefreshIndicator(
    onRefresh: viewModel.refresh,
    child: FieldnotePageList(
      key: const PageStorageKey('sponsor-your-campaigns'),
      top: 12,
      children: [
        Text(
          context.l10n.sponsorDiscoverCreatedCount(
            viewModel.createdCampaigns.length,
          ),
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: context.fieldnoteColors.ink.withValues(alpha: .72),
          ),
        ),
        const SizedBox(height: 12),
        if (viewModel.createdCampaigns.isEmpty)
          SurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.campaign_outlined, size: 36),
                const SizedBox(height: 14),
                Text(
                  context.l10n.sponsorDiscoverNoCreatedTitle,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 6),
                Text(context.l10n.sponsorDiscoverNoCreatedMessage),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () => viewModel.selectSection(1),
                  icon: const Icon(Icons.add),
                  label: Text(context.l10n.sponsorDiscoverCreateAction),
                ),
              ],
            ),
          )
        else
          for (final campaign in viewModel.createdCampaigns) ...[
            _OwnedCampaignCard(
              campaign: campaign,
              impact: viewModel.impacts[campaign.id],
              onMap: () => Navigator.of(context).push<void>(
                MaterialPageRoute(
                  builder: (_) => CampaignVolunteerReachView(
                    campaign: campaign,
                    repository: viewModel.repository,
                  ),
                ),
              ),
              onShare: () => shareCampaign(context, campaign),
            ),
            const SizedBox(height: 12),
          ],
      ],
    ),
  );

  Widget _createCampaign(BuildContext context) => FieldnotePageList(
    top: 12,
    children: [
      SurfaceCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              Icons.auto_awesome_outlined,
              size: 38,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 10),
            Text(
              context.l10n.sponsorDiscoverStartTitle,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(context.l10n.sponsorDiscoverStartBody),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => viewModel.selectSection(1),
              icon: const Icon(Icons.add_circle_outline),
              label: Text(context.l10n.sponsorDiscoverOpenCreator),
            ),
          ],
        ),
      ),
    ],
  );
}

class SponsorVoiceActionController extends ChangeNotifier {
  Future<void> Function()? _onPressStart;
  Future<void> Function()? _onPressEnd;

  bool recording = false;
  bool starting = false;
  bool transcribing = false;
  bool thinking = false;

  bool get captureActive => recording || starting;
  bool get processing => transcribing || thinking;
  bool get canRecord => _onPressStart != null && !transcribing && !thinking;

  void attach({
    required Future<void> Function() onPressStart,
    required Future<void> Function() onPressEnd,
  }) {
    _onPressStart = onPressStart;
    _onPressEnd = onPressEnd;
  }

  void detach() {
    _onPressStart = null;
    _onPressEnd = null;
  }

  void update({
    required bool recording,
    required bool starting,
    required bool transcribing,
    required bool thinking,
  }) {
    if (this.recording == recording &&
        this.starting == starting &&
        this.transcribing == transcribing &&
        this.thinking == thinking) {
      return;
    }
    this.recording = recording;
    this.starting = starting;
    this.transcribing = transcribing;
    this.thinking = thinking;
    notifyListeners();
  }

  Future<void> pressStart() async {
    if (!canRecord) return;
    await _onPressStart?.call();
  }

  Future<void> pressEnd() async {
    await _onPressEnd?.call();
  }
}

class _OwnedCampaignCard extends StatelessWidget {
  const _OwnedCampaignCard({
    required this.campaign,
    required this.impact,
    required this.onMap,
    required this.onShare,
  });

  final Campaign campaign;
  final ImpactSummary? impact;
  final VoidCallback onMap;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final style = campaignPhaseStyle(campaignPhase(campaign), l10n: l10n);
    final progress = campaignFundingProgress(campaign);
    final localeTag = context.localeTag;
    final refunded = campaignRefundedPaise(campaign);
    return Container(
      decoration: BoxDecoration(
        color: context.fieldnoteColors.paper,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: context.fieldnoteColors.forest.withValues(alpha: .10),
        ),
        boxShadow: [
          BoxShadow(
            color: context.fieldnoteColors.ink.withValues(alpha: .045),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 5,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    context.fieldnoteColors.forest,
                    context.fieldnoteColors.moss,
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    StatusPill(
                      label: style.label,
                      color: style.color,
                      icon: style.icon,
                    ),
                    const Spacer(),
                    Text(
                      l10n.sponsorOwnedCampaignId('${campaign.id ?? ''}'),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: context.fieldnoteColors.moss,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  campaign.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: context.fieldnoteColors.ink,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                _infoLine(
                  context,
                  Icons.event_outlined,
                  DateFormat.MMMEd(
                    localeTag,
                  ).add_jm().format(campaign.startsAt.toLocal()),
                ),
                const SizedBox(height: 8),
                _infoLine(context, Icons.place_outlined, campaign.locationName),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: context.fieldnoteColors.mist.withValues(alpha: .6),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.groups_outlined, size: 18),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              impact == null
                                  ? l10n.sponsorCampaignPlaces(
                                      campaign.volunteerCapacity,
                                    )
                                  : l10n.sponsorOwnedJoined(
                                      impact!.joinedVolunteers,
                                      campaign.volunteerCapacity,
                                    ),
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                          ),
                          Text(
                            l10n.sponsorOwnedFundingRatio(
                              formatPaiseCompact(
                                campaignSponsoredPaise(campaign),
                                localeTag: localeTag,
                              ),
                              formatPaiseCompact(
                                campaignGoalPaise(campaign),
                                localeTag: localeTag,
                              ),
                            ),
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                        ],
                      ),
                      if (refunded > 0) ...[
                        const SizedBox(height: 6),
                        Align(
                          alignment: AlignmentDirectional.centerEnd,
                          child: Text(
                            l10n.sponsorAmountRefunded(
                              formatPaiseCompact(
                                refunded,
                                localeTag: localeTag,
                              ),
                            ),
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                        ),
                      ],
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 5,
                          backgroundColor: context.fieldnoteColors.paper,
                          color: context.fieldnoteColors.moss,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final mapButton = FilledButton.icon(
                      onPressed: onMap,
                      icon: const Icon(Icons.map_outlined),
                      label: Text(l10n.sponsorOwnedVolunteerMap),
                    );
                    final shareButton = OutlinedButton.icon(
                      onPressed: onShare,
                      icon: const Icon(Icons.share_outlined),
                      label: Text(l10n.sponsorActionShare),
                    );
                    if (constraints.maxWidth < 300) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          mapButton,
                          const SizedBox(height: 8),
                          shareButton,
                        ],
                      );
                    }
                    return Row(
                      children: [
                        Expanded(child: mapButton),
                        const SizedBox(width: 10),
                        shareButton,
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoLine(BuildContext context, IconData icon, String text) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, size: 18, color: context.fieldnoteColors.moss),
      const SizedBox(width: 9),
      Expanded(
        child: Text(
          text,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    ],
  );
}

class SponsorCreateView extends StatefulWidget {
  const SponsorCreateView({
    super.key,
    required this.viewModel,
    required this.voiceController,
  });

  final FieldnoteViewModel viewModel;
  final SponsorVoiceActionController voiceController;

  @override
  State<SponsorCreateView> createState() => _SponsorCreateViewState();
}

class _SponsorCreateViewState extends State<SponsorCreateView> {
  final _prompt = TextEditingController();
  final _promptFocus = FocusNode();
  final _location = DeviceLocationService();
  final _recorder = AudioRecorder();
  CampaignProposal? _proposal;

  /// The neutral map center is never publishable. The sponsor must search,
  /// drag the pin, or use device GPS before publishing.
  CampaignPin _pin = CampaignPin(
    latitude: 20.5937,
    longitude: 78.9629,
    locationName: '',
    geofenceMeters: 200,
    isDeviceLocation: false,
  );
  bool _locationSelected = false;
  bool _locationQueryPending = false;
  int _locationRequest = 0;
  StreamSubscription<Uint8List>? _audioSubscription;
  BytesBuilder _audioBuffer = BytesBuilder(copy: false);
  Timer? _recordingTimer;
  Object? _recorderStreamError;
  Duration _recordingDuration = Duration.zero;
  int _sampleRate = 16000;
  int _channels = 1;
  bool _working = false;
  bool _recording = false;
  bool _startingRecording = false;
  bool _transcribing = false;
  bool _stopAfterStart = false;

  /// Recordings stop themselves here so a forgotten hold cannot run away.
  static const _maximumRecording = Duration(seconds: 90);

  bool get _busyWithAudio =>
      _working || _recording || _startingRecording || _transcribing;

  void _syncVoiceController() {
    widget.voiceController.update(
      recording: _recording,
      starting: _startingRecording,
      transcribing: _transcribing,
      thinking: _working,
    );
  }

  void _setVoiceState(VoidCallback update) {
    setState(update);
    _syncVoiceController();
  }

  @override
  void initState() {
    super.initState();
    widget.voiceController.attach(
      onPressStart: _startRecording,
      onPressEnd: _releaseRecording,
    );
    _syncVoiceController();
  }

  @override
  void dispose() {
    widget.voiceController.detach();
    _recordingTimer?.cancel();
    unawaited(_audioSubscription?.cancel());
    unawaited(_recorder.dispose());
    _promptFocus.dispose();
    _prompt.dispose();
    super.dispose();
  }

  /// Pointer down on the microphone: start streaming PCM into a buffer.
  Future<void> _startRecording() async {
    if (_working || _recording || _startingRecording || _transcribing) return;
    final l10n = context.l10n;
    _promptFocus.unfocus();
    _setVoiceState(() {
      _startingRecording = true;
      _stopAfterStart = false;
      _recordingDuration = Duration.zero;
    });
    try {
      if (!await _recorder.hasPermission()) {
        throw _DictationFailure(l10n.sponsorDictationMicPermission);
      }
      if (_stopAfterStart) {
        if (mounted) _setVoiceState(() => _startingRecording = false);
        return;
      }
      const config = RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        sampleRate: 16000,
        numChannels: 1,
        autoGain: true,
        echoCancel: true,
        noiseSuppress: true,
      );
      _sampleRate = config.sampleRate;
      _channels = config.numChannels;
      _recorderStreamError = null;
      await _recorder.setOnConfigChanged((actual) {
        _sampleRate = actual.sampleRate;
        _channels = actual.numChannels;
      });
      _audioBuffer = BytesBuilder(copy: false);
      final stream = await _recorder.startStream(config);
      _audioSubscription = stream.listen(
        _audioBuffer.add,
        onError: (Object exception) => _recorderStreamError = exception,
      );
      if (!mounted) {
        await _recorder.cancel();
        return;
      }
      _setVoiceState(() {
        _startingRecording = false;
        _recording = true;
      });
      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted || !_recording) return;
        setState(() => _recordingDuration += const Duration(seconds: 1));
        if (_recordingDuration >= _maximumRecording) {
          unawaited(_stopAndTranscribe());
        }
      });
      if (_stopAfterStart) await _stopAndTranscribe();
    } catch (error) {
      if (!mounted) return;
      _setVoiceState(() {
        _startingRecording = false;
      });
      _notify(_dictationError(error));
    }
  }

  /// Pointer up. A release during start-up is remembered so the recording is
  /// stopped as soon as it actually begins.
  Future<void> _releaseRecording() async {
    if (_startingRecording) {
      _stopAfterStart = true;
      return;
    }
    await _stopAndTranscribe();
  }

  /// Stops the stream, uploads the WAV for transcription, and generates the
  /// campaign from what was said.
  Future<void> _stopAndTranscribe() async {
    if (!_recording) return;
    final duration = _recordingDuration;
    final l10n = context.l10n;
    _recordingTimer?.cancel();
    _setVoiceState(() {
      _recording = false;
      _transcribing = true;
    });
    try {
      await _recorder.stop();
      await _audioSubscription?.cancel();
      _audioSubscription = null;
      final pcmBytes = _audioBuffer.takeBytes();
      if (pcmBytes.isEmpty && _recorderStreamError != null) {
        throw _DictationFailure(l10n.sponsorDictationNoAudio);
      }
      if (duration < const Duration(seconds: 1) || pcmBytes.length < 1600) {
        throw _DictationFailure(l10n.sponsorDictationTooShort);
      }
      final wavBytes = encodePcm16Wav(
        pcmBytes,
        sampleRate: _sampleRate,
        channels: _channels,
      );
      final transcript = await widget.viewModel.repository.transcribeDictation(
        ByteData.sublistView(wavBytes),
        'campaign-brief-${DateTime.now().toUtc().millisecondsSinceEpoch}.wav',
        'audio/wav',
      );
      if (!mounted) return;
      _appendToPrompt(transcript);
      _setVoiceState(() => _transcribing = false);
      if (_prompt.text.trim().length < 20) {
        _notify(context.l10n.sponsorDictationFewWords);
        return;
      }
      await _generate();
    } catch (error) {
      if (mounted) _notify(_dictationError(error));
    } finally {
      if (mounted) _setVoiceState(() => _transcribing = false);
    }
  }

  /// Appends dictation at the caret so a sponsor can dictate more than once.
  void _appendToPrompt(String transcript) {
    final text = transcript.trim();
    if (text.isEmpty) return;
    final value = _prompt.text;
    final selection = _prompt.selection;
    final start = selection.isValid
        ? selection.start.clamp(0, value.length)
        : value.length;
    final end = selection.isValid
        ? selection.end.clamp(0, value.length)
        : value.length;
    final prefix = value.substring(0, start);
    final needsSpace = prefix.isNotEmpty && !RegExp(r'\s$').hasMatch(prefix);
    final insertion = needsSpace ? ' $text' : text;
    final next = value.replaceRange(start, end, insertion);
    _prompt.value = TextEditingValue(
      text: next,
      selection: TextSelection.collapsed(offset: start + insertion.length),
    );
  }

  String _dictationError(Object error) {
    if (error is _DictationFailure) return error.message;
    if (error is FieldnoteException) return error.message;
    return context.l10n.sponsorDictationFailed;
  }

  void _notify(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  /// Builds a campaign by hand, with no model call, and reuses the same
  /// sponsor-confirmed publish path as an AI proposal.
  Future<void> _createManually() async {
    final entered = await showProposalFormDialog(
      context,
      heading: context.l10n.sponsorCreateManualHeading,
      confirmLabel: context.l10n.sponsorProposalFormUseDetails,
      initial: null,
      seedPrompt: _prompt.text.trim(),
      repository: widget.viewModel.repository,
      onLocationPicked: _acceptFormLocation,
    );
    if (entered != null && mounted) setState(() => _applyProposal(entered));
  }

  /// Seeds the map pin's name from the proposal, but never overwrites a name
  /// the sponsor has already chosen on the map.
  void _applyProposal(CampaignProposal value) {
    if (_proposal != null &&
        _proposal!.locationName != value.locationName &&
        _pin.locationName != value.locationName) {
      _locationSelected = false;
    }
    _proposal = value;
    if (!_locationSelected) {
      _pin = _pin.copyWith(locationName: value.locationName.trim());
      _locationQueryPending = false;
    }
  }

  void _acceptFormLocation(SelectedLocation location) {
    ++_locationRequest;
    setState(() {
      _pin = _pin.copyWith(
        latitude: location.latitude,
        longitude: location.longitude,
        locationName: location.label,
        isDeviceLocation: false,
      );
      _locationSelected = true;
      _locationQueryPending = false;
    });
  }

  Future<void> _generate() async {
    _promptFocus.unfocus();
    if (_prompt.text.trim().length < 20) {
      _notify(context.l10n.sponsorCreateBriefTooShort);
      return;
    }
    _setVoiceState(() => _working = true);
    try {
      final value = await widget.viewModel.repository.proposeCampaign(
        _prompt.text,
      );
      if (mounted) setState(() => _applyProposal(value));
    } catch (error) {
      _message(error);
    } finally {
      if (mounted) _setVoiceState(() => _working = false);
    }
  }

  Future<void> _useLocation() async {
    final request = ++_locationRequest;
    try {
      final value = await _location.current();
      if (!mounted || request != _locationRequest) return;
      var label =
          '${value.latitude.toStringAsFixed(5)}, '
          '${value.longitude.toStringAsFixed(5)}';
      try {
        final place = await widget.viewModel.repository.describeCoordinates(
          value.latitude,
          value.longitude,
        );
        if (place != null && place.address.trim().isNotEmpty) {
          label = place.address.trim();
        } else if (place != null && place.name.trim().isNotEmpty) {
          label = place.name.trim();
        }
      } on Object {
        // Coordinates remain useful even when reverse geocoding is offline.
      }
      if (!mounted || request != _locationRequest) return;
      setState(() {
        _pin = _pin.copyWith(
          latitude: value.latitude,
          longitude: value.longitude,
          locationName: label,
          isDeviceLocation: true,
        );
        _locationSelected = true;
        _locationQueryPending = false;
      });
    } on LocationAccessException catch (error) {
      if (mounted && request == _locationRequest) {
        await _showLocationProblem(error);
      }
    } on Object {
      if (mounted && request == _locationRequest) {
        _notify(context.l10n.sponsorCreateLocationUnreadable);
      }
    }
  }

  Future<void> _showLocationProblem(LocationAccessException error) async {
    final opensLocationSettings =
        error.issue == LocationAccessIssue.serviceDisabled;
    final opensAppSettings =
        error.issue == LocationAccessIssue.permissionDeniedForever;
    final canOpenSettings = opensLocationSettings || opensAppSettings;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          opensLocationSettings
              ? dialogContext.l10n.sponsorLocationTurnOnTitle
              : opensAppSettings
              ? dialogContext.l10n.sponsorLocationAllowTitle
              : dialogContext.l10n.sponsorLocationUnavailableTitle,
        ),
        content: Text(error.message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(dialogContext.l10n.sponsorLocationNotNow),
          ),
          if (canOpenSettings)
            FilledButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                if (opensLocationSettings) {
                  await _location.openLocationSettings();
                } else {
                  await _location.openAppSettings();
                }
              },
              child: Text(
                opensLocationSettings
                    ? dialogContext.l10n.sponsorLocationOpenLocationSettings
                    : dialogContext.l10n.sponsorLocationOpenAppSettings,
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _editProposal() async {
    final proposal = _proposal;
    if (proposal == null) return;
    final edited = await showProposalFormDialog(
      context,
      heading: context.l10n.sponsorCreateConfirmHeading,
      confirmLabel: context.l10n.sponsorProposalFormUseDetails,
      initial: proposal,
      repository: widget.viewModel.repository,
      onLocationPicked: _acceptFormLocation,
    );
    if (edited != null && mounted) setState(() => _applyProposal(edited));
  }

  Future<void> _publish() async {
    // Guards a double tap or a retry while the first request is in flight.
    if (_proposal == null || _working) return;
    if (_locationQueryPending) {
      _notify(context.l10n.sponsorCreateSelectPlaceResult);
      return;
    }
    if (!_locationSelected) {
      _notify(context.l10n.sponsorCreateChooseLocationFirst);
      return;
    }
    _setVoiceState(() => _working = true);
    try {
      // The goal is sent as exact paise; the draft may come from an older
      // server that only filled the rupee field.
      final proposal = _proposal!;
      final campaign = await widget.viewModel.publishCampaign(
        proposal.copyWith(fundingGoalPaise: proposalGoalPaise(proposal)),
        _pin.latitude,
        _pin.longitude,
        locationName: _pin.locationName,
        geofenceMeters: _pin.geofenceMeters,
      );
      if (!mounted) return;
      _proposal = null;
      widget.viewModel.selectSection(2);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.sponsorCreateIsLive(campaign.name)),
        ),
      );
    } catch (error) {
      if (mounted) {
        _message(error, fallback: context.l10n.sponsorCreatePublishFailed);
      }
    } finally {
      if (mounted) _setVoiceState(() => _working = false);
    }
  }

  void _message(Object error, {String? fallback}) {
    if (!mounted) return;
    final l10n = context.l10n;
    final text = sponsorErrorMessage(
      error,
      l10n: l10n,
      fallback: fallback ?? l10n.sponsorCreateGenerateFailed,
    );
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    return FieldnotePageList(
      bottom: FieldnoteSpacing.xl,
      children: [
        SectionHeading(
          eyebrow: context.l10n.sponsorCreateEyebrow,
          title: context.l10n.sponsorCreateTitle,
          description: context.l10n.sponsorCreateDescription,
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 900;
            final c = context.fieldnoteColors;
            final prompt = SurfaceCard(
              color: c.inkFill,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.sponsorCreatePromptTitle,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: c.onFill,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    context.l10n.sponsorCreatePromptHelp,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: c.onFill.withValues(alpha: .7),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FieldnoteTextField(
                    controller: _prompt,
                    focusNode: _promptFocus,
                    minLines: 4,
                    maxLines: 7,
                    enabled: !_recording && !_transcribing,
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.newline,
                    textCapitalization: TextCapitalization.sentences,
                    onChanged: (_) => setState(() {}),
                    style: TextStyle(color: c.onFill),
                    decoration: InputDecoration(
                      hintText: _recording
                          ? context.l10n.sponsorCreateListening
                          : context.l10n.sponsorCreatePromptHint,
                      hintStyle: TextStyle(
                        color: c.onFill.withValues(alpha: .54),
                      ),
                      fillColor: c.onFill.withValues(alpha: .09),
                      suffixIcon: _prompt.text.isEmpty || _recording
                          ? null
                          : IconButton(
                              tooltip: context.l10n.sponsorCreateClear,
                              icon: Icon(
                                Icons.close,
                                color: c.onFill.withValues(alpha: .54),
                              ),
                              onPressed: () => setState(_prompt.clear),
                            ),
                    ),
                  ),
                  if (_prompt.text.isEmpty && !_recording) ...[
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: () => setState(() {
                          _prompt.text =
                              context.l10n.sponsorCreateExamplePrompt;
                          _prompt.selection = TextSelection.collapsed(
                            offset: _prompt.text.length,
                          );
                        }),
                        style: TextButton.styleFrom(
                          foregroundColor: c.acid,
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 32),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(context.l10n.sponsorCreateExampleButton),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _busyWithAudio ? null : _generate,
                      style: FilledButton.styleFrom(
                        backgroundColor: c.acid,
                        foregroundColor: c.onAcid,
                        disabledBackgroundColor: c.acid.withValues(alpha: .52),
                        disabledForegroundColor: c.onAcid.withValues(
                          alpha: .82,
                        ),
                      ),
                      icon: _working || _transcribing
                          ? SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                color: c.onAcid,
                              ),
                            )
                          : const Icon(Icons.auto_awesome),
                      label: Text(
                        _transcribing
                            ? context.l10n.sponsorCreateProcessingRecording
                            : _working
                            ? context.l10n.sponsorCreateGenerating
                            : context.l10n.sponsorCreateGenerate,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _busyWithAudio ? null : _createManually,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: c.onFill,
                        disabledForegroundColor: c.onFill.withValues(alpha: .7),
                        side: BorderSide(
                          color: c.onFill.withValues(
                            alpha: _busyWithAudio ? .2 : .35,
                          ),
                        ),
                      ),
                      icon: const Icon(Icons.edit_note),
                      label: Text(context.l10n.sponsorCreateManualButton),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    context.l10n.sponsorCreateManualNote,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: c.onFill.withValues(alpha: .54),
                    ),
                  ),
                ],
              ),
            );
            final result = _proposal == null
                ? SurfaceCard(
                    child: Row(
                      children: [
                        Icon(
                          Icons.auto_awesome_outlined,
                          color: context.fieldnoteColors.moss,
                          size: 26,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            context.l10n.sponsorCreateProposalPlaceholder,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  )
                : _ProposalCard(
                    proposal: _proposal!,
                    repository: widget.viewModel.repository,
                    pin: _pin,
                    locationSelected: _locationSelected,
                    onSearchPendingChanged: (pending) =>
                        _locationQueryPending = pending,
                    onPinChanged: (value) => setState(() {
                      ++_locationRequest;
                      final moved =
                          value.latitude != _pin.latitude ||
                          value.longitude != _pin.longitude ||
                          value.locationName != _pin.locationName ||
                          value.isDeviceLocation != _pin.isDeviceLocation;
                      _pin = value;
                      if (moved) _locationSelected = true;
                      if (moved) _locationQueryPending = false;
                    }),
                    onUseLocation: _useLocation,
                    onEdit: _editProposal,
                    onPublish: _working ? null : _publish,
                  );
            if (wide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 5, child: prompt),
                  const SizedBox(width: 18),
                  Expanded(flex: 6, child: result),
                ],
              );
            }
            return Column(
              children: [prompt, const SizedBox(height: 16), result],
            );
          },
        ),
      ],
    );
  }
}

class _ProposalCard extends StatelessWidget {
  const _ProposalCard({
    required this.proposal,
    required this.repository,
    required this.pin,
    required this.locationSelected,
    required this.onSearchPendingChanged,
    required this.onPinChanged,
    required this.onUseLocation,
    required this.onEdit,
    required this.onPublish,
  });

  final CampaignProposal proposal;
  final FieldnoteRepository repository;
  final CampaignPin pin;
  final bool locationSelected;
  final ValueChanged<bool> onSearchPendingChanged;
  final ValueChanged<CampaignPin> onPinChanged;
  final Future<void> Function() onUseLocation;
  final VoidCallback onEdit;
  final VoidCallback? onPublish;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              StatusPill(
                label: l10n.sponsorProposalAssistedDraft,
                color: context.fieldnoteColors.clay,
                icon: Icons.auto_awesome,
              ),
              const Spacer(),
              Text(
                l10n.sponsorProposalGoal(
                  formatPaiseCompact(
                    proposalGoalPaise(proposal),
                    localeTag: context.localeTag,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            proposal.title,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 7),
          Text(proposal.description),
          const SizedBox(height: 16),
          _detail(
            context,
            Icons.schedule,
            DateFormat.MMMEd(
              context.localeTag,
            ).add_jm().format(proposal.startsAt.toLocal()),
          ),
          _detail(
            context,
            Icons.group_outlined,
            l10n.sponsorProposalTeamSummary(
              l10n.sponsorCampaignPlaces(proposal.volunteerCapacity),
              proposal.minimumVolunteers ??
                  (proposal.volunteerCapacity / 2).ceil(),
              l10n.sponsorProposalHours(proposal.durationMinutes ~/ 60),
            ),
          ),
          _detail(
            context,
            Icons.location_on_outlined,
            pin.locationName.isEmpty ? proposal.locationName : pin.locationName,
          ),
          const Divider(height: 28),
          CampaignPinPicker(
            repository: repository,
            pin: pin,
            locationSelected: locationSelected,
            onSearchPendingChanged: onSearchPendingChanged,
            onChanged: onPinChanged,
            onUseDeviceLocation: onUseLocation,
          ),
          const Divider(height: 28),
          Text(
            l10n.sponsorWorkChecklist,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          ...proposal.checklist.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 18,
                    color: context.fieldnoteColors.forest,
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(item)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            proposal.rationale,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined),
                  label: Text(l10n.sponsorProposalEdit),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: onPublish,
                  icon: const Icon(Icons.rocket_launch_outlined),
                  label: Text(l10n.sponsorProposalPublish),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _detail(BuildContext context, IconData icon, String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      children: [
        Icon(icon, size: 18, color: context.fieldnoteColors.moss),
        const SizedBox(width: 8),
        Expanded(child: Text(text)),
      ],
    ),
  );
}

class SponsorImpactView extends StatelessWidget {
  const SponsorImpactView({super.key, required this.viewModel});

  final FieldnoteViewModel viewModel;

  void _openPaymentHistory(BuildContext context) =>
      Navigator.of(context).push<void>(
        MaterialPageRoute(
          builder: (_) => PaymentHistoryView(viewModel: viewModel),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final campaigns = viewModel.impactCampaigns;
    final needsAttention = viewModel.paymentHistory
        .where(
          (entry) =>
              entry.sponsorship.paymentStatus == 'verified_uncredited' ||
              entry.refund?.status == 'failed',
        )
        .length;
    final l10n = context.l10n;
    return RefreshIndicator(
      onRefresh: viewModel.refresh,
      child: FieldnotePageList(
        children: [
          SectionHeading(
            eyebrow: l10n.sponsorEyebrow,
            title: l10n.sponsorImpactTitle,
            description: l10n.sponsorImpactDescription,
            trailing: OutlinedButton.icon(
              onPressed: () => _openPaymentHistory(context),
              icon: const Icon(Icons.receipt_long_outlined),
              label: Text(
                needsAttention == 0
                    ? l10n.sponsorImpactPaymentHistory
                    : l10n.sponsorImpactPaymentHistoryReview(needsAttention),
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (campaigns.isEmpty)
            EmptyPanel(
              icon: Icons.insights_outlined,
              title: l10n.sponsorImpactEmptyTitle,
              message: l10n.sponsorImpactEmptyMessage,
            )
          else
            ...campaigns.map(
              (campaign) => Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: _ImpactCard(
                  campaign: campaign,
                  impact: viewModel.impacts[campaign.id],
                  impactError: viewModel.impactErrors[campaign.id],
                  viewModel: viewModel,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Live stream state for one campaign (S-8). Null means not listening.
class CampaignLiveIndicator extends StatelessWidget {
  const CampaignLiveIndicator({super.key, required this.state});

  final LiveConnectionState? state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final (label, color, icon) = switch (state) {
      LiveConnectionState.connected => (
        l10n.sponsorLiveConnected,
        context.fieldnoteColors.forest,
        Icons.sensors,
      ),
      LiveConnectionState.reconnecting => (
        l10n.sponsorLiveReconnecting,
        context.fieldnoteColors.clay,
        Icons.sync_problem,
      ),
      LiveConnectionState.connecting => (
        l10n.sponsorLiveConnecting,
        context.fieldnoteColors.moss,
        Icons.sync,
      ),
      null => (
        l10n.sponsorLiveNotListening,
        context.fieldnoteColors.moss,
        Icons.sensors_off,
      ),
    };
    return Semantics(
      liveRegion: true,
      child: StatusPill(label: label, color: color, icon: icon),
    );
  }
}

class _ImpactCard extends StatelessWidget {
  const _ImpactCard({
    required this.campaign,
    required this.impact,
    required this.impactError,
    required this.viewModel,
  });

  final Campaign campaign;
  final ImpactSummary? impact;
  final String? impactError;
  final FieldnoteViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final value = impact;
    final id = campaign.id!;
    // The campaign map endpoint is restricted to the creator, so only offer it
    // for campaigns this sponsor published.
    final isCreator = viewModel.createdCampaigns.any((item) => item.id == id);
    final l10n = context.l10n;
    final phase = campaignPhase(campaign);
    final style = campaignPhaseStyle(phase, l10n: l10n);
    final closed = campaignIsClosed(phase);
    final listening = viewModel.isSubscribedTo(id);
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  campaign.name,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              if (!closed || listening)
                IconButton(
                  tooltip: listening
                      ? l10n.sponsorImpactStopLive
                      : l10n.sponsorImpactListenLive,
                  isSelected: listening,
                  onPressed: () => listening
                      ? viewModel.unsubscribeFromCampaign(id)
                      : viewModel.subscribeToCampaign(id),
                  icon: const Icon(Icons.sensors_off),
                  selectedIcon: const Icon(Icons.sensors),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              StatusPill(
                label: style.label,
                color: style.color,
                icon: style.icon,
              ),
              if (!closed || listening)
                CampaignLiveIndicator(state: viewModel.liveStateFor(id)),
            ],
          ),
          const SizedBox(height: 10),
          if (value != null)
            Text(value.summary)
          else if (impactError != null)
            Row(
              children: [
                Icon(
                  Icons.error_outline,
                  size: 18,
                  color: context.fieldnoteColors.danger,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(localizeStoredMessage(context, impactError!)),
                ),
                TextButton(
                  onPressed: () => viewModel.refreshImpact(id),
                  child: Text(l10n.commonRetry),
                ),
              ],
            )
          else
            Text(l10n.sponsorImpactLoading),
          if (phase == CampaignPhase.cancelled ||
              phase == CampaignPhase.expired) ...[
            const SizedBox(height: 8),
            Text(
              phase == CampaignPhase.cancelled
                  ? l10n.sponsorImpactCancelledNote
                  : l10n.sponsorImpactExpiredNote,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _ImpactMetric(
                label: l10n.sponsorImpactMetricSponsored,
                value: formatPaiseCompact(
                  value == null
                      ? campaignSponsoredPaise(campaign)
                      : impactSponsoredPaise(value),
                  localeTag: context.localeTag,
                ),
              ),
              if ((value?.refundedPaise ?? campaign.refundedAmountPaise) > 0)
                _ImpactMetric(
                  label: l10n.sponsorImpactMetricRefunded,
                  value: formatPaiseCompact(
                    value?.refundedPaise ?? campaign.refundedAmountPaise,
                    localeTag: context.localeTag,
                  ),
                ),
              _ImpactMetric(
                label: l10n.sponsorImpactMetricJoined,
                value: value == null ? '–' : '${value.joinedVolunteers}',
              ),
              _ImpactMetric(
                label: l10n.sponsorImpactMetricCompleted,
                value: value == null ? '–' : '${value.completedVolunteers}',
              ),
              _ImpactMetric(
                label: l10n.sponsorImpactMetricEvidence,
                value: value == null ? '–' : '${value.evidenceCount}',
              ),
            ],
          ),
          if (isCreator) ...[
            const Divider(height: 24),
            LayoutBuilder(
              builder: (context, constraints) {
                final width = (constraints.maxWidth - 8) / 2;
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    SizedBox(
                      width: width,
                      child: OutlinedButton.icon(
                        onPressed: () => shareCampaign(
                          context,
                          campaign,
                          repository: viewModel.repository,
                        ),
                        icon: const Icon(Icons.share_outlined, size: 18),
                        label: Text(l10n.sponsorActionShare),
                      ),
                    ),
                    SizedBox(
                      width: width,
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.of(context).push<void>(
                          MaterialPageRoute(
                            builder: (_) => CampaignVolunteerReachView(
                              campaign: campaign,
                              repository: viewModel.repository,
                            ),
                          ),
                        ),
                        icon: const Icon(Icons.groups_outlined, size: 18),
                        label: Text(l10n.sponsorImpactVolunteers),
                      ),
                    ),
                    SizedBox(
                      width: width,
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.of(context).push<void>(
                          MaterialPageRoute(
                            builder: (_) => CampaignReadinessView(
                              campaign: campaign,
                              viewModel: viewModel,
                            ),
                          ),
                        ),
                        icon: const Icon(
                          Icons.event_available_outlined,
                          size: 18,
                        ),
                        label: Text(l10n.sponsorImpactReadiness),
                      ),
                    ),
                    SizedBox(
                      width: width,
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.of(context).push<void>(
                          MaterialPageRoute(
                            builder: (_) => CampaignPayoutView(
                              campaign: campaign,
                              viewModel: viewModel,
                            ),
                          ),
                        ),
                        icon: const Icon(
                          Icons.account_balance_outlined,
                          size: 18,
                        ),
                        label: Text(l10n.sponsorImpactPayout),
                      ),
                    ),
                    SizedBox(
                      width: constraints.maxWidth,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final post = await showCampaignPostDialog(
                            context,
                            viewModel: viewModel,
                            campaign: campaign,
                          );
                          if (post != null && context.mounted) {
                            showFieldnoteNotice(
                              context,
                              title: l10n.sponsorImpactUpdatePublishedTitle,
                              message: l10n.sponsorImpactUpdatePublishedMessage(
                                post.title,
                              ),
                              kind: FieldnoteNoticeKind.success,
                            );
                          }
                        },
                        icon: const Icon(Icons.campaign_outlined, size: 18),
                        label: Text(l10n.sponsorImpactPostUpdate),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            CampaignProofMap(
              repository: viewModel.repository,
              campaign: campaign,
              // Reloads whenever the live stream reports new activity.
              refreshToken:
                  '${viewModel.lastLiveUpdates[id]?.occurredAt.toIso8601String()}'
                  '·${value?.evidenceCount ?? 0}'
                  '·${value?.joinedVolunteers ?? 0}',
            ),
          ],
          if (value != null && value.recentEvidence.isNotEmpty) ...[
            const Divider(height: 30),
            Text(
              l10n.sponsorEvidenceTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              isCreator
                  ? l10n.sponsorEvidenceTapToReview
                  : l10n.sponsorEvidenceTapToSee,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 236,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: value.recentEvidence.length,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final evidence = value.recentEvidence[index];
                  return SizedBox(
                    width: 280,
                    child: _EvidenceTile(
                      key: ValueKey('evidence-${evidence.id}'),
                      evidence: evidence,
                      campaign: campaign,
                      viewModel: viewModel,
                      canReview: isCreator,
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EvidenceTile extends StatefulWidget {
  const _EvidenceTile({
    super.key,
    required this.evidence,
    required this.campaign,
    required this.viewModel,
    required this.canReview,
  });

  final CompletionEvidence evidence;
  final Campaign campaign;
  final FieldnoteViewModel viewModel;
  final bool canReview;

  @override
  State<_EvidenceTile> createState() => _EvidenceTileState();
}

class _EvidenceTileState extends State<_EvidenceTile> {
  Future<String>? _photoUrl;

  @override
  void initState() {
    super.initState();
    _photoUrl = _fetchUrl();
  }

  /// Download URLs are short-lived, so a failed load fetches a fresh one.
  Future<String>? _fetchUrl() => widget.evidence.id == null
      ? null
      : widget.viewModel.repository.evidenceUrl(widget.evidence.id!);

  void _retryPhoto() => setState(() => _photoUrl = _fetchUrl());

  void _openProvenance() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => EvidenceProvenanceSheet(
        evidence: widget.evidence,
        campaign: widget.campaign,
        reviewPanel: widget.canReview && widget.evidence.id != null
            ? EvidenceReviewPanel(
                evidence: widget.evidence,
                campaign: widget.campaign,
                viewModel: widget.viewModel,
              )
            : null,
      ),
    );
  }

  Widget _photoProblem(String label) => ColoredBox(
    color: context.fieldnoteColors.inkFill,
    child: Center(
      child: TextButton.icon(
        onPressed: _retryPhoto,
        style: TextButton.styleFrom(
          foregroundColor: context.fieldnoteColors.onFill.withValues(alpha: .7),
        ),
        icon: const Icon(Icons.refresh, size: 18),
        label: Text(label),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final review = reviewStateStyle(widget.evidence.reviewState, l10n: l10n);
    final c = context.fieldnoteColors;
    return InkWell(
      onTap: _openProvenance,
      borderRadius: BorderRadius.circular(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: DecoratedBox(
          decoration: BoxDecoration(color: c.mist),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 92,
                width: double.infinity,
                child: _photoUrl == null
                    ? ColoredBox(
                        color: c.inkFill,
                        child: Icon(
                          Icons.photo_outlined,
                          color: c.onFill.withValues(alpha: .54),
                        ),
                      )
                    : FutureBuilder<String>(
                        future: _photoUrl,
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return _photoProblem(
                              l10n.sponsorEvidencePhotoUnavailable,
                            );
                          }
                          if (!snapshot.hasData) {
                            return ColoredBox(
                              color: c.inkFill,
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: c.acid,
                                  strokeWidth: 2,
                                ),
                              ),
                            );
                          }
                          return Image.network(
                            snapshot.data!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) =>
                                _photoProblem(l10n.sponsorEvidenceReloadPhoto),
                          );
                        },
                      ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          StatusPill(
                            label: review.label,
                            color: review.color,
                            icon: review.icon,
                          ),
                          StatusPill(
                            label: widget.evidence.locationIsDemo
                                ? l10n.sponsorEvidenceLocationUnverified
                                : l10n.sponsorEvidenceLocationVerified,
                            color: widget.evidence.locationIsDemo
                                ? context.fieldnoteColors.clay
                                : context.fieldnoteColors.forest,
                            icon: widget.evidence.locationIsDemo
                                ? Icons.science_outlined
                                : Icons.gps_fixed,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.evidence.confirmedSummary,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Icon(
                            widget.canReview
                                ? Icons.rate_review_outlined
                                : Icons.place_outlined,
                            size: 15,
                            color: context.fieldnoteColors.moss,
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              widget.canReview
                                  ? l10n.sponsorEvidenceReviewAndSee
                                  : l10n.sponsorEvidenceSeeWhere,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Approve or reject one evidence item (S-6). Rejecting needs a note that
/// the volunteer is shown.
class EvidenceReviewPanel extends StatefulWidget {
  const EvidenceReviewPanel({
    super.key,
    required this.evidence,
    required this.campaign,
    required this.viewModel,
  });

  final CompletionEvidence evidence;
  final Campaign campaign;
  final FieldnoteViewModel viewModel;

  @override
  State<EvidenceReviewPanel> createState() => _EvidenceReviewPanelState();
}

class _EvidenceReviewPanelState extends State<EvidenceReviewPanel> {
  late final _note = TextEditingController(
    text: widget.evidence.reviewNote ?? '',
  );
  late ReviewState _state = widget.evidence.reviewState;
  late String? _savedNote = widget.evidence.reviewNote;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _review(bool approve) async {
    final l10n = context.l10n;
    final note = _note.text.trim();
    if (!approve && note.length < CampaignLimits.reviewNoteMin) {
      setState(
        () => _error = l10n.sponsorEvidenceRejectNoteTooShort(
          CampaignLimits.reviewNoteMin,
        ),
      );
      return;
    }
    if (note.length > CampaignLimits.reviewNoteMax) {
      setState(
        () => _error = l10n.sponsorEvidenceNoteTooLong(
          CampaignLimits.reviewNoteMax,
        ),
      );
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final updated = await widget.viewModel.reviewEvidence(
        widget.campaign.id!,
        widget.evidence.id!,
        approve: approve,
        note: note.isEmpty ? null : note,
      );
      if (!mounted) return;
      setState(() {
        _state = updated.reviewState;
        _savedNote = updated.reviewNote;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            approve
                ? context.l10n.sponsorEvidenceApproved
                : context.l10n.sponsorEvidenceRejected,
          ),
        ),
      );
    } catch (error) {
      if (mounted) {
        setState(
          () => _error = userMessageFor(
            error,
            fallback: context.l10n.sponsorEvidenceReviewFailed,
            context: context,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final style = reviewStateStyle(_state, l10n: l10n);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.sponsorEvidenceYourReview,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            StatusPill(
              label: style.label,
              color: style.color,
              icon: style.icon,
            ),
          ],
        ),
        if (widget.evidence.aiGenerated) ...[
          const SizedBox(height: 6),
          Text(
            l10n.sponsorEvidenceAiDrafted,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
        if (_savedNote != null && _savedNote!.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(l10n.sponsorEvidenceSavedNote(_savedNote!)),
        ],
        const SizedBox(height: 10),
        FieldnoteTextField(
          controller: _note,
          enabled: !_saving,
          minLines: 2,
          maxLines: 4,
          maxLength: CampaignLimits.reviewNoteMax,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            labelText: l10n.sponsorEvidenceNoteLabel,
            helperText: l10n.sponsorEvidenceNoteHelper,
          ),
        ),
        if (_error != null) ...[
          const SizedBox(height: 6),
          Text(
            _error!,
            style: TextStyle(color: context.fieldnoteColors.danger),
          ),
        ],
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _saving ? null : () => _review(false),
                style: OutlinedButton.styleFrom(
                  foregroundColor: context.fieldnoteColors.danger,
                ),
                icon: const Icon(Icons.thumb_down_alt_outlined),
                label: Text(l10n.sponsorEvidenceReject),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FilledButton.icon(
                onPressed: _saving ? null : () => _review(true),
                icon: _saving
                    ? const SizedBox.square(
                        dimension: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.thumb_up_alt_outlined),
                label: Text(l10n.sponsorEvidenceApprove),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ImpactMetric extends StatelessWidget {
  const _ImpactMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 132,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.fieldnoteColors.acid.withValues(
          alpha: context.fieldnoteColors.isDark ? .12 : .35,
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelMedium),
          Text(value, style: Theme.of(context).textTheme.titleLarge),
        ],
      ),
    );
  }
}

class CampaignCard extends StatelessWidget {
  const CampaignCard({
    super.key,
    required this.campaign,
    required this.actionLabel,
    required this.onAction,
    required this.showFunding,
    this.score,
    this.reasons = const [],
  });

  final Campaign campaign;
  final String actionLabel;
  final VoidCallback? onAction;
  final bool showFunding;
  final double? score;
  final List<String> reasons;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (score != null)
                StatusPill(
                  label: l10n.sponsorCardMatch(score!.round()),
                  color: score! >= 75
                      ? context.fieldnoteColors.forest
                      : context.fieldnoteColors.clay,
                  icon: Icons.auto_awesome,
                )
              else
                Builder(
                  builder: (context) {
                    final phase = campaignPhase(campaign);
                    final style = campaignPhaseStyle(phase, l10n: l10n);
                    return StatusPill(
                      label: switch (phase) {
                        CampaignPhase.planning => l10n.sponsorCardDateTentative,
                        CampaignPhase.needsDecision =>
                          l10n.sponsorCardAwaitingDecision,
                        _ => style.label,
                      },
                      color: phase == CampaignPhase.planning
                          ? context.fieldnoteColors.clay
                          : style.color,
                      icon: Icons.event_outlined,
                    );
                  },
                ),
              const Spacer(),
              Text(l10n.sponsorCampaignPlaces(campaign.volunteerCapacity)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            campaign.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          Text(
            campaign.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 10),
          Text(
            l10n.sponsorCardPlaceAndDate(
              campaign.locationName,
              DateFormat.MMMEd(
                context.localeTag,
              ).format(campaign.startsAt.toLocal()),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (reasons.isNotEmpty) ...[
            const SizedBox(height: 10),
            ...reasons
                .take(2)
                .map(
                  (reason) => Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check,
                          size: 15,
                          color: context.fieldnoteColors.moss,
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            reason,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          ],
          if (showFunding) ...[
            const SizedBox(height: 14),
            _AnimatedFundingProgress(
              sponsoredPaise: campaignSponsoredPaise(campaign),
              goalPaise: campaignGoalPaise(campaign),
              refundedPaise: campaignRefundedPaise(campaign),
            ),
            const SizedBox(height: 10),
          ] else
            const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton(onPressed: onAction, child: Text(actionLabel)),
          ),
        ],
      ),
    );
  }
}

class _AnimatedFundingProgress extends StatefulWidget {
  const _AnimatedFundingProgress({
    required this.sponsoredPaise,
    required this.goalPaise,
    required this.refundedPaise,
  });

  /// Funded amount net of refunds.
  final int sponsoredPaise;
  final int goalPaise;
  final int refundedPaise;

  @override
  State<_AnimatedFundingProgress> createState() =>
      _AnimatedFundingProgressState();
}

class _AnimatedFundingProgressState extends State<_AnimatedFundingProgress> {
  late int _previousPaise = widget.sponsoredPaise;

  @override
  void didUpdateWidget(_AnimatedFundingProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.sponsoredPaise != widget.sponsoredPaise) {
      _previousPaise = oldWidget.sponsoredPaise;
    }
  }

  @override
  Widget build(BuildContext context) {
    final localeTag = context.localeTag;
    return TweenAnimationBuilder<double>(
      tween: Tween(
        begin: _previousPaise.toDouble(),
        end: widget.sponsoredPaise.toDouble(),
      ),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      onEnd: () => _previousPaise = widget.sponsoredPaise,
      builder: (context, animated, _) {
        // Display only: the animated value is rounded back to whole paise.
        final paise = animated.round();
        final funded = formatPaiseCompact(paise, localeTag: localeTag);
        final goal = formatPaiseCompact(widget.goalPaise, localeTag: localeTag);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LinearProgressIndicator(
              minHeight: 8,
              value: fundingProgress(paise, widget.goalPaise),
              borderRadius: BorderRadius.circular(99),
              color: context.fieldnoteColors.clay,
              backgroundColor: context.fieldnoteColors.clay.withValues(
                alpha: .12,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              widget.refundedPaise > 0
                  ? context.l10n.sponsorFundingOfGoalRefunded(
                      funded,
                      goal,
                      formatPaiseCompact(
                        widget.refundedPaise,
                        localeTag: localeTag,
                      ),
                    )
                  : context.l10n.sponsorFundingOfGoal(funded, goal),
            ),
          ],
        );
      },
    );
  }
}

/// Raised when dictation cannot be captured on the device.
class _DictationFailure implements Exception {
  const _DictationFailure(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Shared campaign form. Used to confirm an AI proposal and to author a
/// campaign by hand when no model is involved.
Future<CampaignProposal?> showProposalFormDialog(
  BuildContext context, {
  required String heading,
  required String confirmLabel,
  CampaignProposal? initial,
  String seedPrompt = '',
  FieldnoteRepository? repository,
  ValueChanged<SelectedLocation>? onLocationPicked,
}) {
  return showDialog<CampaignProposal>(
    context: context,
    // A stray tap outside must not throw away a long form (P2).
    barrierDismissible: false,
    builder: (dialogContext) => _ProposalFormDialog(
      heading: heading,
      confirmLabel: confirmLabel,
      initial: initial,
      seedPrompt: seedPrompt,
      repository: repository,
      onLocationPicked: onLocationPicked,
      defaultSkill: dialogContext.l10n.sponsorProposalFormDefaultSkill,
      defaultEvidence: dialogContext.l10n.sponsorProposalFormDefaultEvidence,
    ),
  );
}

class _ProposalFormDialog extends StatefulWidget {
  const _ProposalFormDialog({
    required this.heading,
    required this.confirmLabel,
    required this.initial,
    required this.seedPrompt,
    required this.repository,
    required this.onLocationPicked,
    required this.defaultSkill,
    required this.defaultEvidence,
  });

  final String heading;
  final String confirmLabel;
  final CampaignProposal? initial;
  final String seedPrompt;
  final FieldnoteRepository? repository;
  final ValueChanged<SelectedLocation>? onLocationPicked;

  /// Editable seed text in the sponsor's language for a new campaign.
  final String defaultSkill;
  final String defaultEvidence;

  @override
  State<_ProposalFormDialog> createState() => _ProposalFormDialogState();
}

class _ProposalFormDialogState extends State<_ProposalFormDialog> {
  late final TextEditingController _title;
  late final TextEditingController _description;
  late final TextEditingController _locationName;
  late final TextEditingController _funding;
  late final TextEditingController _capacity;
  late final TextEditingController _minimum;
  late final TextEditingController _duration;
  late final TextEditingController _skills;
  late final TextEditingController _checklist;
  late final TextEditingController _evidence;
  late final TextEditingController _tags;
  late DateTime _startsAt;
  late DateTime _initialStartsAt;
  late final List<TextEditingController> _all;
  late final List<String> _initialTexts;
  String? _error;
  Map<String, String> _errors = const {};
  SelectedLocation? _selectedLocation;

  bool get _dirty =>
      _startsAt != _initialStartsAt ||
      _selectedLocation != null ||
      [
        for (var i = 0; i < _all.length; i++) _all[i].text != _initialTexts[i],
      ].any((changed) => changed);

  Future<void> _cancel() async {
    if (!_dirty || await confirmDiscard(context)) {
      if (mounted) Navigator.pop(context);
    }
  }

  Future<void> _chooseLocation() async {
    final repository = widget.repository;
    if (repository == null) return;
    final selected = await Navigator.push<SelectedLocation>(
      context,
      MaterialPageRoute(
        builder: (_) => LocationPicker(
          repository: repository,
          title: context.l10n.sponsorProposalFormChooseLocation,
          initialQuery: _locationName.text,
        ),
      ),
    );
    if (selected == null || !mounted) return;
    setState(() {
      _selectedLocation = selected;
      _locationName.text = selected.label;
    });
  }

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _title = TextEditingController(text: initial?.title ?? '');
    _description = TextEditingController(
      text: initial?.description ?? widget.seedPrompt,
    );
    _locationName = TextEditingController(text: initial?.locationName ?? '');
    _funding = TextEditingController(
      text: paiseInputText(
        initial == null ? 2500000 : proposalGoalPaise(initial),
      ),
    );
    _capacity = TextEditingController(
      text: (initial?.volunteerCapacity ?? 10).toString(),
    );
    _minimum = TextEditingController(
      text:
          (initial?.minimumVolunteers ??
                  ((initial?.volunteerCapacity ?? 10) / 2).ceil())
              .toString(),
    );
    _duration = TextEditingController(
      text: (initial?.durationMinutes ?? 180).toString(),
    );
    _skills = TextEditingController(
      text: (initial?.requiredSkills ?? [widget.defaultSkill]).join('\n'),
    );
    _checklist = TextEditingController(
      text: (initial?.checklist ?? const <String>[]).join('\n'),
    );
    _evidence = TextEditingController(
      text: initial?.evidenceInstructions ?? widget.defaultEvidence,
    );
    _tags = TextEditingController(
      text: (initial?.tags ?? const ['community']).join('\n'),
    );
    _startsAt = initial?.startsAt.toLocal() ?? _nextSaturdayMorning();
    _initialStartsAt = _startsAt;
    _all = [
      _title,
      _description,
      _locationName,
      _funding,
      _capacity,
      _minimum,
      _duration,
      _skills,
      _checklist,
      _evidence,
      _tags,
    ];
    _initialTexts = [for (final controller in _all) controller.text];
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _locationName.dispose();
    _funding.dispose();
    _capacity.dispose();
    _minimum.dispose();
    _duration.dispose();
    _skills.dispose();
    _checklist.dispose();
    _evidence.dispose();
    _tags.dispose();
    super.dispose();
  }

  static DateTime _nextSaturdayMorning() {
    final now = DateTime.now();
    var days = DateTime.saturday - now.weekday;
    if (days <= 0) days += 7;
    final target = now.add(Duration(days: days));
    return DateTime(target.year, target.month, target.day, 8);
  }

  static List<String> _lines(String value) => value
      .split(RegExp(r'[\n,]'))
      .map((entry) => entry.trim())
      .where((entry) => entry.isNotEmpty)
      .toList();

  Future<void> _pickStart() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _startsAt.isAfter(now) ? _startsAt : now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_startsAt),
    );
    if (!mounted) return;
    setState(() {
      _startsAt = DateTime(
        date.year,
        date.month,
        date.day,
        time?.hour ?? _startsAt.hour,
        time?.minute ?? _startsAt.minute,
      );
    });
  }

  void _submit() {
    final title = _title.text.trim();
    final description = _description.text.trim();
    final locationName = _locationName.text.trim();
    final fundingPaise = parseRupeesToPaise(_funding.text);
    final capacity = parseWholeNumber(_capacity.text);
    final minimum = parseWholeNumber(_minimum.text);
    final duration = parseWholeNumber(_duration.text);
    final checklist = _lines(_checklist.text);
    final skills = _lines(_skills.text);
    final tags = _lines(_tags.text);
    final evidence = _evidence.text.trim();

    final errors = validateCampaignForm(
      title: title,
      description: description,
      locationName: locationName,
      startsAt: _startsAt,
      duration: _duration.text,
      capacity: _capacity.text,
      minimum: _minimum.text,
      funding: _funding.text,
      checklist: checklist,
      skills: skills,
      tags: tags,
      evidence: evidence,
      l10n: context.l10n,
      localeTag: context.localeTag,
    );
    if (errors.isNotEmpty) {
      setState(() {
        _errors = errors;
        _error = errors.length == 1
            ? errors.values.first
            : context.l10n.sponsorProposalFormFixFields(errors.length);
      });
      return;
    }

    final initial = widget.initial;
    if (_selectedLocation != null) {
      widget.onLocationPicked?.call(_selectedLocation!);
    }
    Navigator.pop(
      context,
      CampaignProposal(
        title: title,
        description: description,
        locationName: locationName,
        startsAt: _startsAt.toUtc(),
        durationMinutes: duration!,
        volunteerCapacity: capacity!,
        minimumVolunteers: minimum!,
        // Rupees only for old servers; the paise value is authoritative.
        fundingGoal: fundingPaise! / 100,
        fundingGoalPaise: fundingPaise,
        requiredSkills: skills,
        checklist: checklist,
        evidenceInstructions: evidence,
        tags: tags,
        rationale:
            initial?.rationale ??
            'Entered manually by the sponsor. No AI model produced these details.',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final startInPast = !_startsAt.isAfter(DateTime.now());
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _cancel();
      },
      child: _buildDialog(context, startInPast),
    );
  }

  InputDecoration _field(String key, String label, {String? helper}) =>
      InputDecoration(
        labelText: label,
        helperText: helper,
        errorText: _errors[key],
        errorMaxLines: 2,
      );

  Widget _buildDialog(BuildContext context, bool startInPast) {
    final l10n = context.l10n;
    final localeTag = context.localeTag;
    final numbers = NumberFormat.decimalPattern(localeTag);
    String range(int minimum, int maximum) => l10n.sponsorProposalFormRange(
      numbers.format(minimum),
      numbers.format(maximum),
    );
    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      titlePadding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
      contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      actionsPadding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Text(
        widget.heading,
        style: Theme.of(context).textTheme.titleLarge,
      ),
      content: SizedBox(
        width: 560,
        height:
            (MediaQuery.sizeOf(context).height -
                    MediaQuery.viewInsetsOf(context).bottom -
                    240)
                .clamp(180.0, 620.0),
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.sponsorProposalFormBasics,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              FieldnoteTextField(
                controller: _title,
                textCapitalization: TextCapitalization.sentences,
                maxLength: CampaignLimits.titleMax,
                decoration: _field(
                  CampaignField.title,
                  l10n.sponsorProposalFormTitle,
                ),
              ),
              const SizedBox(height: 12),
              FieldnoteTextField(
                controller: _description,
                minLines: 3,
                maxLines: 5,
                textCapitalization: TextCapitalization.sentences,
                maxLength: CampaignLimits.descriptionMax,
                decoration: _field(
                  CampaignField.description,
                  l10n.sponsorProposalFormDescription,
                ),
              ),
              const SizedBox(height: 12),
              FieldnoteTextField(
                controller: _locationName,
                onChanged: (_) => _selectedLocation = null,
                decoration: _field(
                  CampaignField.location,
                  l10n.sponsorProposalFormLocation,
                ),
              ),
              if (widget.repository != null) ...[
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: _chooseLocation,
                  icon: const Icon(Icons.map_outlined),
                  label: Text(l10n.sponsorProposalFormChooseOnMap),
                ),
              ],
              const SizedBox(height: 18),
              Text(
                l10n.sponsorProposalFormSchedule,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              Text(
                l10n.sponsorProposalFormStartsAt,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _pickStart,
                  icon: const Icon(Icons.event_outlined),
                  label: Text(
                    DateFormat.yMMMEd(localeTag).add_jm().format(_startsAt),
                  ),
                ),
              ),
              if (startInPast || _errors[CampaignField.startsAt] != null) ...[
                const SizedBox(height: 6),
                Text(
                  _errors[CampaignField.startsAt] ??
                      l10n.sponsorProposalFormStartPassed,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 12,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              ResponsiveCardGrid(
                minimumItemWidth: 150,
                spacing: 16,
                children: [
                  FieldnoteTextField(
                    controller: _funding,
                    keyboardType: TextInputType.number,
                    decoration: _field(
                      CampaignField.funding,
                      l10n.sponsorProposalFormFunding,
                      helper: l10n.sponsorProposalFormRange(
                        formatPaise(
                          CampaignLimits.minimumGoalPaise,
                          localeTag: localeTag,
                        ),
                        formatPaise(
                          CampaignLimits.maximumGoalPaise,
                          localeTag: localeTag,
                        ),
                      ),
                    ),
                  ),
                  FieldnoteTextField(
                    controller: _capacity,
                    keyboardType: TextInputType.number,
                    decoration: _field(
                      CampaignField.capacity,
                      l10n.sponsorProposalFormPlaces,
                      helper: range(
                        CampaignLimits.minimumCapacity,
                        CampaignLimits.maximumCapacity,
                      ),
                    ),
                  ),
                  FieldnoteTextField(
                    controller: _minimum,
                    keyboardType: TextInputType.number,
                    decoration: _field(
                      CampaignField.minimum,
                      l10n.sponsorProposalFormMinimumTeam,
                    ),
                  ),
                  FieldnoteTextField(
                    controller: _duration,
                    keyboardType: TextInputType.number,
                    decoration: _field(
                      CampaignField.duration,
                      l10n.sponsorProposalFormMinutes,
                      helper: range(
                        CampaignLimits.minimumDurationMinutes,
                        CampaignLimits.maximumDurationMinutes,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                l10n.sponsorProposalFormWork,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              FieldnoteTextField(
                controller: _checklist,
                minLines: 3,
                maxLines: 6,
                decoration: _field(
                  CampaignField.checklist,
                  l10n.sponsorWorkChecklist,
                  helper: l10n.sponsorProposalFormOneTaskPerLine,
                ),
              ),
              const SizedBox(height: 12),
              FieldnoteTextField(
                controller: _skills,
                minLines: 1,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: l10n.sponsorProposalFormSkills,
                  helperText: l10n.sponsorProposalFormOnePerLine,
                ),
              ),
              const SizedBox(height: 12),
              FieldnoteTextField(
                controller: _evidence,
                minLines: 2,
                maxLines: 3,
                decoration: _field(
                  CampaignField.evidence,
                  l10n.sponsorProposalFormEvidence,
                ),
              ),
              const SizedBox(height: 12),
              FieldnoteTextField(
                controller: _tags,
                minLines: 1,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: l10n.sponsorProposalFormTags,
                  helperText: l10n.sponsorProposalFormOnePerLine,
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(
                  _error!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _submit,
            child: Text(widget.confirmLabel),
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: _cancel,
            child: Text(l10n.sponsorProposalFormCancel),
          ),
        ),
      ],
    );
  }
}
