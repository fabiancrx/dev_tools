import 'dart:convert';

import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:dash_tools/common/extensions.dart';
import 'package:dash_tools/common/utils.dart';
import 'package:dash_tools/tools/clipboard_service.dart';
import 'package:dash_tools/widgets/copy_button.dart';
import 'package:dash_tools/widgets/flex_action_bar.dart';
import 'package:dash_tools/widgets/time_remaining.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'package:yaru/yaru.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class JwtScreen extends StatefulWidget {
  const JwtScreen({super.key});

  @override
  State<JwtScreen> createState() => _JwtScreenState();
}

class _JwtScreenState extends State<JwtScreen> {
  final TextEditingController _controller = TextEditingController();
  JWT? jwt;
  DateTime? _expirationDate;

  @override
  void initState() {
    super.initState();
    _populate();
  }

  @override
  Widget build(BuildContext context) {
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
                    _parse();
                  },
                  child: const Icon(Icons.paste_rounded)),
              CopyButton(
                showText: false,
                copyCallback: () {
                  pasteContentToClipboard(_controller.text);
                },
              ),
              ElevatedButton(onPressed: _parse, child: const Text("Parse")),
              const Spacer(),
              Tooltip(
                  message: "What is a Json Web token?",
                  child: YaruOptionButton(
                      onPressed: () {
                        launchUrlString('https://www.rfc-editor.org/rfc/rfc7519');
                      },
                      child: const Icon(Icons.info_outline))),
              YaruOptionButton(onPressed: _clear, child: const Icon(Icons.clear_rounded)),
            ].interleave(const SizedBox(width: 8)),
          ),
          Expanded(
            child: ListView(
              children: [
                const SizedBox.square(dimension: 8),
                TextField(
                  maxLines: 2,
                  decoration: const InputDecoration(
                    label: Text("JWT Token"),
                  ),
                  controller: _controller,
                ),
                const SizedBox.square(dimension: 8),
                if (_expirationDate != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Column(
                      children: [
                        if (_expirationDate!.isBefore(DateTime.now()))
                          Text(
                            "Expired on: ${formatDateTime(_expirationDate!)}",
                            style: Theme.of(context).textTheme.headline6!.copyWith(color: Theme.of(context).primaryColor),
                          )
                        else
                          DefaultTextStyle(
                            style: Theme.of(context).textTheme.headline6!.copyWith(color: Theme.of(context).successColor),
                            child: TimeRemaining(
                              text: (d) => "Expires on: ${formatDateTime(_expirationDate!)} in $d",
                              duration: _expirationDate!.difference(DateTime.now()),
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
                    _JwtDetails(data: token.payload, title: 'Payload'),
                    if (token.header case final header?) _JwtDetails(data: header, title: "Header"),
                  ].interleave(const SizedBox.square(dimension: 8))
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
  }

  void _parse() {
    if (_controller.text == "") {
      return;
    }
    jwt = null;
    _expirationDate = null;
    try {
      setState(() {
        jwt = JWT.decode(_controller.text);
        _expirationDate = _extractNumericDateFromMap(jwt?.payload["exp"]);
      });
    } catch (e) {
      updateWithError(e.toString());
    }
  }

  void updateWithError(String error) {
    setState(() {
      jwt = null;
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

  const _Entry({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          SelectableText(
            entry.key,
            style: Theme.of(context).textTheme.headline6,
          ),
          Text(
            ": ",
            style: Theme.of(context).textTheme.headline6,
          ),
          Expanded(
            child: SelectableText(
              entry.value.toString(),
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
          if (JwtRegisteredClaims.fromKey(entry.key) case final claim?)
            Tooltip(message: claim.description, child: const Icon(Icons.info_outline)),
        ],
      ),
    );
  }
}

class _JwtDetails extends StatelessWidget {
  final Map<String, dynamic> data;
  final String title;

  const _JwtDetails({super.key, required this.data, required this.title});

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
                })
          ],
        ),
        child: Column(
          children: [
            for (var entry in data.entries) _Entry(entry: entry),
          ],
        ));
  }
}

extension JwtRegisteredClaimsX on JwtRegisteredClaims {
  String get description => switch (this) {
        JwtRegisteredClaims.iss => "Issuer Claim\n identifies the principal that issued the "
            "JWT.  The processing of this claim is generally application specific.",
        JwtRegisteredClaims.sub => "Subject Claim\n identifies the principal that is the "
            "subject of the JWT.  The claims in a JWT are normally statements "
            "about the subject.  The subject value MUST either be scoped to be "
            "locally unique in the context of the issuer or be globally unique. "
            "The processing of this claim is generally application specific. ",
        JwtRegisteredClaims.exp => "Expiration time claim\n identifies the expiration time on "
            "or after which the JWT MUST NOT be accepted for processing.  The "
            "processing of the 'exp' claim requires that the current date/time "
            "MUST be before the expiration date/time listed in the 'exp' claim.",
        JwtRegisteredClaims.nbf => "Not before claim\n identifies the time before which the JWT "
            "MUST NOT be accepted for processing.  The processing of the 'nbf' "
            "claim requires that the current date/time MUST be after or equal to "
            "the not-before date/time listed in the 'nbf' claim.",
        JwtRegisteredClaims.iat => "Issued at claim\n identifies the time at which the JWT was "
            "issued.  This claim can be used to determine the age of the JWT.",
        JwtRegisteredClaims.jti => "JWT ID claim\n provides a unique identifier for the JWT. "
            "The identifier value MUST be assigned in a manner that ensures that "
            "there is a negligible probability that the same value will be "
            "accidentally assigned to a different data object; if the application "
            "uses multiple issuers, collisions MUST be prevented among values "
            "produced by different issuers as well. ",
        JwtRegisteredClaims.aud => "Audience claim\n identifies the recipients that the JWT is "
            "intended for.  Each principal intended to process the JWT MUST "
            "identify itself with a value in the audience claim.",
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

  static bool isRegisteredClaim(MapEntry entry) => JwtRegisteredClaims.values.any((claim) => claim.name == entry.key);

  static JwtRegisteredClaims? fromKey(String key) {
    for (final claim in JwtRegisteredClaims.values) {
      if (claim.name == key) return claim;
    }
    return null;
  }
}

DateTime? _extractNumericDateFromMap(dynamic entry) {
  if (entry is int) {
    return DateTime.fromMillisecondsSinceEpoch(entry * 1000);
  } else if (entry is String) {
    return DateTime.parse(entry);
  }

  return null;
}
