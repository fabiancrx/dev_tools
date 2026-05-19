# Market Study — Local Developer Utilities

A comparison of `dev_tools` against the named competitors plus one direct spiritual sibling
(DevTools-X), followed by recommendations on tools and UX patterns.

**Subject app:** [`fabiancrx/dev_tools`](https://github.com/fabiancrx/dev_tools) — Flutter desktop,
MVVM, en+es localized, Yaru/Ubuntu theme.

**Competitors studied:** DevUtils.com, DevToys, DevUtils.lol, it-tools.tech, plus DevTools-X
(bonus — closest direct comparable).

---

## At a glance

| App                 | Tool count          | Platform                                | Distribution                  | Stance                        |
| ------------------- | ------------------- | --------------------------------------- | ----------------------------- | ----------------------------- |
| **`dev_tools`**     | 7                   | Win/macOS/Linux/Web/Android/iOS (Flutter) | Source-only so far          | Native, MVVM, en+es localized |
| **DevUtils.com**    | 47+                 | macOS only                              | $29 one-time / Setapp / brew  | Paid, native, polished        |
| **DevToys**         | 30 + plugins        | Win/macOS/Linux (.NET MAUI)             | Free, open source, MS Store   | Cross-platform, extensible    |
| **DevUtils.lol**    | ~12 visible, growing | Browser/PWA                             | Free, web                     | Privacy-first, WASM           |
| **it-tools.tech**   | 86 across 10 categories | Browser, self-host Docker            | Free, GPL-3.0                 | Maximalist, breadth-first     |
| **DevTools-X** (bonus) | 41               | Win/macOS/Linux (Tauri)                 | Free, open source, ~10MB      | Spiritual sibling             |

DevTools-X is worth knowing about because it's the closest comparable to what you're building —
non-Electron, cross-platform desktop, single-developer led, ~10MB. Their explicit pitch is that
DevUtils is macOS-only and DevToys was Windows-first, so cross-platform desktop is the unclaimed
niche. That niche is exactly where Flutter fits.

---

## Part 1 — Tool inventory comparison

Grouped the way it-tools groups them, since their taxonomy is the most thought-out.
✅ = present, ❌ = absent, ⚠️ = partial.

### Encoders & decoders

| Tool                          | dev_tools | DevUtils | DevToys | DevUtils.lol | it-tools |
| ----------------------------- | --------- | -------- | ------- | ------------ | -------- |
| Base64 text                   | ✅        | ✅       | ✅      | ✅           | ✅       |
| Base64 image                  | ✅        | ✅       | ✅      | ❌           | ✅       |
| Base64 file (any)             | ❌        | ❌       | ❌      | ❌           | ✅       |
| URL encode/decode             | ❌        | ✅       | ✅      | ✅           | ✅       |
| HTML entity encode/decode     | ❌        | ✅       | ✅      | ❌           | ✅       |
| JWT debug/decode              | ✅        | ✅       | ✅      | ✅           | ✅       |
| Certificate (X.509) decoder   | ❌        | ✅       | ✅      | ❌           | ❌       |
| GZIP encode/decode            | ❌        | ❌       | ✅      | ❌           | ❌       |
| Backslash escape/unescape     | ❌        | ✅       | ✅      | ❌           | ❌       |

### Formatters

| Tool                       | dev_tools | DevUtils | DevToys | DevUtils.lol | it-tools |
| -------------------------- | --------- | -------- | ------- | ------------ | -------- |
| JSON format/validate       | ✅        | ✅       | ✅      | ✅           | ✅       |
| JSON escape/unescape       | ✅        | ✅       | ✅      | ❌           | ❌       |
| XML format                 | ❌        | ✅       | ✅      | ❌           | ✅       |
| SQL format                 | ❌        | ✅       | ✅      | ❌           | ✅       |
| HTML format                | ❌        | ✅       | ❌      | ❌           | ❌       |
| CSS/SCSS/LESS format       | ❌        | ✅       | ❌      | ❌           | ❌       |
| JS format/minify           | ❌        | ✅       | ❌      | ❌           | ❌       |
| YAML format                | ❌        | ❌       | ❌      | ❌           | ✅       |

### Converters

| Tool                          | dev_tools | DevUtils | DevToys | DevUtils.lol | it-tools |
| ----------------------------- | --------- | -------- | ------- | ------------ | -------- |
| Number base (hex/dec/oct/bin) | ✅        | ✅       | ✅      | ❌           | ✅       |
| Hex ↔ ASCII                   | ✅        | ✅       | ❌      | ❌           | ❌       |
| Unix timestamp ↔ date         | ❌        | ✅       | ✅      | ❌           | ✅       |
| JSON ↔ YAML                   | ❌        | ✅       | ✅      | ❌           | ✅       |
| JSON ↔ CSV                    | ❌        | ✅       | ✅      | ❌           | ✅       |
| JSON ↔ TOML                   | ❌        | ❌       | ❌      | ❌           | ✅       |
| JSON ↔ XML                    | ❌        | ❌       | ❌      | ❌           | ✅       |
| Markdown → HTML               | ❌        | ❌       | ❌      | ❌           | ✅       |
| Color converter (hex/rgb/hsl) | ❌        | ✅       | ❌      | ✅           | ✅       |
| Case converter                | ❌        | ✅       | ❌      | ❌           | ✅       |
| cURL → code                   | ❌        | ✅       | ❌      | ❌           | ❌       |
| JSON → typed code (quicktype) | ❌        | ✅       | ✅      | ❌           | ❌       |
| Docker run → docker-compose   | ❌        | ❌       | ❌      | ✅           | ✅       |
| Query string → JSON           | ❌        | ✅       | ❌      | ❌           | ✅       |

### Generators

| Tool                          | dev_tools | DevUtils | DevToys | DevUtils.lol | it-tools |
| ----------------------------- | --------- | -------- | ------- | ------------ | -------- |
| UUID / ULID                   | ❌        | ✅       | ✅      | ❌           | ✅       |
| Hash (MD5/SHA1/SHA2/HMAC)     | ❌        | ✅       | ✅      | ❌           | ✅       |
| Bcrypt                        | ❌        | ❌       | ❌      | ❌           | ✅       |
| Lorem ipsum                   | ❌        | ✅       | ✅      | ❌           | ✅       |
| Password / random string      | ❌        | ✅       | ✅      | ❌           | ✅       |
| QR code                       | ❌        | ✅       | ✅      | ❌           | ✅       |
| WiFi QR code                  | ❌        | ❌       | ❌      | ❌           | ✅       |
| Cron expression               | ❌        | ✅       | ✅      | ✅           | ✅       |
| RSA / SSH key pair            | ❌        | ❌       | ❌      | ❌           | ✅       |
| Token generator               | ❌        | ❌       | ❌      | ❌           | ✅       |

### Inspectors / testers

| Tool                              | dev_tools | DevUtils | DevToys | DevUtils.lol | it-tools |
| --------------------------------- | --------- | -------- | ------- | ------------ | -------- |
| Regex tester                      | ❌        | ✅       | ✅      | ❌           | ✅       |
| Text diff                         | ❌        | ✅       | ✅      | ✅           | ✅       |
| Markdown preview                  | ❌        | ✅       | ✅      | ❌           | ❌       |
| HTML preview                      | ❌        | ✅       | ❌      | ❌           | ❌       |
| String inspector (char count, …)  | ❌        | ✅       | ✅      | ❌           | ✅       |
| JSONPath tester                   | ❌        | ❌       | ✅      | ❌           | ❌       |
| Log parser / scrubber             | ❌        | ❌       | ❌      | ✅           | ❌       |

### Network / IT

| Tool                          | dev_tools | DevUtils | DevToys | DevUtils.lol | it-tools |
| ----------------------------- | --------- | -------- | ------- | ------------ | -------- |
| IPv4 subnet calculator        | ❌        | ❌       | ❌      | ❌           | ✅       |
| IPv4/IPv6 utils               | ❌        | ❌       | ❌      | ❌           | ✅       |
| MAC address tools             | ❌        | ❌       | ❌      | ❌           | ✅       |
| HTTP status code reference    | ❌        | ❌       | ❌      | ❌           | ✅       |
| MIME type lookup              | ❌        | ❌       | ❌      | ❌           | ✅       |
| User-agent parser             | ❌        | ❌       | ❌      | ❌           | ✅       |
| WebSocket / Socket.IO tester  | ❌        | ❌       | ❌      | ✅           | ❌       |

### Coverage summary

Your seven tools all overlap with the universally-supported core (Base64 text, Base64 image,
JSON format, JSON escape, JWT, number base, hex↔ASCII). Zero unique tools so far — which is fine
for a young project, but a thing to be aware of. The most-shared tools you're missing are: URL
encode/decode, text diff, UUID, hash generator, regex tester, Unix timestamp, JSON↔YAML, color
converter. Those eight appear in 3-4 of 4 competitors and are cheap to implement.

---

## Part 2 — UX & DX patterns (separate from tool count)

This is the section that matters more given your "just enough, get out of the way" thesis. Tool
count is a vanity metric; what makes these apps feel good is the surrounding fabric.

**Smart clipboard detection.** DevUtils and DevToys both detect what's on the clipboard the
moment the app opens and route you to the right tool (or even auto-paste it). DevUtils does this
as a menu-bar dropdown: hotkey → glance → done. This is probably the single highest-impact UX
pattern in this category and neither web competitor (it-tools, devutils.lol) can match it. Native
desktop is your edge here. Implementation in Flutter is one `Clipboard.getData()` call plus a
registry of tool detectors (regex/JSON-shape/base64-shape probes). High value, low cost.

**Global keyboard-driven search / command palette.** It-tools has instant fuzzy search across all
86 tools — typing two letters narrows the grid. DevUtils has it. DevToys has it. DevUtils.lol has
it (⌘K). It's table stakes once tool count crosses ~15. Implement once with a
`RawKeyboardListener` + simple substring match before adding tool #15.

**Favorites / pinning.** It-tools pins favorites to the top of the grid. DevToys has jump-list
integration. With 7 tools you don't need this; with 25+ you do.

**Menu bar / tray / Picture-in-Picture mode.** DevUtils lives in the macOS menu bar and opens
with a hotkey. DevToys has Compact Overlay mode on Windows so the app shrinks into a floating
mini-window over your IDE. This is the "get out of the way" pattern in physical form — the app is
never more than a hotkey away and never takes over the screen. Flutter desktop can do
`system_tray` and `window_manager` packages for this; one of the better leverage points.

**Multi-instance / tabs.** DevToys allows multiple instances so you can compare two JSON blobs
side-by-side, or do two encodes at once. DevUtils opens each tool in its own area but lets you
keep state per tool. Tabs inside a single window is the cheapest way to get there in Flutter.

**Persistent input history per tool.** When I encode something in DevUtils, the input box
remembers what I had there last time I opened the app — across sessions. Tiny but enormously
freeing because you stop fearing accidental clears. Hive or shared_preferences, keyed by tool ID.

**Code-editor-quality input field.** DevTools-X explicitly uses Monaco (VS Code's editor) because
the input is often code: syntax highlighting, line numbers, find/replace, fold. DevToys uses a
"rich code editor." Your README mentions a `common/code field` — worth checking if it has syntax
highlighting and find. `code_text_field` or `re_editor` on pub.dev are the Flutter equivalents.

**Drag-and-drop file input.** Already implemented in your Base64 image tool — good. Worth
applying universally (drop a JSON file onto the JSON formatter, drop a cert onto a cert decoder,
etc.).

**Real-time output (no "Convert" button).** All four competitors process as you type. Your
current Base64 tool needs the codec selector but otherwise this should be the default everywhere.

**Smart Detection of input format inside a tool.** DevUtils' number base converter auto-detects
whether you pasted `0xFF`, `0b1010`, or `255` — you don't pick the source base, only the targets.
Same with `1611241901` going straight to Unix time. This is the "get out of the way" doctrine
applied per-tool.

**Themed integration with the host OS.** Your Yaru/Ubuntu theme is one good example. DevUtils
does macOS native. DevToys does Fluent/WinUI. The cross-platform win is *adapting* per platform:
Yaru on Linux, Cupertino on macOS, Material You on Android, Fluent on Windows. Flutter can do
this with platform checks.

**CLI companion.** DevToys ships a separate `DevToys CLI` so the same conversions are usable in
scripts and CI. This is a long-tail feature but a real one — Dart compiles to a native binary, so
the same logic could be wrapped as `dev_tools b64 encode -i file.txt`. Probably out of scope
short-term but the architecture choice (keep tool logic pure, separate from UI) determines
whether it's possible later.

**Plugin / extensibility.** DevToys lets community devs publish tools via NuGet; DevUtils.lol
takes community PRs into a community repo. For a small project, plugins are overengineering; but
a clean "one folder per tool, register in a manifest" structure (which you already have under
`lib/tools/`) keeps the door open.

**Integrations with launcher apps.** DevUtils integrates with Alfred and Raycast on macOS so you
can fire a conversion from the launcher without opening the app. This is the apex of "get out of
the way." On Linux/Windows the equivalents are Rofi, Albert, PowerToys Run.

**Localization.** You have en+es. None of the desktop competitors are heavily localized;
it-tools has ~10 languages. Not a differentiator but worth maintaining as you grow.

---

## Part 3 — What's unique to each competitor (worth stealing or sidestepping)

**DevUtils.com unique strengths:** native macOS feel, smart clipboard detection done extremely
well, breadth of formatters (HTML, CSS, LESS, SCSS, SQL), Alfred/Raycast integration, certificate
decoder, cURL → code, PHP-specific tools. Weakness: paid + macOS-only — you can poach the entire
market segment that wants the UX on Linux/Windows.

**DevToys unique strengths:** plugin ecosystem via NuGet, CLI companion, Compact Overlay mode,
JSONPath, GZIP encode/decode, color blind simulator. Weakness: tied to .NET MAUI which has
rougher Linux support than Flutter — your Linux story can be cleaner.

**DevUtils.lol unique strengths:** Terraform state visualizer, log scrubber (strips PII from
logs), Docker run → compose, Nginx config generator, image editor, socket client. These are
higher-order tools — workflow-shaped rather than single-conversion. Weakness: browser-only means
no clipboard auto-paste, no menu bar, no file drag from OS.

**it-tools.tech unique strengths:** sheer breadth (86), great categorization, network tools
(subnet calc, MAC tools), reference tools (HTTP status, MIME types — *just lookup, no input*),
favorites, Docker-deployable. Weakness: web app, no OS integration. Breadth is also a maintenance
trap if you mimic it.

**DevTools-X unique strengths:** Monaco editor reuse, settings backup/restore (export your
config), uses Tauri so binary is ~10MB. Settings export is a nice feature for a power user who
wants to sync their setup across machines.

---

## Part 4 — Recommendations

### Tools to add, prioritized by "shared across competitors × cheap to build"

**Tier 1 — the universal seven**, all under a day each, all expected by anyone trying your app:

1. URL encode/decode
2. UUID v4 / v7 generator
3. Hash generator (MD5, SHA-1/256/512, HMAC) — `crypto` package
4. Unix timestamp ↔ ISO date — with timezone selector
5. Text diff — `diff_match_patch` package
6. Regex tester with capture group display
7. Color converter (hex / rgb / hsl / cmyk) — with picker

**Tier 2 — high value, slightly more work:**

8. JSON ↔ YAML and JSON ↔ CSV
9. QR code generator + reader — `qr_flutter` + `mobile_scanner`
10. Lorem ipsum
11. Markdown preview
12. Case converter (camel/snake/kebab/pascal/title)

**Tier 3 — differentiators worth thinking about because they raise quality bar, not count:**

- Certificate (X.509) decoder — DevUtils has it, web competitors don't, it's a "I'd switch apps
  just for this" tool
- Cron expression parser with next-N-runs preview
- HTTP status code + MIME type reference panes — zero-input tools, basically a styled cheatsheet

### UX patterns to adopt, in order of leverage

1. **Global search / ⌘K palette** — non-negotiable before you cross ~15 tools.
2. **Clipboard auto-detect on app launch** — your single biggest "feels native" win versus the
   web competitors. Native desktop's whole reason to exist.
3. **Per-tool persistent input** — Hive box keyed by tool ID.
4. **Within-tool auto-detect** — number base, base64, JSON-vs-Base64, all detectable from the
   input shape.
5. **Real-time output everywhere** — kill any "convert" buttons.
6. **Drag-and-drop file input on every text tool**, not just images.
7. **Tray/menu-bar app with global hotkey** — turns it from "an app I open" into "an app I
   summon." `system_tray` + `hotkey_manager` packages.
8. **Tabs or split view** — second-order, but cheap once you have it.
9. **Code-editor input field** with syntax highlight + find for JSON/XML/SQL screens.
10. **Platform-adaptive theming** — Yaru on Linux, Cupertino on macOS, Fluent on Windows,
    Material You on Android.

### What NOT to copy

It-tools' breadth-first count. 86 tools means 86 maintenance surfaces; the moment a Flutter
package breaks, you have 86 places to look. Your `lib/tools/`-per-tool architecture is right;
just be disciplined about which ones earn entry.

### Strategic positioning

The unclaimed niche is "DevUtils-quality UX, cross-platform, free, mobile-included." Flutter buys
you all four.

- DevUtils owns macOS-paid.
- DevToys owns Windows-extensible.
- It-tools owns web-maximalist.
- DevUtils.lol owns browser-privacy.
- DevTools-X is your only direct competitor in "cross-platform native open-source desktop" — and
  they have 41 tools but a "modules not well tested on all 3 OSes" caveat.

The gap is reliability + polish, not count.

---

## Sources

- `dev_tools` repository — https://github.com/fabiancrx/dev_tools
- DevUtils.com — https://devutils.com/
- DevToys — https://devtoys.app/
- DevUtils.lol — https://devutils.lol/
- it-tools.tech — tool inventory verified via
  https://chns.tech/posts/2026/03-21-it-tools-handy-tools-for-developers/ (86 tools, 10 categories)
- DevTools-X — https://github.com/fosslife/devtools-x