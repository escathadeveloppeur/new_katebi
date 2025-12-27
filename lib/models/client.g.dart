// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ClientAdapter extends TypeAdapter<Client> {
  @override
  final int typeId = 3;

  @override
  Client read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Client(
      numeroOrdre: fields[0] as int,
      nom: fields[1] as String,
      postnom: fields[2] as String,
      prenom: fields[3] as String,
      telephone: fields[4] as String,
      email: fields[5] as String,
      nombreTerrains: fields[6] as int,
      blocId: fields[7] as String,
      numerosTerrains: (fields[8] as List).cast<int>(),
      fraisTotal: fields[9] as double,
      montantPaye: fields[10] as double,
      dateEnregistrement: fields[11] as DateTime,
      paiementComplet: fields[12] as bool,
  
    );
  }

  @override
  void write(BinaryWriter writer, Client obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.numeroOrdre)
      ..writeByte(1)
      ..write(obj.nom)
      ..writeByte(2)
      ..write(obj.postnom)
      ..writeByte(3)
      ..write(obj.prenom)
      ..writeByte(4)
      ..write(obj.telephone)
      ..writeByte(5)
      ..write(obj.email)
      ..writeByte(6)
      ..write(obj.nombreTerrains)
      ..writeByte(7)
      ..write(obj.blocId)
      ..writeByte(8)
      ..write(obj.numerosTerrains)
      ..writeByte(9)
      ..write(obj.fraisTotal)
      ..writeByte(10)
      ..write(obj.montantPaye)
      ..writeByte(11)
      ..write(obj.dateEnregistrement)
      ..writeByte(12)
      ..write(obj.paiementComplet);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClientAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
