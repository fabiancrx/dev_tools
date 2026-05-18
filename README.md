# Dash Tools

A Flutter desktop application with a collection of utilities for programmers' day-to-day tasks. Built for Linux (Yaru/Ubuntu theme) using Flutter stable.

## Tools

| Tool | Description |
|---|---|
| Base64 Encoder/Decoder | Encode or decode text as Base64; supports UTF-8, Latin-1, and ASCII codecs |
| Base64 Image Encoder/Decoder | Encode images to Base64 or decode Base64 back to an image; supports clipboard and drag-and-drop |
| JSON Formatter | Prettify, minify, or validate JSON |
| JSON Escape/Unescape | Escape or unescape a JSON string |
| JWT Debugger | Decode and inspect JWT header, payload, and expiry |
| Number Converter | Convert integers between hexadecimal, decimal, octal, and binary |
| Hex ↔ ASCII | Convert between hex strings and ASCII text |

## Architecture

MVVM pattern throughout: each tool screen owns a `ChangeNotifier` ViewModel (`*Controller`) and rebuilds with `ListenableBuilder`. The exception is JSON Formatter which uses Riverpod.

```
lib/
├── app/            — app entry point, navigation shell
├── common/         — shared utilities, text formatters, code field
├── tools/          — one directory per tool (controller + screen)
├── widgets/        — shared widgets (CopyButton, ClearTextIcon, FlexActionBar, …)
├── l10n/           — ARB files and generated localizations
└── previews.dart   — MultiBrightnessPreview annotation for the widget previewer
```

## Localization

The app is fully localized in **English** and **Spanish** using `flutter_localizations`. ARB files live in `lib/l10n/arb/`.

To add a string, edit `lib/l10n/arb/app_en.arb` and the corresponding `app_es.arb`, then run:

```sh
flutter pub get
```

Access strings in widgets via the `context.l10n` extension:

```dart
import 'package:dash_tools/l10n/l10n.dart';

Text(context.l10n.someKey)
```

To add a new locale, add an `app_<locale>.arb` file and register the locale in `lib/app/app.dart`.

## Running Tests

```sh
flutter test
```

Tests cover the controller (ViewModel) layer. Widget-level tests are not included.

```sh
# With coverage
flutter test --coverage
genhtml coverage/lcov.info -o coverage/
open coverage/index.html
```

## Development

Requires [FVM](https://fvm.app/) — the project pins Flutter stable via `.fvmrc`.

```sh
fvm use
fvm flutter run -d linux
```

Widget previews (Flutter 3.38+):

```sh
flutter widget-preview start
```
