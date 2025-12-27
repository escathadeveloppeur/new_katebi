// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'statistique.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StatistiqueAdapter extends TypeAdapter<Statistique> {
  @override
  final int typeId = 7;

  @override
  Statistique read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Statistique(
      date: fields[0] as DateTime,
      revenusTerrains: fields[1] as double,
      revenusConstructions: fields[2] as double,
      depenses: fields[3] as double,
      nouveauxClients: fields[4] as int,
      terrainsVendus: fields[5] as int,
      constructionsDemarrees: fields[6] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Statistique obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.revenusTerrains)
      ..writeByte(2)
      ..write(obj.revenusConstructions)
      ..writeByte(3)
      ..write(obj.depenses)
      ..writeByte(4)
      ..write(obj.nouveauxClients)
      ..writeByte(5)
      ..write(obj.terrainsVendus)
      ..writeByte(6)
      ..write(obj.constructionsDemarrees);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StatistiqueAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
