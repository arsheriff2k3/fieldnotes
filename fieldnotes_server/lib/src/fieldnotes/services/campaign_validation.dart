import '../../generated/protocol.dart';
import 'money.dart';

/// A-5: server-side bounds for anything a sponsor submits as a campaign plan.
abstract final class CampaignValidation {
  static const minimumGoal = 100.0;
  static const maximumGoal = Money.maximumRupees;
  static const minimumDurationMinutes = 15;
  static const maximumDurationMinutes = 1440;
  static const minimumCapacity = 1;
  static const maximumCapacity = 500;
  static const titleLength = (min: 3, max: 120);
  static const descriptionLength = (min: 10, max: 4000);
  static const scopeNoteLength = (min: 20, max: 4000);
  static const listItemMaxLength = 200;
  static const listMaxItems = 20;

  static void fundingGoal(double goal) {
    if (!goal.isFinite || goal < minimumGoal || goal > maximumGoal) {
      _fail(
        'Choose a funding goal between ₹${minimumGoal.toStringAsFixed(0)} and ₹10,00,000.',
        'invalid_funding_goal',
      );
    }
  }

  static void proposal(CampaignProposal proposal) {
    _length(proposal.title, titleLength, 'title');
    _length(proposal.description, descriptionLength, 'description');
    fundingGoal(proposal.fundingGoal);
    if (proposal.durationMinutes < minimumDurationMinutes ||
        proposal.durationMinutes > maximumDurationMinutes) {
      _fail(
        'Choose a duration between 15 minutes and 24 hours.',
        'invalid_duration',
      );
    }
    if (proposal.volunteerCapacity < minimumCapacity ||
        proposal.volunteerCapacity > maximumCapacity) {
      _fail(
        'Choose between $minimumCapacity and $maximumCapacity volunteer places.',
        'invalid_capacity',
      );
    }
    for (final list in [
      proposal.checklist,
      proposal.requiredSkills,
      proposal.tags,
    ]) {
      if (list.length > listMaxItems ||
          list.any((item) => item.length > listItemMaxLength)) {
        _fail(
          'Keep checklists, skills and tags to $listMaxItems short items.',
          'invalid_campaign_plan',
        );
      }
    }
    if (proposal.evidenceInstructions.length > descriptionLength.max) {
      _fail('Shorten the evidence instructions.', 'invalid_campaign_plan');
    }
  }

  static void scopeNote(String note) =>
      _length(note, scopeNoteLength, 'revised scope');

  static void _length(
    String value,
    ({int min, int max}) bounds,
    String label,
  ) {
    final length = value.trim().length;
    if (length < bounds.min || length > bounds.max) {
      _fail(
        'The $label must be ${bounds.min}–${bounds.max} characters.',
        'invalid_campaign_plan',
      );
    }
  }

  static Never _fail(String message, String code) =>
      throw FieldnoteException(message: message, code: code);
}
