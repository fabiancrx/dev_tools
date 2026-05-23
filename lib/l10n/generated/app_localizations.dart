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
/// import 'generated/app_localizations.dart';
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
    Locale('es'),
  ];

  /// Search field hint text
  ///
  /// In en, this message translates to:
  /// **'Search...'**
  String get search;

  /// Settings navigation item label
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Input text field label
  ///
  /// In en, this message translates to:
  /// **'Input'**
  String get input;

  /// Output text field label
  ///
  /// In en, this message translates to:
  /// **'Output'**
  String get output;

  /// Sample button label
  ///
  /// In en, this message translates to:
  /// **'Sample'**
  String get sample;

  /// Clear action label
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// Format button label in JSON formatter
  ///
  /// In en, this message translates to:
  /// **'Format'**
  String get format;

  /// Load image button label
  ///
  /// In en, this message translates to:
  /// **'Load Image'**
  String get loadImage;

  /// Load file tooltip
  ///
  /// In en, this message translates to:
  /// **'Load File'**
  String get loadFile;

  /// Save button tooltip
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Encoding selector tooltip in Base64 converter
  ///
  /// In en, this message translates to:
  /// **'Encoding'**
  String get encoding;

  /// Copy to clipboard context menu item
  ///
  /// In en, this message translates to:
  /// **'Copy to clipboard'**
  String get copyToClipboard;

  /// Snackbar message when image is saved successfully
  ///
  /// In en, this message translates to:
  /// **'Image saved'**
  String get imageSaved;

  /// File save dialog title
  ///
  /// In en, this message translates to:
  /// **'Please select an output file:'**
  String get selectOutputFile;

  /// Tooltip for paste base64 button in image converter
  ///
  /// In en, this message translates to:
  /// **'Paste base 64 encoded image from clipboard'**
  String get pasteBase64FromClipboard;

  /// Tooltip for copy base64 button in image converter
  ///
  /// In en, this message translates to:
  /// **'Copy base 64 encoded image to clipboard'**
  String get copyBase64ToClipboard;

  /// Tooltip for paste image button in image converter
  ///
  /// In en, this message translates to:
  /// **'Paste image from clipboard'**
  String get pasteImageFromClipboard;

  /// Tooltip for copy image button in image converter
  ///
  /// In en, this message translates to:
  /// **'Copy image to clipboard'**
  String get copyImageToClipboard;

  /// JWT token input field label
  ///
  /// In en, this message translates to:
  /// **'JWT Token'**
  String get jwtTokenLabel;

  /// Tooltip for JWT info button
  ///
  /// In en, this message translates to:
  /// **'What is a Json Web token?'**
  String get whatIsJwt;

  /// JWT issued date label
  ///
  /// In en, this message translates to:
  /// **'Issued on: {date}'**
  String issuedOn(String date);

  /// JWT expiration label when token is already expired
  ///
  /// In en, this message translates to:
  /// **'Expired on: {date}'**
  String expiredOn(String date);

  /// JWT expiration label when token is still valid
  ///
  /// In en, this message translates to:
  /// **'Expires on: {date} in {remaining}'**
  String expiresOn(String date, String remaining);

  /// JWT payload section title
  ///
  /// In en, this message translates to:
  /// **'Payload'**
  String get jwtPayload;

  /// JWT header section title
  ///
  /// In en, this message translates to:
  /// **'Header'**
  String get jwtHeader;

  /// JWT iss claim tooltip description
  ///
  /// In en, this message translates to:
  /// **'Issuer Claim\nIdentifies the principal that issued the JWT. The processing of this claim is generally application specific.'**
  String get jwtClaimIss;

  /// JWT sub claim tooltip description
  ///
  /// In en, this message translates to:
  /// **'Subject Claim\nIdentifies the principal that is the subject of the JWT. The claims in a JWT are normally statements about the subject. The subject value MUST either be scoped to be locally unique in the context of the issuer or be globally unique. The processing of this claim is generally application specific.'**
  String get jwtClaimSub;

  /// JWT exp claim tooltip description
  ///
  /// In en, this message translates to:
  /// **'Expiration time claim\nIdentifies the expiration time on or after which the JWT MUST NOT be accepted for processing. The processing of the \'exp\' claim requires that the current date/time MUST be before the expiration date/time listed in the \'exp\' claim.'**
  String get jwtClaimExp;

  /// JWT nbf claim tooltip description
  ///
  /// In en, this message translates to:
  /// **'Not before claim\nIdentifies the time before which the JWT MUST NOT be accepted for processing. The processing of the \'nbf\' claim requires that the current date/time MUST be after or equal to the not-before date/time listed in the \'nbf\' claim.'**
  String get jwtClaimNbf;

  /// JWT iat claim tooltip description
  ///
  /// In en, this message translates to:
  /// **'Issued at claim\nIdentifies the time at which the JWT was issued. This claim can be used to determine the age of the JWT.'**
  String get jwtClaimIat;

  /// JWT jti claim tooltip description
  ///
  /// In en, this message translates to:
  /// **'JWT ID claim\nProvides a unique identifier for the JWT. The identifier value MUST be assigned in a manner that ensures that there is a negligible probability that the same value will be accidentally assigned to a different data object; if the application uses multiple issuers, collisions MUST be prevented among values produced by different issuers as well.'**
  String get jwtClaimJti;

  /// JWT aud claim tooltip description
  ///
  /// In en, this message translates to:
  /// **'Audience claim\nIdentifies the recipients that the JWT is intended for. Each principal intended to process the JWT MUST identify itself with a value in the audience claim.'**
  String get jwtClaimAud;

  /// JWT decode tab label
  ///
  /// In en, this message translates to:
  /// **'Decode'**
  String get jwtDecode;

  /// JWT encode tab label
  ///
  /// In en, this message translates to:
  /// **'Encode'**
  String get jwtEncode;

  /// Status badge when token is structurally valid
  ///
  /// In en, this message translates to:
  /// **'Valid JWT'**
  String get jwtValid;

  /// Status badge when token is malformed
  ///
  /// In en, this message translates to:
  /// **'Invalid token'**
  String get jwtInvalid;

  /// Status badge when signature check passes
  ///
  /// In en, this message translates to:
  /// **'Signature verified'**
  String get jwtSignatureVerified;

  /// Status badge when signature check fails
  ///
  /// In en, this message translates to:
  /// **'Invalid signature'**
  String get jwtSignatureInvalid;

  /// Secret key input field label
  ///
  /// In en, this message translates to:
  /// **'Secret'**
  String get jwtSecret;

  /// Checkbox label for base64-encoded secret
  ///
  /// In en, this message translates to:
  /// **'Base64 encoded'**
  String get jwtSecretBase64;

  /// Signature verification section title
  ///
  /// In en, this message translates to:
  /// **'Verify Signature'**
  String get jwtVerifySignature;

  /// Algorithm dropdown label in encode tab
  ///
  /// In en, this message translates to:
  /// **'Algorithm'**
  String get jwtAlgorithm;

  /// Generated token section title in encode tab
  ///
  /// In en, this message translates to:
  /// **'Generated Token'**
  String get jwtGeneratedToken;

  /// Payload editor label in encode tab
  ///
  /// In en, this message translates to:
  /// **'Payload'**
  String get jwtEncodePayload;

  /// Header editor label in encode tab
  ///
  /// In en, this message translates to:
  /// **'Header'**
  String get jwtEncodeHeader;

  /// Button that copies the decoded token into the encoder tab
  ///
  /// In en, this message translates to:
  /// **'Edit in Encoder'**
  String get jwtEditInEncoder;

  /// JWT nbf claim label
  ///
  /// In en, this message translates to:
  /// **'Not valid before: {date}'**
  String jwtNotValidBefore(String date);

  /// Warning text when nbf is in the future
  ///
  /// In en, this message translates to:
  /// **'Token not yet valid'**
  String get jwtNotYetValid;

  /// Warning banner for alg:none tokens
  ///
  /// In en, this message translates to:
  /// **'This token uses no signature (alg: none) and cannot be trusted.'**
  String get jwtInsecureAlgorithmWarning;

  /// Tooltip for the claims breakdown toggle button
  ///
  /// In en, this message translates to:
  /// **'Claims breakdown'**
  String get jwtClaimsBreakdown;

  /// Tooltip for the show raw JSON toggle button
  ///
  /// In en, this message translates to:
  /// **'Show JSON'**
  String get jwtShowJson;

  /// Hexadecimal number system label
  ///
  /// In en, this message translates to:
  /// **'Hex'**
  String get hex;

  /// Decimal number system label
  ///
  /// In en, this message translates to:
  /// **'Decimal'**
  String get decimal;

  /// Octal number system label
  ///
  /// In en, this message translates to:
  /// **'Octal'**
  String get octal;

  /// Binary number system label
  ///
  /// In en, this message translates to:
  /// **'Binary'**
  String get binary;

  /// Base64 encode mode label
  ///
  /// In en, this message translates to:
  /// **'Encode'**
  String get base64ModeEncode;

  /// Base64 decode mode label
  ///
  /// In en, this message translates to:
  /// **'Decode'**
  String get base64ModeDecode;

  /// JSON escape mode label
  ///
  /// In en, this message translates to:
  /// **'Escape'**
  String get jsonEscapeModeEscape;

  /// JSON unescape mode label
  ///
  /// In en, this message translates to:
  /// **'Unescape'**
  String get jsonEscapeModeUnescape;

  /// Hex to text conversion mode label
  ///
  /// In en, this message translates to:
  /// **'Hex to Text'**
  String get hexTextModeHexToText;

  /// Text to hex conversion mode label
  ///
  /// In en, this message translates to:
  /// **'Text to Hex'**
  String get hexTextModeTextToHex;

  /// JSON minify mode label
  ///
  /// In en, this message translates to:
  /// **'Minify'**
  String get jsonModeMinify;

  /// JSON format with 2-space indent label
  ///
  /// In en, this message translates to:
  /// **'2 Spaces'**
  String get jsonModeTwoSpaces;

  /// JSON format with 4-space indent label
  ///
  /// In en, this message translates to:
  /// **'4 Spaces'**
  String get jsonModeFourSpaces;

  /// JSON format with tab indent label
  ///
  /// In en, this message translates to:
  /// **'Tab'**
  String get jsonModeTab;

  /// Base64 tool name
  ///
  /// In en, this message translates to:
  /// **'BASE 64 encoder/decoder'**
  String get toolBase64Name;

  /// Base64 tool description
  ///
  /// In en, this message translates to:
  /// **'Encode or decode a String as base64'**
  String get toolBase64Description;

  /// JSON formatter tool name
  ///
  /// In en, this message translates to:
  /// **'JSON formatter'**
  String get toolJsonFormatterName;

  /// JSON formatter tool description
  ///
  /// In en, this message translates to:
  /// **'Prettify, minify or just validate a String as JSON'**
  String get toolJsonFormatterDescription;

  /// Base64 image tool name
  ///
  /// In en, this message translates to:
  /// **'BASE 64 Image encoder/decoder'**
  String get toolBase64ImageName;

  /// Base64 image tool description
  ///
  /// In en, this message translates to:
  /// **'Encode or decode an image as base64'**
  String get toolBase64ImageDescription;

  /// Number converter tool name
  ///
  /// In en, this message translates to:
  /// **'Number Converter'**
  String get toolNumberConverterName;

  /// Number converter tool description
  ///
  /// In en, this message translates to:
  /// **'Convert numbers from one base to another'**
  String get toolNumberConverterDescription;

  /// Hex to ASCII tool name
  ///
  /// In en, this message translates to:
  /// **'Hex to ASCII'**
  String get toolHexToAsciiName;

  /// Hex to ASCII tool description
  ///
  /// In en, this message translates to:
  /// **'Hex to ASCII conversion'**
  String get toolHexToAsciiDescription;

  /// JSON escape tool name
  ///
  /// In en, this message translates to:
  /// **'JSON escape/unescape'**
  String get toolJsonEscapeName;

  /// JSON escape tool description
  ///
  /// In en, this message translates to:
  /// **'Escape or unescape a JSON string'**
  String get toolJsonEscapeDescription;

  /// JWT debugger tool name
  ///
  /// In en, this message translates to:
  /// **'JWT Debugger'**
  String get toolJwtDebuggerName;

  /// JWT debugger tool description
  ///
  /// In en, this message translates to:
  /// **'JSON Web Token payload and header debugger'**
  String get toolJwtDebuggerDescription;

  /// URL encoder tool name
  ///
  /// In en, this message translates to:
  /// **'URL Encoder/Decoder'**
  String get toolUrlEncoderName;

  /// URL encoder tool description
  ///
  /// In en, this message translates to:
  /// **'Encode or decode URL components'**
  String get toolUrlEncoderDescription;

  /// Unix timestamp tool name
  ///
  /// In en, this message translates to:
  /// **'Unix Timestamp'**
  String get toolUnixTimestampName;

  /// Unix timestamp tool description
  ///
  /// In en, this message translates to:
  /// **'Convert between Unix timestamps and ISO 8601 dates'**
  String get toolUnixTimestampDescription;

  /// Query string parser tool name
  ///
  /// In en, this message translates to:
  /// **'Query String Parser'**
  String get toolQueryStringName;

  /// Query string parser tool description
  ///
  /// In en, this message translates to:
  /// **'Parse URL query strings into JSON'**
  String get toolQueryStringDescription;

  /// String inspector tool name
  ///
  /// In en, this message translates to:
  /// **'String Inspector'**
  String get toolStringInspectorName;

  /// String inspector tool description
  ///
  /// In en, this message translates to:
  /// **'Analyze strings: characters, bytes, words, lines'**
  String get toolStringInspectorDescription;

  /// UUID generator tool name
  ///
  /// In en, this message translates to:
  /// **'UUID Generator'**
  String get toolUuidGeneratorName;

  /// UUID generator tool description
  ///
  /// In en, this message translates to:
  /// **'Generate UUIDs (v1, v4, v7)'**
  String get toolUuidGeneratorDescription;

  /// Hash generator tool name
  ///
  /// In en, this message translates to:
  /// **'Hash Generator'**
  String get toolHashGeneratorName;

  /// Hash generator tool description
  ///
  /// In en, this message translates to:
  /// **'Generate MD5, SHA-1, SHA-256, SHA-512 and HMAC hashes'**
  String get toolHashGeneratorDescription;

  /// Case converter tool name
  ///
  /// In en, this message translates to:
  /// **'Case Converter'**
  String get toolCaseConverterName;

  /// Case converter tool description
  ///
  /// In en, this message translates to:
  /// **'Convert text between camelCase, snake_case, kebab-case and more'**
  String get toolCaseConverterDescription;

  /// HTTP status codes tool name
  ///
  /// In en, this message translates to:
  /// **'HTTP Status Codes'**
  String get toolHttpStatusName;

  /// HTTP status codes tool description
  ///
  /// In en, this message translates to:
  /// **'Reference for HTTP status codes and their meanings'**
  String get toolHttpStatusDescription;

  /// Cron expression tool name
  ///
  /// In en, this message translates to:
  /// **'Cron Expression'**
  String get toolCronExpressionName;

  /// Cron expression tool description
  ///
  /// In en, this message translates to:
  /// **'Parse cron expressions and preview next run times'**
  String get toolCronExpressionDescription;

  /// QR code generator tool name
  ///
  /// In en, this message translates to:
  /// **'QR Code Generator'**
  String get toolQrCodeName;

  /// QR code generator tool description
  ///
  /// In en, this message translates to:
  /// **'Generate QR codes from any text or URL'**
  String get toolQrCodeDescription;

  /// Placeholder text for the JSONPath query field in the JSON formatter
  ///
  /// In en, this message translates to:
  /// **'JSONPath query  (e.g. \$.store.book[*].title)'**
  String get jsonQueryHint;

  /// Tooltip for the button that clears the JSONPath query and restores the full JSON
  ///
  /// In en, this message translates to:
  /// **'Clear query'**
  String get jsonQueryClear;

  /// Error text shown when the JSONPath expression is syntactically invalid
  ///
  /// In en, this message translates to:
  /// **'Invalid expression'**
  String get jsonQueryInvalid;

  /// JSON to YAML conversion mode label
  ///
  /// In en, this message translates to:
  /// **'JSON → YAML'**
  String get jsonYamlModeJsonToYaml;

  /// YAML to JSON conversion mode label
  ///
  /// In en, this message translates to:
  /// **'YAML → JSON'**
  String get jsonYamlModeYamlToJson;

  /// XML formatter tool name
  ///
  /// In en, this message translates to:
  /// **'XML Formatter'**
  String get toolXmlFormatterName;

  /// XML formatter tool description
  ///
  /// In en, this message translates to:
  /// **'Prettify, minify or validate XML'**
  String get toolXmlFormatterDescription;

  /// YAML formatter tool name
  ///
  /// In en, this message translates to:
  /// **'YAML Formatter'**
  String get toolYamlFormatterName;

  /// YAML formatter tool description
  ///
  /// In en, this message translates to:
  /// **'Format and validate YAML'**
  String get toolYamlFormatterDescription;

  /// JSON/YAML converter tool name
  ///
  /// In en, this message translates to:
  /// **'JSON ↔ YAML'**
  String get toolJsonYamlConverterName;

  /// JSON/YAML converter tool description
  ///
  /// In en, this message translates to:
  /// **'Convert between JSON and YAML'**
  String get toolJsonYamlConverterDescription;

  /// MIME type lookup tool name
  ///
  /// In en, this message translates to:
  /// **'MIME Types'**
  String get toolMimeLookupName;

  /// MIME type lookup tool description
  ///
  /// In en, this message translates to:
  /// **'Look up MIME types by file extension'**
  String get toolMimeLookupDescription;

  /// MAC address tool name
  ///
  /// In en, this message translates to:
  /// **'MAC Address'**
  String get toolMacAddressName;

  /// MAC address tool description
  ///
  /// In en, this message translates to:
  /// **'Look up OUI vendor or generate a random MAC address'**
  String get toolMacAddressDescription;
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
