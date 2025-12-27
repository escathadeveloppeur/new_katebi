import 'package:flutter/material.dart';
import 'package:gestion_lotissement/services/secure_client_service.dart';

class MesTerrainsPage extends StatefulWidget {
  final Map<String, dynamic>? clientData;
  
  const MesTerrainsPage({Key? key, this.clientData}) : super(key: key);

  @override
  _MesTerrainsPageState createState() => _MesTerrainsPageState();
}

class _MesTerrainsPageState extends State<MesTerrainsPage> {
  List<dynamic> _mesTerrains = [];
  bool _isLoading = true;
  Map<String, dynamic>? _clientInfo;

  @override
  void initState() {
    super.initState();
    _chargerMesTerrains();
  }

  Future<void> _chargerMesTerrains() async {
    setState(() => _isLoading = true);

    try {
      // OPTION 1: Si les données sont passées depuis ClientPage
      if (widget.clientData != null) {
        _mesTerrains = widget.clientData!['terrains'] ?? [];
        _clientInfo = widget.clientData!['authInfo'] ?? {};
      } 
      // OPTION 2: Sinon, charger directement depuis SecureClientService
      else {
        final clientData = await SecureClientService.getCurrentClientData();
        if (clientData != null) {
          _mesTerrains = clientData['terrains'] ?? [];
          _clientInfo = clientData['authInfo'] ?? {};
        }
      }

      print('✅ Terrains chargés: ${_mesTerrains.length} terrain(s)');
    } catch (e) {
      print('❌ Erreur chargement terrains: $e');
      _mesTerrains = [];
    } finally {
      setState(() => _isLoading = false);
    }
  }

  double _calculateTotalInvestissement() {
    double total = 0;
    for (var terrain in _mesTerrains) {
      final prixStr = terrain['prix']?.toString() ?? '0';
      final prix = double.tryParse(prixStr.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
      total += prix;
    }
    return total;
  }

  int _getTerrainsDisponibles() {
    return _mesTerrains.where((t) => t['statut'] == 'Disponible').length;
  }

  int _getTerrainsVendus() {
    return _mesTerrains.where((t) => t['statut'] == 'Vendu').length;
  }

  int _getTerrainsReserves() {
    return _mesTerrains.where((t) => t['statut'] == 'Réservé').length;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('Chargement de vos terrains...'),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Mes Terrains'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _chargerMesTerrains,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _chargerMesTerrains,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête avec informations client
              Card(
                elevation: 3,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors.green.shade100,
                            child: Icon(
                              Icons.person,
                              size: 28,
                              color: Colors.green.shade800,
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${_clientInfo?['prenom'] ?? ''} ${_clientInfo?['nom'] ?? ''}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Client ID: ${_clientInfo?['clientId'] ?? 'N/A'}',
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
                      SizedBox(height: 16),
                      Text(
                        'Résumé de vos terrains',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16),

              // Statistiques
              Text(
                'Statistiques',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade900,
                ),
              ),
              SizedBox(height: 12),

              GridView.count(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.3,
                children: [
                  _buildStatCard(
                    title: 'Total terrains',
                    value: _mesTerrains.length.toString(),
                    icon: Icons.landscape,
                    color: Colors.green,
                    subtitle: 'Propriétés',
                  ),
                  _buildStatCard(
                    title: 'Disponibles',
                    value: _getTerrainsDisponibles().toString(),
                    icon: Icons.check_circle,
                    color: Colors.blue,
                    subtitle: 'À construire',
                  ),
                  _buildStatCard(
                    title: 'Vendus',
                    value: _getTerrainsVendus().toString(),
                    icon: Icons.sell,
                    color: Colors.orange,
                    subtitle: 'Transactions',
                  ),
                  _buildStatCard(
                    title: 'Investissement',
                    value: '${_calculateTotalInvestissement().toStringAsFixed(0)} USD',
                    icon: Icons.attach_money,
                    color: Colors.purple,
                    subtitle: 'Total investi',
                  ),
                ],
              ),

              SizedBox(height: 24),

              // Liste des terrains
              Row(
                children: [
                  Text(
                    'Liste de vos terrains',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade900,
                    ),
                  ),
                  Spacer(),
                  if (_mesTerrains.isNotEmpty)
                    Chip(
                      label: Text('${_mesTerrains.length} terrain(s)'),
                      backgroundColor: Colors.green.shade50,
                    ),
                ],
              ),
              SizedBox(height: 12),

              if (_mesTerrains.isEmpty)
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: Column(
                      children: [
                        Icon(
                          Icons.landscape,
                          size: 80,
                          color: Colors.grey.shade300,
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Aucun terrain',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Vous n\'avez pas encore de terrain dans votre portefeuille',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey.shade500,
                          ),
                        ),
                        SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Contactez l\'administration pour acheter un terrain'),
                              ),
                            );
                          },
                          icon: Icon(Icons.add),
                          label: Text('Acquérir un terrain'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: _mesTerrains.length,
                  itemBuilder: (context, index) {
                    final terrain = _mesTerrains[index];
                    return _buildTerrainCard(terrain, index);
                  },
                ),

              SizedBox(height: 24),

              // Informations supplémentaires
              Card(
                elevation: 2,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info, color: Colors.blue),
                          SizedBox(width: 8),
                          Text(
                            'Informations importantes',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Text(
                        '• Chaque terrain est unique et identifié par un numéro spécifique',
                        style: TextStyle(fontSize: 13),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '• Les dimensions et prix sont calculés selon le plan d\'urbanisme',
                        style: TextStyle(fontSize: 13),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '• Pour toute question concernant vos terrains, contactez l\'administration',
                        style: TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 30),

              // Message de confidentialité
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.security, size: 20, color: Colors.blue),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Vos informations sont confidentielles. Seul vous pouvez voir vos terrains.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Action pour ajouter ou voir les détails
          _showTerrainsDetails();
        },
        backgroundColor: Colors.green.shade800,
        child: Icon(Icons.filter_list),
        tooltip: 'Filtrer les terrains',
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String subtitle,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 18, color: color),
                ),
                Spacer(),
              ],
            ),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTerrainCard(Map<String, dynamic> terrain, int index) {
    final numero = terrain['numero'] ?? 'N/A';
    final superficie = terrain['superficie'] ?? 'N/A';
    final prix = terrain['prix'] ?? 'N/A';
    final statut = terrain['statut'] ?? 'N/A';
    final localisation = terrain['localisation'] ?? 'N/A';
    final description = terrain['description'] ?? '';

    Color statutColor = Colors.grey;
    IconData statutIcon = Icons.help_outline;
    
    switch (statut) {
      case 'Disponible':
        statutColor = Colors.green;
        statutIcon = Icons.check_circle;
        break;
      case 'Vendu':
        statutColor = Colors.blue;
        statutIcon = Icons.sell;
        break;
      case 'Réservé':
        statutColor = Colors.orange;
        statutIcon = Icons.schedule;
        break;
      case 'Indisponible':
        statutColor = Colors.red;
        statutIcon = Icons.block;
        break;
    }

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: () => _showTerrainDetails(terrain),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Center(
                      child: Text(
                        '#${index + 1}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade800,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Terrain $numero',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: statutColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: statutColor),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(statutIcon, size: 12, color: statutColor),
                                  SizedBox(width: 4),
                                  Text(
                                    statut,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: statutColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Superficie: $superficie',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 12),
              
              Divider(height: 1),
              
              SizedBox(height: 12),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Localisation',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      Text(
                        localisation,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Prix',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      Text(
                        prix,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade800,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              if (description.isNotEmpty) ...[
                SizedBox(height: 12),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              
              SizedBox(height: 8),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => _showTerrainDetails(terrain),
                    child: Text(
                      'Voir détails',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      _showActionsMenu(terrain);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade50,
                      foregroundColor: Colors.green.shade800,
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    ),
                    child: Text(
                      'Actions',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTerrainDetails(Map<String, dynamic> terrain) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 60,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: 20),
            
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.landscape,
                    size: 36,
                    color: Colors.green.shade800,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Terrain ${terrain['numero']}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Chip(
                        label: Text(
                          terrain['statut'] ?? 'N/A',
                          style: TextStyle(color: Colors.white),
                        ),
                        backgroundColor: _getStatusColor(terrain['statut']),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 24),
            
            GridView.count(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 3,
              children: [
                _buildDetailItem('Numéro', terrain['numero'] ?? 'N/A'),
                _buildDetailItem('Superficie', terrain['superficie'] ?? 'N/A'),
                _buildDetailItem('Prix', terrain['prix'] ?? 'N/A'),
                _buildDetailItem('Localisation', terrain['localisation'] ?? 'N/A'),
                _buildDetailItem('Bloc', terrain['bloc'] ?? 'N/A'),
                _buildDetailItem('Type', terrain['type'] ?? 'Standard'),
              ],
            ),
            
            SizedBox(height: 16),
            
            if ((terrain['description'] ?? '').isNotEmpty) ...[
              Text(
                'Description',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                terrain['description'],
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
              ),
              SizedBox(height: 16),
            ],
            
            Text(
              'Informations techniques',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '• Certificat de propriété: ${terrain['certificat'] ?? 'En cours'}',
              style: TextStyle(fontSize: 14),
            ),
            Text(
              '• Plan de situation: ${terrain['plan'] ?? 'Disponible'}',
              style: TextStyle(fontSize: 14),
            ),
            Text(
              '• Bornage: ${terrain['bornage'] ?? 'Effectué'}',
              style: TextStyle(fontSize: 14),
            ),
            
            SizedBox(height: 24),
            
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Fermer'),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _showActionsMenu(terrain);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade800,
                    ),
                    child: Text('Actions'),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String? statut) {
    switch (statut) {
      case 'Disponible': return Colors.green;
      case 'Vendu': return Colors.blue;
      case 'Réservé': return Colors.orange;
      case 'Indisponible': return Colors.red;
      default: return Colors.grey;
    }
  }

  void _showActionsMenu(Map<String, dynamic> terrain) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.visibility, color: Colors.blue),
              title: Text('Voir sur la carte'),
              onTap: () {
                Navigator.pop(context);
                _showOnMap(terrain);
              },
            ),
            ListTile(
              leading: Icon(Icons.download, color: Colors.green),
              title: Text('Télécharger le certificat'),
              onTap: () {
                Navigator.pop(context);
                _downloadCertificate(terrain);
              },
            ),
            ListTile(
              leading: Icon(Icons.share, color: Colors.purple),
              title: Text('Partager les informations'),
              onTap: () {
                Navigator.pop(context);
                _shareTerrainInfo(terrain);
              },
            ),
            ListTile(
              leading: Icon(Icons.help, color: Colors.orange),
              title: Text('Obtenir de l\'aide'),
              onTap: () {
                Navigator.pop(context);
                _getHelp(terrain);
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.close, color: Colors.grey),
              title: Text('Fermer'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showTerrainsDetails() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Filtrer vos terrains'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildFilterChip('Tous', true),
            _buildFilterChip('Disponibles', false),
            _buildFilterChip('Vendus', false),
            _buildFilterChip('Réservés', false),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Fermer'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Filtre appliqué')),
              );
            },
            child: Text('Appliquer'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool selected) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        selectedColor: Colors.green.shade100,
        onSelected: (selected) {},
      ),
    );
  }

  void _showOnMap(Map<String, dynamic> terrain) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Affichage du terrain ${terrain['numero']} sur la carte')),
    );
  }

  void _downloadCertificate(Map<String, dynamic> terrain) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Téléchargement du certificat pour le terrain ${terrain['numero']}')),
    );
  }

  void _shareTerrainInfo(Map<String, dynamic> terrain) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Partage des informations du terrain ${terrain['numero']}')),
    );
  }

  void _getHelp(Map<String, dynamic> terrain) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Assistance pour le terrain ${terrain['numero']}')),
    );
  }
}