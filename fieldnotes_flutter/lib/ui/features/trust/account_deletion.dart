import 'package:fieldnotes_client/fieldnotes_client.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/error_messages.dart';
import '../../core/fieldnote_theme.dart';
import '../../core/widgets.dart';
import '../shell/fieldnote_view_model.dart';

/// Set after this device requested deletion and signed out, so the sign-in
/// screen can explain what happens next. The sign-in screen resets it.
final ValueNotifier<bool> accountDeletionNotice = ValueNotifier(false);

const accountDeletionSignInMessage =
    'Your account deletion has started and completes within about a minute. '
    'You have been signed out on every device.';

/// What deletion really does (matches `AccountDeletionService`).
const accountDeletionExplanation =
    'Deleting your account removes your profile, availability, invitations, '
    'photographs and evidence text, and signs you out on every device. '
    'Payment, refund and consent records are kept without your name for '
    'accounting and legal purposes. Deletion completes within about a minute '
    'and cannot be undone.';

const accountDeletionBlockers =
    'You cannot delete the account while you are checked in to a campaign, '
    'have campaigns that are still open, or have payments or refunds in '
    'progress.';

const _confirmWord = 'DELETE';

final _timestamp = DateFormat('d MMM yyyy, HH:mm');

/// User-facing label for an [AccountDeletionRequest.status].
String accountDeletionStatusLabel(String status) => switch (status) {
  'pending' => 'Deletion pending',
  'processing' => 'Deletion in progress',
  'completed' => 'Account deleted',
  'failed' => 'Deletion failed',
  _ => 'Deletion $status',
};

bool deletionInFlight(AccountDeletionRequest? request) =>
    request != null &&
    (request.status == 'pending' || request.status == 'processing');

String _failureMessage(AccountDeletionRequest request) {
  final code = request.lastError;
  final reason = code == null || code.isEmpty
      ? 'FieldNote could not finish deleting your account.'
      : code.startsWith('deletion_blocked_')
      ? userMessageFor(FieldnoteException(message: '', code: code))
      : 'FieldNote could not finish deleting your account.';
  final retryAt = request.nextAttemptAt;
  if (retryAt != null) {
    return '$reason It will retry automatically at '
        '${_timestamp.format(retryAt.toLocal())}.';
  }
  return '$reason Request deletion again, or contact support if this keeps '
      'happening.';
}

/// Asks the user to type DELETE, requests deletion, then signs out.
Future<void> confirmAndRequestAccountDeletion(
  BuildContext context,
  FieldnoteViewModel viewModel,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (_) => const _DeleteAccountDialog(),
  );
  if (confirmed != true || !context.mounted) return;
  try {
    await viewModel.requestAccountDeletion();
  } on Object catch (error) {
    if (context.mounted) {
      showFieldnoteNotice(
        context,
        title: 'Account not deleted',
        message: userMessageFor(
          error,
          fallback: 'Could not request account deletion. Try again.',
        ),
        kind: FieldnoteNoticeKind.error,
      );
    }
    return;
  }
  if (!context.mounted) return;
  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Deletion started'),
      content: const Text(
        'Your account is being deleted and this completes within about a '
        'minute. You will now be signed out.',
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('OK'),
        ),
      ],
    ),
  );
  accountDeletionNotice.value = true;
  await viewModel.signOut(allDevices: true);
}

class _DeleteAccountDialog extends StatefulWidget {
  const _DeleteAccountDialog();

  @override
  State<_DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<_DeleteAccountDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _matches => _controller.text.trim().toUpperCase() == _confirmWord;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Delete your account?'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(accountDeletionExplanation),
            const SizedBox(height: 10),
            const Text(accountDeletionBlockers),
            const SizedBox(height: 16),
            const Text('Type $_confirmWord to confirm.'),
            const SizedBox(height: 8),
            TextField(
              key: const ValueKey('delete-confirm-field'),
              controller: _controller,
              autofocus: true,
              autocorrect: false,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(hintText: _confirmWord),
              onChanged: (_) => setState(() {}),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _matches ? () => Navigator.pop(context, true) : null,
          style: FilledButton.styleFrom(
            backgroundColor: FieldnoteColors.danger,
            foregroundColor: Colors.white,
          ),
          child: const Text('Delete account'),
        ),
      ],
    );
  }
}

/// Explanation, current status and the delete button.
class AccountDeletionCard extends StatelessWidget {
  const AccountDeletionCard({super.key, required this.viewModel});

  final FieldnoteViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final request = viewModel.deletionStatus;
    final inFlight = deletionInFlight(request);
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.delete_outline, color: FieldnoteColors.danger),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  'Delete account',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(accountDeletionExplanation),
          const SizedBox(height: 6),
          Text(
            accountDeletionBlockers,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (request != null) ...[
            const SizedBox(height: 12),
            StatusPill(
              label: accountDeletionStatusLabel(request.status),
              color: request.status == 'failed'
                  ? FieldnoteColors.danger
                  : FieldnoteColors.clay,
              icon: request.status == 'failed'
                  ? Icons.error_outline
                  : Icons.hourglass_top,
            ),
            const SizedBox(height: 6),
            Text(
              request.status == 'failed'
                  ? _failureMessage(request)
                  : request.status == 'completed'
                  ? 'Your account was deleted.'
                  : 'Requested ${_timestamp.format(request.requestedAt.toLocal())}. '
                        'This completes within about a minute and signs you '
                        'out.',
            ),
          ],
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton.icon(
                onPressed: inFlight
                    ? null
                    : () =>
                          confirmAndRequestAccountDeletion(context, viewModel),
                style: FilledButton.styleFrom(
                  backgroundColor: FieldnoteColors.danger,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.delete_forever_outlined),
                label: Text(
                  request?.status == 'failed'
                      ? 'Request deletion again'
                      : 'Delete my account',
                ),
              ),
              if (request != null)
                OutlinedButton.icon(
                  onPressed: viewModel.refreshDeletionStatus,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh status'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
