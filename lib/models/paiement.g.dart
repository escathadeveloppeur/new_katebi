// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'paiement.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PaiementAdapter extends TypeAdapter<Paiement> {
  @override
  final int typeId = 6;

  @override
  Paiement read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Paiement(
      id: fields[0] as String,
      clientId: fields[1] as String,
      constructionId: fields[2] as String?,
      type: fields[3] as String,
      montant: fields[4] as double,
      datePaiement: fields[5] as DateTime,
      mois: fields[6] as String,
      modePaiement: fields[7] as String,
      description: fields[8] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Paiement obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.clientId)
      ..writeByte(2)
      ..write(obj.constructionId)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.montant)
      ..writeByte(5)
      ..write(obj.datePaiement)
      ..writeByte(6)
      ..write(obj.mois)
      ..writeByte(7)
      ..write(obj.modePaiement)
      ..writeByte(8)
      ..write(obj.description);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaiementAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
