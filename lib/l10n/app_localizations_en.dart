// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get dashboardTitle => 'SignBot Assistant';

  @override
  String get dashboardSubtitle => 'Your document signing companion';

  @override
  String get dashboardPoweredBy => 'Powered by DocSecure';

  @override
  String get onboardingTitle => 'Let\'s Get Started!';

  @override
  String get onboardingStep1 => 'Verify Identity';

  @override
  String get onboardingStep2 => 'Sign Contracts';

  @override
  String get onboardingStep3 => 'Get Digito ID';

  @override
  String get onboardingStep4 => 'Sign Document';

  @override
  String get onboardingComplete => 'You\'re all set to sign!';

  @override
  String get tabHome => 'Home';

  @override
  String get tabSigning => 'Signing';

  @override
  String get tabArchiving => 'History';

  @override
  String get cardSelfSignTitle => 'Self-Sign Document';

  @override
  String get cardSelfSignSubtitle => 'Sign a document just for yourself';

  @override
  String get cardOneOnOneTitle => '1-on-1 Signing';

  @override
  String get cardOneOnOneSubtitle => 'Send to one other person';

  @override
  String get cardMultiPartyTitle => 'Multiparty Flow';

  @override
  String get cardMultiPartySubtitle => 'Sequential signing for teams';

  @override
  String get promptInputPlaceholder => 'Ask me to draft a contract..';

  @override
  String get menuProfile => 'Profile';

  @override
  String get menuToggleTheme => 'Toggle Theme';

  @override
  String get menuLogOut => 'Log Out';

  @override
  String get menuLanguage => 'Language';

  @override
  String get chatGreeting =>
      'Hello! I can help you create a new signature request.';

  @override
  String get chatWelcomeBack =>
      'Welcome back! 👋 How can I assist you with your documents today?';

  @override
  String chatResumeGreeting(String title) {
    return 'Welcome back! I\'ve loaded your draft for $title.';
  }

  @override
  String chatRequestType(String type) {
    return 'I need to $type a new contract.';
  }

  @override
  String get chatUploadPrompt =>
      'Got it. Let\'s get that signed. Please upload the document you want to work on. I support PDF and DOCX files.';

  @override
  String chatStartedRequest(String type) {
    return 'I\'ve started a **$type** request for you. Please upload the PDF document you\'d like to use.';
  }

  @override
  String get chatFileUploaded => 'File uploaded';

  @override
  String get chatRecipientsPrompt =>
      'Great! I\'ve prepared the document. Who needs to sign it? Please add their details below.';

  @override
  String get chatManageRecipients =>
      'Please manage the recipients for this request.';

  @override
  String get chatRecipientsSet => 'Recipients are set.';

  @override
  String get chatSummaryPrompt =>
      'Perfect. Here is the summary of your request. If everything looks good, you can send it.';

  @override
  String get chatSendRequest => 'Send Request';

  @override
  String chatLinkGenerated(String title) {
    return 'Great job! I\'ve generated the signing link for \'$title\'.';
  }

  @override
  String get chatSendErrorLink =>
      'Your request has been sent, but I could not generate a link.';

  @override
  String get errorLaunchUrl => 'Could not launch signing URL';

  @override
  String get uploadDocumentTitle => 'UPLOAD DOCUMENT';

  @override
  String get uploadBrowse => 'Tap to browse';

  @override
  String get uploadDrag => 'or drag file here';

  @override
  String get btnNextStep => 'Next Step';

  @override
  String get sourceFiles => 'Files';

  @override
  String get sourceScan => 'Scan';

  @override
  String get sourceDrive => 'Drive';

  @override
  String get recipientsTitle => 'CURRENT RECIPIENTS';

  @override
  String get recipientsAdded => 'Added';

  @override
  String get recipientsEmpty => 'No recipients added yet.';

  @override
  String get recipientsAddNew => 'Add New Person';

  @override
  String get labelFullName => 'Full Name';

  @override
  String get labelEmail => 'Email Address';

  @override
  String get btnAddToList => 'Add to List';

  @override
  String get btnAddMyself => 'Add myself';

  @override
  String get btnContinue => 'Continue';

  @override
  String get errorInvalidRecipient => 'Enter a valid name and email';

  @override
  String get errorFillAllFields => 'Please fill all recipient fields';

  @override
  String get errorSelfSignCount => 'Self signing must have exactly 1 signer.';

  @override
  String get errorOneOnOneCount => '1-on-1 requires exactly 2 signers.';

  @override
  String get summaryTitle => 'Draft Summary';

  @override
  String get summaryFile => 'File';

  @override
  String get summaryRecipients => 'Recipients';

  @override
  String get summaryStatus => 'Status';

  @override
  String get summarySignUrl => 'Sign URL';

  @override
  String get btnSendForSigning => 'Send for signing';

  @override
  String get btnEditFields => 'Edit Fields';

  @override
  String get btnAddFields => 'Add Fields';

  @override
  String get signingLinkTitle => 'READY TO SIGN';

  @override
  String get signingLinkGenerated => 'Signing Link Generated';

  @override
  String get signingLinkShare => 'Share this link with';

  @override
  String get btnCopyLink => 'Copy Link';

  @override
  String get toastLinkCopied => 'Link copied to clipboard';

  @override
  String get btnSendEmail => 'Send via Email';

  @override
  String get btnCloseStartNew => 'Close & Start New';

  @override
  String get flowCurrent => 'Current Flow';

  @override
  String get checkboxAmSigner => 'I am one of the signers';

  @override
  String get checkboxAutoFill => 'Auto-fill my account details';

  @override
  String get checkboxLoading => 'Loading profile...';

  @override
  String get btnAddAnother => 'Add Another Recipient';

  @override
  String get btnNextPlaceFields => 'Next: Place Fields';

  @override
  String get labelYourInfo => 'Your Information';

  @override
  String labelRecipientN(int n) {
    return 'Recipient $n';
  }
}
