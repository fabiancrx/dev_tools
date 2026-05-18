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
        _ => id,
      };
}
