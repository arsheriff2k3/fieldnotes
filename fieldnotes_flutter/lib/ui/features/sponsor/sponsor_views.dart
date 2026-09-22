import 'dart:async';
import 'dart:typed_data';

import 'package:fieldnotes_client/fieldnotes_client.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:record/record.dart';

import '../../../data/audio/wav_encoder.dart';
import '../../../data/services/device_location_service.dart';
import '../../../data/services/razorpay_checkout_service.dart';
import '../../core/fieldnote_theme.dart';
import '../../core/widgets.dart';
import '../shell/hackathon_view_model.dart';

class SponsorDiscoverView extends StatelessWidget {
  const SponsorDiscoverView({super.key, required this.viewModel});

  final HackathonViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: viewModel.refresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 100),
        children: [
          SectionHeading(
            eyebrow: 'Sponsor discovery',
            title: 'Fund work you can follow',
            description:
                'Every campaign connects funding to available volunteers and location-grounded evidence.',
            trailing: FilledButton.icon(
              onPressed: () => viewModel.selectSection(1),
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Create with AI'),
            ),
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) => GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: viewModel.campaigns.length,
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 520,
                mainAxisExtent: 350,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemBuilder: (context, index) {
                final campaign = viewModel.campaigns[index];
                return CampaignCard(
                  campaign: campaign,
                  actionLabel: 'Sponsor campaign',
                  onAction: () => _sponsor(context, campaign),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sponsor(BuildContext context, Campaign campaign) async {
    var amount = 5000.0;
    final note = TextEditingController();
    final checkout = RazorpayCheckoutService();
    RazorpayCheckoutOrder? createdOrder;
    var saving = false;
    try {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: Text('Sponsor ${campaign.name}'),
            content: SizedBox(
              width: 480,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: FieldnoteColors.acid.withValues(alpha: .4),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.verified_user_outlined),
                        SizedBox(width: 9),
                        Expanded(
                          child: Text(
                            'Razorpay Test Mode — real checkout and server signature verification; no real money moves.',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    children: [1000.0, 2500.0, 5000.0, 10000.0]
                        .map(
                          (value) => ChoiceChip(
                            label: Text(
                              '₹${NumberFormat.compact().format(value)}',
                            ),
                            selected: amount == value,
                            onSelected: (_) =>
                                setDialogState(() => amount = value),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: note,
                    decoration: const InputDecoration(
                      labelText: 'Message (optional)',
                      hintText: 'Why this campaign matters to you',
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: saving ? null : () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              FilledButton.icon(
                onPressed: saving
                    ? null
                    : () async {
                        setDialogState(() => saving = true);
                        try {
                          final order = await viewModel.createPaymentOrder(
                            campaign,
                            amount,
                            note.text,
                          );
                          createdOrder = order;
                          final result = await checkout.open(order);
                          await viewModel.verifyPayment(
                            order,
                            returnedOrderId: result.orderId,
                            paymentId: result.paymentId,
                            signature: result.signature,
                          );
                          if (dialogContext.mounted) {
                            Navigator.pop(dialogContext);
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Razorpay payment verified. Campaign impact updated.',
                                ),
                              ),
                            );
                          }
                        } catch (error) {
                          final order = createdOrder;
                          if (order != null) {
                            try {
                              await viewModel.repository.recordRazorpayFailure(
                                order.sponsorshipId,
                                _paymentError(error),
                              );
                            } catch (_) {}
                          }
                          if (dialogContext.mounted) {
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              SnackBar(content: Text(_paymentError(error))),
                            );
                          }
                        } finally {
                          if (dialogContext.mounted) {
                            setDialogState(() => saving = false);
                          }
                        }
                      },
                icon: const Icon(Icons.lock_outline),
                label: Text(
                  saving ? 'Opening Razorpay…' : 'Pay ₹${amount.round()}',
                ),
              ),
            ],
          ),
        ),
      );
    } finally {
      checkout.dispose();
      note.dispose();
    }
  }

  static String _paymentError(Object error) {
    if (error is FieldnoteException) return error.message;
    if (error is RazorpayCheckoutException) return error.message;
    return 'The Razorpay test payment was not completed.';
  }
}

class SponsorCreateView extends StatefulWidget {
  const SponsorCreateView({super.key, required this.viewModel});

  final HackathonViewModel viewModel;

  @override
  State<SponsorCreateView> createState() => _SponsorCreateViewState();
}

class _SponsorCreateViewState extends State<SponsorCreateView> {
  static const _examplePrompt =
      'I want to sponsor tree care near the university this Saturday. '
      'Budget is ₹25,000 and I need about 10 volunteers.';

  final _prompt = TextEditingController();
  final _promptFocus = FocusNode();
  final _location = DeviceLocationService();
  final _recorder = AudioRecorder();
  CampaignProposal? _proposal;
  DeviceLocation _campaignLocation = DeviceLocation.demoVenue;
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
  bool _microphoneBlocked = false;

  /// Recordings stop themselves here so a forgotten hold cannot run away.
  static const _maximumRecording = Duration(seconds: 90);

  bool get _busyWithAudio =>
      _working || _recording || _startingRecording || _transcribing;

  @override
  void dispose() {
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
    _promptFocus.unfocus();
    setState(() {
      _startingRecording = true;
      _stopAfterStart = false;
      _recordingDuration = Duration.zero;
    });
    try {
      if (!await _recorder.hasPermission()) {
        throw const _DictationFailure(
          'Microphone permission is required. Allow access and try again.',
        );
      }
      if (_stopAfterStart) {
        if (mounted) setState(() => _startingRecording = false);
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
      setState(() {
        _startingRecording = false;
        _microphoneBlocked = false;
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
      setState(() {
        _startingRecording = false;
        _microphoneBlocked = true;
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
    _recordingTimer?.cancel();
    setState(() {
      _recording = false;
      _transcribing = true;
    });
    try {
      await _recorder.stop();
      await _audioSubscription?.cancel();
      _audioSubscription = null;
      final pcmBytes = _audioBuffer.takeBytes();
      if (pcmBytes.isEmpty && _recorderStreamError != null) {
        throw const _DictationFailure(
          'The microphone stopped before any audio was captured. Check '
          'microphone access and try again.',
        );
      }
      if (duration < const Duration(seconds: 1) || pcmBytes.length < 1600) {
        throw const _DictationFailure(
          'Hold the microphone button while speaking for at least one second.',
        );
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
      setState(() => _transcribing = false);
      if (_prompt.text.trim().length < 20) {
        _notify(
          'Only a few words were heard. Hold the microphone again, or type the '
          'rest of the brief.',
        );
        return;
      }
      await _generate();
    } catch (error) {
      if (mounted) _notify(_dictationError(error));
    } finally {
      if (mounted) setState(() => _transcribing = false);
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

  static String _dictationError(Object error) {
    if (error is _DictationFailure) return error.message;
    if (error is FieldnoteException) return error.message;
    return 'The recording could not be transcribed. Try again, or type the '
        'brief.';
  }

  static String _formatDuration(Duration value) {
    final minutes = value.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = value.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _notify(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  /// Builds a campaign by hand, with no model call, and reuses the same
  /// sponsor-confirmed publish path as an AI proposal.
  Future<void> _createManually() async {
    final entered = await showProposalFormDialog(
      context,
      heading: 'Create a campaign manually',
      confirmLabel: 'Use these details',
      initial: null,
      seedPrompt: _prompt.text.trim(),
    );
    if (entered != null && mounted) setState(() => _proposal = entered);
  }

  Future<void> _generate() async {
    _promptFocus.unfocus();
    if (_prompt.text.trim().length < 20) {
      _notify(
        'Describe the cause, place, timing, and intended impact first, or '
        'create the campaign manually.',
      );
      return;
    }
    setState(() => _working = true);
    try {
      final value = await widget.viewModel.repository.proposeCampaign(
        _prompt.text,
      );
      if (mounted) setState(() => _proposal = value);
    } catch (error) {
      _message(error);
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  Future<void> _useLocation() async {
    final value = await _location.current();
    if (mounted) setState(() => _campaignLocation = value);
  }

  Future<void> _editProposal() async {
    final proposal = _proposal;
    if (proposal == null) return;
    final edited = await showProposalFormDialog(
      context,
      heading: 'Confirm campaign details',
      confirmLabel: 'Use these details',
      initial: proposal,
    );
    if (edited != null && mounted) setState(() => _proposal = edited);
  }

  Future<void> _publish() async {
    if (_proposal == null) return;
    setState(() => _working = true);
    try {
      final campaign = await widget.viewModel.publishCampaign(
        _proposal!,
        _campaignLocation.latitude,
        _campaignLocation.longitude,
      );
      if (!mounted) return;
      _proposal = null;
      widget.viewModel.selectSection(2);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${campaign.name} is live.')),
      );
    } catch (error) {
      _message(error);
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  void _message(Object error) {
    final text = error is FieldnoteException
        ? error.message
        : 'Could not generate the campaign.';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 100),
      children: [
        const SectionHeading(
          eyebrow: 'AI campaign studio',
          title: 'Turn intent into action',
          description:
              'Describe the outcome. AI proposes the schedule, volunteer requirement, checklist, funding goal, and evidence standard.',
        ),
        const SizedBox(height: 24),
        LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 900;
            final prompt = SurfaceCard(
              color: FieldnoteColors.ink,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'What do you want to make happen?',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Hold the microphone while you speak, then release. '
                    'Typing works too.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _prompt,
                    focusNode: _promptFocus,
                    minLines: 7,
                    maxLines: 10,
                    enabled: !_recording && !_transcribing,
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.newline,
                    textCapitalization: TextCapitalization.sentences,
                    onChanged: (_) => setState(() {}),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: _recording
                          ? 'Listening…'
                          : 'Cause, place, date, budget, and volunteers…',
                      hintStyle: const TextStyle(color: Colors.white54),
                      fillColor: Colors.white.withValues(alpha: .09),
                      suffixIcon: _prompt.text.isEmpty || _recording
                          ? null
                          : IconButton(
                              tooltip: 'Clear',
                              icon: const Icon(
                                Icons.close,
                                color: Colors.white54,
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
                          _prompt.text = _examplePrompt;
                          _prompt.selection = TextSelection.collapsed(
                            offset: _prompt.text.length,
                          );
                        }),
                        style: TextButton.styleFrom(
                          foregroundColor: FieldnoteColors.acid,
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 32),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text('Start from an example brief'),
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  _HoldToSpeakButton(
                    recording: _recording,
                    starting: _startingRecording,
                    transcribing: _transcribing,
                    enabled: !_working,
                    blocked: _microphoneBlocked,
                    label: _recording
                        ? 'Recording ${_formatDuration(_recordingDuration)} — release to create'
                        : _transcribing
                        ? 'Transcribing…'
                        : _startingRecording
                        ? 'Starting the microphone…'
                        : 'Hold to speak',
                    onPressStart: _startRecording,
                    onPressEnd: _releaseRecording,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _busyWithAudio ? null : _generate,
                      style: FilledButton.styleFrom(
                        backgroundColor: FieldnoteColors.acid,
                        foregroundColor: FieldnoteColors.ink,
                      ),
                      icon: const Icon(Icons.auto_awesome),
                      label: Text(
                        _working ? 'Structuring…' : 'Generate campaign',
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _busyWithAudio ? null : _createManually,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: BorderSide(
                          color: Colors.white.withValues(alpha: .35),
                        ),
                      ),
                      icon: const Icon(Icons.edit_note),
                      label: const Text('Enter campaign details manually'),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Manual entry never calls a model, so it keeps working when '
                    'the AI provider is busy.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),
            );
            final result = _proposal == null
                ? const EmptyPanel(
                    icon: Icons.auto_awesome_outlined,
                    title: 'Your campaign proposal appears here',
                    message:
                        'The generated result remains editable and sponsor-confirmed.',
                  )
                : _ProposalCard(
                    proposal: _proposal!,
                    location: _campaignLocation,
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
              children: [prompt, const SizedBox(height: 18), result],
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
    required this.location,
    required this.onUseLocation,
    required this.onEdit,
    required this.onPublish,
  });

  final CampaignProposal proposal;
  final DeviceLocation location;
  final VoidCallback onUseLocation;
  final VoidCallback onEdit;
  final VoidCallback? onPublish;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const StatusPill(
                label: 'AI proposal',
                color: FieldnoteColors.clay,
                icon: Icons.auto_awesome,
              ),
              const Spacer(),
              Text(
                '₹${NumberFormat.compact().format(proposal.fundingGoal)} goal',
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
            Icons.schedule,
            DateFormat(
              'EEE, d MMM · h:mm a',
            ).format(proposal.startsAt.toLocal()),
          ),
          _detail(
            Icons.group_outlined,
            '${proposal.volunteerCapacity} volunteers · ${proposal.durationMinutes ~/ 60} hours',
          ),
          _detail(
            Icons.location_on_outlined,
            '${proposal.locationName} · ${location.isLive ? 'live GPS' : 'demo venue'}',
          ),
          const Divider(height: 28),
          Text(
            'AI work checklist',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          ...proposal.checklist.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    size: 18,
                    color: FieldnoteColors.forest,
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
                  label: const Text('Edit'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onUseLocation,
                  icon: const Icon(Icons.my_location),
                  label: const Text('Use GPS'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: onPublish,
                  icon: const Icon(Icons.rocket_launch_outlined),
                  label: const Text('Publish'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _detail(IconData icon, String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      children: [
        Icon(icon, size: 18, color: FieldnoteColors.moss),
        const SizedBox(width: 8),
        Expanded(child: Text(text)),
      ],
    ),
  );
}

class SponsorImpactView extends StatelessWidget {
  const SponsorImpactView({super.key, required this.viewModel});

  final HackathonViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final campaigns = <Campaign>[
      ...viewModel.createdCampaigns,
      ...viewModel.campaigns.where(
        (campaign) =>
            viewModel.sponsorships.any(
              (item) => item.campaignId == campaign.id,
            ) &&
            !viewModel.createdCampaigns.any((item) => item.id == campaign.id),
      ),
    ];
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 100),
      children: [
        SectionHeading(
          eyebrow: 'Live sponsor impact',
          title: 'Proof, not promises',
          description:
              'Serverpod streams new volunteer activity into evidence-backed campaign outcomes.',
          trailing: viewModel.lastLiveUpdate == null
              ? null
              : const StatusPill(
                  label: 'Live connected',
                  color: FieldnoteColors.forest,
                  icon: Icons.sensors,
                ),
        ),
        const SizedBox(height: 24),
        if (campaigns.isEmpty)
          const EmptyPanel(
            icon: Icons.insights_outlined,
            title: 'No sponsored impact yet',
            message: 'Create or sponsor a campaign to begin the evidence loop.',
          )
        else
          ...campaigns.map(
            (campaign) => Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: _ImpactCard(
                campaign: campaign,
                impact: viewModel.impacts[campaign.id],
                viewModel: viewModel,
              ),
            ),
          ),
      ],
    );
  }
}

class _ImpactCard extends StatelessWidget {
  const _ImpactCard({
    required this.campaign,
    required this.impact,
    required this.viewModel,
  });

  final Campaign campaign;
  final ImpactSummary? impact;
  final HackathonViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final value = impact;
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  campaign.name,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              IconButton(
                tooltip: 'Listen for this campaign',
                onPressed: () => viewModel.subscribeToCampaign(campaign.id!),
                icon: const Icon(Icons.sensors),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(value?.summary ?? 'Loading campaign impact…'),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _ImpactMetric(
                label: 'Sponsored',
                value:
                    '₹${NumberFormat.compact().format(value?.sponsorshipTotal ?? campaign.sponsoredAmount)}',
              ),
              _ImpactMetric(
                label: 'Joined',
                value: '${value?.joinedVolunteers ?? 0}',
              ),
              _ImpactMetric(
                label: 'Completed',
                value: '${value?.completedVolunteers ?? 0}',
              ),
              _ImpactMetric(
                label: 'Evidence',
                value: '${value?.evidenceCount ?? 0}',
              ),
            ],
          ),
          if (value != null && value.recentEvidence.isNotEmpty) ...[
            const Divider(height: 30),
            Text(
              'Verified field evidence',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 210,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: value.recentEvidence.length,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final evidence = value.recentEvidence[index];
                  return SizedBox(
                    width: 280,
                    child: _EvidenceTile(
                      evidence: evidence,
                      viewModel: viewModel,
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
  const _EvidenceTile({required this.evidence, required this.viewModel});

  final CompletionEvidence evidence;
  final HackathonViewModel viewModel;

  @override
  State<_EvidenceTile> createState() => _EvidenceTileState();
}

class _EvidenceTileState extends State<_EvidenceTile> {
  late final Future<String>? _photoUrl = widget.evidence.id == null
      ? null
      : widget.viewModel.repository.evidenceUrl(widget.evidence.id!);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: DecoratedBox(
        decoration: const BoxDecoration(color: FieldnoteColors.mist),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 92,
              width: double.infinity,
              child: _photoUrl == null
                  ? const ColoredBox(
                      color: FieldnoteColors.ink,
                      child: Icon(Icons.photo_outlined, color: Colors.white54),
                    )
                  : FutureBuilder<String>(
                      future: _photoUrl,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const ColoredBox(
                            color: FieldnoteColors.ink,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: FieldnoteColors.acid,
                                strokeWidth: 2,
                              ),
                            ),
                          );
                        }
                        return Image.network(
                          snapshot.data!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => const ColoredBox(
                            color: FieldnoteColors.ink,
                            child: Icon(
                              Icons.hide_image_outlined,
                              color: Colors.white54,
                            ),
                          ),
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
                    StatusPill(
                      label: widget.evidence.locationIsDemo
                          ? 'Demo GPS · labeled'
                          : 'Location integrity passed',
                      color: widget.evidence.locationIsDemo
                          ? FieldnoteColors.clay
                          : FieldnoteColors.forest,
                      icon: widget.evidence.locationIsDemo
                          ? Icons.science_outlined
                          : Icons.gps_fixed,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.evidence.confirmedSummary,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
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
        color: FieldnoteColors.acid.withValues(alpha: .35),
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
    this.score,
    this.reasons = const [],
  });

  final Campaign campaign;
  final String actionLabel;
  final VoidCallback? onAction;
  final double? score;
  final List<String> reasons;

  @override
  Widget build(BuildContext context) {
    final progress = campaign.fundingGoal <= 0
        ? 0.0
        : (campaign.sponsoredAmount / campaign.fundingGoal)
              .clamp(0, 1)
              .toDouble();
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (score != null)
                StatusPill(
                  label: '${score!.round()}% match',
                  color: score! >= 75
                      ? FieldnoteColors.forest
                      : FieldnoteColors.clay,
                  icon: Icons.auto_awesome,
                )
              else
                const StatusPill(
                  label: 'Open campaign',
                  color: FieldnoteColors.forest,
                  icon: Icons.public,
                ),
              const Spacer(),
              Text('${campaign.volunteerCapacity} places'),
            ],
          ),
          const SizedBox(height: 14),
          Text(campaign.name, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 6),
          Text(
            campaign.description,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Text(
            '${campaign.locationName} · ${DateFormat('EEE, d MMM').format(campaign.startsAt.toLocal())}',
            style: Theme.of(context).textTheme.labelMedium,
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
                        const Icon(
                          Icons.check,
                          size: 15,
                          color: FieldnoteColors.moss,
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            reason,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          ],
          const Spacer(),
          LinearProgressIndicator(
            minHeight: 8,
            value: progress,
            borderRadius: BorderRadius.circular(99),
            color: FieldnoteColors.clay,
            backgroundColor: FieldnoteColors.clay.withValues(alpha: .12),
          ),
          const SizedBox(height: 6),
          Text(
            '₹${NumberFormat.compact().format(campaign.sponsoredAmount)} of ₹${NumberFormat.compact().format(campaign.fundingGoal)}',
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(onPressed: onAction, child: Text(actionLabel)),
          ),
        ],
      ),
    );
  }
}

/// Press-and-hold microphone control. Recording starts on pointer down and the
/// campaign is generated as soon as the sponsor lets go.
/// Press-and-hold microphone control. Recording starts on pointer down, and on
/// release the audio is transcribed by the server and the campaign generated.
class _HoldToSpeakButton extends StatelessWidget {
  const _HoldToSpeakButton({
    required this.recording,
    required this.starting,
    required this.transcribing,
    required this.enabled,
    required this.blocked,
    required this.label,
    required this.onPressStart,
    required this.onPressEnd,
  });

  final bool recording;
  final bool starting;
  final bool transcribing;
  final bool enabled;
  final bool blocked;
  final String label;
  final Future<void> Function() onPressStart;
  final Future<void> Function() onPressEnd;

  @override
  Widget build(BuildContext context) {
    final busy = starting || transcribing;
    final interactive = enabled && !transcribing;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          button: true,
          enabled: interactive,
          label: 'Hold to speak your campaign brief',
          child: MouseRegion(
            cursor: interactive
                ? SystemMouseCursors.click
                : SystemMouseCursors.basic,
            child: Listener(
              // The child is only a decoration plus text, so the hold control
              // needs its own hit target.
              behavior: HitTestBehavior.opaque,
              onPointerDown: interactive ? (_) => onPressStart() : null,
              onPointerUp: interactive ? (_) => onPressEnd() : null,
              onPointerCancel: interactive ? (_) => onPressEnd() : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                height: 56,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: recording
                      ? FieldnoteColors.clay
                      : Colors.white.withValues(alpha: enabled ? .14 : .06),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: recording
                        ? FieldnoteColors.clay
                        : Colors.white.withValues(alpha: .28),
                    width: recording ? 2 : 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (busy)
                      const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    else
                      Icon(
                        recording ? Icons.stop_rounded : Icons.mic_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (blocked && !recording && !busy) ...[
          const SizedBox(height: 8),
          Text(
            'The microphone could not be used here. Allow microphone access, '
            'type the brief, or enter the details manually.',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: FieldnoteColors.acid),
          ),
        ],
      ],
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
}) {
  return showDialog<CampaignProposal>(
    context: context,
    builder: (dialogContext) => _ProposalFormDialog(
      heading: heading,
      confirmLabel: confirmLabel,
      initial: initial,
      seedPrompt: seedPrompt,
    ),
  );
}

class _ProposalFormDialog extends StatefulWidget {
  const _ProposalFormDialog({
    required this.heading,
    required this.confirmLabel,
    required this.initial,
    required this.seedPrompt,
  });

  final String heading;
  final String confirmLabel;
  final CampaignProposal? initial;
  final String seedPrompt;

  @override
  State<_ProposalFormDialog> createState() => _ProposalFormDialogState();
}

class _ProposalFormDialogState extends State<_ProposalFormDialog> {
  late final TextEditingController _title;
  late final TextEditingController _description;
  late final TextEditingController _locationName;
  late final TextEditingController _funding;
  late final TextEditingController _capacity;
  late final TextEditingController _duration;
  late final TextEditingController _skills;
  late final TextEditingController _checklist;
  late final TextEditingController _evidence;
  late final TextEditingController _tags;
  late DateTime _startsAt;
  String? _error;

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
      text: (initial?.fundingGoal ?? 25000).toStringAsFixed(0),
    );
    _capacity = TextEditingController(
      text: (initial?.volunteerCapacity ?? 10).toString(),
    );
    _duration = TextEditingController(
      text: (initial?.durationMinutes ?? 180).toString(),
    );
    _skills = TextEditingController(
      text: (initial?.requiredSkills ?? const ['No specialist skills']).join(
        '\n',
      ),
    );
    _checklist = TextEditingController(
      text: (initial?.checklist ?? const <String>[]).join('\n'),
    );
    _evidence = TextEditingController(
      text:
          initial?.evidenceInstructions ??
          'Submit a location-verified photograph and describe the completed work.',
    );
    _tags = TextEditingController(
      text: (initial?.tags ?? const ['community']).join('\n'),
    );
    _startsAt = initial?.startsAt.toLocal() ?? _nextSaturdayMorning();
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _locationName.dispose();
    _funding.dispose();
    _capacity.dispose();
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
    final funding = double.tryParse(_funding.text.trim());
    final capacity = int.tryParse(_capacity.text.trim());
    final duration = int.tryParse(_duration.text.trim());
    final checklist = _lines(_checklist.text);
    final evidence = _evidence.text.trim();

    final problem = switch (null) {
      _ when title.length < 4 => 'Give the campaign a title.',
      _ when description.length < 20 =>
        'Describe the work in at least 20 characters.',
      _ when locationName.isEmpty => 'Name the location.',
      _ when _startsAt.isBefore(DateTime.now()) =>
        'Choose a start date and time in the future.',
      _ when duration == null || duration < 30 || duration > 720 =>
        'Duration must be between 30 and 720 minutes.',
      _ when capacity == null || capacity < 1 || capacity > 1000 =>
        'Volunteer places must be between 1 and 1000.',
      _ when funding == null || funding < 100 =>
        'Funding goal must be at least ₹100.',
      _ when checklist.isEmpty => 'Add at least one checklist task.',
      _ when evidence.length < 10 => 'Describe the evidence volunteers submit.',
      _ => null,
    };
    if (problem != null) {
      setState(() => _error = problem);
      return;
    }

    final initial = widget.initial;
    Navigator.pop(
      context,
      CampaignProposal(
        title: title,
        description: description,
        locationName: locationName,
        startsAt: _startsAt.toUtc(),
        durationMinutes: duration!,
        volunteerCapacity: capacity!,
        fundingGoal: funding!,
        requiredSkills: _lines(_skills.text),
        checklist: checklist,
        evidenceInstructions: evidence,
        tags: _lines(_tags.text),
        rationale:
            initial?.rationale ??
            'Entered manually by the sponsor. No AI model produced these details.',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.heading),
      content: SizedBox(
        width: 560,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _title,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(labelText: 'Campaign title'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _description,
                minLines: 2,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _locationName,
                decoration: const InputDecoration(labelText: 'Location name'),
              ),
              const SizedBox(height: 10),
              InputDecorator(
                decoration: const InputDecoration(labelText: 'Starts at'),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        DateFormat(
                          'EEE, d MMM yyyy · h:mm a',
                        ).format(_startsAt),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _pickStart,
                      icon: const Icon(Icons.event, size: 18),
                      label: const Text('Change'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _funding,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Funding goal (₹)',
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _capacity,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Volunteer places',
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _duration,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Minutes',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _checklist,
                minLines: 3,
                maxLines: 6,
                decoration: const InputDecoration(
                  labelText: 'Work checklist',
                  helperText: 'One task per line',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _skills,
                minLines: 1,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Required skills',
                  helperText: 'One per line',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _evidence,
                minLines: 2,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Evidence instructions',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _tags,
                minLines: 1,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Tags',
                  helperText: 'One per line',
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
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _submit, child: Text(widget.confirmLabel)),
      ],
    );
  }
}
