# Dash Tools

A Flutter desktop application with a collection of utilities for programmers' day-to-day tasks. Built for Linux desktop using Flutter stable (pinned via FVM).

## Tools

### Encoders
| Tool | Description |
|---|---|
| Base64 Encoder/Decoder | Encode or decode text as Base64 |
| Base64 Image Encoder/Decoder | Encode or decode an image as Base64; supports clipboard and drag-and-drop |
| URL Encoder/Decoder | Encode or decode URL components (percent-encoding) |
| HTML Entity Encode/Decode | Encode or decode HTML entities |

### Formatters
| Tool | Description |
|---|---|
| JSON Formatter | Prettify, minify, or validate JSON |
| JSON Escape/Unescape | Escape or unescape a JSON string |
| XML Formatter | Prettify, minify, or validate XML |
| YAML Formatter | Format and validate YAML |

### Converters
| Tool | Description |
|---|---|
| Number Converter | Convert integers between hex, decimal, octal, and binary |
| Hex ↔ ASCII | Convert between hex strings and ASCII text |
| Unix Timestamp | Convert between Unix timestamps and human-readable dates (ISO 8601, RFC 3339, RFC 7231, ISO 9075) |
| Query String Parser | Parse URL query strings into key/value pairs |
| Case Converter | Convert text between camelCase, snake_case, kebab-case, PascalCase, and more |
| JSON ↔ YAML | Convert between JSON and YAML |
| Docker Run → Compose | Convert a `docker run` command to a Docker Compose file |

### Generators
| Tool | Description |
|---|---|
| UUID Generator | Generate UUIDs (v1, v4, v7) |
| Hash Generator | Generate MD5, SHA-1, SHA-256, SHA-512, and HMAC hashes |
| Cron Expression | Parse cron expressions and preview next run times; includes a cron reference panel |
| QR Code Generator | Generate QR codes from any text or URL |
| WiFi QR Code | Generate a QR code to share WiFi credentials |

### Inspectors
| Tool | Description |
|---|---|
| JWT Debugger | Decode and inspect JWT header, payload, and expiry |
| String Inspector | Analyze strings: character count, byte length, word count, line count |
| Regex Tester | Test regular expressions with live match highlighting |

### Network
| Tool | Description |
|---|---|
| MAC Address | Look up OUI vendor from a MAC address or generate a random one |

### Reference
| Tool | Description |
|---|---|
| HTTP Status Codes | Reference for all HTTP status codes and their meanings |
| MIME Types | Look up MIME types by file extension |

## Architecture

Three-layer MVVM, enforced for every tool:

```
lib/
├── app/            — app entry point, navigation shell
├── common/         — shared utilities, clipboard detection, app settings
├── tools/          — one directory per tool
│   └── <tool>/
│       ├── <tool>.dart             — pure logic, no Flutter imports
│       ├── <tool>_controller.dart  — ChangeNotifier ViewModel
│       └── <tool>_screen.dart      — UI, rebuilt via ListenableBuilder
├── widgets/        — shared widgets (ToolScaffold, FlexActionBar, CopyButton, …)
└── l10n/           — ARB files and generated localizations
```

**Clipboard detection** — on app focus, `ClipboardRecognizer` runs all registered `ClipboardDetector`s against the clipboard and surfaces a `MaterialBanner` routing to the best-matching tool.

**⌘K palette** — each tool registers aliases used by the command palette for fuzzy search.

**Quick transforms** — tools with an obvious default action expose a `QuickTransform` for tray quick-actions and instant clipboard replacement.

**`AppSettings`** — persists the global `autoRun` toggle (run on input change vs. manual).

**`ToolInputCache`** — persists the last input per tool across sessions.

**`ToolOrderNotifier`** — persists sidebar order and hidden-tool set.

## Localization

Fully localized in **English** and **Spanish** using `flutter_localizations`. ARB files live in `lib/l10n/arb/`.

To add a string, edit `lib/l10n/arb/app_en.arb` and `app_es.arb`, then run:

```sh
flutter pub get
```

Access strings in widgets via the `context.l10n` extension:

```dart
import 'package:dash_tools/l10n/l10n.dart';

Text(context.l10n.someKey)
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

## Running Tests

```sh
fvm flutter test                                          # all tests
fvm flutter test test/tools/url_encoder_test.dart        # single file
fvm dart analyze lib test                                 # static analysis
dart format -l 120 lib/                                   # format
```

Tests cover the pure-logic and ViewModel layers. To collect coverage:

```sh
fvm flutter test --coverage
genhtml coverage/lcov.info -o coverage/
open coverage/index.html
```
