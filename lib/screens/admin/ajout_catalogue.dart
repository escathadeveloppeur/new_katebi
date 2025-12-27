import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:gestion_lotissement/models/catalogue.dart';
import 'package:gestion_lotissement/services/database_service.dart';
import 'package:gestion_lotissement/services/notification_service.dart';

class AjoutCatalogue extends StatefulWidget {
  @override
  _AjoutCatalogueState createState() => _AjoutCatalogueState();
}

class _AjoutCatalogueState extends State<AjoutCatalogue> {
  final _formKey = GlobalKey<FormState>();
  final _uuid = Uuid();

  TextEditingController _nomController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _prixController = TextEditingController();

  String? _selectedType;
  List<String> _photos = [];
  
  bool _isLoading = false;

  Future<void> _ajouterCatalogue() async {
    if (_formKey.currentState!.validate() && _selectedType != null) {
      setState(() => _isLoading = true);

      try {
        Catalogue nouveauCatalogue = Catalogue(
          id: _uuid.v4(),
          nom: _nomController.text,
          typeConstruction: _selectedType!,
          description: _descriptionController.text,
          prix: double.parse(_prixController.text),
          photos: _photos,
          dateCreation: DateTime.now(),
        );

        await DatabaseService.ajouterCatalogue(nouveauCatalogue);
        
        NotificationService.showSuccess(context, 'Modèle ajouté au catalogue');
        Navigator.pop(context);
      } catch (e) {
        NotificationService.showError(context, 'Erreur: $e');
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  void _ajouterPhoto() {
    // Pour l'instant, on simule l'ajout d'une photo
    setState(() {
      _photos.add('photo_${_photos.length + 1}.jpg');
    });
    NotificationService.showSuccess(context, 'Photo ajoutée (simulation)');
  }

  void _supprimerPhoto(int index) {
    setState(() {
      _photos.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nouveau Modèle'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ajouter un modèle au catalogue',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 24),

              // Type de construction
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: InputDecoration(
                  labelText: 'Type de construction',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                items: [
                  DropdownMenuItem(
                    value: 'mise_en_valeur',
                    child: Text('Construction de mise en valeur'),
                  ),
                  DropdownMenuItem(
                    value: 'moderne',
                    child: Text('Construction moderne'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedType = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Veuillez sélectionner un type';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Nom
              TextFormField(
                controller: _nomController,
                decoration: InputDecoration(
                  labelText: 'Nom du modèle',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer le nom';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer la description';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Prix
              TextFormField(
                controller: _prixController,
                decoration: InputDecoration(
                  labelText: 'Prix (\$)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                  helperText: 'Prix total de la construction',
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

              // Photos
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Photos du modèle',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.add_a_photo, color: Colors.blue),
                            onPressed: _ajouterPhoto,
                          ),
                        ],
                      ),
                      SizedBox(height: 12),

                      if (_photos.isEmpty)
                        Container(
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.photo_library,
                                    size: 40, color: Colors.grey),
                                SizedBox(height: 8),
                                Text(
                                  'Aucune photo',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        GridView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                          itemCount: _photos.length,
                          itemBuilder: (context, index) {
                            return Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: Icon(Icons.photo,
                                        size: 30, color: Colors.grey.shade400),
                                  ),
                                ),
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: GestureDetector(
                                    onTap: () => _supprimerPhoto(index),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      padding: EdgeInsets.all(4),
                                      child: Icon(Icons.close,
                                          size: 12, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                    ],
                  ),
                ),
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
                    onPressed: _ajouterCatalogue,
                    icon: Icon(Icons.save),
                    label: Text('Ajouter au Catalogue'),
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
    _descriptionController.dispose();
    _prixController.dispose();
    super.dispose();
  }
}