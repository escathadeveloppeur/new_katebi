// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'catalogue.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CatalogueAdapter extends TypeAdapter<Catalogue> {
  @override
  final int typeId = 5;

  @override
  Catalogue read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Catalogue(
      id: fields[0] as String,
      nom: fields[1] as String,
      typeConstruction: fields[2] as String,
      description: fields[3] as String,
      prix: fields[4] as double,
      photos: (fields[5] as List).cast<String>(),
      dateCreation: fields[6] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Catalogue obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nom)
      ..writeByte(2)
      ..write(obj.typeConstruction)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.prix)
      ..writeByte(5)
      ..write(obj.photos)
      ..writeByte(6)
      ..write(obj.dateCreation);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CatalogueAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
