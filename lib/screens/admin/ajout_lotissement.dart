import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:gestion_lotissement/models/lotissement.dart';
import 'package:gestion_lotissement/models/bloc.dart'; // AJOUTEZ CET IMPORT
import 'package:gestion_lotissement/services/database_service.dart';
import 'package:gestion_lotissement/services/notification_service.dart';

class AjoutLotissement extends StatefulWidget {
  @override
  _AjoutLotissementState createState() => _AjoutLotissementState();
}

class _AjoutLotissementState extends State<AjoutLotissement> {
  final _formKey = GlobalKey<FormState>();
  final _uuid = Uuid();

  TextEditingController _nomController = TextEditingController();
  TextEditingController _prixController = TextEditingController();
  TextEditingController _nombreBlocsController = TextEditingController();

  bool _isLoading = false;

  Future<void> _ajouterLotissement() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        Lotissement nouveauLotissement = Lotissement(
          id: _uuid.v4(),
          nom: _nomController.text,
          prix: double.parse(_prixController.text),
          nombreBlocs: int.parse(_nombreBlocsController.text),
          dateCreation: DateTime.now(),
          blocsRestants: int.parse(_nombreBlocsController.text),
        );

        await DatabaseService.ajouterLotissement(nouveauLotissement);

        // Créer les blocs pour ce lotissement
        for (int i = 1; i <= nouveauLotissement.nombreBlocs; i++) {
          final blocId = '${nouveauLotissement.id}_bloc_$i';
          await DatabaseService.ajouterBloc(
            Bloc( // CLASSE Bloc IMPORTÉE MAINTENANT
              id: blocId,
              lotissementId: nouveauLotissement.id,
              numeroBloc: 'B${i.toString().padLeft(3, '0')}',
            ),
          );
        }

        NotificationService.showSuccess(context, 'Lotissement ajouté avec succès');
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Nouveau Lotissement'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Informations du Lotissement',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 24),
              TextFormField(
                controller: _nomController,
                decoration: InputDecoration(
                  labelText: 'Nom du lotissement',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.business),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer le nom';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _prixController,
                decoration: InputDecoration(
                  labelText: 'Prix par terrain (\$)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer le prix';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Prix invalide';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _nombreBlocsController,
                decoration: InputDecoration(
                  labelText: 'Nombre de blocs',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.grid_view),
                  helperText: 'Chaque bloc contient 12 terrains',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer le nombre de blocs';
                  }
                  final nb = int.tryParse(value);
                  if (nb == null || nb <= 0) {
                    return 'Nombre invalide';
                  }
                  return null;
                },
              ),
              SizedBox(height: 32),
              if (_isLoading)
                Center(child: CircularProgressIndicator())
              else
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _ajouterLotissement,
                    icon: Icon(Icons.save),
                    label: Text('Enregistrer le Lotissement'),
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
    _nomController.dispose();
    _prixController.dispose();
    _nombreBlocsController.dispose();
    super.dispose();
  }
}
