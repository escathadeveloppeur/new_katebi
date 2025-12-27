import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/lotissement.dart';
import '../models/bloc.dart';
import '../models/terrain.dart';
import '../models/client.dart';
import '../models/construction.dart';
import '../models/catalogue.dart';
import '../models/paiement.dart';
import '../models/statistique.dart';

class DatabaseService {
  static late Box<Lotissement> lotissementBox;
  static late Box<Bloc> blocBox;
  static late Box<Terrain> terrainBox;
  static late Box<Client> clientBox;
  static late Box<Construction> constructionBox;
  static late Box<Catalogue> catalogueBox;
  static late Box<Paiement> paiementBox;
  static late Box<Statistique> statistiqueBox;
  static late Box settingsBox;

  // Mode simulation (true = données en mémoire, false = vrai Hive)
  static bool simulationMode = false;
  
  // Données simulées
  static List<Lotissement> _simulatedLotissements = [];
  static List<Bloc> _simulatedBlocs = [];
  static List<Terrain> _simulatedTerrains = [];
  static List<Client> _simulatedClients = [];
  static List<Construction> _simulatedConstructions = [];
  static List<Catalogue> _simulatedCatalogues = [];
  static List<Paiement> _simulatedPaiements = [];
  static List<Statistique> _simulatedStatistiques = [];
  
  static int _clientCounter = 0;
  static int _paiementCounter = 0;
  static String _defaultPassword = 'admin123';

  static Future<void> init() async {
    if (simulationMode) {
      print('🟡 MODE SIMULATION ACTIVÉ - Données en mémoire');
      await _chargerDonneesSimulees();
      return;
    }
    
    print('🟢 MODE HIVE ACTIVÉ - Données persistantes');
    await Hive.initFlutter('gestion_lotissement_db');

    // Enregistrer les adaptateurs
    Hive.registerAdapter(LotissementAdapter());
    Hive.registerAdapter(BlocAdapter());
    Hive.registerAdapter(TerrainAdapter());
    Hive.registerAdapter(ClientAdapter());
    Hive.registerAdapter(ConstructionAdapter());
    Hive.registerAdapter(CatalogueAdapter());
    Hive.registerAdapter(PaiementAdapter());
    Hive.registerAdapter(StatistiqueAdapter());

    // Ouvrir les boîtes
    lotissementBox = await Hive.openBox<Lotissement>('lotissements');
    blocBox = await Hive.openBox<Bloc>('blocs');
    terrainBox = await Hive.openBox<Terrain>('terrains');
    clientBox = await Hive.openBox<Client>('clients');
    constructionBox = await Hive.openBox<Construction>('constructions');
    catalogueBox = await Hive.openBox<Catalogue>('catalogues');
    paiementBox = await Hive.openBox<Paiement>('paiements');
    statistiqueBox = await Hive.openBox<Statistique>('statistiques');
    settingsBox = await Hive.openBox('settings');

    // Initialiser les compteurs
    if (!settingsBox.containsKey('clientCounter')) {
      settingsBox.put('clientCounter', 0);
    }
    if (!settingsBox.containsKey('paiementCounter')) {
      settingsBox.put('paiementCounter', 0);
    }
    
    // Charger quelques données de démo si vide
    if (lotissementBox.isEmpty) {
      await _chargerDonneesDemo();
    }
  }

  // ========== MÉTHODES POUR LOTISSEMENT ==========

  static Future<void> ajouterLotissement(Lotissement lotissement) async {
    print('➕ Ajout lotissement: ${lotissement.nom}');
    
    if (simulationMode) {
      _simulatedLotissements.add(lotissement);
      print('✅ Simulé: ${_simulatedLotissements.length} lotissements');
    } else {
      await lotissementBox.put(lotissement.id, lotissement);
      print('✅ Hive: Lotissement enregistré');
    }
  }

  static Future<List<Lotissement>> getLotissements() async {
    if (simulationMode) {
      return _simulatedLotissements;
    } else {
      return lotissementBox.values.toList();
    }
  }

  // ========== MÉTHODES POUR BLOC ==========

  static Future<void> ajouterBloc(Bloc bloc) async {
    print('➕ Ajout bloc: ${bloc.numeroBloc}');
    
    if (simulationMode) {
      _simulatedBlocs.add(bloc);
      
      // Créer 12 terrains simulés
      for (int i = 1; i <= 12; i++) {
        Terrain terrain = Terrain(
          id: '${bloc.id}_terrain_$i',
          blocId: bloc.id,
          lotissementId: bloc.lotissementId,
          numero: i,
        );
        _simulatedTerrains.add(terrain);
      }
      print('✅ Simulé: Bloc + 12 terrains créés');
    } else {
      await blocBox.put(bloc.id, bloc);
      
      for (int i = 1; i <= 12; i++) {
        Terrain terrain = Terrain(
          id: '${bloc.id}_terrain_$i',
          blocId: bloc.id,
          lotissementId: bloc.lotissementId,
          numero: i,
        );
        await terrainBox.put(terrain.id, terrain);
      }
      print('✅ Hive: Bloc enregistré');
    }
  }

  static Future<List<Bloc>> getBlocsByLotissement(String lotissementId) async {
    if (simulationMode) {
      return _simulatedBlocs
          .where((bloc) => bloc.lotissementId == lotissementId)
          .toList();
    } else {
      return blocBox.values
          .where((bloc) => bloc.lotissementId == lotissementId)
          .toList();
    }
  }

  // ========== MÉTHODES POUR CLIENT ==========

  static Future<int> genererNumeroOrdre() async {
    if (simulationMode) {
      _clientCounter++;
      return _clientCounter;
    } else {
      int counter = settingsBox.get('clientCounter', defaultValue: 0);
      counter++;
      settingsBox.put('clientCounter', counter);
      return counter;
    }
  }

  static Future<void> enregistrerClient(Client client) async {
    print('➕ Enregistrement client: ${client.nom} ${client.prenom}');
    
    if (simulationMode) {
      _simulatedClients.add(client);
      print('✅ Simulé: ${_simulatedClients.length} clients');
    } else {
      await clientBox.put(client.numeroOrdre.toString(), client);
      print('✅ Hive: Client enregistré');
    }
    
    // Logique métier (simulée ou réelle)
    await _mettreAJourTerrainsApresClient(client);
    await mettreAJourStatistiques(client);
  }

  static Future<List<Client>> getClients() async {
    if (simulationMode) {
      return _simulatedClients;
    } else {
      return clientBox.values.toList();
    }
  }

  // ========== MÉTHODES POUR CATALOGUE ==========

  static Future<void> ajouterCatalogue(Catalogue catalogue) async {
    print('➕ Ajout catalogue: ${catalogue.nom}');
    
    if (simulationMode) {
      _simulatedCatalogues.add(catalogue);
    } else {
      await catalogueBox.put(catalogue.id, catalogue);
    }
  }

  static Future<List<Catalogue>> getCatalogues() async {
    if (simulationMode) {
      return _simulatedCatalogues;
    } else {
      return catalogueBox.values.toList();
    }
  }

  // ========== MÉTHODES POUR CONSTRUCTION ==========

  static Future<void> ajouterConstruction(Construction construction) async {
    print('➕ Ajout construction: ${construction.nomComplet}');
    
    if (simulationMode) {
      _simulatedConstructions.add(construction);
    } else {
      await constructionBox.put(construction.id, construction);
    }
    
    await _mettreAJourStatistiquesConstruction();
  }

  // ========== MÉTHODES POUR PAIEMENT ==========

  static Future<String> genererIdPaiement() async {
    if (simulationMode) {
      _paiementCounter++;
      return 'PAY${_paiementCounter.toString().padLeft(6, '0')}';
    } else {
      int counter = settingsBox.get('paiementCounter', defaultValue: 0);
      counter++;
      settingsBox.put('paiementCounter', counter);
      return 'PAY${counter.toString().padLeft(6, '0')}';
    }
  }

  static Future<void> enregistrerPaiement(Paiement paiement) async {
    print('➕ Enregistrement paiement: \$${paiement.montant}');
    
    if (simulationMode) {
      _simulatedPaiements.add(paiement);
    } else {
      await paiementBox.put(paiement.id, paiement);
    }
    
    await mettreAJourStatistiquesPaiement(paiement);
  }

  static Future<List<Paiement>> getPaiements() async {
    if (simulationMode) {
      return _simulatedPaiements;
    } else {
      return paiementBox.values.toList();
    }
  }

  // ========== MÉTHODES UTILITAIRES ==========

  static String getDefaultPassword() {
    if (simulationMode) {
      return _defaultPassword;
    } else {
      final defaultPass = settingsBox.get('default_admin_password');
      if (defaultPass != null) return defaultPass;
      
      settingsBox.put('default_admin_password', 'admin123');
      return 'admin123';
    }
  }

  static Future<void> setDefaultPassword(String newPassword) async {
    if (simulationMode) {
      _defaultPassword = newPassword;
    } else {
      await settingsBox.put('default_admin_password', newPassword);
    }
  }

  // ========== MÉTHODES DE SIMULATION ==========

  static Future<void> _chargerDonneesSimulees() async {
    print('🔄 Chargement données simulées...');
    
    // Données de démo
    _simulatedLotissements = [
      Lotissement(
        id: 'lot_1',
        nom: 'Villa Paradise',
        prix: 5000,
        nombreBlocs: 3,
        dateCreation: DateTime(2024, 1, 15),
      ),
      Lotissement(
        id: 'lot_2',
        nom: 'Green Valley',
        prix: 7500,
        nombreBlocs: 5,
        dateCreation: DateTime(2024, 2, 20),
      ),
    ];
    
    _simulatedClients = [
      Client(
        numeroOrdre: 1,
        nom: 'Dupont',
        postnom: '',
        prenom: 'Jean',
        telephone: '0612345678',
        email: 'jean.dupont@email.com',
        nombreTerrains: 2,
        blocId: 'bloc_1',
        numerosTerrains: [1, 2],
        fraisTotal: 200,
        dateEnregistrement: DateTime(2024, 3, 10),
      ),
      Client(
        numeroOrdre: 2,
        nom: 'Martin',
        postnom: '',
        prenom: 'Marie',
        telephone: '0698765432',
        email: 'marie.martin@email.com',
        nombreTerrains: 1,
        blocId: 'bloc_1',
        numerosTerrains: [3],
        fraisTotal: 100,
        dateEnregistrement: DateTime(2024, 3, 15),
      ),
    ];
    
    _simulatedCatalogues = [
      Catalogue(
        id: 'cat_1',
        nom: 'Maison Moderne 3 chambres',
        typeConstruction: 'moderne',
        description: 'Maison moderne avec 3 chambres, salon spacieux',
        prix: 50000,
        dateCreation: DateTime(2024, 1, 10),
      ),
      Catalogue(
        id: 'cat_2',
        nom: 'Villa Luxe 5 chambres',
        typeConstruction: 'mise_en_valeur',
        description: 'Villa de luxe avec piscine et jardin',
        prix: 120000,
        dateCreation: DateTime(2024, 2, 5),
      ),
    ];
    
    _clientCounter = _simulatedClients.length;
    print('✅ Données simulées chargées:');
    print('   - ${_simulatedLotissements.length} lotissements');
    print('   - ${_simulatedClients.length} clients');
    print('   - ${_simulatedCatalogues.length} catalogues');
  }

  static Future<void> _chargerDonneesDemo() async {
    print('🔄 Chargement données de démo dans Hive...');
    
    // Lotissement de démo
    Lotissement demo = Lotissement(
      id: 'demo_lot',
      nom: 'Exemple Lotissement',
      prix: 6000,
      nombreBlocs: 2,
      dateCreation: DateTime.now(),
    );
    
    await ajouterLotissement(demo);
    
    // Catalogue de démo
    Catalogue demoCat = Catalogue(
      id: 'demo_cat',
      nom: 'Modèle Démo',
      typeConstruction: 'moderne',
      description: 'Exemple de modèle de construction',
      prix: 45000,
      dateCreation: DateTime.now(),
    );
    
    await ajouterCatalogue(demoCat);
    
    print('✅ Données de démo chargées');
  }

  static Future<void> _mettreAJourTerrainsApresClient(Client client) async {
    // Simulation de mise à jour
    print('🔄 Mise à jour terrains pour client ${client.numeroOrdre}');
  }

  static Future<void> mettreAJourStatistiques(Client client) async {
    // Statistiques simulées
    print('📊 Statistiques mises à jour pour nouveau client');
  }

  static Future<void> mettreAJourStatistiquesPaiement(Paiement paiement) async {
    print('📊 Statistiques paiement mises à jour: \$${paiement.montant}');
  }

  static Future<void> _mettreAJourStatistiquesConstruction() async {
    print('📊 Statistiques construction mises à jour');
  }

  // ========== MÉTHODES DE TEST ET DÉBUG ==========

  static Future<void> testerEnregistrement() async {
    print('🧪 === TEST D\'ENREGISTREMENT ===');
    
    // Test Lotissement
    Lotissement test = Lotissement(
      id: 'test_${DateTime.now().millisecondsSinceEpoch}',
      nom: 'Lotissement Test',
      prix: 10000,
      nombreBlocs: 1,
      dateCreation: DateTime.now(),
    );
    
    await ajouterLotissement(test);
    print('✅ Lotissement test ajouté');
    
    // Test Client
    Client testClient = Client(
      numeroOrdre: await genererNumeroOrdre(),
      nom: 'Test',
      postnom: 'User',
      prenom: 'Demo',
      telephone: '0600000000',
      email: 'test@demo.com',
      nombreTerrains: 1,
      blocId: 'test_bloc',
      numerosTerrains: [1],
      fraisTotal: 100,
      dateEnregistrement: DateTime.now(),
    );
    
    await enregistrerClient(testClient);
    print('✅ Client test ajouté');
    
    // Vérification
    final lotissements = await getLotissements();
    final clients = await getClients();
    
    print('📊 RÉSULTATS:');
    print('   - Lotissements: ${lotissements.length}');
    print('   - Clients: ${clients.length}');
    print('🧪 === TEST TERMINÉ ===');
  }

  static Future<void> basculerModeSimulation() async {
    simulationMode = !simulationMode;
    print(simulationMode 
        ? '🟡 MODE SIMULATION ACTIVÉ' 
        : '🟢 MODE HIVE ACTIVÉ');
    
    await init(); // Re-initialiser avec le nouveau mode
  }

  static Future<void> reinitialiserDonnees() async {
    print('🔄 Réinitialisation des données...');
    
    if (simulationMode) {
      _simulatedLotissements.clear();
      _simulatedClients.clear();
      _simulatedCatalogues.clear();
      _simulatedConstructions.clear();
      _simulatedPaiements.clear();
      _clientCounter = 0;
      _paiementCounter = 0;
      print('✅ Données simulées réinitialisées');
    } else {
      await lotissementBox.clear();
      await clientBox.clear();
      await catalogueBox.clear();
      await constructionBox.clear();
      await paiementBox.clear();
      settingsBox.put('clientCounter', 0);
      settingsBox.put('paiementCounter', 0);
      print('✅ Données Hive réinitialisées');
    }
    
    // Recharger données de démo
    await _chargerDonneesDemo();
  }

  // ========== NETTOYAGE ==========

  static Future<void> closeBoxes() async {
    if (!simulationMode) {
      await lotissementBox.close();
      await blocBox.close();
      await terrainBox.close();
      await clientBox.close();
      await constructionBox.close();
      await catalogueBox.close();
      await paiementBox.close();
      await statistiqueBox.close();
      await settingsBox.close();
    }
  }
}