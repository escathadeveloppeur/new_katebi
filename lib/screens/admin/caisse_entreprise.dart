import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:gestion_lotissement/models/paiement.dart';
import 'package:gestion_lotissement/services/database_service.dart';

class CaisseEntreprise extends StatefulWidget {
  @override
  _CaisseEntrepriseState createState() => _CaisseEntrepriseState();
}

class _CaisseEntrepriseState extends State<CaisseEntreprise> {
  List<Paiement> _paiements = [];
  List<Map<String, dynamic>> _transactionsJournalieres = [];
  DateTime _selectedDate = DateTime.now();
  double _totalJour = 0;
  double _totalMois = 0;
  double _totalAnnee = 0;

  @override
  void initState() {
    super.initState();
    _loadPaiements();
  }

  Future<void> _loadPaiements() async {
    final paiements = await DatabaseService.getPaiements();
    setState(() {
      _paiements = paiements;
      _calculerTotaux();
      _grouperTransactions();
    });
  }

  void _calculerTotaux() {
    final now = DateTime.now();
    
    // Total du jour
    _totalJour = _paiements
        .where((p) =>
            p.datePaiement.year == now.year &&
            p.datePaiement.month == now.month &&
            p.datePaiement.day == now.day)
        .fold(0.0, (sum, p) => sum + p.montant);

    // Total du mois
    _totalMois = _paiements
        .where((p) =>
            p.datePaiement.year == now.year &&
            p.datePaiement.month == now.month)
        .fold(0.0, (sum, p) => sum + p.montant);

    // Total de l'année
    _totalAnnee = _paiements
        .where((p) => p.datePaiement.year == now.year)
        .fold(0.0, (sum, p) => sum + p.montant);
  }

  void _grouperTransactions() {
    Map<DateTime, List<Paiement>> grouped = {};
    
    for (var paiement in _paiements) {
      final date = DateTime(
        paiement.datePaiement.year,
        paiement.datePaiement.month,
        paiement.datePaiement.day,
      );
      
      if (!grouped.containsKey(date)) {
        grouped[date] = [];
      }
      grouped[date]!.add(paiement);
    }

    _transactionsJournalieres = grouped.entries.map((entry) {
      final total = entry.value.fold(0.0, (sum, p) => sum + p.montant);
      final terrains = entry.value.where((p) => p.type == 'terrain').length;
      final constructions = entry.value.where((p) => p.type == 'construction').length;
      
      return {
        'date': entry.key,
        'paiements': entry.value,
        'total': total,
        'terrains': terrains,
        'constructions': constructions,
      };
    }).toList();

    _transactionsJournalieres.sort((a, b) => b['date'].compareTo(a['date']));
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 0);
    final dateFormat = DateFormat('dd/MM/yyyy');
    final monthFormat = DateFormat('MMMM yyyy');

    // Paiements de la date sélectionnée
    final paiementsDuJour = _paiements.where((p) {
      return p.datePaiement.year == _selectedDate.year &&
             p.datePaiement.month == _selectedDate.month &&
             p.datePaiement.day == _selectedDate.day;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Caisse de l\'Entreprise'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadPaiements,
          ),
        ],
      ),
      body: Column(
        children: [
          // Statistiques globales
          Card(
            margin: EdgeInsets.all(16),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'Aperçu Financier',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatItem('Aujourd\'hui', _totalJour, Colors.green),
                      _buildStatItem('Ce mois', _totalMois, Colors.blue),
                      _buildStatItem('Cette année', _totalAnnee, Colors.orange),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Sélection de date
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: InkWell(
              onTap: () => _selectDate(context),
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Transactions du jour',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(dateFormat.format(_selectedDate)),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            currencyFormat.format(paiementsDuJour.fold(
                              0.0,
                              (sum, p) => sum + p.montant,
                            )),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.green,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.calendar_today, color: Colors.blue),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Transactions du jour sélectionné
          Expanded(
            child: paiementsDuJour.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.payment, size: 80, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'Aucune transaction pour cette date',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: paiementsDuJour.length,
                    itemBuilder: (context, index) {
                      final paiement = paiementsDuJour[index];
                      return Card(
                        margin: EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: paiement.type == 'terrain'
                                  ? Colors.green.shade100
                                  : Colors.orange.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              paiement.type == 'terrain'
                                  ? Icons.landscape
                                  : Icons.construction,
                              color: paiement.type == 'terrain'
                                  ? Colors.green
                                  : Colors.orange,
                            ),
                          ),
                          title: Text(
                            paiement.description,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${paiement.modePaiement} - ${paiement.mois}'),
                              Text(
                                DateFormat('HH:mm').format(paiement.datePaiement),
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
                                  color: Colors.green,
                                ),
                              ),
                              SizedBox(height: 4),
                              Chip(
                                label: Text(
                                  paiement.type == 'terrain' ? 'Terrain' : 'Construction',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                  ),
                                ),
                                backgroundColor: paiement.type == 'terrain'
                                    ? Colors.green
                                    : Colors.orange,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // Transactions journalières (historique)
          if (_transactionsJournalieres.isNotEmpty) ...[
            Divider(),
            Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Historique des Transactions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: _transactionsJournalieres.length,
                itemBuilder: (context, index) {
                  final transaction = _transactionsJournalieres[index];
                  return Card(
                    margin: EdgeInsets.only(bottom: 12),
                    child: ExpansionTile(
                      leading: Icon(Icons.date_range, color: Colors.blue),
                      title: Text(dateFormat.format(transaction['date'])),
                      subtitle: Text(
                        '${transaction['terrains']} terrains, ${transaction['constructions']} constructions',
                      ),
                      trailing: Text(
                        currencyFormat.format(transaction['total']),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      children: (transaction['paiements'] as List<Paiement>)
                          .map((paiement) => ListTile(
                                leading: Icon(
                                  paiement.type == 'terrain'
                                      ? Icons.landscape
                                      : Icons.construction,
                                  size: 20,
                                ),
                                title: Text(paiement.description),
                                subtitle: Text(paiement.modePaiement),
                                trailing: Text(
                                  currencyFormat.format(paiement.montant),
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ))
                          .toList(),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatItem(String title, double montant, Color color) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.attach_money,
            color: color,
            size: 24,
          ),
        ),
        SizedBox(height: 8),
        Text(
          '\$${montant.toStringAsFixed(0)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          title,
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}