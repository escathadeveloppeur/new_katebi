import 'package:hive/hive.dart';
import 'package:gestion_lotissement/services/auth_service.dart';

class SecureClientService {
  // Récupérer SEULEMENT les données du client connecté
  static Future<Map<String, dynamic>?> getCurrentClientData() async {
    try {
      final currentUsername = AuthService.getCurrentUsername();
      if (currentUsername == null) return null;
      
      final authBox = await Hive.openBox('auth');
      final clientAuthData = authBox.get(currentUsername);
      
      if (clientAuthData == null || clientAuthData['role'] != 'client') {
        return null;
      }
      
      final clientId = clientAuthData['clientId'];
      
      // Récupérer les données spécifiques au client
      return {
        'authInfo': clientAuthData,
        'terrains': await _getTerrainsForClient(clientId),
        'paiements': await _getPaiementsForClient(clientId),
        'constructions': await _getConstructionsForClient(clientId),
      };
    } catch (e) {
      print('❌ Erreur getCurrentClientData: $e');
      return null;
    }
  }
  
  static Future<List<dynamic>> _getTerrainsForClient(String clientId) async {
    try {
      final terrainsBox = await Hive.openBox('terrains');
      final allTerrains = terrainsBox.values.toList();
      
      return allTerrains
          .where((terrain) => terrain['clientId'] == clientId)
          .toList();
    } catch (e) {
      print('❌ Erreur _getTerrainsForClient: $e');
      return [];
    }
  }
  
  static Future<List<dynamic>> _getPaiementsForClient(String clientId) async {
    try {
      final paiementsBox = await Hive.openBox('paiements');
      final allPaiements = paiementsBox.values.toList();
      
      return allPaiements
          .where((paiement) => paiement['clientId'] == clientId)
          .toList();
    } catch (e) {
      print('❌ Erreur _getPaiementsForClient: $e');
      return [];
    }
  }
  
  static Future<List<dynamic>> _getConstructionsForClient(String clientId) async {
    try {
      final constructionsBox = await Hive.openBox('constructions');
      final allConstructions = constructionsBox.values.toList();
      
      return allConstructions
          .where((construction) => construction['clientId'] == clientId)
          .toList();
    } catch (e) {
      print('❌ Erreur _getConstructionsForClient: $e');
      return [];
    }
  }
  
  // Vérifier si le client a accès aux données
  static Future<bool> hasAccessToData(String clientId) async {
    try {
      final currentUsername = AuthService.getCurrentUsername();
      if (currentUsername == null) return false;
      
      final authBox = await Hive.openBox('auth');
      final clientAuthData = authBox.get(currentUsername);
      
      if (clientAuthData == null) return false;
      
      // Vérifier que c'est bien le bon client
      return clientAuthData['clientId'] == clientId;
    } catch (e) {
      print('❌ Erreur hasAccessToData: $e');
      return false;
    }
  }
}