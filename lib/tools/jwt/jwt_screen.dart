import 'dart:convert';

import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:dash_tools/common/extensions.dart';
import 'package:dash_tools/common/utils.dart';
import 'package:dash_tools/l10n/l10n.dart';
import 'package:dash_tools/tools/clipboard_service.dart';
import 'package:dash_tools/widgets/copy_button.dart';
import 'package:dash_tools/widgets/flex_action_bar.dart';
import 'package:dash_tools/widgets/time_remaining.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'package:yaru/yaru.dart';

class JwtScreen extends StatefulWidget {
  const JwtScreen({super.key});

  @override
  State<JwtScreen> createState() => _JwtScreenState();
}

class _JwtScreenState extends State<JwtScreen> {
  final TextEditingController _controller = TextEditingController();
  JWT? jwt;
  DateTime? _expirationDate;
  DateTime? _issuedDate;

  @override
  void initState() {
    super.initState();

    _controller.addListener(() {
      setState(() {
        _parse();
      });
    });
    _populate();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          FlexActionBar(
            children: <Widget>[
              YaruOptionButton(
                onPressed: () async {
                  final clipboardText = await getClipboardContent();
                  if (clipboardText != null && clipboardText.isNotEmpty) {
                    _controller.text = clipboardText;
                  }
                },
                child: const Icon(Icons.paste_rounded),
              ),
              CopyButton(
                showText: false,
                copyCallback: () {
                  pasteContentToClipboard(_controller.text);
                },
              ),
              YaruOptionButton(
                onPressed: _clear,
                child: const Icon(Icons.clear_rounded),
              ),
              const Spacer(),
              Tooltip(
                message: l10n.whatIsJwt,
                child: YaruOptionButton(
                  onPressed: () {
                    launchUrlString('https://www.rfc-editor.org/rfc/rfc7519');
                  },
                  child: const Icon(Icons.info_outline),
                ),
              ),
            ].interleave(const SizedBox(width: 8)),
          ),
          Expanded(
            child: ListView(
              children: [
                const SizedBox.square(dimension: 4),
                TextField(
                  maxLines: 4,
                  minLines: 2,
                  decoration: InputDecoration(label: Text(l10n.jwtTokenLabel)),
                  controller: _controller,
                ),
                const SizedBox.square(dimension: 8),
                if (_expirationDate != null || _issuedDate != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8, left: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_issuedDate case final issuedDate?)
                          Text(
                            l10n.issuedOn(formatDateTime(issuedDate)),
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        if (_expirationDate case final expirationDate?)
                          expirationDate.isBefore(DateTime.now())
                              ? Text(
                                  l10n.expiredOn(formatDateTime(_expirationDate!)),
                                  style: Theme.of(context).textTheme.bodyLarge!
                                      .copyWith(
                                        color: Theme.of(context).primaryColor,
                                      ),
                                )
                              : DefaultTextStyle(
                                  style: Theme.of(context).textTheme.bodyLarge!
                                      .copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.success,
                                      ),
                                  child: TimeRemaining(
                                    text: (d) =>
                                        l10n.expiresOn(formatDateTime(expirationDate), d),
                                    duration: expirationDate.difference(
                                      DateTime.now(),
                                    ),
                                    onTimeOver: () {
                                      setState(() {});
                                    },
                                  ),
                                ),
                      ],
                    ),
                  ),
                if (jwt case final token?)
                  ...<Widget>[
                    _JwtDetails(data: token.payload, title: l10n.jwtPayload),
                    if (token.header case final header?)
                      _JwtDetails(data: header, title: l10n.jwtHeader),
                  ].interleave(const SizedBox.square(dimension: 8)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _populate() {
    _controller.text =
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyLCJpc3MiOiJKb2UiLCJleHAiOjE1MTYyMzkwMjJ9.W_2iFbDheNPQFxhRENNDoF5G9V32X-Qz03FK59VjNWQ';
  }

  void _clear() {
    _controller.clear();
    jwt = null;
    _expirationDate = null;
    _issuedDate = null;
  }

  void _parse() {
    if (_controller.text == "") {
      return;
    }
    jwt = null;
    _expirationDate = null;
    _issuedDate = null;
    try {
      setState(() {
        jwt = JWT.decode(_controller.text);

        _expirationDate = _extractNumericDateFromMap(jwt?.payload["exp"]);
        _issuedDate = _extractNumericDateFromMap(jwt?.payload["iat"]);
      });
    } catch (e) {
      updateWithError(e.toString());
    }
  }

  void updateWithError(String error) {
    setState(() {
      jwt = null;
      _expirationDate = null;
      _issuedDate = null;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _Entry extends StatelessWidget {
  final MapEntry entry;

  const _Entry({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SelectableText(
            "${entry.key}: ${entry.value}",
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          if (JwtRegisteredClaims.fromKey(entry.key) case final claim?)
            Tooltip(
              message: claim.description(context.l10n),
              child: const Icon(Icons.info_outline),
            ),
        ],
      ),
    );
  }
}

class _JwtDetails extends StatelessWidget {
  final Map<String, dynamic> data;
  final String title;

  const _JwtDetails({required this.data, required this.title});

  @override
  Widget build(BuildContext context) {
    return YaruSection(
      headline: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          CopyButton(
            showText: false,
            copyCallback: () {
              pasteContentToClipboard(jsonEncode(data));
            },
          ),
        ],
      ),
      child: Column(
        children: [for (var entry in data.entries) _Entry(entry: entry)],
      ),
    );
  }
}

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
}

enum JwtRegisteredClaims {
  iss,
  sub,
  aud,
  exp,
  nbf,
  iat,
  jti;

  const JwtRegisteredClaims();

  String process(MapEntry entry) {
    final value = entry.value;
    final s = switch (this) {
      exp || nbf || iat => _extractNumericDateFromMap(value),
      _ => value.toString(),
    };
    if (s == null) return '';
    return s.toString();
  }

  static bool isRegisteredClaim(MapEntry entry) =>
      JwtRegisteredClaims.values.any((claim) => claim.name == entry.key);

  static JwtRegisteredClaims? fromKey(String key) =>
      JwtRegisteredClaims.values.where((c) => c.name == key).firstOrNull;
}

DateTime? _extractNumericDateFromMap(dynamic entry) => switch (entry) {
  final int i => DateTime.fromMillisecondsSinceEpoch(i * 1000),
  final String s => DateTime.parse(s),
  _ => null,
};
