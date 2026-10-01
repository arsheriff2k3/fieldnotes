/// Rupee amounts are still stored as `double`. Every value that is written or
/// compared goes through these helpers so arithmetic stays on whole paise.
abstract final class Money {
  /// The largest campaign goal and single sponsorship accepted (₹10,00,000).
  static const maximumRupees = 1000000.0;

  /// Converts rupees to integer paise, rounding half away from zero.
  static int toPaise(double rupees) => (rupees * 100).round();

  /// Converts integer paise back to rupees.
  static double fromPaise(int paise) => paise / 100;

  /// Rounds rupees to two decimal places.
  static double round2(double rupees) => fromPaise(toPaise(rupees));

  /// Adds rupee amounts on integer paise.
  static double add(double a, double b) => fromPaise(toPaise(a) + toPaise(b));

  /// Subtracts rupee amounts on integer paise.
  static double subtract(double a, double b) =>
      fromPaise(toPaise(a) - toPaise(b));
}
