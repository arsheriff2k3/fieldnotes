import '../../generated/protocol.dart';

/// A-4: money is stored and compared as integer paise (`*Paise` columns).
/// The legacy rupee `double` columns are still written as `paise / 100` for
/// clients older than this release and are never read for arithmetic.
abstract final class Money {
  /// The largest campaign goal and single sponsorship accepted (₹10,00,000).
  static const maximumRupees = 1000000.0;
  static const maximumPaise = 100000000;

  /// Converts rupees to integer paise, rounding half away from zero.
  static int toPaise(double rupees) => (rupees * 100).round();

  /// Converts integer paise back to rupees.
  static double fromPaise(int paise) => paise / 100;

  /// Rounds rupees to two decimal places.
  static double round2(double rupees) => fromPaise(toPaise(rupees));

  /// The paise a client sent: explicit [paise] wins over legacy [rupees].
  /// Null when neither is a usable number.
  static int? fromInput({int? paise, double? rupees}) {
    if (paise != null) return paise;
    if (rupees == null || !rupees.isFinite) return null;
    if (rupees.abs() > maximumRupees * 10) return null;
    return toPaise(rupees);
  }

  /// `₹1,234.50` style text for emails and audit rows (`₹1234.50`).
  static String format(int paise) => '₹${fromPaise(paise).toStringAsFixed(2)}';
}

/// Writes campaign money in paise and mirrors it into the legacy doubles.
extension CampaignMoney on Campaign {
  void setFundingGoalPaise(int paise) {
    fundingGoalPaise = paise;
    fundingGoal = Money.fromPaise(paise);
  }

  void setSponsoredPaise(int paise) {
    sponsoredAmountPaise = paise;
    sponsoredAmount = Money.fromPaise(paise);
  }

  int get unfundedPaise => fundingGoalPaise - sponsoredAmountPaise;
}
