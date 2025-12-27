import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:gestion_lotissement/models/statistique.dart';
import 'package:gestion_lotissement/models/paiement.dart';
import 'package:gestion_lotissement/models/client.dart';
import 'package:gestion_lotissement/models/construction.dart';
import 'package:gestion_lotissement/services/database_service.dart';

class StatistiquesPage extends StatefulWidget {
  @override
  _StatistiquesPageState createState() => _StatistiquesPageState();
}

class _StatistiquesPageState extends State<StatistiquesPage> {
  List<Statistique> _statistiques = [];
  List<Paiement> _paiements = [];
  List<Client> _clients = [];
  List<Construction> _constructions = [];
  
  String _periode = 'mois';
  DateTime _dateDebut = DateTime.now().subtract(Duration(days: 30));
  DateTime _dateFin = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final statistiques = DatabaseService.statistiqueBox.values.toList();
    final paiements = await DatabaseService.getPaiements();
    final clients = await DatabaseService.getClients();
    final constructions = DatabaseService.constructionBox.values.toList();
    
    setState(() {
      _statistiques = statistiques;
      _paiements = paiements;
      _clients = clients;
      _constructions = constructions;
    });
  }

  List<Map<String, dynamic>> _getRevenusParMois() {
    Map<String, double> revenus = {};
    
    for (var paiement in _paiements) {
      final mois = DateFormat('yyyy-MM').format(paiement.datePaiement);
      if (!revenus.containsKey(mois)) {
        revenus[mois] = 0;
      }
      revenus[mois] = revenus[mois]! + paiement.montant;
    }

    return revenus.entries.map((entry) {
      return {
        'mois': entry.key,
        'revenus': entry.value,
      };
    }).toList()
      ..sort((a, b) => (a['mois']as String).compareTo(b['mois']as String));
  }

  List<Map<String, dynamic>> _getClientsParMois() {
    Map<String, int> clients = {};
    
    for (var client in _clients) {
      final mois = DateFormat('yyyy-MM').format(client.dateEnregistrement);
      if (!clients.containsKey(mois)) {
        clients[mois] = 0;
      }
      clients[mois] = clients[mois]! + 1;
    }

    return clients.entries.map((entry) {
      return {
        'mois': entry.key,
        'clients': entry.value,
      };
    }).toList()
      ..sort((a, b) => (a['mois']as String).compareTo(b['mois']as String));
  }

  double _getTotalRevenus() {
    return _paiements.fold(0.0, (sum, p) => sum + p.montant);
  }

  double _getRevenusTerrains() {
    return _paiements
        .where((p) => p.type == 'terrain')
        .fold(0.0, (sum, p) => sum + p.montant);
  }

  double _getRevenusConstructions() {
    return _paiements
        .where((p) => p.type == 'construction')
        .fold(0.0, (sum, p) => sum + p.montant);
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 0);
    final revenusParMois = _getRevenusParMois();
    final clientsParMois = _getClientsParMois();

    return Scaffold(
      appBar: AppBar(
        title: Text('Statistiques et Rapports'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Vue d'ensemble
            Text(
              'Vue d\'ensemble',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 1.5,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildStatCard(
                  'Revenus Totaux',
                  currencyFormat.format(_getTotalRevenus()),
                  Icons.attach_money,
                  Colors.green,
                ),
                _buildStatCard(
                  'Clients Totaux',
                  _clients.length.toString(),
                  Icons.people,
                  Colors.blue,
                ),
                _buildStatCard(
                  'Revenus Terrains',
                  currencyFormat.format(_getRevenusTerrains()),
                  Icons.landscape,
                  Colors.orange,
                ),
                _buildStatCard(
                  'Revenus Constructions',
                  currencyFormat.format(_getRevenusConstructions()),
                  Icons.construction,
                  Colors.purple,
                ),
              ],
            ),
            SizedBox(height: 32),

            // Graphique des revenus
            Card(
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Revenus par Mois',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    Container(
                      height: 300,
                      child: SfCartesianChart(
                        primaryXAxis: CategoryAxis(),
                        series: <CartesianSeries>[
                          LineSeries<Map<String, dynamic>, String>(
                            dataSource: revenusParMois,
                            xValueMapper: (data, _) => data['mois'],
                            yValueMapper: (data, _) => data['revenus'],
                            name: 'Revenus',
                            color: Colors.green,
                            markerSettings: MarkerSettings(isVisible: true),
                          ),
                        ],
                        tooltipBehavior: TooltipBehavior(enable: true),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 32),

            // Graphique des clients
            Card(
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nouveaux Clients par Mois',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    Container(
                      height: 300,
                      child: SfCartesianChart(
                        primaryXAxis: CategoryAxis(),
                        series: <CartesianSeries>[
                          ColumnSeries<Map<String, dynamic>, String>(
                            dataSource: clientsParMois,
                            xValueMapper: (data, _) => data['mois'],
                            yValueMapper: (data, _) => data['clients'],
                            name: 'Clients',
                            color: Colors.blue,
                          ),
                        ],
                        tooltipBehavior: TooltipBehavior(enable: true),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 32),

            // Statistiques détaillées
            Card(
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Statistiques Détailées',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    _buildStatItemDetail('Terrains vendus', 
                      _clients.fold(0, (sum, c) => sum + c.nombreTerrains).toString()),
                    _buildStatItemDetail('Constructions en cours', 
                      _constructions.where((c) => c.statut == 'en_cours').length.toString()),
                    _buildStatItemDetail('Constructions complétées', 
                      _constructions.where((c) => c.statut == 'complet').length.toString()),
                    _buildStatItemDetail('Paiements enregistrés', 
                      _paiements.length.toString()),
                    _buildStatItemDetail('Moyenne par client', 
                      currencyFormat.format(_clients.isEmpty ? 0 : _getTotalRevenus() / _clients.length)),
                  ],
                ),
              ),
            ),

            // Distribution des revenus
            SizedBox(height: 32),
            Card(
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Distribution des Revenus',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    Container(
                      height: 300,
                      child: SfCircularChart(
                        series: <CircularSeries>[
                          PieSeries<Map<String, dynamic>, String>(
                            dataSource: [
                              {'type': 'Terrains', 'value': _getRevenusTerrains()},
                              {'type': 'Constructions', 'value': _getRevenusConstructions()},
                            ],
                            xValueMapper: (data, _) => data['type'],
                            yValueMapper: (data, _) => data['value'],
                            dataLabelSettings: DataLabelSettings(isVisible: true),
                            enableTooltip: true,
                          ),
                        ],
                        legend: Legend(isVisible: true),
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

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItemDetail(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}