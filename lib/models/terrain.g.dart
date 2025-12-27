// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'terrain.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TerrainAdapter extends TypeAdapter<Terrain> {
  @override
  final int typeId = 2;

  @override
  Terrain read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Terrain(
      id: fields[0] as String,
      blocId: fields[1] as String,
      lotissementId: fields[2] as String,
      numero: fields[3] as int,
      estOccupe: fields[4] as bool,
      clientId: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Terrain obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.blocId)
      ..writeByte(2)
      ..write(obj.lotissementId)
      ..writeByte(3)
      ..write(obj.numero)
      ..writeByte(4)
      ..write(obj.estOccupe)
      ..writeByte(5)
      ..write(obj.clientId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TerrainAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
