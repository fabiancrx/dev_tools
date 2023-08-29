import 'package:flutter/material.dart';
import 'package:yaru_widgets/widgets.dart';

class CopyButton extends StatelessWidget {
  final VoidCallback copyCallback;

  const CopyButton({super.key, required this.copyCallback});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints.tightFor(width: 96),
      child: YaruOptionButton(
          onPressed: copyCallback,
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [Flexible(child: Icon(Icons.content_copy_outlined)), Flexible(child: Text("Copy"))],
            ),
          )),
    );
  }
}
