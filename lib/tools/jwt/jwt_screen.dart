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

class JwtScreen extends StatefulWidget {
  const JwtScreen({super.key});

  @override
  State<JwtScreen> createState() => _JwtScreenState();
}

class _JwtScreenState extends State<JwtScreen> {
  late final _controller = JwtController();
  late final _tokenTec = TextEditingController(text: _controller.token);

  @override
  void initState() {
    super.initState();
    _tokenTec.addListener(() => _controller.setToken(_tokenTec.text));
    _controller.addListener(() {
      if (_tokenTec.text != _controller.token) {
        _tokenTec.text = _controller.token;
      }
    });
  }

  @override
  void dispose() {
    _tokenTec.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              FlexActionBar(
                children: <Widget>[
                  YaruOptionButton(
                    onPressed: () async {
                      final text = await getClipboardContent();
                      if (text != null && text.isNotEmpty) {
                        _tokenTec.text = text;
                      }
                    },
                    child: const Icon(Icons.paste_rounded),
                  ),
                  CopyButton(
                    showText: false,
                    copyCallback: () => pasteContentToClipboard(_controller.token),
                  ),
                  YaruOptionButton(
                    onPressed: _controller.clear,
                    child: const Icon(Icons.clear_rounded),
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
              ),
              Expanded(
                child: ListView(
                  children: [
                    const SizedBox.square(dimension: 4),
                    TextField(
                      maxLines: 4,
                      minLines: 2,
                      decoration: InputDecoration(label: Text(l10n.jwtTokenLabel)),
                      controller: _tokenTec,
                    ),
                    const SizedBox.square(dimension: 8),
                    if (_controller.expirationDate != null || _controller.issuedDate != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8, left: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_controller.issuedDate case final issuedDate?)
                              Text(
                                l10n.issuedOn(formatDateTime(issuedDate)),
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            if (_controller.expirationDate case final expirationDate?)
                              expirationDate.isBefore(DateTime.now())
                                  ? Text(
                                      l10n.expiredOn(formatDateTime(expirationDate)),
                                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                            color: Theme.of(context).primaryColor,
                                          ),
                                    )
                                  : DefaultTextStyle(
                                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                            color: Theme.of(context).colorScheme.success,
                                          ),
                                      child: TimeRemaining(
                                        text: (d) => l10n.expiresOn(formatDateTime(expirationDate), d),
                                        duration: expirationDate.difference(DateTime.now()),
                                        onTimeOver: _controller.refresh,
                                      ),
                                    ),
                          ],
                        ),
                      ),
                    if (_controller.jwt case final token?)
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
      },
    );
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
            '${entry.key}: ${entry.value}',
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
            copyCallback: () => pasteContentToClipboard(jsonEncode(data)),
          ),
        ],
      ),
      child: Column(
        children: [for (final entry in data.entries) _Entry(entry: entry)],
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
