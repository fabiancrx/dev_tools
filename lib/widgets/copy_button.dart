import 'package:flutter/material.dart';
import 'package:yaru/widgets.dart';


class CopyButton extends StatelessWidget {
  final VoidCallback copyCallback;
  final bool showText;

  const CopyButton({super.key, required this.copyCallback, this.showText = true});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints.tightFor(width: showText ? 96 : 48),
      child: Tooltip(
        message: "Copy",
        child: YaruOptionButton(
            onPressed: copyCallback,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  const Flexible(child: Icon(Icons.content_copy_outlined)),
                  if (showText) const Flexible(child: Text("Copy")),
                ],
              ),
            )),
      ),
    );
  }
}
