export 'generated/app_localizations.dart';

import 'package:dash_tools/l10n/generated/app_localizations.dart';
import 'package:flutter/widgets.dart';

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

extension AppLocalizationsToolsX on AppLocalizations {
  String toolName(String id) => switch (id) {
        'base64' => toolBase64Name,
        'jsonf' => toolJsonFormatterName,
        'base64image' => toolBase64ImageName,
        'number' => toolNumberConverterName,
        'hextext' => toolHexToAsciiName,
        'jsone' => toolJsonEscapeName,
        'jwt' => toolJwtDebuggerName,
        _ => id,
      };

  String toolDescription(String id) => switch (id) {
        'base64' => toolBase64Description,
        'jsonf' => toolJsonFormatterDescription,
        'base64image' => toolBase64ImageDescription,
        'number' => toolNumberConverterDescription,
        'hextext' => toolHexToAsciiDescription,
        'jsone' => toolJsonEscapeDescription,
        'jwt' => toolJwtDebuggerDescription,
        _ => id,
      };
}
