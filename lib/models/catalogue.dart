import 'package:hive/hive.dart';

part 'catalogue.g.dart';

@HiveType(typeId: 5)
class Catalogue {
  @HiveField(0)
  String id;
  
  @HiveField(1)
  String nom;
  
  @HiveField(2)
  String typeConstruction;
  
  @HiveField(3)
  String description;
  
  @HiveField(4)
  double prix;
  
  @HiveField(5)
  List<String> photos; // chemins des photos
  
  @HiveField(6)
  DateTime dateCreation;

  Catalogue({
    required this.id,
    required this.nom,
    required this.typeConstruction,
    required this.description,
    required this.prix,
    this.photos = const [],
    required this.dateCreation,
  });
}