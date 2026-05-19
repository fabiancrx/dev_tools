import 'package:uuid/uuid.dart';

const _uuid = Uuid();

enum UuidVersion { v1, v4, v7 }

extension UuidVersionX on UuidVersion {
  String get label => switch (this) {
        UuidVersion.v1 => 'v1 (time)',
        UuidVersion.v4 => 'v4 (random)',
        UuidVersion.v7 => 'v7 (time-ordered)',
      };

  String generate() => switch (this) {
        UuidVersion.v1 => _uuid.v1(),
        UuidVersion.v4 => _uuid.v4(),
        UuidVersion.v7 => _uuid.v7(),
      };
}

List<String> generateUuids(UuidVersion version, int count) =>
    List.generate(count, (_) => version.generate());
