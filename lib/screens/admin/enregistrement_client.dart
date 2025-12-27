import 'package:flutter/material.dart';
import '/models/bloc.dart';
import '/models/lotissement.dart';
import '/models/client.dart';
import '/services/auth_service.dart';
import '/services/database_service.dart';
import '/services/notification_service.dart';

class EnregistrementClient extends StatefulWidget {
  @override
  _EnregistrementClientState createState() => _EnregistrementClientState();
}

class _EnregistrementClientState extends State<EnregistrementClient> {
  final _formKey = GlobalKey<FormState>();

  // Liste des clients existants
  List<Map<String, dynamic>> _clientsExistants = [];
  String? _selectedClientUsername;
  Map<String, dynamic>? _selectedClientInfo;

  List<Lotissement> _lotissements = [];
  List<Bloc> _blocsDisponibles = [];

  String? _selectedLotissementId;
  String? _selectedBlocId;
  Bloc? _selectedBloc;

  TextEditingController _nombreTerrainsController = TextEditingController(
    text: '1',
  );
  List<int> _terrainsSelectionnes = [];

  bool _isLoading = false;
  bool _chargementClients = true;

  @override
  void initState() {
    super.initState();
    _chargerClients();
    _chargerLotissements();
  }

  Future<void> _chargerClients() async {
    setState(() => _chargementClients = true);

    try {
      // Récupérer tous les clients depuis AuthService
      final clients = AuthService.getClientAccounts();
      
      setState(() {
        _clientsExistants = clients;
        _chargementClients = false;
      });
    } catch (e) {
      NotificationService.showError(context, 'Erreur chargement clients: $e');
      setState(() => _chargementClients = false);
    }
  }

  Future<void> _chargerLotissements() async {
    final lotissements = await DatabaseService.getLotissements();
    setState(() {
      _lotissements = lotissements;
    });
  }

  Future<void> _chargerBlocsDisponibles() async {
    if (_selectedLotissementId == null) return;

    final blocs = await DatabaseService.getBlocsByLotissement(
      _selectedLotissementId!,
    );
    final blocsDisponibles = blocs.where((bloc) => !bloc.isSature).toList();

    setState(() {
      _blocsDisponibles = blocsDisponibles;
      _selectedBlocId = null;
      _selectedBloc = null;
      _terrainsSelectionnes = [];
    });
  }

  void _selectionnerTerrains() {
    if (_selectedBloc == null) return;

    final nombreTerrains = int.tryParse(_nombreTerrainsController.text) ?? 1;

    if (nombreTerrains > _selectedBloc!.terrainsRestants) {
      NotificationService.showError(
        context,
        'Nombre de terrains insuffisant dans ce bloc',
      );
      return;
    }

    // Sélectionner automatiquement les premiers terrains disponibles
    setState(() {
      _terrainsSelectionnes = [];
      for (int i = 1;
          i <= 12 && _terrainsSelectionnes.length < nombreTerrains;
          i++) {
        if (!_selectedBloc!.terrainsOccupes.contains(i)) {
          _terrainsSelectionnes.add(i);
        }
      }
    });
  }

  Future<void> _enregistrerClient() async {
    if (_formKey.currentState!.validate() && 
        _selectedClientUsername != null && 
        _selectedBloc != null) {
      setState(() => _isLoading = true);

      try {
        final clientInfo = _selectedClientInfo!;
        final numeroOrdre = int.parse(clientInfo['clientId']);
        final nombreTerrains = int.parse(_nombreTerrainsController.text);

        // Créer l'objet Client pour DatabaseService
        Client nouveauClient = Client(
          numeroOrdre: numeroOrdre,
          nom: clientInfo['nom'],
          postnom: '',
          prenom: clientInfo['prenom'],
          telephone: clientInfo['telephone'],
          email: clientInfo['email'],
          nombreTerrains: nombreTerrains,
          blocId: _selectedBlocId!,
          numerosTerrains: _terrainsSelectionnes,
          fraisTotal: nombreTerrains * 100.0,
          dateEnregistrement: DateTime.now(),
        );

        await DatabaseService.enregistrerClient(nouveauClient);

        NotificationService.showSuccess(
          context,
          'Client enregistré avec succès',
        );
        Navigator.pop(context);
      } catch (e) {
        NotificationService.showError(context, 'Erreur: $e');
      } finally {
        setState(() => _isLoading = false);
      }
    } else {
      if (_selectedClientUsername == null) {
        NotificationService.showError(context, 'Veuillez sélectionner un client');
      }
      if (_selectedBloc == null) {
        NotificationService.showError(context, 'Veuillez sélectionner un bloc');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Enregistrement Client')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sélection du Client',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 24),

              // Sélection du client existant
              if (_chargementClients)
                Center(child: CircularProgressIndicator())
              else if (_clientsExistants.isEmpty)
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning, color: Colors.amber),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Aucun client disponible. Créez d\'abord des comptes clients.',
                          style: TextStyle(color: Colors.amber.shade800),
                        ),
                      ),
                    ],
                  ),
                )
              else
                DropdownButtonFormField<String>(
                  value: _selectedClientUsername,
                  decoration: InputDecoration(
                    labelText: 'Sélectionner un client existant',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  items: _clientsExistants.map((client) {
                    return DropdownMenuItem<String>(
                      value: client['username'],
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${client['nom']} ${client['prenom']}',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'ID: ${client['clientId']} | Tél: ${client['telephone']}',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedClientUsername = value;
                      _selectedClientInfo = _clientsExistants
                          .firstWhere((c) => c['username'] == value);
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Veuillez sélectionner un client';
                    }
                    return null;
                  },
                ),

              // Informations du client sélectionné
              if (_selectedClientInfo != null) ...[
                SizedBox(height: 16),
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          child: Text(
                            '${_selectedClientInfo!['nom'][0]}${_selectedClientInfo!['prenom'][0]}',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${_selectedClientInfo!['nom']} ${_selectedClientInfo!['prenom']}',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 4),
                              Text('Tél: ${_selectedClientInfo!['telephone']}'),
                              Text('Email: ${_selectedClientInfo!['email']}'),
                            ],
                          ),
                        ),
                        Icon(Icons.check_circle, color: Colors.green),
                      ],
                    ),
                  ),
                ),
              ],

              SizedBox(height: 32),
              Text(
                'Sélection du Terrain',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 24),

              // Sélection du lotissement
              DropdownButtonFormField<String>(
                value: _selectedLotissementId,
                decoration: InputDecoration(
                  labelText: 'Lotissement',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.business),
                ),
                items: _lotissements.map((lotissement) {
                  return DropdownMenuItem<String>(
                    value: lotissement.id,
                    child: Text(lotissement.nom),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedLotissementId = value;
                  });
                  _chargerBlocsDisponibles();
                },
                validator: (value) {
                  if (value == null) {
                    return 'Veuillez sélectionner un lotissement';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Sélection du bloc
              DropdownButtonFormField<String>(
                value: _selectedBlocId,
                decoration: InputDecoration(
                  labelText: 'Bloc',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.grid_view),
                ),
                items: _blocsDisponibles.map((bloc) {
                  return DropdownMenuItem<String>(
                    value: bloc.id,
                    child: Text(
                      'Bloc ${bloc.numeroBloc} - ${bloc.terrainsRestants} terrains disponibles',
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedBlocId = value;
                    _selectedBloc = _blocsDisponibles.firstWhere(
                      (b) => b.id == value,
                      orElse: () =>
                          Bloc(id: '', lotissementId: '', numeroBloc: ''),
                    );
                    _terrainsSelectionnes = [];
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Veuillez sélectionner un bloc';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Nombre de terrains
              TextFormField(
                controller: _nombreTerrainsController,
                decoration: InputDecoration(
                  labelText: 'Nombre de terrains',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.landscape),
                  helperText: '100\$ par terrain',
                  suffixIcon: _selectedBloc != null
                      ? IconButton(
                          icon: Icon(Icons.check_circle),
                          onPressed: _selectionnerTerrains,
                          color: Colors.green,
                        )
                      : null,
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer le nombre';
                  }
                  final nb = int.tryParse(value);
                  if (nb == null || nb <= 0) {
                    return 'Nombre invalide';
                  }
                  if (_selectedBloc != null &&
                      nb > _selectedBloc!.terrainsRestants) {
                    return 'Nombre supérieur aux terrains disponibles';
                  }
                  return null;
                },
              ),

              // Terrains sélectionnés
              if (_terrainsSelectionnes.isNotEmpty) ...[
                SizedBox(height: 16),
                Text(
                  'Terrains sélectionnés:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: _terrainsSelectionnes
                      .map(
                        (numero) => Chip(
                          label: Text('Terrain $numero'),
                          backgroundColor: Colors.blue.shade100,
                        ),
                      )
                      .toList(),
                ),
              ],

              // Frais total
              if (_terrainsSelectionnes.isNotEmpty) ...[
                SizedBox(height: 16),
                Card(
                  color: Colors.green.shade50,
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Frais Total:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '\$${(_terrainsSelectionnes.length * 100).toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              SizedBox(height: 32),

              // Bouton d'enregistrement
              if (_isLoading)
                Center(child: CircularProgressIndicator())
              else
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _enregistrerClient,
                    icon: Icon(Icons.save),
                    label: Text('Enregistrer le Client'),
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
    _nombreTerrainsController.dispose();
    super.dispose();
  }
}