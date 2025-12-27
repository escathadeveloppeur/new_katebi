import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:gestion_lotissement/models/paiement.dart';
import 'package:gestion_lotissement/models/client.dart';
import 'package:gestion_lotissement/models/construction.dart';
import 'package:gestion_lotissement/services/database_service.dart';
import 'package:gestion_lotissement/services/notification_service.dart';

class EnregistrementPaiement extends StatefulWidget {
  @override
  _EnregistrementPaiementState createState() => _EnregistrementPaiementState();
}

class _EnregistrementPaiementState extends State<EnregistrementPaiement> {
  final _formKey = GlobalKey<FormState>();
  final _uuid = Uuid();
  final DateFormat _monthFormat = DateFormat('MMMM yyyy');

  TextEditingController _montantController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _moisController = TextEditingController();

  List<Client> _clients = [];
  List<Construction> _constructions = [];
  
  String? _selectedClientId;
  String? _selectedConstructionId;
  String _typePaiement = 'terrain';
  String _modePaiement = 'espece';
  DateTime _datePaiement = DateTime.now();
  
  Client? _selectedClient;
  Construction? _selectedConstruction;
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadClients();
    _moisController.text = _monthFormat.format(DateTime.now());
  }

  Future<void> _loadClients() async {
    final clients = await DatabaseService.getClients();
    setState(() {
      _clients = clients;
    });
  }

  Future<void> _loadConstructions(String clientId) async {
    final constructions = DatabaseService.constructionBox.values
        .where((c) => c.clientId == clientId && c.statut != 'complet')
        .toList();
    setState(() {
      _constructions = constructions;
    });
  }

  Future<void> _enregistrerPaiement() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final paiementId = await DatabaseService.genererIdPaiement();
        
        Paiement nouveauPaiement = Paiement(
          id: paiementId,
          clientId: _selectedClientId!,
          constructionId: _typePaiement == 'construction' ? _selectedConstructionId : null,
          type: _typePaiement,
          montant: double.parse(_montantController.text),
          datePaiement: _datePaiement,
          mois: _moisController.text,
          modePaiement: _modePaiement,
          description: _descriptionController.text,
        );

        await DatabaseService.enregistrerPaiement(nouveauPaiement);
        
        NotificationService.showSuccess(context, 'Paiement enregistré avec succès');
        Navigator.pop(context);
      } catch (e) {
        NotificationService.showError(context, 'Erreur: $e');
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _datePaiement,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _datePaiement = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Enregistrement Paiement'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nouveau Paiement',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 24),

              // Type de paiement
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Type de paiement',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile<String>(
                              title: Text('Terrain'),
                              value: 'terrain',
                              groupValue: _typePaiement,
                              onChanged: (value) {
                                setState(() {
                                  _typePaiement = value!;
                                  _selectedConstructionId = null;
                                });
                              },
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<String>(
                              title: Text('Construction'),
                              value: 'construction',
                              groupValue: _typePaiement,
                              onChanged: (value) {
                                setState(() {
                                  _typePaiement = value!;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16),

              // Sélection du client
              DropdownButtonFormField<String>(
                value: _selectedClientId,
                decoration: InputDecoration(
                  labelText: 'Client',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                items: _clients.map((client) {
                  return DropdownMenuItem(
                    value: client.numeroOrdre.toString(),
                    child: Text('${client.nom} ${client.prenom}'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedClientId = value;
                    _selectedClient = _clients.firstWhere(
                      (c) => c.numeroOrdre.toString() == value,
                    );
                  });
                  if (_typePaiement == 'construction') {
                    _loadConstructions(value!);
                  }
                },
                validator: (value) {
                  if (value == null) {
                    return 'Veuillez sélectionner un client';
                  }
                  return null;
                },
              ),

              // Informations du client sélectionné
              if (_selectedClient != null) ...[
                SizedBox(height: 16),
                Card(
                  color: Colors.blue.shade50,
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Informations du client',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text('Nom: ${_selectedClient!.nom} ${_selectedClient!.prenom}'),
                        Text('Tél: ${_selectedClient!.telephone}'),
                        Text(
                          'Solde restant: \$${(_selectedClient!.fraisTotal - _selectedClient!.montantPaye).toStringAsFixed(0)}',
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              // Sélection de la construction (si type construction)
              if (_typePaiement == 'construction' && _selectedClientId != null) ...[
                SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedConstructionId,
                  decoration: InputDecoration(
                    labelText: 'Construction',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.construction),
                  ),
                  items: _constructions.map((construction) {
                    return DropdownMenuItem(
                      value: construction.id,
                      child: Text(construction.nomComplet),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedConstructionId = value;
                      _selectedConstruction = _constructions.firstWhere(
                        (c) => c.id == value,
                      );
                    });
                  },
                  validator: (value) {
                    if (_typePaiement == 'construction' && value == null) {
                      return 'Veuillez sélectionner une construction';
                    }
                    return null;
                  },
                ),

                // Informations de la construction sélectionnée
                if (_selectedConstruction != null) ...[
                  SizedBox(height: 16),
                  Card(
                    color: Colors.orange.shade50,
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Informations de la construction',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          Text('Type: ${_selectedConstruction!.typeConstruction}'),
                          Text(
                            'Payé: \$${_selectedConstruction!.montantPaye.toStringAsFixed(0)} / \$${_selectedConstruction!.montantTotal.toStringAsFixed(0)}',
                          ),
                          Text(
                            'Reste: \$${(_selectedConstruction!.montantTotal - _selectedConstruction!.montantPaye).toStringAsFixed(0)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],

              SizedBox(height: 16),

              // Montant
              TextFormField(
                controller: _montantController,
                decoration: InputDecoration(
                  labelText: 'Montant (\$)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer le montant';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Montant invalide';
                  }
                  return null;
                },
              ),

              SizedBox(height: 16),

              // Date de paiement
              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Date de paiement',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(DateFormat('dd/MM/yyyy').format(_datePaiement)),
                      Icon(Icons.arrow_drop_down, color: Colors.grey),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16),

              // Mois
              TextFormField(
                controller: _moisController,
                decoration: InputDecoration(
                  labelText: 'Mois',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.date_range),
                  helperText: 'Ex: Janvier 2024',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer le mois';
                  }
                  return null;
                },
              ),

              SizedBox(height: 16),

              // Mode de paiement
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mode de paiement',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        children: [
                          ChoiceChip(
                            label: Text('Espèce'),
                            selected: _modePaiement == 'espece',
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _modePaiement = 'espece';
                                });
                              }
                            },
                          ),
                          ChoiceChip(
                            label: Text('Chèque'),
                            selected: _modePaiement == 'cheque',
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _modePaiement = 'cheque';
                                });
                              }
                            },
                          ),
                          ChoiceChip(
                            label: Text('Virement'),
                            selected: _modePaiement == 'virement',
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _modePaiement = 'virement';
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                  helperText: 'Notes additionnelles',
                ),
                maxLines: 3,
              ),

              SizedBox(height: 32),

              // Bouton d'enregistrement
              if (_isLoading)
                Center(child: CircularProgressIndicator())
              else
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _enregistrerPaiement,
                    icon: Icon(Icons.payment),
                    label: Text('Enregistrer le Paiement'),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _montantController.dispose();
    _descriptionController.dispose();
    _moisController.dispose();
    super.dispose();
  }
}