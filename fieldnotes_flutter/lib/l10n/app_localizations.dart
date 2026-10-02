import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_ta.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi'),
    Locale('ta'),
  ];

  /// No description provided for @shellOfflineTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline'**
  String get shellOfflineTitle;

  /// No description provided for @shellErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get shellErrorTitle;

  /// No description provided for @navDiscover.
  ///
  /// In en, this message translates to:
  /// **'Discover'**
  String get navDiscover;

  /// No description provided for @navCreate.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get navCreate;

  /// No description provided for @navImpact.
  ///
  /// In en, this message translates to:
  /// **'Impact'**
  String get navImpact;

  /// No description provided for @navTrust.
  ///
  /// In en, this message translates to:
  /// **'Trust'**
  String get navTrust;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @navMatches.
  ///
  /// In en, this message translates to:
  /// **'Matches'**
  String get navMatches;

  /// No description provided for @navMyWork.
  ///
  /// In en, this message translates to:
  /// **'My work'**
  String get navMyWork;

  /// No description provided for @navAvailability.
  ///
  /// In en, this message translates to:
  /// **'Availability'**
  String get navAvailability;

  /// No description provided for @voiceRecordingLabel.
  ///
  /// In en, this message translates to:
  /// **'Recording. Release to finish.'**
  String get voiceRecordingLabel;

  /// No description provided for @voiceProcessingLabel.
  ///
  /// In en, this message translates to:
  /// **'Campaign generation in progress'**
  String get voiceProcessingLabel;

  /// No description provided for @voiceHoldLabel.
  ///
  /// In en, this message translates to:
  /// **'Hold to record a campaign brief'**
  String get voiceHoldLabel;

  /// No description provided for @shellSponsorWorkspace.
  ///
  /// In en, this message translates to:
  /// **'SPONSOR WORKSPACE'**
  String get shellSponsorWorkspace;

  /// No description provided for @shellVolunteerWorkspace.
  ///
  /// In en, this message translates to:
  /// **'VOLUNTEER WORKSPACE'**
  String get shellVolunteerWorkspace;

  /// No description provided for @shellLoading.
  ///
  /// In en, this message translates to:
  /// **'Preparing your impact workspace…'**
  String get shellLoading;

  /// No description provided for @shellCantReach.
  ///
  /// In en, this message translates to:
  /// **'Can\'t reach FieldNote'**
  String get shellCantReach;

  /// No description provided for @shellCouldNotLoad.
  ///
  /// In en, this message translates to:
  /// **'FieldNote could not load'**
  String get shellCouldNotLoad;

  /// No description provided for @commonTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get commonTryAgain;

  /// No description provided for @commonDismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get commonDismiss;

  /// No description provided for @signInHeroTitle.
  ///
  /// In en, this message translates to:
  /// **'Fund an idea.\nMatch the people.\nProve the impact.'**
  String get signInHeroTitle;

  /// No description provided for @signInHeroBody.
  ///
  /// In en, this message translates to:
  /// **'AI turns sponsor intent into action. Availability and GPS find the right volunteer. Field evidence closes the loop.'**
  String get signInHeroBody;

  /// No description provided for @signInRoleTitle.
  ///
  /// In en, this message translates to:
  /// **'How will you create impact?'**
  String get signInRoleTitle;

  /// No description provided for @signInRoleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose once while creating your FieldNote account.'**
  String get signInRoleSubtitle;

  /// No description provided for @signInSponsorCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Sponsor Account'**
  String get signInSponsorCardTitle;

  /// No description provided for @signInSponsorCardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Turn an idea into a campaign, fund it, and watch verified work arrive.'**
  String get signInSponsorCardSubtitle;

  /// No description provided for @signInVolunteerCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Volunteer Account'**
  String get signInVolunteerCardTitle;

  /// No description provided for @signInVolunteerCardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Mark your availability and discover nearby campaigns matched to you.'**
  String get signInVolunteerCardSubtitle;

  /// No description provided for @signInExistingAccount.
  ///
  /// In en, this message translates to:
  /// **'I already have an account'**
  String get signInExistingAccount;

  /// No description provided for @signInCreateAgreement.
  ///
  /// In en, this message translates to:
  /// **'By creating an account you agree to the FieldNote Terms and Privacy Policy.'**
  String get signInCreateAgreement;

  /// No description provided for @signInWelcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get signInWelcomeBack;

  /// No description provided for @signInCreateSponsorAccount.
  ///
  /// In en, this message translates to:
  /// **'Create your sponsor account'**
  String get signInCreateSponsorAccount;

  /// No description provided for @signInCreateVolunteerAccount.
  ///
  /// In en, this message translates to:
  /// **'Create your volunteer account'**
  String get signInCreateVolunteerAccount;

  /// No description provided for @signInExistingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with your existing email account.'**
  String get signInExistingSubtitle;

  /// No description provided for @signInNewSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use email authentication, then finish your role-specific profile.'**
  String get signInNewSubtitle;

  /// No description provided for @signInAuthFailed.
  ///
  /// In en, this message translates to:
  /// **'Authentication failed: {error}'**
  String signInAuthFailed(String error);

  /// No description provided for @signInContinueAgreement.
  ///
  /// In en, this message translates to:
  /// **'By continuing you agree to the FieldNote Terms and Privacy Policy.'**
  String get signInContinueAgreement;

  /// No description provided for @consentLocationTitle.
  ///
  /// In en, this message translates to:
  /// **'Use GPS for matching and check-in integrity'**
  String get consentLocationTitle;

  /// No description provided for @consentLocationDescription.
  ///
  /// In en, this message translates to:
  /// **'Stores approximate check-in and evidence coordinates and integrity signals.'**
  String get consentLocationDescription;

  /// No description provided for @consentAiTitle.
  ///
  /// In en, this message translates to:
  /// **'Use AI assistance'**
  String get consentAiTitle;

  /// No description provided for @consentAiDescription.
  ///
  /// In en, this message translates to:
  /// **'Campaign text and evidence inputs can be sent to an AI provider for structured drafts.'**
  String get consentAiDescription;

  /// No description provided for @consentEvidenceTitle.
  ///
  /// In en, this message translates to:
  /// **'Share evidence privately with campaign sponsors'**
  String get consentEvidenceTitle;

  /// No description provided for @consentEvidenceDescription.
  ///
  /// In en, this message translates to:
  /// **'Evidence is private and exposed only through temporary authenticated links.'**
  String get consentEvidenceDescription;

  /// No description provided for @consentRequiredSuffix.
  ///
  /// In en, this message translates to:
  /// **'{title} (required)'**
  String consentRequiredSuffix(String title);

  /// No description provided for @legalOpenInBrowser.
  ///
  /// In en, this message translates to:
  /// **'Open this address in your browser to read it:'**
  String get legalOpenInBrowser;

  /// No description provided for @commonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// No description provided for @legalCopyLink.
  ///
  /// In en, this message translates to:
  /// **'Copy link'**
  String get legalCopyLink;

  /// No description provided for @legalLoading.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy and Terms are loading…'**
  String get legalLoading;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// No description provided for @legalPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get legalPrivacyPolicy;

  /// No description provided for @legalPrivacyPolicyVersion.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy v{version}'**
  String legalPrivacyPolicyVersion(String version);

  /// No description provided for @legalTermsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get legalTermsOfService;

  /// No description provided for @legalTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms'**
  String get legalTerms;

  /// No description provided for @legalTermsVersion.
  ///
  /// In en, this message translates to:
  /// **'Terms v{version}'**
  String legalTermsVersion(String version);

  /// No description provided for @onboardingChooseSponsorLocation.
  ///
  /// In en, this message translates to:
  /// **'Choose sponsor location'**
  String get onboardingChooseSponsorLocation;

  /// No description provided for @onboardingChooseTravelArea.
  ///
  /// In en, this message translates to:
  /// **'Choose travel area'**
  String get onboardingChooseTravelArea;

  /// No description provided for @onboardingNeedRoleAndName.
  ///
  /// In en, this message translates to:
  /// **'Choose a role and enter your name.'**
  String get onboardingNeedRoleAndName;

  /// No description provided for @onboardingNeedArea.
  ///
  /// In en, this message translates to:
  /// **'Use current GPS or choose your travel area on the map.'**
  String get onboardingNeedArea;

  /// No description provided for @onboardingWaitForArea.
  ///
  /// In en, this message translates to:
  /// **'Wait for the selected area to finish loading.'**
  String get onboardingWaitForArea;

  /// No description provided for @onboardingNeedLocation.
  ///
  /// In en, this message translates to:
  /// **'Choose your location.'**
  String get onboardingNeedLocation;

  /// No description provided for @onboardingNeedPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter a phone number with country code, for example +919876543210.'**
  String get onboardingNeedPhone;

  /// No description provided for @onboardingSelectSuggestion.
  ///
  /// In en, this message translates to:
  /// **'Select your location from the Google suggestions.'**
  String get onboardingSelectSuggestion;

  /// No description provided for @onboardingPoliciesUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Could not load the Privacy Policy and Terms. Check your connection and try again.'**
  String get onboardingPoliciesUnavailable;

  /// No description provided for @onboardingAcceptConsents.
  ///
  /// In en, this message translates to:
  /// **'Review and accept every required privacy choice.'**
  String get onboardingAcceptConsents;

  /// No description provided for @onboardingSetupFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not complete account setup.'**
  String get onboardingSetupFailed;

  /// No description provided for @onboardingBrandHeader.
  ///
  /// In en, this message translates to:
  /// **'FIELDNOTE · ACCOUNT SETUP'**
  String get onboardingBrandHeader;

  /// No description provided for @onboardingChooseRole.
  ///
  /// In en, this message translates to:
  /// **'Choose role'**
  String get onboardingChooseRole;

  /// No description provided for @roleSponsor.
  ///
  /// In en, this message translates to:
  /// **'Sponsor'**
  String get roleSponsor;

  /// No description provided for @roleVolunteer.
  ///
  /// In en, this message translates to:
  /// **'Volunteer'**
  String get roleVolunteer;

  /// No description provided for @onboardingSponsorTitle.
  ///
  /// In en, this message translates to:
  /// **'Set up your sponsor profile'**
  String get onboardingSponsorTitle;

  /// No description provided for @onboardingVolunteerTitle.
  ///
  /// In en, this message translates to:
  /// **'Tell AI when and where you can help'**
  String get onboardingVolunteerTitle;

  /// No description provided for @onboardingSponsorDescription.
  ///
  /// In en, this message translates to:
  /// **'Sponsors create, fund, and monitor campaigns.'**
  String get onboardingSponsorDescription;

  /// No description provided for @onboardingVolunteerDescription.
  ///
  /// In en, this message translates to:
  /// **'Availability and GPS are used to explain every campaign match.'**
  String get onboardingVolunteerDescription;

  /// No description provided for @onboardingDisplayName.
  ///
  /// In en, this message translates to:
  /// **'Display name'**
  String get onboardingDisplayName;

  /// No description provided for @onboardingPreparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing account…'**
  String get onboardingPreparing;

  /// No description provided for @onboardingEnter.
  ///
  /// In en, this message translates to:
  /// **'Enter FieldNote'**
  String get onboardingEnter;

  /// No description provided for @onboardingLocationLabel.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get onboardingLocationLabel;

  /// No description provided for @onboardingLocationHint.
  ///
  /// In en, this message translates to:
  /// **'Search for an address or place…'**
  String get onboardingLocationHint;

  /// No description provided for @onboardingChooseOnMap.
  ///
  /// In en, this message translates to:
  /// **'Choose on map'**
  String get onboardingChooseOnMap;

  /// No description provided for @onboardingPlacesHint.
  ///
  /// In en, this message translates to:
  /// **'Choose a complete location from Google Places · Powered by Google'**
  String get onboardingPlacesHint;

  /// No description provided for @onboardingPlacesUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Location search is unavailable; enter the complete address manually.'**
  String get onboardingPlacesUnavailable;

  /// No description provided for @sponsorTypeIndividual.
  ///
  /// In en, this message translates to:
  /// **'Individual'**
  String get sponsorTypeIndividual;

  /// No description provided for @sponsorTypeCompany.
  ///
  /// In en, this message translates to:
  /// **'Company'**
  String get sponsorTypeCompany;

  /// No description provided for @sponsorTypeFoundation.
  ///
  /// In en, this message translates to:
  /// **'Foundation'**
  String get sponsorTypeFoundation;

  /// No description provided for @sponsorTypeCommunityGroup.
  ///
  /// In en, this message translates to:
  /// **'Community group'**
  String get sponsorTypeCommunityGroup;

  /// No description provided for @onboardingSponsorType.
  ///
  /// In en, this message translates to:
  /// **'Sponsor type'**
  String get onboardingSponsorType;

  /// No description provided for @onboardingOrganization.
  ///
  /// In en, this message translates to:
  /// **'Organization name (optional)'**
  String get onboardingOrganization;

  /// No description provided for @onboardingContactPhone.
  ///
  /// In en, this message translates to:
  /// **'Contact phone (required)'**
  String get onboardingContactPhone;

  /// No description provided for @onboardingContactPhoneHelper.
  ///
  /// In en, this message translates to:
  /// **'Shared with volunteers after they join your campaign.'**
  String get onboardingContactPhoneHelper;

  /// No description provided for @onboardingPreferredCauses.
  ///
  /// In en, this message translates to:
  /// **'Preferred causes'**
  String get onboardingPreferredCauses;

  /// No description provided for @onboardingAvailableForMatches.
  ///
  /// In en, this message translates to:
  /// **'Available for campaign matches'**
  String get onboardingAvailableForMatches;

  /// No description provided for @onboardingAvailableToday.
  ///
  /// In en, this message translates to:
  /// **'Available today'**
  String get onboardingAvailableToday;

  /// No description provided for @onboardingAvailableDays.
  ///
  /// In en, this message translates to:
  /// **'Available days'**
  String get onboardingAvailableDays;

  /// Slider label; km is a locale-formatted number.
  ///
  /// In en, this message translates to:
  /// **'Travel radius · {km} km'**
  String onboardingTravelRadius(String km);

  /// No description provided for @onboardingTravelAreaHint.
  ///
  /// In en, this message translates to:
  /// **'Choose your travel area using GPS or the map pin.'**
  String get onboardingTravelAreaHint;

  /// No description provided for @onboardingFindingLocation.
  ///
  /// In en, this message translates to:
  /// **'Finding your location…'**
  String get onboardingFindingLocation;

  /// No description provided for @onboardingUseGps.
  ///
  /// In en, this message translates to:
  /// **'Use current GPS location'**
  String get onboardingUseGps;

  /// No description provided for @onboardingUseGpsInstead.
  ///
  /// In en, this message translates to:
  /// **'Use current GPS instead'**
  String get onboardingUseGpsInstead;

  /// No description provided for @onboardingRefreshGps.
  ///
  /// In en, this message translates to:
  /// **'Refresh current GPS location'**
  String get onboardingRefreshGps;

  /// No description provided for @onboardingChooseTravelAreaOnMap.
  ///
  /// In en, this message translates to:
  /// **'Choose travel area on map'**
  String get onboardingChooseTravelAreaOnMap;

  /// No description provided for @locationEnableInSettings.
  ///
  /// In en, this message translates to:
  /// **'Enable Location in Settings'**
  String get locationEnableInSettings;

  /// No description provided for @locationOpenPermissions.
  ///
  /// In en, this message translates to:
  /// **'Open FieldNote permissions'**
  String get locationOpenPermissions;

  /// No description provided for @onboardingFindingAreaName.
  ///
  /// In en, this message translates to:
  /// **'Finding the area name…'**
  String get onboardingFindingAreaName;

  /// No description provided for @onboardingSelectedArea.
  ///
  /// In en, this message translates to:
  /// **'Selected area: {area}'**
  String onboardingSelectedArea(String area);

  /// No description provided for @onboardingInterests.
  ///
  /// In en, this message translates to:
  /// **'Interests'**
  String get onboardingInterests;

  /// No description provided for @onboardingSkills.
  ///
  /// In en, this message translates to:
  /// **'Skills'**
  String get onboardingSkills;

  /// No description provided for @onboardingMapSemantics.
  ///
  /// In en, this message translates to:
  /// **'Draggable map pin for the area you can travel from'**
  String get onboardingMapSemantics;

  /// No description provided for @onboardingMapFallback.
  ///
  /// In en, this message translates to:
  /// **'Map preview is off. Use the GPS button below to set the area you travel from.'**
  String get onboardingMapFallback;

  /// No description provided for @onboardingPrivacyChoices.
  ///
  /// In en, this message translates to:
  /// **'Privacy choices'**
  String get onboardingPrivacyChoices;

  /// No description provided for @onboardingPrivacyChoicesBody.
  ///
  /// In en, this message translates to:
  /// **'You can review these records, withdraw consent, export your data or delete your account from Trust & safety.'**
  String get onboardingPrivacyChoicesBody;

  /// No description provided for @onboardingAcceptCurrent.
  ///
  /// In en, this message translates to:
  /// **'By continuing you accept the current FieldNote Terms and Privacy Policy.'**
  String get onboardingAcceptCurrent;

  /// No description provided for @onboardingAcceptVersions.
  ///
  /// In en, this message translates to:
  /// **'By continuing you accept the FieldNote Terms v{termsVersion} and Privacy Policy v{privacyVersion}.'**
  String onboardingAcceptVersions(String termsVersion, String privacyVersion);

  /// No description provided for @deletionStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Deletion pending'**
  String get deletionStatusPending;

  /// No description provided for @deletionStatusProcessing.
  ///
  /// In en, this message translates to:
  /// **'Deletion in progress'**
  String get deletionStatusProcessing;

  /// No description provided for @deletionStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Account deleted'**
  String get deletionStatusCompleted;

  /// No description provided for @deletionStatusFailed.
  ///
  /// In en, this message translates to:
  /// **'Deletion failed'**
  String get deletionStatusFailed;

  /// No description provided for @deletionStatusOther.
  ///
  /// In en, this message translates to:
  /// **'Deletion {status}'**
  String deletionStatusOther(String status);

  /// No description provided for @deletionFailedReason.
  ///
  /// In en, this message translates to:
  /// **'FieldNote could not finish deleting your account.'**
  String get deletionFailedReason;

  /// No description provided for @deletionWillRetry.
  ///
  /// In en, this message translates to:
  /// **'{reason} It will retry automatically at {time}.'**
  String deletionWillRetry(String reason, String time);

  /// No description provided for @deletionRequestAgain.
  ///
  /// In en, this message translates to:
  /// **'{reason} Request deletion again, or contact support if this keeps happening.'**
  String deletionRequestAgain(String reason);

  /// No description provided for @deletionNotDeletedTitle.
  ///
  /// In en, this message translates to:
  /// **'Account not deleted'**
  String get deletionNotDeletedTitle;

  /// No description provided for @deletionRequestFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not request account deletion. Try again.'**
  String get deletionRequestFailed;

  /// No description provided for @deletionStartedTitle.
  ///
  /// In en, this message translates to:
  /// **'Deletion started'**
  String get deletionStartedTitle;

  /// No description provided for @deletionStartedBody.
  ///
  /// In en, this message translates to:
  /// **'Your account is being deleted and this completes within about a minute. You will now be signed out.'**
  String get deletionStartedBody;

  /// No description provided for @deletionDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete your account?'**
  String get deletionDialogTitle;

  /// No description provided for @deletionExplanation.
  ///
  /// In en, this message translates to:
  /// **'Deleting your account removes your profile, availability, invitations, photographs and evidence text, and signs you out on every device. Payment, refund and consent records are kept without your name for accounting and legal purposes. Deletion completes within about a minute and cannot be undone.'**
  String get deletionExplanation;

  /// No description provided for @deletionBlockers.
  ///
  /// In en, this message translates to:
  /// **'You cannot delete the account while you are checked in to a campaign, have campaigns that are still open, or have payments or refunds in progress.'**
  String get deletionBlockers;

  /// word is always DELETE; do not translate it.
  ///
  /// In en, this message translates to:
  /// **'Type {word} to confirm.'**
  String deletionTypeToConfirm(String word);

  /// No description provided for @deletionDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get deletionDeleteAccount;

  /// No description provided for @deletionCompletedBody.
  ///
  /// In en, this message translates to:
  /// **'Your account was deleted.'**
  String get deletionCompletedBody;

  /// No description provided for @deletionRequestedAt.
  ///
  /// In en, this message translates to:
  /// **'Requested {time}. This completes within about a minute and signs you out.'**
  String deletionRequestedAt(String time);

  /// No description provided for @deletionRequestAgainButton.
  ///
  /// In en, this message translates to:
  /// **'Request deletion again'**
  String get deletionRequestAgainButton;

  /// No description provided for @deletionDeleteMyAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete my account'**
  String get deletionDeleteMyAccount;

  /// No description provided for @deletionRefreshStatus.
  ///
  /// In en, this message translates to:
  /// **'Refresh status'**
  String get deletionRefreshStatus;

  /// No description provided for @consentNotSavedTitle.
  ///
  /// In en, this message translates to:
  /// **'Consent not saved'**
  String get consentNotSavedTitle;

  /// No description provided for @consentNotSavedBody.
  ///
  /// In en, this message translates to:
  /// **'Could not save your consent. Try again.'**
  String get consentNotSavedBody;

  /// No description provided for @consentGateIntro.
  ///
  /// In en, this message translates to:
  /// **'FieldNote uses location, AI, and private evidence to connect sponsorship with verified volunteer work.'**
  String get consentGateIntro;

  /// No description provided for @consentGatePolicyChanged.
  ///
  /// In en, this message translates to:
  /// **'The Privacy Policy or Terms changed since you last agreed. Review them and confirm your choices to continue.'**
  String get consentGatePolicyChanged;

  /// No description provided for @consentGateWithdrawn.
  ///
  /// In en, this message translates to:
  /// **'You withdrew consent, so matching, check-in, AI drafts and evidence sharing are paused. Accept again to keep using FieldNote, or delete your account.'**
  String get consentGateWithdrawn;

  /// No description provided for @consentGateEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Trust before action'**
  String get consentGateEyebrow;

  /// No description provided for @consentGateTitle.
  ///
  /// In en, this message translates to:
  /// **'Review your privacy choices'**
  String get consentGateTitle;

  /// No description provided for @commonSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get commonSaving;

  /// No description provided for @consentAcceptAndContinue.
  ///
  /// In en, this message translates to:
  /// **'Accept and continue'**
  String get consentAcceptAndContinue;

  /// No description provided for @consentCheckRequired.
  ///
  /// In en, this message translates to:
  /// **'Check every required choice to continue.'**
  String get consentCheckRequired;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @signOutTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out?'**
  String get signOutTitle;

  /// No description provided for @signOutAllDevicesTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out of all devices?'**
  String get signOutAllDevicesTitle;

  /// No description provided for @signOutBody.
  ///
  /// In en, this message translates to:
  /// **'You will need to sign in again to use FieldNote on this device.'**
  String get signOutBody;

  /// No description provided for @signOutAllDevicesBody.
  ///
  /// In en, this message translates to:
  /// **'Every device signed in to this account, including this one, will need to sign in again.'**
  String get signOutAllDevicesBody;

  /// No description provided for @signOutEverywhere.
  ///
  /// In en, this message translates to:
  /// **'Sign out everywhere'**
  String get signOutEverywhere;

  /// No description provided for @trustEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Your account'**
  String get trustEyebrow;

  /// No description provided for @trustTitle.
  ///
  /// In en, this message translates to:
  /// **'Trust & safety'**
  String get trustTitle;

  /// No description provided for @trustDescription.
  ///
  /// In en, this message translates to:
  /// **'Review privacy controls and account activity.'**
  String get trustDescription;

  /// No description provided for @trustLoadingTitle.
  ///
  /// In en, this message translates to:
  /// **'Trust data is loading'**
  String get trustLoadingTitle;

  /// No description provided for @trustLoadingBody.
  ///
  /// In en, this message translates to:
  /// **'Pull to refresh the security activity for this account.'**
  String get trustLoadingBody;

  /// No description provided for @trustVerifiedPayments.
  ///
  /// In en, this message translates to:
  /// **'Verified payments'**
  String get trustVerifiedPayments;

  /// No description provided for @trustLocationIntegrity.
  ///
  /// In en, this message translates to:
  /// **'Location integrity'**
  String get trustLocationIntegrity;

  /// No description provided for @trustContentModeration.
  ///
  /// In en, this message translates to:
  /// **'Content moderation'**
  String get trustContentModeration;

  /// No description provided for @trustSecurityActivity.
  ///
  /// In en, this message translates to:
  /// **'Security activity'**
  String get trustSecurityActivity;

  /// No description provided for @trustNoSecurityEvents.
  ///
  /// In en, this message translates to:
  /// **'No security events recorded yet.'**
  String get trustNoSecurityEvents;

  /// No description provided for @trustViewAllEvents.
  ///
  /// In en, this message translates to:
  /// **'View all {count} events'**
  String trustViewAllEvents(int count);

  /// No description provided for @trustEventCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 event} other{{count} events}}'**
  String trustEventCount(int count);

  /// No description provided for @trustPrivacyControls.
  ///
  /// In en, this message translates to:
  /// **'Privacy controls'**
  String get trustPrivacyControls;

  /// No description provided for @trustConsentRecorded.
  ///
  /// In en, this message translates to:
  /// **'Consent recorded'**
  String get trustConsentRecorded;

  /// No description provided for @trustNoConsent.
  ///
  /// In en, this message translates to:
  /// **'No consent recorded'**
  String get trustNoConsent;

  /// No description provided for @trustConsentOutdated.
  ///
  /// In en, this message translates to:
  /// **'Consent withdrawn or out of date'**
  String get trustConsentOutdated;

  /// No description provided for @trustConsentAccepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted {time} (Privacy Policy v{privacyVersion}, Terms v{termsVersion}).'**
  String trustConsentAccepted(
    String time,
    String privacyVersion,
    String termsVersion,
  );

  /// No description provided for @trustConsentLastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last updated {time}.'**
  String trustConsentLastUpdated(String time);

  /// No description provided for @trustCurrentVersions.
  ///
  /// In en, this message translates to:
  /// **'Current Privacy Policy v{privacyVersion} · Terms v{termsVersion}'**
  String trustCurrentVersions(String privacyVersion, String termsVersion);

  /// No description provided for @trustExportData.
  ///
  /// In en, this message translates to:
  /// **'View and export my data'**
  String get trustExportData;

  /// No description provided for @trustWithdrawConsent.
  ///
  /// In en, this message translates to:
  /// **'Withdraw consent'**
  String get trustWithdrawConsent;

  /// No description provided for @trustConsentHistory.
  ///
  /// In en, this message translates to:
  /// **'Consent history'**
  String get trustConsentHistory;

  /// No description provided for @trustNoConsentChanges.
  ///
  /// In en, this message translates to:
  /// **'No consent changes recorded yet.'**
  String get trustNoConsentChanges;

  /// No description provided for @trustGrantedGps.
  ///
  /// In en, this message translates to:
  /// **'GPS'**
  String get trustGrantedGps;

  /// No description provided for @trustGrantedAi.
  ///
  /// In en, this message translates to:
  /// **'AI'**
  String get trustGrantedAi;

  /// No description provided for @trustGrantedEvidence.
  ///
  /// In en, this message translates to:
  /// **'evidence sharing'**
  String get trustGrantedEvidence;

  /// No description provided for @trustConsentHistoryEntry.
  ///
  /// In en, this message translates to:
  /// **'{time} · Privacy v{privacyVersion}, Terms v{termsVersion}'**
  String trustConsentHistoryEntry(
    String time,
    String privacyVersion,
    String termsVersion,
  );

  /// No description provided for @trustConsentWithdrawn.
  ///
  /// In en, this message translates to:
  /// **'Consent withdrawn'**
  String get trustConsentWithdrawn;

  /// No description provided for @trustConsentAcceptedTitle.
  ///
  /// In en, this message translates to:
  /// **'Consent accepted'**
  String get trustConsentAcceptedTitle;

  /// No description provided for @trustWithdrawTitle.
  ///
  /// In en, this message translates to:
  /// **'Withdraw consent?'**
  String get trustWithdrawTitle;

  /// No description provided for @trustWithdrawBody.
  ///
  /// In en, this message translates to:
  /// **'FieldNote needs GPS, AI processing and private evidence sharing to work. After you withdraw, matching, check-in, AI drafts and evidence submission stop, and you will be asked to accept again before you can use the app. Your existing records stay until you delete your account.'**
  String get trustWithdrawBody;

  /// No description provided for @trustKeepConsent.
  ///
  /// In en, this message translates to:
  /// **'Keep consent'**
  String get trustKeepConsent;

  /// No description provided for @trustWithdraw.
  ///
  /// In en, this message translates to:
  /// **'Withdraw'**
  String get trustWithdraw;

  /// No description provided for @trustConsentNotWithdrawn.
  ///
  /// In en, this message translates to:
  /// **'Consent not withdrawn'**
  String get trustConsentNotWithdrawn;

  /// No description provided for @trustCheckoutDidNotComplete.
  ///
  /// In en, this message translates to:
  /// **'Checkout did not complete.'**
  String get trustCheckoutDidNotComplete;

  /// No description provided for @eventPaymentOrderCreated.
  ///
  /// In en, this message translates to:
  /// **'Razorpay order created'**
  String get eventPaymentOrderCreated;

  /// No description provided for @eventPaymentSignatureVerified.
  ///
  /// In en, this message translates to:
  /// **'Payment signature checked'**
  String get eventPaymentSignatureVerified;

  /// No description provided for @eventPaymentCheckoutFailed.
  ///
  /// In en, this message translates to:
  /// **'Checkout failed or cancelled'**
  String get eventPaymentCheckoutFailed;

  /// No description provided for @eventPaymentVerifiedWithoutCredit.
  ///
  /// In en, this message translates to:
  /// **'Payment verification reviewed'**
  String get eventPaymentVerifiedWithoutCredit;

  /// No description provided for @eventPaymentOrderCreate.
  ///
  /// In en, this message translates to:
  /// **'Checkout requested'**
  String get eventPaymentOrderCreate;

  /// No description provided for @eventLocationCheckIn.
  ///
  /// In en, this message translates to:
  /// **'Check-in integrity checked'**
  String get eventLocationCheckIn;

  /// No description provided for @eventEvidenceLocationIntegrity.
  ///
  /// In en, this message translates to:
  /// **'Evidence location checked'**
  String get eventEvidenceLocationIntegrity;

  /// No description provided for @eventEvidenceSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Evidence verified'**
  String get eventEvidenceSubmitted;

  /// No description provided for @eventContentModeration.
  ///
  /// In en, this message translates to:
  /// **'Content moderation decision'**
  String get eventContentModeration;

  /// No description provided for @eventPrivacyDataExported.
  ///
  /// In en, this message translates to:
  /// **'Data exported'**
  String get eventPrivacyDataExported;

  /// No description provided for @eventTestPayoutSimulated.
  ///
  /// In en, this message translates to:
  /// **'Test payout recorded'**
  String get eventTestPayoutSimulated;

  /// No description provided for @eventAccountDeletionRequested.
  ///
  /// In en, this message translates to:
  /// **'Deletion requested'**
  String get eventAccountDeletionRequested;

  /// No description provided for @exportLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load your data. Try again.'**
  String get exportLoadFailed;

  /// No description provided for @exportPdfFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not create the PDF. Try again.'**
  String get exportPdfFailed;

  /// No description provided for @exportJsonFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not share the JSON file. Try again.'**
  String get exportJsonFailed;

  /// No description provided for @exportAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'My data'**
  String get exportAppBarTitle;

  /// No description provided for @exportEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Your account records'**
  String get exportEyebrow;

  /// No description provided for @exportTitle.
  ///
  /// In en, this message translates to:
  /// **'Your FieldNote data'**
  String get exportTitle;

  /// No description provided for @exportDescription.
  ///
  /// In en, this message translates to:
  /// **'Read your records here, or save a report to your phone.'**
  String get exportDescription;

  /// No description provided for @exportReportTitle.
  ///
  /// In en, this message translates to:
  /// **'Save or share a readable report'**
  String get exportReportTitle;

  /// No description provided for @exportPreparedAt.
  ///
  /// In en, this message translates to:
  /// **'Prepared {time}. The PDF contains the records shown below.'**
  String exportPreparedAt(String time);

  /// No description provided for @exportPreparingPdf.
  ///
  /// In en, this message translates to:
  /// **'Preparing PDF…'**
  String get exportPreparingPdf;

  /// No description provided for @exportSharePdf.
  ///
  /// In en, this message translates to:
  /// **'Save or share PDF'**
  String get exportSharePdf;

  /// No description provided for @exportRecordCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 record} other{{count} records}}'**
  String exportRecordCount(int count);

  /// No description provided for @exportPhotosNotice.
  ///
  /// In en, this message translates to:
  /// **'Private photographs are not included in this report. Shared files may contain personal details, so choose where to save them carefully.'**
  String get exportPhotosNotice;

  /// No description provided for @exportAdvancedTitle.
  ///
  /// In en, this message translates to:
  /// **'Advanced export'**
  String get exportAdvancedTitle;

  /// No description provided for @exportAdvancedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'For moving data to another service'**
  String get exportAdvancedSubtitle;

  /// No description provided for @exportJsonDescription.
  ///
  /// In en, this message translates to:
  /// **'JSON is a machine-readable copy of these account records.'**
  String get exportJsonDescription;

  /// No description provided for @exportShareJson.
  ///
  /// In en, this message translates to:
  /// **'Save or share JSON'**
  String get exportShareJson;

  /// No description provided for @profileChooseLocation.
  ///
  /// In en, this message translates to:
  /// **'Choose profile location'**
  String get profileChooseLocation;

  /// No description provided for @profileNeedNameAndLocation.
  ///
  /// In en, this message translates to:
  /// **'Enter your display name and location.'**
  String get profileNeedNameAndLocation;

  /// No description provided for @profileNeedNameAndCity.
  ///
  /// In en, this message translates to:
  /// **'Enter your display name and city.'**
  String get profileNeedNameAndCity;

  /// No description provided for @profileNeedInterest.
  ///
  /// In en, this message translates to:
  /// **'Choose at least one interest.'**
  String get profileNeedInterest;

  /// No description provided for @profileSelectLocationSuggestion.
  ///
  /// In en, this message translates to:
  /// **'Select the new location from the Google suggestions.'**
  String get profileSelectLocationSuggestion;

  /// No description provided for @profileSelectCitySuggestion.
  ///
  /// In en, this message translates to:
  /// **'Select the new city from the Google suggestions.'**
  String get profileSelectCitySuggestion;

  /// No description provided for @profileNeedSkill.
  ///
  /// In en, this message translates to:
  /// **'Choose at least one skill.'**
  String get profileNeedSkill;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated.'**
  String get profileUpdated;

  /// No description provided for @profileUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not update your profile.'**
  String get profileUpdateFailed;

  /// No description provided for @profileNoMappedLocation.
  ///
  /// In en, this message translates to:
  /// **'This profile does not have a mapped location yet.'**
  String get profileNoMappedLocation;

  /// No description provided for @profileSponsorAccount.
  ///
  /// In en, this message translates to:
  /// **'Sponsor account'**
  String get profileSponsorAccount;

  /// No description provided for @profileVolunteerAccount.
  ///
  /// In en, this message translates to:
  /// **'Volunteer account'**
  String get profileVolunteerAccount;

  /// No description provided for @profileEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit your profile'**
  String get profileEditTitle;

  /// No description provided for @profileEditDescription.
  ///
  /// In en, this message translates to:
  /// **'Update the details people use to reach you.'**
  String get profileEditDescription;

  /// No description provided for @profileSponsorDescription.
  ///
  /// In en, this message translates to:
  /// **'Your contact and campaign identity.'**
  String get profileSponsorDescription;

  /// No description provided for @profileVolunteerDescription.
  ///
  /// In en, this message translates to:
  /// **'Your account and availability details.'**
  String get profileVolunteerDescription;

  /// No description provided for @profileEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get profileEdit;

  /// No description provided for @profilePhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get profilePhoneNumber;

  /// No description provided for @profileNotProvided.
  ///
  /// In en, this message translates to:
  /// **'Not provided'**
  String get profileNotProvided;

  /// No description provided for @profileAddPhoneHint.
  ///
  /// In en, this message translates to:
  /// **'Add your phone number so volunteers who join your campaigns can call you.'**
  String get profileAddPhoneHint;

  /// No description provided for @profileAddContactNumber.
  ///
  /// In en, this message translates to:
  /// **'Add contact number'**
  String get profileAddContactNumber;

  /// No description provided for @profileHomeArea.
  ///
  /// In en, this message translates to:
  /// **'Home area'**
  String get profileHomeArea;

  /// No description provided for @profileViewLocationOnMap.
  ///
  /// In en, this message translates to:
  /// **'View location on map'**
  String get profileViewLocationOnMap;

  /// No description provided for @profilePhoneSharedNotice.
  ///
  /// In en, this message translates to:
  /// **'Your number is shared only with volunteers who join your campaign.'**
  String get profilePhoneSharedNotice;

  /// No description provided for @profileOrganization.
  ///
  /// In en, this message translates to:
  /// **'Organization'**
  String get profileOrganization;

  /// No description provided for @profileAvailabilityActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get profileAvailabilityActive;

  /// No description provided for @profileAvailabilityPaused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get profileAvailabilityPaused;

  /// No description provided for @commonYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get commonYes;

  /// No description provided for @commonNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get commonNo;

  /// No description provided for @profileRegularDays.
  ///
  /// In en, this message translates to:
  /// **'Regular days'**
  String get profileRegularDays;

  /// No description provided for @profileHours.
  ///
  /// In en, this message translates to:
  /// **'Hours'**
  String get profileHours;

  /// No description provided for @profileHoursRange.
  ///
  /// In en, this message translates to:
  /// **'{start} – {end}'**
  String profileHoursRange(String start, String end);

  /// No description provided for @profileTravelRadius.
  ///
  /// In en, this message translates to:
  /// **'Travel radius'**
  String get profileTravelRadius;

  /// No description provided for @profileKm.
  ///
  /// In en, this message translates to:
  /// **'{distance} km'**
  String profileKm(String distance);

  /// No description provided for @profileTravelArea.
  ///
  /// In en, this message translates to:
  /// **'Travel area'**
  String get profileTravelArea;

  /// No description provided for @profileNotSelected.
  ///
  /// In en, this message translates to:
  /// **'Not selected'**
  String get profileNotSelected;

  /// No description provided for @profileEditAvailability.
  ///
  /// In en, this message translates to:
  /// **'Edit availability and travel area'**
  String get profileEditAvailability;

  /// No description provided for @profileSignOutAllDevices.
  ///
  /// In en, this message translates to:
  /// **'Sign out of all devices'**
  String get profileSignOutAllDevices;

  /// No description provided for @profileEmailNotifications.
  ///
  /// In en, this message translates to:
  /// **'Email notifications'**
  String get profileEmailNotifications;

  /// No description provided for @profileEmailNotificationsBody.
  ///
  /// In en, this message translates to:
  /// **'Emails about campaign changes, cancellations, invitations and confirmations.'**
  String get profileEmailNotificationsBody;

  /// No description provided for @profileEmailNotificationsFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not update email notifications. Try again.'**
  String get profileEmailNotificationsFailed;

  /// No description provided for @profileSignOutAllPartial.
  ///
  /// In en, this message translates to:
  /// **'Signed out here, but other devices could not be reached. Try again after signing in.'**
  String get profileSignOutAllPartial;

  /// No description provided for @profileSignOutLocalOnly.
  ///
  /// In en, this message translates to:
  /// **'Signed out on this device. The server could not be reached to end the session.'**
  String get profileSignOutLocalOnly;

  /// No description provided for @profilePhoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Phone number (required)'**
  String get profilePhoneRequired;

  /// No description provided for @profilePhoneOptional.
  ///
  /// In en, this message translates to:
  /// **'Phone number (optional)'**
  String get profilePhoneOptional;

  /// No description provided for @profilePhoneVisibleToJoined.
  ///
  /// In en, this message translates to:
  /// **'Visible only to joined volunteers.'**
  String get profilePhoneVisibleToJoined;

  /// No description provided for @profilePhonePrivate.
  ///
  /// In en, this message translates to:
  /// **'Private to your account.'**
  String get profilePhonePrivate;

  /// No description provided for @profileScheduleManagedInAvailability.
  ///
  /// In en, this message translates to:
  /// **'Travel area and schedule are managed in Availability.'**
  String get profileScheduleManagedInAvailability;

  /// No description provided for @profileSave.
  ///
  /// In en, this message translates to:
  /// **'Save profile'**
  String get profileSave;

  /// No description provided for @profileHomeCity.
  ///
  /// In en, this message translates to:
  /// **'Home city'**
  String get profileHomeCity;

  /// No description provided for @profileCityHint.
  ///
  /// In en, this message translates to:
  /// **'Start typing a city…'**
  String get profileCityHint;

  /// No description provided for @profileLocationSuggestionHint.
  ///
  /// In en, this message translates to:
  /// **'Choose a suggestion or pin a place on the map.'**
  String get profileLocationSuggestionHint;

  /// No description provided for @profileCitySuggestionHint.
  ///
  /// In en, this message translates to:
  /// **'Choose a city suggestion · Powered by Google'**
  String get profileCitySuggestionHint;

  /// No description provided for @profileCitySearchUnavailable.
  ///
  /// In en, this message translates to:
  /// **'City search is unavailable; enter the city manually.'**
  String get profileCitySearchUnavailable;

  /// No description provided for @profilePrivacyReadOnly.
  ///
  /// In en, this message translates to:
  /// **'Privacy choices (read-only)'**
  String get profilePrivacyReadOnly;

  /// No description provided for @profileConsentGps.
  ///
  /// In en, this message translates to:
  /// **'GPS for matching and evidence'**
  String get profileConsentGps;

  /// No description provided for @profileConsentAi.
  ///
  /// In en, this message translates to:
  /// **'AI processing'**
  String get profileConsentAi;

  /// No description provided for @profileConsentEvidence.
  ///
  /// In en, this message translates to:
  /// **'Evidence sharing'**
  String get profileConsentEvidence;

  /// No description provided for @profilePrivacyReviewHint.
  ///
  /// In en, this message translates to:
  /// **'Review your consent history or withdraw consent in Trust & safety.'**
  String get profilePrivacyReviewHint;

  /// No description provided for @sponsorGoalRange.
  ///
  /// In en, this message translates to:
  /// **'{minimum} to {maximum}.'**
  String sponsorGoalRange(String minimum, String maximum);

  /// No description provided for @sponsorValidationTitle.
  ///
  /// In en, this message translates to:
  /// **'Use {min}–{max} characters.'**
  String sponsorValidationTitle(int min, int max);

  /// No description provided for @sponsorValidationDescription.
  ///
  /// In en, this message translates to:
  /// **'Describe the work in {min}–{max} characters.'**
  String sponsorValidationDescription(int min, int max);

  /// No description provided for @sponsorValidationLocation.
  ///
  /// In en, this message translates to:
  /// **'Name the location.'**
  String get sponsorValidationLocation;

  /// No description provided for @sponsorValidationStartsAt.
  ///
  /// In en, this message translates to:
  /// **'This time has passed. Choose a start date and time in the future.'**
  String get sponsorValidationStartsAt;

  /// No description provided for @sponsorValidationDuration.
  ///
  /// In en, this message translates to:
  /// **'{min}–{max} minutes.'**
  String sponsorValidationDuration(int min, int max);

  /// No description provided for @sponsorValidationCapacity.
  ///
  /// In en, this message translates to:
  /// **'{min}–{max} places.'**
  String sponsorValidationCapacity(int min, int max);

  /// No description provided for @sponsorValidationMinimum.
  ///
  /// In en, this message translates to:
  /// **'Between 1 and the volunteer places.'**
  String get sponsorValidationMinimum;

  /// No description provided for @sponsorValidationChecklist.
  ///
  /// In en, this message translates to:
  /// **'Add at least one checklist task.'**
  String get sponsorValidationChecklist;

  /// No description provided for @sponsorValidationEvidence.
  ///
  /// In en, this message translates to:
  /// **'Describe the evidence volunteers submit ({min}–{max} characters).'**
  String sponsorValidationEvidence(int min, int max);

  /// No description provided for @sponsorValidationLists.
  ///
  /// In en, this message translates to:
  /// **'Keep checklists, skills and tags to {items} items of up to {length} characters.'**
  String sponsorValidationLists(int items, int length);

  /// No description provided for @sponsorValidationScopeGoal.
  ///
  /// In en, this message translates to:
  /// **'Choose a funding goal between {range}'**
  String sponsorValidationScopeGoal(String range);

  /// No description provided for @sponsorValidationScopeMinimum.
  ///
  /// In en, this message translates to:
  /// **'Choose a minimum team between 1 and {capacity}.'**
  String sponsorValidationScopeMinimum(int capacity);

  /// No description provided for @sponsorValidationScopeDescription.
  ///
  /// In en, this message translates to:
  /// **'Describe the revised work in {min}–{max} characters.'**
  String sponsorValidationScopeDescription(int min, int max);

  /// No description provided for @sponsorPayoutsManual.
  ///
  /// In en, this message translates to:
  /// **'Payouts are settled manually by FieldNote operations.'**
  String get sponsorPayoutsManual;

  /// No description provided for @sponsorErrorRequestReused.
  ///
  /// In en, this message translates to:
  /// **'This draft was already published as a different campaign. Review your campaigns, then publish again.'**
  String get sponsorErrorRequestReused;

  /// No description provided for @sponsorErrorRequestInvalid.
  ///
  /// In en, this message translates to:
  /// **'FieldNote could not process that request. Try again.'**
  String get sponsorErrorRequestInvalid;

  /// No description provided for @sponsorErrorDuplicatePayment.
  ///
  /// In en, this message translates to:
  /// **'This payment request was already handled. Start a new checkout.'**
  String get sponsorErrorDuplicatePayment;

  /// No description provided for @sponsorPhaseDraft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get sponsorPhaseDraft;

  /// No description provided for @sponsorPhasePlanning.
  ///
  /// In en, this message translates to:
  /// **'Planning'**
  String get sponsorPhasePlanning;

  /// No description provided for @sponsorPhaseNeedsDecision.
  ///
  /// In en, this message translates to:
  /// **'Needs a decision'**
  String get sponsorPhaseNeedsDecision;

  /// No description provided for @sponsorPhasePostponed.
  ///
  /// In en, this message translates to:
  /// **'Postponed'**
  String get sponsorPhasePostponed;

  /// No description provided for @sponsorPhaseConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get sponsorPhaseConfirmed;

  /// No description provided for @sponsorPhaseInProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get sponsorPhaseInProgress;

  /// No description provided for @sponsorPhaseCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get sponsorPhaseCompleted;

  /// No description provided for @sponsorPhaseCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get sponsorPhaseCancelled;

  /// No description provided for @sponsorPhaseExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get sponsorPhaseExpired;

  /// No description provided for @sponsorPaymentVerified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get sponsorPaymentVerified;

  /// No description provided for @sponsorPaymentRefundQueued.
  ///
  /// In en, this message translates to:
  /// **'Refund queued'**
  String get sponsorPaymentRefundQueued;

  /// No description provided for @sponsorPaymentFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get sponsorPaymentFailed;

  /// No description provided for @sponsorPaymentNotCompleted.
  ///
  /// In en, this message translates to:
  /// **'Not completed'**
  String get sponsorPaymentNotCompleted;

  /// No description provided for @sponsorPaymentPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get sponsorPaymentPending;

  /// No description provided for @sponsorRefundProcessed.
  ///
  /// In en, this message translates to:
  /// **'Refunded'**
  String get sponsorRefundProcessed;

  /// No description provided for @sponsorRefundProcessing.
  ///
  /// In en, this message translates to:
  /// **'Refund processing'**
  String get sponsorRefundProcessing;

  /// No description provided for @sponsorRefundFailed.
  ///
  /// In en, this message translates to:
  /// **'Refund failed'**
  String get sponsorRefundFailed;

  /// No description provided for @sponsorRefundPending.
  ///
  /// In en, this message translates to:
  /// **'Refund pending'**
  String get sponsorRefundPending;

  /// No description provided for @sponsorReviewApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get sponsorReviewApproved;

  /// No description provided for @sponsorReviewRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get sponsorReviewRejected;

  /// No description provided for @sponsorReviewChangesRequested.
  ///
  /// In en, this message translates to:
  /// **'Changes requested'**
  String get sponsorReviewChangesRequested;

  /// No description provided for @sponsorReviewAwaiting.
  ///
  /// In en, this message translates to:
  /// **'Awaiting review'**
  String get sponsorReviewAwaiting;

  /// No description provided for @sponsorRefundReasonCancelled.
  ///
  /// In en, this message translates to:
  /// **'Campaign cancelled'**
  String get sponsorRefundReasonCancelled;

  /// No description provided for @sponsorRefundReasonExpired.
  ///
  /// In en, this message translates to:
  /// **'Campaign expired'**
  String get sponsorRefundReasonExpired;

  /// No description provided for @sponsorRefundReasonUncredited.
  ///
  /// In en, this message translates to:
  /// **'Payment could not be credited'**
  String get sponsorRefundReasonUncredited;

  /// No description provided for @sponsorPinPickerNoMatches.
  ///
  /// In en, this message translates to:
  /// **'No matching places. Try a city, street, or landmark.'**
  String get sponsorPinPickerNoMatches;

  /// No description provided for @sponsorPinPickerSearchUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Place search is unavailable. Use the map or GPS.'**
  String get sponsorPinPickerSearchUnavailable;

  /// No description provided for @sponsorPinPickerResolveFailed.
  ///
  /// In en, this message translates to:
  /// **'That place could not be resolved. Drag the pin instead.'**
  String get sponsorPinPickerResolveFailed;

  /// No description provided for @sponsorPinPickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Where will this happen?'**
  String get sponsorPinPickerTitle;

  /// No description provided for @sponsorPinPickerIntro.
  ///
  /// In en, this message translates to:
  /// **'Search for a place or move the pin to the exact work site. The ring is the check-in geofence volunteers must stand inside.'**
  String get sponsorPinPickerIntro;

  /// No description provided for @sponsorPinPickerFromBrief.
  ///
  /// In en, this message translates to:
  /// **'From your brief: {location}. Choose a search result or set a pin to confirm it.'**
  String sponsorPinPickerFromBrief(String location);

  /// No description provided for @sponsorPinPickerChooseOnMap.
  ///
  /// In en, this message translates to:
  /// **'Choose on map'**
  String get sponsorPinPickerChooseOnMap;

  /// No description provided for @sponsorPinPickerSearchLabel.
  ///
  /// In en, this message translates to:
  /// **'Search for a place'**
  String get sponsorPinPickerSearchLabel;

  /// No description provided for @sponsorPinPickerSearchHint.
  ///
  /// In en, this message translates to:
  /// **'City, street, or landmark…'**
  String get sponsorPinPickerSearchHint;

  /// No description provided for @sponsorPinPickerClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get sponsorPinPickerClear;

  /// No description provided for @sponsorPinPickerMapSemantics.
  ///
  /// In en, this message translates to:
  /// **'Draggable campaign pin with its check-in geofence'**
  String get sponsorPinPickerMapSemantics;

  /// No description provided for @sponsorPinPickerMapFallback.
  ///
  /// In en, this message translates to:
  /// **'Map preview is off. Campaign pin: {latitude}, {longitude} with a {meters} m geofence.'**
  String sponsorPinPickerMapFallback(
    String latitude,
    String longitude,
    int meters,
  );

  /// No description provided for @sponsorPinPickerEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose the campaign site'**
  String get sponsorPinPickerEmptyTitle;

  /// No description provided for @sponsorPinPickerEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Select a place result, choose on the map, or use your device location.'**
  String get sponsorPinPickerEmptyMessage;

  /// No description provided for @sponsorPinPickerLocationNotSelected.
  ///
  /// In en, this message translates to:
  /// **'Location not selected'**
  String get sponsorPinPickerLocationNotSelected;

  /// No description provided for @sponsorPinPickerUnnamedPin.
  ///
  /// In en, this message translates to:
  /// **'Unnamed pin'**
  String get sponsorPinPickerUnnamedPin;

  /// No description provided for @sponsorPinPickerDeviceLocation.
  ///
  /// In en, this message translates to:
  /// **'Your device location'**
  String get sponsorPinPickerDeviceLocation;

  /// No description provided for @sponsorPinPickerGeofenceTitle.
  ///
  /// In en, this message translates to:
  /// **'Check-in geofence · {meters} m'**
  String sponsorPinPickerGeofenceTitle(int meters);

  /// No description provided for @sponsorPinPickerGeofenceValue.
  ///
  /// In en, this message translates to:
  /// **'{meters} m'**
  String sponsorPinPickerGeofenceValue(int meters);

  /// No description provided for @sponsorPinPickerGeofenceHelp.
  ///
  /// In en, this message translates to:
  /// **'Volunteers must be inside this ring, allowing for their GPS accuracy, before they can check in.'**
  String get sponsorPinPickerGeofenceHelp;

  /// No description provided for @sponsorPinPickerFindingLocation.
  ///
  /// In en, this message translates to:
  /// **'Finding my location…'**
  String get sponsorPinPickerFindingLocation;

  /// No description provided for @sponsorPinPickerPinToMyLocation.
  ///
  /// In en, this message translates to:
  /// **'Pin to my location'**
  String get sponsorPinPickerPinToMyLocation;

  /// No description provided for @sponsorPinPickerReachTitle.
  ///
  /// In en, this message translates to:
  /// **'Volunteer reach at this pin'**
  String get sponsorPinPickerReachTitle;

  /// No description provided for @sponsorPinPickerReachChecking.
  ///
  /// In en, this message translates to:
  /// **'Checking who could reach this pin…'**
  String get sponsorPinPickerReachChecking;

  /// No description provided for @sponsorPinPickerReachUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Reach could not be estimated for this pin.'**
  String get sponsorPinPickerReachUnavailable;

  /// No description provided for @sponsorPinPickerMedianDistance.
  ///
  /// In en, this message translates to:
  /// **'Median distance {distance} km.'**
  String sponsorPinPickerMedianDistance(String distance);

  /// No description provided for @sponsorPinPickerReachPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Counts come from volunteers who published availability and a travel radius. Individual volunteer locations are never shown to sponsors.'**
  String get sponsorPinPickerReachPrivacy;

  /// No description provided for @sponsorPinPickerFullMapSearchUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Place search is unavailable. Tap the map to set a pin.'**
  String get sponsorPinPickerFullMapSearchUnavailable;

  /// No description provided for @sponsorPinPickerFullMapOpenFailed.
  ///
  /// In en, this message translates to:
  /// **'That place could not be opened. Choose another result.'**
  String get sponsorPinPickerFullMapOpenFailed;

  /// No description provided for @sponsorPinPickerFullMapTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose campaign location'**
  String get sponsorPinPickerFullMapTitle;

  /// No description provided for @sponsorPinPickerFullMapSemantics.
  ///
  /// In en, this message translates to:
  /// **'Full-screen campaign map. Tap to set the pin.'**
  String get sponsorPinPickerFullMapSemantics;

  /// No description provided for @sponsorPinPickerFullMapFallbackSearch.
  ///
  /// In en, this message translates to:
  /// **'Map tiles are unavailable. Search for a place here, or go back to use device GPS.'**
  String get sponsorPinPickerFullMapFallbackSearch;

  /// No description provided for @sponsorPinPickerFullMapFallbackGps.
  ///
  /// In en, this message translates to:
  /// **'Map tiles are unavailable. Go back to use device GPS.'**
  String get sponsorPinPickerFullMapFallbackGps;

  /// No description provided for @sponsorPinPickerFullMapPrompt.
  ///
  /// In en, this message translates to:
  /// **'Search for a place or tap the map to choose a site.'**
  String get sponsorPinPickerFullMapPrompt;

  /// No description provided for @sponsorPinPickerUseThisPin.
  ///
  /// In en, this message translates to:
  /// **'Use this pin'**
  String get sponsorPinPickerUseThisPin;

  /// No description provided for @sponsorReachLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load nearby volunteers.'**
  String get sponsorReachLoadFailed;

  /// No description provided for @sponsorReachInviteTitle.
  ///
  /// In en, this message translates to:
  /// **'Invite this area?'**
  String get sponsorReachInviteTitle;

  /// No description provided for @sponsorReachInviteBody.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Send an in-app invitation to {campaign} to the available volunteers in this area? Their identities stay private until they choose to join.} =1{Send an in-app invitation to {campaign} to the 1 available volunteer in this area? Their identity stays private until they choose to join.} other{Send an in-app invitation to {campaign} to the {count} available volunteers in this area? Their identities stay private until they choose to join.}}'**
  String sponsorReachInviteBody(int count, String campaign);

  /// No description provided for @sponsorReachCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get sponsorReachCancel;

  /// No description provided for @sponsorReachInviteArea.
  ///
  /// In en, this message translates to:
  /// **'Invite area'**
  String get sponsorReachInviteArea;

  /// No description provided for @sponsorReachAllAlreadyInvited.
  ///
  /// In en, this message translates to:
  /// **'Everyone in this area has already been invited.'**
  String get sponsorReachAllAlreadyInvited;

  /// No description provided for @sponsorReachInvitedCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Invited 1 volunteer in this area.} other{Invited {count} volunteers in this area.}}'**
  String sponsorReachInvitedCount(int count);

  /// No description provided for @sponsorReachInviteFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not send the invitations.'**
  String get sponsorReachInviteFailed;

  /// No description provided for @sponsorReachJoinedInArea.
  ///
  /// In en, this message translates to:
  /// **'Joined in this area'**
  String get sponsorReachJoinedInArea;

  /// No description provided for @sponsorReachApproximateNote.
  ///
  /// In en, this message translates to:
  /// **'Pins show approximate areas, not live locations.'**
  String get sponsorReachApproximateNote;

  /// No description provided for @sponsorReachJoined.
  ///
  /// In en, this message translates to:
  /// **'Joined'**
  String get sponsorReachJoined;

  /// No description provided for @sponsorReachBucketTitle.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Volunteers in this area} =1{1 volunteer in this area} other{{count} volunteers in this area}}'**
  String sponsorReachBucketTitle(int count);

  /// No description provided for @sponsorReachAllInvited.
  ///
  /// In en, this message translates to:
  /// **'All invited'**
  String get sponsorReachAllInvited;

  /// No description provided for @sponsorReachClosed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get sponsorReachClosed;

  /// No description provided for @sponsorReachTitle.
  ///
  /// In en, this message translates to:
  /// **'Nearby volunteers'**
  String get sponsorReachTitle;

  /// No description provided for @sponsorReachPrivacyNote.
  ///
  /// In en, this message translates to:
  /// **'Joined volunteers are named. Everyone else is shown only as an area of at least three people, never individually. Pins show approximate areas.'**
  String get sponsorReachPrivacyNote;

  /// No description provided for @sponsorReachJoinedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} joined'**
  String sponsorReachJoinedCount(int count);

  /// No description provided for @sponsorReachInReachCount.
  ///
  /// In en, this message translates to:
  /// **'{count} in reach'**
  String sponsorReachInReachCount(int count);

  /// No description provided for @sponsorReachAreaCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 area} other{{count} areas}}'**
  String sponsorReachAreaCount(int count);

  /// No description provided for @sponsorReachMapSemantics.
  ///
  /// In en, this message translates to:
  /// **'Campaign and approximate volunteer areas'**
  String get sponsorReachMapSemantics;

  /// No description provided for @sponsorReachMapFallback.
  ///
  /// In en, this message translates to:
  /// **'Map unavailable. Volunteers and invite buttons are listed below.'**
  String get sponsorReachMapFallback;

  /// No description provided for @sponsorReachMarkerTapHint.
  ///
  /// In en, this message translates to:
  /// **'Tap to view volunteers'**
  String get sponsorReachMarkerTapHint;

  /// No description provided for @sponsorReachMarkerVolunteers.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 volunteer} other{{count} volunteers}}'**
  String sponsorReachMarkerVolunteers(int count);

  /// No description provided for @sponsorReachLegendCampaign.
  ///
  /// In en, this message translates to:
  /// **'Campaign'**
  String get sponsorReachLegendCampaign;

  /// No description provided for @sponsorReachLegendVolunteerArea.
  ///
  /// In en, this message translates to:
  /// **'Volunteer area'**
  String get sponsorReachLegendVolunteerArea;

  /// No description provided for @sponsorReachLegendAreaInvited.
  ///
  /// In en, this message translates to:
  /// **'Area invited'**
  String get sponsorReachLegendAreaInvited;

  /// No description provided for @sponsorReachNoneJoined.
  ///
  /// In en, this message translates to:
  /// **'No volunteers have joined yet.'**
  String get sponsorReachNoneJoined;

  /// No description provided for @sponsorReachNearbyAreas.
  ///
  /// In en, this message translates to:
  /// **'Nearby volunteer areas'**
  String get sponsorReachNearbyAreas;

  /// No description provided for @sponsorReachNoAreas.
  ///
  /// In en, this message translates to:
  /// **'No area has enough available volunteers to show yet. Areas appear once at least three volunteers nearby publish availability.'**
  String get sponsorReachNoAreas;

  /// No description provided for @sponsorReachInvitationsClosed.
  ///
  /// In en, this message translates to:
  /// **'Invitations are closed for this campaign.'**
  String get sponsorReachInvitationsClosed;

  /// No description provided for @sponsorCampaignMapLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load the campaign map.'**
  String get sponsorCampaignMapLoadFailed;

  /// No description provided for @sponsorCampaignMapTitle.
  ///
  /// In en, this message translates to:
  /// **'Where the work happened'**
  String get sponsorCampaignMapTitle;

  /// No description provided for @sponsorCampaignMapSemantics.
  ///
  /// In en, this message translates to:
  /// **'Map of volunteer check-ins and evidence locations'**
  String get sponsorCampaignMapSemantics;

  /// No description provided for @sponsorCampaignMapPinUnverifiedEvidence.
  ///
  /// In en, this message translates to:
  /// **'Unverified · evidence'**
  String get sponsorCampaignMapPinUnverifiedEvidence;

  /// No description provided for @sponsorCampaignMapPinUnverifiedCheckIn.
  ///
  /// In en, this message translates to:
  /// **'Unverified · check-in'**
  String get sponsorCampaignMapPinUnverifiedCheckIn;

  /// No description provided for @sponsorCampaignMapPinEvidence.
  ///
  /// In en, this message translates to:
  /// **'Evidence'**
  String get sponsorCampaignMapPinEvidence;

  /// No description provided for @sponsorCampaignMapPinCheckIn.
  ///
  /// In en, this message translates to:
  /// **'Check-in'**
  String get sponsorCampaignMapPinCheckIn;

  /// No description provided for @sponsorCampaignMapPinSnippet.
  ///
  /// In en, this message translates to:
  /// **'{distance} m from the pin · ±{accuracy} m'**
  String sponsorCampaignMapPinSnippet(int distance, int accuracy);

  /// No description provided for @sponsorCampaignMapFallback.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Map preview is off. 1 location-verified point recorded within {meters} m of the campaign pin.} other{Map preview is off. {count} location-verified points recorded within {meters} m of the campaign pin.}}'**
  String sponsorCampaignMapFallback(int count, int meters);

  /// No description provided for @sponsorCampaignMapLegendCampaign.
  ///
  /// In en, this message translates to:
  /// **'Campaign pin & geofence'**
  String get sponsorCampaignMapLegendCampaign;

  /// No description provided for @sponsorCampaignMapLegendEvidence.
  ///
  /// In en, this message translates to:
  /// **'Evidence submitted'**
  String get sponsorCampaignMapLegendEvidence;

  /// No description provided for @sponsorCampaignMapLegendUnverified.
  ///
  /// In en, this message translates to:
  /// **'Unverified legacy point'**
  String get sponsorCampaignMapLegendUnverified;

  /// No description provided for @sponsorCampaignMapJoinedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} joined'**
  String sponsorCampaignMapJoinedCount(int count);

  /// No description provided for @sponsorCampaignMapCheckedInCount.
  ///
  /// In en, this message translates to:
  /// **'{count} checked in'**
  String sponsorCampaignMapCheckedInCount(int count);

  /// No description provided for @sponsorCampaignMapCompletedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} completed'**
  String sponsorCampaignMapCompletedCount(int count);

  /// No description provided for @sponsorCampaignMapUnverifiedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} unverified'**
  String sponsorCampaignMapUnverifiedCount(int count);

  /// No description provided for @sponsorCampaignMapLegacyNote.
  ///
  /// In en, this message translates to:
  /// **'Legacy unverified points are retained for audit history and are never counted as verified field locations.'**
  String get sponsorCampaignMapLegacyNote;

  /// No description provided for @sponsorCampaignMapViewPin.
  ///
  /// In en, this message translates to:
  /// **'View campaign pin'**
  String get sponsorCampaignMapViewPin;

  /// No description provided for @sponsorCampaignMapProvenanceEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Evidence provenance'**
  String get sponsorCampaignMapProvenanceEyebrow;

  /// No description provided for @sponsorCampaignMapProvenanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Verified in place'**
  String get sponsorCampaignMapProvenanceTitle;

  /// No description provided for @sponsorCampaignMapProvenanceSemantics.
  ///
  /// In en, this message translates to:
  /// **'Map of where this evidence was captured'**
  String get sponsorCampaignMapProvenanceSemantics;

  /// No description provided for @sponsorCampaignMapProvenanceFallback.
  ///
  /// In en, this message translates to:
  /// **'Map preview is off. Captured {distance} m from the campaign pin with ±{accuracy} m accuracy.'**
  String sponsorCampaignMapProvenanceFallback(int distance, int accuracy);

  /// No description provided for @sponsorCampaignMapLegacyLocation.
  ///
  /// In en, this message translates to:
  /// **'Legacy location · not verified'**
  String get sponsorCampaignMapLegacyLocation;

  /// No description provided for @sponsorCampaignMapLocationIntegrity.
  ///
  /// In en, this message translates to:
  /// **'Location integrity {status}'**
  String sponsorCampaignMapLocationIntegrity(String status);

  /// No description provided for @sponsorCampaignMapDistanceFact.
  ///
  /// In en, this message translates to:
  /// **'{distance} m from the campaign pin (geofence {geofence} m)'**
  String sponsorCampaignMapDistanceFact(int distance, int geofence);

  /// No description provided for @sponsorCampaignMapAccuracyFact.
  ///
  /// In en, this message translates to:
  /// **'Captured with ±{accuracy} m GPS accuracy'**
  String sponsorCampaignMapAccuracyFact(int accuracy);

  /// No description provided for @sponsorCampaignMapServerChecks.
  ///
  /// In en, this message translates to:
  /// **'Server checks'**
  String get sponsorCampaignMapServerChecks;

  /// No description provided for @sponsorCampaignMapEvidenceLocation.
  ///
  /// In en, this message translates to:
  /// **'Evidence location'**
  String get sponsorCampaignMapEvidenceLocation;

  /// No description provided for @sponsorCampaignMapViewEvidence.
  ///
  /// In en, this message translates to:
  /// **'View evidence point'**
  String get sponsorCampaignMapViewEvidence;

  /// No description provided for @sponsorPayoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Campaign payout'**
  String get sponsorPayoutTitle;

  /// No description provided for @sponsorPayoutLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load payout and refund records.'**
  String get sponsorPayoutLoadFailed;

  /// No description provided for @sponsorPayoutNothingToSimulate.
  ///
  /// In en, this message translates to:
  /// **'No verified Razorpay test checkout is ready to simulate.'**
  String get sponsorPayoutNothingToSimulate;

  /// No description provided for @sponsorPayoutSimulated.
  ///
  /// In en, this message translates to:
  /// **'Test payout recorded. No money was sent.'**
  String get sponsorPayoutSimulated;

  /// No description provided for @sponsorPayoutSimulateFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not simulate payout.'**
  String get sponsorPayoutSimulateFailed;

  /// No description provided for @sponsorPayoutBlockedCancelled.
  ///
  /// In en, this message translates to:
  /// **'This campaign was cancelled, so sponsors are refunded instead of a creator payout.'**
  String get sponsorPayoutBlockedCancelled;

  /// No description provided for @sponsorPayoutBlockedExpired.
  ///
  /// In en, this message translates to:
  /// **'This campaign expired before it was confirmed, so sponsors are refunded instead of a creator payout.'**
  String get sponsorPayoutBlockedExpired;

  /// No description provided for @sponsorPayoutBlockedInProgress.
  ///
  /// In en, this message translates to:
  /// **'The event is under way. A payout can be simulated once FieldNote marks the campaign completed after it ends.'**
  String get sponsorPayoutBlockedInProgress;

  /// No description provided for @sponsorPayoutBlockedNotCompleted.
  ///
  /// In en, this message translates to:
  /// **'A payout can only be simulated after the campaign is completed: the event must take place and FieldNote marks it completed after it ends.'**
  String get sponsorPayoutBlockedNotCompleted;

  /// No description provided for @sponsorPayoutTestModePill.
  ///
  /// In en, this message translates to:
  /// **'Razorpay Test Mode'**
  String get sponsorPayoutTestModePill;

  /// No description provided for @sponsorPayoutManualPill.
  ///
  /// In en, this message translates to:
  /// **'Manual settlement'**
  String get sponsorPayoutManualPill;

  /// No description provided for @sponsorPayoutTestModeNotice.
  ///
  /// In en, this message translates to:
  /// **'Payment testing is active. No real money has moved to a bank account.'**
  String get sponsorPayoutTestModeNotice;

  /// No description provided for @sponsorPayoutCancelledRefunds.
  ///
  /// In en, this message translates to:
  /// **'Campaign cancelled · verified sponsorships are refunded to the original payment method.'**
  String get sponsorPayoutCancelledRefunds;

  /// No description provided for @sponsorPayoutExpiredRefunds.
  ///
  /// In en, this message translates to:
  /// **'Campaign expired · verified sponsorships are refunded to the original payment method.'**
  String get sponsorPayoutExpiredRefunds;

  /// No description provided for @sponsorPayoutStatusTitle.
  ///
  /// In en, this message translates to:
  /// **'Payout status'**
  String get sponsorPayoutStatusTitle;

  /// No description provided for @sponsorPayoutRecordedSponsorships.
  ///
  /// In en, this message translates to:
  /// **'Recorded sponsorships'**
  String get sponsorPayoutRecordedSponsorships;

  /// No description provided for @sponsorPayoutRefundedToSponsors.
  ///
  /// In en, this message translates to:
  /// **'Refunded to sponsors'**
  String get sponsorPayoutRefundedToSponsors;

  /// No description provided for @sponsorPayoutSimulatedCredit.
  ///
  /// In en, this message translates to:
  /// **'Simulated creator credit'**
  String get sponsorPayoutSimulatedCredit;

  /// No description provided for @sponsorPayoutRealTransfer.
  ///
  /// In en, this message translates to:
  /// **'Real bank transfer'**
  String get sponsorPayoutRealTransfer;

  /// No description provided for @sponsorPayoutNoSimulation.
  ///
  /// In en, this message translates to:
  /// **'No simulation yet'**
  String get sponsorPayoutNoSimulation;

  /// No description provided for @sponsorPayoutCreditsRecorded.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 test credit recorded} other{{count} test credits recorded}}'**
  String sponsorPayoutCreditsRecorded(int count);

  /// No description provided for @sponsorPayoutSimulating.
  ///
  /// In en, this message translates to:
  /// **'Recording test payout…'**
  String get sponsorPayoutSimulating;

  /// No description provided for @sponsorPayoutSimulateButton.
  ///
  /// In en, this message translates to:
  /// **'Simulate payout to creator'**
  String get sponsorPayoutSimulateButton;

  /// No description provided for @sponsorPayoutRecipientTitle.
  ///
  /// In en, this message translates to:
  /// **'Recipient account'**
  String get sponsorPayoutRecipientTitle;

  /// No description provided for @sponsorPayoutRecipientAccount.
  ///
  /// In en, this message translates to:
  /// **'Creator test account · in-app ledger only'**
  String get sponsorPayoutRecipientAccount;

  /// No description provided for @sponsorPayoutRecipientHelp.
  ///
  /// In en, this message translates to:
  /// **'Tap Simulate after a verified Razorpay test checkout. Each checkout is credited once in this app’s test ledger. No Razorpay Route transfer or bank deposit occurs.'**
  String get sponsorPayoutRecipientHelp;

  /// No description provided for @sponsorPayoutRefundsTitle.
  ///
  /// In en, this message translates to:
  /// **'Sponsor refunds'**
  String get sponsorPayoutRefundsTitle;

  /// No description provided for @sponsorPayoutCreditHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Test credit history'**
  String get sponsorPayoutCreditHistoryTitle;

  /// No description provided for @sponsorPayoutCheckoutLine.
  ///
  /// In en, this message translates to:
  /// **'Checkout #{id} · {detail}'**
  String sponsorPayoutCheckoutLine(int id, String detail);

  /// No description provided for @sponsorPayoutBeforeLiveTitle.
  ///
  /// In en, this message translates to:
  /// **'Before live payouts'**
  String get sponsorPayoutBeforeLiveTitle;

  /// No description provided for @sponsorPayoutBeforeLiveStep1.
  ///
  /// In en, this message translates to:
  /// **'1. Verify the campaign creator and payout account.'**
  String get sponsorPayoutBeforeLiveStep1;

  /// No description provided for @sponsorPayoutBeforeLiveStep2.
  ///
  /// In en, this message translates to:
  /// **'2. Decide when funds are released if a campaign is delayed, cancelled, or underfunded.'**
  String get sponsorPayoutBeforeLiveStep2;

  /// No description provided for @sponsorPayoutBeforeLiveStep3.
  ///
  /// In en, this message translates to:
  /// **'3. Reconcile provider transfers, failures, and refunds with the campaign ledger.'**
  String get sponsorPayoutBeforeLiveStep3;

  /// No description provided for @sponsorPayoutManualDetail.
  ///
  /// In en, this message translates to:
  /// **'Once the campaign is completed, FieldNote operations verify your payee details outside the app, transfer the verified sponsorships that were not refunded, and email you the bank reference. FieldNote never asks for bank details in the app.'**
  String get sponsorPayoutManualDetail;

  /// No description provided for @sponsorCheckoutFullyFundedTitle.
  ///
  /// In en, this message translates to:
  /// **'Campaign fully funded'**
  String get sponsorCheckoutFullyFundedTitle;

  /// No description provided for @sponsorCheckoutFullyFundedMessage.
  ///
  /// In en, this message translates to:
  /// **'This campaign has already reached its funding goal.'**
  String get sponsorCheckoutFullyFundedMessage;

  /// No description provided for @sponsorCheckoutClosedTitle.
  ///
  /// In en, this message translates to:
  /// **'Campaign closed'**
  String get sponsorCheckoutClosedTitle;

  /// No description provided for @sponsorCheckoutClosedMessage.
  ///
  /// In en, this message translates to:
  /// **'This campaign is no longer accepting sponsorships.'**
  String get sponsorCheckoutClosedMessage;

  /// No description provided for @sponsorCheckoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Sponsor campaign'**
  String get sponsorCheckoutTitle;

  /// No description provided for @sponsorCheckoutBanner.
  ///
  /// In en, this message translates to:
  /// **'Razorpay test checkout. Payment is credited after verification.'**
  String get sponsorCheckoutBanner;

  /// No description provided for @sponsorCheckoutBannerLive.
  ///
  /// In en, this message translates to:
  /// **'Secure Razorpay checkout. Payment is credited after verification.'**
  String get sponsorCheckoutBannerLive;

  /// No description provided for @sponsorCheckoutRemaining.
  ///
  /// In en, this message translates to:
  /// **'{amount} remaining'**
  String sponsorCheckoutRemaining(String amount);

  /// No description provided for @sponsorCheckoutChooseAmount.
  ///
  /// In en, this message translates to:
  /// **'Choose how much to contribute'**
  String get sponsorCheckoutChooseAmount;

  /// No description provided for @sponsorCheckoutMessageLabel.
  ///
  /// In en, this message translates to:
  /// **'Message (optional)'**
  String get sponsorCheckoutMessageLabel;

  /// No description provided for @sponsorCheckoutMessageHint.
  ///
  /// In en, this message translates to:
  /// **'Why this campaign matters to you'**
  String get sponsorCheckoutMessageHint;

  /// No description provided for @sponsorCheckoutNeedsReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment needs review'**
  String get sponsorCheckoutNeedsReviewTitle;

  /// No description provided for @sponsorCheckoutUnsuccessfulTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment unsuccessful'**
  String get sponsorCheckoutUnsuccessfulTitle;

  /// No description provided for @sponsorCheckoutNeedsReviewMessage.
  ///
  /// In en, this message translates to:
  /// **'{reason} If money left your account, it is credited or refunded automatically. See Payment history.'**
  String sponsorCheckoutNeedsReviewMessage(String reason);

  /// No description provided for @sponsorCheckoutProcessing.
  ///
  /// In en, this message translates to:
  /// **'Processing payment…'**
  String get sponsorCheckoutProcessing;

  /// No description provided for @sponsorCheckoutPay.
  ///
  /// In en, this message translates to:
  /// **'Pay {amount}'**
  String sponsorCheckoutPay(String amount);

  /// No description provided for @sponsorCheckoutCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get sponsorCheckoutCancel;

  /// No description provided for @sponsorCheckoutSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment successful'**
  String get sponsorCheckoutSuccessTitle;

  /// No description provided for @sponsorCheckoutSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'{amount} was added to {campaign}.'**
  String sponsorCheckoutSuccessMessage(String amount, String campaign);

  /// No description provided for @sponsorCheckoutNotCompleted.
  ///
  /// In en, this message translates to:
  /// **'The Razorpay test payment was not completed.'**
  String get sponsorCheckoutNotCompleted;

  /// No description provided for @sponsorEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Sponsor'**
  String get sponsorEyebrow;

  /// No description provided for @sponsorDiscoverTitle.
  ///
  /// In en, this message translates to:
  /// **'Campaigns'**
  String get sponsorDiscoverTitle;

  /// No description provided for @sponsorDiscoverTabAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get sponsorDiscoverTabAll;

  /// No description provided for @sponsorDiscoverTabYours.
  ///
  /// In en, this message translates to:
  /// **'Yours'**
  String get sponsorDiscoverTabYours;

  /// No description provided for @sponsorDiscoverTabCreate.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get sponsorDiscoverTabCreate;

  /// No description provided for @sponsorDiscoverLocalCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 local campaign} other{{count} local campaigns}}'**
  String sponsorDiscoverLocalCount(int count);

  /// No description provided for @sponsorDiscoverEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No campaigns yet'**
  String get sponsorDiscoverEmptyTitle;

  /// No description provided for @sponsorDiscoverEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Pull down to refresh or start the first campaign.'**
  String get sponsorDiscoverEmptyMessage;

  /// No description provided for @sponsorDiscoverSponsorAction.
  ///
  /// In en, this message translates to:
  /// **'Sponsor campaign'**
  String get sponsorDiscoverSponsorAction;

  /// No description provided for @sponsorDiscoverFullyFunded.
  ///
  /// In en, this message translates to:
  /// **'Fully funded'**
  String get sponsorDiscoverFullyFunded;

  /// No description provided for @sponsorDiscoverCreatedCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 campaign created} other{{count} campaigns created}}'**
  String sponsorDiscoverCreatedCount(int count);

  /// No description provided for @sponsorDiscoverNoCreatedTitle.
  ///
  /// In en, this message translates to:
  /// **'No campaigns created yet'**
  String get sponsorDiscoverNoCreatedTitle;

  /// No description provided for @sponsorDiscoverNoCreatedMessage.
  ///
  /// In en, this message translates to:
  /// **'Create a campaign to see it here.'**
  String get sponsorDiscoverNoCreatedMessage;

  /// No description provided for @sponsorDiscoverCreateAction.
  ///
  /// In en, this message translates to:
  /// **'Create a campaign'**
  String get sponsorDiscoverCreateAction;

  /// No description provided for @sponsorDiscoverStartTitle.
  ///
  /// In en, this message translates to:
  /// **'Start a campaign'**
  String get sponsorDiscoverStartTitle;

  /// No description provided for @sponsorDiscoverStartBody.
  ///
  /// In en, this message translates to:
  /// **'Describe your idea by voice or text, or enter the details yourself.'**
  String get sponsorDiscoverStartBody;

  /// No description provided for @sponsorDiscoverOpenCreator.
  ///
  /// In en, this message translates to:
  /// **'Open campaign creator'**
  String get sponsorDiscoverOpenCreator;

  /// No description provided for @sponsorOwnedCampaignId.
  ///
  /// In en, this message translates to:
  /// **'CAMPAIGN {id}'**
  String sponsorOwnedCampaignId(String id);

  /// No description provided for @sponsorCampaignPlaces.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 place} other{{count} places}}'**
  String sponsorCampaignPlaces(int count);

  /// No description provided for @sponsorOwnedJoined.
  ///
  /// In en, this message translates to:
  /// **'{joined}/{capacity} joined'**
  String sponsorOwnedJoined(int joined, int capacity);

  /// No description provided for @sponsorOwnedFundingRatio.
  ///
  /// In en, this message translates to:
  /// **'{funded} / {goal}'**
  String sponsorOwnedFundingRatio(String funded, String goal);

  /// No description provided for @sponsorAmountRefunded.
  ///
  /// In en, this message translates to:
  /// **'{amount} refunded'**
  String sponsorAmountRefunded(String amount);

  /// No description provided for @sponsorOwnedVolunteerMap.
  ///
  /// In en, this message translates to:
  /// **'Volunteer map'**
  String get sponsorOwnedVolunteerMap;

  /// No description provided for @sponsorActionShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get sponsorActionShare;

  /// No description provided for @sponsorCreateExamplePrompt.
  ///
  /// In en, this message translates to:
  /// **'I want to sponsor tree care near the university this Saturday. Budget is ₹25,000 and I need about 10 volunteers.'**
  String get sponsorCreateExamplePrompt;

  /// No description provided for @sponsorDictationMicPermission.
  ///
  /// In en, this message translates to:
  /// **'Microphone permission is required. Allow access and try again.'**
  String get sponsorDictationMicPermission;

  /// No description provided for @sponsorDictationNoAudio.
  ///
  /// In en, this message translates to:
  /// **'The microphone stopped before any audio was captured. Check microphone access and try again.'**
  String get sponsorDictationNoAudio;

  /// No description provided for @sponsorDictationTooShort.
  ///
  /// In en, this message translates to:
  /// **'Hold the microphone button while speaking for at least one second.'**
  String get sponsorDictationTooShort;

  /// No description provided for @sponsorDictationFewWords.
  ///
  /// In en, this message translates to:
  /// **'Only a few words were heard. Hold the microphone again, or type the rest of the brief.'**
  String get sponsorDictationFewWords;

  /// No description provided for @sponsorDictationFailed.
  ///
  /// In en, this message translates to:
  /// **'The recording could not be transcribed. Try again, or type the brief.'**
  String get sponsorDictationFailed;

  /// No description provided for @sponsorCreateManualHeading.
  ///
  /// In en, this message translates to:
  /// **'Create a campaign manually'**
  String get sponsorCreateManualHeading;

  /// No description provided for @sponsorCreateConfirmHeading.
  ///
  /// In en, this message translates to:
  /// **'Confirm campaign details'**
  String get sponsorCreateConfirmHeading;

  /// No description provided for @sponsorProposalFormUseDetails.
  ///
  /// In en, this message translates to:
  /// **'Use these details'**
  String get sponsorProposalFormUseDetails;

  /// No description provided for @sponsorCreateBriefTooShort.
  ///
  /// In en, this message translates to:
  /// **'Describe the cause, place, timing, and intended impact first, or create the campaign manually.'**
  String get sponsorCreateBriefTooShort;

  /// No description provided for @sponsorCreateLocationUnreadable.
  ///
  /// In en, this message translates to:
  /// **'Could not read this device location. Check Settings and try again.'**
  String get sponsorCreateLocationUnreadable;

  /// No description provided for @sponsorLocationTurnOnTitle.
  ///
  /// In en, this message translates to:
  /// **'Turn on device location'**
  String get sponsorLocationTurnOnTitle;

  /// No description provided for @sponsorLocationAllowTitle.
  ///
  /// In en, this message translates to:
  /// **'Allow location access'**
  String get sponsorLocationAllowTitle;

  /// No description provided for @sponsorLocationUnavailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Location unavailable'**
  String get sponsorLocationUnavailableTitle;

  /// No description provided for @sponsorLocationNotNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get sponsorLocationNotNow;

  /// No description provided for @sponsorLocationOpenLocationSettings.
  ///
  /// In en, this message translates to:
  /// **'Open location settings'**
  String get sponsorLocationOpenLocationSettings;

  /// No description provided for @sponsorLocationOpenAppSettings.
  ///
  /// In en, this message translates to:
  /// **'Open app settings'**
  String get sponsorLocationOpenAppSettings;

  /// No description provided for @sponsorCreateSelectPlaceResult.
  ///
  /// In en, this message translates to:
  /// **'Select a place result or restore the selected campaign pin.'**
  String get sponsorCreateSelectPlaceResult;

  /// No description provided for @sponsorCreateChooseLocationFirst.
  ///
  /// In en, this message translates to:
  /// **'Choose the campaign location on the map before publishing.'**
  String get sponsorCreateChooseLocationFirst;

  /// No description provided for @sponsorCreateIsLive.
  ///
  /// In en, this message translates to:
  /// **'{name} is live.'**
  String sponsorCreateIsLive(String name);

  /// No description provided for @sponsorCreatePublishFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not publish the campaign.'**
  String get sponsorCreatePublishFailed;

  /// No description provided for @sponsorCreateGenerateFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not generate the campaign.'**
  String get sponsorCreateGenerateFailed;

  /// No description provided for @sponsorCreateEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Sponsor studio'**
  String get sponsorCreateEyebrow;

  /// No description provided for @sponsorCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'Create a campaign'**
  String get sponsorCreateTitle;

  /// No description provided for @sponsorCreateDescription.
  ///
  /// In en, this message translates to:
  /// **'Describe the work, then review the draft before publishing.'**
  String get sponsorCreateDescription;

  /// No description provided for @sponsorCreatePromptTitle.
  ///
  /// In en, this message translates to:
  /// **'What needs to happen?'**
  String get sponsorCreatePromptTitle;

  /// No description provided for @sponsorCreatePromptHelp.
  ///
  /// In en, this message translates to:
  /// **'Type a brief, or hold the round microphone while you speak and release when finished.'**
  String get sponsorCreatePromptHelp;

  /// No description provided for @sponsorCreateListening.
  ///
  /// In en, this message translates to:
  /// **'Listening…'**
  String get sponsorCreateListening;

  /// No description provided for @sponsorCreatePromptHint.
  ///
  /// In en, this message translates to:
  /// **'Cause, place, date, budget, and volunteers…'**
  String get sponsorCreatePromptHint;

  /// No description provided for @sponsorCreateClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get sponsorCreateClear;

  /// No description provided for @sponsorCreateExampleButton.
  ///
  /// In en, this message translates to:
  /// **'Start from an example brief'**
  String get sponsorCreateExampleButton;

  /// No description provided for @sponsorCreateProcessingRecording.
  ///
  /// In en, this message translates to:
  /// **'Processing recording…'**
  String get sponsorCreateProcessingRecording;

  /// No description provided for @sponsorCreateGenerating.
  ///
  /// In en, this message translates to:
  /// **'Generating campaign…'**
  String get sponsorCreateGenerating;

  /// No description provided for @sponsorCreateGenerate.
  ///
  /// In en, this message translates to:
  /// **'Generate campaign'**
  String get sponsorCreateGenerate;

  /// No description provided for @sponsorCreateManualButton.
  ///
  /// In en, this message translates to:
  /// **'Enter campaign details manually'**
  String get sponsorCreateManualButton;

  /// No description provided for @sponsorCreateManualNote.
  ///
  /// In en, this message translates to:
  /// **'Manual entry works when AI is busy.'**
  String get sponsorCreateManualNote;

  /// No description provided for @sponsorCreateProposalPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Your editable proposal will appear here.'**
  String get sponsorCreateProposalPlaceholder;

  /// No description provided for @sponsorProposalAssistedDraft.
  ///
  /// In en, this message translates to:
  /// **'Assisted draft'**
  String get sponsorProposalAssistedDraft;

  /// No description provided for @sponsorProposalGoal.
  ///
  /// In en, this message translates to:
  /// **'{amount} goal'**
  String sponsorProposalGoal(String amount);

  /// No description provided for @sponsorProposalTeamSummary.
  ///
  /// In en, this message translates to:
  /// **'{places} · {minimum} minimum safe team · {hours}'**
  String sponsorProposalTeamSummary(String places, int minimum, String hours);

  /// No description provided for @sponsorProposalHours.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 hour} other{{count} hours}}'**
  String sponsorProposalHours(int count);

  /// No description provided for @sponsorWorkChecklist.
  ///
  /// In en, this message translates to:
  /// **'Work checklist'**
  String get sponsorWorkChecklist;

  /// No description provided for @sponsorProposalEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get sponsorProposalEdit;

  /// No description provided for @sponsorProposalPublish.
  ///
  /// In en, this message translates to:
  /// **'Publish'**
  String get sponsorProposalPublish;

  /// No description provided for @sponsorImpactTitle.
  ///
  /// In en, this message translates to:
  /// **'Campaign impact'**
  String get sponsorImpactTitle;

  /// No description provided for @sponsorImpactDescription.
  ///
  /// In en, this message translates to:
  /// **'Follow funding, volunteers, and completed work.'**
  String get sponsorImpactDescription;

  /// No description provided for @sponsorImpactPaymentHistory.
  ///
  /// In en, this message translates to:
  /// **'Payment history'**
  String get sponsorImpactPaymentHistory;

  /// No description provided for @sponsorImpactPaymentHistoryReview.
  ///
  /// In en, this message translates to:
  /// **'Payment history · {count} to review'**
  String sponsorImpactPaymentHistoryReview(int count);

  /// No description provided for @sponsorImpactEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No sponsored impact yet'**
  String get sponsorImpactEmptyTitle;

  /// No description provided for @sponsorImpactEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Create or sponsor a campaign to begin the evidence loop.'**
  String get sponsorImpactEmptyMessage;

  /// No description provided for @sponsorLiveConnected.
  ///
  /// In en, this message translates to:
  /// **'Live'**
  String get sponsorLiveConnected;

  /// No description provided for @sponsorLiveReconnecting.
  ///
  /// In en, this message translates to:
  /// **'Reconnecting…'**
  String get sponsorLiveReconnecting;

  /// No description provided for @sponsorLiveConnecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting…'**
  String get sponsorLiveConnecting;

  /// No description provided for @sponsorLiveNotListening.
  ///
  /// In en, this message translates to:
  /// **'Not listening'**
  String get sponsorLiveNotListening;

  /// No description provided for @sponsorImpactStopLive.
  ///
  /// In en, this message translates to:
  /// **'Stop live updates for this campaign'**
  String get sponsorImpactStopLive;

  /// No description provided for @sponsorImpactListenLive.
  ///
  /// In en, this message translates to:
  /// **'Listen for live updates'**
  String get sponsorImpactListenLive;

  /// No description provided for @sponsorImpactLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading campaign impact…'**
  String get sponsorImpactLoading;

  /// No description provided for @sponsorImpactCancelledNote.
  ///
  /// In en, this message translates to:
  /// **'This campaign was cancelled. Verified sponsorships are refunded to the original payment method.'**
  String get sponsorImpactCancelledNote;

  /// No description provided for @sponsorImpactExpiredNote.
  ///
  /// In en, this message translates to:
  /// **'This campaign expired before it was confirmed. Verified sponsorships are refunded to the original payment method.'**
  String get sponsorImpactExpiredNote;

  /// No description provided for @sponsorImpactMetricSponsored.
  ///
  /// In en, this message translates to:
  /// **'Sponsored'**
  String get sponsorImpactMetricSponsored;

  /// No description provided for @sponsorImpactMetricRefunded.
  ///
  /// In en, this message translates to:
  /// **'Refunded'**
  String get sponsorImpactMetricRefunded;

  /// No description provided for @sponsorImpactMetricJoined.
  ///
  /// In en, this message translates to:
  /// **'Joined'**
  String get sponsorImpactMetricJoined;

  /// No description provided for @sponsorImpactMetricCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get sponsorImpactMetricCompleted;

  /// No description provided for @sponsorImpactMetricEvidence.
  ///
  /// In en, this message translates to:
  /// **'Evidence'**
  String get sponsorImpactMetricEvidence;

  /// No description provided for @sponsorImpactVolunteers.
  ///
  /// In en, this message translates to:
  /// **'Volunteers'**
  String get sponsorImpactVolunteers;

  /// No description provided for @sponsorImpactReadiness.
  ///
  /// In en, this message translates to:
  /// **'Readiness'**
  String get sponsorImpactReadiness;

  /// No description provided for @sponsorImpactPayout.
  ///
  /// In en, this message translates to:
  /// **'Payout'**
  String get sponsorImpactPayout;

  /// No description provided for @sponsorImpactPostUpdate.
  ///
  /// In en, this message translates to:
  /// **'Post update'**
  String get sponsorImpactPostUpdate;

  /// No description provided for @sponsorImpactUpdatePublishedTitle.
  ///
  /// In en, this message translates to:
  /// **'Update published'**
  String get sponsorImpactUpdatePublishedTitle;

  /// No description provided for @sponsorImpactUpdatePublishedMessage.
  ///
  /// In en, this message translates to:
  /// **'Volunteers and sponsors can now read \"{title}\".'**
  String sponsorImpactUpdatePublishedMessage(String title);

  /// No description provided for @sponsorEvidenceTitle.
  ///
  /// In en, this message translates to:
  /// **'Field evidence'**
  String get sponsorEvidenceTitle;

  /// No description provided for @sponsorEvidenceTapToReview.
  ///
  /// In en, this message translates to:
  /// **'Tap a photograph to review it and see exactly where it was captured.'**
  String get sponsorEvidenceTapToReview;

  /// No description provided for @sponsorEvidenceTapToSee.
  ///
  /// In en, this message translates to:
  /// **'Tap a photograph to see exactly where it was captured.'**
  String get sponsorEvidenceTapToSee;

  /// No description provided for @sponsorEvidencePhotoUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Photo unavailable · Retry'**
  String get sponsorEvidencePhotoUnavailable;

  /// No description provided for @sponsorEvidenceReloadPhoto.
  ///
  /// In en, this message translates to:
  /// **'Reload photo'**
  String get sponsorEvidenceReloadPhoto;

  /// No description provided for @sponsorEvidenceLocationUnverified.
  ///
  /// In en, this message translates to:
  /// **'Unverified location'**
  String get sponsorEvidenceLocationUnverified;

  /// No description provided for @sponsorEvidenceLocationVerified.
  ///
  /// In en, this message translates to:
  /// **'Location verified'**
  String get sponsorEvidenceLocationVerified;

  /// No description provided for @sponsorEvidenceReviewAndSee.
  ///
  /// In en, this message translates to:
  /// **'Review and see where it was captured'**
  String get sponsorEvidenceReviewAndSee;

  /// No description provided for @sponsorEvidenceSeeWhere.
  ///
  /// In en, this message translates to:
  /// **'See where this was captured'**
  String get sponsorEvidenceSeeWhere;

  /// No description provided for @sponsorEvidenceRejectNoteTooShort.
  ///
  /// In en, this message translates to:
  /// **'Explain why the evidence is rejected (at least {minimum} characters).'**
  String sponsorEvidenceRejectNoteTooShort(int minimum);

  /// No description provided for @sponsorEvidenceNoteTooLong.
  ///
  /// In en, this message translates to:
  /// **'Keep the note under {maximum} characters.'**
  String sponsorEvidenceNoteTooLong(int maximum);

  /// No description provided for @sponsorEvidenceApproved.
  ///
  /// In en, this message translates to:
  /// **'Evidence approved.'**
  String get sponsorEvidenceApproved;

  /// No description provided for @sponsorEvidenceRejected.
  ///
  /// In en, this message translates to:
  /// **'Evidence rejected.'**
  String get sponsorEvidenceRejected;

  /// No description provided for @sponsorEvidenceReviewFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save the review.'**
  String get sponsorEvidenceReviewFailed;

  /// No description provided for @sponsorEvidenceYourReview.
  ///
  /// In en, this message translates to:
  /// **'Your review'**
  String get sponsorEvidenceYourReview;

  /// No description provided for @sponsorEvidenceAiDrafted.
  ///
  /// In en, this message translates to:
  /// **'The summary was drafted by AI and confirmed by the volunteer.'**
  String get sponsorEvidenceAiDrafted;

  /// No description provided for @sponsorEvidenceSavedNote.
  ///
  /// In en, this message translates to:
  /// **'Note: {note}'**
  String sponsorEvidenceSavedNote(String note);

  /// No description provided for @sponsorEvidenceNoteLabel.
  ///
  /// In en, this message translates to:
  /// **'Note to the volunteer'**
  String get sponsorEvidenceNoteLabel;

  /// No description provided for @sponsorEvidenceNoteHelper.
  ///
  /// In en, this message translates to:
  /// **'Required when rejecting'**
  String get sponsorEvidenceNoteHelper;

  /// No description provided for @sponsorEvidenceReject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get sponsorEvidenceReject;

  /// No description provided for @sponsorEvidenceApprove.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get sponsorEvidenceApprove;

  /// No description provided for @sponsorCardMatch.
  ///
  /// In en, this message translates to:
  /// **'{percent}% match'**
  String sponsorCardMatch(int percent);

  /// No description provided for @sponsorCardDateTentative.
  ///
  /// In en, this message translates to:
  /// **'Date tentative'**
  String get sponsorCardDateTentative;

  /// No description provided for @sponsorCardAwaitingDecision.
  ///
  /// In en, this message translates to:
  /// **'Awaiting decision'**
  String get sponsorCardAwaitingDecision;

  /// No description provided for @sponsorCardPlaceAndDate.
  ///
  /// In en, this message translates to:
  /// **'{location} · {date}'**
  String sponsorCardPlaceAndDate(String location, String date);

  /// No description provided for @sponsorFundingOfGoal.
  ///
  /// In en, this message translates to:
  /// **'{funded} of {goal}'**
  String sponsorFundingOfGoal(String funded, String goal);

  /// No description provided for @sponsorFundingOfGoalRefunded.
  ///
  /// In en, this message translates to:
  /// **'{funded} of {goal} · {refunded} refunded'**
  String sponsorFundingOfGoalRefunded(
    String funded,
    String goal,
    String refunded,
  );

  /// No description provided for @sponsorProposalFormChooseLocation.
  ///
  /// In en, this message translates to:
  /// **'Choose campaign location'**
  String get sponsorProposalFormChooseLocation;

  /// No description provided for @sponsorProposalFormDefaultSkill.
  ///
  /// In en, this message translates to:
  /// **'No specialist skills'**
  String get sponsorProposalFormDefaultSkill;

  /// No description provided for @sponsorProposalFormDefaultEvidence.
  ///
  /// In en, this message translates to:
  /// **'Submit a location-verified photograph and describe the completed work.'**
  String get sponsorProposalFormDefaultEvidence;

  /// No description provided for @sponsorProposalFormFixFields.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Fix the highlighted field.} other{Fix the {count} highlighted fields.}}'**
  String sponsorProposalFormFixFields(int count);

  /// No description provided for @sponsorProposalFormBasics.
  ///
  /// In en, this message translates to:
  /// **'Basics'**
  String get sponsorProposalFormBasics;

  /// No description provided for @sponsorProposalFormTitle.
  ///
  /// In en, this message translates to:
  /// **'Campaign title'**
  String get sponsorProposalFormTitle;

  /// No description provided for @sponsorProposalFormDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get sponsorProposalFormDescription;

  /// No description provided for @sponsorProposalFormLocation.
  ///
  /// In en, this message translates to:
  /// **'Location name'**
  String get sponsorProposalFormLocation;

  /// No description provided for @sponsorProposalFormChooseOnMap.
  ///
  /// In en, this message translates to:
  /// **'Choose on map'**
  String get sponsorProposalFormChooseOnMap;

  /// No description provided for @sponsorProposalFormSchedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule and capacity'**
  String get sponsorProposalFormSchedule;

  /// No description provided for @sponsorProposalFormStartsAt.
  ///
  /// In en, this message translates to:
  /// **'Starts at'**
  String get sponsorProposalFormStartsAt;

  /// No description provided for @sponsorProposalFormStartPassed.
  ///
  /// In en, this message translates to:
  /// **'This time has passed. Choose a start date and time in the future.'**
  String get sponsorProposalFormStartPassed;

  /// No description provided for @sponsorProposalFormFunding.
  ///
  /// In en, this message translates to:
  /// **'Funding goal (₹)'**
  String get sponsorProposalFormFunding;

  /// No description provided for @sponsorProposalFormRange.
  ///
  /// In en, this message translates to:
  /// **'{minimum} – {maximum}'**
  String sponsorProposalFormRange(String minimum, String maximum);

  /// No description provided for @sponsorProposalFormPlaces.
  ///
  /// In en, this message translates to:
  /// **'Volunteer places'**
  String get sponsorProposalFormPlaces;

  /// No description provided for @sponsorProposalFormMinimumTeam.
  ///
  /// In en, this message translates to:
  /// **'Minimum safe team'**
  String get sponsorProposalFormMinimumTeam;

  /// No description provided for @sponsorProposalFormMinutes.
  ///
  /// In en, this message translates to:
  /// **'Minutes'**
  String get sponsorProposalFormMinutes;

  /// No description provided for @sponsorProposalFormWork.
  ///
  /// In en, this message translates to:
  /// **'Work and evidence'**
  String get sponsorProposalFormWork;

  /// No description provided for @sponsorProposalFormOneTaskPerLine.
  ///
  /// In en, this message translates to:
  /// **'One task per line'**
  String get sponsorProposalFormOneTaskPerLine;

  /// No description provided for @sponsorProposalFormSkills.
  ///
  /// In en, this message translates to:
  /// **'Required skills'**
  String get sponsorProposalFormSkills;

  /// No description provided for @sponsorProposalFormOnePerLine.
  ///
  /// In en, this message translates to:
  /// **'One per line'**
  String get sponsorProposalFormOnePerLine;

  /// No description provided for @sponsorProposalFormEvidence.
  ///
  /// In en, this message translates to:
  /// **'Evidence instructions'**
  String get sponsorProposalFormEvidence;

  /// No description provided for @sponsorProposalFormTags.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get sponsorProposalFormTags;

  /// No description provided for @sponsorProposalFormCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get sponsorProposalFormCancel;

  /// No description provided for @sponsorPaymentHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment history'**
  String get sponsorPaymentHistoryTitle;

  /// No description provided for @sponsorPaymentHistoryIntro.
  ///
  /// In en, this message translates to:
  /// **'Razorpay Test Mode. Payments are credited only after the server verifies them; anything that could not be credited is refunded automatically.'**
  String get sponsorPaymentHistoryIntro;

  /// No description provided for @sponsorPaymentHistoryEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No payments yet'**
  String get sponsorPaymentHistoryEmptyTitle;

  /// No description provided for @sponsorPaymentHistoryEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Sponsor a campaign and it will be listed here.'**
  String get sponsorPaymentHistoryEmptyMessage;

  /// No description provided for @sponsorPaymentRefundedOn.
  ///
  /// In en, this message translates to:
  /// **'{amount} refunded on {date}.'**
  String sponsorPaymentRefundedOn(String amount, String date);

  /// No description provided for @sponsorPaymentRefunded.
  ///
  /// In en, this message translates to:
  /// **'{amount} refunded.'**
  String sponsorPaymentRefunded(String amount);

  /// No description provided for @sponsorPaymentRefundFailedDetail.
  ///
  /// In en, this message translates to:
  /// **'The refund of {amount} failed. FieldNote will contact you to resolve it.'**
  String sponsorPaymentRefundFailedDetail(String amount);

  /// No description provided for @sponsorPaymentRefundOnItsWay.
  ///
  /// In en, this message translates to:
  /// **'A refund of {amount} is on its way to the original payment method.'**
  String sponsorPaymentRefundOnItsWay(String amount);

  /// No description provided for @sponsorPaymentUncreditedDetail.
  ///
  /// In en, this message translates to:
  /// **'The payment was verified but could not be credited (for example the campaign closed or was already fully funded). It will be refunded automatically.'**
  String get sponsorPaymentUncreditedDetail;

  /// No description provided for @sponsorPaymentAwaitingConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Waiting for Razorpay to confirm this payment. It updates automatically.'**
  String get sponsorPaymentAwaitingConfirmation;

  /// No description provided for @sponsorReadinessUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not update campaign readiness.'**
  String get sponsorReadinessUpdateFailed;

  /// No description provided for @sponsorReadinessReviseTitle.
  ///
  /// In en, this message translates to:
  /// **'Revise the work scope'**
  String get sponsorReadinessReviseTitle;

  /// No description provided for @sponsorReadinessReviseIntro.
  ///
  /// In en, this message translates to:
  /// **'A revised scope asks joined volunteers to reconfirm before they count toward the minimum team.'**
  String get sponsorReadinessReviseIntro;

  /// No description provided for @sponsorReadinessReviseGoalLabel.
  ///
  /// In en, this message translates to:
  /// **'Revised funding goal (₹)'**
  String get sponsorReadinessReviseGoalLabel;

  /// No description provided for @sponsorReadinessRange.
  ///
  /// In en, this message translates to:
  /// **'{min} – {max}'**
  String sponsorReadinessRange(String min, String max);

  /// No description provided for @sponsorReadinessReviseMinimumLabel.
  ///
  /// In en, this message translates to:
  /// **'Minimum safe team'**
  String get sponsorReadinessReviseMinimumLabel;

  /// No description provided for @sponsorReadinessReviseDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Revised work description'**
  String get sponsorReadinessReviseDescriptionLabel;

  /// No description provided for @sponsorReadinessSaveRevision.
  ///
  /// In en, this message translates to:
  /// **'Save revision'**
  String get sponsorReadinessSaveRevision;

  /// No description provided for @sponsorReadinessPostponePast.
  ///
  /// In en, this message translates to:
  /// **'That time has already passed. Choose a new start in the future.'**
  String get sponsorReadinessPostponePast;

  /// No description provided for @sponsorReadinessCancelTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel this campaign?'**
  String get sponsorReadinessCancelTitle;

  /// No description provided for @sponsorReadinessCancelBody.
  ///
  /// In en, this message translates to:
  /// **'{joined, plural, =1{1 volunteer has} other{{joined} volunteers have}} joined. Their places are released and they are emailed and told not to travel.\n\nEvery verified sponsorship ({recorded} recorded) is refunded to the original payment method. This cannot be undone.'**
  String sponsorReadinessCancelBody(int joined, String recorded);

  /// No description provided for @sponsorReadinessKeepCampaign.
  ///
  /// In en, this message translates to:
  /// **'Keep campaign'**
  String get sponsorReadinessKeepCampaign;

  /// No description provided for @sponsorReadinessCancelCampaign.
  ///
  /// In en, this message translates to:
  /// **'Cancel campaign'**
  String get sponsorReadinessCancelCampaign;

  /// No description provided for @sponsorReadinessInviteMessage.
  ///
  /// In en, this message translates to:
  /// **'Volunteer places are open on FieldNote. Join here: {link}'**
  String sponsorReadinessInviteMessage(String link);

  /// No description provided for @sponsorReadinessInviteCopied.
  ///
  /// In en, this message translates to:
  /// **'Invite and campaign link copied. Share them with your volunteers.'**
  String get sponsorReadinessInviteCopied;

  /// No description provided for @sponsorReadinessFundingShort.
  ///
  /// In en, this message translates to:
  /// **'Funding short'**
  String get sponsorReadinessFundingShort;

  /// No description provided for @sponsorReadinessVolunteersShort.
  ///
  /// In en, this message translates to:
  /// **'Volunteers short'**
  String get sponsorReadinessVolunteersShort;

  /// No description provided for @sponsorReadinessBothShort.
  ///
  /// In en, this message translates to:
  /// **'Funding and volunteers short'**
  String get sponsorReadinessBothShort;

  /// No description provided for @sponsorReadinessPostponedCutoff.
  ///
  /// In en, this message translates to:
  /// **'Postponed · awaiting cutoff'**
  String get sponsorReadinessPostponedCutoff;

  /// No description provided for @sponsorReadinessPostponedReconfirm.
  ///
  /// In en, this message translates to:
  /// **'Postponed · awaiting reconfirmation'**
  String get sponsorReadinessPostponedReconfirm;

  /// No description provided for @sponsorReadinessDateExpired.
  ///
  /// In en, this message translates to:
  /// **'Date expired'**
  String get sponsorReadinessDateExpired;

  /// No description provided for @sponsorReadinessOpenTentative.
  ///
  /// In en, this message translates to:
  /// **'Open · date tentative'**
  String get sponsorReadinessOpenTentative;

  /// No description provided for @sponsorReadinessTitle.
  ///
  /// In en, this message translates to:
  /// **'Campaign readiness'**
  String get sponsorReadinessTitle;

  /// No description provided for @sponsorReadinessCutoffTitle.
  ///
  /// In en, this message translates to:
  /// **'At the cutoff'**
  String get sponsorReadinessCutoffTitle;

  /// No description provided for @sponsorReadinessCheckedBefore.
  ///
  /// In en, this message translates to:
  /// **'Readiness is checked 24 hours before {start}.'**
  String sponsorReadinessCheckedBefore(String start);

  /// No description provided for @sponsorReadinessReadyBeforeCutoff.
  ///
  /// In en, this message translates to:
  /// **'Funding and the minimum team are ready. The event will be checked for confirmation on {cutoff}.'**
  String sponsorReadinessReadyBeforeCutoff(String cutoff);

  /// No description provided for @sponsorReadinessTentativeUntil.
  ///
  /// In en, this message translates to:
  /// **'The event stays tentative until {cutoff}. Refreshing now updates the counts.'**
  String sponsorReadinessTentativeUntil(String cutoff);

  /// No description provided for @sponsorReadinessFundingLine.
  ///
  /// In en, this message translates to:
  /// **'Funding: {funded} of {goal} · {short} short'**
  String sponsorReadinessFundingLine(String funded, String goal, String short);

  /// No description provided for @sponsorReadinessRefundedLine.
  ///
  /// In en, this message translates to:
  /// **'{amount} refunded to sponsors'**
  String sponsorReadinessRefundedLine(String amount);

  /// No description provided for @sponsorReadinessTeamLine.
  ///
  /// In en, this message translates to:
  /// **'Team: {joined} joined · {minimum} minimum · {short} short'**
  String sponsorReadinessTeamLine(int joined, int minimum, int short);

  /// No description provided for @sponsorReadinessReconfirmNote.
  ///
  /// In en, this message translates to:
  /// **'After a scope or date change, joined volunteers must reconfirm before counting toward readiness.'**
  String get sponsorReadinessReconfirmNote;

  /// No description provided for @sponsorReadinessStartedLocked.
  ///
  /// In en, this message translates to:
  /// **'This campaign has started. Its date and scope are locked and it can no longer be cancelled.'**
  String get sponsorReadinessStartedLocked;

  /// No description provided for @sponsorReadinessDecisionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Sponsor decisions'**
  String get sponsorReadinessDecisionsTitle;

  /// No description provided for @sponsorReadinessTopUpHint.
  ///
  /// In en, this message translates to:
  /// **'Top up through the sponsor checkout. A verified payment updates the funding result.'**
  String get sponsorReadinessTopUpHint;

  /// No description provided for @sponsorReadinessRecruitHint.
  ///
  /// In en, this message translates to:
  /// **'Keep recruiting volunteers. New joins and reconfirmations update the team result.'**
  String get sponsorReadinessRecruitHint;

  /// No description provided for @sponsorReadinessCopyInvite.
  ///
  /// In en, this message translates to:
  /// **'Copy volunteer invite'**
  String get sponsorReadinessCopyInvite;

  /// No description provided for @sponsorReadinessOpenCheckout.
  ///
  /// In en, this message translates to:
  /// **'Open sponsor checkout'**
  String get sponsorReadinessOpenCheckout;

  /// No description provided for @sponsorReadinessReviseScope.
  ///
  /// In en, this message translates to:
  /// **'Revise scope'**
  String get sponsorReadinessReviseScope;

  /// No description provided for @sponsorReadinessPostpone.
  ///
  /// In en, this message translates to:
  /// **'Postpone'**
  String get sponsorReadinessPostpone;

  /// No description provided for @sponsorReadinessRefreshStatus.
  ///
  /// In en, this message translates to:
  /// **'Refresh status'**
  String get sponsorReadinessRefreshStatus;

  /// No description provided for @sponsorPostTitleInvalid.
  ///
  /// In en, this message translates to:
  /// **'Give the update a title of {min}–{max} characters.'**
  String sponsorPostTitleInvalid(int min, int max);

  /// No description provided for @sponsorPostBodyInvalid.
  ///
  /// In en, this message translates to:
  /// **'Write {min}–{max} characters for the update.'**
  String sponsorPostBodyInvalid(int min, int max);

  /// No description provided for @sponsorPostPublishFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not publish the update.'**
  String get sponsorPostPublishFailed;

  /// No description provided for @sponsorPostTitle.
  ///
  /// In en, this message translates to:
  /// **'Post an update'**
  String get sponsorPostTitle;

  /// No description provided for @sponsorPostAudience.
  ///
  /// In en, this message translates to:
  /// **'Volunteers and sponsors of {campaign} will see this update.'**
  String sponsorPostAudience(String campaign);

  /// No description provided for @sponsorPostTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get sponsorPostTitleLabel;

  /// No description provided for @sponsorPostBodyLabel.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get sponsorPostBodyLabel;

  /// No description provided for @sponsorPostPublishing.
  ///
  /// In en, this message translates to:
  /// **'Publishing…'**
  String get sponsorPostPublishing;

  /// No description provided for @sponsorPostPublish.
  ///
  /// In en, this message translates to:
  /// **'Publish update'**
  String get sponsorPostPublish;

  /// No description provided for @sponsorDiscardTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard changes?'**
  String get sponsorDiscardTitle;

  /// No description provided for @sponsorDiscardMessage.
  ///
  /// In en, this message translates to:
  /// **'What you entered in this form will be lost.'**
  String get sponsorDiscardMessage;

  /// No description provided for @sponsorDiscardKeepEditing.
  ///
  /// In en, this message translates to:
  /// **'Keep editing'**
  String get sponsorDiscardKeepEditing;

  /// No description provided for @sponsorDiscardConfirm.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get sponsorDiscardConfirm;

  /// No description provided for @coreErrorSessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Your session expired, please sign in again.'**
  String get coreErrorSessionExpired;

  /// No description provided for @coreErrorOffline.
  ///
  /// In en, this message translates to:
  /// **'Can\'t reach FieldNote. Check your connection.'**
  String get coreErrorOffline;

  /// No description provided for @coreErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'FieldNote could not complete that action. Try again.'**
  String get coreErrorGeneric;

  /// No description provided for @coreErrorServer.
  ///
  /// In en, this message translates to:
  /// **'FieldNote hit a problem on the server. Try again.'**
  String get coreErrorServer;

  /// No description provided for @coreErrorForbidden.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have access to that.'**
  String get coreErrorForbidden;

  /// No description provided for @coreErrorRateLimited.
  ///
  /// In en, this message translates to:
  /// **'Too many requests. Wait a moment and try again.'**
  String get coreErrorRateLimited;

  /// No description provided for @coreErrorRateLimitedWait.
  ///
  /// In en, this message translates to:
  /// **'Too many requests. Try again in {wait}.'**
  String coreErrorRateLimitedWait(String wait);

  /// No description provided for @coreWaitSeconds.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 second} other{{count} seconds}}'**
  String coreWaitSeconds(int count);

  /// No description provided for @coreWaitMinutes.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 minute} other{{count} minutes}}'**
  String coreWaitMinutes(int count);

  /// No description provided for @coreWaitHours.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 hour} other{{count} hours}}'**
  String coreWaitHours(int count);

  /// No description provided for @coreErrorDeletionBlocked.
  ///
  /// In en, this message translates to:
  /// **'Your account cannot be deleted yet. Resolve open campaigns or payments and try again.'**
  String get coreErrorDeletionBlocked;

  /// No description provided for @coreErrorDeletionOpenCampaign.
  ///
  /// In en, this message translates to:
  /// **'Cancel or complete the campaigns you created before deleting your account.'**
  String get coreErrorDeletionOpenCampaign;

  /// No description provided for @coreErrorDeletionRefundPending.
  ///
  /// In en, this message translates to:
  /// **'A refund for one of your payments is still being processed. Try again once it completes.'**
  String get coreErrorDeletionRefundPending;

  /// No description provided for @coreErrorDeletionPaymentPending.
  ///
  /// In en, this message translates to:
  /// **'One of your payments is still being confirmed. Try again once it settles.'**
  String get coreErrorDeletionPaymentPending;

  /// No description provided for @coreErrorDeletionCheckedIn.
  ///
  /// In en, this message translates to:
  /// **'Finish or leave the campaign you are checked in to before deleting your account.'**
  String get coreErrorDeletionCheckedIn;

  /// No description provided for @coreErrorCampaignStarted.
  ///
  /// In en, this message translates to:
  /// **'This campaign has already started.'**
  String get coreErrorCampaignStarted;

  /// No description provided for @coreErrorCampaignExpired.
  ///
  /// In en, this message translates to:
  /// **'This campaign has expired.'**
  String get coreErrorCampaignExpired;

  /// No description provided for @coreErrorCampaignNotCompleted.
  ///
  /// In en, this message translates to:
  /// **'This is available once the campaign completes.'**
  String get coreErrorCampaignNotCompleted;

  /// No description provided for @coreErrorCampaignFull.
  ///
  /// In en, this message translates to:
  /// **'This campaign is already full.'**
  String get coreErrorCampaignFull;

  /// No description provided for @coreErrorCampaignClosed.
  ///
  /// In en, this message translates to:
  /// **'This campaign is closed.'**
  String get coreErrorCampaignClosed;

  /// No description provided for @coreErrorCampaignUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This campaign is no longer available.'**
  String get coreErrorCampaignUnavailable;

  /// No description provided for @coreErrorCampaignNotFound.
  ///
  /// In en, this message translates to:
  /// **'This campaign could not be found.'**
  String get coreErrorCampaignNotFound;

  /// No description provided for @coreErrorCampaignNotConfirmed.
  ///
  /// In en, this message translates to:
  /// **'This campaign is not confirmed yet.'**
  String get coreErrorCampaignNotConfirmed;

  /// No description provided for @coreErrorPayoutsExist.
  ///
  /// In en, this message translates to:
  /// **'A creator payout was already recorded, so this campaign cannot be changed.'**
  String get coreErrorPayoutsExist;

  /// No description provided for @coreErrorPayoutsManual.
  ///
  /// In en, this message translates to:
  /// **'Payouts are settled manually by FieldNote operations.'**
  String get coreErrorPayoutsManual;

  /// No description provided for @coreErrorInvalidFundingGoal.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid funding goal.'**
  String get coreErrorInvalidFundingGoal;

  /// No description provided for @coreErrorInvalidDuration.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid campaign duration.'**
  String get coreErrorInvalidDuration;

  /// No description provided for @coreErrorInvalidCapacity.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid volunteer capacity.'**
  String get coreErrorInvalidCapacity;

  /// No description provided for @coreErrorInvalidAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid amount.'**
  String get coreErrorInvalidAmount;

  /// No description provided for @coreErrorInvalidCampaignDate.
  ///
  /// In en, this message translates to:
  /// **'Choose a valid campaign date.'**
  String get coreErrorInvalidCampaignDate;

  /// No description provided for @coreErrorInvalidAvailability.
  ///
  /// In en, this message translates to:
  /// **'Check your availability settings and try again.'**
  String get coreErrorInvalidAvailability;

  /// No description provided for @coreErrorInvalidContactPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid phone number.'**
  String get coreErrorInvalidContactPhone;

  /// No description provided for @coreErrorInvalidLocation.
  ///
  /// In en, this message translates to:
  /// **'That location is not valid. Choose another place.'**
  String get coreErrorInvalidLocation;

  /// No description provided for @coreErrorInvalidSummary.
  ///
  /// In en, this message translates to:
  /// **'Check the summary length and try again.'**
  String get coreErrorInvalidSummary;

  /// No description provided for @coreErrorInvalidPhotograph.
  ///
  /// In en, this message translates to:
  /// **'That photograph could not be used. Take or choose another one.'**
  String get coreErrorInvalidPhotograph;

  /// No description provided for @coreErrorInvalidTimezone.
  ///
  /// In en, this message translates to:
  /// **'Your device time zone was not recognised.'**
  String get coreErrorInvalidTimezone;

  /// No description provided for @coreErrorInvalidInput.
  ///
  /// In en, this message translates to:
  /// **'Some of the details are invalid. Check them and try again.'**
  String get coreErrorInvalidInput;

  /// No description provided for @coreErrorInputTooLong.
  ///
  /// In en, this message translates to:
  /// **'That text is too long. Shorten it and try again.'**
  String get coreErrorInputTooLong;

  /// No description provided for @coreErrorClientRequestIdReused.
  ///
  /// In en, this message translates to:
  /// **'This request was already used for something else. Start again.'**
  String get coreErrorClientRequestIdReused;

  /// No description provided for @coreErrorDuplicatePaymentRequest.
  ///
  /// In en, this message translates to:
  /// **'This payment request was already handled. Start a new checkout.'**
  String get coreErrorDuplicatePaymentRequest;

  /// No description provided for @coreErrorConsentRequired.
  ///
  /// In en, this message translates to:
  /// **'Accept the current consent to continue.'**
  String get coreErrorConsentRequired;

  /// No description provided for @coreErrorUploadFailed.
  ///
  /// In en, this message translates to:
  /// **'The photograph could not be uploaded. Try again.'**
  String get coreErrorUploadFailed;

  /// No description provided for @coreErrorPhotoRequired.
  ///
  /// In en, this message translates to:
  /// **'Add an evidence photograph first.'**
  String get coreErrorPhotoRequired;

  /// No description provided for @coreErrorOutsideGeofence.
  ///
  /// In en, this message translates to:
  /// **'Move closer to the campaign location and try again.'**
  String get coreErrorOutsideGeofence;

  /// No description provided for @coreErrorCheckInWindow.
  ///
  /// In en, this message translates to:
  /// **'GPS check-in is available from 30 minutes before the event until it ends.'**
  String get coreErrorCheckInWindow;

  /// No description provided for @coreErrorCompletionWindowClosed.
  ///
  /// In en, this message translates to:
  /// **'The evidence window for this campaign has closed.'**
  String get coreErrorCompletionWindowClosed;

  /// No description provided for @coreErrorJoinRequired.
  ///
  /// In en, this message translates to:
  /// **'Join this campaign first.'**
  String get coreErrorJoinRequired;

  /// No description provided for @coreErrorCheckInRequired.
  ///
  /// In en, this message translates to:
  /// **'Check in on site first.'**
  String get coreErrorCheckInRequired;

  /// No description provided for @coreErrorAiUnavailable.
  ///
  /// In en, this message translates to:
  /// **'AI assistance is unavailable right now.'**
  String get coreErrorAiUnavailable;

  /// No description provided for @coreLocationServiceDisabled.
  ///
  /// In en, this message translates to:
  /// **'Location is turned off. Enable Location on this device and try again.'**
  String get coreLocationServiceDisabled;

  /// No description provided for @coreLocationPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission was not granted. Allow it and try again.'**
  String get coreLocationPermissionDenied;

  /// No description provided for @coreLocationPermissionBlocked.
  ///
  /// In en, this message translates to:
  /// **'Location permission is blocked. Enable Precise Location for FieldNote in device Settings.'**
  String get coreLocationPermissionBlocked;

  /// No description provided for @coreLocationTimedOut.
  ///
  /// In en, this message translates to:
  /// **'A precise location could not be obtained in time. Move near a window and try again.'**
  String get coreLocationTimedOut;

  /// No description provided for @coreLocationUnavailable.
  ///
  /// In en, this message translates to:
  /// **'The device location is currently unavailable. Check Location settings and try again.'**
  String get coreLocationUnavailable;

  /// No description provided for @coreMapRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry map'**
  String get coreMapRetry;

  /// No description provided for @coreMapShowDetails.
  ///
  /// In en, this message translates to:
  /// **'Map not loading? Show location details'**
  String get coreMapShowDetails;

  /// No description provided for @coreMapUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Map preview is unavailable. Location details are still shown below.'**
  String get coreMapUnavailable;

  /// No description provided for @corePlacesSearchLabel.
  ///
  /// In en, this message translates to:
  /// **'Search Google Places'**
  String get corePlacesSearchLabel;

  /// No description provided for @corePickerSearchHint.
  ///
  /// In en, this message translates to:
  /// **'City, address, or landmark'**
  String get corePickerSearchHint;

  /// No description provided for @corePickerNoMatches.
  ///
  /// In en, this message translates to:
  /// **'No matching places. Try a nearby landmark.'**
  String get corePickerNoMatches;

  /// No description provided for @corePickerSearchUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Place search is unavailable. Tap the map to set a pin.'**
  String get corePickerSearchUnavailable;

  /// No description provided for @corePickerOpenFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open that place. Try another result.'**
  String get corePickerOpenFailed;

  /// No description provided for @corePickerMapSemantics.
  ///
  /// In en, this message translates to:
  /// **'Google map. Tap to select an exact location.'**
  String get corePickerMapSemantics;

  /// No description provided for @corePickerTilesUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Map tiles are unavailable. Search for a place above.'**
  String get corePickerTilesUnavailable;

  /// No description provided for @corePickerPrompt.
  ///
  /// In en, this message translates to:
  /// **'Search or tap the map to choose a location.'**
  String get corePickerPrompt;

  /// No description provided for @corePickerUseLocation.
  ///
  /// In en, this message translates to:
  /// **'Use this location'**
  String get corePickerUseLocation;

  /// No description provided for @corePlaceLocation.
  ///
  /// In en, this message translates to:
  /// **'Location: {coordinates}'**
  String corePlaceLocation(String coordinates);

  /// No description provided for @coreTravelTitle.
  ///
  /// In en, this message translates to:
  /// **'Travel to campaign'**
  String get coreTravelTitle;

  /// No description provided for @coreTravelWalk.
  ///
  /// In en, this message translates to:
  /// **'Walk'**
  String get coreTravelWalk;

  /// No description provided for @coreTravelDrive.
  ///
  /// In en, this message translates to:
  /// **'Drive'**
  String get coreTravelDrive;

  /// No description provided for @coreTravelCycle.
  ///
  /// In en, this message translates to:
  /// **'Cycle'**
  String get coreTravelCycle;

  /// No description provided for @coreTravelYourPosition.
  ///
  /// In en, this message translates to:
  /// **'Your current position'**
  String get coreTravelYourPosition;

  /// No description provided for @coreTravelFallback.
  ///
  /// In en, this message translates to:
  /// **'Destination: {place}. Live distance and route instructions remain below.'**
  String coreTravelFallback(String place);

  /// No description provided for @coreTravelRouteUnavailable.
  ///
  /// In en, this message translates to:
  /// **'A road route is unavailable. The destination pin is still shown.'**
  String get coreTravelRouteUnavailable;

  /// No description provided for @coreTravelDetailsChanged.
  ///
  /// In en, this message translates to:
  /// **'Campaign details changed. Return to My work before travelling.'**
  String get coreTravelDetailsChanged;

  /// No description provided for @coreTravelConfirmFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not confirm the event. Try again online.'**
  String get coreTravelConfirmFailed;

  /// No description provided for @coreTravelOffRoute.
  ///
  /// In en, this message translates to:
  /// **'Off planned route · recalculating when available'**
  String get coreTravelOffRoute;

  /// No description provided for @coreTravelRouteSummary.
  ///
  /// In en, this message translates to:
  /// **'{distance} km route · about {minutes} min'**
  String coreTravelRouteSummary(String distance, int minutes);

  /// No description provided for @coreTravelRemaining.
  ///
  /// In en, this message translates to:
  /// **'{distance} km remaining · about {minutes} min'**
  String coreTravelRemaining(String distance, int minutes);

  /// No description provided for @coreTravelRouteSteps.
  ///
  /// In en, this message translates to:
  /// **'Route steps'**
  String get coreTravelRouteSteps;

  /// No description provided for @coreTravelCloseSteps.
  ///
  /// In en, this message translates to:
  /// **'Close route steps'**
  String get coreTravelCloseSteps;

  /// No description provided for @coreTravelStepDistance.
  ///
  /// In en, this message translates to:
  /// **'{meters} m'**
  String coreTravelStepDistance(String meters);

  /// No description provided for @coreTravelViewSteps.
  ///
  /// In en, this message translates to:
  /// **'View route steps'**
  String get coreTravelViewSteps;

  /// No description provided for @coreTravelArrived.
  ///
  /// In en, this message translates to:
  /// **'Near the campaign pin. Return to My work for GPS check-in.'**
  String get coreTravelArrived;

  /// No description provided for @coreTravelJoinFirst.
  ///
  /// In en, this message translates to:
  /// **'Join this campaign and wait for event confirmation before travelling.'**
  String get coreTravelJoinFirst;

  /// No description provided for @coreTravelStop.
  ///
  /// In en, this message translates to:
  /// **'Stop travel'**
  String get coreTravelStop;

  /// No description provided for @coreTravelStart.
  ///
  /// In en, this message translates to:
  /// **'Start travel'**
  String get coreTravelStart;

  /// No description provided for @coreTravelRetryRoute.
  ///
  /// In en, this message translates to:
  /// **'Retry road route'**
  String get coreTravelRetryRoute;

  /// No description provided for @coreTravelRetryLocation.
  ///
  /// In en, this message translates to:
  /// **'Retry location'**
  String get coreTravelRetryLocation;

  /// No description provided for @volunteerCheckInOpensAt.
  ///
  /// In en, this message translates to:
  /// **'Check-in opens at {time}'**
  String volunteerCheckInOpensAt(String time);

  /// No description provided for @volunteerCheckInOpensOn.
  ///
  /// In en, this message translates to:
  /// **'Check-in opens {date} at {time}'**
  String volunteerCheckInOpensOn(String date, String time);

  /// No description provided for @volunteerStatusImpactSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Impact submitted'**
  String get volunteerStatusImpactSubmitted;

  /// No description provided for @volunteerStatusLeft.
  ///
  /// In en, this message translates to:
  /// **'You left this campaign'**
  String get volunteerStatusLeft;

  /// No description provided for @volunteerStatusLeftDetail.
  ///
  /// In en, this message translates to:
  /// **'Your place was freed. You can join again while it is open.'**
  String get volunteerStatusLeftDetail;

  /// No description provided for @volunteerStatusNoShow.
  ///
  /// In en, this message translates to:
  /// **'Missed · no check-in'**
  String get volunteerStatusNoShow;

  /// No description provided for @volunteerStatusNoShowDetail.
  ///
  /// In en, this message translates to:
  /// **'The campaign ended without a GPS check-in from you.'**
  String get volunteerStatusNoShowDetail;

  /// No description provided for @volunteerStatusIncomplete.
  ///
  /// In en, this message translates to:
  /// **'Incomplete · no evidence'**
  String get volunteerStatusIncomplete;

  /// No description provided for @volunteerStatusIncompleteDetail.
  ///
  /// In en, this message translates to:
  /// **'You checked in, but no evidence was sent before the deadline.'**
  String get volunteerStatusIncompleteDetail;

  /// No description provided for @volunteerStatusCampaignCompleted.
  ///
  /// In en, this message translates to:
  /// **'Campaign completed'**
  String get volunteerStatusCampaignCompleted;

  /// No description provided for @volunteerStatusEvidenceWindowClosed.
  ///
  /// In en, this message translates to:
  /// **'The evidence window has closed.'**
  String get volunteerStatusEvidenceWindowClosed;

  /// No description provided for @volunteerStatusCampaignFinished.
  ///
  /// In en, this message translates to:
  /// **'This campaign has finished.'**
  String get volunteerStatusCampaignFinished;

  /// No description provided for @volunteerStatusCheckedIn.
  ///
  /// In en, this message translates to:
  /// **'GPS checked in'**
  String get volunteerStatusCheckedIn;

  /// No description provided for @volunteerStatusJoined.
  ///
  /// In en, this message translates to:
  /// **'Joined'**
  String get volunteerStatusJoined;

  /// No description provided for @volunteerStatusExpired.
  ///
  /// In en, this message translates to:
  /// **'Campaign expired'**
  String get volunteerStatusExpired;

  /// No description provided for @volunteerStatusExpiredDetail.
  ///
  /// In en, this message translates to:
  /// **'The proposed date passed without enough support. Do not travel.'**
  String get volunteerStatusExpiredDetail;

  /// No description provided for @volunteerStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Campaign cancelled — do not travel'**
  String get volunteerStatusCancelled;

  /// No description provided for @volunteerStatusCancelledDetail.
  ///
  /// In en, this message translates to:
  /// **'The organizer cancelled this campaign.'**
  String get volunteerStatusCancelledDetail;

  /// No description provided for @volunteerReviewAwaiting.
  ///
  /// In en, this message translates to:
  /// **'Awaiting sponsor review'**
  String get volunteerReviewAwaiting;

  /// No description provided for @volunteerReviewApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved by sponsor'**
  String get volunteerReviewApproved;

  /// No description provided for @volunteerReviewChangesRequested.
  ///
  /// In en, this message translates to:
  /// **'Changes requested'**
  String get volunteerReviewChangesRequested;

  /// No description provided for @volunteerReviewRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected by sponsor'**
  String get volunteerReviewRejected;

  /// No description provided for @volunteerGpsOutOfDate.
  ///
  /// In en, this message translates to:
  /// **'The GPS reading is out of date. Try again.'**
  String get volunteerGpsOutOfDate;

  /// No description provided for @volunteerGpsAccuracyTooLow.
  ///
  /// In en, this message translates to:
  /// **'GPS accuracy is ±{accuracy} m; FieldNote needs {required} m or better. Move outdoors or near a window and try again.'**
  String volunteerGpsAccuracyTooLow(String accuracy, int required);

  /// No description provided for @volunteerTimesWithinDay.
  ///
  /// In en, this message translates to:
  /// **'Choose times within the day.'**
  String get volunteerTimesWithinDay;

  /// No description provided for @volunteerEndAfterStart.
  ///
  /// In en, this message translates to:
  /// **'The end time must be after the start time.'**
  String get volunteerEndAfterStart;

  /// No description provided for @volunteerAreaMapTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose travel area'**
  String get volunteerAreaMapTitle;

  /// No description provided for @volunteerAreaMapMinimize.
  ///
  /// In en, this message translates to:
  /// **'Minimize map'**
  String get volunteerAreaMapMinimize;

  /// No description provided for @volunteerAreaMapSemantics.
  ///
  /// In en, this message translates to:
  /// **'Full screen map. Tap or drag to choose your travel area.'**
  String get volunteerAreaMapSemantics;

  /// No description provided for @volunteerYourTravelArea.
  ///
  /// In en, this message translates to:
  /// **'Your travel area'**
  String get volunteerYourTravelArea;

  /// No description provided for @volunteerAreaMapUnavailable.
  ///
  /// In en, this message translates to:
  /// **'The map is unavailable. Return to Availability and use your current GPS area.'**
  String get volunteerAreaMapUnavailable;

  /// No description provided for @volunteerAreaMapTapPrompt.
  ///
  /// In en, this message translates to:
  /// **'Tap the map to place your travel area pin.'**
  String get volunteerAreaMapTapPrompt;

  /// No description provided for @volunteerAreaMapPinSelected.
  ///
  /// In en, this message translates to:
  /// **'Pin selected · {radius} km travel radius'**
  String volunteerAreaMapPinSelected(int radius);

  /// No description provided for @volunteerAreaMapUseArea.
  ///
  /// In en, this message translates to:
  /// **'Use this area'**
  String get volunteerAreaMapUseArea;

  /// No description provided for @volunteerLinkOpenFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open the campaign link. Try again.'**
  String get volunteerLinkOpenFailed;

  /// No description provided for @volunteerLinkStartedInMyWork.
  ///
  /// In en, this message translates to:
  /// **'This campaign has started. Your place is in My work.'**
  String get volunteerLinkStartedInMyWork;

  /// No description provided for @volunteerLinkNoLongerOpen.
  ///
  /// In en, this message translates to:
  /// **'This campaign is no longer open.'**
  String get volunteerLinkNoLongerOpen;

  /// No description provided for @volunteerJoined.
  ///
  /// In en, this message translates to:
  /// **'You joined {campaign}.'**
  String volunteerJoined(String campaign);

  /// No description provided for @volunteerJoinFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not join this campaign.'**
  String get volunteerJoinFailed;

  /// No description provided for @volunteerJoinCampaignFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not join the campaign.'**
  String get volunteerJoinCampaignFailed;

  /// No description provided for @volunteerInvitationTitle.
  ///
  /// In en, this message translates to:
  /// **'Campaign invitation'**
  String get volunteerInvitationTitle;

  /// No description provided for @volunteerShareCampaign.
  ///
  /// In en, this message translates to:
  /// **'Share campaign'**
  String get volunteerShareCampaign;

  /// No description provided for @volunteerInvitationEyebrow.
  ///
  /// In en, this message translates to:
  /// **'FIELDNOTE CAMPAIGN'**
  String get volunteerInvitationEyebrow;

  /// No description provided for @volunteerJoining.
  ///
  /// In en, this message translates to:
  /// **'Joining…'**
  String get volunteerJoining;

  /// No description provided for @volunteerViewMyWork.
  ///
  /// In en, this message translates to:
  /// **'View my work'**
  String get volunteerViewMyWork;

  /// No description provided for @volunteerJoinCampaign.
  ///
  /// In en, this message translates to:
  /// **'Join campaign'**
  String get volunteerJoinCampaign;

  /// No description provided for @volunteerJoin.
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get volunteerJoin;

  /// No description provided for @volunteerFull.
  ///
  /// In en, this message translates to:
  /// **'Full'**
  String get volunteerFull;

  /// No description provided for @volunteerSignInToJoin.
  ///
  /// In en, this message translates to:
  /// **'Sign in with a volunteer account to join this campaign.'**
  String get volunteerSignInToJoin;

  /// No description provided for @volunteerHistoryAppBar.
  ///
  /// In en, this message translates to:
  /// **'My impact'**
  String get volunteerHistoryAppBar;

  /// No description provided for @volunteerHistoryEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Your record'**
  String get volunteerHistoryEyebrow;

  /// No description provided for @volunteerHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Impact & history'**
  String get volunteerHistoryTitle;

  /// No description provided for @volunteerHistoryDescription.
  ///
  /// In en, this message translates to:
  /// **'Every campaign you joined, what happened, and how your evidence was reviewed.'**
  String get volunteerHistoryDescription;

  /// No description provided for @volunteerHistoryStatJoined.
  ///
  /// In en, this message translates to:
  /// **'Campaigns joined'**
  String get volunteerHistoryStatJoined;

  /// No description provided for @volunteerHistoryStatSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Evidence submitted'**
  String get volunteerHistoryStatSubmitted;

  /// No description provided for @volunteerHistoryStatApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved by sponsors'**
  String get volunteerHistoryStatApproved;

  /// No description provided for @volunteerHistoryEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No history yet'**
  String get volunteerHistoryEmptyTitle;

  /// No description provided for @volunteerHistoryEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Campaigns you join will appear here.'**
  String get volunteerHistoryEmptyMessage;

  /// No description provided for @volunteerSponsorNote.
  ///
  /// In en, this message translates to:
  /// **'Sponsor note: {note}'**
  String volunteerSponsorNote(String note);

  /// No description provided for @volunteerSubmittedAt.
  ///
  /// In en, this message translates to:
  /// **'Submitted {time}'**
  String volunteerSubmittedAt(String time);

  /// No description provided for @volunteerSubmittedAtAi.
  ///
  /// In en, this message translates to:
  /// **'Submitted {time} · AI-assisted summary'**
  String volunteerSubmittedAtAi(String time);

  /// No description provided for @volunteerViewEvidencePhoto.
  ///
  /// In en, this message translates to:
  /// **'View my evidence photo'**
  String get volunteerViewEvidencePhoto;

  /// No description provided for @volunteerPhotoLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load the photo.'**
  String get volunteerPhotoLoadFailed;

  /// No description provided for @volunteerMatchesEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Volunteer campaigns'**
  String get volunteerMatchesEyebrow;

  /// No description provided for @volunteerMatchesTitle.
  ///
  /// In en, this message translates to:
  /// **'Find a campaign'**
  String get volunteerMatchesTitle;

  /// No description provided for @volunteerMatchesDescription.
  ///
  /// In en, this message translates to:
  /// **'Browse nearby work and invitations.'**
  String get volunteerMatchesDescription;

  /// No description provided for @volunteerTabList.
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get volunteerTabList;

  /// No description provided for @volunteerTabMap.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get volunteerTabMap;

  /// No description provided for @volunteerTabInvites.
  ///
  /// In en, this message translates to:
  /// **'Invites'**
  String get volunteerTabInvites;

  /// No description provided for @volunteerNoMatchesTitle.
  ///
  /// In en, this message translates to:
  /// **'No matches yet'**
  String get volunteerNoMatchesTitle;

  /// No description provided for @volunteerNoMatchesWiden.
  ///
  /// In en, this message translates to:
  /// **'Try increasing your travel radius or choosing more available days.'**
  String get volunteerNoMatchesWiden;

  /// No description provided for @volunteerNoMatchesTurnOn.
  ///
  /// In en, this message translates to:
  /// **'Turn on availability to let AI recommend campaigns.'**
  String get volunteerNoMatchesTurnOn;

  /// No description provided for @volunteerEveryPlaceTaken.
  ///
  /// In en, this message translates to:
  /// **'Every place is taken'**
  String get volunteerEveryPlaceTaken;

  /// No description provided for @volunteerInvitedReason.
  ///
  /// In en, this message translates to:
  /// **'The campaign creator invited you to join'**
  String get volunteerInvitedReason;

  /// No description provided for @volunteerMapUnavailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Map unavailable'**
  String get volunteerMapUnavailableTitle;

  /// No description provided for @volunteerMapUnavailableMessage.
  ///
  /// In en, this message translates to:
  /// **'Open List to browse and join campaigns.'**
  String get volunteerMapUnavailableMessage;

  /// No description provided for @volunteerMapEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No campaigns on the map yet'**
  String get volunteerMapEmptyTitle;

  /// No description provided for @volunteerMapEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Check your availability and travel radius, then refresh.'**
  String get volunteerMapEmptyMessage;

  /// No description provided for @volunteerInvitations.
  ///
  /// In en, this message translates to:
  /// **'Invitations'**
  String get volunteerInvitations;

  /// No description provided for @volunteerInvitationsCount.
  ///
  /// In en, this message translates to:
  /// **'Invitations ({count})'**
  String volunteerInvitationsCount(int count);

  /// No description provided for @volunteerCheckInvitations.
  ///
  /// In en, this message translates to:
  /// **'Check for invitations'**
  String get volunteerCheckInvitations;

  /// No description provided for @volunteerNoInvitations.
  ///
  /// In en, this message translates to:
  /// **'No invitations yet. Pull down to check again.'**
  String get volunteerNoInvitations;

  /// No description provided for @volunteerViewRoute.
  ///
  /// In en, this message translates to:
  /// **'View route'**
  String get volunteerViewRoute;

  /// No description provided for @volunteerDistanceStraight.
  ///
  /// In en, this message translates to:
  /// **'{distance} km away (straight line)'**
  String volunteerDistanceStraight(String distance);

  /// No description provided for @volunteerDistanceByRoad.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min drive · {distance} km by road'**
  String volunteerDistanceByRoad(int minutes, String distance);

  /// No description provided for @volunteerMatchMapSemantics.
  ///
  /// In en, this message translates to:
  /// **'Map of matched campaigns inside your travel radius'**
  String get volunteerMatchMapSemantics;

  /// No description provided for @volunteerYourArea.
  ///
  /// In en, this message translates to:
  /// **'Your area'**
  String get volunteerYourArea;

  /// No description provided for @volunteerMatchPinTitle.
  ///
  /// In en, this message translates to:
  /// **'{campaign} · {score}'**
  String volunteerMatchPinTitle(String campaign, String score);

  /// No description provided for @volunteerLegendStrong.
  ///
  /// In en, this message translates to:
  /// **'Strong match'**
  String get volunteerLegendStrong;

  /// No description provided for @volunteerLegendModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate match'**
  String get volunteerLegendModerate;

  /// No description provided for @volunteerLegendWeaker.
  ///
  /// In en, this message translates to:
  /// **'Weaker match'**
  String get volunteerLegendWeaker;

  /// No description provided for @volunteerMatchMapHint.
  ///
  /// In en, this message translates to:
  /// **'Tap a pin for the full score explanation. The ring is your saved travel radius.'**
  String get volunteerMatchMapHint;

  /// No description provided for @volunteerWorkEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Your campaigns'**
  String get volunteerWorkEyebrow;

  /// No description provided for @volunteerWorkDescription.
  ///
  /// In en, this message translates to:
  /// **'See your joined campaigns, directions, and next steps.'**
  String get volunteerWorkDescription;

  /// No description provided for @volunteerOpenHistory.
  ///
  /// In en, this message translates to:
  /// **'My impact & history'**
  String get volunteerOpenHistory;

  /// No description provided for @volunteerNoJoinedCampaigns.
  ///
  /// In en, this message translates to:
  /// **'No joined campaigns yet'**
  String get volunteerNoJoinedCampaigns;

  /// No description provided for @volunteerNoUpcomingCampaigns.
  ///
  /// In en, this message translates to:
  /// **'No upcoming campaigns'**
  String get volunteerNoUpcomingCampaigns;

  /// No description provided for @volunteerFindNearby.
  ///
  /// In en, this message translates to:
  /// **'Find a campaign nearby and join when it fits.'**
  String get volunteerFindNearby;

  /// No description provided for @volunteerBrowseCampaigns.
  ///
  /// In en, this message translates to:
  /// **'Browse campaigns'**
  String get volunteerBrowseCampaigns;

  /// No description provided for @volunteerPastAndClosed.
  ///
  /// In en, this message translates to:
  /// **'Past and closed'**
  String get volunteerPastAndClosed;

  /// No description provided for @volunteerCampaignNumber.
  ///
  /// In en, this message translates to:
  /// **'Campaign #{id}'**
  String volunteerCampaignNumber(int id);

  /// No description provided for @volunteerJoinedOnRefresh.
  ///
  /// In en, this message translates to:
  /// **'Joined {date}. Pull down to refresh the campaign details.'**
  String volunteerJoinedOnRefresh(String date);

  /// No description provided for @volunteerViewMyEvidence.
  ///
  /// In en, this message translates to:
  /// **'View my evidence'**
  String get volunteerViewMyEvidence;

  /// No description provided for @volunteerCreatorNoPhone.
  ///
  /// In en, this message translates to:
  /// **'This campaign creator has no saved phone number yet.'**
  String get volunteerCreatorNoPhone;

  /// No description provided for @volunteerContactLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load contact. Try again.'**
  String get volunteerContactLoadFailed;

  /// No description provided for @volunteerDialerFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open the phone dialer.'**
  String get volunteerDialerFailed;

  /// No description provided for @volunteerCheckInConfirmed.
  ///
  /// In en, this message translates to:
  /// **'On-site GPS check-in confirmed.'**
  String get volunteerCheckInConfirmed;

  /// No description provided for @volunteerCheckInFailed.
  ///
  /// In en, this message translates to:
  /// **'Live GPS check-in was not available.'**
  String get volunteerCheckInFailed;

  /// No description provided for @volunteerLeaveTitle.
  ///
  /// In en, this message translates to:
  /// **'Leave this campaign?'**
  String get volunteerLeaveTitle;

  /// No description provided for @volunteerLeaveBody.
  ///
  /// In en, this message translates to:
  /// **'Your place in {campaign} will be freed for another volunteer. You can join again later if places are still open.'**
  String volunteerLeaveBody(String campaign);

  /// No description provided for @volunteerStay.
  ///
  /// In en, this message translates to:
  /// **'Stay'**
  String get volunteerStay;

  /// No description provided for @volunteerLeaveCampaign.
  ///
  /// In en, this message translates to:
  /// **'Leave campaign'**
  String get volunteerLeaveCampaign;

  /// No description provided for @volunteerLeft.
  ///
  /// In en, this message translates to:
  /// **'You left {campaign}.'**
  String volunteerLeft(String campaign);

  /// No description provided for @volunteerLeaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not leave the campaign.'**
  String get volunteerLeaveFailed;

  /// No description provided for @volunteerReconfirmFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not reconfirm your place.'**
  String get volunteerReconfirmFailed;

  /// No description provided for @volunteerReadinessConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Event confirmed'**
  String get volunteerReadinessConfirmed;

  /// No description provided for @volunteerReadinessPostponed.
  ///
  /// In en, this message translates to:
  /// **'Postponed · new proposed date'**
  String get volunteerReadinessPostponed;

  /// No description provided for @volunteerReadinessAwaitingSponsor.
  ///
  /// In en, this message translates to:
  /// **'Awaiting sponsor decision'**
  String get volunteerReadinessAwaitingSponsor;

  /// No description provided for @volunteerReadinessTentative.
  ///
  /// In en, this message translates to:
  /// **'Date tentative'**
  String get volunteerReadinessTentative;

  /// No description provided for @volunteerTimeRange.
  ///
  /// In en, this message translates to:
  /// **'{start}–{end}'**
  String volunteerTimeRange(String start, String end);

  /// No description provided for @volunteerOrganizerUpdate.
  ///
  /// In en, this message translates to:
  /// **'Organizer update: {update}'**
  String volunteerOrganizerUpdate(String update);

  /// No description provided for @volunteerReconfirmNeeded.
  ///
  /// In en, this message translates to:
  /// **'The sponsor changed the date or work scope. Review the details, then reconfirm your place.'**
  String get volunteerReconfirmNeeded;

  /// No description provided for @volunteerReconfirm.
  ///
  /// In en, this message translates to:
  /// **'Reconfirm my place'**
  String get volunteerReconfirm;

  /// No description provided for @volunteerContactLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading campaign contact…'**
  String get volunteerContactLoading;

  /// No description provided for @volunteerContactRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh creator contact'**
  String get volunteerContactRefresh;

  /// No description provided for @volunteerContactCall.
  ///
  /// In en, this message translates to:
  /// **'Call campaign creator'**
  String get volunteerContactCall;

  /// No description provided for @volunteerContactRetry.
  ///
  /// In en, this message translates to:
  /// **'Could not load the contact. Tap to retry.'**
  String get volunteerContactRetry;

  /// No description provided for @volunteerContactMissing.
  ///
  /// In en, this message translates to:
  /// **'The creator of this campaign has not added a phone number yet. They can add it in their Profile.'**
  String get volunteerContactMissing;

  /// No description provided for @volunteerFieldChecklist.
  ///
  /// In en, this message translates to:
  /// **'Field checklist'**
  String get volunteerFieldChecklist;

  /// No description provided for @volunteerSubmitEvidence.
  ///
  /// In en, this message translates to:
  /// **'Submit photo + field note'**
  String get volunteerSubmitEvidence;

  /// No description provided for @volunteerAwaitConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Await event confirmation'**
  String get volunteerAwaitConfirmation;

  /// No description provided for @volunteerReconfirmFirst.
  ///
  /// In en, this message translates to:
  /// **'Reconfirm your place first'**
  String get volunteerReconfirmFirst;

  /// No description provided for @volunteerCheckInClosed.
  ///
  /// In en, this message translates to:
  /// **'Check-in has closed'**
  String get volunteerCheckInClosed;

  /// No description provided for @volunteerCheckInOnSite.
  ///
  /// In en, this message translates to:
  /// **'GPS check in on site'**
  String get volunteerCheckInOnSite;

  /// No description provided for @volunteerCheckInWindowHint.
  ///
  /// In en, this message translates to:
  /// **'Check-in is open from 30 minutes before the start until the end of the event.'**
  String get volunteerCheckInWindowHint;

  /// No description provided for @volunteerLeaving.
  ///
  /// In en, this message translates to:
  /// **'Leaving…'**
  String get volunteerLeaving;

  /// No description provided for @volunteerLiveLocationCheck.
  ///
  /// In en, this message translates to:
  /// **'Live location check'**
  String get volunteerLiveLocationCheck;

  /// No description provided for @volunteerGpsStreaming.
  ///
  /// In en, this message translates to:
  /// **'GPS streaming'**
  String get volunteerGpsStreaming;

  /// No description provided for @volunteerGpsNotStarted.
  ///
  /// In en, this message translates to:
  /// **'Not started'**
  String get volunteerGpsNotStarted;

  /// No description provided for @volunteerGpsPaused.
  ///
  /// In en, this message translates to:
  /// **'GPS paused'**
  String get volunteerGpsPaused;

  /// No description provided for @volunteerTrackingIntro.
  ///
  /// In en, this message translates to:
  /// **'Start tracking to request Precise Location and show live coordinates, accuracy, mock-location status, and geofence distance.'**
  String get volunteerTrackingIntro;

  /// No description provided for @volunteerLiveLocationUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Live location is unavailable.'**
  String get volunteerLiveLocationUnavailable;

  /// No description provided for @volunteerAccuracyFact.
  ///
  /// In en, this message translates to:
  /// **'±{meters} m'**
  String volunteerAccuracyFact(String meters);

  /// No description provided for @volunteerMockDetected.
  ///
  /// In en, this message translates to:
  /// **'Mock flag detected'**
  String get volunteerMockDetected;

  /// No description provided for @volunteerNoMock.
  ///
  /// In en, this message translates to:
  /// **'No mock flag'**
  String get volunteerNoMock;

  /// No description provided for @volunteerCalculatingDistance.
  ///
  /// In en, this message translates to:
  /// **'Calculating distance'**
  String get volunteerCalculatingDistance;

  /// No description provided for @volunteerDistanceAccuracyLow.
  ///
  /// In en, this message translates to:
  /// **'{meters} m · accuracy too low'**
  String volunteerDistanceAccuracyLow(String meters);

  /// No description provided for @volunteerDistanceInside.
  ///
  /// In en, this message translates to:
  /// **'{meters} m · inside geofence'**
  String volunteerDistanceInside(String meters);

  /// No description provided for @volunteerDistanceOutside.
  ///
  /// In en, this message translates to:
  /// **'{meters} m · outside geofence'**
  String volunteerDistanceOutside(String meters);

  /// No description provided for @volunteerFixAge.
  ///
  /// In en, this message translates to:
  /// **'{seconds} s old'**
  String volunteerFixAge(int seconds);

  /// No description provided for @volunteerStopTracking.
  ///
  /// In en, this message translates to:
  /// **'Stop live tracking'**
  String get volunteerStopTracking;

  /// No description provided for @volunteerEnableTracking.
  ///
  /// In en, this message translates to:
  /// **'Enable live location'**
  String get volunteerEnableTracking;

  /// No description provided for @volunteerRouteUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Route unavailable'**
  String get volunteerRouteUnavailable;

  /// No description provided for @volunteerTrackingPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Tracking stays on this screen. Only the check-in snapshot is sent to the server.'**
  String get volunteerTrackingPrivacy;

  /// No description provided for @volunteerApproachMapSemantics.
  ///
  /// In en, this message translates to:
  /// **'Map showing the campaign geofence and your live position'**
  String get volunteerApproachMapSemantics;

  /// No description provided for @volunteerYouAreHere.
  ///
  /// In en, this message translates to:
  /// **'You are here'**
  String get volunteerYouAreHere;

  /// No description provided for @volunteerMetersFromPin.
  ///
  /// In en, this message translates to:
  /// **'{meters} m from the pin'**
  String volunteerMetersFromPin(String meters);

  /// No description provided for @volunteerApproachFallbackNoFix.
  ///
  /// In en, this message translates to:
  /// **'Map preview is off. Enable live location for a distance readout, or add a Maps key to draw the geofence.'**
  String get volunteerApproachFallbackNoFix;

  /// No description provided for @volunteerApproachFallback.
  ///
  /// In en, this message translates to:
  /// **'Map preview is off. You are {meters} m from the campaign pin (geofence {geofence} m).'**
  String volunteerApproachFallback(String meters, String geofence);

  /// No description provided for @volunteerLegendCampaignPin.
  ///
  /// In en, this message translates to:
  /// **'Campaign pin'**
  String get volunteerLegendCampaignPin;

  /// No description provided for @volunteerLegendGeofence.
  ///
  /// In en, this message translates to:
  /// **'Geofence {meters} m'**
  String volunteerLegendGeofence(String meters);

  /// No description provided for @volunteerLegendAccuracy.
  ///
  /// In en, this message translates to:
  /// **'Your GPS accuracy'**
  String get volunteerLegendAccuracy;

  /// No description provided for @volunteerCameraUnavailable.
  ///
  /// In en, this message translates to:
  /// **'The camera is unavailable. Allow camera access or choose from the gallery.'**
  String get volunteerCameraUnavailable;

  /// No description provided for @volunteerGalleryFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open the photo library.'**
  String get volunteerGalleryFailed;

  /// No description provided for @volunteerOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get volunteerOpenSettings;

  /// No description provided for @volunteerMicPermission.
  ///
  /// In en, this message translates to:
  /// **'Microphone access is off. Allow microphone and speech recognition for FieldNote in Settings, or type your note.'**
  String get volunteerMicPermission;

  /// No description provided for @volunteerNoSpeech.
  ///
  /// In en, this message translates to:
  /// **'No speech was heard. Try again or type your note.'**
  String get volunteerNoSpeech;

  /// No description provided for @volunteerDictationStopped.
  ///
  /// In en, this message translates to:
  /// **'Dictation stopped. Try again or type your note.'**
  String get volunteerDictationStopped;

  /// No description provided for @volunteerSpeechUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Speech recognition is unavailable on this device. Type your note instead.'**
  String get volunteerSpeechUnavailable;

  /// No description provided for @volunteerDictationFailed.
  ///
  /// In en, this message translates to:
  /// **'Dictation could not start. Type your note instead.'**
  String get volunteerDictationFailed;

  /// No description provided for @volunteerPhotoFirst.
  ///
  /// In en, this message translates to:
  /// **'Take or choose an evidence photograph first.'**
  String get volunteerPhotoFirst;

  /// No description provided for @volunteerNoteTooShort.
  ///
  /// In en, this message translates to:
  /// **'Add or dictate a field note of at least {min} characters.'**
  String volunteerNoteTooShort(int min);

  /// No description provided for @volunteerAnalyzeFailed.
  ///
  /// In en, this message translates to:
  /// **'AI could not analyze this note. Write the summary yourself below.'**
  String get volunteerAnalyzeFailed;

  /// No description provided for @volunteerSummaryLength.
  ///
  /// In en, this message translates to:
  /// **'Write a summary of the completed work ({min}–{max} characters).'**
  String volunteerSummaryLength(int min, int max);

  /// No description provided for @volunteerNoteTooLong.
  ///
  /// In en, this message translates to:
  /// **'Keep the field note under {max} characters.'**
  String volunteerNoteTooLong(int max);

  /// No description provided for @volunteerEvidenceSent.
  ///
  /// In en, this message translates to:
  /// **'Impact evidence sent to the sponsor.'**
  String get volunteerEvidenceSent;

  /// No description provided for @volunteerSubmitFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not submit evidence.'**
  String get volunteerSubmitFailed;

  /// No description provided for @volunteerEvidenceEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Evidence'**
  String get volunteerEvidenceEyebrow;

  /// No description provided for @volunteerEvidenceEyebrowAi.
  ///
  /// In en, this message translates to:
  /// **'AI evidence assistant'**
  String get volunteerEvidenceEyebrowAi;

  /// No description provided for @volunteerEvidenceTitle.
  ///
  /// In en, this message translates to:
  /// **'Show what changed'**
  String get volunteerEvidenceTitle;

  /// No description provided for @volunteerEvidenceDescription.
  ///
  /// In en, this message translates to:
  /// **'Capture one photo, describe the result, then confirm your summary.'**
  String get volunteerEvidenceDescription;

  /// No description provided for @volunteerEvidenceDescriptionAi.
  ///
  /// In en, this message translates to:
  /// **'Capture one photo, describe the result, then confirm the structured summary.'**
  String get volunteerEvidenceDescriptionAi;

  /// No description provided for @volunteerEvidenceWindowClosed.
  ///
  /// In en, this message translates to:
  /// **'The evidence window for this campaign has closed.'**
  String get volunteerEvidenceWindowClosed;

  /// No description provided for @volunteerTakePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take evidence photograph'**
  String get volunteerTakePhoto;

  /// No description provided for @volunteerChooseGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get volunteerChooseGallery;

  /// No description provided for @volunteerNoteLabel.
  ///
  /// In en, this message translates to:
  /// **'What did your team complete?'**
  String get volunteerNoteLabel;

  /// No description provided for @volunteerNoteHint.
  ///
  /// In en, this message translates to:
  /// **'We planted 12 saplings and cleared 8 bags of waste…'**
  String get volunteerNoteHint;

  /// No description provided for @volunteerStopListening.
  ///
  /// In en, this message translates to:
  /// **'Stop listening'**
  String get volunteerStopListening;

  /// No description provided for @volunteerDictateNote.
  ///
  /// In en, this message translates to:
  /// **'Dictate note'**
  String get volunteerDictateNote;

  /// No description provided for @volunteerAnalyzing.
  ///
  /// In en, this message translates to:
  /// **'Analyzing…'**
  String get volunteerAnalyzing;

  /// No description provided for @volunteerAnalyze.
  ///
  /// In en, this message translates to:
  /// **'AI analyze field note'**
  String get volunteerAnalyze;

  /// No description provided for @volunteerWriteMyself.
  ///
  /// In en, this message translates to:
  /// **'Write the summary myself'**
  String get volunteerWriteMyself;

  /// No description provided for @volunteerSummaryManualPill.
  ///
  /// In en, this message translates to:
  /// **'Your summary · not AI generated'**
  String get volunteerSummaryManualPill;

  /// No description provided for @volunteerSummaryAiPill.
  ///
  /// In en, this message translates to:
  /// **'AI draft · volunteer confirms'**
  String get volunteerSummaryAiPill;

  /// No description provided for @volunteerAiUnavailableDescribe.
  ///
  /// In en, this message translates to:
  /// **'AI analysis is unavailable. Describe the completed work in your own words.'**
  String get volunteerAiUnavailableDescribe;

  /// No description provided for @volunteerDescribeOwnWords.
  ///
  /// In en, this message translates to:
  /// **'Describe the completed work in your own words.'**
  String get volunteerDescribeOwnWords;

  /// No description provided for @volunteerConfirmedSummary.
  ///
  /// In en, this message translates to:
  /// **'Confirmed impact summary'**
  String get volunteerConfirmedSummary;

  /// No description provided for @volunteerSummaryHelper.
  ///
  /// In en, this message translates to:
  /// **'At least {min} characters. The sponsor sees this.'**
  String volunteerSummaryHelper(int min);

  /// No description provided for @volunteerCheckingGps.
  ///
  /// In en, this message translates to:
  /// **'Checking your GPS position…'**
  String get volunteerCheckingGps;

  /// No description provided for @volunteerUploading.
  ///
  /// In en, this message translates to:
  /// **'Uploading photo and submitting evidence…'**
  String get volunteerUploading;

  /// No description provided for @volunteerSubmitting.
  ///
  /// In en, this message translates to:
  /// **'Submitting…'**
  String get volunteerSubmitting;

  /// No description provided for @volunteerConfirmSubmit.
  ///
  /// In en, this message translates to:
  /// **'Confirm and submit evidence'**
  String get volunteerConfirmSubmit;

  /// No description provided for @volunteerNoPlacesFound.
  ///
  /// In en, this message translates to:
  /// **'No matching places found.'**
  String get volunteerNoPlacesFound;

  /// No description provided for @volunteerPlaceSearchUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Place search is unavailable. Move the pin or use GPS.'**
  String get volunteerPlaceSearchUnavailable;

  /// No description provided for @volunteerPlaceSelectFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not select that place. Try another result.'**
  String get volunteerPlaceSelectFailed;

  /// No description provided for @volunteerAvailableFrom.
  ///
  /// In en, this message translates to:
  /// **'Available from'**
  String get volunteerAvailableFrom;

  /// No description provided for @volunteerAvailableUntil.
  ///
  /// In en, this message translates to:
  /// **'Available until'**
  String get volunteerAvailableUntil;

  /// No description provided for @volunteerSelectSearchResult.
  ///
  /// In en, this message translates to:
  /// **'Select a search result, or clear the search to keep the current pin.'**
  String get volunteerSelectSearchResult;

  /// No description provided for @volunteerAvailabilitySaved.
  ///
  /// In en, this message translates to:
  /// **'Availability saved.'**
  String get volunteerAvailabilitySaved;

  /// No description provided for @volunteerAvailabilityFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not update availability.'**
  String get volunteerAvailabilityFailed;

  /// No description provided for @volunteerAvailabilityEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Volunteer preferences'**
  String get volunteerAvailabilityEyebrow;

  /// No description provided for @volunteerAvailabilityDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose when and how far you can travel.'**
  String get volunteerAvailabilityDescription;

  /// No description provided for @volunteerAvailableToggle.
  ///
  /// In en, this message translates to:
  /// **'I am available for campaigns'**
  String get volunteerAvailableToggle;

  /// No description provided for @volunteerAvailableToggleHint.
  ///
  /// In en, this message translates to:
  /// **'Pause this without deleting your preferences.'**
  String get volunteerAvailableToggleHint;

  /// No description provided for @volunteerTodayToggle.
  ///
  /// In en, this message translates to:
  /// **'I can help today'**
  String get volunteerTodayToggle;

  /// No description provided for @volunteerTodayToggleHint.
  ///
  /// In en, this message translates to:
  /// **'Turns off automatically at midnight.'**
  String get volunteerTodayToggleHint;

  /// No description provided for @volunteerRegularDays.
  ///
  /// In en, this message translates to:
  /// **'Regular days'**
  String get volunteerRegularDays;

  /// No description provided for @volunteerTimeWindow.
  ///
  /// In en, this message translates to:
  /// **'Time window'**
  String get volunteerTimeWindow;

  /// No description provided for @volunteerFromTime.
  ///
  /// In en, this message translates to:
  /// **'From {time}'**
  String volunteerFromTime(String time);

  /// No description provided for @volunteerUntilTime.
  ///
  /// In en, this message translates to:
  /// **'Until {time}'**
  String volunteerUntilTime(String time);

  /// No description provided for @volunteerTravelFrom.
  ///
  /// In en, this message translates to:
  /// **'Where you can travel from'**
  String get volunteerTravelFrom;

  /// No description provided for @volunteerTravelFromHint.
  ///
  /// In en, this message translates to:
  /// **'Drag the pin to the area you actually set out from. The ring is the radius below, drawn to scale.'**
  String get volunteerTravelFromHint;

  /// No description provided for @volunteerPlaceSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Address, landmark, or city'**
  String get volunteerPlaceSearchHint;

  /// No description provided for @volunteerMaximumTravel.
  ///
  /// In en, this message translates to:
  /// **'Maximum travel · {km} km'**
  String volunteerMaximumTravel(String km);

  /// No description provided for @volunteerKm.
  ///
  /// In en, this message translates to:
  /// **'{km} km'**
  String volunteerKm(String km);

  /// No description provided for @volunteerCurrentLocationFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not get your current location.'**
  String get volunteerCurrentLocationFailed;

  /// No description provided for @volunteerUseGpsArea.
  ///
  /// In en, this message translates to:
  /// **'Use my current GPS area'**
  String get volunteerUseGpsArea;

  /// No description provided for @volunteerLiveGpsSelected.
  ///
  /// In en, this message translates to:
  /// **'Live GPS area selected'**
  String get volunteerLiveGpsSelected;

  /// No description provided for @volunteerUseGpsAreaInstead.
  ///
  /// In en, this message translates to:
  /// **'Use my current GPS area instead'**
  String get volunteerUseGpsAreaInstead;

  /// No description provided for @volunteerSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get volunteerSave;

  /// No description provided for @volunteerAreaMapPinSemantics.
  ///
  /// In en, this message translates to:
  /// **'Draggable map pin for your travel area'**
  String get volunteerAreaMapPinSemantics;

  /// No description provided for @volunteerAreaFallbackNoArea.
  ///
  /// In en, this message translates to:
  /// **'Map preview is off. Use the GPS button below to set your area.'**
  String get volunteerAreaFallbackNoArea;

  /// No description provided for @volunteerAreaFallback.
  ///
  /// In en, this message translates to:
  /// **'Map preview is off. Saved area: {coordinates} ({km} km radius).'**
  String volunteerAreaFallback(String coordinates, String km);

  /// No description provided for @volunteerExpandMap.
  ///
  /// In en, this message translates to:
  /// **'Expand map'**
  String get volunteerExpandMap;

  /// No description provided for @volunteerOpenLocationSettings.
  ///
  /// In en, this message translates to:
  /// **'Open location settings'**
  String get volunteerOpenLocationSettings;

  /// No description provided for @volunteerOpenAppSettings.
  ///
  /// In en, this message translates to:
  /// **'Open app settings'**
  String get volunteerOpenAppSettings;

  /// No description provided for @exportSectionProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get exportSectionProfile;

  /// No description provided for @exportSectionPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy choices'**
  String get exportSectionPrivacy;

  /// No description provided for @exportSectionAvailability.
  ///
  /// In en, this message translates to:
  /// **'Volunteer availability'**
  String get exportSectionAvailability;

  /// No description provided for @exportSectionCreatedCampaigns.
  ///
  /// In en, this message translates to:
  /// **'Campaigns you created'**
  String get exportSectionCreatedCampaigns;

  /// No description provided for @exportSectionSponsorships.
  ///
  /// In en, this message translates to:
  /// **'Sponsorships'**
  String get exportSectionSponsorships;

  /// No description provided for @exportSectionVolunteerWork.
  ///
  /// In en, this message translates to:
  /// **'Volunteer work'**
  String get exportSectionVolunteerWork;

  /// No description provided for @exportSectionEvidence.
  ///
  /// In en, this message translates to:
  /// **'Evidence you submitted'**
  String get exportSectionEvidence;

  /// No description provided for @exportSectionPosts.
  ///
  /// In en, this message translates to:
  /// **'Campaign updates you posted'**
  String get exportSectionPosts;

  /// No description provided for @exportSectionPayouts.
  ///
  /// In en, this message translates to:
  /// **'Test payout simulations'**
  String get exportSectionPayouts;

  /// No description provided for @exportSectionRefunds.
  ///
  /// In en, this message translates to:
  /// **'Test refunds'**
  String get exportSectionRefunds;

  /// No description provided for @exportSectionSecurity.
  ///
  /// In en, this message translates to:
  /// **'Security activity'**
  String get exportSectionSecurity;

  /// No description provided for @exportFieldRole.
  ///
  /// In en, this message translates to:
  /// **'Role: {value}'**
  String exportFieldRole(String value);

  /// No description provided for @exportFieldCity.
  ///
  /// In en, this message translates to:
  /// **'City: {value}'**
  String exportFieldCity(String value);

  /// No description provided for @exportFieldContactPhone.
  ///
  /// In en, this message translates to:
  /// **'Contact phone: {value}'**
  String exportFieldContactPhone(String value);

  /// No description provided for @exportFieldOrganization.
  ///
  /// In en, this message translates to:
  /// **'Organization: {value}'**
  String exportFieldOrganization(String value);

  /// No description provided for @exportFieldInterests.
  ///
  /// In en, this message translates to:
  /// **'Interests: {value}'**
  String exportFieldInterests(String value);

  /// No description provided for @exportFieldSkills.
  ///
  /// In en, this message translates to:
  /// **'Skills: {value}'**
  String exportFieldSkills(String value);

  /// No description provided for @exportConsentAccepted.
  ///
  /// In en, this message translates to:
  /// **'Consent accepted {date}'**
  String exportConsentAccepted(String date);

  /// No description provided for @exportFieldLocation.
  ///
  /// In en, this message translates to:
  /// **'Location: {value}'**
  String exportFieldLocation(String value);

  /// No description provided for @exportFieldAiProcessing.
  ///
  /// In en, this message translates to:
  /// **'AI processing: {value}'**
  String exportFieldAiProcessing(String value);

  /// No description provided for @exportFieldEvidenceSharing.
  ///
  /// In en, this message translates to:
  /// **'Evidence sharing: {value}'**
  String exportFieldEvidenceSharing(String value);

  /// No description provided for @exportFieldPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy: {value}'**
  String exportFieldPrivacyPolicy(String value);

  /// No description provided for @exportFieldTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms: {value}'**
  String exportFieldTerms(String value);

  /// No description provided for @exportFieldAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available: {value}'**
  String exportFieldAvailable(String value);

  /// No description provided for @exportFieldAvailableToday.
  ///
  /// In en, this message translates to:
  /// **'Available today: {value}'**
  String exportFieldAvailableToday(String value);

  /// No description provided for @exportFieldTravelRadius.
  ///
  /// In en, this message translates to:
  /// **'Travel radius: {value} km'**
  String exportFieldTravelRadius(String value);

  /// No description provided for @exportFieldDays.
  ///
  /// In en, this message translates to:
  /// **'Days: {value}'**
  String exportFieldDays(String value);

  /// No description provided for @exportFieldUpdated.
  ///
  /// In en, this message translates to:
  /// **'Updated: {value}'**
  String exportFieldUpdated(String value);

  /// No description provided for @exportFieldStarts.
  ///
  /// In en, this message translates to:
  /// **'Starts: {value}'**
  String exportFieldStarts(String value);

  /// No description provided for @exportFieldStatus.
  ///
  /// In en, this message translates to:
  /// **'Status: {value}'**
  String exportFieldStatus(String value);

  /// No description provided for @exportFieldFundingGoal.
  ///
  /// In en, this message translates to:
  /// **'Funding goal: INR {value}'**
  String exportFieldFundingGoal(String value);

  /// No description provided for @exportFieldDescription.
  ///
  /// In en, this message translates to:
  /// **'Description: {value}'**
  String exportFieldDescription(String value);

  /// No description provided for @exportFieldAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount: INR {value}'**
  String exportFieldAmount(String value);

  /// No description provided for @exportFieldPaymentStatus.
  ///
  /// In en, this message translates to:
  /// **'Payment status: {value}'**
  String exportFieldPaymentStatus(String value);

  /// No description provided for @exportFieldDate.
  ///
  /// In en, this message translates to:
  /// **'Date: {value}'**
  String exportFieldDate(String value);

  /// No description provided for @exportFieldMessage.
  ///
  /// In en, this message translates to:
  /// **'Message: {value}'**
  String exportFieldMessage(String value);

  /// No description provided for @exportFieldJoined.
  ///
  /// In en, this message translates to:
  /// **'Joined: {value}'**
  String exportFieldJoined(String value);

  /// No description provided for @exportFieldCheckedIn.
  ///
  /// In en, this message translates to:
  /// **'Checked in: {value}'**
  String exportFieldCheckedIn(String value);

  /// No description provided for @exportFieldCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed: {value}'**
  String exportFieldCompleted(String value);

  /// No description provided for @exportFieldSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Submitted: {value}'**
  String exportFieldSubmitted(String value);

  /// No description provided for @exportFieldYourNote.
  ///
  /// In en, this message translates to:
  /// **'Your note: {value}'**
  String exportFieldYourNote(String value);

  /// No description provided for @exportFieldConfirmedSummary.
  ///
  /// In en, this message translates to:
  /// **'Confirmed summary: {value}'**
  String exportFieldConfirmedSummary(String value);

  /// No description provided for @exportFieldLocationCheck.
  ///
  /// In en, this message translates to:
  /// **'Location check: {value}'**
  String exportFieldLocationCheck(String value);

  /// No description provided for @exportFieldPosted.
  ///
  /// In en, this message translates to:
  /// **'Posted: {value}'**
  String exportFieldPosted(String value);

  /// No description provided for @exportFieldSimulated.
  ///
  /// In en, this message translates to:
  /// **'Simulated: {value}'**
  String exportFieldSimulated(String value);

  /// No description provided for @exportFieldRecorded.
  ///
  /// In en, this message translates to:
  /// **'Recorded: {value}'**
  String exportFieldRecorded(String value);

  /// No description provided for @exportFieldWhen.
  ///
  /// In en, this message translates to:
  /// **'When: {value}'**
  String exportFieldWhen(String value);

  /// No description provided for @exportFieldResult.
  ///
  /// In en, this message translates to:
  /// **'Result: {value}'**
  String exportFieldResult(String value);

  /// No description provided for @exportInrAmount.
  ///
  /// In en, this message translates to:
  /// **'INR {value}'**
  String exportInrAmount(String value);

  /// No description provided for @exportNoBankTransfer.
  ///
  /// In en, this message translates to:
  /// **'No bank transfer was made.'**
  String get exportNoBankTransfer;

  /// No description provided for @exportEventPaymentStarted.
  ///
  /// In en, this message translates to:
  /// **'Payment started'**
  String get exportEventPaymentStarted;

  /// No description provided for @exportEventPaymentVerified.
  ///
  /// In en, this message translates to:
  /// **'Payment verified'**
  String get exportEventPaymentVerified;

  /// No description provided for @exportEventLocationCheck.
  ///
  /// In en, this message translates to:
  /// **'Location check'**
  String get exportEventLocationCheck;

  /// No description provided for @exportEventEvidenceSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Evidence submitted'**
  String get exportEventEvidenceSubmitted;

  /// No description provided for @exportEventConsentAccepted.
  ///
  /// In en, this message translates to:
  /// **'Privacy choices accepted'**
  String get exportEventConsentAccepted;

  /// No description provided for @exportEventDeletionRequested.
  ///
  /// In en, this message translates to:
  /// **'Account deletion requested'**
  String get exportEventDeletionRequested;

  /// No description provided for @exportPdfFooter.
  ///
  /// In en, this message translates to:
  /// **'FieldNote account report  •  Page {page} of {pages}'**
  String exportPdfFooter(int page, int pages);

  /// No description provided for @exportPdfTitle.
  ///
  /// In en, this message translates to:
  /// **'My FieldNote data'**
  String get exportPdfTitle;

  /// No description provided for @exportPdfPrepared.
  ///
  /// In en, this message translates to:
  /// **'Prepared {time}'**
  String exportPdfPrepared(String time);

  /// No description provided for @exportPdfPhotosNotice.
  ///
  /// In en, this message translates to:
  /// **'Private photographs are not embedded in this report.'**
  String get exportPdfPhotosNotice;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hi', 'ta'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
    case 'ta':
      return AppLocalizationsTa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
