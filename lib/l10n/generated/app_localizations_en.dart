// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get search => 'Search...';

  @override
  String get settings => 'Settings';

  @override
  String get input => 'Input';

  @override
  String get output => 'Output';

  @override
  String get sample => 'Sample';

  @override
  String get clear => 'Clear';

  @override
  String get format => 'Format';

  @override
  String get loadImage => 'Load Image';

  @override
  String get loadFile => 'Load File';

  @override
  String get save => 'Save';

  @override
  String get encoding => 'Encoding';

  @override
  String get copyToClipboard => 'Copy to clipboard';

  @override
  String get imageSaved => 'Image saved';

  @override
  String get selectOutputFile => 'Please select an output file:';

  @override
  String get pasteBase64FromClipboard =>
      'Paste base 64 encoded image from clipboard';

  @override
  String get copyBase64ToClipboard => 'Copy base 64 encoded image to clipboard';

  @override
  String get pasteImageFromClipboard => 'Paste image from clipboard';

  @override
  String get copyImageToClipboard => 'Copy image to clipboard';

  @override
  String get jwtTokenLabel => 'JWT Token';

  @override
  String get whatIsJwt => 'What is a Json Web token?';

  @override
  String issuedOn(String date) {
    return 'Issued on: $date';
  }

  @override
  String expiredOn(String date) {
    return 'Expired on: $date';
  }

  @override
  String expiresOn(String date, String remaining) {
    return 'Expires on: $date in $remaining';
  }

  @override
  String get jwtPayload => 'Payload';

  @override
  String get jwtHeader => 'Header';

  @override
  String get jwtClaimIss =>
      'Issuer Claim\nIdentifies the principal that issued the JWT. The processing of this claim is generally application specific.';

  @override
  String get jwtClaimSub =>
      'Subject Claim\nIdentifies the principal that is the subject of the JWT. The claims in a JWT are normally statements about the subject. The subject value MUST either be scoped to be locally unique in the context of the issuer or be globally unique. The processing of this claim is generally application specific.';

  @override
  String get jwtClaimExp =>
      'Expiration time claim\nIdentifies the expiration time on or after which the JWT MUST NOT be accepted for processing. The processing of the \'exp\' claim requires that the current date/time MUST be before the expiration date/time listed in the \'exp\' claim.';

  @override
  String get jwtClaimNbf =>
      'Not before claim\nIdentifies the time before which the JWT MUST NOT be accepted for processing. The processing of the \'nbf\' claim requires that the current date/time MUST be after or equal to the not-before date/time listed in the \'nbf\' claim.';

  @override
  String get jwtClaimIat =>
      'Issued at claim\nIdentifies the time at which the JWT was issued. This claim can be used to determine the age of the JWT.';

  @override
  String get jwtClaimJti =>
      'JWT ID claim\nProvides a unique identifier for the JWT. The identifier value MUST be assigned in a manner that ensures that there is a negligible probability that the same value will be accidentally assigned to a different data object; if the application uses multiple issuers, collisions MUST be prevented among values produced by different issuers as well.';

  @override
  String get jwtClaimAud =>
      'Audience claim\nIdentifies the recipients that the JWT is intended for. Each principal intended to process the JWT MUST identify itself with a value in the audience claim.';

  @override
  String get jwtDecode => 'Decode';

  @override
  String get jwtEncode => 'Encode';

  @override
  String get jwtValid => 'Valid JWT';

  @override
  String get jwtInvalid => 'Invalid token';

  @override
  String get jwtSignatureVerified => 'Signature verified';

  @override
  String get jwtSignatureInvalid => 'Invalid signature';

  @override
  String get jwtSecret => 'Secret';

  @override
  String get jwtSecretBase64 => 'Base64 encoded';

  @override
  String get jwtVerifySignature => 'Verify Signature';

  @override
  String get jwtAlgorithm => 'Algorithm';

  @override
  String get jwtGeneratedToken => 'Generated Token';

  @override
  String get jwtEncodePayload => 'Payload';

  @override
  String get jwtEncodeHeader => 'Header';

  @override
  String get jwtEditInEncoder => 'Edit in Encoder';

  @override
  String jwtNotValidBefore(String date) {
    return 'Not valid before: $date';
  }

  @override
  String get jwtNotYetValid => 'Token not yet valid';

  @override
  String get jwtInsecureAlgorithmWarning =>
      'This token uses no signature (alg: none) and cannot be trusted.';

  @override
  String get jwtClaimsBreakdown => 'Claims breakdown';

  @override
  String get jwtShowJson => 'Show JSON';

  @override
  String get hex => 'Hex';

  @override
  String get decimal => 'Decimal';

  @override
  String get octal => 'Octal';

  @override
  String get binary => 'Binary';

  @override
  String get base64ModeEncode => 'Encode';

  @override
  String get base64ModeDecode => 'Decode';

  @override
  String get jsonEscapeModeEscape => 'Escape';

  @override
  String get jsonEscapeModeUnescape => 'Unescape';

  @override
  String get hexTextModeHexToText => 'Hex to Text';

  @override
  String get hexTextModeTextToHex => 'Text to Hex';

  @override
  String get jsonModeMinify => 'Minify';

  @override
  String get jsonModeTwoSpaces => '2 Spaces';

  @override
  String get jsonModeFourSpaces => '4 Spaces';

  @override
  String get jsonModeTab => 'Tab';

  @override
  String get toolBase64Name => 'BASE 64 encoder/decoder';

  @override
  String get toolBase64Description => 'Encode or decode a String as base64';

  @override
  String get toolJsonFormatterName => 'JSON formatter';

  @override
  String get toolJsonFormatterDescription =>
      'Prettify, minify or just validate a String as JSON';

  @override
  String get toolBase64ImageName => 'BASE 64 Image encoder/decoder';

  @override
  String get toolBase64ImageDescription =>
      'Encode or decode an image as base64';

  @override
  String get toolNumberConverterName => 'Number Converter';

  @override
  String get toolNumberConverterDescription =>
      'Convert numbers from one base to another';

  @override
  String get toolHexToAsciiName => 'Hex to ASCII';

  @override
  String get toolHexToAsciiDescription => 'Hex to ASCII conversion';

  @override
  String get toolJsonEscapeName => 'JSON escape/unescape';

  @override
  String get toolJsonEscapeDescription => 'Escape or unescape a JSON string';

  @override
  String get toolJwtDebuggerName => 'JWT Debugger';

  @override
  String get toolJwtDebuggerDescription =>
      'JSON Web Token payload and header debugger';

  @override
  String get toolUrlEncoderName => 'URL Encoder/Decoder';

  @override
  String get toolUrlEncoderDescription => 'Encode or decode URL components';

  @override
  String get toolUnixTimestampName => 'Unix Timestamp';

  @override
  String get toolUnixTimestampDescription =>
      'Convert between Unix timestamps and ISO 8601 dates';

  @override
  String get toolQueryStringName => 'Query String Parser';

  @override
  String get toolQueryStringDescription => 'Parse URL query strings into JSON';

  @override
  String get toolStringInspectorName => 'String Inspector';

  @override
  String get toolStringInspectorDescription =>
      'Analyze strings: characters, bytes, words, lines';

  @override
  String get toolUuidGeneratorName => 'UUID Generator';

  @override
  String get toolUuidGeneratorDescription => 'Generate UUIDs (v1, v4, v7)';

  @override
  String get toolHashGeneratorName => 'Hash Generator';

  @override
  String get toolHashGeneratorDescription =>
      'Generate MD5, SHA-1, SHA-256, SHA-512 and HMAC hashes';

  @override
  String get toolCaseConverterName => 'Case Converter';

  @override
  String get toolCaseConverterDescription =>
      'Convert text between camelCase, snake_case, kebab-case and more';

  @override
  String get toolHttpStatusName => 'HTTP Status Codes';

  @override
  String get toolHttpStatusDescription =>
      'Reference for HTTP status codes and their meanings';

  @override
  String get toolCronExpressionName => 'Cron Expression';

  @override
  String get toolCronExpressionDescription =>
      'Parse cron expressions and preview next run times';

  @override
  String get toolQrCodeName => 'QR Code Generator';

  @override
  String get toolQrCodeDescription => 'Generate QR codes from any text or URL';
}
