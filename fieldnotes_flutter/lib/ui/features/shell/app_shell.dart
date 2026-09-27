import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../data/repositories/fieldnote_repository.dart';
import '../../core/fieldnote_theme.dart';
import '../../core/widgets.dart';
import '../onboarding/onboarding_view.dart';
import '../volunteer/shared_campaign_view.dart';
import '../profile/profile_view.dart';
import '../sponsor/sponsor_views.dart';
import '../trust/trust_center_view.dart';
import '../volunteer/volunteer_views.dart';
import 'fieldnote_view_model.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.campaignLink});

  final ValueNotifier<int?> campaignLink;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late final FieldnoteViewModel _viewModel;
  late final SponsorVoiceActionController _sponsorVoiceController;
  bool _openingCampaignLink = false;

  @override
  void initState() {
    super.initState();
    _sponsorVoiceController = SponsorVoiceActionController();
    _viewModel = FieldnoteViewModel(FieldnoteRepository())..initialize();
    widget.campaignLink.addListener(_openCampaignLinkIfReady);
    _viewModel.addListener(_openCampaignLinkIfReady);
  }

  @override
  void didUpdateWidget(AppShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.campaignLink != widget.campaignLink) {
      oldWidget.campaignLink.removeListener(_openCampaignLinkIfReady);
      widget.campaignLink.addListener(_openCampaignLinkIfReady);
    }
  }

  void _openCampaignLinkIfReady() {
    final id = widget.campaignLink.value;
    if (!mounted ||
        _openingCampaignLink ||
        id == null ||
        _viewModel.loading ||
        _viewModel.profile == null ||
        _viewModel.needsConsentForCurrentPolicy) {
      return;
    }
    _openingCampaignLink = true;
    widget.campaignLink.value = null;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final campaign = await _viewModel.repository.sharedCampaign(id);
        if (!mounted) return;
        if (campaign == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('This campaign is no longer open.')),
          );
          return;
        }
        await Navigator.of(context).push<void>(
          MaterialPageRoute(
            builder: (_) => SharedCampaignView(
              campaign: campaign,
              viewModel: _viewModel,
            ),
          ),
        );
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open the campaign link. Try again.'),
            ),
          );
        }
      } finally {
        _openingCampaignLink = false;
        if (mounted) _openCampaignLinkIfReady();
      }
    });
  }

  @override
  void dispose() {
    widget.campaignLink.removeListener(_openCampaignLinkIfReady);
    _viewModel.removeListener(_openCampaignLinkIfReady);
    _sponsorVoiceController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        if (_viewModel.loading) return const Scaffold(body: _LoadingView());
        if (_viewModel.errorMessage != null && _viewModel.profile == null) {
          return Scaffold(
            body: _ErrorView(
              message: _viewModel.errorMessage!,
              onRetry: _viewModel.initialize,
            ),
          );
        }
        if (_viewModel.needsOnboarding) {
          return OnboardingView(viewModel: _viewModel);
        }
        if (_viewModel.needsConsent) {
          return LegalConsentGate(viewModel: _viewModel);
        }

        final destinations = _viewModel.isSponsor
            ? const [
                _Destination('Discover', Icons.explore_outlined, Icons.explore),
                _Destination(
                  'Create',
                  Icons.auto_awesome_outlined,
                  Icons.auto_awesome,
                ),
                _Destination('Impact', Icons.insights_outlined, Icons.insights),
                _Destination(
                  'Trust',
                  Icons.shield_outlined,
                  Icons.shield,
                ),
                _Destination('Profile', Icons.person_outline, Icons.person),
              ]
            : const [
                _Destination(
                  'Matches',
                  Icons.travel_explore_outlined,
                  Icons.travel_explore,
                ),
                _Destination('My work', Icons.hiking_outlined, Icons.hiking),
                _Destination(
                  'Availability',
                  Icons.event_available_outlined,
                  Icons.event_available,
                ),
                _Destination(
                  'Trust',
                  Icons.shield_outlined,
                  Icons.shield,
                ),
                _Destination('Profile', Icons.person_outline, Icons.person),
              ];
        final pages = _viewModel.isSponsor
            ? <Widget>[
                SponsorDiscoverView(viewModel: _viewModel),
                SponsorCreateView(
                  viewModel: _viewModel,
                  voiceController: _sponsorVoiceController,
                ),
                SponsorImpactView(viewModel: _viewModel),
                TrustCenterView(viewModel: _viewModel),
                ProfileView(viewModel: _viewModel),
              ]
            : <Widget>[
                VolunteerMatchesView(viewModel: _viewModel),
                VolunteerWorkView(viewModel: _viewModel),
                VolunteerAvailabilityView(viewModel: _viewModel),
                TrustCenterView(viewModel: _viewModel),
                ProfileView(
                  viewModel: _viewModel,
                  onEditAvailability: () => _viewModel.selectSection(2),
                ),
              ];

        return LayoutBuilder(
          builder: (context, constraints) {
            final desktop = constraints.maxWidth >= 920;
            return Scaffold(
              body: Row(
                children: [
                  if (desktop)
                    _DesktopNavigation(
                      viewModel: _viewModel,
                      destinations: destinations,
                    ),
                  Expanded(
                    child: SafeArea(
                      top: !desktop,
                      bottom: false,
                      child: Stack(
                        children: [
                          IndexedStack(
                            index: _viewModel.selectedIndex,
                            children: pages,
                          ),
                          if (_viewModel.working)
                            const Positioned(
                              left: 0,
                              top: 0,
                              right: 0,
                              child: LinearProgressIndicator(minHeight: 3),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              bottomNavigationBar: desktop
                  ? null
                  : _viewModel.isSponsor
                  ? _SponsorBottomBar(
                      controller: _sponsorVoiceController,
                      selectedIndex: _viewModel.selectedIndex,
                      onSelected: _viewModel.selectSection,
                    )
                  : NavigationBar(
                      height: 72,
                      animationDuration: const Duration(milliseconds: 180),
                      selectedIndex: _viewModel.selectedIndex,
                      onDestinationSelected: _viewModel.selectSection,
                      destinations: destinations
                          .map(
                            (item) => NavigationDestination(
                              icon: Icon(item.icon),
                              selectedIcon: Icon(item.selectedIcon),
                              label: item.label,
                            ),
                          )
                          .toList(),
                    ),
              floatingActionButton: desktop || !_viewModel.isSponsor
                  ? null
                  : _SponsorVoiceButton(
                      controller: _sponsorVoiceController,
                      selected: _viewModel.selectedIndex == 1,
                      onOpenCreate: () => _viewModel.selectSection(1),
                    ),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerDocked,
            );
          },
        );
      },
    );
  }
}

class _SponsorBottomBar extends StatefulWidget {
  const _SponsorBottomBar({
    required this.controller,
    required this.selectedIndex,
    required this.onSelected,
  });

  final SponsorVoiceActionController controller;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  State<_SponsorBottomBar> createState() => _SponsorBottomBarState();
}

class _SponsorBottomBarState extends State<_SponsorBottomBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _wave = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1050),
  );

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_statusChanged);
    _statusChanged();
  }

  @override
  void didUpdateWidget(_SponsorBottomBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_statusChanged);
      widget.controller.addListener(_statusChanged);
      _statusChanged();
    }
  }

  void _statusChanged() {
    if (widget.controller.captureActive) {
      if (!_wave.isAnimating) _wave.repeat(reverse: true);
    } else if (_wave.isAnimating || _wave.value != 0) {
      _wave.reset();
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_statusChanged);
    _wave.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 92,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: -145,
            height: 160,
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _wave,
                builder: (context, _) => CustomPaint(
                  painter: _VoiceSemicirclePainter(
                    progress: _wave.value,
                    visible: widget.controller.captureActive,
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: BottomAppBar(
              elevation: 12,
              color: FieldnoteColors.mist,
              shape: const CircularNotchedRectangle(),
              notchMargin: 9,
              padding: EdgeInsets.zero,
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    _item(0, Icons.explore_outlined, Icons.explore, 'Discover'),
                    _item(2, Icons.insights_outlined, Icons.insights, 'Impact'),
                    const SizedBox(width: 70),
                    _item(3, Icons.shield_outlined, Icons.shield, 'Trust'),
                    _item(4, Icons.person_outline, Icons.person, 'Profile'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _item(int index, IconData icon, IconData selectedIcon, String label) {
    final selected = widget.selectedIndex == index;
    return Expanded(
      child: InkResponse(
        onTap: () => widget.onSelected(index),
        radius: 34,
        child: Semantics(
          button: true,
          selected: selected,
          label: label,
          child: Padding(
            padding: const EdgeInsets.only(top: 5, bottom: 3),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedScale(
                  scale: selected ? 1.08 : 1,
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOutCubic,
                  child: Icon(
                    selected ? selectedIcon : icon,
                    size: 21,
                    color: selected
                        ? FieldnoteColors.forest
                        : FieldnoteColors.ink.withValues(alpha: .68),
                  ),
                ),
                const SizedBox(height: 1),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOutCubic,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                    color: selected
                        ? FieldnoteColors.forest
                        : FieldnoteColors.ink.withValues(alpha: .68),
                  ),
                  child: Text(label, maxLines: 1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SponsorVoiceButton extends StatefulWidget {
  const _SponsorVoiceButton({
    required this.controller,
    required this.selected,
    required this.onOpenCreate,
  });

  final SponsorVoiceActionController controller;
  final bool selected;
  final VoidCallback onOpenCreate;

  @override
  State<_SponsorVoiceButton> createState() => _SponsorVoiceButtonState();
}

class _SponsorVoiceButtonState extends State<_SponsorVoiceButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 760),
  );
  bool _holding = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_statusChanged);
  }

  void _statusChanged() {
    if (!mounted) return;
    if (widget.controller.captureActive) {
      if (!_pulse.isAnimating) _pulse.repeat(reverse: true);
    } else if (!_holding) {
      _pulse.reset();
    }
    setState(() {});
  }

  void _pressStart() {
    if (!widget.controller.canRecord) return;
    widget.onOpenCreate();
    setState(() => _holding = true);
    _pulse.repeat(reverse: true);
    widget.controller.pressStart();
  }

  void _pressEnd() {
    if (!_holding) return;
    setState(() => _holding = false);
    widget.controller.pressEnd();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_statusChanged);
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final active = _holding || widget.controller.captureActive;
    final processing = widget.controller.processing;
    final enabled = widget.controller.canRecord || widget.controller.recording;
    final icon = widget.controller.recording
        ? Icons.stop_rounded
        : Icons.mic_rounded;
    final idleColor = processing
        ? FieldnoteColors.moss
        : FieldnoteColors.forest;
    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.controller.recording
          ? 'Recording. Release to finish.'
          : processing
          ? 'Campaign generation in progress'
          : 'Hold to record a campaign brief',
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: enabled ? (_) => _pressStart() : null,
        onPointerUp: enabled ? (_) => _pressEnd() : null,
        onPointerCancel: enabled ? (_) => _pressEnd() : null,
        child: AnimatedBuilder(
          animation: _pulse,
          builder: (context, _) => Transform.scale(
            scale: active ? 1 + (_pulse.value * .08) : 1,
            child: Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: active ? FieldnoteColors.clay : idleColor,
                border: Border.all(
                  color: FieldnoteColors.paper,
                  width: 5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (active ? FieldnoteColors.clay : idleColor)
                        .withValues(alpha: .3 + (_pulse.value * .2)),
                    blurRadius: 14 + (_pulse.value * 18),
                    spreadRadius: _pulse.value * 5,
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 27),
            ),
          ),
        ),
      ),
    );
  }
}

class _VoiceSemicirclePainter extends CustomPainter {
  const _VoiceSemicirclePainter({
    required this.progress,
    required this.visible,
  });

  final double progress;
  final bool visible;

  @override
  void paint(Canvas canvas, Size size) {
    if (!visible && progress == 0) return;
    final center = Offset(size.width / 2, size.height);
    for (var index = 0; index < 3; index++) {
      final phase = (progress + (index * .22)).clamp(0.0, 1.0);
      final radius = 52 + (phase * size.width * .42);
      final paint = Paint()
        ..color = FieldnoteColors.clay.withValues(
          alpha: (1 - phase) * (.17 - (index * .035)),
        )
        ..style = PaintingStyle.fill;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        math.pi,
        math.pi,
        true,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_VoiceSemicirclePainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.visible != visible;
}

class _DesktopNavigation extends StatelessWidget {
  const _DesktopNavigation({
    required this.viewModel,
    required this.destinations,
  });

  final FieldnoteViewModel viewModel;
  final List<_Destination> destinations;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: FieldnoteColors.ink,
      padding: const EdgeInsets.fromLTRB(18, 28, 18, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(
            children: [
              Icon(Icons.eco, color: FieldnoteColors.acid),
              SizedBox(width: 9),
              Text(
                'FIELDNOTE',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.4,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            viewModel.isSponsor ? 'SPONSOR WORKSPACE' : 'VOLUNTEER WORKSPACE',
            style: TextStyle(
              color: FieldnoteColors.acid.withValues(alpha: .72),
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 36),
          ...destinations.indexed.map((entry) {
            final index = entry.$1;
            final item = entry.$2;
            final selected = viewModel.selectedIndex == index;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Material(
                color: selected
                    ? FieldnoteColors.acid.withValues(alpha: .14)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
                child: ListTile(
                  selected: selected,
                  selectedColor: FieldnoteColors.acid,
                  textColor: Colors.white70,
                  iconColor: Colors.white54,
                  leading: Icon(selected ? item.selectedIcon : item.icon),
                  title: Text(item.label),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  onTap: () => viewModel.selectSection(index),
                ),
              ),
            );
          }),
          const Spacer(),
          Row(
            children: [
              CircleAvatar(
                backgroundColor: FieldnoteColors.acid,
                foregroundColor: FieldnoteColors.ink,
                child: Text(
                  viewModel.profile!.displayName.characters.first.toUpperCase(),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      viewModel.profile!.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      viewModel.isSponsor
                          ? viewModel.profile!.locationAddress ??
                                viewModel.profile!.city
                          : viewModel.profile!.city,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.eco, size: 44, color: FieldnoteColors.forest),
          const SizedBox(height: 18),
          Text(
            'Preparing your impact workspace…',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 14),
          const SizedBox(width: 180, child: LinearProgressIndicator()),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              EmptyPanel(
                icon: Icons.cloud_off_outlined,
                title: 'Local server unavailable',
                message: message,
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Try again'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Destination {
  const _Destination(this.label, this.icon, this.selectedIcon);

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}
