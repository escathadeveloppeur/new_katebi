import 'package:flutter/material.dart';
import 'package:gestion_lotissement/models/bloc.dart';
import 'package:gestion_lotissement/models/terrain.dart';
import 'package:gestion_lotissement/services/database_service.dart';

class GestionBlocs extends StatefulWidget {
  final String lotissementId;

  const GestionBlocs({Key? key, required this.lotissementId}) : super(key: key);

  @override
  _GestionBlocsState createState() => _GestionBlocsState();
}

class _GestionBlocsState extends State<GestionBlocs> {
  List<Bloc> _blocs = [];
  Map<String, List<Terrain>> _terrainsParBloc = {};

  @override
  void initState() {
    super.initState();
    _loadBlocs();
  }

  Future<void> _loadBlocs() async {
    final blocs = await DatabaseService.getBlocsByLotissement(widget.lotissementId);
    setState(() {
      _blocs = blocs;
    });

    // Charger les terrains pour chaque bloc
    for (var bloc in blocs) {
      final terrains = DatabaseService.terrainBox.values
          .where((t) => t.blocId == bloc.id)
          .toList();
      _terrainsParBloc[bloc.id] = terrains;
    }
  }

  Widget _buildTerrainGrid(String blocId) {
    final terrains = _terrainsParBloc[blocId] ?? [];
    
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: 12,
      itemBuilder: (context, index) {
        final terrainNumero = index + 1;
        final terrain = terrains.firstWhere(
          (t) => t.numero == terrainNumero,
          orElse: () => Terrain(
            id: '',
            blocId: blocId,
            lotissementId: widget.lotissementId,
            numero: terrainNumero,
          ),
        );

        return Container(
          decoration: BoxDecoration(
            color: terrain.estOccupe ? Colors.red.shade100 : Colors.green.shade100,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$terrainNumero',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: terrain.estOccupe ? Colors.red : Colors.green,
                  ),
                ),
                if (terrain.estOccupe)
                  Icon(Icons.person, size: 12, color: Colors.red),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestion des Blocs'),
      ),
      body: _blocs.isEmpty
          ? Center(child: Text('Aucun bloc disponible'))
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: _blocs.length,
              itemBuilder: (context, index) {
                final bloc = _blocs[index];
                return Card(
                  margin: EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Bloc ${bloc.numeroBloc}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Chip(
                              label: Text(
                                '${bloc.terrainsRestants} restants',
                                style: TextStyle(color: Colors.white),
                              ),
                              backgroundColor: bloc.terrainsRestants > 0
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Terrains (${bloc.totalTerrains} total, ${bloc.terrainsRestants} disponibles)',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        SizedBox(height: 12),
                        _buildTerrainGrid(bloc.id),
                        SizedBox(height: 12),
                        if (bloc.terrainsOccupes.isNotEmpty) ...[
                          Divider(),
                          Text(
                            'Terrains occupés:',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: bloc.terrainsOccupes
                                .map((numero) => Chip(
                                      label: Text('Terrain $numero'),
                                      backgroundColor: Colors.red.shade100,
                                    ))
                                .toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}