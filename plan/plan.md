# Tool Matrix & Development Plan

A prioritized roadmap for `dev_tools`, derived from the market study of DevUtils, DevToys,
DevUtils.lol, it-tools, and DevTools-X.

**Scope:** Tools that at least one competitor implements. No invented categories.

---

## Scoring methodology

**Usefulness (1–5).** Floor = number of competitors that have it. The "floor" is then
adjusted ±1 by judgment of real-world dev frequency.

| Competitors | Floor | Example adjustment |
| ----------- | ----- | ------------------ |
| 5 of 5      | 5     | Stays 5 (Base64 text) |
| 3–4 of 5    | 4     | Bumps to 5 if everyday-use (Unix timestamp), stays 4 otherwise |
| 2 of 5      | 3     | Down to 2 if niche (Backslash escape) |
| 1 of 5      | 2     | Up to 3 if killer-feature (Cert decoder), down to 1 if niche (Bcrypt) |

**Complexity (1–5)**, in Flutter specifically:

| Score | Effort   | Description                                                                     |
| ----- | -------- | ------------------------------------------------------------------------------- |
| 1     | <1 hr    | Pure-Dart, no UI work beyond a `TextField` (e.g. URL encode/decode)             |
| 2     | ½ day    | One mature package, simple UI                                                   |
| 3     | 1–2 days | Package + non-trivial UI, multiple inputs/outputs                               |
| 4     | 3+ days  | Custom rendering, multi-pane UI (diff view, regex highlighting), or many edge cases |
| 5     | Week+    | Complex algorithms, custom widgets, platform integration                        |

**Priority score = Usefulness ÷ Complexity.** Higher = build first.

| Score band     | Tier   | Action                                              |
| -------------- | ------ | --------------------------------------------------- |
| ≥ 2.0          | Tier 1 | Build next; the obvious wins                        |
| 1.0 – 2.0      | Tier 2 | Build after Tier 1 is done                          |
| < 1.0          | Tier 3 | Build only if it differentiates or you want it      |

**FFI column.** Marks whether FFI-to-C/Rust meaningfully changes the tool's profile. See
the [FFI lens](#ffi-lens-when-native-libraries-change-the-equation) section below.

- "—" — irrelevant. Pure-Dart is the right answer; FFI adds overhead with no payoff.
- "🟡 future" — pure-Dart works for v1; FFI is a known upgrade path if quality or perf
  complaints emerge.
- "🟢 sprint 5" — FFI is the *correct* implementation; pure-Dart would be a regression.

**CLI-friendliness note.** Regardless of UI, every tool's pure logic should be a plain
Dart function in its own file under `lib/tools/<tool>/<tool>.dart`, with no Flutter
imports. This costs nothing today and keeps a future CLI companion (or scripting use) a
straightforward wrapper. The Controller (MVVM) calls these functions; it doesn't
*contain* the logic.

---

## FFI lens — when native libraries change the equation

FFI is leverage only when **all three** are true:

1. A mature, battle-tested C/Rust library exists that would take weeks to reimplement.
2. The pure-Dart alternative is missing, immature, or noticeably slower.
3. Per-platform packaging cost is amortized — the library is worth shipping a binary for.

FFI's cost is *distribution complexity*, not coding complexity. Every release ships
platform-specific binaries (Linux/macOS/Windows + Android/iOS if mobile is in scope), the
CI matrix grows, and each FFI dependency adds permanent release-engineering overhead. The
economics only work if one FFI integration powers several tools, not one.

**Web fallback.** Use conditional imports:

```dart
// formatter.dart
export 'formatter_io.dart' if (dart.library.html) 'formatter_web.dart';
```

The IO version uses FFI; the web version either skips the tool, falls back to a slower
pure-Dart implementation, or shows a "available on desktop" notice. Tools that should
gracefully degrade on web: code formatters (skip), image conversion (Canvas-based
fallback), PDF inspection (skip).

**What FFI does not help with.** UI complexity is unchanged. Text diff is "3 days of UI
work" not because the algorithm is hard but because side-by-side rendering with synced
scroll is hard. Tools where the cost is widgets, not algorithms, are unaffected.

---

## Matrix by category

Already-implemented tools are marked ✓ and excluded from priority sorting.

### Encoders & decoders

| Tool                          | Comps | Useful | Complex | Score | FFI            | Package                              | Notes                                  |
| ----------------------------- | ----- | ------ | ------- | ----- | -------------- | ------------------------------------ | -------------------------------------- |
| ✓ Base64 text                 | 5     | —      | —       | —     | —              | `dart:convert`                       | Already built                          |
| ✓ Base64 image                | 4     | —      | —       | —     | —              | `dart:convert`                       | Already built                          |
| ✓ JWT debug/decode            | 5     | —      | —       | —     | —              | `dart_jsonwebtoken` or hand-rolled   | Already built                          |
| URL encode/decode             | 4     | 5      | 1       | 5.0   | —              | `dart:core` (`Uri.encodeComponent`)  | Single most overdue tool               |
| HTML entity encode/decode     | 3     | 4      | 2       | 2.0   | —              | `html_unescape`                      | Cheap                                  |
| Backslash escape/unescape     | 2     | 2      | 2       | 1.0   | —              | hand-rolled                          | Niche but tiny                         |
| Certificate (X.509) decoder   | 2     | 3      | 2       | 1.5   | 🟡 future      | `basic_utils` v1; OpenSSL FFI for v2 | Ship basic_utils first; FFI for full validation/OCSP/CT |
| Base64 file (any)             | 1     | 2      | 2       | 1.0   | —              | `file_picker` + `dart:convert`       | Extension of existing tool             |
| GZIP encode/decode            | 1     | 2      | 1       | 2.0   | —              | `dart:io` `GZipCodec`                | Trivial                                |

### Formatters

| Tool                       | Comps | Useful | Complex | Score | FFI            | Package                  | Notes                              |
| -------------------------- | ----- | ------ | ------- | ----- | -------------- | ------------------------ | ---------------------------------- |
| ✓ JSON format/validate     | 5     | —      | —       | —     | —              | `dart:convert`           | Already built                      |
| ✓ JSON escape/unescape     | 3     | —      | —       | —     | —              | `dart:convert`           | Already built                      |
| XML format                 | 3     | 4      | 2       | 2.0   | —              | `xml`                    | Cheap                              |
| SQL format                 | 3     | 4      | 2       | 2.0   | —              | `sql_format` or JS bridge | Cheap                             |
| YAML format                | 1     | 3      | 2       | 1.5   | —              | `yaml` + `yaml_writer`   | Useful with K8s/CI work            |
| HTML format                | 1     | 3      | 3 → 2*  | 1.0 → 1.5* | 🟢 sprint 5 | `dprint` HTML (Rust)     | *With shared dprint FFI binding    |
| CSS / SCSS / LESS format   | 1     | 2      | 4 → 2*  | 0.5 → 1.0* | 🟢 sprint 5 | `dprint` (Rust)          | *Shared dprint FFI; otherwise skip |
| JS / TS format / minify    | 1     | 2      | 4 → 2*  | 0.5 → 1.0* | 🟢 sprint 5 | `dprint` (Rust)          | *Shared dprint FFI; otherwise skip |

### Converters

| Tool                          | Comps | Useful | Complex | Score | FFI            | Package                       | Notes                                     |
| ----------------------------- | ----- | ------ | ------- | ----- | -------------- | ----------------------------- | ----------------------------------------- |
| ✓ Number base                 | 4     | —      | —       | —     | —              | `dart:core`                   | Already built                             |
| ✓ Hex ↔ ASCII                 | 2     | —      | —       | —     | —              | `dart:convert`                | Already built                             |
| Unix timestamp ↔ ISO date     | 3     | 5      | 2       | 2.5   | —              | `dart:core` + `timezone`      | Daily-use for backend devs                |
| Color converter (hex/rgb/hsl) | 3     | 4      | 3       | 1.3   | —              | `flutter_colorpicker` or `flex_color_picker` | Picker UI takes the time |
| Case converter                | 2     | 4      | 1       | 4.0   | —              | hand-rolled or `recase`       | Cheapest possible win                     |
| JSON ↔ YAML                   | 3     | 4      | 2       | 2.0   | —              | `yaml` + `dart:convert`       |                                           |
| JSON ↔ CSV                    | 3     | 4      | 2       | 2.0   | —              | `csv`                         |                                           |
| JSON ↔ TOML                   | 1     | 2      | 2       | 1.0   | —              | `toml`                        | Niche                                     |
| JSON ↔ XML                    | 1     | 2      | 3       | 0.7   | —              | `xml`                         | Schema-loss problem; skip                 |
| Markdown → HTML               | 1     | 3      | 2       | 1.5   | 🟡 future      | `markdown` v1; `pulldown-cmark` (Rust) for v2 | Pure-Dart fine; FFI for GFM extras |
| cURL → code                   | 1     | 3      | 4       | 0.75  | —              | hand-rolled parser            | No mature C/Rust library; FFI doesn't help |
| JSON → typed code (quicktype) | 2     | 3      | 5       | 0.6   | —              | quicktype CLI bridge          | TS-based, out of scope                    |
| Docker run → docker-compose   | 2     | 3      | 4       | 0.75  | —              | hand-rolled parser            | No library does this end-to-end           |
| Query string → JSON           | 2     | 3      | 1       | 3.0   | —              | `dart:core` `Uri.queryParameters` | Trivially cheap                       |

### Generators

| Tool                          | Comps | Useful | Complex | Score | FFI            | Package                | Notes                                |
| ----------------------------- | ----- | ------ | ------- | ----- | -------------- | ---------------------- | ------------------------------------ |
| UUID / ULID                   | 3     | 5      | 1       | 5.0   | —              | `uuid` + `ulid`        | Trivial, universal                   |
| Hash (MD5/SHA-1/SHA-2/HMAC)   | 3     | 5      | 1       | 5.0   | —              | `crypto`               | Trivial, universal                   |
| Hash extras (SHA-3, BLAKE3)   | 0     | 3      | 2       | 1.5   | 🟡 future      | `pointycastle` v1; `tiny-keccak` FFI later | Match DevUtils' Keccak-256 for blockchain |
| Lorem ipsum                   | 3     | 3      | 1       | 3.0   | —              | `lorem_ipsum` or hand-rolled | Cheap                          |
| Password / random string      | 3     | 4      | 2       | 2.0   | —              | `random_string`        | Add config options                   |
| QR code                       | 3     | 4      | 2       | 2.0   | —              | `qr_flutter` + `mobile_scanner` | Reader is extra effort      |
| Cron expression               | 4     | 4      | 2       | 2.0   | —              | `cron_parser`          | Next-N-runs preview is the value-add |
| WiFi QR code                  | 1     | 2      | 2       | 1.0   | —              | `qr_flutter` + format spec | Specialization of QR              |
| Bcrypt                        | 1     | 2      | 2       | 1.0   | 🟡 future      | `bcrypt` v1            | FFI only if perf complaints (high cost factors) |
| RSA / SSH key pair            | 1     | 2      | 3       | 0.7   | 🟡 future      | `basic_utils` v1; OpenSSL FFI for v2 | Niche                       |
| Token generator               | 1     | 2      | 1       | 2.0   | —              | `dart:math` + `crypto` | Adjacent to password generator       |

### Inspectors / testers

| Tool                              | Comps | Useful | Complex | Score | FFI            | Package                 | Notes                                 |
| --------------------------------- | ----- | ------ | ------- | ----- | -------------- | ----------------------- | ------------------------------------- |
| Text diff                         | 4     | 5      | 4       | 1.25  | 🟡 future      | `diff_match_patch` v1; Rust `similar` later | UI is the work; FFI helps only for huge diffs |
| Regex tester                      | 3     | 5      | 3       | 1.7   | 🟡 future      | `dart:core` `RegExp` v1; PCRE2 FFI for v2 | Dart regex lacks lookbehind/PCRE features |
| String inspector (char count, …)  | 3     | 3      | 1       | 3.0   | —              | hand-rolled             | Cheap; combine with case converter    |
| Markdown preview                  | 2     | 3      | 2       | 1.5   | —              | `flutter_markdown`      | Pair with Markdown → HTML             |
| HTML preview                      | 1     | 3      | 3       | 1.0   | —              | `webview_flutter`       | Heavier dependency on desktop         |
| JSONPath tester                   | 1     | 3      | 2       | 1.5   | —              | `json_path`             | Power-user                            |
| Log parser / scrubber             | 1     | 3      | 3       | 1.0   | —              | hand-rolled regex rules | DevUtils.lol's niche; skip            |

### Network / IT

| Tool                          | Comps | Useful | Complex | Score | FFI            | Package                | Notes                              |
| ----------------------------- | ----- | ------ | ------- | ----- | -------------- | ---------------------- | ---------------------------------- |
| IPv4 subnet calculator        | 1     | 3      | 2       | 1.5   | —              | `dart_ipify` or `cidr` | Sysadmin tool, popular            |
| IPv4 / IPv6 utils             | 1     | 2      | 2       | 1.0   | —              | as above              | Same niche                         |
| MAC address tools             | 1     | 2      | 1       | 2.0   | —              | hand-rolled            | Cheap                              |
| HTTP status code reference    | 1     | 4      | 1       | 4.0   | —              | static map             | Zero-input "cheatsheet" — pure win |
| MIME type lookup              | 1     | 3      | 1       | 3.0   | —              | `mime`                 | Cheatsheet                         |
| User-agent parser             | 1     | 3      | 2       | 1.5   | —              | `user_agent_parser`    | Useful for support work            |
| WebSocket / Socket.IO tester  | 1     | 3      | 4       | 0.75  | —              | `web_socket_channel`   | Out-of-scope for stateless tooling |

---

## Top of the pile — sorted by priority score

Scores marked * use FFI-based numbers (see Sprint 5). Pure-Dart scores in parentheses.

| Rank | Tool                          | Useful | Complex | Score | Tier | FFI       |
| ---- | ----------------------------- | ------ | ------- | ----- | ---- | --------- |
| 1    | URL encode/decode             | 5      | 1       | 5.0   | 1    | —         |
| 2    | UUID / ULID                   | 5      | 1       | 5.0   | 1    | —         |
| 3    | Hash (MD5/SHA-1/SHA-2/HMAC)   | 5      | 1       | 5.0   | 1    | —         |
| 4    | Case converter                | 4      | 1       | 4.0   | 1    | —         |
| 5    | HTTP status code reference    | 4      | 1       | 4.0   | 1    | —         |
| 6    | Lorem ipsum                   | 3      | 1       | 3.0   | 1    | —         |
| 7    | Query string → JSON           | 3      | 1       | 3.0   | 1    | —         |
| 8    | String inspector              | 3      | 1       | 3.0   | 1    | —         |
| 9    | MIME type lookup              | 3      | 1       | 3.0   | 1    | —         |
| 10   | Unix timestamp ↔ ISO date     | 5      | 2       | 2.5   | 1    | —         |
| 11   | XML format                    | 4      | 2       | 2.0   | 1    | —         |
| 12   | SQL format                    | 4      | 2       | 2.0   | 1    | —         |
| 13   | JSON ↔ YAML                   | 4      | 2       | 2.0   | 1    | —         |
| 14   | JSON ↔ CSV                    | 4      | 2       | 2.0   | 1    | —         |
| 15   | Cron expression               | 4      | 2       | 2.0   | 1    | —         |
| 16   | Password / random string      | 4      | 2       | 2.0   | 1    | —         |
| 17   | QR code                       | 4      | 2       | 2.0   | 1    | —         |
| 18   | HTML entity encode/decode     | 4      | 2       | 2.0   | 1    | —         |
| 19   | GZIP encode/decode            | 2      | 1       | 2.0   | 1    | —         |
| 20   | Token generator               | 2      | 1       | 2.0   | 1    | —         |
| 21   | MAC address tools             | 2      | 1       | 2.0   | 1    | —         |
| 22   | Regex tester                  | 5      | 3       | 1.7   | 2    | 🟡 future |
| 23   | Certificate (X.509) decoder   | 3      | 2       | 1.5   | 2    | 🟡 future |
| 24   | Markdown → HTML               | 3      | 2       | 1.5   | 2    | 🟡 future |
| 25   | YAML format                   | 3      | 2       | 1.5   | 2    | —         |
| 26   | Markdown preview              | 3      | 2       | 1.5   | 2    | —         |
| 27   | JSONPath tester               | 3      | 2       | 1.5   | 2    | —         |
| 28   | IPv4 subnet calculator        | 3      | 2       | 1.5   | 2    | —         |
| 29   | User-agent parser             | 3      | 2       | 1.5   | 2    | —         |
| 30   | Hash extras (SHA-3, BLAKE3)   | 3      | 2       | 1.5   | 2    | 🟡 future |
| 31   | Code Formatter (dprint, multi-lang) | 4 | 3      | 1.3*  | 2    | 🟢 sprint 5 |
| 32   | Color converter               | 4      | 3       | 1.3   | 2    | —         |
| 33   | Text diff                     | 5      | 4       | 1.25  | 2    | 🟡 future |
| 34   | Base64 file (any)             | 2      | 2       | 1.0   | 2    | —         |
| 35   | Backslash escape/unescape     | 2      | 2       | 1.0   | 2    | —         |
| 36   | Bcrypt                        | 2      | 2       | 1.0   | 2    | 🟡 future |
| 37   | WiFi QR code                  | 2      | 2       | 1.0   | 2    | —         |
| 38   | HTML preview                  | 3      | 3       | 1.0   | 2    | —         |
| 39   | HTML format (standalone)      | 3      | 3       | 1.0   | 2    | 🟢 sprint 5 |
| 40   | IPv4 / IPv6 utils             | 2      | 2       | 1.0   | 2    | —         |
| 41   | Log parser / scrubber         | 3      | 3       | 1.0   | 2    | —         |
| 42   | JSON ↔ TOML                   | 2      | 2       | 1.0   | 2    | —         |
| 43   | cURL → code                   | 3      | 4       | 0.75  | 3    | —         |
| 44   | Docker run → docker-compose   | 3      | 4       | 0.75  | 3    | —         |
| 45   | WebSocket / Socket.IO tester  | 3      | 4       | 0.75  | 3    | —         |
| 46   | RSA / SSH key pair            | 2      | 3       | 0.7   | 3    | 🟡 future |
| 47   | JSON ↔ XML                    | 2      | 3       | 0.7   | 3    | —         |
| 48   | JSON → typed code (quicktype) | 3      | 5       | 0.6   | 3    | —         |
| 49   | CSS / SCSS / LESS format (standalone) | 2 | 4    | 0.5   | 3    | 🟢 sprint 5 |
| 50   | JS / TS format (standalone)   | 2      | 4       | 0.5   | 3    | 🟢 sprint 5 |

---

## Development plan — phased

### Sprint 0.5: "Plumbing before the rush"

Goal: a half-day to one-day pass *before* Sprint 1 that prevents the next 19 tools from
becoming a refactor magnet. The principle: plumbing only earns its way in if it unblocks
Sprint 1, or if adding it later means rewriting Sprint 1 tools. Anything that can be
bolted on cleanly later, leave for later.

**1. Audit existing tools for pure-logic separation.** For each of the seven existing
tools, verify the actual encode/decode/format logic lives in a Flutter-free function
(`lib/tools/<tool>/<tool>.dart` or similar) and the Controller just calls it. If
anything is tangled — logic embedded in the Controller, `BuildContext` reaching into
codec code — untangle it now. Untangling 7 tools is a half-day; untangling 26 tools
after Sprint 2 is a multi-day pass and a CLI-readiness blocker.

**2. Tool registry / manifest.** Create `lib/tools/registry.dart` with a `ToolDescriptor`
type and a single `toolRegistry` list. Suggested shape:

```dart
class ToolDescriptor {
  final String id;              // stable, e.g. 'base64_text' — used as Hive key, settings key
  final String Function(BuildContext) name;    // l10n-aware
  final ToolCategory category;
  final IconData icon;
  final WidgetBuilder builder;
  final List<String> aliases;   // for search: 'b64', 'base 64'
  final ClipboardDetector? detector;  // null = doesn't auto-detect
}
```

This is the single piece of plumbing that Sprints 1, 2.5 step 1 (clipboard), 2.5 step 2
(sidebar reorganization), 2.5 step 3 (⌘K palette), and 2.5 step 4 (drag-and-drop) all
share. Building Sprint 1 tools without it means every new tool gets registered in three
or four places; you'd be refactoring during Sprint 2.5. Migrate the existing seven onto
it as the first acceptance test.

**3. Lock the tool-ID convention.** Pick snake_case stable IDs (`base64_text`,
`jwt_debugger`, `unix_timestamp`) and commit to them — they end up in settings
keys, and eventually CLI subcommand names. Renaming later is a data migration.

**4. ClipboardDetector interface (contract only, no implementations yet).** Add to
`lib/common/clipboard/`:

```dart
abstract class ClipboardDetector {
  /// Higher = checked first. Disambiguates e.g. JWT (also base64-shaped).
  int get priority;
  bool canHandle(String input);
}
```

Why now: every Sprint 1 tool should declare its detector at the same time as the rest of
the tool. By the time Sprint 2.5 step 1 lands, you'll already have ~19 detectors. Adding
them retroactively means re-reading 19 tools to remember what each one accepts.

**5. Extract a shared `ToolScaffold` widget.** If your existing seven tools already share
an input/output/actions layout (CopyButton, ClearTextIcon, FlexActionBar look like the
right pieces), pull the layout itself into one reusable widget so Sprint 1 tools compose
it rather than rebuild it. Cheapest version: a few named slots (`input`, `output`,
`actions`, `options`). If they don't share one yet, this is the time.

>> Reuse for tools that share simple data transformation logic, some tools like JWT decode or multi convert like times might not adhere and such this should not be the base template for everything but a reusable screen

**Estimated effort:** ~0.5–1 day.

**What deliberately doesn't go in Sprint 0.5:**

- **Drift database for settings + history.** Drift is a SQL ORM with code generation,
  schema migrations, and a native SQLite binary on each platform. Settings are a flat
  key→value map (use `shared_preferences`); per-tool input history is one large string
  per tool ID (use Hive). Neither has relational queries, joins, or full-text search
  needs. Revisit Drift only if a future tool actually wants structured query — saved
  snippets with search, for example.
- **Riverpod migration.** The JSON Formatter using Riverpod while the other six tools
  use ChangeNotifier is a small tax, not a problem. Pick a direction *after* Sprint 2.5,
  when shared state (clipboard registry, settings, tool visibility) actually exists and
  Riverpod's providers have something to do.
- **Platform-adaptive theming** (Cupertino/Fluent/MaterialYou). In the market study as a
  recommendation, but not in the first five sprints; don't speculatively build it.
- **Plugin system / dynamic tool loading.** Sprint 2.5's "hide tool" toggle delivers 90%
  of the user-visible benefit (curate your set) without the architectural cost.

### Sprint 1: "The universal core"

Goal: be a credible replacement for "I'll just google a base64 decoder." After this sprint
the app has 19 tools and covers the most-shared utilities across all competitors.

The 12 highest-priority tools (score ≥ 2.5):

1. URL encode/decode 
2. Unix timestamp ↔ ISO date (with timezone)
3. QR code generator + reader 
4. Query string → JSON 
5. String inspector (chars / bytes / words / lines / readability)
6. UUID / ULID generator 
7. Hash generator (MD5, SHA-1, SHA-2, HMAC)
8. Case converter (camel / snake / kebab / pascal / title / constant)
9. HTTP status code reference (zero-input cheatsheet)
10. Cron expression (with next-N-runs preview)



**Estimated effort:** ~5–7 days total — most are sub-hour tools sharing a common
input/output widget pattern.

**Architecture note:** for each tool, keep pure logic in `lib/tools/<tool>/<tool>.dart`
with no Flutter imports. The Controller (MVVM) calls these functions; it doesn't
*contain* the logic. This costs nothing today and keeps a future CLI companion (or
scripting / test reuse) straightforward.

### Sprint 2: "The expected next set"

Goal: cross the threshold of "as complete as DevUtils on the conversion side." After this
sprint the app has 30 tools.

The 9 tools with score 2.0:

11. XML format
12. SQL format
13. JSON ↔ YAML
14. JSON ↔ CSV.
15. Password / random string generator 
16. HTML entity encode/decode 
17. GZIP encode/decode 
18. Lorem ipsum 
19. MIME type lookup 
20. Token generator 
21. MAC address tools

**Estimated effort:** ~7–10 days. All have mature Dart packages.

### Sprint 2.5: "Platform & UX investment"

Stop adding tools. Build the platform around them, in this order. Rationale: 30 tools
without these is worse than 7 with them; this is the single biggest leverage point in the
roadmap. See Part 2 of the market study.

**Order matters.** Items earlier in the list block or enable items later.

1. **Smart clipboard detection on app launch + tray icon.** The marquee
   "feels-native-vs-web-app" feature. On launch (or on hotkey via tray), inspect
   `Clipboard.getData()` and route to the most likely tool (or auto-paste it). Build a
   simple detector registry: each tool exposes a `bool canHandle(String input)` predicate
   (JSON-shape, base64-shape, JWT-shape, timestamp range, URL-encoded shape, etc.). The
   registry runs them in priority order and picks the best match. *Packages:*
   `system_tray`, `hotkey_manager`, `window_manager`.

2. **Config wizard: tool reorder + hide.** The sidebar stays flat — it is just an
   ordered, filtered subset of `toolRegistry`. Categories are metadata, not nav structure.
   A settings screen (wizard) exposes two actions:

   - **Organize tab** — `ReorderableListView` of visible tools; drag handles let the user
     define their own sidebar order. Persisted as an ordered `List<String>` of tool IDs
     in `shared_preferences`.
   - **Show/Hide tab** — all tools grouped by `ToolCategory` (Encoders, Formatters, …)
     with toggle switches. Hidden tools stay reachable via the ⌘K palette (step 3).
     Persisted as a `Set<String>` of hidden IDs in `shared_preferences`.

   `ToolCategory` is already on every `ToolDescriptor`; it is only referenced in the
   wizard, never in the nav rail. Default (empty prefs) = registry order, all visible.
   Pinning/favorites come free later as the inverse of hide.

3. **Global ⌘K / Ctrl+K command palette.** Substring + fuzzy match across tool names,
   categories, and aliases. After tool reorganization is in, this becomes trivial — the
   palette searches the same registry the sidebar uses, and it includes hidden tools.

4. **Global drag-and-drop file input.** Drop a file anywhere in the window; the app
   detects type and routes to the right tool (drop a `.json` → JSON formatter, drop a
   `.crt` → cert decoder, drop an image → Base64 image encoder). Reuses the same
   detector registry from step 1 — the input is now "what's on the clipboard *or* what
   got dropped." *Packages:* `desktop_drop`, `cross_file`.

5. **Real-time output as a configurable setting.** Default: on. Setting: "Process as you
   type" toggle (global, with per-tool override available). For most tools this is
   correct; for expensive operations (large diffs, regex over huge inputs, full X.509
   verification) the user can disable it and use an explicit "Run" button.
   Architecturally: every Controller exposes `bool autoRun` and a `run()` method; the
   input field's `onChanged` calls `run()` only if `autoRun` is true.

6. **Per-tool persistent input history.** drift keyed by tool ID. Input box remembers
   the last value across sessions per tool. Tiny but freeing — users stop fearing
   accidental clears.

**CLI-readiness hygiene pass.** Not a new feature; an audit. Every tool's pure-logic
file in `lib/tools/<tool>/<tool>.dart` must have no Flutter imports and take plain Dart
types in/out. This makes a future `dev_tools_cli` package (Dart compiles to a native
binary) a wrapper exercise, not a rewrite. Add unit tests at this layer if they don't
exist yet — the project's existing test posture is controller-layer, which is close but
not the same. CLI itself is deferred; keeping the code CLI-friendly is not.

**Estimated effort:** ~6–8 days. Clipboard detection, tray integration, and the detector
registry are the long pole; once that's in, steps 3 and 4 reuse the same registry and
go quickly.

### Sprint 3: "Differentiators"

Goal: stop being "another DevToys clone." Pick the tools that DevUtils-quality apps have
that web competitors don't, and that justify someone keeping the app open.

The 9 tools with score 1.25–1.7:

22. Regex tester (with capture group highlighting) — *pure-Dart `RegExp` v1; flag PCRE2
    FFI as v2 upgrade path*
23. Certificate (X.509) decoder — *`basic_utils` v1; OpenSSL FFI as v2 upgrade path*
24. Color converter + picker
25. Text diff (side-by-side)
26. Markdown preview (pair with Markdown → HTML)
27. YAML format
28. JSONPath tester
29. IPv4 subnet calculator
30. User-agent parser

**Estimated effort:** ~10–12 days. Text diff alone is ~3 days of UI work.

### Sprint 4: "Earned breadth"

Optional. Tier 2 leftovers and a couple of niche but cheap wins:

31. Base64 file (any) — extension of existing Base64 tool
32. Backslash escape/unescape
33. WiFi QR code (extends QR tool)
34. HTML preview
35. IPv4 / IPv6 utils (extends subnet calc)
36. Bcrypt
37. Hash extras — SHA-3, BLAKE3 (matches DevUtils' Keccak-256 for blockchain devs)

After Sprint 4 the app sits at ~37 tools — comparable to DevToys (30 + plugins) and
DevTools-X (41), well below it-tools (86), without taking on the maintenance surface of
breadth-first apps.

### Sprint 5: "FFI investment" (optional, differentiator)

Only worth doing if (a) Sprints 1–4 are landed, (b) you want a genuine differentiator
vs. DevUtils/DevToys, and (c) you're willing to take on the permanent release-engineering
overhead of shipping native binaries.

**Phase A — One-time FFI plumbing (~2 days):**

- Set up `dart_ffi` + `ffigen` for binding generation
- CI/CD: build-time binary bundling for Linux / macOS / Windows (Android/iOS if mobile
  is in scope)
- Conditional-import skeleton: every FFI tool has an `<tool>_io.dart` and
  `<tool>_web.dart` pair
- Decide web strategy per tool: skip / pure-Dart fallback / "available on desktop" notice

**Phase B — Payoff tools, in priority order:**

1. **Code Formatter (single tool, multi-language)** — FFI to `dprint` (Rust). One tool
   with a language dropdown that handles JS, TS, CSS, HTML, Markdown, JSON, TOML, YAML.
   This *replaces* the rejected standalone JS/CSS/HTML formatter tools with something
   strictly better — a genuine differentiator versus DevUtils (which has them as
   separate tools) and a huge convenience win. Score: useful 4 / complex 3 (one-time
   FFI work) / **1.3**. Web fallback: skip with "available on desktop" notice.

2. **Regex tester v2** — FFI to PCRE2. Handles lookbehinds, possessive quantifiers,
   Unicode property escapes, and other expressions Dart's `RegExp` can't. Web fallback:
   pure-Dart `RegExp`, warn on unsupported syntax.

3. **Certificate decoder v2** — FFI to OpenSSL. Full X.509 + verification + OCSP +
   certificate chain + CT log check. Web fallback: keep `basic_utils` version.

4. **Text diff v2** — FFI to Rust `similar`. Only worth it if real perf complaints emerge
   for multi-thousand-line inputs. Otherwise leave `diff_match_patch`. Web fallback:
   pure-Dart `diff_match_patch`.

**Estimated effort:** ~5 days for Phase A + payoff #1; Phase B items 2–4 are 1–2 days
each *if* Phase A is solid.

**Honest tradeoff.** Phase A is a permanent ~30 min/release tax on release engineering
and a CI matrix expansion. Don't take this on for one tool — only do Sprint 5 if you're
committing to at least the Code Formatter and one other FFI tool. The Code Formatter
alone is probably worth it on its own merits, since it replaces three "don't build"
entries with a single, genuinely-better-than-competitors tool.

### Don't build

Scored < 1.0 and not improved by FFI. Kept here so a future contributor can see the
reasoning rather than re-raise them:

- **cURL → code** (0.75) — needs a real cURL parser; DevUtils owns it; no mature C/Rust
  library does it end-to-end, so FFI doesn't rescue this.
- **Docker run → docker-compose** (0.75) — DevUtils.lol owns it; no library does it; pure
  parser work.
- **WebSocket / Socket.IO tester** (0.75) — out of scope for a "stateless conversion"
  app; would invite real API-testing scope creep.
- **JSON → typed code (quicktype)** (0.6) — quicktype is TypeScript; bridging is brittle;
  not differentiable from running the CLI.
- **JSON ↔ XML** (0.7) — schema loss makes the round-trip lossy and the result
  unsatisfying.

Note: standalone JS/CSS/HTML formatters were here in v1 of this plan; they've moved to
Sprint 5 Phase B as a single Code Formatter tool, which is strictly better.

---

## Where the matrix lands you

After Sprints 0.5 + 1 + 2 + 2.5, the app has:

- 30 tools (≈ DevToys parity, comfortably above DevTools-X's well-tested core)
- All universally-supported tools
- Smart clipboard detection, ⌘K search, configurable real-time output, global
  drag-and-drop, per-tool persistence, tray icon, hide-tool curation
- Cross-platform native (your existing Flutter base)
- A CLI-ready architecture, even though no CLI ships yet

After Sprint 3, it crosses into "DevUtils-quality on Linux/Windows" territory.

After Sprint 5 (optional), it has *one tool DevUtils doesn't*: a single multi-language
code formatter with consistent behavior across formats. That's the kind of feature that
gets the app on r/programming.

That is the "DevUtils-quality UX, cross-platform, free, mobile-included" positioning from
the market study — reached with a finite, ordered backlog rather than open-ended scope.

---

## Sources

- Market study (`market_study.md` in this project)
- pub.dev package availability verified for: `crypto`, `uuid`, `ulid`, `diff_match_patch`,
  `flex_color_picker`, `flutter_colorpicker`, `cron_parser`, `cron`, `basic_utils`,
  `qr_flutter`, `mobile_scanner`, `timezone`, `yaml`, `xml`, `csv`, `markdown`,
  `flutter_markdown`, `json_path`, `mime`, `html_unescape`, `bcrypt`, `recase`,
  `pointycastle`, `desktop_drop`, `system_tray`, `hotkey_manager`, `window_manager`.
- FFI candidates: `dprint` (Rust, multi-lang formatter), `pcre2` (C, regex), OpenSSL
  (C, X.509), `similar` (Rust, diff), `pulldown-cmark` (Rust, Markdown), `tiny-keccak`
  (Rust, SHA-3 family).