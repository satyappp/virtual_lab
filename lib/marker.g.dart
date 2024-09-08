// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'marker.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MarkerModelAdapter extends TypeAdapter<MarkerModel> {
  @override
  final int typeId = 0;

  @override
  MarkerModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MarkerModel(
      dx: fields[0] as double,
      dy: fields[1] as double,
      name: fields[2] as String,
      year: fields[3] as String,
      hardware: fields[4] as String,
      isUser: fields[5] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, MarkerModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.dx)
      ..writeByte(1)
      ..write(obj.dy)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.year)
      ..writeByte(4)
      ..write(obj.hardware)
      ..writeByte(5)
      ..write(obj.isUser);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MarkerModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
