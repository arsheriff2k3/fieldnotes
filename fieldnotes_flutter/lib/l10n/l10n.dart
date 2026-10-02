import 'package:flutter/widgets.dart';

import 'app_localizations.dart';

export 'app_localizations.dart';

extension AppLocalizationsContext on BuildContext {
  /// The app strings for the current locale.
  ///
  /// Falls back to English when a widget is pumped without
  /// [AppLocalizations.delegate] (e.g. in focused widget tests), so views
  /// never crash on a missing delegate.
  AppLocalizations get l10n =>
      Localizations.of<AppLocalizations>(this, AppLocalizations) ??
      lookupAppLocalizations(const Locale('en'));

  /// The current locale tag for `intl` formatters (e.g. `DateFormat`).
  String get localeTag =>
      Localizations.maybeLocaleOf(this)?.toLanguageTag() ?? 'en';
}
