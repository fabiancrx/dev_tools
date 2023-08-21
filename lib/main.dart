import "package:dash_tools/app/app.dart";
import 'package:flutter_riverpod/flutter_riverpod.dart';

import "bootstrap.dart";

void main() {
  bootstrap(() => const ProviderScope(child: App()));
}