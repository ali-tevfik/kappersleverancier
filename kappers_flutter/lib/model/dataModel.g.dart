// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dataModel.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DatamodelAdapter extends TypeAdapter<Datamodel> {
  @override
  final int typeId = 0;

  @override
  Datamodel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Datamodel(
      id: fields[0] as int,
      ean: fields[1] as String,
      name: fields[2] as String,
      imgUrl: fields[3] as String,
      price: fields[4] as String,
      url: fields[5] as String,
    )..pieces = 0;
  }

  @override
  void write(BinaryWriter writer, Datamodel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.ean)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.imgUrl)
      ..writeByte(4)
      ..write(obj.price)
      ..writeByte(5)
      ..write(obj.url)
      ..writeByte(6)
      ..write(obj.pieces);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DatamodelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
