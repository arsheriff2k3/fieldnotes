import 'package:fieldnotes_client/fieldnotes_client.dart';
import 'package:flutter/material.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

import '../client.dart';
import '../data/repositories/fieldnote_repository.dart';
import '../data/services/pending_role_service.dart';
import '../ui/core/error_messages.dart';
import '../ui/core/fieldnote_theme.dart';
import '../ui/core/legal.dart';
import '../ui/features/shell/fieldnote_view_model.dart'
    show sessionExpiredNotice;
import '../ui/features/trust/account_deletion.dart'
    show accountDeletionNotice, accountDeletionSignInMessage;

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
  LegalPolicies? _policies;
  bool _loadingPolicies = false;

  /// Shown above the sign-in panels (session expiry, account deletion).
  String? _notice;

  @override
  void initState() {
    super.initState();
    client.auth.authInfoListenable.addListener(_updateSignedInState);
    sessionExpiredNotice.addListener(_takeNotices);
    accountDeletionNotice.addListener(_takeNotices);
    _isSignedIn = client.auth.isAuthenticated;
    _restorePendingRole();
    _takeNotices();
    _loadPolicies();
  }

  /// Copies a pending notice into [_notice] and resets the flag.
  void _takeNotices() {
    String? notice;
    if (accountDeletionNotice.value) {
      notice = accountDeletionSignInMessage;
      accountDeletionNotice.value = false;
      // A deletion sign-out is never also an "expired session".
      sessionExpiredNotice.value = false;
    } else if (sessionExpiredNotice.value) {
      notice = sessionExpiredMessage;
      sessionExpiredNotice.value = false;
    }
    if (notice == null) return;
    if (mounted) {
      setState(() => _notice = notice);
    } else {
      _notice = notice;
    }
  }

  Future<void> _loadPolicies() async {
    if (_loadingPolicies) return;
    setState(() => _loadingPolicies = true);
    try {
      final policies = await FieldnoteRepository().legalPolicies();
      if (mounted) setState(() => _policies = policies);
    } on Object {
      // The links offer a retry while the policies are unavailable.
    } finally {
      if (mounted) setState(() => _loadingPolicies = false);
    }
  }

  Future<void> _restorePendingRole() async {
    final role = await _pendingRole.load();
    if (mounted && role != null) setState(() => _selectedRole = role);
  }

  @override
  void dispose() {
    client.auth.authInfoListenable.removeListener(_updateSignedInState);
    sessionExpiredNotice.removeListener(_takeNotices);
    accountDeletionNotice.removeListener(_takeNotices);
    super.dispose();
  }

  void _updateSignedInState() {
    final signedIn = client.auth.isAuthenticated;
    setState(() {
      _isSignedIn = signedIn;
      if (signedIn) _notice = null;
    });
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
          final legal = LegalLinks(
            policies: _policies,
            onRetry: _loadingPolicies ? null : _loadPolicies,
            alignment: WrapAlignment.center,
          );
          final action = AnimatedSwitcher(
            duration: const Duration(milliseconds: 320),
            child: _showAuth
                ? _AuthPanel(
                    key: const ValueKey('auth'),
                    selectedRole: _selectedRole,
                    onBack: () => setState(() => _showAuth = false),
                    footer: legal,
                  )
                : _RolePanel(
                    key: const ValueKey('roles'),
                    footer: legal,
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
          final notice = _notice;
          final panel = notice == null
              ? action
              : Column(
                  children: [
                    SafeArea(
                      bottom: false,
                      child: MaterialBanner(
                        backgroundColor: FieldnoteColors.mist,
                        leading: const Icon(
                          Icons.info_outline,
                          color: FieldnoteColors.forest,
                        ),
                        content: Semantics(
                          liveRegion: true,
                          child: Text(notice),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => setState(() => _notice = null),
                            child: const Text('Dismiss'),
                          ),
                        ],
                      ),
                    ),
                    Expanded(child: action),
                  ],
                );
          if (wide) {
            return Row(
              children: [
                Expanded(flex: 6, child: story),
                Expanded(flex: 5, child: panel),
              ],
            );
          }
          return panel;
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
                  // Scales down instead of clipping at large text sizes.
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Fund an idea.\nMatch the people.\nProve the impact.',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: Colors.white,
                        fontSize: 62,
                      ),
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
    required this.footer,
  });

  final ValueChanged<AccountRole> onRole;
  final VoidCallback onExistingAccount;
  final Widget footer;

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
              const SizedBox(height: 12),
              const Center(
                child: Text(
                  'By creating an account you agree to the FieldNote Terms '
                  'and Privacy Policy.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12),
                ),
              ),
              footer,
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
    required this.footer,
  });

  final AccountRole? selectedRole;
  final VoidCallback onBack;
  final Widget footer;

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
                tooltip: 'Back',
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
                    SnackBar(
                      content: Text(
                        isNetworkError(error)
                            ? offlineMessage
                            : 'Authentication failed: $error',
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'By continuing you agree to the FieldNote Terms and Privacy '
                'Policy.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12),
              ),
              Center(child: footer),
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
