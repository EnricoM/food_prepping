import 'package:hive/hive.dart';

class ImportedUrlEntity extends HiveObject {
  ImportedUrlEntity({
    required this.url,
    required this.domain,
    required this.importedAt,
  });

  final String url;
  final String domain;
  final DateTime importedAt;
}

class ImportedUrlEntityAdapter extends TypeAdapter<ImportedUrlEntity> {
  @override
  final int typeId = 6;

  @override
  ImportedUrlEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < numOfFields; i++) {
      final key = reader.readByte();
      fields[key] = reader.read();
    }

    return ImportedUrlEntity(
      url: fields[0] as String,
      domain: fields[1] as String,
      importedAt: fields[2] is int
          ? DateTime.fromMillisecondsSinceEpoch(fields[2] as int)
          : (fields[2] as DateTime?) ?? DateTime.now(),
    );
  }

  @override
  void write(BinaryWriter writer, ImportedUrlEntity obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.url)
      ..writeByte(1)
      ..write(obj.domain)
      ..writeByte(2)
      ..write(obj.importedAt.millisecondsSinceEpoch);
  }
}

