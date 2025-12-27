// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'construction.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ConstructionAdapter extends TypeAdapter<Construction> {
  @override
  final int typeId = 4;

  @override
  Construction read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Construction(
      id: fields[0] as String,
      clientId: fields[1] as String,
      nomComplet: fields[2] as String,
      typeConstruction: fields[3] as String,
      catalogueId: fields[4] as String,
      adresseParcelle: fields[5] as String,
      dureeConstruction: fields[6] as int,
      dureePaiement: fields[7] as int,
      montantTotal: fields[8] as double,
      montantPaye: fields[9] as double,
      dateDebut: fields[10] as DateTime,
      dateFin: fields[11] as DateTime?,
      statut: fields[12] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Construction obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.clientId)
      ..writeByte(2)
      ..write(obj.nomComplet)
      ..writeByte(3)
      ..write(obj.typeConstruction)
      ..writeByte(4)
      ..write(obj.catalogueId)
      ..writeByte(5)
      ..write(obj.adresseParcelle)
      ..writeByte(6)
      ..write(obj.dureeConstruction)
      ..writeByte(7)
      ..write(obj.dureePaiement)
      ..writeByte(8)
      ..write(obj.montantTotal)
      ..writeByte(9)
      ..write(obj.montantPaye)
      ..writeByte(10)
      ..write(obj.dateDebut)
      ..writeByte(11)
      ..write(obj.dateFin)
      ..writeByte(12)
      ..write(obj.statut);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConstructionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
