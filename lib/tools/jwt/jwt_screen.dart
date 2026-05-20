import 'dart:convert';

import 'package:dash_tools/common/extensions.dart';
import 'package:dash_tools/common/utils.dart';
import 'package:dash_tools/l10n/l10n.dart';
import 'package:dash_tools/tools/clipboard_service.dart';
import 'package:dash_tools/tools/jwt/jwt_controller.dart';
import 'package:dash_tools/widgets/copy_button.dart';
import 'package:dash_tools/widgets/flex_action_bar.dart';
import 'package:dash_tools/widgets/time_remaining.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:yaru/yaru.dart';

// JWT segment colours matching jwt.io conventions
const _headerColor = Color(0xFFe17036);
const _payloadColor = Color(0xFF9371f7);
const _signatureColor = Color(0xFF8ec789);
const _dotColor = Color(0xFF888888);

// ── Color-coded token TextEditingController ───────────────────────────────────

class _JwtTokenController extends TextEditingController {
  _JwtTokenController({String text = ''}) : super(text: text);

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final parts = text.split('.');
    if (parts.length != 3) return TextSpan(text: text, style: style);

    const dot = TextSpan(text: '.', style: TextStyle(color: _dotColor));
    return TextSpan(children: [
      TextSpan(text: parts[0], style: style?.copyWith(color: _headerColor)),
      dot,
      TextSpan(text: parts[1], style: style?.copyWith(color: _payloadColor)),
      dot,
      TextSpan(text: parts[2], style: style?.copyWith(color: _signatureColor)),
    ]);
  }
}

// ── Screen ────────────────────────────────────────────────────────────────────

class JwtScreen extends StatefulWidget {
  const JwtScreen({super.key});

  @override
  State<JwtScreen> createState() => _JwtScreenState();
}

class _JwtScreenState extends State<JwtScreen>
    with SingleTickerProviderStateMixin {
  late final _controller = JwtController();
  late final _tokenTec = _JwtTokenController(text: _controller.token);
  late final _secretTec = TextEditingController(text: _controller.secret);
  late final _tabController = TabController(length: 2, vsync: this);

  // Encode tab controllers
  late final _headerTec = TextEditingController(text: _controller.headerJson);
  late final _payloadTec = TextEditingController(text: _controller.payloadJson);
  late final _encodeSecretTec = TextEditingController(text: _controller.secret);

  @override
  void initState() {
    super.initState();
    _tokenTec.addListener(() => _controller.setToken(_tokenTec.text));
    _secretTec.addListener(() => _controller.setSecret(_secretTec.text));
    _headerTec.addListener(() => _controller.setHeaderJson(_headerTec.text));
    _payloadTec.addListener(() => _controller.setPayloadJson(_payloadTec.text));
    _encodeSecretTec.addListener(() {
      _controller.setSecret(_encodeSecretTec.text);
      if (_secretTec.text != _encodeSecretTec.text) {
        _secretTec.text = _encodeSecretTec.text;
      }
    });

    _controller.addListener(() {
      if (_tokenTec.text != _controller.token) _tokenTec.text = _controller.token;
      if (_secretTec.text != _controller.secret) _secretTec.text = _controller.secret;
      if (_encodeSecretTec.text != _controller.secret) _encodeSecretTec.text = _controller.secret;
      if (_headerTec.text != _controller.headerJson) _headerTec.text = _controller.headerJson;
      if (_payloadTec.text != _controller.payloadJson) _payloadTec.text = _controller.payloadJson;
    });
  }

  @override
  void dispose() {
    _tokenTec.dispose();
    _secretTec.dispose();
    _headerTec.dispose();
    _payloadTec.dispose();
    _encodeSecretTec.dispose();
    _tabController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ActionBar(controller: _controller, tabController: _tabController),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _DecodeTab(
                controller: _controller,
                tokenTec: _tokenTec,
                secretTec: _secretTec,
                tabController: _tabController,
              ),
              _EncodeTab(
                controller: _controller,
                headerTec: _headerTec,
                payloadTec: _payloadTec,
                secretTec: _encodeSecretTec,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Action bar ────────────────────────────────────────────────────────────────

class _ActionBar extends StatelessWidget {
  final JwtController controller;
  final TabController tabController;

  const _ActionBar({required this.controller, required this.tabController});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return FlexActionBar(
      children: <Widget>[
        Tooltip(
          message: 'Paste from clipboard',
          child: YaruOptionButton(
            onPressed: () async {
              final text = await getClipboardContent();
              if (text != null && text.isNotEmpty) {
                controller.setToken(text);
                tabController.animateTo(0);
              }
            },
            child: const Icon(Icons.paste_rounded),
          ),
        ),
        CopyButton(
          showText: false,
          copyCallback: () => pasteContentToClipboard(controller.token),
        ),
        Tooltip(
          message: 'Clear',
          child: YaruOptionButton(
            onPressed: controller.clear,
            child: const Icon(Icons.clear_rounded),
          ),
        ),
        Tooltip(
          message: 'Load sample token',
          child: YaruOptionButton(
            onPressed: controller.populate,
            child: const Icon(Icons.data_object_rounded),
          ),
        ),
        const Spacer(),
        TabBar(
          controller: tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.center,
          tabs: [
            Tab(text: l10n.jwtDecode),
            Tab(text: l10n.jwtEncode),
          ],
        ),
        const Spacer(),
        Tooltip(
          message: l10n.whatIsJwt,
          child: YaruOptionButton(
            onPressed: () => launchUrlString('https://www.rfc-editor.org/rfc/rfc7519'),
            child: const Icon(Icons.info_outline),
          ),
        ),
      ].interleave(const SizedBox(width: 8)),
    );
  }
}

// ── Decode tab ────────────────────────────────────────────────────────────────

class _DecodeTab extends StatelessWidget {
  final JwtController controller;
  final TextEditingController tokenTec;
  final TextEditingController secretTec;
  final TabController tabController;

  const _DecodeTab({
    required this.controller,
    required this.tokenTec,
    required this.secretTec,
    required this.tabController,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final l10n = context.l10n;
        final jwt = controller.jwt;
        return Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Left: encoded token + status ──────────────────────────────
              Expanded(
                child: ListView(
                  children: [
                    const SizedBox(height: 4),
                    const _ColorLegend(),
                    const SizedBox(height: 6),
                    TextField(
                      maxLines: null,
                      minLines: 4,
                      style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
                      decoration: InputDecoration(label: Text(l10n.jwtTokenLabel)),
                      controller: tokenTec,
                    ),
                    const SizedBox(height: 8),
                    if (controller.hasToken)
                      Row(
                        children: [
                          _StatusBadge(controller: controller),
                          const Spacer(),
                          if (jwt != null)
                            Tooltip(
                              message: l10n.jwtEditInEncoder,
                              child: TextButton.icon(
                                onPressed: () {
                                  controller.editInEncoder();
                                  tabController.animateTo(1);
                                },
                                icon: const Icon(Icons.edit_outlined, size: 14),
                                label: Text(l10n.jwtEditInEncoder,
                                    style: const TextStyle(fontSize: 12)),
                              ),
                            ),
                        ],
                      ),
                    if (controller.error.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4, left: 4),
                        child: Text(
                          controller.error,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontSize: 12,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                    if (controller.isInsecureAlgorithm)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.errorContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.warning_amber_rounded,
                                  color: Theme.of(context).colorScheme.onErrorContainer,
                                  size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  l10n.jwtInsecureAlgorithmWarning,
                                  style: TextStyle(
                                      color: Theme.of(context).colorScheme.onErrorContainer,
                                      fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    // Date strip: iat, nbf, exp
                    if (jwt != null &&
                        (controller.issuedDate != null ||
                            controller.notBeforeDate != null ||
                            controller.expirationDate != null))
                      Padding(
                        padding: const EdgeInsets.only(top: 12, left: 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (controller.issuedDate case final iat?)
                              Text(l10n.issuedOn(formatDateTime(iat)),
                                  style: Theme.of(context).textTheme.bodyLarge),
                            if (controller.notBeforeDate case final nbf?)
                              nbf.isAfter(DateTime.now())
                                  ? Row(
                                      children: [
                                        Icon(Icons.schedule_rounded,
                                            size: 14,
                                            color: Theme.of(context).colorScheme.error),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            '${l10n.jwtNotValidBefore(formatDateTime(nbf))} — ${l10n.jwtNotYetValid}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge
                                                ?.copyWith(
                                                    color: Theme.of(context).colorScheme.error),
                                          ),
                                        ),
                                      ],
                                    )
                                  : Text(l10n.jwtNotValidBefore(formatDateTime(nbf)),
                                      style: Theme.of(context).textTheme.bodyLarge),
                            if (controller.expirationDate case final exp?)
                              exp.isBefore(DateTime.now())
                                  ? Text(
                                      l10n.expiredOn(formatDateTime(exp)),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(color: Theme.of(context).colorScheme.error),
                                    )
                                  : DefaultTextStyle(
                                      style: (Theme.of(context).textTheme.bodyLarge ??
                                              const TextStyle())
                                          .copyWith(
                                              color: Theme.of(context).colorScheme.success),
                                      child: TimeRemaining(
                                        text: (d) => l10n.expiresOn(formatDateTime(exp), d),
                                        duration: exp.difference(DateTime.now()),
                                        onTimeOver: controller.refresh,
                                      ),
                                    ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // ── Right: header, payload, signature ─────────────────────────
              Expanded(
                child: ListView(
                  children: [
                    const SizedBox(height: 4),
                    if (jwt?.header case final header?)
                      _JwtDetails(
                        data: header,
                        title: l10n.jwtHeader,
                        color: _headerColor,
                        initialBreakdown: false,
                      ),
                    if (jwt != null) ...[
                      const SizedBox(height: 8),
                      _JwtDetails(
                        data: jwt.payload,
                        title: l10n.jwtPayload,
                        color: _payloadColor,
                        initialBreakdown: true,
                      ),
                    ],
                    const SizedBox(height: 8),
                    _SignatureSection(controller: controller, secretTec: secretTec),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Color legend ──────────────────────────────────────────────────────────────

class _ColorLegend extends StatelessWidget {
  const _ColorLegend();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _LegendDot(
          color: _headerColor,
          label: 'Header',
          tooltip: 'Base64URL encoded header — algorithm & token type',
        ),
        const SizedBox(width: 16),
        _LegendDot(
          color: _payloadColor,
          label: 'Payload',
          tooltip: 'Base64URL encoded payload — your claims',
        ),
        const SizedBox(width: 16),
        _LegendDot(
          color: _signatureColor,
          label: 'Signature',
          tooltip: 'Cryptographic signature of header.payload',
        ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  final String tooltip;

  const _LegendDot({required this.color, required this.label, required this.tooltip});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// ── Status badge ──────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final JwtController controller;

  const _StatusBadge({required this.controller});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cs = Theme.of(context).colorScheme;
    final alg = controller.jwt?.header?['alg'] as String?;

    final (icon, label, color, tooltip) = switch ((
      controller.jwt != null,
      controller.signatureValid,
    )) {
      (false, _) => (
          Icons.cancel_outlined,
          l10n.jwtInvalid,
          cs.error,
          'Token structure is malformed or not a valid JWT',
        ),
      (true, true) => (
          Icons.verified_outlined,
          l10n.jwtSignatureVerified,
          cs.success,
          'Signature is valid — verified using the provided HMAC secret',
        ),
      (true, false) => (
          Icons.gpp_bad_outlined,
          l10n.jwtSignatureInvalid,
          cs.error,
          'Signature check failed — the secret or token is incorrect',
        ),
      (true, null) => (
          Icons.check_circle_outline,
          l10n.jwtValid,
          cs.success,
          'Token structure is valid — enter a secret to verify the signature',
        ),
    };

    return Row(
      children: [
        Tooltip(
          message: tooltip,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 6),
              Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        if (alg != null) ...[
          const SizedBox(width: 12),
          _AlgorithmPill(alg: alg),
        ],
      ],
    );
  }
}

// ── Algorithm pill ────────────────────────────────────────────────────────────

class _AlgorithmPill extends StatelessWidget {
  final String alg;

  const _AlgorithmPill({required this.alg});

  String get _tooltip => switch (alg.toUpperCase()) {
        'HS256' => 'HMAC with SHA-256 — symmetric key',
        'HS384' => 'HMAC with SHA-384 — symmetric key',
        'HS512' => 'HMAC with SHA-512 — symmetric key',
        'RS256' => 'RSA PKCS#1 with SHA-256 — asymmetric key',
        'RS384' => 'RSA PKCS#1 with SHA-384 — asymmetric key',
        'RS512' => 'RSA PKCS#1 with SHA-512 — asymmetric key',
        'ES256' => 'ECDSA with P-256 and SHA-256 — asymmetric key',
        'ES384' => 'ECDSA with P-384 and SHA-384 — asymmetric key',
        'ES512' => 'ECDSA with P-521 and SHA-512 — asymmetric key',
        'PS256' => 'RSA-PSS with SHA-256 — asymmetric key',
        'PS384' => 'RSA-PSS with SHA-384 — asymmetric key',
        'PS512' => 'RSA-PSS with SHA-512 — asymmetric key',
        'NONE' || 'none' => '⚠ No digital signature — insecure, never use in production',
        _ => 'Algorithm: $alg',
      };

  @override
  Widget build(BuildContext context) {
    final isInsecure = alg.toLowerCase() == 'none';
    final color = isInsecure
        ? Theme.of(context).colorScheme.error
        : Theme.of(context).colorScheme.outline;

    return Tooltip(
      message: _tooltip,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color),
        ),
        child: Text(
          alg,
          style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

// ── Signature section ─────────────────────────────────────────────────────────

class _SignatureSection extends StatelessWidget {
  final JwtController controller;
  final TextEditingController secretTec;

  const _SignatureSection({required this.controller, required this.secretTec});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return YaruSection(
      headline: Row(
        children: [
          Text(l10n.jwtVerifySignature, style: const TextStyle(color: _signatureColor)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: secretTec,
              decoration: InputDecoration(
                label: Text(l10n.jwtSecret),
                hintText: 'your-256-bit-secret',
              ),
            ),
            const SizedBox(height: 8),
            Tooltip(
              message: l10n.jwtSecretBase64,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Checkbox(
                    value: controller.isBase64Secret,
                    onChanged: (v) => controller.setBase64Secret(v ?? false),
                  ),
                  Text(l10n.jwtSecretBase64),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Encode tab ────────────────────────────────────────────────────────────────

class _EncodeTab extends StatelessWidget {
  final JwtController controller;
  final TextEditingController headerTec;
  final TextEditingController payloadTec;
  final TextEditingController secretTec;

  const _EncodeTab({
    required this.controller,
    required this.headerTec,
    required this.payloadTec,
    required this.secretTec,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final l10n = context.l10n;
        return Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left column: editors
              Expanded(
                child: ListView(
                  children: [
                    const SizedBox(height: 4),
                    _JsonEditor(
                      label: l10n.jwtEncodeHeader,
                      color: _headerColor,
                      controller: headerTec,
                      isValid: controller.isHeaderJsonValid,
                      minLines: 4,
                    ),
                    const SizedBox(height: 8),
                    _JsonEditor(
                      label: l10n.jwtEncodePayload,
                      color: _payloadColor,
                      controller: payloadTec,
                      isValid: controller.isPayloadJsonValid,
                      minLines: 6,
                    ),
                    const SizedBox(height: 8),
                    YaruSection(
                      headline: Text(
                        l10n.jwtVerifySignature,
                        style: const TextStyle(color: _signatureColor),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextField(
                              controller: secretTec,
                              decoration: InputDecoration(
                                label: Text(l10n.jwtSecret),
                                hintText: 'your-256-bit-secret',
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Text('${l10n.jwtAlgorithm}: '),
                                const SizedBox(width: 8),
                                DropdownButton<String>(
                                  value: controller.algorithm,
                                  items: [
                                    for (final alg in JwtController.supportedAlgorithms)
                                      DropdownMenuItem(value: alg, child: Text(alg)),
                                  ],
                                  onChanged: (v) {
                                    if (v != null) controller.setAlgorithm(v);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (controller.encodeError.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4, left: 4),
                        child: Text(
                          controller.encodeError,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontSize: 12,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Right column: generated token
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    YaruSection(
                      headline: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(l10n.jwtGeneratedToken),
                          if (controller.encodedResult.isNotEmpty)
                            CopyButton(
                              showText: false,
                              copyCallback: () =>
                                  pasteContentToClipboard(controller.encodedResult),
                            ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: controller.encodedResult.isEmpty
                            ? Text(
                                controller.secret.isEmpty
                                    ? 'Enter a secret to generate a token'
                                    : 'Invalid payload or header JSON',
                                style: TextStyle(
                                    color: Theme.of(context).colorScheme.outline),
                              )
                            : _ColoredToken(token: controller.encodedResult),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Colored token display (read-only) ─────────────────────────────────────────

class _ColoredToken extends StatelessWidget {
  final String token;

  const _ColoredToken({required this.token});

  @override
  Widget build(BuildContext context) {
    final parts = token.split('.');
    if (parts.length != 3) {
      return SelectableText(token,
          style: const TextStyle(fontFamily: 'monospace', fontSize: 13));
    }
    return SelectableText.rich(
      TextSpan(children: [
        TextSpan(
            text: parts[0],
            style: const TextStyle(
                color: _headerColor, fontFamily: 'monospace', fontSize: 13)),
        const TextSpan(
            text: '.',
            style: TextStyle(
                color: _dotColor, fontFamily: 'monospace', fontSize: 13)),
        TextSpan(
            text: parts[1],
            style: const TextStyle(
                color: _payloadColor, fontFamily: 'monospace', fontSize: 13)),
        const TextSpan(
            text: '.',
            style: TextStyle(
                color: _dotColor, fontFamily: 'monospace', fontSize: 13)),
        TextSpan(
            text: parts[2],
            style: const TextStyle(
                color: _signatureColor, fontFamily: 'monospace', fontSize: 13)),
      ]),
    );
  }
}

// ── JSON editor ───────────────────────────────────────────────────────────────

class _JsonEditor extends StatelessWidget {
  final String label;
  final Color color;
  final TextEditingController controller;
  final bool isValid;
  final int minLines;

  const _JsonEditor({
    required this.label,
    required this.color,
    required this.controller,
    required this.isValid,
    this.minLines = 4,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return YaruSection(
      headline: Row(
        children: [
          Text(label, style: TextStyle(color: color)),
          const Spacer(),
          Tooltip(
            message: isValid ? 'Valid JSON' : 'Invalid JSON',
            child: Icon(
              isValid ? Icons.check_circle_outline : Icons.error_outline,
              size: 14,
              color: isValid ? cs.success : cs.error,
            ),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: TextField(
          controller: controller,
          maxLines: null,
          minLines: minLines,
          style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
          decoration: const InputDecoration.collapsed(hintText: '{}'),
        ),
      ),
    );
  }
}

// ── JWT details section ───────────────────────────────────────────────────────

class _JwtDetails extends StatefulWidget {
  final Map<String, dynamic> data;
  final String title;
  final Color color;
  final bool initialBreakdown;

  const _JwtDetails({
    required this.data,
    required this.title,
    required this.color,
    this.initialBreakdown = true,
  });

  @override
  State<_JwtDetails> createState() => _JwtDetailsState();
}

class _JwtDetailsState extends State<_JwtDetails> {
  late bool _showBreakdown = widget.initialBreakdown;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final pretty = const JsonEncoder.withIndent('  ').convert(widget.data);
    return YaruSection(
      headline: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(widget.title, style: TextStyle(color: widget.color)),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Tooltip(
                message: _showBreakdown ? l10n.jwtShowJson : l10n.jwtClaimsBreakdown,
                child: IconButton(
                  icon: Icon(
                    _showBreakdown ? Icons.code_rounded : Icons.table_rows_outlined,
                    size: 16,
                  ),
                  onPressed: () => setState(() => _showBreakdown = !_showBreakdown),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                ),
              ),
              CopyButton(
                showText: false,
                copyCallback: () => pasteContentToClipboard(pretty),
              ),
            ],
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: _showBreakdown
            ? _BreakdownView(data: widget.data)
            : SelectableText(
                pretty,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
              ),
      ),
    );
  }
}

// ── Claims breakdown view ─────────────────────────────────────────────────────

class _BreakdownView extends StatelessWidget {
  final Map<String, dynamic> data;

  const _BreakdownView({required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final entry in data.entries) _BreakdownEntry(entry: entry),
      ],
    );
  }
}

class _BreakdownEntry extends StatelessWidget {
  final MapEntry entry;

  const _BreakdownEntry({required this.entry});

  @override
  Widget build(BuildContext context) {
    final key = entry.key as String;
    final claim = JwtRegisteredClaims.fromKey(key);
    final displayValue = claim != null ? claim.process(entry) : entry.value.toString();
    final shortDesc = claim?.shortDescription ?? _headerClaimShortDescription(key);
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Key
          SizedBox(
            width: 52,
            child: SelectableText(
              key,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: claim != null ? cs.primary : null,
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Short description
          SizedBox(
            width: 120,
            child: Text(
              shortDesc,
              style: TextStyle(
                fontSize: 11,
                color: cs.onSurface.withValues(alpha: 0.55),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Value
          Expanded(
            child: SelectableText(
              displayValue,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
            ),
          ),
          // Info tooltip for registered claims
          if (claim != null)
            Tooltip(
              message: claim.description(context.l10n),
              child: const Icon(Icons.info_outline, size: 14),
            ),
        ],
      ),
    );
  }

  String _headerClaimShortDescription(String key) => switch (key) {
        'alg' => 'Algorithm',
        'typ' => 'Token type',
        'kid' => 'Key ID',
        'cty' => 'Content type',
        'x5t' => 'X.509 thumbprint',
        _ => 'Custom claim',
      };
}

// ── l10n extensions ───────────────────────────────────────────────────────────

extension JwtRegisteredClaimsX on JwtRegisteredClaims {
  String description(AppLocalizations l10n) => switch (this) {
        JwtRegisteredClaims.iss => l10n.jwtClaimIss,
        JwtRegisteredClaims.sub => l10n.jwtClaimSub,
        JwtRegisteredClaims.exp => l10n.jwtClaimExp,
        JwtRegisteredClaims.nbf => l10n.jwtClaimNbf,
        JwtRegisteredClaims.iat => l10n.jwtClaimIat,
        JwtRegisteredClaims.jti => l10n.jwtClaimJti,
        JwtRegisteredClaims.aud => l10n.jwtClaimAud,
      };

  String get shortDescription => switch (this) {
        JwtRegisteredClaims.iss => 'Issuer',
        JwtRegisteredClaims.sub => 'Subject',
        JwtRegisteredClaims.aud => 'Audience',
        JwtRegisteredClaims.exp => 'Expiration',
        JwtRegisteredClaims.nbf => 'Not before',
        JwtRegisteredClaims.iat => 'Issued at',
        JwtRegisteredClaims.jti => 'JWT ID',
      };
}
