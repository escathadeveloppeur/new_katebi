import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:gestion_lotissement/screens/home/page_accueil.dart'; // IMPORT AJOUTÉ
import 'package:gestion_lotissement/screens/auth/login_page.dart';
import 'package:gestion_lotissement/screens/admin/admin_page.dart';
import 'package:gestion_lotissement/screens/admin/enregistrement_client.dart';
import 'package:gestion_lotissement/screens/admin/enregistrement_paiement.dart';
import 'package:gestion_lotissement/screens/admin/ajout_lotissement.dart';
import 'package:gestion_lotissement/screens/admin/ajout_construction.dart';
import 'package:gestion_lotissement/screens/admin/ajout_catalogue.dart';
import 'package:gestion_lotissement/screens/admin/gestion_paiements.dart';
import 'package:gestion_lotissement/screens/admin/statistiques.dart';
import 'package:gestion_lotissement/screens/admin/caisse_entreprise.dart';
import 'package:gestion_lotissement/services/database_service.dart';
import 'package:gestion_lotissement/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await DatabaseService.init();
  await AuthService.init();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestion Lotissement',
      theme: ThemeData(
        primarySwatch: Colors.green, // Changé à vert pour correspondre au design
        useMaterial3: true,
        fontFamily: 'Roboto', // Optionnel: pour une meilleure typographie
      ),
      debugShowCheckedModeBanner: false,

      // Routes nommées - Page d'accueil en premier
      routes: {
        // Page d'accueil comme première page visible
        '/': (context) => PageAccueil(),
        
        // Authentification
        '/login': (context) => LoginPage(),
        
        // Admin
        '/admin': (context) => AdminPage(),
        '/enregistrement-client': (context) => EnregistrementClient(),
        '/enregistrement-paiement': (context) => EnregistrementPaiement(),
        '/ajout-lotissement': (context) => AjoutLotissement(),
        '/ajout-construction': (context) => AjoutConstruction(),
        '/ajout-catalogue': (context) => AjoutCatalogue(),
        '/gestion-paiements': (context) => GestionPaiements(),
        '/statistiques': (context) => StatistiquesPage(),
        '/caisse': (context) => CaisseEntreprise(),
      },
      
      // Optionnel: Gestionnaire pour les routes non trouvées
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => PageAccueil(),
        );
      },
    );
  }
}