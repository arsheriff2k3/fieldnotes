import 'package:fieldnotes_client/fieldnotes_client.dart';
import 'package:flutter/material.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

import '../client.dart';
import '../data/services/pending_role_service.dart';
import '../ui/core/fieldnote_theme.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key, required this.child});

  final Widget child;

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _pendingRole = PendingRoleService();
  bool _isSignedIn = false;
  bool _showAuth = false;
  AccountRole? _selectedRole;

  @override
  void initState() {
    super.initState();
    client.auth.authInfoListenable.addListener(_updateSignedInState);
    _isSignedIn = client.auth.isAuthenticated;
    _restorePendingRole();
  }

  Future<void> _restorePendingRole() async {
    final role = await _pendingRole.load();
    if (mounted && role != null) setState(() => _selectedRole = role);
  }

  @override
  void dispose() {
    client.auth.authInfoListenable.removeListener(_updateSignedInState);
    super.dispose();
  }

  void _updateSignedInState() {
    setState(() => _isSignedIn = client.auth.isAuthenticated);
  }

  Future<void> _chooseRole(AccountRole role) async {
    await _pendingRole.save(role);
    if (mounted) {
      setState(() {
        _selectedRole = role;
        _showAuth = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isSignedIn) return widget.child;
    return Scaffold(
      backgroundColor: FieldnoteColors.paper,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 880;
          final story = _StoryPanel(compact: !wide);
          final action = AnimatedSwitcher(
            duration: const Duration(milliseconds: 320),
            child: _showAuth
                ? _AuthPanel(
                    key: const ValueKey('auth'),
                    selectedRole: _selectedRole,
                    onBack: () => setState(() => _showAuth = false),
                  )
                : _RolePanel(
                    key: const ValueKey('roles'),
                    onRole: _chooseRole,
                    onExistingAccount: () async {
                      await _pendingRole.clear();
                      if (mounted) {
                        setState(() {
                          _selectedRole = null;
                          _showAuth = true;
                        });
                      }
                    },
                  ),
          );
          if (wide) {
            return Row(
              children: [
                Expanded(flex: 6, child: story),
                Expanded(flex: 5, child: action),
              ],
            );
          }
          return action;
        },
      ),
    );
  }
}

class _StoryPanel extends StatelessWidget {
  const _StoryPanel({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: FieldnoteColors.ink,
      padding: EdgeInsets.all(compact ? 24 : 52),
      child: Stack(
        children: [
          Positioned(
            right: -90,
            bottom: -80,
            child: Icon(
              Icons.hub_outlined,
              size: 440,
              color: FieldnoteColors.acid.withValues(alpha: .06),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _Brand(light: true),
                  const SizedBox(height: 60),
                  Text(
                    'Fund an idea.\nMatch the people.\nProve the impact.',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: Colors.white,
                      fontSize: 62,
                    ),
                  ),
                  const SizedBox(height: 22),
                  Text(
                    'AI turns sponsor intent into action. Availability and GPS find the right volunteer. Field evidence closes the loop.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white70,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RolePanel extends StatelessWidget {
  const _RolePanel({
    super.key,
    required this.onRole,
    required this.onExistingAccount,
  });

  final ValueChanged<AccountRole> onRole;
  final VoidCallback onExistingAccount;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _Brand(),
              const SizedBox(height: 34),
              Text(
                'How will you create impact?',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 8),
              const Text('Choose once while creating your FieldNote account.'),
              const SizedBox(height: 22),
              _RoleCard(
                icon: Icons.volunteer_activism_outlined,
                title: 'Create Sponsor Account',
                subtitle:
                    'Turn an idea into a campaign, fund it, and watch verified work arrive.',
                accent: FieldnoteColors.clay,
                onTap: () => onRole(AccountRole.sponsor),
              ),
              const SizedBox(height: 12),
              _RoleCard(
                icon: Icons.directions_walk_outlined,
                title: 'Create Volunteer Account',
                subtitle:
                    'Mark your availability and discover nearby campaigns matched to you.',
                accent: FieldnoteColors.forest,
                onTap: () => onRole(AccountRole.volunteer),
              ),
              const SizedBox(height: 18),
              Center(
                child: TextButton(
                  onPressed: onExistingAccount,
                  child: const Text('I already have an account'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: .7),
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: .13),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(icon, color: accent, size: 29),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 5),
                    Text(subtitle),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward),
            ],
          ),
        ),
      ),
    );
  }
}

class _AuthPanel extends StatelessWidget {
  const _AuthPanel({
    super.key,
    required this.selectedRole,
    required this.onBack,
  });

  final AccountRole? selectedRole;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 470),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back),
              ),
              const SizedBox(height: 10),
              Text(
                selectedRole == null
                    ? 'Welcome back'
                    : 'Create your ${selectedRole!.name} account',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 8),
              Text(
                selectedRole == null
                    ? 'Sign in with your existing email account.'
                    : 'Use email authentication, then finish your role-specific profile.',
              ),
              const SizedBox(height: 20),
              SignInWidget(
                client: client,
                onAuthenticated: () {},
                onError: (error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Authentication failed: $error')),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand({this.light = false});

  final bool light;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: FieldnoteColors.acid,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.eco, color: FieldnoteColors.ink),
        ),
        const SizedBox(width: 12),
        Text(
          'FIELDNOTE',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: light ? Colors.white : FieldnoteColors.ink,
            letterSpacing: 1.4,
          ),
        ),
      ],
    );
  }
}
