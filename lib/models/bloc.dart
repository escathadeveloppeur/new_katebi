import 'package:hive/hive.dart';

part 'bloc.g.dart';

@HiveType(typeId: 1)
class Bloc {
  @HiveField(0)
  String id;
  
  @HiveField(1)
  String lotissementId;
  
  @HiveField(2)
  String numeroBloc;
  
  @HiveField(3)
  int totalTerrains;
  
  @HiveField(4)
  int terrainsRestants;
  
  @HiveField(5)
  List<int> terrainsOccupes;
  
  @HiveField(6)
  bool isSature;

  Bloc({
    required this.id,
    required this.lotissementId,
    required this.numeroBloc,
    this.totalTerrains = 12,
    this.terrainsRestants = 12,
    this.terrainsOccupes = const [],
    this.isSature = false,
  });
}