import 'package:hive/hive.dart';

part 'client.g.dart';

@HiveType(typeId: 3)
class Client {
  @HiveField(0)
  int numeroOrdre;
  
  @HiveField(1)
  String nom;
  
  @HiveField(2)
  String postnom;
  
  @HiveField(3)
  String prenom;
  
  @HiveField(4)
  String telephone;
  
  @HiveField(5)
  String email;
  
  @HiveField(6)
  int nombreTerrains;
  
  @HiveField(7)
  String blocId;
  
  @HiveField(8)
  List<int> numerosTerrains;
  
  @HiveField(9)
  double fraisTotal;
  
  @HiveField(10)
  double montantPaye;
  
  @HiveField(11)
  DateTime dateEnregistrement;
  
  @HiveField(12)
  bool paiementComplet;

  Client({
    required this.numeroOrdre,
    required this.nom,
    required this.postnom,
    required this.prenom,
    required this.telephone,
    required this.email,
    required this.nombreTerrains,
    required this.blocId,
    required this.numerosTerrains,
    required this.fraisTotal,
    this.montantPaye = 0.0,
    required this.dateEnregistrement,
    this.paiementComplet = false,
   
  });
}
