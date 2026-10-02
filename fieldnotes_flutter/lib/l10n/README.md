# App strings

`flutter gen-l10n` (run automatically by `flutter pub get` / `flutter run`
because `generate: true` is set in `pubspec.yaml`) turns these ARB files into
`app_localizations*.dart` in this folder. Configuration is in `../../l10n.yaml`.

- `app_en.arb` is the template and must contain every key.
- `app_hi.arb` (Hindi) and `app_ta.arb` (Tamil) contain only short UI labels
  (navigation, buttons, field labels). **They were machine-drafted and need
  review by a native speaker before release.**
- Any key missing from `app_hi.arb` / `app_ta.arb` falls back to the English
  text from `app_en.arb` (gen-l10n copies the template message into the
  locale class). The list of untranslated keys is written to
  `build/l10n_untranslated.json` on every generation.

Use strings in widgets through `context.l10n` (`l10n.dart`), which falls back
to English when a widget is pumped without the localization delegate.
Format dates and numbers with `intl` and `context.localeTag`, e.g.
`DateFormat.yMMMd(context.localeTag)`. Code that may run without the
localization delegates (pure helpers, tests) should pass English as `null`
to `DateFormat` (`dateLocale()` in `volunteer_status.dart`), because intl
only ships `en_US` date data until `initializeDateFormatting` has run.

Key prefixes: `core…` for `lib/ui/core` (errors are `coreError…`,
`coreLocation…`, `coreWait…`), `volunteer…` for the volunteer screens,
`sponsor…` for sponsor screens, `export…` for the data export. Errors are
worded through `UserError` in `lib/ui/core/error_messages.dart`; pass
`context:` to `userMessageFor` in views.

The Hindi/Tamil entries added for errors, maps and volunteer screens are
short labels and a few common error sentences only, and like the rest
**need native-speaker review**. Longer volunteer and export text is
English in `hi`/`ta` for now.

Do not translate stored values (sponsor types, interest and skill tags,
location labels); localize only their display labels.
