import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '/models/lotissement.dart';
import '/services/database_service.dart';
import '/screens/admin/ajout_lotissement.dart';
import '/screens/admin/gestion_blocs.dart';
import '/services/notification_service.dart';

class GestionLotissements extends StatefulWidget {
  @override
  _GestionLotissementsState createState() => _GestionLotissementsState();
}

class _GestionLotissementsState extends State<GestionLotissements> {
  List<Lotissement> _lotissements = [];

  @override
  void initState() {
    super.initState();
    _loadLotissements();
  }

  Future<void> _loadLotissements() async {
    final lotissements = await DatabaseService.getLotissements();
    setState(() {
      _lotissements = lotissements;
    });
  }

  Future<void> _supprimerLotissement(String id) async {
    final confirmed = await NotificationService.showConfirmationDialog(
      context,
      'Supprimer Lotissement',
      'Êtes-vous sûr de vouloir supprimer ce lotissement ? Cette action est irréversible.',
    );

    if (confirmed) {
      // Vérifier s'il y a des blocs associés
      final blocs = await DatabaseService.getBlocsByLotissement(id);
      if (blocs.isNotEmpty) {
        NotificationService.showError(
          context,
          'Impossible de supprimer. Des blocs sont associés à ce lotissement.',
        );
        return;
      }

      await DatabaseService.lotissementBox.delete(id);
      _loadLotissements();
      NotificationService.showSuccess(
        context,
        'Lotissement supprimé avec succès',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 0);
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AjoutLotissement()),
          );
          _loadLotissements();
        },
        icon: Icon(Icons.add_business),
        label: Text('NOUVEAU LOTISSEMENT'),
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
                          Icon(Icons.landscape, color: Colors.white, size: 28),
                          SizedBox(width: 10),
                          Text(
                            'GESTION DES LOTISSEMENTS',
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
                        'Administration des projets immobiliers',
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
                onPressed: _loadLotissements,
              ),
            ],
          ),

          // Statistiques
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
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatCard(
                    'TOTAL',
                    _lotissements.length.toString(),
                    Icons.business,
                    Colors.green,
                  ),
                  _buildStatCard(
                    'BLOCS',
                    _lotissements.fold(
                      0,
                      (sum, lot) => sum + lot.nombreBlocs,
                    ).toString(),
                    Icons.layers,
                    Colors.blue,
                  ),
                  _buildStatCard(
                    'INVESTISSEMENT',
                    currencyFormat.format(
                      _lotissements.fold(
                        0.0,
                        (sum, lot) => sum + lot.prix,
                      ),
                    ),
                    Icons.attach_money,
                    Colors.orange,
                  ),
                ],
              ),
            ),
          ),

          // Titre liste
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(left: 20, right: 20, bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'LISTE DES LOTISSEMENTS',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade900,
                      letterSpacing: 1.2,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      '${_lotissements.length} lotissements',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (_lotissements.isEmpty)
            SliverToBoxAdapter(
              child: Container(
                margin: EdgeInsets.all(20),
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
                    Icon(Icons.landscape, size: 80, color: Colors.grey.shade400),
                    SizedBox(height: 20),
                    Text(
                      'Aucun lotissement enregistré',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Commencez par créer votre premier lotissement',
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
                          MaterialPageRoute(builder: (context) => AjoutLotissement()),
                        );
                        _loadLotissements();
                      },
                      icon: Icon(Icons.add),
                      label: Text('CRÉER UN LOTISSEMENT'),
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
                  final lotissement = _lotissements[index];
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
                      contentPadding: EdgeInsets.all(20),
                      leading: Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.landscape,
                          color: Colors.blue.shade800,
                          size: 28,
                        ),
                      ),
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lotissement.nom.toUpperCase(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.grey.shade800,
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.date_range, size: 14, color: Colors.grey.shade600),
                              SizedBox(width: 4),
                              Text(
                                'Créé le ${dateFormat.format(lotissement.dateCreation)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      subtitle: Padding(
                        padding: EdgeInsets.only(top: 12),
                        child: Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            _buildInfoChip(
                              Icons.layers,
                              '${lotissement.nombreBlocs} Blocs',
                              Colors.green,
                            ),
                            _buildInfoChip(
                              Icons.attach_money,
                              currencyFormat.format(lotissement.prix),
                              Colors.orange,
                            ),
                            _buildInfoChip(
                              Icons.location_on,

                              'Lotissement ${lotissement.nom}',

                              Colors.purple,
                            ),
                          ],
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: IconButton(
                              icon: Icon(Icons.visibility, size: 20),
                              color: Colors.green,
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => GestionBlocs(lotissementId: lotissement.id),
                                  ),
                                );
                              },
                              tooltip: 'Voir les blocs',
                            ),
                          ),
                          SizedBox(width: 10),
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.red.shade100,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: IconButton(
                              icon: Icon(Icons.delete, size: 20),
                              color: Colors.red,
                              onPressed: () => _supprimerLotissement(lotissement.id),
                              tooltip: 'Supprimer',
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GestionBlocs(lotissementId: lotissement.id),
                          ),
                        );
                      },
                    ),
                  );
                },
                childCount: _lotissements.length,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        SizedBox(height: 10),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        SizedBox(height: 5),
        Text(
          title,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
            letterSpacing: 1.1,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoChip(IconData icon, String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}