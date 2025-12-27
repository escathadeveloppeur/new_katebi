import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:gestion_lotissement/models/catalogue.dart';
import 'package:gestion_lotissement/services/database_service.dart';
import 'package:gestion_lotissement/screens/admin/ajout_catalogue.dart';
import 'package:gestion_lotissement/services/notification_service.dart';

class GestionCatalogue extends StatefulWidget {
  @override
  _GestionCatalogueState createState() => _GestionCatalogueState();
}

class _GestionCatalogueState extends State<GestionCatalogue> {
  List<Catalogue> _catalogues = [];
  String _filterType = 'tous';

  @override
  void initState() {
    super.initState();
    _loadCatalogues();
  }

  Future<void> _loadCatalogues() async {
    final catalogues = await DatabaseService.getCatalogues();
    setState(() {
      _catalogues = catalogues;
    });
  }

  Future<void> _supprimerCatalogue(String id) async {
    final confirmed = await NotificationService.showConfirmationDialog(
      context,
      'Supprimer Catalogue',
      'Êtes-vous sûr de vouloir supprimer ce modèle ?',
    );

    if (confirmed) {
      await DatabaseService.catalogueBox.delete(id);
      _loadCatalogues();
      NotificationService.showSuccess(context, 'Modèle supprimé avec succès');
    }
  }

  String _getTypeText(String type) {
    switch (type) {
      case 'mise_en_valeur': return 'Mise en valeur';
      case 'moderne': return 'Moderne';
      default: return type;
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'mise_en_valeur': return Colors.orange;
      case 'moderne': return Colors.blue;
      default: return Colors.grey;
    }
  }

  List<Catalogue> _getFilteredCatalogues() {
    if (_filterType == 'tous') return _catalogues;
    return _catalogues.where((c) => c.typeConstruction == _filterType).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredCatalogues = _getFilteredCatalogues();
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: Text('Catalogue des Constructions'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AjoutCatalogue()),
              );
              _loadCatalogues();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtres
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _filterType,
                    decoration: InputDecoration(
                      labelText: 'Filtrer par type',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      DropdownMenuItem(value: 'tous', child: Text('Tous')),
                      DropdownMenuItem(
                        value: 'mise_en_valeur',
                        child: Text('Mise en valeur'),
                      ),
                      DropdownMenuItem(
                        value: 'moderne',
                        child: Text('Moderne'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _filterType = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),

          // Statistiques
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatCard(
                  'Total',
                  _catalogues.length.toString(),
                  Icons.library_books,
                ),
                _buildStatCard(
                  'Mise en valeur',
                  _catalogues.where((c) => c.typeConstruction == 'mise_en_valeur').length.toString(),
                  Icons.house,
                ),
                _buildStatCard(
                  'Moderne',
                  _catalogues.where((c) => c.typeConstruction == 'moderne').length.toString(),
                  Icons.apartment,
                ),
              ],
            ),
          ),

          SizedBox(height: 16),

          // Liste des catalogues
          Expanded(
            child: filteredCatalogues.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.photo_library, size: 80, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'Aucun modèle dans le catalogue',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Ajoutez votre premier modèle',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: EdgeInsets.all(16),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: filteredCatalogues.length,
                    itemBuilder: (context, index) {
                      final catalogue = filteredCatalogues[index];
                      return Card(
                        elevation: 4,
                        child: InkWell(
                          onTap: () {
                            _showCatalogueDetails(catalogue);
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Image placeholder
                              Container(
                                height: 120,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(8),
                                  ),
                                ),
                                child: catalogue.photos.isNotEmpty
                                    ? Icon(Icons.photo, size: 50, color: Colors.grey)
                                    : Center(
                                        child: Icon(
                                          catalogue.typeConstruction == 'moderne'
                                              ? Icons.apartment
                                              : Icons.house,
                                          size: 50,
                                          color: Colors.grey.shade400,
                                        ),
                                      ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Chip(
                                          label: Text(
                                            _getTypeText(catalogue.typeConstruction),
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                            ),
                                          ),
                                          backgroundColor:
                                              _getTypeColor(catalogue.typeConstruction),
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.delete,
                                              size: 20, color: Colors.red),
                                          onPressed: () =>
                                              _supprimerCatalogue(catalogue.id),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      catalogue.nom,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      catalogue.description,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      currencyFormat.format(catalogue.prix),
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: Colors.blue),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  void _showCatalogueDetails(Catalogue catalogue) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(catalogue.nom),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Images
              if (catalogue.photos.isNotEmpty)
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Icon(Icons.photo_library, size: 60, color: Colors.grey),
                  ),
                )
              else
                Container(
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Icon(
                      catalogue.typeConstruction == 'moderne'
                          ? Icons.apartment
                          : Icons.house,
                      size: 80,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ),
              SizedBox(height: 16),
              
              // Informations
              ListTile(
                leading: Icon(Icons.category),
                title: Text('Type'),
                subtitle: Text(_getTypeText(catalogue.typeConstruction)),
              ),
              ListTile(
                leading: Icon(Icons.description),
                title: Text('Description'),
                subtitle: Text(catalogue.description),
              ),
              ListTile(
                leading: Icon(Icons.attach_money),
                title: Text('Prix'),
                subtitle: Text(
                  '\$${catalogue.prix.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.date_range),
                title: Text('Date d\'ajout'),
                subtitle: Text(
                  DateFormat('dd/MM/yyyy').format(catalogue.dateCreation),
                ),
              ),
              if (catalogue.photos.isNotEmpty)
                ListTile(
                  leading: Icon(Icons.photo),
                  title: Text('Nombre de photos'),
                  subtitle: Text('${catalogue.photos.length} photo(s)'),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Fermer'),
          ),
        ],
      ),
    );
  }
}