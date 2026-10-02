import 'package:fieldnotes_client/fieldnotes_client.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/error_messages.dart';
import '../../core/fieldnote_theme.dart';
import '../../core/widgets.dart';
import '../../../l10n/l10n.dart';
import '../shell/fieldnote_view_model.dart';

/// Set after this device requested deletion and signed out, so the sign-in
/// screen can explain what happens next. The sign-in screen resets it.
final ValueNotifier<bool> accountDeletionNotice = ValueNotifier(false);

const accountDeletionSignInMessage =
    'Your account deletion has started and completes within about a minute. '
    'You have been signed out on every device.';

// The constants below are the English copies used where no BuildContext is
// available (the sign-in notice); widgets show the AppLocalizations strings.

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

DateFormat _timestamp(BuildContext context) =>
    DateFormat.yMMMd(context.localeTag).add_Hm();

/// User-facing label for an [AccountDeletionRequest.status]. English unless
/// [l10n] is given.
String accountDeletionStatusLabel(String status, [AppLocalizations? l10n]) {
  final l = l10n ?? lookupAppLocalizations(const Locale('en'));
  return switch (status) {
    'pending' => l.deletionStatusPending,
    'processing' => l.deletionStatusProcessing,
    'completed' => l.deletionStatusCompleted,
    'failed' => l.deletionStatusFailed,
    _ => l.deletionStatusOther(status),
  };
}

bool deletionInFlight(AccountDeletionRequest? request) =>
    request != null &&
    (request.status == 'pending' || request.status == 'processing');

String _failureMessage(BuildContext context, AccountDeletionRequest request) {
  final l10n = context.l10n;
  final code = request.lastError;
  final reason = code != null && code.startsWith('deletion_blocked_')
      ? userMessageFor(FieldnoteException(message: '', code: code))
      : l10n.deletionFailedReason;
  final retryAt = request.nextAttemptAt;
  if (retryAt != null) {
    return l10n.deletionWillRetry(
      reason,
      _timestamp(context).format(retryAt.toLocal()),
    );
  }
  return l10n.deletionRequestAgain(reason);
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
  final l10n = context.l10n;
  try {
    await viewModel.requestAccountDeletion();
  } on Object catch (error) {
    if (context.mounted) {
      showFieldnoteNotice(
        context,
        title: l10n.deletionNotDeletedTitle,
        message: userMessageFor(
          error,
          fallback: l10n.deletionRequestFailed,
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
      title: Text(l10n.deletionStartedTitle),
      content: Text(l10n.deletionStartedBody),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: Text(
            MaterialLocalizations.of(dialogContext).okButtonLabel,
          ),
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
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.deletionDialogTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.deletionExplanation),
            const SizedBox(height: 10),
            Text(l10n.deletionBlockers),
            const SizedBox(height: 16),
            // The confirmation word itself stays DELETE in every language.
            Text(l10n.deletionTypeToConfirm(_confirmWord)),
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
          child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
        ),
        FilledButton(
          onPressed: _matches ? () => Navigator.pop(context, true) : null,
          // A solid fill with white text in both brightnesses.
          style: FilledButton.styleFrom(
            backgroundColor: FieldnoteColors.danger,
            foregroundColor: Colors.white,
          ),
          child: Text(l10n.deletionDeleteAccount),
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
    final c = context.fieldnoteColors;
    final l10n = context.l10n;
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.delete_outline, color: c.danger),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  l10n.deletionDeleteAccount,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(l10n.deletionExplanation),
          const SizedBox(height: 6),
          Text(
            l10n.deletionBlockers,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (request != null) ...[
            const SizedBox(height: 12),
            StatusPill(
              label: accountDeletionStatusLabel(request.status, l10n),
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
                  ? _failureMessage(context, request)
                  : request.status == 'completed'
                  ? l10n.deletionCompletedBody
                  : l10n.deletionRequestedAt(
                      _timestamp(context).format(request.requestedAt.toLocal()),
                    ),
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
                // A solid fill with white text in both brightnesses.
                style: FilledButton.styleFrom(
                  backgroundColor: FieldnoteColors.danger,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.delete_forever_outlined),
                label: Text(
                  request?.status == 'failed'
                      ? l10n.deletionRequestAgainButton
                      : l10n.deletionDeleteMyAccount,
                ),
              ),
              if (request != null)
                OutlinedButton.icon(
                  onPressed: viewModel.refreshDeletionStatus,
                  icon: const Icon(Icons.refresh),
                  label: Text(l10n.deletionRefreshStatus),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
