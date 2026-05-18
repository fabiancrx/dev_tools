import 'package:dash_tools/previews.dart';
import 'package:flutter/material.dart';

class ClearTextIcon extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final VoidCallback? onPressed;

  const ClearTextIcon({super.key, required this.controller, this.focusNode, this.onPressed});

  bool get hasFocus => focusNode?.hasFocus ?? true;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
        listenable: Listenable.merge([controller, focusNode]),
        builder: (context, child) {
          return Visibility(
            visible: controller.text.trim().isNotEmpty && hasFocus,
            child: IconButton(
              onPressed: onPressed?.call ?? controller.clear,
              tooltip: 'Clear',
              icon: const Icon(Icons.clear),
            ),
          );
        });
  }
}

@MultiBrightnessPreview(name: 'ClearTextIcon · visible')
Widget clearTextIconVisiblePreview() => ClearTextIcon(controller: TextEditingController(text: 'Some text'));

@MultiBrightnessPreview(name: 'ClearTextIcon · hidden')
Widget clearTextIconHiddenPreview() => ClearTextIcon(controller: TextEditingController());
