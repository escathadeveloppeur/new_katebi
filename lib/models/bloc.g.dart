// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bloc.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BlocAdapter extends TypeAdapter<Bloc> {
  @override
  final int typeId = 1;

  @override
  Bloc read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Bloc(
      id: fields[0] as String,
      lotissementId: fields[1] as String,
      numeroBloc: fields[2] as String,
      totalTerrains: fields[3] as int,
      terrainsRestants: fields[4] as int,
      terrainsOccupes: (fields[5] as List).cast<int>(),
      isSature: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Bloc obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.lotissementId)
      ..writeByte(2)
      ..write(obj.numeroBloc)
      ..writeByte(3)
      ..write(obj.totalTerrains)
      ..writeByte(4)
      ..write(obj.terrainsRestants)
      ..writeByte(5)
      ..write(obj.terrainsOccupes)
      ..writeByte(6)
      ..write(obj.isSature);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BlocAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
