import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:gestion_lotissement/services/secure_client_service.dart';

class MesConstructionsPage extends StatefulWidget {
  final Map<String, dynamic>? clientData;
  
  const MesConstructionsPage({Key? key, this.clientData}) : super(key: key);

  @override
  _MesConstructionsPageState createState() => _MesConstructionsPageState();
}

class _MesConstructionsPageState extends State<MesConstructionsPage> {
  List<dynamic> _mesConstructions = [];
  List<dynamic> _catalogues = [];
  bool _isLoading = true;
  Map<String, dynamic>? _clientInfo;

  @override
  void initState() {
    super.initState();
    _chargerMesConstructions();
  }

  Future<void> _chargerMesConstructions() async {
    setState(() => _isLoading = true);

    try {
      // OPTION 1: Si les données sont passées depuis ClientPage
      if (widget.clientData != null) {
        _mesConstructions = widget.clientData!['constructions'] ?? [];
        _clientInfo = widget.clientData!['authInfo'] ?? {};
        
        // Charger les catalogues séparément
        _catalogues = await _chargerCatalogues();
      } 
      // OPTION 2: Sinon, charger directement depuis SecureClientService
      else {
        final clientData = await SecureClientService.getCurrentClientData();
        if (clientData != null) {
          _mesConstructions = clientData['constructions'] ?? [];
          _clientInfo = clientData['authInfo'] ?? {};
          
          // Charger les catalogues séparément
          _catalogues = await _chargerCatalogues();
        }
      }

      print('✅ Constructions chargées: ${_mesConstructions.length} projet(s)');
      print('✅ Catalogues chargés: ${_catalogues.length} modèle(s)');
    } catch (e) {
      print('❌ Erreur chargement constructions: $e');
      _mesConstructions = [];
      _catalogues = [];
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<List<dynamic>> _chargerCatalogues() async {
    // À implémenter: Charger les catalogues depuis votre service
    // Pour l'instant, retourner des données de démo
    return [
      {
        'id': 'cat_1',
        'nom': 'Maison Moderne 3 Chambres',
        'type': 'moderne',
        'description': 'Maison contemporaine avec 3 chambres, salon et cuisine américaine',
        'prix': 50000,
        'duree': 6,
        'image': 'assets/modern_house.jpg',
        'caracteristiques': ['3 chambres', '2 salles de bain', 'Garage', 'Jardin']
      },
      {
        'id': 'cat_2',
        'nom': 'Villa de Luxe',
        'type': 'luxe',
        'description': 'Villa spacieuse avec piscine et jardin paysager',
        'prix': 120000,
        'duree': 12,
        'image': 'assets/luxury_villa.jpg',
        'caracteristiques': ['5 chambres', '4 salles de bain', 'Piscine', 'Jardin']
      },
      {
        'id': 'cat_3',
        'nom': 'Appartement Économique',
        'type': 'economique',
        'description': 'Appartement fonctionnel et économique',
        'prix': 25000,
        'duree': 4,
        'image': 'assets/apartment.jpg',
        'caracteristiques': ['2 chambres', '1 salle de bain', 'Balcon']
      },
      {
        'id': 'cat_4',
        'nom': 'Bureau Commercial',
        'type': 'commercial',
        'description': 'Espace de bureau moderne pour professionnels',
        'prix': 75000,
        'duree': 8,
        'image': 'assets/office.jpg',
        'caracteristiques': ['Espace ouvert', 'Salle de réunion', 'Parking']
      }
    ];
  }

  Map<String, dynamic>? _getCatalogue(String catalogueId) {
    try {
      return _catalogues.firstWhere(
        (c) => c['id'] == catalogueId,
        orElse: () => {
          'nom': 'Modèle non spécifié',
          'type': 'standard',
          'description': 'Aucune description disponible',
          'prix': 0,
        },
      );
    } catch (e) {
      return {
        'nom': 'Modèle non spécifié',
        'type': 'standard',
        'description': 'Aucune description disponible',
        'prix': 0,
      };
    }
  }

  Color _getStatutColor(String? statut) {
    switch (statut) {
      case 'en_attente':
        return Colors.grey;
      case 'en_cours':
        return Colors.blue;
      case 'termine':
      case 'complet':
        return Colors.green;
      case 'suspendu':
        return Colors.orange;
      case 'annule':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatutText(String? statut) {
    switch (statut) {
      case 'en_attente':
        return 'En attente';
      case 'en_cours':
        return 'En cours';
      case 'termine':
      case 'complet':
        return 'Terminé';
      case 'suspendu':
        return 'Suspendu';
      case 'annule':
        return 'Annulé';
      default:
        return statut ?? 'Inconnu';
    }
  }

  double _getProgressionValue(String? progression) {
    if (progression == null) return 0.0;
    final match = RegExp(r'(\d+)').firstMatch(progression);
    if (match != null) {
      final value = int.tryParse(match.group(0) ?? '0') ?? 0;
      return value / 100.0;
    }
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 0);
    final dateFormat = DateFormat('dd/MM/yyyy');

    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('Chargement de vos constructions...'),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Mes Constructions'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _chargerMesConstructions,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _chargerMesConstructions,
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
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.orange.shade100,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Icon(
                                Icons.construction,
                                size: 28,
                                color: Colors.orange.shade800,
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Vos projets de construction',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Suivez l\'avancement de vos constructions',
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
                  color: Colors.orange.shade900,
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
                    title: 'Total projets',
                    value: _mesConstructions.length.toString(),
                    icon: Icons.construction,
                    color: Colors.orange,
                    subtitle: 'Constructions',
                  ),
                  _buildStatCard(
                    title: 'En cours',
                    value: _mesConstructions.where((c) => c['statut'] == 'en_cours').length.toString(),
                    icon: Icons.timelapse,
                    color: Colors.blue,
                    subtitle: 'Actifs',
                  ),
                  _buildStatCard(
                    title: 'Terminés',
                    value: _mesConstructions.where((c) => c['statut'] == 'termine').length.toString(),
                    icon: Icons.check_circle,
                    color: Colors.green,
                    subtitle: 'Finalisés',
                  ),
                  _buildStatCard(
                    title: 'Investissement',
                    value: _calculateTotalInvestissement(),
                    icon: Icons.attach_money,
                    color: Colors.purple,
                    subtitle: 'Total investi',
                  ),
                ],
              ),

              SizedBox(height: 24),

              // Liste des constructions
              Row(
                children: [
                  Text(
                    'Vos projets',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade900,
                    ),
                  ),
                  Spacer(),
                  if (_mesConstructions.isNotEmpty)
                    Chip(
                      label: Text('${_mesConstructions.length} projet(s)'),
                      backgroundColor: Colors.orange.shade50,
                    ),
                ],
              ),
              SizedBox(height: 12),

              if (_mesConstructions.isEmpty)
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: Column(
                      children: [
                        Icon(
                          Icons.construction,
                          size: 80,
                          color: Colors.grey.shade300,
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Aucun projet de construction',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Vous n\'avez pas encore de projet de construction en cours',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey.shade500,
                          ),
                        ),
                        SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () {
                            _showCatalogueComplet();
                          },
                          icon: Icon(Icons.add),
                          label: Text('Démarrer un projet'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ..._mesConstructions.map((construction) {
                  final catalogue = _getCatalogue(construction['catalogueId'] ?? '');
                  final statut = construction['statut'] ?? 'en_attente';
                  final progression = construction['progression'] ?? '0%';

                  return Card(
                    margin: EdgeInsets.only(bottom: 16),
                    elevation: 2,
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  construction['type'] ?? catalogue?['nom'] ?? 'Construction',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatutColor(statut).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: _getStatutColor(statut)),
                                ),
                                child: Text(
                                  _getStatutText(statut),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: _getStatutColor(statut),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 12),

                          // Localisation
                          if (construction['localisation'] != null)
                            Row(
                              children: [
                                Icon(Icons.location_on, size: 16, color: Colors.grey.shade600),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    construction['localisation'] ?? 'Non spécifiée',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                          SizedBox(height: 12),

                          // Progression
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Progression',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    progression,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange.shade800,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              LinearProgressIndicator(
                                value: _getProgressionValue(progression),
                                backgroundColor: Colors.grey.shade200,
                                color: _getProgressionValue(progression) >= 1.0
                                    ? Colors.green
                                    : Colors.orange,
                                minHeight: 8,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ],
                          ),

                          SizedBox(height: 12),

                          // Informations
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildInfoItem('Budget', construction['budget'] ?? 'N/A'),
                              _buildInfoItem('Début', construction['dateDebut'] != null 
                                  ? dateFormat.format(DateTime.parse(construction['dateDebut']))
                                  : 'N/A'),
                              _buildInfoItem('Fin estimée', construction['dateFin'] != null 
                                  ? dateFormat.format(DateTime.parse(construction['dateFin']))
                                  : 'N/A'),
                            ],
                          ),

                          SizedBox(height: 16),

                          // Actions
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                    _showDetailsConstruction(construction, catalogue);
                                  },
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: Colors.orange),
                                  ),
                                  child: Text(
                                    'Détails',
                                    style: TextStyle(color: Colors.orange),
                                  ),
                                ),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    _showSuiviProjet(construction);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange.shade800,
                                  ),
                                  child: Text('Suivre'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),

              SizedBox(height: 32),

              // Section catalogue
              Card(
                elevation: 2,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.photo_library, color: Colors.orange),
                          SizedBox(width: 8),
                          Text(
                            'Catalogue des modèles',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Spacer(),
                          TextButton(
                            onPressed: _showCatalogueComplet,
                            child: Text('Voir tout'),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Explorez nos modèles pour votre prochain projet',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                        ),
                      ),
                      SizedBox(height: 16),

                      if (_catalogues.isEmpty)
                        Center(
                          child: Column(
                            children: [
                              Icon(Icons.photo_library, size: 60, color: Colors.grey.shade300),
                              SizedBox(height: 16),
                              Text(
                                'Aucun modèle disponible',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                      else
                        SizedBox(
                          height: 180,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _catalogues.length,
                            itemBuilder: (context, index) {
                              final catalogue = _catalogues[index];
                              return Container(
                                width: 150,
                                margin: EdgeInsets.only(right: 12),
                                child: Card(
                                  elevation: 2,
                                  child: InkWell(
                                    onTap: () => _showDetailsCatalogue(catalogue),
                                    borderRadius: BorderRadius.circular(8),
                                    child: Padding(
                                      padding: EdgeInsets.all(12),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            height: 80,
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade100,
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Center(
                                              child: Icon(
                                                _getCatalogueIcon(catalogue['type']),
                                                size: 40,
                                                color: Colors.grey.shade400,
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            catalogue['nom'],
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            currencyFormat.format(catalogue['prix']),
                                            style: TextStyle(
                                              color: Colors.orange.shade800,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Icon(Icons.schedule, size: 12, color: Colors.grey),
                                              SizedBox(width: 4),
                                              Text(
                                                '${catalogue['duree']} mois',
                                                style: TextStyle(fontSize: 11, color: Colors.grey),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 24),

              // Message informatif
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, size: 20, color: Colors.orange),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Pour démarrer un nouveau projet, contactez l\'administration avec le modèle choisi.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange.shade800,
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
        onPressed: _showCatalogueComplet,
        backgroundColor: Colors.orange.shade800,
        child: Icon(Icons.add),
        tooltip: 'Nouveau projet',
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

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
          ),
        ),
        SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _calculateTotalInvestissement() {
    double total = 0;
    for (var construction in _mesConstructions) {
      final budgetStr = construction['budget']?.toString() ?? '0';
      final budget = double.tryParse(budgetStr.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
      total += budget;
    }
    return '${total.toStringAsFixed(0)} USD';
  }

  IconData _getCatalogueIcon(String? type) {
    switch (type) {
      case 'moderne':
        return Icons.apartment;
      case 'luxe':
        return Icons.villa;
      case 'economique':
        return Icons.house;
      case 'commercial':
        return Icons.business;
      default:
        return Icons.home;
    }
  }

  void _showDetailsConstruction(Map<String, dynamic> construction, Map<String, dynamic>? catalogue) {
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
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.construction,
                    size: 36,
                    color: Colors.orange.shade800,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        construction['type'] ?? 'Construction',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Chip(
                        label: Text(
                          _getStatutText(construction['statut']),
                          style: TextStyle(color: Colors.white),
                        ),
                        backgroundColor: _getStatutColor(construction['statut']),
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
                _buildDetailItem('Type', construction['type'] ?? 'N/A'),
                _buildDetailItem('Localisation', construction['localisation'] ?? 'N/A'),
                _buildDetailItem('Budget', construction['budget'] ?? 'N/A'),
                _buildDetailItem('Progression', construction['progression'] ?? '0%'),
                _buildDetailItem('Début', construction['dateDebut'] != null 
                    ? DateFormat('dd/MM/yyyy').format(DateTime.parse(construction['dateDebut']))
                    : 'N/A'),
                _buildDetailItem('Fin estimée', construction['dateFin'] != null 
                    ? DateFormat('dd/MM/yyyy').format(DateTime.parse(construction['dateFin']))
                    : 'N/A'),
              ],
            ),
            
            SizedBox(height: 16),
            
            if (catalogue != null) ...[
              Text(
                'Modèle de référence',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                catalogue['nom'] ?? 'N/A',
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 4),
              Text(
                catalogue['description'] ?? 'Aucune description',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
              SizedBox(height: 16),
            ],
            
            if (construction['description'] != null && construction['description'].isNotEmpty) ...[
              Text(
                'Description du projet',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                construction['description'],
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
              ),
              SizedBox(height: 16),
            ],
            
            Text(
              'Étapes du projet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            
            LinearProgressIndicator(
              value: _getProgressionValue(construction['progression']),
              backgroundColor: Colors.grey.shade200,
              color: _getProgressionValue(construction['progression']) >= 1.0
                  ? Colors.green
                  : Colors.orange,
              minHeight: 8,
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Progression actuelle',
                  style: TextStyle(fontSize: 12),
                ),
                Text(
                  construction['progression'] ?? '0%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
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
                      _showSuiviProjet(construction);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade800,
                    ),
                    child: Text('Suivi détaillé'),
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

  void _showSuiviProjet(Map<String, dynamic> construction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Suivi du projet'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildEtapeSuivi('Planification', true, true),
              _buildEtapeSuivi('Fondations', true, true),
              _buildEtapeSuivi('Murs', construction['progression'] == '60%' || construction['progression'] == '100%', construction['progression'] == '60%'),
              _buildEtapeSuivi('Toiture', construction['progression'] == '80%' || construction['progression'] == '100%', construction['progression'] == '80%'),
              _buildEtapeSuivi('Finitions', construction['progression'] == '90%' || construction['progression'] == '100%', construction['progression'] == '90%'),
              _buildEtapeSuivi('Livraison', construction['progression'] == '100%', construction['progression'] == '100%'),
            ],
          ),
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
                SnackBar(content: Text('Rapport demandé à l\'administration')),
              );
            },
            child: Text('Rapport détaillé'),
          ),
        ],
      ),
    );
  }

  Widget _buildEtapeSuivi(String etape, bool terminee, bool enCours) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: terminee ? Colors.green : (enCours ? Colors.orange : Colors.grey.shade300),
              border: Border.all(
                color: terminee ? Colors.green.shade800 : Colors.transparent,
              ),
            ),
            child: Center(
              child: Icon(
                terminee ? Icons.check : (enCours ? Icons.timelapse : Icons.schedule),
                size: 14,
                color: terminee ? Colors.white : (enCours ? Colors.white : Colors.grey.shade600),
              ),
            ),
          ),
          SizedBox(width: 12),
          Text(
            etape,
            style: TextStyle(
              fontWeight: enCours ? FontWeight.bold : FontWeight.normal,
              color: enCours ? Colors.orange.shade800 : Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  void _showCatalogueComplet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        height: MediaQuery.of(context).size.height * 0.8,
        child: Column(
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
            
            Text(
              'Catalogue des modèles',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Choisissez un modèle pour votre prochain projet',
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
            
            SizedBox(height: 20),
            
            Expanded(
              child: ListView.builder(
                itemCount: _catalogues.length,
                itemBuilder: (context, index) {
                  final catalogue = _catalogues[index];
                  final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 0);
                  
                  return Card(
                    margin: EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(16),
                      leading: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Icon(
                            _getCatalogueIcon(catalogue['type']),
                            size: 30,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                      title: Text(
                        catalogue['nom'],
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 4),
                          Text(
                            catalogue['description'] ?? '',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 12),
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Chip(
                                label: Text(
                                  currencyFormat.format(catalogue['prix']),
                                  style: TextStyle(fontSize: 11),
                                ),
                                backgroundColor: Colors.orange.shade50,
                              ),
                              SizedBox(width: 8),
                              Chip(
                                label: Text(
                                  '${catalogue['duree']} mois',
                                  style: TextStyle(fontSize: 11),
                                ),
                                backgroundColor: Colors.blue.shade50,
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => _showDetailsCatalogue(catalogue),
                    ),
                  );
                },
              ),
            ),
            
            SizedBox(height: 20),
            
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Contactez l\'administration pour démarrer un projet'),
                    action: SnackBarAction(
                      label: 'OK',
                      onPressed: () {},
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade800,
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text('Contacter l\'administration'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetailsCatalogue(Map<String, dynamic> catalogue) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(catalogue['nom']),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Icon(
                    _getCatalogueIcon(catalogue['type']),
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                ),
              ),
              SizedBox(height: 16),
              
              Text(
                catalogue['description'] ?? '',
                style: TextStyle(fontSize: 14),
              ),
              
              SizedBox(height: 16),
              
              Row(
                children: [
                  Icon(Icons.attach_money, size: 16, color: Colors.green),
                  SizedBox(width: 8),
                  Text(
                    'Prix: \$${catalogue['prix']}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              
              SizedBox(height: 8),
              
              Row(
                children: [
                  Icon(Icons.schedule, size: 16, color: Colors.blue),
                  SizedBox(width: 8),
                  Text(
                    'Durée: ${catalogue['duree']} mois',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              
              SizedBox(height: 8),
              
              Row(
                children: [
                  Icon(Icons.category, size: 16, color: Colors.orange),
                  SizedBox(width: 8),
                  Text(
                    'Type: ${catalogue['type']}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              
              SizedBox(height: 16),
              
              if (catalogue['caracteristiques'] != null) ...[
                Text(
                  'Caractéristiques:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                ...List.generate(
                  catalogue['caracteristiques'].length,
                  (index) => Padding(
                    padding: EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, size: 14, color: Colors.green),
                        SizedBox(width: 8),
                        Text(catalogue['caracteristiques'][index]),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
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
                SnackBar(
                  content: Text('Intéressé par le modèle ${catalogue['nom']}'),
                  action: SnackBarAction(
                    label: 'OK',
                    onPressed: () {},
                  ),
                ),
              );
            },
            child: Text('Choisir ce modèle'),
          ),
        ],
      ),
    );
  }
}