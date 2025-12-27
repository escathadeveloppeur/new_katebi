import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:gestion_lotissement/services/secure_client_service.dart';

class MesPaiementsPage extends StatefulWidget {
  final Map<String, dynamic>? clientData;
  
  const MesPaiementsPage({Key? key, this.clientData}) : super(key: key);

  @override
  _MesPaiementsPageState createState() => _MesPaiementsPageState();
}

class _MesPaiementsPageState extends State<MesPaiementsPage> {
  List<dynamic> _mesPaiements = [];
  bool _isLoading = true;
  Map<String, dynamic>? _clientInfo;
  String _filterStatut = 'tous';
  String _filterType = 'tous';

  @override
  void initState() {
    super.initState();
    _chargerMesPaiements();
  }

  Future<void> _chargerMesPaiements() async {
    setState(() => _isLoading = true);

    try {
      // OPTION 1: Si les données sont passées depuis ClientPage
      if (widget.clientData != null) {
        _mesPaiements = widget.clientData!['paiements'] ?? [];
        _clientInfo = widget.clientData!['authInfo'] ?? {};
      } 
      // OPTION 2: Sinon, charger directement depuis SecureClientService
      else {
        final clientData = await SecureClientService.getCurrentClientData();
        if (clientData != null) {
          _mesPaiements = clientData['paiements'] ?? [];
          _clientInfo = clientData['authInfo'] ?? {};
        }
      }

      // Trier par date décroissante
      _mesPaiements.sort((a, b) {
        final dateA = DateTime.parse(a['date'] ?? '2000-01-01');
        final dateB = DateTime.parse(b['date'] ?? '2000-01-01');
        return dateB.compareTo(dateA);
      });

      print('✅ Paiements chargés: ${_mesPaiements.length} transaction(s)');
    } catch (e) {
      print('❌ Erreur chargement paiements: $e');
      _mesPaiements = [];
    } finally {
      setState(() => _isLoading = false);
    }
  }

  List<dynamic> _getPaiementsFiltres() {
    List<dynamic> result = _mesPaiements;

    if (_filterStatut != 'tous') {
      result = result.where((p) => p['statut'] == _filterStatut).toList();
    }

    if (_filterType != 'tous') {
      result = result.where((p) => p['type'] == _filterType).toList();
    }

    return result;
  }

  double _getTotalPaye() {
    return _mesPaiements
        .where((p) => p['statut'] == 'Payé')
        .fold(0.0, (sum, p) {
      final montantStr = p['montant']?.toString() ?? '0';
      final montant = double.tryParse(montantStr.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
      return sum + montant;
    });
  }

  double _getTotalEnAttente() {
    return _mesPaiements
        .where((p) => p['statut'] == 'En attente' || p['statut'] == 'En retard')
        .fold(0.0, (sum, p) {
      final montantStr = p['montant']?.toString() ?? '0';
      final montant = double.tryParse(montantStr.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
      return sum + montant;
    });
  }

  double _getTotalAnnule() {
    return _mesPaiements
        .where((p) => p['statut'] == 'Annulé')
        .fold(0.0, (sum, p) {
      final montantStr = p['montant']?.toString() ?? '0';
      final montant = double.tryParse(montantStr.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
      return sum + montant;
    });
  }

  Map<String, double> _getPaiementsParMois() {
    final Map<String, double> paiementsParMois = {};
    final dateFormat = DateFormat('MMM yyyy');

    for (var paiement in _mesPaiements) {
      if (paiement['statut'] == 'Payé' && paiement['date'] != null) {
        try {
          final date = DateTime.parse(paiement['date']);
          final mois = dateFormat.format(date);
          final montantStr = paiement['montant']?.toString() ?? '0';
          final montant = double.tryParse(montantStr.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
          
          paiementsParMois[mois] = (paiementsParMois[mois] ?? 0) + montant;
        } catch (e) {
          print('Erreur parsing date: $e');
        }
      }
    }

    // Trier par date
    final sortedEntries = paiementsParMois.entries.toList()
      ..sort((a, b) {
        try {
          final dateA = DateFormat('MMM yyyy').parse(a.key);
          final dateB = DateFormat('MMM yyyy').parse(b.key);
          return dateB.compareTo(dateA);
        } catch (e) {
          return 0;
        }
      });

    return Map.fromEntries(sortedEntries.take(6));
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 0);
    final dateFormat = DateFormat('dd/MM/yyyy');
    final paiementsFiltres = _getPaiementsFiltres();

    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('Chargement de vos paiements...'),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Mes Paiements'),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: 'Filtrer',
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _chargerMesPaiements,
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _chargerMesPaiements,
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
                              color: Colors.blue.shade100,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Icon(
                                Icons.payment,
                                size: 28,
                                color: Colors.blue.shade800,
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Vos transactions financières',
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
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16),

              // Statistiques
              Text(
                'Statistiques financières',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade900,
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
                    title: 'Total payé',
                    value: '${_getTotalPaye().toStringAsFixed(0)} USD',
                    icon: Icons.check_circle,
                    color: Colors.green,
                    subtitle: 'Transactions validées',
                  ),
                  _buildStatCard(
                    title: 'En attente',
                    value: '${_getTotalEnAttente().toStringAsFixed(0)} USD',
                    icon: Icons.schedule,
                    color: Colors.orange,
                    subtitle: 'À régulariser',
                  ),
                  _buildStatCard(
                    title: 'Transactions',
                    value: _mesPaiements.length.toString(),
                    icon: Icons.payment,
                    color: Colors.blue,
                    subtitle: 'Total opérations',
                  ),
                  _buildStatCard(
                    title: 'Annulés',
                    value: '${_getTotalAnnule().toStringAsFixed(0)} USD',
                    icon: Icons.cancel,
                    color: Colors.red,
                    subtitle: 'Transactions annulées',
                  ),
                ],
              ),

              SizedBox(height: 24),

              // Filtres actifs
              if (_filterStatut != 'tous' || _filterType != 'tous')
                Card(
                  elevation: 2,
                  color: Colors.blue.shade50,
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Icon(Icons.filter_alt, size: 18, color: Colors.blue),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Filtres actifs: ${_getFilterText()}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue.shade800,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _filterStatut = 'tous';
                              _filterType = 'tous';
                            });
                          },
                          child: Text(
                            'Effacer',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              SizedBox(height: 16),

              // Liste des paiements
              Row(
                children: [
                  Text(
                    'Historique des paiements',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade900,
                    ),
                  ),
                  Spacer(),
                  if (paiementsFiltres.isNotEmpty)
                    Chip(
                      label: Text('${paiementsFiltres.length} paiement(s)'),
                      backgroundColor: Colors.blue.shade50,
                    ),
                ],
              ),
              SizedBox(height: 12),

              if (paiementsFiltres.isEmpty)
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: Column(
                      children: [
                        Icon(
                          Icons.payment,
                          size: 80,
                          color: Colors.grey.shade300,
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Aucun paiement',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          _filterStatut != 'tous' || _filterType != 'tous'
                              ? 'Aucun paiement correspondant aux filtres'
                              : 'Vous n\'avez pas encore de paiements enregistrés',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...paiementsFiltres.map((paiement) {
                  final statut = paiement['statut'] ?? 'En attente';
                  final type = paiement['type'] ?? 'Paiement';
                  final date = paiement['date'] != null
                      ? dateFormat.format(DateTime.parse(paiement['date']))
                      : 'N/A';
                  final montant = paiement['montant'] ?? '0 USD';
                  final description = paiement['description'] ?? '';

                  return Card(
                    margin: EdgeInsets.only(bottom: 12),
                    elevation: 2,
                    child: InkWell(
                      onTap: () => _showDetailsPaiement(paiement),
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        description.isNotEmpty ? description : type,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        date,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
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
                                    statut,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: _getStatutColor(statut),
                                    ),
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
                                      'Type',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                    Text(
                                      type,
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
                                      'Montant',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                    Text(
                                      montant,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: _getMontantColor(statut),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            if (paiement['reference'] != null) ...[
                              SizedBox(height: 12),
                              Row(
                                children: [
                                  Icon(Icons.receipt, size: 14, color: Colors.grey),
                                  SizedBox(width: 4),
                                  Text(
                                    'Réf: ${paiement['reference']}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ],

                            SizedBox(height: 12),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () => _showDetailsPaiement(paiement),
                                  child: Text(
                                    'Détails',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                                SizedBox(width: 8),
                                if (statut == 'En attente' || statut == 'En retard')
                                  ElevatedButton(
                                    onPressed: () {
                                      _effectuerPaiement(paiement);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue.shade50,
                                      foregroundColor: Colors.blue.shade800,
                                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    ),
                                    child: Text(
                                      'Payer',
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
                }).toList(),

              SizedBox(height: 32),

              // Statistiques par mois
              Card(
                elevation: 2,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.timeline, color: Colors.blue),
                          SizedBox(width: 8),
                          Text(
                            'Historique mensuel',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      
                      if (_getPaiementsParMois().isEmpty)
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Center(
                            child: Text(
                              'Aucune donnée mensuelle disponible',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        )
                      else
                        Column(
                          children: _getPaiementsParMois().entries.map((entry) {
                            return Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      entry.key,
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ),
                                  Text(
                                    currencyFormat.format(entry.value),
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green.shade800,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 24),

              // Informations importantes
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, size: 20, color: Colors.blue),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Vos paiements sont traités dans un délai de 24 à 48h. '
                        'Conservez vos reçus de paiement.',
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
        onPressed: () {
          _simulerNouveauPaiement();
        },
        backgroundColor: Colors.blue.shade800,
        child: Icon(Icons.add),
        tooltip: 'Nouveau paiement',
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
                fontSize: 18,
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

  Color _getStatutColor(String statut) {
    switch (statut.toLowerCase()) {
      case 'payé':
      case 'complet':
        return Colors.green;
      case 'en attente':
        return Colors.orange;
      case 'en retard':
        return Colors.red;
      case 'annulé':
        return Colors.grey;
      case 'en cours':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Color _getMontantColor(String statut) {
    switch (statut.toLowerCase()) {
      case 'payé':
      case 'complet':
        return Colors.green.shade800;
      case 'en retard':
        return Colors.red.shade800;
      case 'annulé':
        return Colors.grey.shade600;
      default:
        return Colors.blue.shade800;
    }
  }

  String _getFilterText() {
    List<String> filters = [];
    
    if (_filterStatut != 'tous') {
      filters.add('Statut: $_filterStatut');
    }
    
    if (_filterType != 'tous') {
      filters.add('Type: $_filterType');
    }
    
    return filters.join(' • ');
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setStateSheet) {
          return Padding(
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
                
                Text(
                  'Filtrer les paiements',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                SizedBox(height: 20),
                
                Text(
                  'Statut',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 8),
                
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildFilterChip('Tous', _filterStatut == 'tous', () {
                      setStateSheet(() => _filterStatut = 'tous');
                    }),
                    _buildFilterChip('Payé', _filterStatut == 'Payé', () {
                      setStateSheet(() => _filterStatut = 'Payé');
                    }),
                    _buildFilterChip('En attente', _filterStatut == 'En attente', () {
                      setStateSheet(() => _filterStatut = 'En attente');
                    }),
                    _buildFilterChip('En retard', _filterStatut == 'En retard', () {
                      setStateSheet(() => _filterStatut = 'En retard');
                    }),
                    _buildFilterChip('Annulé', _filterStatut == 'Annulé', () {
                      setStateSheet(() => _filterStatut = 'Annulé');
                    }),
                  ],
                ),
                
                SizedBox(height: 20),
                
                Text(
                  'Type',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 8),
                
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildFilterChip('Tous', _filterType == 'tous', () {
                      setStateSheet(() => _filterType = 'tous');
                    }),
                    _buildFilterChip('Terrain', _filterType == 'terrain', () {
                      setStateSheet(() => _filterType = 'terrain');
                    }),
                    _buildFilterChip('Construction', _filterType == 'construction', () {
                      setStateSheet(() => _filterType = 'construction');
                    }),
                    _buildFilterChip('Taxe', _filterType == 'taxe', () {
                      setStateSheet(() => _filterType = 'taxe');
                    }),
                    _buildFilterChip('Autre', _filterType == 'autre', () {
                      setStateSheet(() => _filterType = 'autre');
                    }),
                  ],
                ),
                
                SizedBox(height: 30),
                
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setStateSheet(() {
                            _filterStatut = 'tous';
                            _filterType = 'tous';
                          });
                          setState(() {
                            _filterStatut = 'tous';
                            _filterType = 'tous';
                          });
                          Navigator.pop(context);
                        },
                        child: Text('Effacer tout'),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _filterStatut = _filterStatut;
                            _filterType = _filterType;
                          });
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade800,
                        ),
                        child: Text('Appliquer'),
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(String label, bool selected, VoidCallback onTap) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      selectedColor: Colors.blue.shade100,
      checkmarkColor: Colors.blue.shade800,
      onSelected: (selected) => onTap(),
    );
  }

  void _showDetailsPaiement(Map<String, dynamic> paiement) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final statut = paiement['statut'] ?? 'En attente';
    final type = paiement['type'] ?? 'Paiement';
    final date = paiement['date'] != null
        ? dateFormat.format(DateTime.parse(paiement['date']))
        : 'N/A';

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
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.payment,
                      size: 36,
                      color: Colors.blue.shade800,
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        paiement['description'] ?? type,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
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
                          statut,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _getStatutColor(statut),
                          ),
                        ),
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
                _buildDetailItem('Montant', paiement['montant'] ?? 'N/A'),
                _buildDetailItem('Type', type),
                _buildDetailItem('Statut', statut),
                _buildDetailItem('Date', date),
                _buildDetailItem('Référence', paiement['reference'] ?? 'N/A'),
                _buildDetailItem('Mode', paiement['mode'] ?? 'N/A'),
              ],
            ),
            
            SizedBox(height: 16),
            
            if (paiement['notes'] != null && paiement['notes'].isNotEmpty) ...[
              Text(
                'Notes',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                paiement['notes'],
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
              ),
              SizedBox(height: 16),
            ],
            
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Fermer'),
                  ),
                ),
                SizedBox(width: 12),
                if (statut == 'En attente' || statut == 'En retard')
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _effectuerPaiement(paiement);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade800,
                      ),
                      child: Text('Payer maintenant'),
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

  void _effectuerPaiement(Map<String, dynamic> paiement) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Effectuer le paiement'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Montant à payer: ${paiement['montant']}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Choisissez votre mode de paiement:',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 12),
            ListTile(
              leading: Icon(Icons.mobile_friendly, color: Colors.blue),
              title: Text('Mobile Money'),
              onTap: () => _processPaiement(paiement, 'Mobile Money'),
            ),
            ListTile(
              leading: Icon(Icons.credit_card, color: Colors.green),
              title: Text('Carte bancaire'),
              onTap: () => _processPaiement(paiement, 'Carte bancaire'),
            ),
            ListTile(
              leading: Icon(Icons.account_balance, color: Colors.purple),
              title: Text('Virement bancaire'),
              onTap: () => _processPaiement(paiement, 'Virement bancaire'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
        ],
      ),
    );
  }

  void _processPaiement(Map<String, dynamic> paiement, String mode) {
    Navigator.pop(context);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Redirection vers le paiement $mode...'),
        duration: Duration(seconds: 2),
      ),
    );
    
    Future.delayed(Duration(seconds: 2), () {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Paiement simulé avec succès!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
    });
  }

  void _simulerNouveauPaiement() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Nouveau paiement'),
        content: Text(
          'Pour effectuer un nouveau paiement, contactez l\'administration '
          'ou utilisez le système de paiement en ligne.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Redirection vers le portail de paiement...'),
                ),
              );
            },
            child: Text('Payer en ligne'),
          ),
        ],
      ),
    );
  }
}