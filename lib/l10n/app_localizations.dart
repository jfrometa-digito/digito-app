import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('es'),
  ];

  /// No description provided for @dashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'SignBot Assistant'**
  String get dashboardTitle;

  /// No description provided for @dashboardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your document signing companion'**
  String get dashboardSubtitle;

  /// No description provided for @dashboardPoweredBy.
  ///
  /// In en, this message translates to:
  /// **'Powered by DocSecure'**
  String get dashboardPoweredBy;

  /// No description provided for @tabDrafting.
  ///
  /// In en, this message translates to:
  /// **'Drafting'**
  String get tabDrafting;

  /// No description provided for @tabSigning.
  ///
  /// In en, this message translates to:
  /// **'Signing'**
  String get tabSigning;

  /// No description provided for @tabArchiving.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get tabArchiving;

  /// No description provided for @cardSelfSignTitle.
  ///
  /// In en, this message translates to:
  /// **'Self-Sign Document'**
  String get cardSelfSignTitle;

  /// No description provided for @cardSelfSignSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign a document just for yourself'**
  String get cardSelfSignSubtitle;

  /// No description provided for @cardOneOnOneTitle.
  ///
  /// In en, this message translates to:
  /// **'1-on-1 Signing'**
  String get cardOneOnOneTitle;

  /// No description provided for @cardOneOnOneSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Send to one other person'**
  String get cardOneOnOneSubtitle;

  /// No description provided for @cardMultiPartyTitle.
  ///
  /// In en, this message translates to:
  /// **'Multiparty Flow'**
  String get cardMultiPartyTitle;

  /// No description provided for @cardMultiPartySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sequential signing for teams'**
  String get cardMultiPartySubtitle;

  /// No description provided for @promptInputPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Ask me to draft a contract..'**
  String get promptInputPlaceholder;

  /// No description provided for @menuProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get menuProfile;

  /// No description provided for @menuToggleTheme.
  ///
  /// In en, this message translates to:
  /// **'Toggle Theme'**
  String get menuToggleTheme;

  /// No description provided for @menuLogOut.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get menuLogOut;

  /// No description provided for @menuLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get menuLanguage;

  /// No description provided for @chatGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hello! I can help you create a new signature request.'**
  String get chatGreeting;

  /// No description provided for @chatWelcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back! 👋 How can I assist you with your documents today?'**
  String get chatWelcomeBack;

  /// No description provided for @chatResumeGreeting.
  ///
  /// In en, this message translates to:
  /// **'Welcome back! I\'ve loaded your draft for {title}.'**
  String chatResumeGreeting(String title);

  /// No description provided for @chatRequestType.
  ///
  /// In en, this message translates to:
  /// **'I need to {type} a new contract.'**
  String chatRequestType(String type);

  /// No description provided for @chatUploadPrompt.
  ///
  /// In en, this message translates to:
  /// **'Got it. Let\'s get that signed. Please upload the document you want to work on. I support PDF and DOCX files.'**
  String get chatUploadPrompt;

  /// No description provided for @chatStartedRequest.
  ///
  /// In en, this message translates to:
  /// **'I\'ve started a **{type}** request for you. Please upload the PDF document you\'d like to use.'**
  String chatStartedRequest(String type);

  /// No description provided for @chatFileUploaded.
  ///
  /// In en, this message translates to:
  /// **'File uploaded'**
  String get chatFileUploaded;

  /// No description provided for @chatRecipientsPrompt.
  ///
  /// In en, this message translates to:
  /// **'Great! I\'ve prepared the document. Who needs to sign it? Please add their details below.'**
  String get chatRecipientsPrompt;

  /// No description provided for @chatManageRecipients.
  ///
  /// In en, this message translates to:
  /// **'Please manage the recipients for this request.'**
  String get chatManageRecipients;

  /// No description provided for @chatRecipientsSet.
  ///
  /// In en, this message translates to:
  /// **'Recipients are set.'**
  String get chatRecipientsSet;

  /// No description provided for @chatSummaryPrompt.
  ///
  /// In en, this message translates to:
  /// **'Perfect. Here is the summary of your request. If everything looks good, you can send it.'**
  String get chatSummaryPrompt;

  /// No description provided for @chatSendRequest.
  ///
  /// In en, this message translates to:
  /// **'Send Request'**
  String get chatSendRequest;

  /// No description provided for @chatLinkGenerated.
  ///
  /// In en, this message translates to:
  /// **'Great job! I\'ve generated the signing link for \'{title}\'.'**
  String chatLinkGenerated(String title);

  /// No description provided for @chatSendErrorLink.
  ///
  /// In en, this message translates to:
  /// **'Your request has been sent, but I could not generate a link.'**
  String get chatSendErrorLink;

  /// No description provided for @errorLaunchUrl.
  ///
  /// In en, this message translates to:
  /// **'Could not launch signing URL'**
  String get errorLaunchUrl;

  /// No description provided for @uploadDocumentTitle.
  ///
  /// In en, this message translates to:
  /// **'UPLOAD DOCUMENT'**
  String get uploadDocumentTitle;

  /// No description provided for @uploadBrowse.
  ///
  /// In en, this message translates to:
  /// **'Tap to browse'**
  String get uploadBrowse;

  /// No description provided for @uploadDrag.
  ///
  /// In en, this message translates to:
  /// **'or drag file here'**
  String get uploadDrag;

  /// No description provided for @btnNextStep.
  ///
  /// In en, this message translates to:
  /// **'Next Step'**
  String get btnNextStep;

  /// No description provided for @sourceFiles.
  ///
  /// In en, this message translates to:
  /// **'Files'**
  String get sourceFiles;

  /// No description provided for @sourceScan.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get sourceScan;

  /// No description provided for @sourceDrive.
  ///
  /// In en, this message translates to:
  /// **'Drive'**
  String get sourceDrive;

  /// No description provided for @recipientsTitle.
  ///
  /// In en, this message translates to:
  /// **'CURRENT RECIPIENTS'**
  String get recipientsTitle;

  /// No description provided for @recipientsAdded.
  ///
  /// In en, this message translates to:
  /// **'Added'**
  String get recipientsAdded;

  /// No description provided for @recipientsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No recipients added yet.'**
  String get recipientsEmpty;

  /// No description provided for @recipientsAddNew.
  ///
  /// In en, this message translates to:
  /// **'Add New Person'**
  String get recipientsAddNew;

  /// No description provided for @labelFullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get labelFullName;

  /// No description provided for @labelEmail.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get labelEmail;

  /// No description provided for @btnAddToList.
  ///
  /// In en, this message translates to:
  /// **'Add to List'**
  String get btnAddToList;

  /// No description provided for @btnAddMyself.
  ///
  /// In en, this message translates to:
  /// **'Add myself'**
  String get btnAddMyself;

  /// No description provided for @btnContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get btnContinue;

  /// No description provided for @errorInvalidRecipient.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid name and email'**
  String get errorInvalidRecipient;

  /// No description provided for @errorFillAllFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill all recipient fields'**
  String get errorFillAllFields;

  /// No description provided for @errorSelfSignCount.
  ///
  /// In en, this message translates to:
  /// **'Self signing must have exactly 1 signer.'**
  String get errorSelfSignCount;

  /// No description provided for @errorOneOnOneCount.
  ///
  /// In en, this message translates to:
  /// **'1-on-1 requires exactly 2 signers.'**
  String get errorOneOnOneCount;

  /// No description provided for @summaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Draft Summary'**
  String get summaryTitle;

  /// No description provided for @summaryFile.
  ///
  /// In en, this message translates to:
  /// **'File'**
  String get summaryFile;

  /// No description provided for @summaryRecipients.
  ///
  /// In en, this message translates to:
  /// **'Recipients'**
  String get summaryRecipients;

  /// No description provided for @summaryStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get summaryStatus;

  /// No description provided for @summarySignUrl.
  ///
  /// In en, this message translates to:
  /// **'Sign URL'**
  String get summarySignUrl;

  /// No description provided for @btnSendForSigning.
  ///
  /// In en, this message translates to:
  /// **'Send for signing'**
  String get btnSendForSigning;

  /// No description provided for @btnEditFields.
  ///
  /// In en, this message translates to:
  /// **'Edit Fields'**
  String get btnEditFields;

  /// No description provided for @btnAddFields.
  ///
  /// In en, this message translates to:
  /// **'Add Fields'**
  String get btnAddFields;

  /// No description provided for @signingLinkTitle.
  ///
  /// In en, this message translates to:
  /// **'READY TO SIGN'**
  String get signingLinkTitle;

  /// No description provided for @signingLinkGenerated.
  ///
  /// In en, this message translates to:
  /// **'Signing Link Generated'**
  String get signingLinkGenerated;

  /// No description provided for @signingLinkShare.
  ///
  /// In en, this message translates to:
  /// **'Share this link with'**
  String get signingLinkShare;

  /// No description provided for @btnCopyLink.
  ///
  /// In en, this message translates to:
  /// **'Copy Link'**
  String get btnCopyLink;

  /// No description provided for @toastLinkCopied.
  ///
  /// In en, this message translates to:
  /// **'Link copied to clipboard'**
  String get toastLinkCopied;

  /// No description provided for @btnSendEmail.
  ///
  /// In en, this message translates to:
  /// **'Send via Email'**
  String get btnSendEmail;

  /// No description provided for @btnCloseStartNew.
  ///
  /// In en, this message translates to:
  /// **'Close & Start New'**
  String get btnCloseStartNew;

  /// No description provided for @flowCurrent.
  ///
  /// In en, this message translates to:
  /// **'Current Flow'**
  String get flowCurrent;

  /// No description provided for @checkboxAmSigner.
  ///
  /// In en, this message translates to:
  /// **'I am one of the signers'**
  String get checkboxAmSigner;

  /// No description provided for @checkboxAutoFill.
  ///
  /// In en, this message translates to:
  /// **'Auto-fill my account details'**
  String get checkboxAutoFill;

  /// No description provided for @checkboxLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading profile...'**
  String get checkboxLoading;

  /// No description provided for @btnAddAnother.
  ///
  /// In en, this message translates to:
  /// **'Add Another Recipient'**
  String get btnAddAnother;

  /// No description provided for @btnNextPlaceFields.
  ///
  /// In en, this message translates to:
  /// **'Next: Place Fields'**
  String get btnNextPlaceFields;

  /// No description provided for @labelYourInfo.
  ///
  /// In en, this message translates to:
  /// **'Your Information'**
  String get labelYourInfo;

  /// No description provided for @labelRecipientN.
  ///
  /// In en, this message translates to:
  /// **'Recipient {n}'**
  String labelRecipientN(int n);
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
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
