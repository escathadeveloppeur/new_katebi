import 'package:hive/hive.dart';

part 'terrain.g.dart';

@HiveType(typeId: 2)
class Terrain {
  @HiveField(0)
  String id;
  
  @HiveField(1)
  String blocId;
  
  @HiveField(2)
  String lotissementId;
  
  @HiveField(3)
  int numero;
  
  @HiveField(4)
  bool estOccupe;
  
  @HiveField(5)
  String? clientId;

  Terrain({
    required this.id,
    required this.blocId,
    required this.lotissementId,
    required this.numero,
    this.estOccupe = false,
    this.clientId,
  });
}