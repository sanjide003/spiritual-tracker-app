// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_models.dart';

class CustomPrayerAdapter extends TypeAdapter<CustomPrayer> {
  @override
  final int typeId = 0;

  @override
  CustomPrayer read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CustomPrayer(
      id: fields[0] as String,
      name: fields[1] as String,
      rakah: fields[2] as int,
      isCompleted: fields[3] as bool,
      date: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, CustomPrayer obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.rakah)
      ..writeByte(3)
      ..write(obj.isCompleted)
      ..writeByte(4)
      ..write(obj.date);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomPrayerAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CustomDhikrAdapter extends TypeAdapter<CustomDhikr> {
  @override
  final int typeId = 1;

  @override
  CustomDhikr read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CustomDhikr(
      id: fields[0] as String,
      text: fields[1] as String,
      count: fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, CustomDhikr obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.text)
      ..writeByte(2)
      ..write(obj.count);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomDhikrAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class NoteItemAdapter extends TypeAdapter<NoteItem> {
  @override
  final int typeId = 2;

  @override
  NoteItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NoteItem(
      id: fields[0] as String,
      title: fields[1] as String,
      content: fields[2] as String,
      type: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, NoteItem obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.content)
      ..writeByte(3)
      ..write(obj.type);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NoteItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
