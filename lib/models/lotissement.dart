import 'package:hive/hive.dart';

part 'lotissement.g.dart';

@HiveType(typeId: 0)
class Lotissement {
  @HiveField(0)
  String id;
  
  @HiveField(1)
  String nom;
  
  @HiveField(2)
  double prix;
  
  @HiveField(3)
  int nombreBlocs;
  
  @HiveField(4)
  int blocsRestants;
  
  @HiveField(5)
  DateTime dateCreation;
  
  @HiveField(6)
  List<String> blocsIds;

  Lotissement({
    required this.id,
    required this.nom,
    required this.prix,
    required this.nombreBlocs,
    this.blocsRestants = 0,
    required this.dateCreation,
    this.blocsIds = const [],
  });
}