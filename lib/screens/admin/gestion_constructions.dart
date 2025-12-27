import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '/models/construction.dart';
import '/services/database_service.dart';
import '/screens/admin/ajout_construction.dart';
import '/services/notification_service.dart';

class GestionConstructions extends StatefulWidget {
  @override
  _GestionConstructionsState createState() => _GestionConstructionsState();
}

class _GestionConstructionsState extends State<GestionConstructions> {
  List<Construction> _constructions = [];
  String _filterStatut = 'tous';

  @override
  void initState() {
    super.initState();
    _loadConstructions();
  }

  Future<void> _loadConstructions() async {
    final constructions = DatabaseService.constructionBox.values.toList();
    setState(() {
      _constructions = constructions;
    });
  }

  Future<void> _changerStatut(
    String constructionId,
    String nouveauStatut,
  ) async {
    final construction = DatabaseService.constructionBox.get(constructionId);
    if (construction != null) {
      construction.statut = nouveauStatut;
      if (nouveauStatut == 'complet') {
        construction.dateFin = DateTime.now();
      }
      await DatabaseService.constructionBox.put(constructionId, construction);
      _loadConstructions();
      NotificationService.showSuccess(context, 'Statut mis à jour');
    }
  }

  Color _getStatutColor(String statut) {
    switch (statut) {
      case 'en_attente':
        return Colors.grey.shade600;
      case 'en_cours':
        return Colors.blue.shade700;
      case 'complet':
        return Colors.green.shade700;
      default:
        return Colors.grey;
    }
  }

  Color _getStatutBgColor(String statut) {
    switch (statut) {
      case 'en_attente':
        return Colors.grey.shade100;
      case 'en_cours':
        return Colors.blue.shade50;
      case 'complet':
        return Colors.green.shade50;
      default:
        return Colors.grey.shade50;
    }
  }

  String _getStatutText(String statut) {
    switch (statut) {
      case 'en_attente':
        return 'EN ATTENTE';
      case 'en_cours':
        return 'EN COURS';
      case 'complet':
        return 'TERMINÉ';
      default:
        return statut.toUpperCase();
    }
  }

  List<Construction> _getFilteredConstructions() {
    if (_filterStatut == 'tous') return _constructions;
    return _constructions.where((c) => c.statut == _filterStatut).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredConstructions = _getFilteredConstructions();
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 0);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AjoutConstruction()),
          );
          _loadConstructions();
        },
        icon: Icon(Icons.add_circle_outline),
        label: Text('NOUVELLE CONSTRUCTION'),
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
                          Icon(Icons.construction, color: Colors.white, size: 28),
                          SizedBox(width: 10),
                          Text(
                            'GESTION DES CONSTRUCTIONS',
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
                        'Suivi des projets de construction',
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
                onPressed: _loadConstructions,
              ),
            ],
          ),

          // Filtre
          SliverToBoxAdapter(
            child: Container(
              margin: EdgeInsets.all(20),
              padding: EdgeInsets.all(16),
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
              child: Row(
                children: [
                  Icon(Icons.filter_alt, color: Colors.green, size: 20),
                  SizedBox(width: 10),
                  Text(
                    'FILTRER PAR STATUT',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade900,
                      letterSpacing: 1.1,
                    ),
                  ),
                  Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _filterStatut,
                        icon: Icon(Icons.arrow_drop_down),
                        items: [
                          DropdownMenuItem(
                            value: 'tous',
                            child: Row(
                              children: [
                                Icon(Icons.all_inclusive, size: 18, color: Colors.grey),
                                SizedBox(width: 8),
                                Text('Tous les statuts'),
                              ],
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'en_attente',
                            child: Row(
                              children: [
                                Icon(Icons.access_time, size: 18, color: Colors.orange),
                                SizedBox(width: 8),
                                Text('En attente'),
                              ],
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'en_cours',
                            child: Row(
                              children: [
                                Icon(Icons.build, size: 18, color: Colors.blue),
                                SizedBox(width: 8),
                                Text('En cours'),
                              ],
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'complet',
                            child: Row(
                              children: [
                                Icon(Icons.check_circle, size: 18, color: Colors.green),
                                SizedBox(width: 8),
                                Text('Terminé'),
                              ],
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _filterStatut = value!;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Statistiques
          SliverToBoxAdapter(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
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
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatCard(
                    'TOTAL',
                    _constructions.length.toString(),
                    Icons.construction,
                    Colors.green,
                  ),
                  _buildStatCard(
                    'EN COURS',
                    _constructions.where((c) => c.statut == 'en_cours').length.toString(),
                    Icons.build,
                    Colors.blue,
                  ),
                  _buildStatCard(
                    'TERMINÉES',
                    _constructions.where((c) => c.statut == 'complet').length.toString(),
                    Icons.check_circle,
                    Colors.green.shade700,
                  ),
                ],
              ),
            ),
          ),

          // Titre liste
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'LISTE DES CONSTRUCTIONS',
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
                      '${filteredConstructions.length} constructions',
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

          if (filteredConstructions.isEmpty)
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
                    Icon(Icons.construction, size: 80, color: Colors.grey.shade400),
                    SizedBox(height: 20),
                    Text(
                      'Aucune construction trouvée',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      _filterStatut == 'tous'
                          ? 'Commencez par créer votre première construction'
                          : 'Aucune construction avec ce statut',
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
                          MaterialPageRoute(builder: (context) => AjoutConstruction()),
                        );
                        _loadConstructions();
                      },
                      icon: Icon(Icons.add),
                      label: Text('CRÉER UNE CONSTRUCTION'),
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
                  final construction = filteredConstructions[index];
                  final statutColor = _getStatutColor(construction.statut);
                  final statutBgColor = _getStatutBgColor(construction.statut);
                  final progress = construction.montantTotal > 0
                      ? construction.montantPaye / construction.montantTotal
                      : 0;

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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // En-tête de la carte
                        Padding(
                          padding: EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      construction.nomComplet.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey.shade800,
                                        letterSpacing: 0.5,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: statutBgColor,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: statutColor.withOpacity(0.3)),
                                    ),
                                    child: Text(
                                      _getStatutText(construction.statut),
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: statutColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12),

                              // Informations
                              Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                children: [
                                  _infoChip(
                                    Icons.category,
                                    construction.typeConstruction,
                                    Colors.blue,
                                  ),
                                  _infoChip(
                                    Icons.location_on,
                                    construction.adresseParcelle,
                                    Colors.purple,
                                  ),
                                  _infoChip(
                                    Icons.calendar_today,
                                    '${construction.dureeConstruction} mois',
                                    Colors.orange,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Barre de progression du paiement
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'PROGRESSION DU PAIEMENT',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  Text(
                                    '${(progress * 100).toStringAsFixed(1)}%',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green.shade800,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Container(
                                height: 8,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: FractionallySizedBox(
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Payé: ${currencyFormat.format(construction.montantPaye)}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green.shade800,
                                    ),
                                  ),
                                  Text(
                                    'Total: ${currencyFormat.format(construction.montantTotal)}',
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

                        SizedBox(height: 20),

                        // Boutons d'action
                        if (construction.statut != 'complet')
                          Padding(
                            padding: EdgeInsets.all(20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (construction.statut == 'en_attente')
                                  ElevatedButton.icon(
                                    onPressed: () => _changerStatut(
                                      construction.id,
                                      'en_cours',
                                    ),
                                    icon: Icon(Icons.play_arrow, size: 18),
                                    label: Text('DÉMARRER'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                if (construction.statut == 'en_cours')
                                  ElevatedButton.icon(
                                    onPressed: () => _changerStatut(
                                      construction.id,
                                      'complet',
                                    ),
                                    icon: Icon(Icons.check, size: 18),
                                    label: Text('TERMINER'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  );
                },
                childCount: filteredConstructions.length,
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
          child: Icon(icon, color: color, size: 22),
        ),
        SizedBox(height: 10),
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
            fontSize: 11,
            color: Colors.grey.shade600,
            letterSpacing: 1.1,
          ),
        ),
      ],
    );
  }

  Widget _infoChip(IconData icon, String text, Color color) {
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