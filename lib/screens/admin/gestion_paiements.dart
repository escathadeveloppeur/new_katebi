import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '/models/paiement.dart';
import '/models/client.dart';
import '/services/database_service.dart';
import '/screens/admin/enregistrement_paiement.dart';
import '/services/notification_service.dart';

class GestionPaiements extends StatefulWidget {
  @override
  _GestionPaiementsState createState() => _GestionPaiementsState();
}

class _GestionPaiementsState extends State<GestionPaiements> {
  List<Paiement> _paiements = [];
  List<Client> _clients = [];
  DateTime? _selectedDate;
  String _filterType = 'tous';
  String? _selectedClientId;
  final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 0);
  final dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final paiements = await DatabaseService.getPaiements();
    final clients = await DatabaseService.getClients();

    setState(() {
      _paiements = paiements;
      _clients = clients;
    });
  }

  Future<void> _supprimerPaiement(String id) async {
    final confirmed = await NotificationService.showConfirmationDialog(
      context,
      'Supprimer Paiement',
      'Êtes-vous sûr de vouloir supprimer ce paiement ?',
    );

    if (confirmed) {
      await DatabaseService.paiementBox.delete(id);
      _loadData();
      NotificationService.showSuccess(context, 'Paiement supprimé avec succès');
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  List<Paiement> _getFilteredPaiements() {
    List<Paiement> filtered = _paiements;

    // Filtrer par type
    if (_filterType != 'tous') {
      filtered = filtered.where((p) => p.type == _filterType).toList();
    }

    // Filtrer par client
    if (_selectedClientId != null) {
      filtered =
          filtered.where((p) => p.clientId == _selectedClientId).toList();
    }

    // Filtrer par date
    if (_selectedDate != null) {
      filtered = filtered.where((p) {
        return p.datePaiement.year == _selectedDate!.year &&
            p.datePaiement.month == _selectedDate!.month &&
            p.datePaiement.day == _selectedDate!.day;
      }).toList();
    }

    // Trier par date (plus récent en premier)
    filtered.sort((a, b) => b.datePaiement.compareTo(a.datePaiement));

    return filtered;
  }

  double _calculerTotal(List<Paiement> paiements) {
    return paiements.fold(0.0, (sum, p) => sum + p.montant);
  }

  @override
  Widget build(BuildContext context) {
    final filteredPaiements = _getFilteredPaiements();
    final total = _calculerTotal(filteredPaiements);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => EnregistrementPaiement()),
          );
          _loadData();
        },
        icon: Icon(Icons.payment),
        label: Text('NOUVEAU PAIEMENT'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        elevation: 5,
      ),
      body: CustomScrollView(
        slivers: [
          // En-tête
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.green.shade900,
                      Colors.green.shade800,
                      Colors.green.shade700,
                    ],
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.only(left: 20, bottom: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.payment, color: Colors.white, size: 28),
                          SizedBox(width: 10),
                          Text(
                            'GESTION DES PAIEMENTS',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Suivi et gestion des transactions financières',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.refresh, color: Colors.white),
                onPressed: _loadData,
              ),
            ],
          ),

          // Section statistiques
          SliverToBoxAdapter(
            child: Container(
              margin: EdgeInsets.all(20),
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'TOTAL',
                      currencyFormat.format(total),
                      FontAwesomeIcons.moneyBillWave,
                      Colors.green,
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: _buildStatCard(
                      'TRANSACTIONS',
                      filteredPaiements.length.toString(),
                      Icons.list_alt,
                      Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Section filtres
          SliverToBoxAdapter(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
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
                    Text(
                      'FILTRES',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade900,
                        letterSpacing: 1.2,
                      ),
                    ),
                    SizedBox(height: 15),
                    Wrap(
                      spacing: 15,
                      runSpacing: 15,
                      children: [
                        // Filtre type
                        Container(
                          width: 200,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _filterType,
                                isExpanded: true,
                                icon: Icon(Icons.arrow_drop_down),
                                items: [
                                  DropdownMenuItem(
                                    value: 'tous',
                                    child: Row(
                                      children: [
                                        Icon(Icons.all_inclusive,
                                            color: Colors.grey, size: 20),
                                        SizedBox(width: 8),
                                        Text('Tous les types'),
                                      ],
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 'terrain',
                                    child: Row(
                                      children: [
                                        Icon(Icons.landscape,
                                            color: Colors.green, size: 20),
                                        SizedBox(width: 8),
                                        Text('Terrains'),
                                      ],
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 'construction',
                                    child: Row(
                                      children: [
                                        Icon(Icons.construction,
                                            color: Colors.orange, size: 20),
                                        SizedBox(width: 8),
                                        Text('Constructions'),
                                      ],
                                    ),
                                  ),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _filterType = value!;
                                  });
                                },
                              ),
                            ),
                          ),
                        ),

                        // Filtre client
                        Container(
                          width: 250,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedClientId,
                                isExpanded: true,
                                hint: Row(
                                  children: [
                                    Icon(Icons.person, color: Colors.grey),
                                    SizedBox(width: 8),
                                    Text('Tous les clients'),
                                  ],
                                ),
                                icon: Icon(Icons.arrow_drop_down),
                                items: [
                                  DropdownMenuItem(
                                    value: null,
                                    child: Text('Tous les clients'),
                                  ),
                                  ..._clients.map((client) {
                                    return DropdownMenuItem(
                                      value: client.numeroOrdre.toString(),
                                      child: Text(
                                        '${client.nom} ${client.prenom}',
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    );
                                  }).toList(),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _selectedClientId = value;
                                  });
                                },
                              ),
                            ),
                          ),
                        ),

                        // Filtre date
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: InkWell(
                            onTap: () => _selectDate(context),
                            borderRadius: BorderRadius.circular(10),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 12),
                              child: Row(
                                children: [
                                  Icon(Icons.calendar_today,
                                      color: Colors.green),
                                  SizedBox(width: 8),
                                  Text(
                                    _selectedDate != null
                                        ? dateFormat.format(_selectedDate!)
                                        : 'Toutes les dates',
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Bouton effacer date
                        if (_selectedDate != null)
                          IconButton(
                            icon: Icon(Icons.clear, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                _selectedDate = null;
                              });
                            },
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Liste des paiements
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'LISTE DES PAIEMENTS',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade900,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),

          if (filteredPaiements.isEmpty)
            SliverToBoxAdapter(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                padding: EdgeInsets.all(40),
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
                child: Column(
                  children: [
                    Icon(Icons.payment, size: 60, color: Colors.grey.shade400),
                    SizedBox(height: 20),
                    Text(
                      'Aucun paiement trouvé',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Aucun paiement ne correspond à vos filtres',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => EnregistrementPaiement()),
                        );
                        _loadData();
                      },
                      icon: Icon(Icons.add),
                      label: Text('AJOUTER UN PAIEMENT'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final paiement = filteredPaiements[index];
                  final client = _clients.firstWhere(
                    (c) => c.numeroOrdre.toString() == paiement.clientId,
                    orElse: () => Client(
                      numeroOrdre: 0,
                      nom: 'Inconnu',
                      postnom: '',
                      prenom: '',
                      telephone: '',
                      email: '',
                      nombreTerrains: 0,
                      blocId: '',
                      numerosTerrains: [],
                      fraisTotal: 0,
                      dateEnregistrement: DateTime.now(),
                    ),
                  );

                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(15),
                      leading: Container(
                        padding: EdgeInsets.all(10),
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
                          size: 24,
                        ),
                      ),
                      title: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${client.nom} ${client.prenom}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.calendar_today, size: 12),
                                    SizedBox(width: 4),
                                    Text(
                                      dateFormat.format(paiement.datePaiement),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 10),
                          Container(
                            padding:
                                EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: paiement.modePaiement == 'cash'
                                  ? Colors.green.shade100
                                  : Colors.blue.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              paiement.modePaiement.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: paiement.modePaiement == 'cash'
                                    ? Colors.green.shade800
                                    : Colors.blue.shade800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 8),
                          Text(
                            paiement.description,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade700,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.calendar_view_month, size: 12),
                              SizedBox(width: 4),
                              Text(
                                'Mois : ${paiement.mois}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            currencyFormat.format(paiement.montant),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.green.shade800,
                            ),
                          ),
                          SizedBox(height: 5),
                          Container(
                            padding:
                                EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: paiement.type == 'terrain'
                                  ? Colors.green.shade100
                                  : Colors.orange.shade100,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              paiement.type == 'terrain' ? 'TERRAIN' : 'CONSTRUCTION',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: paiement.type == 'terrain'
                                    ? Colors.green.shade800
                                    : Colors.orange.shade800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      onLongPress: () {
                        _showPaiementDetails(paiement, client);
                      },
                    ),
                  );
                },
                childCount: filteredPaiements.length,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      letterSpacing: 1.1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showPaiementDetails(Paiement paiement, Client client) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.payment, color: Colors.green, size: 28),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'DÉTAILS DU PAIEMENT',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    _detailItem(
                      Icons.person,
                      'Client',
                      '${client.nom} ${client.prenom}',
                    ),
                    SizedBox(height: 10),
                    _detailItem(
                      Icons.calendar_today,
                      'Date',
                      DateFormat('dd/MM/yyyy HH:mm').format(paiement.datePaiement),
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _detailItem(
                            Icons.category,
                            'Type',
                            paiement.type == 'terrain' ? 'Terrain' : 'Construction',
                          ),
                        ),
                        SizedBox(width: 20),
                        Expanded(
                          child: _detailItem(
                            Icons.payment,
                            'Mode',
                            paiement.modePaiement,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    _detailItem(
                      Icons.attach_money,
                      'Montant',
                      currencyFormat.format(paiement.montant),
                      isAmount: true,
                    ),
                    SizedBox(height: 10),
                    _detailItem(
                      Icons.calendar_view_month,
                      'Mois',
                      paiement.mois,
                    ),
                    SizedBox(height: 10),
                    _detailItem(
                      Icons.description,
                      'Description',
                      paiement.description,
                      isDescription: true,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'FERMER',
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _supprimerPaiement(paiement.id);
                      },
                      icon: Icon(Icons.delete, size: 18),
                      label: Text('SUPPRIMER'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailItem(IconData icon, String label, String value,
      {bool isAmount = false, bool isDescription = false}) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.green, size: 16),
              SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isAmount ? FontWeight.bold : FontWeight.normal,
              color: isAmount ? Colors.green.shade800 : Colors.grey.shade800,
            ),
            maxLines: isDescription ? 3 : 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}