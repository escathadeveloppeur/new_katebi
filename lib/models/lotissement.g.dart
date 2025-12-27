// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lotissement.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LotissementAdapter extends TypeAdapter<Lotissement> {
  @override
  final int typeId = 0;

  @override
  Lotissement read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Lotissement(
      id: fields[0] as String,
      nom: fields[1] as String,
      prix: fields[2] as double,
      nombreBlocs: fields[3] as int,
      blocsRestants: fields[4] as int,
      dateCreation: fields[5] as DateTime,
      blocsIds: (fields[6] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, Lotissement obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nom)
      ..writeByte(2)
      ..write(obj.prix)
      ..writeByte(3)
      ..write(obj.nombreBlocs)
      ..writeByte(4)
      ..write(obj.blocsRestants)
      ..writeByte(5)
      ..write(obj.dateCreation)
      ..writeByte(6)
      ..write(obj.blocsIds);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LotissementAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
