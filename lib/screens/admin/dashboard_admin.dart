import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '/services/database_service.dart';
import '/services/auth_service.dart';
import '/screens/admin/gestion_lotissements.dart';
import '/screens/admin/gestion_clients.dart';
import '/screens/admin/gestion_paiements.dart';
import '/screens/admin/statistiques.dart';
import '/screens/admin/caisse_entreprise.dart';
import '/screens/admin/gestion_constructions.dart';
import '/screens/admin/gestion_catalogue.dart';
import '/screens/admin/enregistrement_client.dart';
import '/screens/admin/ajout_lotissement.dart';
import '/screens/admin/ajout_construction.dart';
import '/screens/admin/enregistrement_paiement.dart';
import '/screens/admin/ajout_catalogue.dart';

class DashboardAdmin extends StatefulWidget {
  @override
  _DashboardAdminState createState() => _DashboardAdminState();
}

class _DashboardAdminState extends State<DashboardAdmin> {
  late Future<Map<String, dynamic>> _dashboardData;
  final currencyFormat = NumberFormat.currency(
    symbol: '\$',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _dashboardData = _loadDashboardData();
  }

  Future<Map<String, dynamic>> _loadDashboardData() async {
    final clients = await DatabaseService.clientBox.values.toList();
    final lotissements = await DatabaseService.lotissementBox.values.toList();
    final paiements = await DatabaseService.paiementBox.values.toList();
    final constructions = await DatabaseService.constructionBox.values.toList();

    double totalRevenus = 0;
    for (var paiement in paiements) {
      totalRevenus += paiement.montant;
    }

    return {
      'totalClients': clients.length,
      'totalLotissements': lotissements.length,
      'totalRevenus': totalRevenus,
      'constructionsEnCours':
          constructions.where((c) => c.statut == 'en_cours').length,
      'terrainsRestants': _calculerTerrainsRestants(),
    };
  }

  int _calculerTerrainsRestants() {
    final blocs = DatabaseService.blocBox.values.toList();
    int total = 0;
    for (var bloc in blocs) {
      total += bloc.terrainsRestants;
    }
    return total;
  }

  void _refreshData() {
    setState(() {
      _dashboardData = _loadDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.green.shade900,
                  Colors.green.shade800,
                ],
              ),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.dashboard,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TABLEAU DE BORD ADMIN',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Vue d\'ensemble du système de gestion',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.logout, color: Colors.white),
                  onPressed: () {
                    AuthService.logout();
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: 25),

          // Statistiques
          Text(
            'STATISTIQUES GLOBALES',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.green.shade900,
              letterSpacing: 1.1,
            ),
          ),
          SizedBox(height: 10),
          Container(
            height: 2,
            color: Colors.green.shade300,
            width: 100,
          ),
          SizedBox(height: 20),

          FutureBuilder<Map<String, dynamic>>(
            future: _dashboardData,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container(
                  height: 200,
                  child: Center(
                    child: CircularProgressIndicator(color: Colors.green),
                  ),
                );
              }

              if (snapshot.hasError) {
                return Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red, size: 40),
                      SizedBox(height: 10),
                      Text(
                        'Erreur de chargement des données',
                        style: TextStyle(color: Colors.red.shade800),
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _refreshData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        child: Text('RÉESSAYER'),
                      ),
                    ],
                  ),
                );
              }

              final data = snapshot.data!;

              return GridView.count(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: 1.3,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                children: [
                  _buildStatCard(
                    'CLIENTS',
                    '${data['totalClients']}',
                    Icons.people_outline,
                    Colors.blue.shade800,
                    'Clients enregistrés',
                  ),
                  _buildStatCard(
                    'LOTISSEMENTS',
                    '${data['totalLotissements']}',
                    Icons.landscape,
                    Colors.green,
                    'Nombre de lotissements',
                  ),
                  _buildStatCard(
                    'REVENUS TOTAUX',
                    currencyFormat.format(data['totalRevenus']),
                    FontAwesomeIcons.moneyBillWave,
                    Colors.orange.shade800,
                    'Revenus générés',
                  ),
                  _buildStatCard(
                    'TERRAINS RESTANTS',
                    '${data['terrainsRestants']}',
                    FontAwesomeIcons.layerGroup,
                    Colors.purple,
                    'Terrains disponibles',
                  ),
                ],
              );
            },
          ),
          SizedBox(height: 30),

          // Actions rapides
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ACTIONS RAPIDES',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade900,
                  letterSpacing: 1.1,
                ),
              ),
              IconButton(
                icon: Icon(Icons.refresh, color: Colors.green),
                onPressed: _refreshData,
              ),
            ],
          ),
          SizedBox(height: 10),
          Container(
            height: 2,
            color: Colors.green.shade300,
            width: 100,
          ),
          SizedBox(height: 20),

          GridView.count(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 1.8,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            children: [
              _buildActionCard(
                'Gérer Lotissements',
                Icons.landscape,
                Colors.blue.shade800,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GestionLotissements(),
                  ),
                ),
              ),
              _buildActionCard(
                'Nouveau Client',
                Icons.person_add,
                Colors.green,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EnregistrementClient(),
                  ),
                ),
              ),
              _buildActionCard(
                'Enregistrer Paiement',
                Icons.payment,
                Colors.orange.shade700,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EnregistrementPaiement(),
                  ),
                ),
              ),
              _buildActionCard(
                'Gérer Constructions',
                Icons.construction,
                Colors.red,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GestionConstructions(),
                  ),
                ),
              ),
              _buildActionCard(
                'Catalogue',
                Icons.photo_library,
                Colors.purple,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GestionCatalogue(),
                  ),
                ),
              ),
              _buildActionCard(
                'Statistiques',
                Icons.bar_chart,
                Colors.teal,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StatistiquesPage(),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 30),

          // Dernières activités
          Text(
            'DERNIÈRES ACTIVITÉS',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.green.shade900,
              letterSpacing: 1.1,
            ),
          ),
          SizedBox(height: 10),
          Container(
            height: 2,
            color: Colors.green.shade300,
            width: 100,
          ),
          SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: _buildRecentClients(),
              ),
              SizedBox(width: 20),
              Expanded(
                child: _buildRecentPaiements(),
              ),
            ],
          ),
          SizedBox(height: 30),

          // Info système
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.green.shade800),
                SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Système de Gestion Lotissement Katebi',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade900,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Toutes les données sont sauvegardées localement',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    String subtitle,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 28, color: color),
                ),
                Spacer(),
                IconButton(
                  icon: Icon(Icons.more_vert, size: 20, color: Colors.grey),
                  onPressed: () {},
                ),
              ],
            ),
            SizedBox(height: 15),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ),
            SizedBox(height: 5),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: color,
                  letterSpacing: 1.1,
                ),
              ),
            ),
            SizedBox(height: 5),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 28, color: color),
              ),
              SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'ACCÉDER',
                    style: TextStyle(
                      fontSize: 10,
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 5),
                  Icon(Icons.arrow_forward_ios, size: 10, color: color),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentClients() {
    final clients = DatabaseService.clientBox.values.toList();
    clients.sort(
      (a, b) => b.dateEnregistrement.compareTo(a.dateEnregistrement),
    );
    final recentClients = clients.take(5).toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.people_outline, color: Colors.blue, size: 22),
                SizedBox(width: 10),
                Text(
                  'CLIENTS RÉCENTS',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                Spacer(),
                if (clients.length > 5)
                  TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => GestionClients()),
                    ),
                    child: Text(
                      'Voir tous',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 15),
            if (recentClients.isEmpty)
              Container(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(Icons.people_outline, color: Colors.grey.shade400, size: 40),
                    SizedBox(height: 10),
                    Text(
                      'Aucun client enregistré',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              )
            else
              ...recentClients.map(
                (client) => Container(
                  margin: EdgeInsets.only(bottom: 10),
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.blue.shade100,
                        child: Icon(Icons.person, color: Colors.blue, size: 20),
                        radius: 20,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${client.nom} ${client.prenom}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              client.telephone,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${client.nombreTerrains}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green.shade800,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentPaiements() {
    final paiements = DatabaseService.paiementBox.values.toList();
    paiements.sort((a, b) => b.datePaiement.compareTo(a.datePaiement));
    final recentPaiements = paiements.take(5).toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.payment, color: Colors.green, size: 22),
                SizedBox(width: 10),
                Text(
                  'DERNIERS PAIEMENTS',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
            SizedBox(height: 15),
            if (recentPaiements.isEmpty)
              Container(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(Icons.payment, color: Colors.grey.shade400, size: 40),
                    SizedBox(height: 10),
                    Text(
                      'Aucun paiement enregistré',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              )
            else
              ...recentPaiements.map(
                (paiement) => Container(
                  margin: EdgeInsets.only(bottom: 10),
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: paiement.type == 'terrain'
                              ? Colors.green.shade100
                              : Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          paiement.type == 'terrain'
                              ? Icons.landscape
                              : Icons.construction,
                          color: paiement.type == 'terrain'
                              ? Colors.green
                              : Colors.orange,
                          size: 20,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              paiement.type == 'terrain'
                                  ? 'Paiement Terrain'
                                  : 'Paiement Construction',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              DateFormat('dd/MM/yyyy').format(paiement.datePaiement),
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        currencyFormat.format(paiement.montant),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade800,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}