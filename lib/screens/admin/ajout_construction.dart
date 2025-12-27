import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '/models/construction.dart';
import '/models/catalogue.dart';
import '/models/client.dart';
import '/services/database_service.dart';
import '/services/notification_service.dart';

class AjoutConstruction extends StatefulWidget {
  @override
  _AjoutConstructionState createState() => _AjoutConstructionState();
}

class _AjoutConstructionState extends State<AjoutConstruction> {
  final _formKey = GlobalKey<FormState>();
  final _uuid = Uuid();
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  TextEditingController _nomCompletController = TextEditingController();
  TextEditingController _adresseController = TextEditingController();
  TextEditingController _dureeConstructionController = TextEditingController();
  TextEditingController _dureePaiementController = TextEditingController();

  List<Client> _clients = [];
  List<Catalogue> _catalogues = [];

  String? _selectedClientId;
  String? _selectedTypeConstruction;
  String? _selectedCatalogueId;
  Catalogue? _selectedCatalogue;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _chargerClients();
    _chargerCatalogues();
  }

  Future<void> _chargerClients() async {
    final clients = await DatabaseService.getClients();
    setState(() {
      _clients = clients;
    });
  }

  Future<void> _chargerCatalogues() async {
    final catalogues = await DatabaseService.getCatalogues();
    setState(() {
      _catalogues = catalogues;
    });
  }

  Future<void> _ajouterConstruction() async {
    if (_formKey.currentState!.validate() && _selectedCatalogue != null) {
      setState(() => _isLoading = true);

      try {
        Construction nouvelleConstruction = Construction(
          id: _uuid.v4(),
          clientId: _selectedClientId!,
          nomComplet: _nomCompletController.text,
          typeConstruction: _selectedTypeConstruction!,
          catalogueId: _selectedCatalogueId!,
          adresseParcelle: _adresseController.text,
          dureeConstruction: int.parse(_dureeConstructionController.text),
          dureePaiement: int.parse(_dureePaiementController.text),
          montantTotal: _selectedCatalogue!.prix,
          dateDebut: DateTime.now(),
          statut: 'en_attente',
        );

        await DatabaseService.ajouterConstruction(nouvelleConstruction);

        NotificationService.showSuccess(
          context,
          'Construction enregistrée avec succès',
        );
        Navigator.pop(context);
      } catch (e) {
        NotificationService.showError(context, 'Erreur: $e');
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 0);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.add_circle_outline, size: 24),
            SizedBox(width: 10),
            Text(
              'NOUVELLE CONSTRUCTION',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green.shade900,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // En-tête
            Container(
              padding: EdgeInsets.all(25),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.green.shade800,
                    Colors.green.shade700,
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.construction,
                    size: 50,
                    color: Colors.white,
                  ),
                  SizedBox(height: 15),
                  Text(
                    'NOUVELLE CONSTRUCTION',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.5,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Enregistrement d\'un nouveau projet de construction',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            // Formulaire
            Container(
              margin: EdgeInsets.all(20),
              padding: EdgeInsets.all(25),
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
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'INFORMATIONS DE LA CONSTRUCTION',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade900,
                        letterSpacing: 1.1,
                      ),
                    ),
                    SizedBox(height: 5),
                    Container(
                      height: 2,
                      color: Colors.green.shade300,
                      width: 150,
                    ),
                    SizedBox(height: 25),

                    // Sélection du client
                    Text(
                      'CLIENT',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                        letterSpacing: 1.1,
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedClientId,
                            hint: Row(
                              children: [
                                Icon(Icons.person, color: Colors.grey),
                                SizedBox(width: 8),
                                Text('Sélectionner un client'),
                              ],
                            ),
                            isExpanded: true,
                            icon: Icon(Icons.arrow_drop_down),
                            items: _clients.map((client) {
                              return DropdownMenuItem(
                                value: client.numeroOrdre.toString(),
                                child: Text(
                                  '${client.nom} ${client.prenom} - ${client.telephone}',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedClientId = value;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),

                    // Nom complet
                    Text(
                      'NOM COMPLET',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                        letterSpacing: 1.1,
                      ),
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: _nomCompletController,
                      decoration: InputDecoration(
                        hintText: 'Nom complet du client',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.green),
                        ),
                        prefixIcon: Icon(Icons.person_outline, color: Colors.green),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer le nom complet';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),

                    // Type de construction
                    Text(
                      'TYPE DE CONSTRUCTION',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                        letterSpacing: 1.1,
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedTypeConstruction,
                            hint: Row(
                              children: [
                                Icon(Icons.category, color: Colors.grey),
                                SizedBox(width: 8),
                                Text('Sélectionner un type'),
                              ],
                            ),
                            isExpanded: true,
                            icon: Icon(Icons.arrow_drop_down),
                            items: [
                              DropdownMenuItem(
                                value: 'mise_en_valeur',
                                child: Row(
                                  children: [
                                    Icon(Icons.landscape, color: Colors.blue),
                                    SizedBox(width: 8),
                                    Text('Construction de mise en valeur'),
                                  ],
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'moderne',
                                child: Row(
                                  children: [
                                    Icon(Icons.apartment, color: Colors.green),
                                    SizedBox(width: 8),
                                    Text('Construction moderne'),
                                  ],
                                ),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedTypeConstruction = value;
                                _selectedCatalogueId = null;
                                _selectedCatalogue = null;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),

                    // Catalogue
                    if (_selectedTypeConstruction != null) ...[
                      Text(
                        'MODÈLE DE CONSTRUCTION',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade700,
                          letterSpacing: 1.1,
                        ),
                      ),
                      SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedCatalogueId,
                              hint: Row(
                                children: [
                                  Icon(Icons.photo_library, color: Colors.grey),
                                  SizedBox(width: 8),
                                  Text('Sélectionner un modèle'),
                                ],
                              ),
                              isExpanded: true,
                              icon: Icon(Icons.arrow_drop_down),
                              items: _catalogues
                                  .where(
                                    (c) => c.typeConstruction == _selectedTypeConstruction,
                                  )
                                  .map((catalogue) {
                                    return DropdownMenuItem(
                                      value: catalogue.id,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            catalogue.nom,
                                            style: TextStyle(fontWeight: FontWeight.w500),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            '${currencyFormat.format(catalogue.prix)} - ${catalogue.description}',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey.shade600,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    );
                                  })
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedCatalogueId = value;
                                  _selectedCatalogue = _catalogues.firstWhere(
                                    (c) => c.id == value,
                                    orElse: () => Catalogue(
                                      id: '',
                                      nom: '',
                                      typeConstruction: '',
                                      description: '',
                                      prix: 0,
                                      dateCreation: DateTime.now(),
                                    ),
                                  );
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                    ],

                    // Détails du catalogue sélectionné
                    if (_selectedCatalogue != null) ...[
                      Container(
                        padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.info_outline, color: Colors.blue),
                                SizedBox(width: 8),
                                Text(
                                  'MODÈLE SÉLECTIONNÉ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade800,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Text(
                              _selectedCatalogue!.nom,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Colors.grey.shade800,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              _selectedCatalogue!.description,
                              style: TextStyle(
                                color: Colors.grey.shade700,
                              ),
                            ),
                            SizedBox(height: 10),
                            Row(
                              children: [
                                Icon(Icons.attach_money, size: 16, color: Colors.green),
                                SizedBox(width: 8),
                                Text(
                                  'Prix: ${currencyFormat.format(_selectedCatalogue!.prix)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green.shade800,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                    ],

                    // Adresse
                    Text(
                      'ADRESSE DE LA PARCELLE',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                        letterSpacing: 1.1,
                      ),
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: _adresseController,
                      decoration: InputDecoration(
                        hintText: 'Bloc et numéro de terrain',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.green),
                        ),
                        prefixIcon: Icon(Icons.location_on, color: Colors.green),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer l\'adresse';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),

                    // Durées
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'DURÉE CONSTRUCTION',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade700,
                                  letterSpacing: 1.1,
                                ),
                              ),
                              SizedBox(height: 8),
                              TextFormField(
                                controller: _dureeConstructionController,
                                decoration: InputDecoration(
                                  hintText: 'Mois',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(color: Colors.grey.shade300),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(color: Colors.green),
                                  ),
                                  prefixIcon: Icon(Icons.calendar_today, color: Colors.green),
                                  filled: true,
                                  fillColor: Colors.grey.shade50,
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Veuillez entrer la durée';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'DURÉE PAIEMENT',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade700,
                                  letterSpacing: 1.1,
                                ),
                              ),
                              SizedBox(height: 8),
                              TextFormField(
                                controller: _dureePaiementController,
                                decoration: InputDecoration(
                                  hintText: 'Mois',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(color: Colors.grey.shade300),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(color: Colors.green),
                                  ),
                                  prefixIcon: Icon(Icons.payment, color: Colors.green),
                                  filled: true,
                                  fillColor: Colors.grey.shade50,
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Veuillez entrer la durée';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 30),

                    // Résumé
                    if (_selectedCatalogue != null) ...[
                      Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.summarize, color: Colors.green),
                                SizedBox(width: 8),
                                Text(
                                  'RÉSUMÉ DE LA CONSTRUCTION',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green.shade900,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 15),
                            _summaryItem(
                              'Coût total',
                              currencyFormat.format(_selectedCatalogue!.prix),
                              Colors.green,
                            ),
                            SizedBox(height: 10),
                            _summaryItem(
                              'Paiement mensuel',
                              _dureePaiementController.text.isNotEmpty
                                  ? '${currencyFormat.format(_selectedCatalogue!.prix / int.parse(_dureePaiementController.text))}/mois'
                                  : '-',
                              Colors.blue,
                            ),
                            SizedBox(height: 10),
                            _summaryItem(
                              'Date de début',
                              _dateFormat.format(DateTime.now()),
                              Colors.orange,
                            ),
                            SizedBox(height: 10),
                            _summaryItem(
                              'Durée de construction',
                              _dureeConstructionController.text.isNotEmpty
                                  ? '${_dureeConstructionController.text} mois'
                                  : '-',
                              Colors.purple,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 30),
                    ],

                    // Bouton d'enregistrement
                    if (_isLoading)
                      Center(
                        child: Column(
                          children: [
                            CircularProgressIndicator(color: Colors.green),
                            SizedBox(height: 10),
                            Text(
                              'Enregistrement en cours...',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      )
                    else
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton.icon(
                          onPressed: _ajouterConstruction,
                          icon: Icon(Icons.save),
                          label: Text(
                            'ENREGISTRER LA CONSTRUCTION',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 5,
                            shadowColor: Colors.green.withOpacity(0.3),
                          ),
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

  Widget _summaryItem(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nomCompletController.dispose();
    _adresseController.dispose();
    _dureeConstructionController.dispose();
    _dureePaiementController.dispose();
    super.dispose();
  }
}