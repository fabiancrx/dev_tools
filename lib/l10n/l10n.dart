export 'generated/app_localizations.dart';

import 'package:dash_tools/l10n/generated/app_localizations.dart';
import 'package:flutter/widgets.dart';

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

extension AppLocalizationsToolsX on AppLocalizations {
  String toolName(String id) => switch (id) {
        'base64_text' => toolBase64Name,
        'json_formatter' => toolJsonFormatterName,
        'base64_image' => toolBase64ImageName,
        'number_base' => toolNumberConverterName,
        'hex_ascii' => toolHexToAsciiName,
        'json_escape' => toolJsonEscapeName,
        'jwt_debugger' => toolJwtDebuggerName,
        'url_encoder' => toolUrlEncoderName,
        'unix_timestamp' => toolUnixTimestampName,
        'query_string' => toolQueryStringName,
        'string_inspector' => toolStringInspectorName,
        'uuid_generator' => toolUuidGeneratorName,
        'hash_generator' => toolHashGeneratorName,
        'case_converter' => toolCaseConverterName,
        'http_status' => toolHttpStatusName,
        'cron_expression' => toolCronExpressionName,
        'qr_code' => toolQrCodeName,
        _ => id,
      };

  String toolDescription(String id) => switch (id) {
        'base64_text' => toolBase64Description,
        'json_formatter' => toolJsonFormatterDescription,
        'base64_image' => toolBase64ImageDescription,
        'number_base' => toolNumberConverterDescription,
        'hex_ascii' => toolHexToAsciiDescription,
        'json_escape' => toolJsonEscapeDescription,
        'jwt_debugger' => toolJwtDebuggerDescription,
        'url_encoder' => toolUrlEncoderDescription,
        'unix_timestamp' => toolUnixTimestampDescription,
        'query_string' => toolQueryStringDescription,
        'string_inspector' => toolStringInspectorDescription,
        'uuid_generator' => toolUuidGeneratorDescription,
        'hash_generator' => toolHashGeneratorDescription,
        'case_converter' => toolCaseConverterDescription,
        'http_status' => toolHttpStatusDescription,
        'cron_expression' => toolCronExpressionDescription,
        'qr_code' => toolQrCodeDescription,
        _ => id,
      };
}
