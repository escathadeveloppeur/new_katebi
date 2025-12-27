import 'package:hive/hive.dart';

part 'statistique.g.dart';

@HiveType(typeId: 7)
class Statistique {
  @HiveField(0)
  DateTime date;
  
  @HiveField(1)
  double revenusTerrains;
  
  @HiveField(2)
  double revenusConstructions;
  
  @HiveField(3)
  double depenses;
  
  @HiveField(4)
  int nouveauxClients;
  
  @HiveField(5)
  int terrainsVendus;
  
  @HiveField(6)
  int constructionsDemarrees;

  Statistique({
    required this.date,
    this.revenusTerrains = 0.0,
    this.revenusConstructions = 0.0,
    this.depenses = 0.0,
    this.nouveauxClients = 0,
    this.terrainsVendus = 0,
    this.constructionsDemarrees = 0,
  });
}