// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Tamil (`ta`).
class AppLocalizationsTa extends AppLocalizations {
  AppLocalizationsTa([String locale = 'ta']) : super(locale);

  @override
  String get shellOfflineTitle => 'நீங்கள் ஆஃப்லைனில் உள்ளீர்கள்';

  @override
  String get shellErrorTitle => 'ஏதோ தவறு நடந்தது';

  @override
  String get navDiscover => 'கண்டறி';

  @override
  String get navCreate => 'உருவாக்கு';

  @override
  String get navImpact => 'தாக்கம்';

  @override
  String get navTrust => 'நம்பிக்கை';

  @override
  String get navProfile => 'சுயவிவரம்';

  @override
  String get navMatches => 'பொருத்தங்கள்';

  @override
  String get navMyWork => 'என் பணி';

  @override
  String get navAvailability => 'கிடைக்கும் நேரம்';

  @override
  String get voiceRecordingLabel => 'Recording. Release to finish.';

  @override
  String get voiceProcessingLabel => 'Campaign generation in progress';

  @override
  String get voiceHoldLabel => 'Hold to record a campaign brief';

  @override
  String get shellSponsorWorkspace => 'SPONSOR WORKSPACE';

  @override
  String get shellVolunteerWorkspace => 'VOLUNTEER WORKSPACE';

  @override
  String get shellLoading => 'Preparing your impact workspace…';

  @override
  String get shellCantReach => 'Can\'t reach FieldNote';

  @override
  String get shellCouldNotLoad => 'FieldNote could not load';

  @override
  String get commonTryAgain => 'மீண்டும் முயலவும்';

  @override
  String get commonDismiss => 'நிராகரி';

  @override
  String get signInHeroTitle =>
      'Fund an idea.\nMatch the people.\nProve the impact.';

  @override
  String get signInHeroBody =>
      'AI turns sponsor intent into action. Availability and GPS find the right volunteer. Field evidence closes the loop.';

  @override
  String get signInRoleTitle => 'How will you create impact?';

  @override
  String get signInRoleSubtitle =>
      'Choose once while creating your FieldNote account.';

  @override
  String get signInSponsorCardTitle => 'Create Sponsor Account';

  @override
  String get signInSponsorCardSubtitle =>
      'Turn an idea into a campaign, fund it, and watch verified work arrive.';

  @override
  String get signInVolunteerCardTitle => 'Create Volunteer Account';

  @override
  String get signInVolunteerCardSubtitle =>
      'Mark your availability and discover nearby campaigns matched to you.';

  @override
  String get signInExistingAccount => 'எனக்கு ஏற்கனவே கணக்கு உள்ளது';

  @override
  String get signInCreateAgreement =>
      'By creating an account you agree to the FieldNote Terms and Privacy Policy.';

  @override
  String get signInWelcomeBack => 'மீண்டும் வருக';

  @override
  String get signInCreateSponsorAccount => 'Create your sponsor account';

  @override
  String get signInCreateVolunteerAccount => 'Create your volunteer account';

  @override
  String get signInExistingSubtitle =>
      'Sign in with your existing email account.';

  @override
  String get signInNewSubtitle =>
      'Use email authentication, then finish your role-specific profile.';

  @override
  String signInAuthFailed(String error) {
    return 'Authentication failed: $error';
  }

  @override
  String get signInContinueAgreement =>
      'By continuing you agree to the FieldNote Terms and Privacy Policy.';

  @override
  String get consentLocationTitle =>
      'Use GPS for matching and check-in integrity';

  @override
  String get consentLocationDescription =>
      'Stores approximate check-in and evidence coordinates and integrity signals.';

  @override
  String get consentAiTitle => 'Use AI assistance';

  @override
  String get consentAiDescription =>
      'Campaign text and evidence inputs can be sent to an AI provider for structured drafts.';

  @override
  String get consentEvidenceTitle =>
      'Share evidence privately with campaign sponsors';

  @override
  String get consentEvidenceDescription =>
      'Evidence is private and exposed only through temporary authenticated links.';

  @override
  String consentRequiredSuffix(String title) {
    return '$title (required)';
  }

  @override
  String get legalOpenInBrowser =>
      'Open this address in your browser to read it:';

  @override
  String get commonClose => 'மூடு';

  @override
  String get legalCopyLink => 'இணைப்பை நகலெடு';

  @override
  String get legalLoading => 'Privacy Policy and Terms are loading…';

  @override
  String get commonRetry => 'மீண்டும் முயலவும்';

  @override
  String get legalPrivacyPolicy => 'தனியுரிமைக் கொள்கை';

  @override
  String legalPrivacyPolicyVersion(String version) {
    return 'Privacy Policy v$version';
  }

  @override
  String get legalTermsOfService => 'சேவை விதிமுறைகள்';

  @override
  String get legalTerms => 'விதிமுறைகள்';

  @override
  String legalTermsVersion(String version) {
    return 'Terms v$version';
  }

  @override
  String get onboardingChooseSponsorLocation => 'Choose sponsor location';

  @override
  String get onboardingChooseTravelArea => 'Choose travel area';

  @override
  String get onboardingNeedRoleAndName => 'Choose a role and enter your name.';

  @override
  String get onboardingNeedArea =>
      'Use current GPS or choose your travel area on the map.';

  @override
  String get onboardingWaitForArea =>
      'Wait for the selected area to finish loading.';

  @override
  String get onboardingNeedLocation => 'Choose your location.';

  @override
  String get onboardingNeedPhone =>
      'Enter a phone number with country code, for example +919876543210.';

  @override
  String get onboardingSelectSuggestion =>
      'Select your location from the Google suggestions.';

  @override
  String get onboardingPoliciesUnavailable =>
      'Could not load the Privacy Policy and Terms. Check your connection and try again.';

  @override
  String get onboardingAcceptConsents =>
      'Review and accept every required privacy choice.';

  @override
  String get onboardingSetupFailed => 'Could not complete account setup.';

  @override
  String get onboardingBrandHeader => 'FIELDNOTE · ACCOUNT SETUP';

  @override
  String get onboardingChooseRole => 'Choose role';

  @override
  String get roleSponsor => 'நிதியுதவியாளர்';

  @override
  String get roleVolunteer => 'தன்னார்வலர்';

  @override
  String get onboardingSponsorTitle => 'Set up your sponsor profile';

  @override
  String get onboardingVolunteerTitle => 'Tell AI when and where you can help';

  @override
  String get onboardingSponsorDescription =>
      'Sponsors create, fund, and monitor campaigns.';

  @override
  String get onboardingVolunteerDescription =>
      'Availability and GPS are used to explain every campaign match.';

  @override
  String get onboardingDisplayName => 'காட்சிப் பெயர்';

  @override
  String get onboardingPreparing => 'Preparing account…';

  @override
  String get onboardingEnter => 'Enter FieldNote';

  @override
  String get onboardingLocationLabel => 'இருப்பிடம்';

  @override
  String get onboardingLocationHint => 'Search for an address or place…';

  @override
  String get onboardingChooseOnMap => 'வரைபடத்தில் தேர்ந்தெடு';

  @override
  String get onboardingPlacesHint =>
      'Choose a complete location from Google Places · Powered by Google';

  @override
  String get onboardingPlacesUnavailable =>
      'Location search is unavailable; enter the complete address manually.';

  @override
  String get sponsorTypeIndividual => 'Individual';

  @override
  String get sponsorTypeCompany => 'Company';

  @override
  String get sponsorTypeFoundation => 'Foundation';

  @override
  String get sponsorTypeCommunityGroup => 'Community group';

  @override
  String get onboardingSponsorType => 'Sponsor type';

  @override
  String get onboardingOrganization => 'Organization name (optional)';

  @override
  String get onboardingContactPhone => 'Contact phone (required)';

  @override
  String get onboardingContactPhoneHelper =>
      'Shared with volunteers after they join your campaign.';

  @override
  String get onboardingPreferredCauses => 'Preferred causes';

  @override
  String get onboardingAvailableForMatches => 'Available for campaign matches';

  @override
  String get onboardingAvailableToday => 'இன்று கிடைக்கிறேன்';

  @override
  String get onboardingAvailableDays => 'கிடைக்கும் நாட்கள்';

  @override
  String onboardingTravelRadius(String km) {
    return 'Travel radius · $km km';
  }

  @override
  String get onboardingTravelAreaHint =>
      'Choose your travel area using GPS or the map pin.';

  @override
  String get onboardingFindingLocation => 'Finding your location…';

  @override
  String get onboardingUseGps => 'Use current GPS location';

  @override
  String get onboardingUseGpsInstead => 'Use current GPS instead';

  @override
  String get onboardingRefreshGps => 'Refresh current GPS location';

  @override
  String get onboardingChooseTravelAreaOnMap => 'Choose travel area on map';

  @override
  String get locationEnableInSettings => 'Enable Location in Settings';

  @override
  String get locationOpenPermissions => 'Open FieldNote permissions';

  @override
  String get onboardingFindingAreaName => 'Finding the area name…';

  @override
  String onboardingSelectedArea(String area) {
    return 'Selected area: $area';
  }

  @override
  String get onboardingInterests => 'ஆர்வங்கள்';

  @override
  String get onboardingSkills => 'திறன்கள்';

  @override
  String get onboardingMapSemantics =>
      'Draggable map pin for the area you can travel from';

  @override
  String get onboardingMapFallback =>
      'Map preview is off. Use the GPS button below to set the area you travel from.';

  @override
  String get onboardingPrivacyChoices => 'Privacy choices';

  @override
  String get onboardingPrivacyChoicesBody =>
      'You can review these records, withdraw consent, export your data or delete your account from Trust & safety.';

  @override
  String get onboardingAcceptCurrent =>
      'By continuing you accept the current FieldNote Terms and Privacy Policy.';

  @override
  String onboardingAcceptVersions(String termsVersion, String privacyVersion) {
    return 'By continuing you accept the FieldNote Terms v$termsVersion and Privacy Policy v$privacyVersion.';
  }

  @override
  String get deletionStatusPending => 'Deletion pending';

  @override
  String get deletionStatusProcessing => 'Deletion in progress';

  @override
  String get deletionStatusCompleted => 'Account deleted';

  @override
  String get deletionStatusFailed => 'Deletion failed';

  @override
  String deletionStatusOther(String status) {
    return 'Deletion $status';
  }

  @override
  String get deletionFailedReason =>
      'FieldNote could not finish deleting your account.';

  @override
  String deletionWillRetry(String reason, String time) {
    return '$reason It will retry automatically at $time.';
  }

  @override
  String deletionRequestAgain(String reason) {
    return '$reason Request deletion again, or contact support if this keeps happening.';
  }

  @override
  String get deletionNotDeletedTitle => 'Account not deleted';

  @override
  String get deletionRequestFailed =>
      'Could not request account deletion. Try again.';

  @override
  String get deletionStartedTitle => 'Deletion started';

  @override
  String get deletionStartedBody =>
      'Your account is being deleted and this completes within about a minute. You will now be signed out.';

  @override
  String get deletionDialogTitle => 'Delete your account?';

  @override
  String get deletionExplanation =>
      'Deleting your account removes your profile, availability, invitations, photographs and evidence text, and signs you out on every device. Payment, refund and consent records are kept without your name for accounting and legal purposes. Deletion completes within about a minute and cannot be undone.';

  @override
  String get deletionBlockers =>
      'You cannot delete the account while you are checked in to a campaign, have campaigns that are still open, or have payments or refunds in progress.';

  @override
  String deletionTypeToConfirm(String word) {
    return 'Type $word to confirm.';
  }

  @override
  String get deletionDeleteAccount => 'கணக்கை நீக்கு';

  @override
  String get deletionCompletedBody => 'Your account was deleted.';

  @override
  String deletionRequestedAt(String time) {
    return 'Requested $time. This completes within about a minute and signs you out.';
  }

  @override
  String get deletionRequestAgainButton => 'Request deletion again';

  @override
  String get deletionDeleteMyAccount => 'என் கணக்கை நீக்கு';

  @override
  String get deletionRefreshStatus => 'Refresh status';

  @override
  String get consentNotSavedTitle => 'Consent not saved';

  @override
  String get consentNotSavedBody => 'Could not save your consent. Try again.';

  @override
  String get consentGateIntro =>
      'FieldNote uses location, AI, and private evidence to connect sponsorship with verified volunteer work.';

  @override
  String get consentGatePolicyChanged =>
      'The Privacy Policy or Terms changed since you last agreed. Review them and confirm your choices to continue.';

  @override
  String get consentGateWithdrawn =>
      'You withdrew consent, so matching, check-in, AI drafts and evidence sharing are paused. Accept again to keep using FieldNote, or delete your account.';

  @override
  String get consentGateEyebrow => 'Trust before action';

  @override
  String get consentGateTitle => 'Review your privacy choices';

  @override
  String get commonSaving => 'சேமிக்கிறது…';

  @override
  String get consentAcceptAndContinue => 'Accept and continue';

  @override
  String get consentCheckRequired => 'Check every required choice to continue.';

  @override
  String get signOut => 'வெளியேறு';

  @override
  String get signOutTitle => 'வெளியேறவா?';

  @override
  String get signOutAllDevicesTitle => 'Sign out of all devices?';

  @override
  String get signOutBody =>
      'You will need to sign in again to use FieldNote on this device.';

  @override
  String get signOutAllDevicesBody =>
      'Every device signed in to this account, including this one, will need to sign in again.';

  @override
  String get signOutEverywhere => 'Sign out everywhere';

  @override
  String get trustEyebrow => 'Your account';

  @override
  String get trustTitle => 'நம்பிக்கை & பாதுகாப்பு';

  @override
  String get trustDescription =>
      'Review privacy controls and account activity.';

  @override
  String get trustLoadingTitle => 'Trust data is loading';

  @override
  String get trustLoadingBody =>
      'Pull to refresh the security activity for this account.';

  @override
  String get trustVerifiedPayments => 'Verified payments';

  @override
  String get trustLocationIntegrity => 'Location integrity';

  @override
  String get trustContentModeration => 'Content moderation';

  @override
  String get trustSecurityActivity => 'பாதுகாப்புச் செயல்பாடு';

  @override
  String get trustNoSecurityEvents => 'No security events recorded yet.';

  @override
  String trustViewAllEvents(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return 'View all $countString events';
  }

  @override
  String trustEventCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString events',
      one: '1 event',
    );
    return '$_temp0';
  }

  @override
  String get trustPrivacyControls => 'Privacy controls';

  @override
  String get trustConsentRecorded => 'Consent recorded';

  @override
  String get trustNoConsent => 'No consent recorded';

  @override
  String get trustConsentOutdated => 'Consent withdrawn or out of date';

  @override
  String trustConsentAccepted(
    String time,
    String privacyVersion,
    String termsVersion,
  ) {
    return 'Accepted $time (Privacy Policy v$privacyVersion, Terms v$termsVersion).';
  }

  @override
  String trustConsentLastUpdated(String time) {
    return 'Last updated $time.';
  }

  @override
  String trustCurrentVersions(String privacyVersion, String termsVersion) {
    return 'Current Privacy Policy v$privacyVersion · Terms v$termsVersion';
  }

  @override
  String get trustExportData => 'View and export my data';

  @override
  String get trustWithdrawConsent => 'Withdraw consent';

  @override
  String get trustConsentHistory => 'ஒப்புதல் வரலாறு';

  @override
  String get trustNoConsentChanges => 'No consent changes recorded yet.';

  @override
  String get trustGrantedGps => 'GPS';

  @override
  String get trustGrantedAi => 'AI';

  @override
  String get trustGrantedEvidence => 'evidence sharing';

  @override
  String trustConsentHistoryEntry(
    String time,
    String privacyVersion,
    String termsVersion,
  ) {
    return '$time · Privacy v$privacyVersion, Terms v$termsVersion';
  }

  @override
  String get trustConsentWithdrawn => 'Consent withdrawn';

  @override
  String get trustConsentAcceptedTitle => 'Consent accepted';

  @override
  String get trustWithdrawTitle => 'Withdraw consent?';

  @override
  String get trustWithdrawBody =>
      'FieldNote needs GPS, AI processing and private evidence sharing to work. After you withdraw, matching, check-in, AI drafts and evidence submission stop, and you will be asked to accept again before you can use the app. Your existing records stay until you delete your account.';

  @override
  String get trustKeepConsent => 'Keep consent';

  @override
  String get trustWithdraw => 'Withdraw';

  @override
  String get trustConsentNotWithdrawn => 'Consent not withdrawn';

  @override
  String get trustCheckoutDidNotComplete => 'Checkout did not complete.';

  @override
  String get eventPaymentOrderCreated => 'Razorpay order created';

  @override
  String get eventPaymentSignatureVerified => 'Payment signature checked';

  @override
  String get eventPaymentCheckoutFailed => 'Checkout failed or cancelled';

  @override
  String get eventPaymentVerifiedWithoutCredit =>
      'Payment verification reviewed';

  @override
  String get eventPaymentOrderCreate => 'Checkout requested';

  @override
  String get eventLocationCheckIn => 'Check-in integrity checked';

  @override
  String get eventEvidenceLocationIntegrity => 'Evidence location checked';

  @override
  String get eventEvidenceSubmitted => 'Evidence verified';

  @override
  String get eventContentModeration => 'Content moderation decision';

  @override
  String get eventPrivacyDataExported => 'Data exported';

  @override
  String get eventTestPayoutSimulated => 'Test payout recorded';

  @override
  String get eventAccountDeletionRequested => 'Deletion requested';

  @override
  String get exportLoadFailed => 'Could not load your data. Try again.';

  @override
  String get exportPdfFailed => 'Could not create the PDF. Try again.';

  @override
  String get exportJsonFailed => 'Could not share the JSON file. Try again.';

  @override
  String get exportAppBarTitle => 'என் தரவு';

  @override
  String get exportEyebrow => 'Your account records';

  @override
  String get exportTitle => 'Your FieldNote data';

  @override
  String get exportDescription =>
      'Read your records here, or save a report to your phone.';

  @override
  String get exportReportTitle => 'Save or share a readable report';

  @override
  String exportPreparedAt(String time) {
    return 'Prepared $time. The PDF contains the records shown below.';
  }

  @override
  String get exportPreparingPdf => 'Preparing PDF…';

  @override
  String get exportSharePdf => 'Save or share PDF';

  @override
  String exportRecordCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString records',
      one: '1 record',
    );
    return '$_temp0';
  }

  @override
  String get exportPhotosNotice =>
      'Private photographs are not included in this report. Shared files may contain personal details, so choose where to save them carefully.';

  @override
  String get exportAdvancedTitle => 'Advanced export';

  @override
  String get exportAdvancedSubtitle => 'For moving data to another service';

  @override
  String get exportJsonDescription =>
      'JSON is a machine-readable copy of these account records.';

  @override
  String get exportShareJson => 'Save or share JSON';

  @override
  String get profileChooseLocation => 'Choose profile location';

  @override
  String get profileNeedNameAndLocation =>
      'Enter your display name and location.';

  @override
  String get profileNeedNameAndCity => 'Enter your display name and city.';

  @override
  String get profileNeedInterest => 'Choose at least one interest.';

  @override
  String get profileSelectLocationSuggestion =>
      'Select the new location from the Google suggestions.';

  @override
  String get profileSelectCitySuggestion =>
      'Select the new city from the Google suggestions.';

  @override
  String get profileNeedSkill => 'Choose at least one skill.';

  @override
  String get profileUpdated => 'Profile updated.';

  @override
  String get profileUpdateFailed => 'Could not update your profile.';

  @override
  String get profileNoMappedLocation =>
      'This profile does not have a mapped location yet.';

  @override
  String get profileSponsorAccount => 'Sponsor account';

  @override
  String get profileVolunteerAccount => 'Volunteer account';

  @override
  String get profileEditTitle => 'Edit your profile';

  @override
  String get profileEditDescription =>
      'Update the details people use to reach you.';

  @override
  String get profileSponsorDescription => 'Your contact and campaign identity.';

  @override
  String get profileVolunteerDescription =>
      'Your account and availability details.';

  @override
  String get profileEdit => 'சுயவிவரத்தைத் திருத்து';

  @override
  String get profilePhoneNumber => 'தொலைபேசி எண்';

  @override
  String get profileNotProvided => 'வழங்கப்படவில்லை';

  @override
  String get profileAddPhoneHint =>
      'Add your phone number so volunteers who join your campaigns can call you.';

  @override
  String get profileAddContactNumber => 'Add contact number';

  @override
  String get profileHomeArea => 'Home area';

  @override
  String get profileViewLocationOnMap => 'View location on map';

  @override
  String get profilePhoneSharedNotice =>
      'Your number is shared only with volunteers who join your campaign.';

  @override
  String get profileOrganization => 'Organization';

  @override
  String get profileAvailabilityActive => 'Active';

  @override
  String get profileAvailabilityPaused => 'Paused';

  @override
  String get commonYes => 'ஆம்';

  @override
  String get commonNo => 'இல்லை';

  @override
  String get profileRegularDays => 'Regular days';

  @override
  String get profileHours => 'Hours';

  @override
  String profileHoursRange(String start, String end) {
    return '$start – $end';
  }

  @override
  String get profileTravelRadius => 'Travel radius';

  @override
  String profileKm(String distance) {
    return '$distance km';
  }

  @override
  String get profileTravelArea => 'Travel area';

  @override
  String get profileNotSelected => 'தேர்ந்தெடுக்கப்படவில்லை';

  @override
  String get profileEditAvailability => 'Edit availability and travel area';

  @override
  String get profileSignOutAllDevices => 'Sign out of all devices';

  @override
  String get profileEmailNotifications => 'மின்னஞ்சல் அறிவிப்புகள்';

  @override
  String get profileEmailNotificationsBody =>
      'Emails about campaign changes, cancellations, invitations and confirmations.';

  @override
  String get profileEmailNotificationsFailed =>
      'Could not update email notifications. Try again.';

  @override
  String get profileSignOutAllPartial =>
      'Signed out here, but other devices could not be reached. Try again after signing in.';

  @override
  String get profileSignOutLocalOnly =>
      'Signed out on this device. The server could not be reached to end the session.';

  @override
  String get profilePhoneRequired => 'Phone number (required)';

  @override
  String get profilePhoneOptional => 'Phone number (optional)';

  @override
  String get profilePhoneVisibleToJoined =>
      'Visible only to joined volunteers.';

  @override
  String get profilePhonePrivate => 'Private to your account.';

  @override
  String get profileScheduleManagedInAvailability =>
      'Travel area and schedule are managed in Availability.';

  @override
  String get profileSave => 'சுயவிவரத்தைச் சேமி';

  @override
  String get profileHomeCity => 'Home city';

  @override
  String get profileCityHint => 'Start typing a city…';

  @override
  String get profileLocationSuggestionHint =>
      'Choose a suggestion or pin a place on the map.';

  @override
  String get profileCitySuggestionHint =>
      'Choose a city suggestion · Powered by Google';

  @override
  String get profileCitySearchUnavailable =>
      'City search is unavailable; enter the city manually.';

  @override
  String get profilePrivacyReadOnly => 'Privacy choices (read-only)';

  @override
  String get profileConsentGps => 'GPS for matching and evidence';

  @override
  String get profileConsentAi => 'AI processing';

  @override
  String get profileConsentEvidence => 'Evidence sharing';

  @override
  String get profilePrivacyReviewHint =>
      'Review your consent history or withdraw consent in Trust & safety.';

  @override
  String sponsorGoalRange(String minimum, String maximum) {
    return '$minimum to $maximum.';
  }

  @override
  String sponsorValidationTitle(int min, int max) {
    return 'Use $min–$max characters.';
  }

  @override
  String sponsorValidationDescription(int min, int max) {
    return 'Describe the work in $min–$max characters.';
  }

  @override
  String get sponsorValidationLocation => 'Name the location.';

  @override
  String get sponsorValidationStartsAt =>
      'This time has passed. Choose a start date and time in the future.';

  @override
  String sponsorValidationDuration(int min, int max) {
    return '$min–$max minutes.';
  }

  @override
  String sponsorValidationCapacity(int min, int max) {
    return '$min–$max places.';
  }

  @override
  String get sponsorValidationMinimum => 'Between 1 and the volunteer places.';

  @override
  String get sponsorValidationChecklist => 'Add at least one checklist task.';

  @override
  String sponsorValidationEvidence(int min, int max) {
    return 'Describe the evidence volunteers submit ($min–$max characters).';
  }

  @override
  String sponsorValidationLists(int items, int length) {
    return 'Keep checklists, skills and tags to $items items of up to $length characters.';
  }

  @override
  String sponsorValidationScopeGoal(String range) {
    return 'Choose a funding goal between $range';
  }

  @override
  String sponsorValidationScopeMinimum(int capacity) {
    return 'Choose a minimum team between 1 and $capacity.';
  }

  @override
  String sponsorValidationScopeDescription(int min, int max) {
    return 'Describe the revised work in $min–$max characters.';
  }

  @override
  String get sponsorPayoutsManual =>
      'பணப்பட்டுவாடாக்கள் FieldNote செயல்பாட்டுக் குழுவால் கைமுறையாகச் செய்யப்படுகின்றன.';

  @override
  String get sponsorErrorRequestReused =>
      'This draft was already published as a different campaign. Review your campaigns, then publish again.';

  @override
  String get sponsorErrorRequestInvalid =>
      'FieldNote could not process that request. Try again.';

  @override
  String get sponsorErrorDuplicatePayment =>
      'This payment request was already handled. Start a new checkout.';

  @override
  String get sponsorPhaseDraft => 'வரைவு';

  @override
  String get sponsorPhasePlanning => 'திட்டமிடல்';

  @override
  String get sponsorPhaseNeedsDecision => 'Needs a decision';

  @override
  String get sponsorPhasePostponed => 'ஒத்திவைக்கப்பட்டது';

  @override
  String get sponsorPhaseConfirmed => 'உறுதிசெய்யப்பட்டது';

  @override
  String get sponsorPhaseInProgress => 'நடைபெறுகிறது';

  @override
  String get sponsorPhaseCompleted => 'முடிந்தது';

  @override
  String get sponsorPhaseCancelled => 'ரத்துசெய்யப்பட்டது';

  @override
  String get sponsorPhaseExpired => 'காலாவதியானது';

  @override
  String get sponsorPaymentVerified => 'சரிபார்க்கப்பட்டது';

  @override
  String get sponsorPaymentRefundQueued => 'Refund queued';

  @override
  String get sponsorPaymentFailed => 'தோல்வி';

  @override
  String get sponsorPaymentNotCompleted => 'Not completed';

  @override
  String get sponsorPaymentPending => 'நிலுவையில்';

  @override
  String get sponsorRefundProcessed => 'Refunded';

  @override
  String get sponsorRefundProcessing => 'Refund processing';

  @override
  String get sponsorRefundFailed => 'Refund failed';

  @override
  String get sponsorRefundPending => 'Refund pending';

  @override
  String get sponsorReviewApproved => 'அங்கீகரிக்கப்பட்டது';

  @override
  String get sponsorReviewRejected => 'நிராகரிக்கப்பட்டது';

  @override
  String get sponsorReviewChangesRequested => 'Changes requested';

  @override
  String get sponsorReviewAwaiting => 'Awaiting review';

  @override
  String get sponsorRefundReasonCancelled => 'Campaign cancelled';

  @override
  String get sponsorRefundReasonExpired => 'Campaign expired';

  @override
  String get sponsorRefundReasonUncredited => 'Payment could not be credited';

  @override
  String get sponsorPinPickerNoMatches =>
      'No matching places. Try a city, street, or landmark.';

  @override
  String get sponsorPinPickerSearchUnavailable =>
      'Place search is unavailable. Use the map or GPS.';

  @override
  String get sponsorPinPickerResolveFailed =>
      'That place could not be resolved. Drag the pin instead.';

  @override
  String get sponsorPinPickerTitle => 'Where will this happen?';

  @override
  String get sponsorPinPickerIntro =>
      'Search for a place or move the pin to the exact work site. The ring is the check-in geofence volunteers must stand inside.';

  @override
  String sponsorPinPickerFromBrief(String location) {
    return 'From your brief: $location. Choose a search result or set a pin to confirm it.';
  }

  @override
  String get sponsorPinPickerChooseOnMap => 'வரைபடத்தில் தேர்ந்தெடு';

  @override
  String get sponsorPinPickerSearchLabel => 'இடத்தைத் தேடுக';

  @override
  String get sponsorPinPickerSearchHint => 'City, street, or landmark…';

  @override
  String get sponsorPinPickerClear => 'அழி';

  @override
  String get sponsorPinPickerMapSemantics =>
      'Draggable campaign pin with its check-in geofence';

  @override
  String sponsorPinPickerMapFallback(
    String latitude,
    String longitude,
    int meters,
  ) {
    return 'Map preview is off. Campaign pin: $latitude, $longitude with a $meters m geofence.';
  }

  @override
  String get sponsorPinPickerEmptyTitle => 'Choose the campaign site';

  @override
  String get sponsorPinPickerEmptyMessage =>
      'Select a place result, choose on the map, or use your device location.';

  @override
  String get sponsorPinPickerLocationNotSelected => 'Location not selected';

  @override
  String get sponsorPinPickerUnnamedPin => 'Unnamed pin';

  @override
  String get sponsorPinPickerDeviceLocation => 'Your device location';

  @override
  String sponsorPinPickerGeofenceTitle(int meters) {
    return 'Check-in geofence · $meters m';
  }

  @override
  String sponsorPinPickerGeofenceValue(int meters) {
    return '$meters m';
  }

  @override
  String get sponsorPinPickerGeofenceHelp =>
      'Volunteers must be inside this ring, allowing for their GPS accuracy, before they can check in.';

  @override
  String get sponsorPinPickerFindingLocation => 'Finding my location…';

  @override
  String get sponsorPinPickerPinToMyLocation => 'என் இருப்பிடத்தில் பின் செய்';

  @override
  String get sponsorPinPickerReachTitle => 'Volunteer reach at this pin';

  @override
  String get sponsorPinPickerReachChecking =>
      'Checking who could reach this pin…';

  @override
  String get sponsorPinPickerReachUnavailable =>
      'Reach could not be estimated for this pin.';

  @override
  String sponsorPinPickerMedianDistance(String distance) {
    return 'Median distance $distance km.';
  }

  @override
  String get sponsorPinPickerReachPrivacy =>
      'Counts come from volunteers who published availability and a travel radius. Individual volunteer locations are never shown to sponsors.';

  @override
  String get sponsorPinPickerFullMapSearchUnavailable =>
      'Place search is unavailable. Tap the map to set a pin.';

  @override
  String get sponsorPinPickerFullMapOpenFailed =>
      'That place could not be opened. Choose another result.';

  @override
  String get sponsorPinPickerFullMapTitle => 'பிரச்சார இடத்தைத் தேர்வுசெய்க';

  @override
  String get sponsorPinPickerFullMapSemantics =>
      'Full-screen campaign map. Tap to set the pin.';

  @override
  String get sponsorPinPickerFullMapFallbackSearch =>
      'Map tiles are unavailable. Search for a place here, or go back to use device GPS.';

  @override
  String get sponsorPinPickerFullMapFallbackGps =>
      'Map tiles are unavailable. Go back to use device GPS.';

  @override
  String get sponsorPinPickerFullMapPrompt =>
      'Search for a place or tap the map to choose a site.';

  @override
  String get sponsorPinPickerUseThisPin => 'இந்த பின்னைப் பயன்படுத்து';

  @override
  String get sponsorReachLoadFailed => 'Could not load nearby volunteers.';

  @override
  String get sponsorReachInviteTitle => 'Invite this area?';

  @override
  String sponsorReachInviteBody(int count, String campaign) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Send an in-app invitation to $campaign to the $count available volunteers in this area? Their identities stay private until they choose to join.',
      one:
          'Send an in-app invitation to $campaign to the 1 available volunteer in this area? Their identity stays private until they choose to join.',
      zero:
          'Send an in-app invitation to $campaign to the available volunteers in this area? Their identities stay private until they choose to join.',
    );
    return '$_temp0';
  }

  @override
  String get sponsorReachCancel => 'ரத்துசெய்';

  @override
  String get sponsorReachInviteArea => 'பகுதியை அழை';

  @override
  String get sponsorReachAllAlreadyInvited =>
      'Everyone in this area has already been invited.';

  @override
  String sponsorReachInvitedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Invited $count volunteers in this area.',
      one: 'Invited 1 volunteer in this area.',
    );
    return '$_temp0';
  }

  @override
  String get sponsorReachInviteFailed => 'Could not send the invitations.';

  @override
  String get sponsorReachJoinedInArea => 'Joined in this area';

  @override
  String get sponsorReachApproximateNote =>
      'Pins show approximate areas, not live locations.';

  @override
  String get sponsorReachJoined => 'இணைந்தவர்கள்';

  @override
  String sponsorReachBucketTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count volunteers in this area',
      one: '1 volunteer in this area',
      zero: 'Volunteers in this area',
    );
    return '$_temp0';
  }

  @override
  String get sponsorReachAllInvited => 'All invited';

  @override
  String get sponsorReachClosed => 'மூடப்பட்டது';

  @override
  String get sponsorReachTitle => 'அருகிலுள்ள தன்னார்வலர்கள்';

  @override
  String get sponsorReachPrivacyNote =>
      'Joined volunteers are named. Everyone else is shown only as an area of at least three people, never individually. Pins show approximate areas.';

  @override
  String sponsorReachJoinedCount(int count) {
    return '$count joined';
  }

  @override
  String sponsorReachInReachCount(int count) {
    return '$count in reach';
  }

  @override
  String sponsorReachAreaCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count areas',
      one: '1 area',
    );
    return '$_temp0';
  }

  @override
  String get sponsorReachMapSemantics =>
      'Campaign and approximate volunteer areas';

  @override
  String get sponsorReachMapFallback =>
      'Map unavailable. Volunteers and invite buttons are listed below.';

  @override
  String get sponsorReachMarkerTapHint => 'Tap to view volunteers';

  @override
  String sponsorReachMarkerVolunteers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count volunteers',
      one: '1 volunteer',
    );
    return '$_temp0';
  }

  @override
  String get sponsorReachLegendCampaign => 'பிரச்சாரம்';

  @override
  String get sponsorReachLegendVolunteerArea => 'Volunteer area';

  @override
  String get sponsorReachLegendAreaInvited => 'Area invited';

  @override
  String get sponsorReachNoneJoined => 'No volunteers have joined yet.';

  @override
  String get sponsorReachNearbyAreas => 'Nearby volunteer areas';

  @override
  String get sponsorReachNoAreas =>
      'No area has enough available volunteers to show yet. Areas appear once at least three volunteers nearby publish availability.';

  @override
  String get sponsorReachInvitationsClosed =>
      'Invitations are closed for this campaign.';

  @override
  String get sponsorCampaignMapLoadFailed => 'Could not load the campaign map.';

  @override
  String get sponsorCampaignMapTitle => 'Where the work happened';

  @override
  String get sponsorCampaignMapSemantics =>
      'Map of volunteer check-ins and evidence locations';

  @override
  String get sponsorCampaignMapPinUnverifiedEvidence => 'Unverified · evidence';

  @override
  String get sponsorCampaignMapPinUnverifiedCheckIn => 'Unverified · check-in';

  @override
  String get sponsorCampaignMapPinEvidence => 'சான்று';

  @override
  String get sponsorCampaignMapPinCheckIn => 'செக்-இன்';

  @override
  String sponsorCampaignMapPinSnippet(int distance, int accuracy) {
    return '$distance m from the pin · ±$accuracy m';
  }

  @override
  String sponsorCampaignMapFallback(int count, int meters) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Map preview is off. $count location-verified points recorded within $meters m of the campaign pin.',
      one:
          'Map preview is off. 1 location-verified point recorded within $meters m of the campaign pin.',
    );
    return '$_temp0';
  }

  @override
  String get sponsorCampaignMapLegendCampaign => 'Campaign pin & geofence';

  @override
  String get sponsorCampaignMapLegendEvidence => 'Evidence submitted';

  @override
  String get sponsorCampaignMapLegendUnverified => 'Unverified legacy point';

  @override
  String sponsorCampaignMapJoinedCount(int count) {
    return '$count joined';
  }

  @override
  String sponsorCampaignMapCheckedInCount(int count) {
    return '$count checked in';
  }

  @override
  String sponsorCampaignMapCompletedCount(int count) {
    return '$count completed';
  }

  @override
  String sponsorCampaignMapUnverifiedCount(int count) {
    return '$count unverified';
  }

  @override
  String get sponsorCampaignMapLegacyNote =>
      'Legacy unverified points are retained for audit history and are never counted as verified field locations.';

  @override
  String get sponsorCampaignMapViewPin => 'பிரச்சார பின்னைக் காண்க';

  @override
  String get sponsorCampaignMapProvenanceEyebrow => 'Evidence provenance';

  @override
  String get sponsorCampaignMapProvenanceTitle => 'Verified in place';

  @override
  String get sponsorCampaignMapProvenanceSemantics =>
      'Map of where this evidence was captured';

  @override
  String sponsorCampaignMapProvenanceFallback(int distance, int accuracy) {
    return 'Map preview is off. Captured $distance m from the campaign pin with ±$accuracy m accuracy.';
  }

  @override
  String get sponsorCampaignMapLegacyLocation =>
      'Legacy location · not verified';

  @override
  String sponsorCampaignMapLocationIntegrity(String status) {
    return 'Location integrity $status';
  }

  @override
  String sponsorCampaignMapDistanceFact(int distance, int geofence) {
    return '$distance m from the campaign pin (geofence $geofence m)';
  }

  @override
  String sponsorCampaignMapAccuracyFact(int accuracy) {
    return 'Captured with ±$accuracy m GPS accuracy';
  }

  @override
  String get sponsorCampaignMapServerChecks => 'சர்வர் சோதனைகள்';

  @override
  String get sponsorCampaignMapEvidenceLocation => 'சான்று இருப்பிடம்';

  @override
  String get sponsorCampaignMapViewEvidence => 'View evidence point';

  @override
  String get sponsorPayoutTitle => 'பிரச்சாரப் பணப்பட்டுவாடா';

  @override
  String get sponsorPayoutLoadFailed =>
      'Could not load payout and refund records.';

  @override
  String get sponsorPayoutNothingToSimulate =>
      'No verified Razorpay test checkout is ready to simulate.';

  @override
  String get sponsorPayoutSimulated =>
      'Test payout recorded. No money was sent.';

  @override
  String get sponsorPayoutSimulateFailed => 'Could not simulate payout.';

  @override
  String get sponsorPayoutBlockedCancelled =>
      'This campaign was cancelled, so sponsors are refunded instead of a creator payout.';

  @override
  String get sponsorPayoutBlockedExpired =>
      'This campaign expired before it was confirmed, so sponsors are refunded instead of a creator payout.';

  @override
  String get sponsorPayoutBlockedInProgress =>
      'The event is under way. A payout can be simulated once FieldNote marks the campaign completed after it ends.';

  @override
  String get sponsorPayoutBlockedNotCompleted =>
      'A payout can only be simulated after the campaign is completed: the event must take place and FieldNote marks it completed after it ends.';

  @override
  String get sponsorPayoutTestModePill => 'Razorpay Test Mode';

  @override
  String get sponsorPayoutManualPill => 'கைமுறைத் தீர்வு';

  @override
  String get sponsorPayoutTestModeNotice =>
      'Payment testing is active. No real money has moved to a bank account.';

  @override
  String get sponsorPayoutCancelledRefunds =>
      'Campaign cancelled · verified sponsorships are refunded to the original payment method.';

  @override
  String get sponsorPayoutExpiredRefunds =>
      'Campaign expired · verified sponsorships are refunded to the original payment method.';

  @override
  String get sponsorPayoutStatusTitle => 'பணப்பட்டுவாடா நிலை';

  @override
  String get sponsorPayoutRecordedSponsorships => 'Recorded sponsorships';

  @override
  String get sponsorPayoutRefundedToSponsors => 'Refunded to sponsors';

  @override
  String get sponsorPayoutSimulatedCredit => 'Simulated creator credit';

  @override
  String get sponsorPayoutRealTransfer => 'Real bank transfer';

  @override
  String get sponsorPayoutNoSimulation => 'No simulation yet';

  @override
  String sponsorPayoutCreditsRecorded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count test credits recorded',
      one: '1 test credit recorded',
    );
    return '$_temp0';
  }

  @override
  String get sponsorPayoutSimulating => 'Recording test payout…';

  @override
  String get sponsorPayoutSimulateButton => 'Simulate payout to creator';

  @override
  String get sponsorPayoutRecipientTitle => 'Recipient account';

  @override
  String get sponsorPayoutRecipientAccount =>
      'Creator test account · in-app ledger only';

  @override
  String get sponsorPayoutRecipientHelp =>
      'Tap Simulate after a verified Razorpay test checkout. Each checkout is credited once in this app’s test ledger. No Razorpay Route transfer or bank deposit occurs.';

  @override
  String get sponsorPayoutRefundsTitle => 'Sponsor refunds';

  @override
  String get sponsorPayoutCreditHistoryTitle => 'Test credit history';

  @override
  String sponsorPayoutCheckoutLine(int id, String detail) {
    return 'Checkout #$id · $detail';
  }

  @override
  String get sponsorPayoutBeforeLiveTitle => 'Before live payouts';

  @override
  String get sponsorPayoutBeforeLiveStep1 =>
      '1. Verify the campaign creator and payout account.';

  @override
  String get sponsorPayoutBeforeLiveStep2 =>
      '2. Decide when funds are released if a campaign is delayed, cancelled, or underfunded.';

  @override
  String get sponsorPayoutBeforeLiveStep3 =>
      '3. Reconcile provider transfers, failures, and refunds with the campaign ledger.';

  @override
  String get sponsorPayoutManualDetail =>
      'After campaign completion, request a payout above. Operations verify settlement and your payee details outside the app, then record the bank transfer reference in your payout history. FieldNote never asks for bank details in the app.';

  @override
  String get sponsorCheckoutFullyFundedTitle => 'Campaign fully funded';

  @override
  String get sponsorCheckoutFullyFundedMessage =>
      'This campaign has already reached its funding goal.';

  @override
  String get sponsorCheckoutClosedTitle => 'Campaign closed';

  @override
  String get sponsorCheckoutClosedMessage =>
      'This campaign is no longer accepting sponsorships.';

  @override
  String get sponsorCheckoutTitle => 'Sponsor campaign';

  @override
  String get sponsorCheckoutBanner =>
      'Razorpay test checkout. Payment is credited after verification.';

  @override
  String get sponsorCheckoutBannerLive =>
      'Secure Razorpay checkout. Payment is credited after verification.';

  @override
  String sponsorCheckoutRemaining(String amount) {
    return '$amount மீதம்';
  }

  @override
  String get sponsorCheckoutChooseAmount => 'Choose how much to contribute';

  @override
  String get sponsorCheckoutMessageLabel => 'செய்தி (விருப்பத்தேர்வு)';

  @override
  String get sponsorCheckoutMessageHint => 'Why this campaign matters to you';

  @override
  String get sponsorCheckoutNeedsReviewTitle => 'Payment needs review';

  @override
  String get sponsorCheckoutUnsuccessfulTitle => 'பணம் செலுத்துதல் தோல்வி';

  @override
  String sponsorCheckoutNeedsReviewMessage(String reason) {
    return '$reason If money left your account, it is credited or refunded automatically. See Payment history.';
  }

  @override
  String get sponsorCheckoutProcessing => 'Processing payment…';

  @override
  String sponsorCheckoutPay(String amount) {
    return '$amount செலுத்து';
  }

  @override
  String get sponsorCheckoutCancel => 'ரத்துசெய்';

  @override
  String get sponsorCheckoutSuccessTitle => 'பணம் செலுத்துதல் வெற்றி';

  @override
  String sponsorCheckoutSuccessMessage(String amount, String campaign) {
    return '$amount was added to $campaign.';
  }

  @override
  String get sponsorCheckoutNotCompleted =>
      'The Razorpay test payment was not completed.';

  @override
  String get sponsorEyebrow => 'நிதியளிப்பவர்';

  @override
  String get sponsorDiscoverTitle => 'பிரச்சாரங்கள்';

  @override
  String get sponsorDiscoverTabAll => 'அனைத்தும்';

  @override
  String get sponsorDiscoverTabYours => 'உங்களுடையவை';

  @override
  String get sponsorDiscoverTabCreate => 'உருவாக்கு';

  @override
  String sponsorDiscoverLocalCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count local campaigns',
      one: '1 local campaign',
    );
    return '$_temp0';
  }

  @override
  String get sponsorDiscoverEmptyTitle => 'No campaigns yet';

  @override
  String get sponsorDiscoverEmptyMessage =>
      'Pull down to refresh or start the first campaign.';

  @override
  String get sponsorDiscoverSponsorAction => 'Sponsor campaign';

  @override
  String get sponsorDiscoverFullyFunded => 'Fully funded';

  @override
  String sponsorDiscoverCreatedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count campaigns created',
      one: '1 campaign created',
    );
    return '$_temp0';
  }

  @override
  String get sponsorDiscoverNoCreatedTitle => 'No campaigns created yet';

  @override
  String get sponsorDiscoverNoCreatedMessage =>
      'Create a campaign to see it here.';

  @override
  String get sponsorDiscoverCreateAction => 'பிரச்சாரத்தை உருவாக்கு';

  @override
  String get sponsorDiscoverStartTitle => 'Start a campaign';

  @override
  String get sponsorDiscoverStartBody =>
      'Describe your idea by voice or text, or enter the details yourself.';

  @override
  String get sponsorDiscoverOpenCreator => 'Open campaign creator';

  @override
  String sponsorOwnedCampaignId(String id) {
    return 'CAMPAIGN $id';
  }

  @override
  String sponsorCampaignPlaces(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count places',
      one: '1 place',
    );
    return '$_temp0';
  }

  @override
  String sponsorOwnedJoined(int joined, int capacity) {
    return '$joined/$capacity joined';
  }

  @override
  String sponsorOwnedFundingRatio(String funded, String goal) {
    return '$funded / $goal';
  }

  @override
  String sponsorAmountRefunded(String amount) {
    return '$amount refunded';
  }

  @override
  String get sponsorOwnedVolunteerMap => 'Volunteer map';

  @override
  String get sponsorActionShare => 'பகிர்';

  @override
  String get sponsorCreateExamplePrompt =>
      'I want to sponsor tree care near the university this Saturday. Budget is ₹25,000 and I need about 10 volunteers.';

  @override
  String get sponsorDictationMicPermission =>
      'Microphone permission is required. Allow access and try again.';

  @override
  String get sponsorDictationNoAudio =>
      'The microphone stopped before any audio was captured. Check microphone access and try again.';

  @override
  String get sponsorDictationTooShort =>
      'Hold the microphone button while speaking for at least one second.';

  @override
  String get sponsorDictationFewWords =>
      'Only a few words were heard. Hold the microphone again, or type the rest of the brief.';

  @override
  String get sponsorDictationFailed =>
      'The recording could not be transcribed. Try again, or type the brief.';

  @override
  String get sponsorCreateManualHeading => 'Create a campaign manually';

  @override
  String get sponsorCreateConfirmHeading => 'Confirm campaign details';

  @override
  String get sponsorProposalFormUseDetails => 'Use these details';

  @override
  String get sponsorCreateBriefTooShort =>
      'Describe the cause, place, timing, and intended impact first, or create the campaign manually.';

  @override
  String get sponsorCreateLocationUnreadable =>
      'Could not read this device location. Check Settings and try again.';

  @override
  String get sponsorLocationTurnOnTitle => 'Turn on device location';

  @override
  String get sponsorLocationAllowTitle => 'Allow location access';

  @override
  String get sponsorLocationUnavailableTitle => 'Location unavailable';

  @override
  String get sponsorLocationNotNow => 'இப்போது வேண்டாம்';

  @override
  String get sponsorLocationOpenLocationSettings => 'Open location settings';

  @override
  String get sponsorLocationOpenAppSettings => 'Open app settings';

  @override
  String get sponsorCreateSelectPlaceResult =>
      'Select a place result or restore the selected campaign pin.';

  @override
  String get sponsorCreateChooseLocationFirst =>
      'Choose the campaign location on the map before publishing.';

  @override
  String sponsorCreateIsLive(String name) {
    return '$name is live.';
  }

  @override
  String get sponsorCreatePublishFailed => 'Could not publish the campaign.';

  @override
  String get sponsorCreateGenerateFailed => 'Could not generate the campaign.';

  @override
  String get sponsorCreateEyebrow => 'Sponsor studio';

  @override
  String get sponsorCreateTitle => 'பிரச்சாரத்தை உருவாக்கு';

  @override
  String get sponsorCreateDescription =>
      'Describe the work, then review the draft before publishing.';

  @override
  String get sponsorCreatePromptTitle => 'What needs to happen?';

  @override
  String get sponsorCreatePromptHelp =>
      'Type a brief, or hold the round microphone while you speak and release when finished.';

  @override
  String get sponsorCreateListening => 'Listening…';

  @override
  String get sponsorCreatePromptHint =>
      'Cause, place, date, budget, and volunteers…';

  @override
  String get sponsorCreateClear => 'அழி';

  @override
  String get sponsorCreateExampleButton => 'Start from an example brief';

  @override
  String get sponsorCreateProcessingRecording => 'Processing recording…';

  @override
  String get sponsorCreateGenerating => 'Generating campaign…';

  @override
  String get sponsorCreateGenerate => 'Generate campaign';

  @override
  String get sponsorCreateManualButton => 'Enter campaign details manually';

  @override
  String get sponsorCreateManualNote => 'Manual entry works when AI is busy.';

  @override
  String get sponsorCreateProposalPlaceholder =>
      'Your editable proposal will appear here.';

  @override
  String get sponsorProposalAssistedDraft => 'Assisted draft';

  @override
  String sponsorProposalGoal(String amount) {
    return '$amount goal';
  }

  @override
  String sponsorProposalTeamSummary(String places, int minimum, String hours) {
    return '$places · $minimum minimum safe team · $hours';
  }

  @override
  String sponsorProposalHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hours',
      one: '1 hour',
    );
    return '$_temp0';
  }

  @override
  String get sponsorWorkChecklist => 'Work checklist';

  @override
  String get sponsorProposalEdit => 'திருத்து';

  @override
  String get sponsorProposalPublish => 'வெளியிடு';

  @override
  String get sponsorImpactTitle => 'Campaign impact';

  @override
  String get sponsorImpactDescription =>
      'Follow funding, volunteers, and completed work.';

  @override
  String get sponsorImpactPaymentHistory => 'கட்டண வரலாறு';

  @override
  String sponsorImpactPaymentHistoryReview(int count) {
    return 'Payment history · $count to review';
  }

  @override
  String get sponsorImpactEmptyTitle => 'No sponsored impact yet';

  @override
  String get sponsorImpactEmptyMessage =>
      'Create or sponsor a campaign to begin the evidence loop.';

  @override
  String get sponsorLiveConnected => 'நேரலை';

  @override
  String get sponsorLiveReconnecting => 'Reconnecting…';

  @override
  String get sponsorLiveConnecting => 'Connecting…';

  @override
  String get sponsorLiveNotListening => 'Not listening';

  @override
  String get sponsorImpactStopLive => 'Stop live updates for this campaign';

  @override
  String get sponsorImpactListenLive => 'Listen for live updates';

  @override
  String get sponsorImpactLoading => 'Loading campaign impact…';

  @override
  String get sponsorImpactCancelledNote =>
      'This campaign was cancelled. Verified sponsorships are refunded to the original payment method.';

  @override
  String get sponsorImpactExpiredNote =>
      'This campaign expired before it was confirmed. Verified sponsorships are refunded to the original payment method.';

  @override
  String get sponsorImpactMetricSponsored => 'Sponsored';

  @override
  String get sponsorImpactMetricRefunded => 'Refunded';

  @override
  String get sponsorImpactMetricJoined => 'இணைந்தவர்கள்';

  @override
  String get sponsorImpactMetricCompleted => 'முடிந்தது';

  @override
  String get sponsorImpactMetricEvidence => 'சான்று';

  @override
  String get sponsorImpactVolunteers => 'தன்னார்வலர்கள்';

  @override
  String get sponsorImpactReadiness => 'Readiness';

  @override
  String get sponsorImpactPayout => 'Payout';

  @override
  String get sponsorImpactPostUpdate => 'Post update';

  @override
  String get sponsorImpactUpdatePublishedTitle => 'Update published';

  @override
  String sponsorImpactUpdatePublishedMessage(String title) {
    return 'Volunteers and sponsors can now read \"$title\".';
  }

  @override
  String get sponsorEvidenceTitle => 'Field evidence';

  @override
  String get sponsorEvidenceTapToReview =>
      'Tap a photograph to review it and see exactly where it was captured.';

  @override
  String get sponsorEvidenceTapToSee =>
      'Tap a photograph to see exactly where it was captured.';

  @override
  String get sponsorEvidencePhotoUnavailable => 'Photo unavailable · Retry';

  @override
  String get sponsorEvidenceReloadPhoto => 'Reload photo';

  @override
  String get sponsorEvidenceLocationUnverified => 'Unverified location';

  @override
  String get sponsorEvidenceLocationVerified => 'Location verified';

  @override
  String get sponsorEvidenceReviewAndSee =>
      'Review and see where it was captured';

  @override
  String get sponsorEvidenceSeeWhere => 'See where this was captured';

  @override
  String sponsorEvidenceRejectNoteTooShort(int minimum) {
    return 'Explain why the evidence is rejected (at least $minimum characters).';
  }

  @override
  String sponsorEvidenceNoteTooLong(int maximum) {
    return 'Keep the note under $maximum characters.';
  }

  @override
  String get sponsorEvidenceApproved => 'Evidence approved.';

  @override
  String get sponsorEvidenceRejected => 'Evidence rejected.';

  @override
  String get sponsorEvidenceReviewFailed => 'Could not save the review.';

  @override
  String get sponsorEvidenceYourReview => 'Your review';

  @override
  String get sponsorEvidenceAiDrafted =>
      'The summary was drafted by AI and confirmed by the volunteer.';

  @override
  String sponsorEvidenceSavedNote(String note) {
    return 'Note: $note';
  }

  @override
  String get sponsorEvidenceNoteLabel => 'Note to the volunteer';

  @override
  String get sponsorEvidenceNoteHelper => 'Required when rejecting';

  @override
  String get sponsorEvidenceReject => 'நிராகரி';

  @override
  String get sponsorEvidenceApprove => 'அங்கீகரி';

  @override
  String sponsorCardMatch(int percent) {
    return '$percent% match';
  }

  @override
  String get sponsorCardDateTentative => 'Date tentative';

  @override
  String get sponsorCardAwaitingDecision => 'Awaiting decision';

  @override
  String sponsorCardPlaceAndDate(String location, String date) {
    return '$location · $date';
  }

  @override
  String sponsorFundingOfGoal(String funded, String goal) {
    return '$funded of $goal';
  }

  @override
  String sponsorFundingOfGoalRefunded(
    String funded,
    String goal,
    String refunded,
  ) {
    return '$funded of $goal · $refunded refunded';
  }

  @override
  String get sponsorProposalFormChooseLocation => 'Choose campaign location';

  @override
  String get sponsorProposalFormDefaultSkill => 'No specialist skills';

  @override
  String get sponsorProposalFormDefaultEvidence =>
      'Submit a location-verified photograph and describe the completed work.';

  @override
  String sponsorProposalFormFixFields(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Fix the $count highlighted fields.',
      one: 'Fix the highlighted field.',
    );
    return '$_temp0';
  }

  @override
  String get sponsorProposalFormBasics => 'Basics';

  @override
  String get sponsorProposalFormTitle => 'Campaign title';

  @override
  String get sponsorProposalFormDescription => 'விளக்கம்';

  @override
  String get sponsorProposalFormLocation => 'இடத்தின் பெயர்';

  @override
  String get sponsorProposalFormChooseOnMap => 'வரைபடத்தில் தேர்வு செய்';

  @override
  String get sponsorProposalFormSchedule => 'Schedule and capacity';

  @override
  String get sponsorProposalFormStartsAt => 'Starts at';

  @override
  String get sponsorProposalFormStartPassed =>
      'This time has passed. Choose a start date and time in the future.';

  @override
  String get sponsorProposalFormFunding => 'Funding goal (₹)';

  @override
  String sponsorProposalFormRange(String minimum, String maximum) {
    return '$minimum – $maximum';
  }

  @override
  String get sponsorProposalFormPlaces => 'Volunteer places';

  @override
  String get sponsorProposalFormMinimumTeam => 'Minimum safe team';

  @override
  String get sponsorProposalFormMinutes => 'நிமிடங்கள்';

  @override
  String get sponsorProposalFormWork => 'Work and evidence';

  @override
  String get sponsorProposalFormOneTaskPerLine => 'One task per line';

  @override
  String get sponsorProposalFormSkills => 'தேவையான திறன்கள்';

  @override
  String get sponsorProposalFormOnePerLine => 'One per line';

  @override
  String get sponsorProposalFormEvidence => 'Evidence instructions';

  @override
  String get sponsorProposalFormTags => 'குறிச்சொற்கள்';

  @override
  String get sponsorProposalFormCancel => 'ரத்து செய்';

  @override
  String get sponsorPaymentHistoryTitle => 'பணம் செலுத்திய வரலாறு';

  @override
  String get sponsorPaymentHistoryIntro =>
      'Razorpay Test Mode. Payments are credited only after the server verifies them; anything that could not be credited is refunded automatically.';

  @override
  String get sponsorPaymentHistoryEmptyTitle => 'No payments yet';

  @override
  String get sponsorPaymentHistoryEmptyMessage =>
      'Sponsor a campaign and it will be listed here.';

  @override
  String sponsorPaymentRefundedOn(String amount, String date) {
    return '$amount refunded on $date.';
  }

  @override
  String sponsorPaymentRefunded(String amount) {
    return '$amount refunded.';
  }

  @override
  String sponsorPaymentRefundFailedDetail(String amount) {
    return 'The refund of $amount failed. FieldNote will contact you to resolve it.';
  }

  @override
  String sponsorPaymentRefundOnItsWay(String amount) {
    return 'A refund of $amount is on its way to the original payment method.';
  }

  @override
  String get sponsorPaymentUncreditedDetail =>
      'The payment was verified but could not be credited (for example the campaign closed or was already fully funded). It will be refunded automatically.';

  @override
  String get sponsorPaymentAwaitingConfirmation =>
      'Waiting for Razorpay to confirm this payment. It updates automatically.';

  @override
  String get sponsorReadinessUpdateFailed =>
      'Could not update campaign readiness.';

  @override
  String get sponsorReadinessReviseTitle => 'Revise the work scope';

  @override
  String get sponsorReadinessReviseIntro =>
      'A revised scope asks joined volunteers to reconfirm before they count toward the minimum team.';

  @override
  String get sponsorReadinessReviseGoalLabel => 'Revised funding goal (₹)';

  @override
  String sponsorReadinessRange(String min, String max) {
    return '$min – $max';
  }

  @override
  String get sponsorReadinessReviseMinimumLabel => 'Minimum safe team';

  @override
  String get sponsorReadinessReviseDescriptionLabel =>
      'Revised work description';

  @override
  String get sponsorReadinessSaveRevision => 'Save revision';

  @override
  String get sponsorReadinessPostponePast =>
      'That time has already passed. Choose a new start in the future.';

  @override
  String get sponsorReadinessCancelTitle => 'Cancel this campaign?';

  @override
  String sponsorReadinessCancelBody(int joined, String recorded) {
    String _temp0 = intl.Intl.pluralLogic(
      joined,
      locale: localeName,
      other: '$joined volunteers have',
      one: '1 volunteer has',
    );
    return '$_temp0 joined. Their places are released and they are emailed and told not to travel.\n\nEvery verified sponsorship ($recorded recorded) is refunded to the original payment method. This cannot be undone.';
  }

  @override
  String get sponsorReadinessKeepCampaign => 'Keep campaign';

  @override
  String get sponsorReadinessCancelCampaign => 'பிரச்சாரத்தை ரத்துசெய்';

  @override
  String sponsorReadinessInviteMessage(String link) {
    return 'Volunteer places are open on FieldNote. Join here: $link';
  }

  @override
  String get sponsorReadinessInviteCopied =>
      'Invite and campaign link copied. Share them with your volunteers.';

  @override
  String get sponsorReadinessFundingShort => 'Funding short';

  @override
  String get sponsorReadinessVolunteersShort => 'Volunteers short';

  @override
  String get sponsorReadinessBothShort => 'Funding and volunteers short';

  @override
  String get sponsorReadinessPostponedCutoff => 'Postponed · awaiting cutoff';

  @override
  String get sponsorReadinessPostponedReconfirm =>
      'Postponed · awaiting reconfirmation';

  @override
  String get sponsorReadinessDateExpired => 'Date expired';

  @override
  String get sponsorReadinessOpenTentative => 'Open · date tentative';

  @override
  String get sponsorReadinessTitle => 'Campaign readiness';

  @override
  String get sponsorReadinessCutoffTitle => 'At the cutoff';

  @override
  String sponsorReadinessCheckedBefore(String start) {
    return 'Readiness is checked 24 hours before $start.';
  }

  @override
  String sponsorReadinessReadyBeforeCutoff(String cutoff) {
    return 'Funding and the minimum team are ready. The event will be checked for confirmation on $cutoff.';
  }

  @override
  String sponsorReadinessTentativeUntil(String cutoff) {
    return 'The event stays tentative until $cutoff. Refreshing now updates the counts.';
  }

  @override
  String sponsorReadinessFundingLine(String funded, String goal, String short) {
    return 'Funding: $funded of $goal · $short short';
  }

  @override
  String sponsorReadinessRefundedLine(String amount) {
    return '$amount refunded to sponsors';
  }

  @override
  String sponsorReadinessTeamLine(int joined, int minimum, int short) {
    return 'Team: $joined joined · $minimum minimum · $short short';
  }

  @override
  String get sponsorReadinessReconfirmNote =>
      'After a scope or date change, joined volunteers must reconfirm before counting toward readiness.';

  @override
  String get sponsorReadinessStartedLocked =>
      'This campaign has started. Its date and scope are locked and it can no longer be cancelled.';

  @override
  String get sponsorReadinessDecisionsTitle => 'Sponsor decisions';

  @override
  String get sponsorReadinessTopUpHint =>
      'Top up through the sponsor checkout. A verified payment updates the funding result.';

  @override
  String get sponsorReadinessRecruitHint =>
      'Keep recruiting volunteers. New joins and reconfirmations update the team result.';

  @override
  String get sponsorReadinessCopyInvite => 'Copy volunteer invite';

  @override
  String get sponsorReadinessOpenCheckout => 'Open sponsor checkout';

  @override
  String get sponsorReadinessReviseScope => 'Revise scope';

  @override
  String get sponsorReadinessPostpone => 'ஒத்திவை';

  @override
  String get sponsorReadinessRefreshStatus => 'Refresh status';

  @override
  String sponsorPostTitleInvalid(int min, int max) {
    return 'Give the update a title of $min–$max characters.';
  }

  @override
  String sponsorPostBodyInvalid(int min, int max) {
    return 'Write $min–$max characters for the update.';
  }

  @override
  String get sponsorPostPublishFailed => 'Could not publish the update.';

  @override
  String get sponsorPostTitle => 'Post an update';

  @override
  String sponsorPostAudience(String campaign) {
    return 'Volunteers and sponsors of $campaign will see this update.';
  }

  @override
  String get sponsorPostTitleLabel => 'தலைப்பு';

  @override
  String get sponsorPostBodyLabel => 'Update';

  @override
  String get sponsorPostPublishing => 'Publishing…';

  @override
  String get sponsorPostPublish => 'Publish update';

  @override
  String get sponsorDiscardTitle => 'Discard changes?';

  @override
  String get sponsorDiscardMessage =>
      'What you entered in this form will be lost.';

  @override
  String get sponsorDiscardKeepEditing => 'Keep editing';

  @override
  String get sponsorDiscardConfirm => 'நிராகரி';

  @override
  String get coreErrorSessionExpired =>
      'உங்கள் அமர்வு காலாவதியானது, மீண்டும் உள்நுழையவும்.';

  @override
  String get coreErrorOffline =>
      'FieldNote-ஐ அணுக முடியவில்லை. உங்கள் இணைப்பைச் சரிபார்க்கவும்.';

  @override
  String get coreErrorGeneric =>
      'FieldNote could not complete that action. Try again.';

  @override
  String get coreErrorServer =>
      'FieldNote hit a problem on the server. Try again.';

  @override
  String get coreErrorForbidden => 'இதற்கு உங்களுக்கு அனுமதி இல்லை.';

  @override
  String get coreErrorRateLimited =>
      'Too many requests. Wait a moment and try again.';

  @override
  String coreErrorRateLimitedWait(String wait) {
    return 'Too many requests. Try again in $wait.';
  }

  @override
  String coreWaitSeconds(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count seconds',
      one: '1 second',
    );
    return '$_temp0';
  }

  @override
  String coreWaitMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minutes',
      one: '1 minute',
    );
    return '$_temp0';
  }

  @override
  String coreWaitHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hours',
      one: '1 hour',
    );
    return '$_temp0';
  }

  @override
  String get coreErrorDeletionBlocked =>
      'Your account cannot be deleted yet. Resolve open campaigns or payments and try again.';

  @override
  String get coreErrorDeletionOpenCampaign =>
      'Cancel or complete the campaigns you created before deleting your account.';

  @override
  String get coreErrorDeletionRefundPending =>
      'A refund for one of your payments is still being processed. Try again once it completes.';

  @override
  String get coreErrorDeletionPaymentPending =>
      'One of your payments is still being confirmed. Try again once it settles.';

  @override
  String get coreErrorDeletionCheckedIn =>
      'Finish or leave the campaign you are checked in to before deleting your account.';

  @override
  String get coreErrorCampaignStarted => 'This campaign has already started.';

  @override
  String get coreErrorCampaignExpired => 'இந்த பிரச்சாரம் காலாவதியாகிவிட்டது.';

  @override
  String get coreErrorCampaignNotCompleted =>
      'This is available once the campaign completes.';

  @override
  String get coreErrorCampaignFull => 'இந்த பிரச்சாரம் ஏற்கனவே நிரம்பிவிட்டது.';

  @override
  String get coreErrorCampaignClosed => 'This campaign is closed.';

  @override
  String get coreErrorCampaignUnavailable =>
      'This campaign is no longer available.';

  @override
  String get coreErrorCampaignNotFound => 'This campaign could not be found.';

  @override
  String get coreErrorCampaignNotConfirmed =>
      'This campaign is not confirmed yet.';

  @override
  String get coreErrorPayoutsExist =>
      'A creator payout was already recorded, so this campaign cannot be changed.';

  @override
  String get coreErrorPayoutsManual =>
      'Payouts are settled manually by FieldNote operations.';

  @override
  String get coreErrorInvalidFundingGoal => 'Enter a valid funding goal.';

  @override
  String get coreErrorInvalidDuration => 'Enter a valid campaign duration.';

  @override
  String get coreErrorInvalidCapacity => 'Enter a valid volunteer capacity.';

  @override
  String get coreErrorInvalidAmount => 'Enter a valid amount.';

  @override
  String get coreErrorInvalidCampaignDate => 'Choose a valid campaign date.';

  @override
  String get coreErrorInvalidAvailability =>
      'Check your availability settings and try again.';

  @override
  String get coreErrorInvalidContactPhone => 'Enter a valid phone number.';

  @override
  String get coreErrorInvalidLocation =>
      'That location is not valid. Choose another place.';

  @override
  String get coreErrorInvalidSummary =>
      'Check the summary length and try again.';

  @override
  String get coreErrorInvalidPhotograph =>
      'That photograph could not be used. Take or choose another one.';

  @override
  String get coreErrorInvalidTimezone =>
      'Your device time zone was not recognised.';

  @override
  String get coreErrorInvalidInput =>
      'Some of the details are invalid. Check them and try again.';

  @override
  String get coreErrorInputTooLong =>
      'That text is too long. Shorten it and try again.';

  @override
  String get coreErrorClientRequestIdReused =>
      'This request was already used for something else. Start again.';

  @override
  String get coreErrorDuplicatePaymentRequest =>
      'This payment request was already handled. Start a new checkout.';

  @override
  String get coreErrorConsentRequired =>
      'Accept the current consent to continue.';

  @override
  String get coreErrorUploadFailed =>
      'The photograph could not be uploaded. Try again.';

  @override
  String get coreErrorPhotoRequired => 'Add an evidence photograph first.';

  @override
  String get coreErrorOutsideGeofence =>
      'Move closer to the campaign location and try again.';

  @override
  String get coreErrorCheckInWindow =>
      'GPS check-in is available from 30 minutes before the event until it ends.';

  @override
  String get coreErrorCompletionWindowClosed =>
      'The evidence window for this campaign has closed.';

  @override
  String get coreErrorJoinRequired => 'Join this campaign first.';

  @override
  String get coreErrorCheckInRequired => 'Check in on site first.';

  @override
  String get coreErrorAiUnavailable =>
      'AI assistance is unavailable right now.';

  @override
  String get coreLocationServiceDisabled =>
      'Location is turned off. Enable Location on this device and try again.';

  @override
  String get coreLocationPermissionDenied =>
      'Location permission was not granted. Allow it and try again.';

  @override
  String get coreLocationPermissionBlocked =>
      'Location permission is blocked. Enable Precise Location for FieldNote in device Settings.';

  @override
  String get coreLocationTimedOut =>
      'A precise location could not be obtained in time. Move near a window and try again.';

  @override
  String get coreLocationUnavailable =>
      'The device location is currently unavailable. Check Location settings and try again.';

  @override
  String get coreMapRetry => 'வரைபடத்தை மீண்டும் ஏற்று';

  @override
  String get coreMapShowDetails => 'Map not loading? Show location details';

  @override
  String get coreMapUnavailable =>
      'Map preview is unavailable. Location details are still shown below.';

  @override
  String get corePlacesSearchLabel => 'Search Google Places';

  @override
  String get corePickerSearchHint => 'City, address, or landmark';

  @override
  String get corePickerNoMatches =>
      'No matching places. Try a nearby landmark.';

  @override
  String get corePickerSearchUnavailable =>
      'Place search is unavailable. Tap the map to set a pin.';

  @override
  String get corePickerOpenFailed =>
      'Could not open that place. Try another result.';

  @override
  String get corePickerMapSemantics =>
      'Google map. Tap to select an exact location.';

  @override
  String get corePickerTilesUnavailable =>
      'Map tiles are unavailable. Search for a place above.';

  @override
  String get corePickerPrompt => 'Search or tap the map to choose a location.';

  @override
  String get corePickerUseLocation => 'இந்த இடத்தைப் பயன்படுத்து';

  @override
  String corePlaceLocation(String coordinates) {
    return 'Location: $coordinates';
  }

  @override
  String get coreTravelTitle => 'Travel to campaign';

  @override
  String get coreTravelWalk => 'நடை';

  @override
  String get coreTravelDrive => 'வாகனம்';

  @override
  String get coreTravelCycle => 'சைக்கிள்';

  @override
  String get coreTravelYourPosition => 'Your current position';

  @override
  String coreTravelFallback(String place) {
    return 'Destination: $place. Live distance and route instructions remain below.';
  }

  @override
  String get coreTravelRouteUnavailable =>
      'A road route is unavailable. The destination pin is still shown.';

  @override
  String get coreTravelDetailsChanged =>
      'Campaign details changed. Return to My work before travelling.';

  @override
  String get coreTravelConfirmFailed =>
      'Could not confirm the event. Try again online.';

  @override
  String get coreTravelOffRoute =>
      'Off planned route · recalculating when available';

  @override
  String coreTravelRouteSummary(String distance, int minutes) {
    return '$distance km route · about $minutes min';
  }

  @override
  String coreTravelRemaining(String distance, int minutes) {
    return '$distance km remaining · about $minutes min';
  }

  @override
  String get coreTravelRouteSteps => 'Route steps';

  @override
  String get coreTravelCloseSteps => 'Close route steps';

  @override
  String coreTravelStepDistance(String meters) {
    return '$meters m';
  }

  @override
  String get coreTravelViewSteps => 'View route steps';

  @override
  String get coreTravelArrived =>
      'Near the campaign pin. Return to My work for GPS check-in.';

  @override
  String get coreTravelJoinFirst =>
      'Join this campaign and wait for event confirmation before travelling.';

  @override
  String get coreTravelStop => 'Stop travel';

  @override
  String get coreTravelStart => 'Start travel';

  @override
  String get coreTravelRetryRoute => 'Retry road route';

  @override
  String get coreTravelRetryLocation => 'Retry location';

  @override
  String volunteerCheckInOpensAt(String time) {
    return 'Check-in opens at $time';
  }

  @override
  String volunteerCheckInOpensOn(String date, String time) {
    return 'Check-in opens $date at $time';
  }

  @override
  String get volunteerStatusImpactSubmitted => 'Impact submitted';

  @override
  String get volunteerStatusLeft => 'You left this campaign';

  @override
  String get volunteerStatusLeftDetail =>
      'Your place was freed. You can join again while it is open.';

  @override
  String get volunteerStatusNoShow => 'Missed · no check-in';

  @override
  String get volunteerStatusNoShowDetail =>
      'The campaign ended without a GPS check-in from you.';

  @override
  String get volunteerStatusIncomplete => 'Incomplete · no evidence';

  @override
  String get volunteerStatusIncompleteDetail =>
      'You checked in, but no evidence was sent before the deadline.';

  @override
  String get volunteerStatusCampaignCompleted => 'Campaign completed';

  @override
  String get volunteerStatusEvidenceWindowClosed =>
      'The evidence window has closed.';

  @override
  String get volunteerStatusCampaignFinished => 'This campaign has finished.';

  @override
  String get volunteerStatusCheckedIn => 'GPS checked in';

  @override
  String get volunteerStatusJoined => 'இணைந்தீர்கள்';

  @override
  String get volunteerStatusExpired => 'Campaign expired';

  @override
  String get volunteerStatusExpiredDetail =>
      'The proposed date passed without enough support. Do not travel.';

  @override
  String get volunteerStatusCancelled => 'Campaign cancelled — do not travel';

  @override
  String get volunteerStatusCancelledDetail =>
      'The organizer cancelled this campaign.';

  @override
  String get volunteerReviewAwaiting => 'Awaiting sponsor review';

  @override
  String get volunteerReviewApproved => 'Approved by sponsor';

  @override
  String get volunteerReviewChangesRequested => 'Changes requested';

  @override
  String get volunteerReviewRejected => 'Rejected by sponsor';

  @override
  String get volunteerGpsOutOfDate =>
      'The GPS reading is out of date. Try again.';

  @override
  String volunteerGpsAccuracyTooLow(String accuracy, int required) {
    return 'GPS accuracy is ±$accuracy m; FieldNote needs $required m or better. Move outdoors or near a window and try again.';
  }

  @override
  String get volunteerTimesWithinDay => 'Choose times within the day.';

  @override
  String get volunteerEndAfterStart =>
      'The end time must be after the start time.';

  @override
  String get volunteerAreaMapTitle => 'Choose travel area';

  @override
  String get volunteerAreaMapMinimize => 'Minimize map';

  @override
  String get volunteerAreaMapSemantics =>
      'Full screen map. Tap or drag to choose your travel area.';

  @override
  String get volunteerYourTravelArea => 'Your travel area';

  @override
  String get volunteerAreaMapUnavailable =>
      'The map is unavailable. Return to Availability and use your current GPS area.';

  @override
  String get volunteerAreaMapTapPrompt =>
      'Tap the map to place your travel area pin.';

  @override
  String volunteerAreaMapPinSelected(int radius) {
    return 'Pin selected · $radius km travel radius';
  }

  @override
  String get volunteerAreaMapUseArea => 'Use this area';

  @override
  String get volunteerLinkOpenFailed =>
      'Could not open the campaign link. Try again.';

  @override
  String get volunteerLinkStartedInMyWork =>
      'This campaign has started. Your place is in My work.';

  @override
  String get volunteerLinkNoLongerOpen => 'This campaign is no longer open.';

  @override
  String volunteerJoined(String campaign) {
    return 'You joined $campaign.';
  }

  @override
  String get volunteerJoinFailed => 'Could not join this campaign.';

  @override
  String get volunteerJoinCampaignFailed => 'Could not join the campaign.';

  @override
  String get volunteerInvitationTitle => 'Campaign invitation';

  @override
  String get volunteerShareCampaign => 'Share campaign';

  @override
  String get volunteerInvitationEyebrow => 'FIELDNOTE CAMPAIGN';

  @override
  String get volunteerJoining => 'Joining…';

  @override
  String get volunteerViewMyWork => 'View my work';

  @override
  String get volunteerJoinCampaign => 'பிரச்சாரத்தில் சேர்';

  @override
  String get volunteerJoin => 'சேர்';

  @override
  String get volunteerFull => 'நிரம்பியது';

  @override
  String get volunteerSignInToJoin =>
      'Sign in with a volunteer account to join this campaign.';

  @override
  String get volunteerHistoryAppBar => 'My impact';

  @override
  String get volunteerHistoryEyebrow => 'Your record';

  @override
  String get volunteerHistoryTitle => 'Impact & history';

  @override
  String get volunteerHistoryDescription =>
      'Every campaign you joined, what happened, and how your evidence was reviewed.';

  @override
  String get volunteerHistoryStatJoined => 'Campaigns joined';

  @override
  String get volunteerHistoryStatSubmitted => 'Evidence submitted';

  @override
  String get volunteerHistoryStatApproved => 'Approved by sponsors';

  @override
  String get volunteerHistoryEmptyTitle => 'No history yet';

  @override
  String get volunteerHistoryEmptyMessage =>
      'Campaigns you join will appear here.';

  @override
  String volunteerSponsorNote(String note) {
    return 'Sponsor note: $note';
  }

  @override
  String volunteerSubmittedAt(String time) {
    return 'Submitted $time';
  }

  @override
  String volunteerSubmittedAtAi(String time) {
    return 'Submitted $time · AI-assisted summary';
  }

  @override
  String get volunteerViewEvidencePhoto => 'View my evidence photo';

  @override
  String get volunteerPhotoLoadFailed => 'Could not load the photo.';

  @override
  String get volunteerMatchesEyebrow => 'Volunteer campaigns';

  @override
  String get volunteerMatchesTitle => 'Find a campaign';

  @override
  String get volunteerMatchesDescription =>
      'Browse nearby work and invitations.';

  @override
  String get volunteerTabList => 'பட்டியல்';

  @override
  String get volunteerTabMap => 'வரைபடம்';

  @override
  String get volunteerTabInvites => 'அழைப்புகள்';

  @override
  String get volunteerNoMatchesTitle => 'No matches yet';

  @override
  String get volunteerNoMatchesWiden =>
      'Try increasing your travel radius or choosing more available days.';

  @override
  String get volunteerNoMatchesTurnOn =>
      'Turn on availability to let AI recommend campaigns.';

  @override
  String get volunteerEveryPlaceTaken => 'Every place is taken';

  @override
  String get volunteerInvitedReason =>
      'The campaign creator invited you to join';

  @override
  String get volunteerMapUnavailableTitle => 'Map unavailable';

  @override
  String get volunteerMapUnavailableMessage =>
      'Open List to browse and join campaigns.';

  @override
  String get volunteerMapEmptyTitle => 'No campaigns on the map yet';

  @override
  String get volunteerMapEmptyMessage =>
      'Check your availability and travel radius, then refresh.';

  @override
  String get volunteerInvitations => 'அழைப்புகள்';

  @override
  String volunteerInvitationsCount(int count) {
    return 'Invitations ($count)';
  }

  @override
  String get volunteerCheckInvitations => 'Check for invitations';

  @override
  String get volunteerNoInvitations =>
      'No invitations yet. Pull down to check again.';

  @override
  String get volunteerViewRoute => 'வழியைக் காண்க';

  @override
  String volunteerDistanceStraight(String distance) {
    return '$distance km away (straight line)';
  }

  @override
  String volunteerDistanceByRoad(int minutes, String distance) {
    return '$minutes min drive · $distance km by road';
  }

  @override
  String get volunteerMatchMapSemantics =>
      'Map of matched campaigns inside your travel radius';

  @override
  String get volunteerYourArea => 'Your area';

  @override
  String volunteerMatchPinTitle(String campaign, String score) {
    return '$campaign · $score';
  }

  @override
  String get volunteerLegendStrong => 'Strong match';

  @override
  String get volunteerLegendModerate => 'Moderate match';

  @override
  String get volunteerLegendWeaker => 'Weaker match';

  @override
  String get volunteerMatchMapHint =>
      'Tap a pin for the full score explanation. The ring is your saved travel radius.';

  @override
  String get volunteerWorkEyebrow => 'Your campaigns';

  @override
  String get volunteerWorkDescription =>
      'See your joined campaigns, directions, and next steps.';

  @override
  String get volunteerOpenHistory => 'My impact & history';

  @override
  String get volunteerNoJoinedCampaigns => 'No joined campaigns yet';

  @override
  String get volunteerNoUpcomingCampaigns => 'No upcoming campaigns';

  @override
  String get volunteerFindNearby =>
      'Find a campaign nearby and join when it fits.';

  @override
  String get volunteerBrowseCampaigns => 'Browse campaigns';

  @override
  String get volunteerPastAndClosed => 'Past and closed';

  @override
  String volunteerCampaignNumber(int id) {
    return 'Campaign #$id';
  }

  @override
  String volunteerJoinedOnRefresh(String date) {
    return 'Joined $date. Pull down to refresh the campaign details.';
  }

  @override
  String get volunteerViewMyEvidence => 'View my evidence';

  @override
  String get volunteerCreatorNoPhone =>
      'This campaign creator has no saved phone number yet.';

  @override
  String get volunteerContactLoadFailed => 'Could not load contact. Try again.';

  @override
  String get volunteerDialerFailed => 'Could not open the phone dialer.';

  @override
  String get volunteerCheckInConfirmed => 'On-site GPS check-in confirmed.';

  @override
  String get volunteerCheckInFailed => 'Live GPS check-in was not available.';

  @override
  String get volunteerLeaveTitle => 'Leave this campaign?';

  @override
  String volunteerLeaveBody(String campaign) {
    return 'Your place in $campaign will be freed for another volunteer. You can join again later if places are still open.';
  }

  @override
  String get volunteerStay => 'Stay';

  @override
  String get volunteerLeaveCampaign => 'பிரச்சாரத்திலிருந்து வெளியேறு';

  @override
  String volunteerLeft(String campaign) {
    return 'You left $campaign.';
  }

  @override
  String get volunteerLeaveFailed => 'Could not leave the campaign.';

  @override
  String get volunteerReconfirmFailed => 'Could not reconfirm your place.';

  @override
  String get volunteerReadinessConfirmed => 'Event confirmed';

  @override
  String get volunteerReadinessPostponed => 'Postponed · new proposed date';

  @override
  String get volunteerReadinessAwaitingSponsor => 'Awaiting sponsor decision';

  @override
  String get volunteerReadinessTentative => 'Date tentative';

  @override
  String volunteerTimeRange(String start, String end) {
    return '$start–$end';
  }

  @override
  String volunteerOrganizerUpdate(String update) {
    return 'Organizer update: $update';
  }

  @override
  String get volunteerReconfirmNeeded =>
      'The sponsor changed the date or work scope. Review the details, then reconfirm your place.';

  @override
  String get volunteerReconfirm => 'Reconfirm my place';

  @override
  String get volunteerContactLoading => 'Loading campaign contact…';

  @override
  String get volunteerContactRefresh => 'Refresh creator contact';

  @override
  String get volunteerContactCall => 'Call campaign creator';

  @override
  String get volunteerContactRetry =>
      'Could not load the contact. Tap to retry.';

  @override
  String get volunteerContactMissing =>
      'The creator of this campaign has not added a phone number yet. They can add it in their Profile.';

  @override
  String get volunteerFieldChecklist => 'Field checklist';

  @override
  String get volunteerSubmitEvidence => 'Submit photo + field note';

  @override
  String get volunteerAwaitConfirmation => 'Await event confirmation';

  @override
  String get volunteerReconfirmFirst => 'Reconfirm your place first';

  @override
  String get volunteerCheckInClosed => 'Check-in has closed';

  @override
  String get volunteerCheckInOnSite => 'GPS check in on site';

  @override
  String get volunteerCheckInWindowHint =>
      'Check-in is open from 30 minutes before the start until the end of the event.';

  @override
  String get volunteerLeaving => 'Leaving…';

  @override
  String get volunteerLiveLocationCheck => 'Live location check';

  @override
  String get volunteerGpsStreaming => 'GPS streaming';

  @override
  String get volunteerGpsNotStarted => 'Not started';

  @override
  String get volunteerGpsPaused => 'GPS paused';

  @override
  String get volunteerTrackingIntro =>
      'Start tracking to request Precise Location and show live coordinates, accuracy, mock-location status, and geofence distance.';

  @override
  String get volunteerLiveLocationUnavailable =>
      'Live location is unavailable.';

  @override
  String volunteerAccuracyFact(String meters) {
    return '±$meters m';
  }

  @override
  String get volunteerMockDetected => 'Mock flag detected';

  @override
  String get volunteerNoMock => 'No mock flag';

  @override
  String get volunteerCalculatingDistance => 'Calculating distance';

  @override
  String volunteerDistanceAccuracyLow(String meters) {
    return '$meters m · accuracy too low';
  }

  @override
  String volunteerDistanceInside(String meters) {
    return '$meters m · inside geofence';
  }

  @override
  String volunteerDistanceOutside(String meters) {
    return '$meters m · outside geofence';
  }

  @override
  String volunteerFixAge(int seconds) {
    return '$seconds s old';
  }

  @override
  String get volunteerStopTracking => 'Stop live tracking';

  @override
  String get volunteerEnableTracking => 'Enable live location';

  @override
  String get volunteerRouteUnavailable => 'Route unavailable';

  @override
  String get volunteerTrackingPrivacy =>
      'Tracking stays on this screen. Only the check-in snapshot is sent to the server.';

  @override
  String get volunteerApproachMapSemantics =>
      'Map showing the campaign geofence and your live position';

  @override
  String get volunteerYouAreHere => 'நீங்கள் இங்கே இருக்கிறீர்கள்';

  @override
  String volunteerMetersFromPin(String meters) {
    return '$meters m from the pin';
  }

  @override
  String get volunteerApproachFallbackNoFix =>
      'Map preview is off. Enable live location for a distance readout, or add a Maps key to draw the geofence.';

  @override
  String volunteerApproachFallback(String meters, String geofence) {
    return 'Map preview is off. You are $meters m from the campaign pin (geofence $geofence m).';
  }

  @override
  String get volunteerLegendCampaignPin => 'Campaign pin';

  @override
  String volunteerLegendGeofence(String meters) {
    return 'Geofence $meters m';
  }

  @override
  String get volunteerLegendAccuracy => 'Your GPS accuracy';

  @override
  String get volunteerCameraUnavailable =>
      'The camera is unavailable. Allow camera access or choose from the gallery.';

  @override
  String get volunteerGalleryFailed => 'Could not open the photo library.';

  @override
  String get volunteerOpenSettings => 'அமைப்புகளைத் திற';

  @override
  String get volunteerMicPermission =>
      'Microphone access is off. Allow microphone and speech recognition for FieldNote in Settings, or type your note.';

  @override
  String get volunteerNoSpeech =>
      'No speech was heard. Try again or type your note.';

  @override
  String get volunteerDictationStopped =>
      'Dictation stopped. Try again or type your note.';

  @override
  String get volunteerSpeechUnavailable =>
      'Speech recognition is unavailable on this device. Type your note instead.';

  @override
  String get volunteerDictationFailed =>
      'Dictation could not start. Type your note instead.';

  @override
  String get volunteerPhotoFirst =>
      'Take or choose an evidence photograph first.';

  @override
  String volunteerNoteTooShort(int min) {
    return 'Add or dictate a field note of at least $min characters.';
  }

  @override
  String get volunteerAnalyzeFailed =>
      'AI could not analyze this note. Write the summary yourself below.';

  @override
  String volunteerSummaryLength(int min, int max) {
    return 'Write a summary of the completed work ($min–$max characters).';
  }

  @override
  String volunteerNoteTooLong(int max) {
    return 'Keep the field note under $max characters.';
  }

  @override
  String get volunteerEvidenceSent => 'Impact evidence sent to the sponsor.';

  @override
  String get volunteerSubmitFailed => 'Could not submit evidence.';

  @override
  String get volunteerEvidenceEyebrow => 'Evidence';

  @override
  String get volunteerEvidenceEyebrowAi => 'AI evidence assistant';

  @override
  String get volunteerEvidenceTitle => 'Show what changed';

  @override
  String get volunteerEvidenceDescription =>
      'Capture one photo, describe the result, then confirm your summary.';

  @override
  String get volunteerEvidenceDescriptionAi =>
      'Capture one photo, describe the result, then confirm the structured summary.';

  @override
  String get volunteerEvidenceWindowClosed =>
      'The evidence window for this campaign has closed.';

  @override
  String get volunteerTakePhoto => 'Take evidence photograph';

  @override
  String get volunteerChooseGallery => 'கேலரியிலிருந்து தேர்ந்தெடு';

  @override
  String get volunteerNoteLabel => 'What did your team complete?';

  @override
  String get volunteerNoteHint =>
      'We planted 12 saplings and cleared 8 bags of waste…';

  @override
  String get volunteerStopListening => 'Stop listening';

  @override
  String get volunteerDictateNote => 'Dictate note';

  @override
  String get volunteerAnalyzing => 'Analyzing…';

  @override
  String get volunteerAnalyze => 'AI analyze field note';

  @override
  String get volunteerWriteMyself => 'Write the summary myself';

  @override
  String get volunteerSummaryManualPill => 'Your summary · not AI generated';

  @override
  String get volunteerSummaryAiPill => 'AI draft · volunteer confirms';

  @override
  String get volunteerAiUnavailableDescribe =>
      'AI analysis is unavailable. Describe the completed work in your own words.';

  @override
  String get volunteerDescribeOwnWords =>
      'Describe the completed work in your own words.';

  @override
  String get volunteerConfirmedSummary => 'Confirmed impact summary';

  @override
  String volunteerSummaryHelper(int min) {
    return 'At least $min characters. The sponsor sees this.';
  }

  @override
  String get volunteerCheckingGps => 'Checking your GPS position…';

  @override
  String get volunteerUploading => 'Uploading photo and submitting evidence…';

  @override
  String get volunteerSubmitting => 'Submitting…';

  @override
  String get volunteerConfirmSubmit => 'Confirm and submit evidence';

  @override
  String get volunteerNoPlacesFound => 'No matching places found.';

  @override
  String get volunteerPlaceSearchUnavailable =>
      'Place search is unavailable. Move the pin or use GPS.';

  @override
  String get volunteerPlaceSelectFailed =>
      'Could not select that place. Try another result.';

  @override
  String get volunteerAvailableFrom => 'Available from';

  @override
  String get volunteerAvailableUntil => 'Available until';

  @override
  String get volunteerSelectSearchResult =>
      'Select a search result, or clear the search to keep the current pin.';

  @override
  String get volunteerAvailabilitySaved => 'Availability saved.';

  @override
  String get volunteerAvailabilityFailed => 'Could not update availability.';

  @override
  String get volunteerAvailabilityEyebrow => 'Volunteer preferences';

  @override
  String get volunteerAvailabilityDescription =>
      'Choose when and how far you can travel.';

  @override
  String get volunteerAvailableToggle => 'I am available for campaigns';

  @override
  String get volunteerAvailableToggleHint =>
      'Pause this without deleting your preferences.';

  @override
  String get volunteerTodayToggle => 'I can help today';

  @override
  String get volunteerTodayToggleHint => 'Turns off automatically at midnight.';

  @override
  String get volunteerRegularDays => 'Regular days';

  @override
  String get volunteerTimeWindow => 'Time window';

  @override
  String volunteerFromTime(String time) {
    return 'From $time';
  }

  @override
  String volunteerUntilTime(String time) {
    return 'Until $time';
  }

  @override
  String get volunteerTravelFrom => 'Where you can travel from';

  @override
  String get volunteerTravelFromHint =>
      'Drag the pin to the area you actually set out from. The ring is the radius below, drawn to scale.';

  @override
  String get volunteerPlaceSearchHint => 'Address, landmark, or city';

  @override
  String volunteerMaximumTravel(String km) {
    return 'Maximum travel · $km km';
  }

  @override
  String volunteerKm(String km) {
    return '$km km';
  }

  @override
  String get volunteerCurrentLocationFailed =>
      'Could not get your current location.';

  @override
  String get volunteerUseGpsArea => 'Use my current GPS area';

  @override
  String get volunteerLiveGpsSelected => 'Live GPS area selected';

  @override
  String get volunteerUseGpsAreaInstead => 'Use my current GPS area instead';

  @override
  String get volunteerSave => 'சேமி';

  @override
  String get volunteerAreaMapPinSemantics =>
      'Draggable map pin for your travel area';

  @override
  String get volunteerAreaFallbackNoArea =>
      'Map preview is off. Use the GPS button below to set your area.';

  @override
  String volunteerAreaFallback(String coordinates, String km) {
    return 'Map preview is off. Saved area: $coordinates ($km km radius).';
  }

  @override
  String get volunteerExpandMap => 'Expand map';

  @override
  String get volunteerOpenLocationSettings => 'Open location settings';

  @override
  String get volunteerOpenAppSettings => 'Open app settings';

  @override
  String get exportSectionProfile => 'சுயவிவரம்';

  @override
  String get exportSectionPrivacy => 'Privacy choices';

  @override
  String get exportSectionAvailability => 'Volunteer availability';

  @override
  String get exportSectionCreatedCampaigns => 'Campaigns you created';

  @override
  String get exportSectionSponsorships => 'Sponsorships';

  @override
  String get exportSectionVolunteerWork => 'Volunteer work';

  @override
  String get exportSectionEvidence => 'Evidence you submitted';

  @override
  String get exportSectionPosts => 'Campaign updates you posted';

  @override
  String get exportSectionPayouts => 'Test payout simulations';

  @override
  String get exportSectionRefunds => 'Test refunds';

  @override
  String get exportSectionSecurity => 'Security activity';

  @override
  String exportFieldRole(String value) {
    return 'Role: $value';
  }

  @override
  String exportFieldCity(String value) {
    return 'City: $value';
  }

  @override
  String exportFieldContactPhone(String value) {
    return 'Contact phone: $value';
  }

  @override
  String exportFieldOrganization(String value) {
    return 'Organization: $value';
  }

  @override
  String exportFieldInterests(String value) {
    return 'Interests: $value';
  }

  @override
  String exportFieldSkills(String value) {
    return 'Skills: $value';
  }

  @override
  String exportConsentAccepted(String date) {
    return 'Consent accepted $date';
  }

  @override
  String exportFieldLocation(String value) {
    return 'Location: $value';
  }

  @override
  String exportFieldAiProcessing(String value) {
    return 'AI processing: $value';
  }

  @override
  String exportFieldEvidenceSharing(String value) {
    return 'Evidence sharing: $value';
  }

  @override
  String exportFieldPrivacyPolicy(String value) {
    return 'Privacy policy: $value';
  }

  @override
  String exportFieldTerms(String value) {
    return 'Terms: $value';
  }

  @override
  String exportFieldAvailable(String value) {
    return 'Available: $value';
  }

  @override
  String exportFieldAvailableToday(String value) {
    return 'Available today: $value';
  }

  @override
  String exportFieldTravelRadius(String value) {
    return 'Travel radius: $value km';
  }

  @override
  String exportFieldDays(String value) {
    return 'Days: $value';
  }

  @override
  String exportFieldUpdated(String value) {
    return 'Updated: $value';
  }

  @override
  String exportFieldStarts(String value) {
    return 'Starts: $value';
  }

  @override
  String exportFieldStatus(String value) {
    return 'Status: $value';
  }

  @override
  String exportFieldFundingGoal(String value) {
    return 'Funding goal: INR $value';
  }

  @override
  String exportFieldDescription(String value) {
    return 'Description: $value';
  }

  @override
  String exportFieldAmount(String value) {
    return 'Amount: INR $value';
  }

  @override
  String exportFieldPaymentStatus(String value) {
    return 'Payment status: $value';
  }

  @override
  String exportFieldDate(String value) {
    return 'Date: $value';
  }

  @override
  String exportFieldMessage(String value) {
    return 'Message: $value';
  }

  @override
  String exportFieldJoined(String value) {
    return 'Joined: $value';
  }

  @override
  String exportFieldCheckedIn(String value) {
    return 'Checked in: $value';
  }

  @override
  String exportFieldCompleted(String value) {
    return 'Completed: $value';
  }

  @override
  String exportFieldSubmitted(String value) {
    return 'Submitted: $value';
  }

  @override
  String exportFieldYourNote(String value) {
    return 'Your note: $value';
  }

  @override
  String exportFieldConfirmedSummary(String value) {
    return 'Confirmed summary: $value';
  }

  @override
  String exportFieldLocationCheck(String value) {
    return 'Location check: $value';
  }

  @override
  String exportFieldPosted(String value) {
    return 'Posted: $value';
  }

  @override
  String exportFieldSimulated(String value) {
    return 'Simulated: $value';
  }

  @override
  String exportFieldRecorded(String value) {
    return 'Recorded: $value';
  }

  @override
  String exportFieldWhen(String value) {
    return 'When: $value';
  }

  @override
  String exportFieldResult(String value) {
    return 'Result: $value';
  }

  @override
  String exportInrAmount(String value) {
    return 'INR $value';
  }

  @override
  String get exportNoBankTransfer => 'No bank transfer was made.';

  @override
  String get exportEventPaymentStarted => 'Payment started';

  @override
  String get exportEventPaymentVerified => 'Payment verified';

  @override
  String get exportEventLocationCheck => 'Location check';

  @override
  String get exportEventEvidenceSubmitted => 'Evidence submitted';

  @override
  String get exportEventConsentAccepted => 'Privacy choices accepted';

  @override
  String get exportEventDeletionRequested => 'Account deletion requested';

  @override
  String exportPdfFooter(int page, int pages) {
    return 'FieldNote account report  •  Page $page of $pages';
  }

  @override
  String get exportPdfTitle => 'My FieldNote data';

  @override
  String exportPdfPrepared(String time) {
    return 'Prepared $time';
  }

  @override
  String get exportPdfPhotosNotice =>
      'Private photographs are not embedded in this report.';

  @override
  String get manualPayoutFunds => 'Campaign funds';

  @override
  String get manualPayoutRequest => 'Request payout';

  @override
  String get manualPayoutRequestNotice =>
      'Request the full eligible balance. Operations verify settlement and your payee details outside the app before transferring funds. Agreed fees may reduce the final amount. Submitting a request does not send money.';

  @override
  String get manualPayoutRequested => 'Requested';

  @override
  String get manualPayoutProcessing => 'Processing';

  @override
  String get manualPayoutPaid => 'Paid out';

  @override
  String get manualPayoutRejected => 'Rejected';

  @override
  String get manualPayoutRefresh => 'Refresh payout records';

  @override
  String get manualPayoutEligible => 'Eligible live funding';

  @override
  String get manualPayoutAvailable => 'Available to request';

  @override
  String get manualPayoutReserved => 'Reserved for requests';

  @override
  String get manualPayoutLiveRequired =>
      'Real requests require Razorpay Live keys. Test and unclassified legacy payments cannot fund real payouts.';

  @override
  String get manualPayoutCompletionRequired =>
      'Payouts unlock after campaign completion.';

  @override
  String get manualPayoutHistory => 'Payout request history';

  @override
  String get manualPayoutGross => 'Gross amount';

  @override
  String get manualPayoutNet => 'Bank transfer amount';

  @override
  String get manualPayoutDeductions => 'Agreed deductions';

  @override
  String get manualPayoutBankReference => 'Bank transfer reference (UTR)';

  @override
  String get manualPayoutOperations => 'Payout operations';

  @override
  String get manualPayoutApprove => 'Approve for transfer';

  @override
  String get manualPayoutReject => 'Reject request';

  @override
  String get manualPayoutReviewNotice =>
      'Approve only after matching payments have settled into the business bank account and the creator payee has been verified. Enter opaque evidence references, not bank account numbers or KYC documents. Approval reserves funds; it does not transfer them.';

  @override
  String get manualPayoutSettlementReference =>
      'Settlement verification reference';

  @override
  String get manualPayoutPayeeReference => 'Payee verification reference';

  @override
  String get manualPayoutDeductionInput =>
      'Agreed deductions in INR (e.g. 10.50)';

  @override
  String get manualPayoutInvalidAmount =>
      'Enter a valid amount smaller than the requested amount.';

  @override
  String get manualPayoutReviewNote =>
      'Creator-visible review note and fee explanation';

  @override
  String get manualPayoutRequired =>
      'Enter at least 3 characters (references: maximum 120).';

  @override
  String get manualPayoutRecordPaid => 'Record completed transfer';

  @override
  String get manualPayoutPaidNotice =>
      'Confirm the bank transfer succeeded for the approved net amount, then record its reference. This action records an external transfer; it does not initiate one. Keep the request processing if the bank outcome is uncertain.';

  @override
  String get manualPayoutOperationsNotice =>
      'Restricted operations queue. Verify settlement and payee details, transfer the approved amount through your bank, then record its reference. Never record Test Mode funds as real transfers.';

  @override
  String get manualPayoutEmpty => 'No payout requests yet.';

  @override
  String get manualPayoutCampaign => 'Campaign';

  @override
  String get manualPayoutCreator => 'Creator account ID';

  @override
  String get manualPayoutLoadMore => 'Load more requests';

  @override
  String get impactReportTitle => 'Campaign impact report';

  @override
  String get impactReportRefresh => 'Refresh report';

  @override
  String get impactReportLoadFailed =>
      'Could not load the campaign report. Try again.';

  @override
  String get impactReportExportFailed =>
      'Could not save or share the report. Try again.';

  @override
  String get impactReportStarts => 'Starts';

  @override
  String get impactReportEnds => 'Ends';

  @override
  String get impactReportRetrieved => 'Retrieved';

  @override
  String get impactReportNetFunding => 'Net credited funding';

  @override
  String get impactReportGoal => 'Funding goal';

  @override
  String get impactReportRefunds => 'Processed refunds';

  @override
  String get impactReportParticipants => 'Active participants';

  @override
  String get impactReportSubmitted => 'Submitted contributions';

  @override
  String get impactReportApproved => 'Sponsor-approved contributions';

  @override
  String get impactReportPending => 'Awaiting review';

  @override
  String get impactReportChanges => 'Changes requested';

  @override
  String get impactReportRejected => 'Rejected';

  @override
  String get impactReportDemoCount => 'Demo GPS evidence';

  @override
  String get impactReportEmpty => 'No sponsor-approved contributions yet.';

  @override
  String get impactReportEvidence => 'Evidence';

  @override
  String get impactReportSubmittedAt => 'Submitted';

  @override
  String get impactReportReviewedAt => 'Reviewed';

  @override
  String get impactReportNotRecorded => 'Not recorded';

  @override
  String get impactReportDemoGps => 'Demo GPS — simulated location';

  @override
  String get impactReportLiveGps => 'Live GPS submission';

  @override
  String get impactReportAiSummary => 'AI-assisted summary';

  @override
  String get impactReportManualSummary => 'Manual summary';

  @override
  String get impactReportEvidenceNotice =>
      'Contributions are volunteer-reported and sponsor-approved, not independently verified outcomes. Photos and location checks do not establish every claimed quantity. No environmental or carbon totals are inferred.';

  @override
  String get impactReportSharingNotice =>
      'Later reviews and refunds can change the next report. Private photos and exact coordinates are omitted. Review summary text before sharing outside the team. PDF labels are in English.';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsUnreadOnly => 'Unread only';

  @override
  String get notificationsMarkAllRead => 'Mark all read';

  @override
  String get notificationsEnablePush => 'Enable device alerts';

  @override
  String get notificationsPushEnabled => 'Device alerts enabled.';

  @override
  String get notificationsPushUnavailable =>
      'Device alerts are unavailable here. Your inbox still works.';

  @override
  String get notificationsLoadFailed =>
      'Could not load notifications. Check your connection and try again.';

  @override
  String get notificationsActionFailed =>
      'Could not complete this action. Check notification permissions and try again.';

  @override
  String get notificationsRetry => 'Retry';

  @override
  String get notificationsClose => 'Close';

  @override
  String get notificationsViewActivity => 'View activity';

  @override
  String get notificationsEmpty => 'Your updates will appear here.';

  @override
  String get notificationsAllCaughtUp => 'You have no unread notifications.';

  @override
  String get notificationsLoadMore => 'Load more';

  @override
  String get notificationsNewUpdate => 'You have a new FieldNote update.';

  @override
  String get notificationsOpen => 'Open';

  @override
  String get notificationsUnavailable =>
      'This update is no longer available for this account.';

  @override
  String get campaignDiscussionTitle => 'பிரச்சார கலந்துரையாடல்';

  @override
  String get campaignDiscussionDescription =>
      'பிரச்சார அமைப்பாளரும் இணைந்த தன்னார்வலர்களும் பகிரும் ஒரே அறை. கேள்விகள் கேட்டு குழுவினருடன் பேசுங்கள்.';

  @override
  String get campaignDiscussionEmpty =>
      'கலந்துரையாடலைத் தொடங்குங்கள். இந்தப் பிரச்சாரத்தின் அனைவரும் பதிலளிக்கலாம்.';

  @override
  String get campaignDiscussionReadOnly =>
      'இந்தப் பிரச்சாரம் முடிவடைந்தது. கலந்துரையாடலைப் படிக்கலாம்.';

  @override
  String get campaignDiscussionNoAccess =>
      'இந்தப் பிரச்சார கலந்துரையாடலுக்கான அணுகல் இனி உங்களுக்கு இல்லை.';

  @override
  String get campaignDiscussionReconnecting => 'கலந்துரையாடலுடன் இணைகிறது…';

  @override
  String get campaignDiscussionOlder => 'முந்தைய செய்திகளைப் பார்க்கவும்';

  @override
  String get campaignDiscussionYou => 'நீங்கள்';

  @override
  String get campaignDiscussionCampaigner => 'பிரச்சார அமைப்பாளர்';

  @override
  String get campaignDiscussionVolunteer => 'தன்னார்வலர்';

  @override
  String get campaignDiscussionCompose =>
      'கேள்வி கேளுங்கள் அல்லது செய்தி எழுதுங்கள்';

  @override
  String get campaignDiscussionSend => 'செய்தி அனுப்பு';

  @override
  String get campaignDiscussionTeam => 'பிரச்சார குழு';

  @override
  String get campaignDiscussionInfo => 'இந்தக் கலந்துரையாடல் பற்றி';

  @override
  String get campaignDiscussionToday => 'இன்று';

  @override
  String get campaignDiscussionYesterday => 'நேற்று';

  @override
  String get campaignDiscussionArchived => 'படிக்க மட்டும்';

  @override
  String get campaignDiscussionConnected => 'இணைக்கப்பட்டது';

  @override
  String get campaignDiscussionNewMessages => 'புதிய செய்திகள்';

  @override
  String get campaignDiscussionMessageHint => 'குழுவிற்கு செய்தி எழுதுங்கள்…';

  @override
  String get campaignDiscussionConnecting => 'இணைகிறது…';

  @override
  String get campaignDiscussionUnavailable => 'கிடைக்கவில்லை';

  @override
  String get notificationsCaughtUpTitle =>
      'அனைத்து அறிவிப்புகளையும் படித்துவிட்டீர்கள்';

  @override
  String notificationsUnreadCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'படிக்காத $count அறிவிப்புகள்',
      one: 'படிக்காத 1 அறிவிப்பு',
    );
    return '$_temp0';
  }

  @override
  String get notificationsSubtitle =>
      'பணித்திட்டச் செயல்பாடுகள், அழைப்புகள் மற்றும் அறிவிப்புகள்.';

  @override
  String get notificationsAll => 'அனைத்தும்';

  @override
  String get notificationsUnread => 'படிக்காதவை';

  @override
  String get notificationsStayUpdated => 'தொடர்ந்து தகவல் பெறுங்கள்';

  @override
  String get notificationsEnablePushDescription =>
      'FieldNote மூடியிருக்கும்போதும் அறிவிப்புகளைப் பெற சாதன அறிவிப்புகளை இயக்கவும்.';

  @override
  String get notificationsConnectionTitle => 'புதுப்பிக்க முடியவில்லை';

  @override
  String get notificationsEmptyTitle => 'இன்னும் அறிவிப்புகள் இல்லை';

  @override
  String get notificationsToday => 'இன்று';

  @override
  String get notificationsYesterday => 'நேற்று';

  @override
  String get notificationsCategoryInvitation => 'அழைப்பு';

  @override
  String get notificationsCategoryTeam => 'குழுச் செயல்பாடு';

  @override
  String get notificationsCategoryCheckIn => 'வருகைப் பதிவு';

  @override
  String get notificationsCategoryPayment => 'கட்டணங்கள்';

  @override
  String get notificationsCategoryEvidence => 'சான்று';

  @override
  String get notificationsCategoryCampaign => 'பணித்திட்ட அறிவிப்பு';

  @override
  String get navSchedule => 'நேரம்';

  @override
  String campaignChatUnread(int count) {
    return '$count படிக்காத செய்திகள்';
  }
}
