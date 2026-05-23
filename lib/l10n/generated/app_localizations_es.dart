// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get search => 'Buscar...';

  @override
  String get settings => 'Configuración';

  @override
  String get input => 'Entrada';

  @override
  String get output => 'Salida';

  @override
  String get sample => 'Ejemplo';

  @override
  String get clear => 'Limpiar';

  @override
  String get format => 'Formatear';

  @override
  String get loadImage => 'Cargar imagen';

  @override
  String get loadFile => 'Cargar archivo';

  @override
  String get save => 'Guardar';

  @override
  String get encoding => 'Codificación';

  @override
  String get copyToClipboard => 'Copiar al portapapeles';

  @override
  String get imageSaved => 'Imagen guardada';

  @override
  String get selectOutputFile => 'Por favor seleccione un archivo de salida:';

  @override
  String get pasteBase64FromClipboard =>
      'Pegar imagen base 64 codificada desde el portapapeles';

  @override
  String get copyBase64ToClipboard =>
      'Copiar imagen base 64 codificada al portapapeles';

  @override
  String get pasteImageFromClipboard => 'Pegar imagen desde el portapapeles';

  @override
  String get copyImageToClipboard => 'Copiar imagen al portapapeles';

  @override
  String get jwtTokenLabel => 'Token JWT';

  @override
  String get whatIsJwt => '¿Qué es un token web JSON?';

  @override
  String issuedOn(String date) {
    return 'Emitido el: $date';
  }

  @override
  String expiredOn(String date) {
    return 'Expirado el: $date';
  }

  @override
  String expiresOn(String date, String remaining) {
    return 'Expira el: $date en $remaining';
  }

  @override
  String get jwtPayload => 'Carga útil';

  @override
  String get jwtHeader => 'Encabezado';

  @override
  String get jwtClaimIss =>
      'Claim del emisor\nIdentifica el principal que emitió el JWT. El procesamiento de este claim generalmente es específico de la aplicación.';

  @override
  String get jwtClaimSub =>
      'Claim del sujeto\nIdentifica el principal que es el sujeto del JWT. Los claims en un JWT son normalmente declaraciones sobre el sujeto. El valor del sujeto DEBE estar restringido para ser localmente único en el contexto del emisor o ser globalmente único. El procesamiento de este claim generalmente es específico de la aplicación.';

  @override
  String get jwtClaimExp =>
      'Claim de tiempo de expiración\nIdentifica el tiempo de expiración tras el cual el JWT NO DEBE ser aceptado para procesamiento. El procesamiento del claim \'exp\' requiere que la fecha/hora actual DEBE ser antes de la fecha/hora de expiración indicada en el claim \'exp\'.';

  @override
  String get jwtClaimNbf =>
      'Claim de no antes de\nIdentifica el tiempo antes del cual el JWT NO DEBE ser aceptado para procesamiento. El procesamiento del claim \'nbf\' requiere que la fecha/hora actual DEBE ser después o igual a la fecha/hora indicada en el claim \'nbf\'.';

  @override
  String get jwtClaimIat =>
      'Claim de emitido en\nIdentifica el tiempo en el que se emitió el JWT. Este claim puede usarse para determinar la antigüedad del JWT.';

  @override
  String get jwtClaimJti =>
      'Claim de ID del JWT\nProporciona un identificador único para el JWT. El valor del identificador DEBE asignarse de manera que garantice una probabilidad insignificante de que el mismo valor sea asignado accidentalmente a otro objeto de datos.';

  @override
  String get jwtClaimAud =>
      'Claim de audiencia\nIdentifica los destinatarios para los que está destinado el JWT. Cada principal que pretenda procesar el JWT DEBE identificarse con un valor en el claim de audiencia.';

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
  String get hex => 'Hexadecimal';

  @override
  String get decimal => 'Decimal';

  @override
  String get octal => 'Octal';

  @override
  String get binary => 'Binario';

  @override
  String get base64ModeEncode => 'Codificar';

  @override
  String get base64ModeDecode => 'Decodificar';

  @override
  String get jsonEscapeModeEscape => 'Escapar';

  @override
  String get jsonEscapeModeUnescape => 'Desescapar';

  @override
  String get hexTextModeHexToText => 'Hex a Texto';

  @override
  String get hexTextModeTextToHex => 'Texto a Hex';

  @override
  String get jsonModeMinify => 'Minificar';

  @override
  String get jsonModeTwoSpaces => '2 Espacios';

  @override
  String get jsonModeFourSpaces => '4 Espacios';

  @override
  String get jsonModeTab => 'Tabulación';

  @override
  String get toolBase64Name => 'Codificador/decodificador BASE 64';

  @override
  String get toolBase64Description =>
      'Codifica o decodifica una cadena en base64';

  @override
  String get toolJsonFormatterName => 'Formateador JSON';

  @override
  String get toolJsonFormatterDescription =>
      'Embellece, minifica o valida una cadena JSON';

  @override
  String get toolBase64ImageName =>
      'Codificador/decodificador de imágenes BASE 64';

  @override
  String get toolBase64ImageDescription =>
      'Codifica o decodifica una imagen en base64';

  @override
  String get toolNumberConverterName => 'Convertidor de números';

  @override
  String get toolNumberConverterDescription =>
      'Convierte números de una base a otra';

  @override
  String get toolHexToAsciiName => 'Hex a ASCII';

  @override
  String get toolHexToAsciiDescription => 'Conversión de Hex a ASCII';

  @override
  String get toolJsonEscapeName => 'Escapado/desescapado JSON';

  @override
  String get toolJsonEscapeDescription => 'Escapa o desescapa una cadena JSON';

  @override
  String get toolJwtDebuggerName => 'Depurador JWT';

  @override
  String get toolJwtDebuggerDescription =>
      'Depurador de carga útil y encabezado de Token Web JSON';

  @override
  String get toolUrlEncoderName => 'Codificador/Decodificador URL';

  @override
  String get toolUrlEncoderDescription =>
      'Codifica o decodifica componentes de URL';

  @override
  String get toolUnixTimestampName => 'Marca de tiempo Unix';

  @override
  String get toolUnixTimestampDescription =>
      'Convierte entre marcas de tiempo Unix y fechas ISO 8601';

  @override
  String get toolQueryStringName => 'Analizador de cadena de consulta';

  @override
  String get toolQueryStringDescription =>
      'Analiza cadenas de consulta URL en JSON';

  @override
  String get toolStringInspectorName => 'Inspector de cadenas';

  @override
  String get toolStringInspectorDescription =>
      'Analiza cadenas: caracteres, bytes, palabras, líneas';

  @override
  String get toolUuidGeneratorName => 'Generador de UUID';

  @override
  String get toolUuidGeneratorDescription => 'Genera UUIDs (v1, v4, v7)';

  @override
  String get toolHashGeneratorName => 'Generador de Hash';

  @override
  String get toolHashGeneratorDescription =>
      'Genera hashes MD5, SHA-1, SHA-256, SHA-512 y HMAC';

  @override
  String get toolCaseConverterName => 'Convertidor de Case';

  @override
  String get toolCaseConverterDescription =>
      'Convierte texto entre camelCase, snake_case, kebab-case y más';

  @override
  String get toolHttpStatusName => 'Códigos de estado HTTP';

  @override
  String get toolHttpStatusDescription =>
      'Referencia de códigos de estado HTTP y sus significados';

  @override
  String get toolCronExpressionName => 'Expresión Cron';

  @override
  String get toolCronExpressionDescription =>
      'Analiza expresiones cron y previsualiza las próximas ejecuciones';

  @override
  String get toolQrCodeName => 'Generador de código QR';

  @override
  String get toolQrCodeDescription =>
      'Genera códigos QR desde cualquier texto o URL';

  @override
  String get jsonQueryHint => 'Consulta JSONPath  (ej. \$.store.book[*].title)';

  @override
  String get jsonQueryClear => 'Limpiar consulta';

  @override
  String get jsonQueryInvalid => 'Expresión inválida';

  @override
  String get jsonYamlModeJsonToYaml => 'JSON → YAML';

  @override
  String get jsonYamlModeYamlToJson => 'YAML → JSON';

  @override
  String get toolXmlFormatterName => 'Formateador XML';

  @override
  String get toolXmlFormatterDescription => 'Embellece, minifica o valida XML';

  @override
  String get toolYamlFormatterName => 'Formateador YAML';

  @override
  String get toolYamlFormatterDescription => 'Formatea y valida YAML';

  @override
  String get toolJsonYamlConverterName => 'JSON ↔ YAML';

  @override
  String get toolJsonYamlConverterDescription => 'Convierte entre JSON y YAML';

  @override
  String get toolMimeLookupName => 'Tipos MIME';

  @override
  String get toolMimeLookupDescription =>
      'Busca tipos MIME por extensión de archivo';

  @override
  String get toolMacAddressName => 'Dirección MAC';

  @override
  String get toolMacAddressDescription =>
      'Consulta el fabricante OUI o genera una dirección MAC aleatoria';
}
