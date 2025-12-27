import 'package:hive/hive.dart';

part 'construction.g.dart';

@HiveType(typeId: 4)
class Construction {
  @HiveField(0)
  String id;
  
  @HiveField(1)
  String clientId;
  
  @HiveField(2)
  String nomComplet;
  
  @HiveField(3)
  String typeConstruction; // 'mise_en_valeur' ou 'moderne'
  
  @HiveField(4)
  String catalogueId;
  
  @HiveField(5)
  String adresseParcelle;
  
  @HiveField(6)
  int dureeConstruction; // en mois
  
  @HiveField(7)
  int dureePaiement; // en mois
  
  @HiveField(8)
  double montantTotal;
  
  @HiveField(9)
  double montantPaye;
  
  @HiveField(10)
  DateTime dateDebut;
  
  @HiveField(11)
  DateTime? dateFin;
  
  @HiveField(12)
  String statut; // 'en_attente', 'en_cours', 'complet'

  Construction({
    required this.id,
    required this.clientId,
    required this.nomComplet,
    required this.typeConstruction,
    required this.catalogueId,
    required this.adresseParcelle,
    required this.dureeConstruction,
    required this.dureePaiement,
    required this.montantTotal,
    this.montantPaye = 0.0,
    required this.dateDebut,
    this.dateFin,
    this.statut = 'en_attente',
  });
}