import 'package:hive/hive.dart';

part 'paiement.g.dart';

@HiveType(typeId: 6)
class Paiement {
  @HiveField(0)
  String id;
  
  @HiveField(1)
  String clientId;
  
  @HiveField(2)
  String? constructionId;
  
  @HiveField(3)
  String type; // 'terrain' ou 'construction'
  
  @HiveField(4)
  double montant;
  
  @HiveField(5)
  DateTime datePaiement;
  
  @HiveField(6)
  String mois;
  
  @HiveField(7)
  String modePaiement; // 'espece', 'cheque', 'virement'
  
  @HiveField(8)
  String description;

  Paiement({
    required this.id,
    required this.clientId,
    this.constructionId,
    required this.type,
    required this.montant,
    required this.datePaiement,
    required this.mois,
    required this.modePaiement,
    required this.description,
  });
}
