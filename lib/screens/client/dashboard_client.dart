import 'package:flutter/material.dart';
import 'package:gestion_lotissement/services/auth_service.dart';
import 'package:gestion_lotissement/services/secure_client_service.dart';

class DashboardClient extends StatefulWidget {
  @override
  _DashboardClientState createState() => _DashboardClientState();
}

class _DashboardClientState extends State<DashboardClient> {
  Map<String, dynamic>? _clientData;
  bool _isLoading = true;
  String _clientId = '';

  @override
  void initState() {
    super.initState();
    _loadClientData();
  }

  Future<void> _loadClientData() async {
    setState(() => _isLoading = true);
    
    try {
      // Récupérer SEULEMENT les données du client connecté
      _clientData = await SecureClientService.getCurrentClientData();
      
      if (_clientData == null) {
        print('⚠️ Aucune donnée trouvée pour ce client');
        return;
      }
      
      final authInfo = _clientData!['authInfo'];
      _clientId = authInfo['clientId'] ?? '';
      
      print('✅ Données chargées pour le client: $_clientId');
      print('   Terrains: ${_clientData!['terrains'].length}');
      print('   Paiements: ${_clientData!['paiements'].length}');
      print('   Constructions: ${_clientData!['constructions'].length}');
      
    } catch (e) {
      print('❌ Erreur chargement données client: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _calculateTotalInvestment(List<dynamic> paiements) {
    try {
      double total = 0;
      for (var paiement in paiements) {
        final montantStr = paiement['montant']?.toString() ?? '0';
        // Nettoyer le montant (enlever USD, espaces, etc.)
        final cleaned = montantStr.replaceAll(RegExp(r'[^0-9.]'), '');
        final montant = double.tryParse(cleaned) ?? 0;
        total += montant;
      }
      return '${total.toStringAsFixed(0)} USD';
    } catch (e) {
      return '0 USD';
    }
  }

  double _parseProgression(String? progression) {
    if (progression == null) return 0;
    final match = RegExp(r'(\d+)').firstMatch(progression);
    if (match != null) {
      final value = int.tryParse(match.group(0) ?? '0') ?? 0;
      return value / 100;
    }
    return 0;
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 24, color: color),
                ),
                Spacer(),
              ],
            ),
            SizedBox(height: 15),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            SizedBox(height: 5),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
            SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Color color,
    required List<dynamic> items,
    required Widget Function(dynamic) itemBuilder,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 24),
            SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade900,
              ),
            ),
            Spacer(),
            TextButton(
              onPressed: () {
                // Navigation vers la page détaillée
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Fonctionnalité à implémenter'),
                  ),
                );
              },
              child: Text('Voir tout'),
            ),
          ],
        ),
        SizedBox(height: 10),
        Card(
          child: Column(
            children: items.map(itemBuilder).toList(),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_clientData == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 60, color: Colors.red),
            SizedBox(height: 20),
            Text(
              'Aucune donnée disponible',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadClientData,
              child: Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    final authInfo = _clientData!['authInfo'];
    final terrains = _clientData!['terrains'];
    final paiements = _clientData!['paiements'];
    final constructions = _clientData!['constructions'];
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Tableau de bord client'),
        backgroundColor: Colors.green.shade900,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadClientData,
          ),
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () {
              AuthService.logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadClientData,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Carte de bienvenue PERSONNALISÉE
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.green.shade100,
                            child: Icon(
                              Icons.person,
                              size: 40,
                              color: Colors.green.shade800,
                            ),
                          ),
                          SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Bonjour, ${authInfo['prenom'] ?? 'Client'} !',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green.shade900,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  'Client ID: ${authInfo['clientId'] ?? 'N/A'}',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  'Bienvenue dans votre espace personnel',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 15),
                      Divider(),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildMiniStat('Téléphone', authInfo['telephone'] ?? 'N/A'),
                          _buildMiniStat('Email', authInfo['email'] ?? 'N/A'),
                          _buildMiniStat('Statut', 'Actif'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: 25),
              
              // Statistiques PERSONNELLES
              Text(
                'Vos statistiques personnelles',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade900,
                ),
              ),
              SizedBox(height: 15),
              
              GridView.count(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 1.2,
                children: [
                  _buildStatCard(
                    title: 'Vos Terrains',
                    value: terrains.length.toString(),
                    subtitle: 'Terrains achetés',
                    icon: Icons.landscape,
                    color: Colors.green,
                  ),
                  _buildStatCard(
                    title: 'Vos Paiements',
                    value: paiements.length.toString(),
                    subtitle: 'Transactions effectuées',
                    icon: Icons.payment,
                    color: Colors.blue,
                  ),
                  _buildStatCard(
                    title: 'Constructions',
                    value: constructions.length.toString(),
                    subtitle: 'Projets en cours',
                    icon: Icons.construction,
                    color: Colors.orange,
                  ),
                  _buildStatCard(
                    title: 'Investissement',
                    value: _calculateTotalInvestment(paiements),
                    subtitle: 'Total investi',
                    icon: Icons.attach_money,
                    color: Colors.purple,
                  ),
                ],
              ),
              
              SizedBox(height: 30),
              
              // Vos terrains (seulement les vôtres)
              if (terrains.isNotEmpty) ...[
                _buildSection(
                  title: 'Vos Terrains',
                  icon: Icons.landscape,
                  color: Colors.green,
                  items: terrains.take(3).toList(),
                  itemBuilder: (item) => ListTile(
                    leading: Icon(Icons.landscape, color: Colors.green),
                    title: Text(item['numero'] ?? 'Terrain'),
                    subtitle: Text('${item['superficie']} - ${item['statut']}'),
                    trailing: Text(item['prix'] ?? ''),
                    onTap: () {
                      // Navigation vers détail du terrain
                    },
                  ),
                ),
                SizedBox(height: 20),
              ],
              
              // Vos paiements (seulement les vôtres)
              if (paiements.isNotEmpty) ...[
                _buildSection(
                  title: 'Vos Paiements',
                  icon: Icons.payment,
                  color: Colors.blue,
                  items: paiements.take(3).toList(),
                  itemBuilder: (item) => ListTile(
                    leading: Icon(Icons.payment, color: Colors.blue),
                    title: Text(item['description'] ?? 'Paiement'),
                    subtitle: Text(item['date'] ?? ''),
                    trailing: Text(
                      item['montant'] ?? '',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: item['statut'] == 'Payé' ? Colors.green : Colors.orange,
                      ),
                    ),
                    onTap: () {
                      // Navigation vers détail du paiement
                    },
                  ),
                ),
                SizedBox(height: 20),
              ],
              
              // Vos constructions (seulement les vôtres)
              if (constructions.isNotEmpty) ...[
                _buildSection(
                  title: 'Vos Constructions',
                  icon: Icons.construction,
                  color: Colors.orange,
                  items: constructions.take(2).toList(),
                  itemBuilder: (item) => ListTile(
                    leading: Icon(Icons.construction, color: Colors.orange),
                    title: Text(item['type'] ?? 'Construction'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: _parseProgression(item['progression']),
                          backgroundColor: Colors.grey.shade200,
                          color: Colors.green,
                          minHeight: 6,
                        ),
                        SizedBox(height: 4),
                        Text(item['statut'] ?? 'En cours'),
                      ],
                    ),
                    trailing: Text(item['progression'] ?? '0%'),
                    onTap: () {
                      // Navigation vers détail de la construction
                    },
                  ),
                ),
                SizedBox(height: 20),
              ],
              
              // Message si pas de données
              if (terrains.isEmpty && paiements.isEmpty && constructions.isEmpty)
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Icon(Icons.inbox, size: 80, color: Colors.grey.shade300),
                        SizedBox(height: 20),
                        Text(
                          'Aucune donnée personnelle disponible',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Vos données apparaîtront ici une fois ajoutées par l\'administration',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _loadClientData,
                          child: Text('Actualiser les données'),
                        ),
                      ],
                    ),
                  ),
                ),
              
              SizedBox(height: 20),
              
              // Actions rapides
              Text(
                'Actions rapides',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade900,
                ),
              ),
              SizedBox(height: 15),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Contacter l'administration
                      },
                      icon: Icon(Icons.message),
                      label: Text('Contacter'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade50,
                        foregroundColor: Colors.green.shade900,
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Voir documents
                      },
                      icon: Icon(Icons.description),
                      label: Text('Documents'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade50,
                        foregroundColor: Colors.blue.shade900,
                      ),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 20),
              
              // Message de sécurité
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.security, color: Colors.blue, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Vos données sont sécurisées et privées. Seul vous pouvez les voir.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 30),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadClientData,
        backgroundColor: Colors.green,
        child: Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildMiniStat(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.green.shade800,
          ),
        ),
      ],
    );
  }
}