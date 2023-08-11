// import 'dart:developer';
//
// import 'package:dash_tools/common/extensions.dart';
// import 'package:dash_tools/tools/clipboard_service.dart';
// import "package:dash_tools/widgets/rounded_container.dart";
// import 'package:dash_tools/widgets/vendored/resizable_pane.dart';
// import "package:flutter/material.dart";
//
// // Import the language & theme
// import "package:code_text_field/code_text_field.dart";
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import "package:highlight/languages/json.dart" show json;
// import "package:flutter_highlight/themes/monokai-sublime.dart" show monokaiSublimeTheme;
// import 'package:yaru_widgets/yaru_widgets.dart';
// import "json_screen_controller.dart";
//
// class JsonFormatterScreen extends ConsumerStatefulWidget {
//   const JsonFormatterScreen({
//     Key? key,
//   }) : super(key: key);
//
//   @override
//   ConsumerState createState() => _JsonFormatterScreenState();
// }
//
// class _JsonFormatterScreenState extends ConsumerState<JsonFormatterScreen> {
//   late final CodeController inputController = CodeController(language: json, theme: monokaiSublimeTheme);
//
//   late final CodeController outputController = CodeController(language: json, theme: monokaiSublimeTheme);
//
//   @override
//   void initState() {
//     inputController.addListener(() {
//       final pageProvider = ref.read(jsonControllerProvider);
//
//       if (pageProvider.autoProcess) {
//         final jsonObject = ref.read(jsonControllerProvider.notifier).processSync(inputController.text);
//         outputController.text = jsonObject;
//       }
//     });
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final pageController = ref.watch(jsonControllerProvider.notifier);
//     final pageState = ref.watch(jsonControllerProvider);
//
//     ref.listen(jsonControllerProvider, (previous, next) {
//       log("jsonPageProvider changed from $previous to $next");
//     });
//
//     return Scaffold(
//       body: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Row(
//           children: [
//             Column(
//               mainAxisSize: MainAxisSize.max,
//               children: [
//                 Flexible(
//                     child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceAround,
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     YaruOptionButton(onPressed: inputController.clear, iconData: Icons.clear_rounded),
//                     const YaruOptionButton(onPressed: getClipboardContent, iconData: Icons.paste_rounded),
//                     OutlinedButton(
//                         onPressed: () {
//                           inputController.text = pageController.sample;
//                           inputController.notifyListeners();
//                         },
//                         child: const Text("Sample")),
//                     DropdownButton(
//                       value: pageState.mode,
//                       onChanged: (JsonMode? m) {
//                         pageController.changeMode(m);
//                         inputController.notifyListeners();
//                       },
//                       items: JsonMode.values
//                           .map((e) => DropdownMenuItem(
//                                 value: e,
//                                 child: Text(e.name),
//                               ))
//                           .toList(),
//                     ),
//                   ].interleave(SizedBox()),
//                 )),
//                 Expanded(
//                   flex: 3,
//                   child: ResizablePane(
//                     resizableSide: ResizableSide.right,
//                     minWidth: 92,
//                     startWidth: MediaQuery.of(context).size.width / 3,
//                     maxWidth: MediaQuery.of(context).size.width / 2,
//
//                     builder: (context, width) {
//                       return RoundedContainer(
//                         child: CodeField(
//                           controller: inputController,
//                           expands: true,
//                           lineNumberStyle: const LineNumberStyle(
//                             width: 32,
//                             margin: 14,
//                           ),
//                           maxLines: null,
//                           minLines: null,
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(
//                 width: 35,
//                 child: VerticalDivider(
//                   indent: 8,
//                   endIndent: 8,
//                 )),
//             Flexible(
//               flex: 2,
//               child: RoundedContainer(
//                 child: CodeField(
//                   controller: outputController,
//                   expands: true,
//                   maxLines: null,
//                   minLines: null,
//                 ),
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'dart:developer';

import 'package:dash_tools/common/extensions.dart';
import 'package:dash_tools/tools/clipboard_service.dart';
import "package:dash_tools/widgets/rounded_container.dart";
import 'package:dash_tools/widgets/vendored/split.dart';
import "package:flutter/material.dart";

// Import the language & theme
import "package:code_text_field/code_text_field.dart";
import 'package:flutter_riverpod/flutter_riverpod.dart';
import "package:highlight/languages/json.dart" show json;
import "package:flutter_highlight/themes/monokai-sublime.dart" show monokaiSublimeTheme;
import 'package:yaru_widgets/yaru_widgets.dart';
import "json_screen_controller.dart";

class JsonFormatterScreen extends ConsumerStatefulWidget {
  const JsonFormatterScreen({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _JsonFormatterScreenState();
}

class _JsonFormatterScreenState extends ConsumerState<JsonFormatterScreen> {
  late final CodeController inputController = CodeController(language: json);

  late final CodeController outputController = CodeController(language: json);

  @override
  void initState() {
    inputController.addListener(() {
      final pageProvider = ref.read(jsonControllerProvider);

      if (pageProvider.autoProcess) {
        final jsonObject = ref.read(jsonControllerProvider.notifier).processSync(inputController.text);
        outputController.text = jsonObject;
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final pageController = ref.watch(jsonControllerProvider.notifier);
    final pageState = ref.watch(jsonControllerProvider);

    ref.listen(jsonControllerProvider, (previous, next) {
      log("jsonPageProvider changed from $previous to $next");
    });

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child:             Split(
          axis: Axis.horizontal,
          initialFractions: [0.5,0.5],
          minSizes: [278,80],
          children: [
            Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    YaruOptionButton(onPressed: inputController.clear, child: Icon(Icons.clear_rounded)),
                    YaruOptionButton(onPressed: getClipboardContent, child: Icon(Icons.paste_rounded)),
                    OutlinedButton(
                        onPressed: () {
                          inputController.text = pageController.sample;
                          inputController.notifyListeners();
                        },
                        child: const Text("Sample")),
                    DropdownButton(
                      value: pageState.mode,
                      onChanged: (JsonMode? m) {
                        pageController.changeMode(m);
                        inputController.notifyListeners();
                      },
                      items: JsonMode.values
                          .map((e) => DropdownMenuItem(
                        value: e,
                        child: Text(e.name),
                      ))
                          .toList(),
                    ),
                  ].interleave(const SizedBox()),
                ),
                Expanded(

                  child: RoundedContainer(
                    child: TextField(
                      controller: inputController,
                      expands: true,
                      // lineNumberStyle: const LineNumberStyle(
                      //   width: 32,
                      //   margin: 14,
                      // ),

                      maxLines: null,
                      minLines: null,
                    ),
                  ),
                ),
              ],
            ),

            RoundedContainer(
              child: CodeField(
                controller: outputController,
                expands: true,
                maxLines: null,
                minLines: null,
              ),
            )
          ],
        ),
      ),
    );
  }
}
