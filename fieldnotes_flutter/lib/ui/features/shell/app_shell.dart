import 'package:flutter/material.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

import '../../../client.dart';
import '../../../data/repositories/fieldnote_repository.dart';
import '../../core/fieldnote_theme.dart';
import '../../core/widgets.dart';
import '../onboarding/onboarding_view.dart';
import '../sponsor/sponsor_views.dart';
import '../trust/trust_center_view.dart';
import '../volunteer/volunteer_views.dart';
import 'hackathon_view_model.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late final HackathonViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = HackathonViewModel(FieldnoteRepository())..initialize();
  }

  @override
  void dispose() {
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
                SponsorCreateView(viewModel: _viewModel),
                SponsorImpactView(viewModel: _viewModel),
                TrustCenterView(viewModel: _viewModel),
                _ProfileView(viewModel: _viewModel),
              ]
            : <Widget>[
                VolunteerMatchesView(viewModel: _viewModel),
                VolunteerWorkView(viewModel: _viewModel),
                VolunteerAvailabilityView(viewModel: _viewModel),
                TrustCenterView(viewModel: _viewModel),
                _ProfileView(viewModel: _viewModel),
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
                ],
              ),
              bottomNavigationBar: desktop
                  ? null
                  : NavigationBar(
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
            );
          },
        );
      },
    );
  }
}

class _DesktopNavigation extends StatelessWidget {
  const _DesktopNavigation({
    required this.viewModel,
    required this.destinations,
  });

  final HackathonViewModel viewModel;
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
                      viewModel.profile!.city,
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

class _ProfileView extends StatelessWidget {
  const _ProfileView({required this.viewModel});

  final HackathonViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final profile = viewModel.profile!;
    final roleName = viewModel.isSponsor ? 'Sponsor' : 'Volunteer';
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 100),
      children: [
        SectionHeading(
          eyebrow: '$roleName account',
          title: profile.displayName,
          description:
              '${profile.city} · ${profile.interests.split('|').map((value) => value.trim()).where((value) => value.isNotEmpty).join(' · ')}',
          trailing: OutlinedButton.icon(
            onPressed: viewModel.refresh,
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh data'),
          ),
        ),
        const SizedBox(height: 24),
        SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 62,
                    height: 62,
                    decoration: BoxDecoration(
                      color: FieldnoteColors.acid,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      viewModel.isSponsor
                          ? Icons.volunteer_activism_outlined
                          : Icons.directions_walk_outlined,
                      size: 31,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$roleName account',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(
                          viewModel.isSponsor
                              ? profile.organizationName?.isNotEmpty == true
                                    ? profile.organizationName!
                                    : profile.sponsorType ??
                                          'Individual sponsor'
                              : '${profile.skills.split('|').where((value) => value.trim().isNotEmpty).length} volunteer skills',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 32),
              const Text(
                'This hackathon MVP intentionally has two roles only. Sponsors create and fund campaigns; volunteers publish availability, join work, and submit verified evidence.',
              ),
              const SizedBox(height: 22),
              OutlinedButton.icon(
                onPressed: () async {
                  final signedOut = await client.auth.signOutDevice();
                  if (!signedOut && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Could not sign out this device.'),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.logout),
                label: const Text('Sign out'),
              ),
            ],
          ),
        ),
      ],
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
