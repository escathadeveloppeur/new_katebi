import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:gestion_lotissement/services/secure_client_service.dart';

class NotificationsPage extends StatefulWidget {
  final Map<String, dynamic>? clientData;
  
  const NotificationsPage({Key? key, this.clientData}) : super(key: key);

  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<Map<String, dynamic>> _mesNotifications = [];
  bool _isLoading = true;
  String _filterType = 'tous';

  @override
  void initState() {
    super.initState();
    _chargerMesNotifications();
  }

  Future<void> _chargerMesNotifications() async {
    setState(() => _isLoading = true);

    try {
      List<Map<String, dynamic>> notifications = [];

      // OPTION 1: Si les données sont passées depuis ClientPage
      if (widget.clientData != null) {
        notifications = _genererNotificationsPersonnalisees(widget.clientData!);
      } 
      // OPTION 2: Sinon, charger directement depuis SecureClientService
      else {
        final clientData = await SecureClientService.getCurrentClientData();
        if (clientData != null) {
          notifications = _genererNotificationsPersonnalisees(clientData);
        }
      }

      // Trier par date (plus récent d'abord)
      notifications.sort((a, b) => b['date'].compareTo(a['date']));

      setState(() {
        _mesNotifications = notifications;
        _isLoading = false;
      });

      print('✅ Notifications chargées: ${_mesNotifications.length} notification(s)');
    } catch (e) {
      print('❌ Erreur chargement notifications: $e');
      _mesNotifications = [];
      setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> _genererNotificationsPersonnalisees(Map<String, dynamic> clientData) {
    final authInfo = clientData['authInfo'] ?? {};
    final terrains = clientData['terrains'] as List? ?? [];
    final paiements = clientData['paiements'] as List? ?? [];
    final constructions = clientData['constructions'] as List? ?? [];
    
    final maintenant = DateTime.now();
    final clientId = authInfo['clientId'] ?? '';
    final clientName = '${authInfo['prenom']} ${authInfo['nom']}';

    List<Map<String, dynamic>> notifications = [];

    // 1. Notifications basées sur les paiements
    final paiementsRecents = (paiements as List).where((p) {
      if (p is Map && p['date'] != null) {
        try {
          final datePaiement = DateTime.parse(p['date'].toString());
          return maintenant.difference(datePaiement).inDays <= 30;
        } catch (e) {
          return false;
        }
      }
      return false;
    }).toList();

    for (var paiement in paiementsRecents.take(3)) {
      final p = paiement as Map<String, dynamic>;
      notifications.add({
        'id': 'paiement_${p['id'] ?? DateTime.now().millisecondsSinceEpoch}',
        'type': 'paiement',
        'titre': 'Paiement enregistré',
        'message': '${p['description'] ?? 'Paiement'} de ${p['montant']} a été validé',
        'date': DateTime.parse(p['date']?.toString() ?? DateTime.now().toString()),
        'lu': false,
        'important': true,
        'icon': Icons.payment,
        'color': Colors.green,
        'data': p,
      });
    }

    // 2. Notifications basées sur les constructions
    for (var construction in constructions) {
      final c = construction as Map<String, dynamic>;
      final statut = c['statut']?.toString() ?? '';
      final progression = c['progression']?.toString() ?? '0%';
      
      if (statut == 'en_cours' && progression != '100%') {
        notifications.add({
          'id': 'construction_${c['id'] ?? 'construction'}',
          'type': 'construction',
          'titre': 'Progression construction',
          'message': 'Votre projet de construction est à $progression d\'avancement',
          'date': DateTime.now().subtract(Duration(days: 2)),
          'lu': false,
          'important': true,
          'icon': Icons.construction,
          'color': Colors.orange,
          'data': c,
        });
      }
    }

    // 3. Notifications basées sur les terrains
    final terrainsAchetes = terrains.where((t) {
      final terrain = t as Map<String, dynamic>;
      final statut = terrain['statut']?.toString() ?? '';
      return statut == 'Vendu' || statut == 'Disponible';
    }).toList();
    
    if (terrainsAchetes.isNotEmpty) {
      notifications.add({
        'id': 'terrain_info',
        'type': 'terrain',
        'titre': 'Vos terrains',
        'message': 'Vous possédez ${terrainsAchetes.length} terrain(s) dans votre portefeuille',
        'date': DateTime.now().subtract(Duration(days: 4)),
        'lu': false,
        'important': false,
        'icon': Icons.landscape,
        'color': Colors.green,
        'data': terrains,
      });
    }

    // 4. Notifications système
    notifications.addAll([
      {
        'id': 'systeme_001',
        'type': 'systeme',
        'titre': 'Bienvenue $clientName',
        'message': 'Votre espace client est maintenant actif. Explorez toutes les fonctionnalités.',
        'date': DateTime.now().subtract(Duration(days: 1)),
        'lu': false,
        'important': true,
        'icon': Icons.waving_hand,
        'color': Colors.blue,
      },
      {
        'id': 'rappel_001',
        'type': 'rappel',
        'titre': 'Prochain échéance',
        'message': 'Votre prochaine échéance est prévue pour le 15/12/2024',
        'date': DateTime.now().subtract(Duration(days: 3)),
        'lu': true,
        'important': true,
        'icon': Icons.notification_important,
        'color': Colors.red,
      },
      {
        'id': 'info_001',
        'type': 'information',
        'titre': 'Support disponible',
        'message': 'Notre équipe support est disponible du lundi au vendredi de 8h à 17h',
        'date': DateTime.now().subtract(Duration(days: 5)),
        'lu': true,
        'important': false,
        'icon': Icons.info,
        'color': Colors.purple,
      },
      {
        'id': 'securite_001',
        'type': 'securite',
        'titre': 'Sécurité de vos données',
        'message': 'Vos informations personnelles sont protégées et chiffrées',
        'date': DateTime.now().subtract(Duration(days: 7)),
        'lu': true,
        'important': false,
        'icon': Icons.security,
        'color': Colors.teal,
      },
    ]);

    return notifications;
  }

  List<Map<String, dynamic>> _getNotificationsFiltrees() {
    if (_filterType == 'tous') return _mesNotifications;
    
    return _mesNotifications.where((n) => n['type'] == _filterType).toList()
      ..sort((a, b) => b['date'].compareTo(a['date']));
  }

  void _marquerCommeLu(int index) {
    setState(() {
      _mesNotifications[index]['lu'] = true;
    });
  }

  void _supprimerNotification(int index) {
    final notification = _mesNotifications[index];
    setState(() {
      _mesNotifications.removeAt(index);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Notification supprimée'),
        action: SnackBarAction(
          label: 'Annuler',
          onPressed: () {
            setState(() {
              _mesNotifications.insert(index, notification);
            });
          },
        ),
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _marquerTousCommeLus() {
    setState(() {
      for (var notification in _mesNotifications) {
        notification['lu'] = true;
      }
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Toutes les notifications marquées comme lues'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _supprimerToutesLues() {
    final anciennesNotifications = List<Map<String, dynamic>>.from(_mesNotifications);
    setState(() {
      _mesNotifications.removeWhere((notification) => notification['lu'] == true);
    });
    
    if (_mesNotifications.length < anciennesNotifications.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${anciennesNotifications.length - _mesNotifications.length} notification(s) lue(s) supprimée(s)'),
          action: SnackBarAction(
            label: 'Annuler',
            onPressed: () {
              setState(() {
                _mesNotifications = anciennesNotifications;
              });
            },
          ),
          duration: Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final notificationsFiltrees = _getNotificationsFiltrees();
    final notificationsNonLues = _mesNotifications.where((n) => !n['lu']).length;
    final notificationsImportantes = _mesNotifications.where((n) => n['important'] == true).length;

    return Scaffold(
      appBar: AppBar(
        title: Text('Mes Notifications'),
        actions: [
          if (notificationsNonLues > 0)
            IconButton(
              icon: Icon(Icons.done_all),
              tooltip: 'Tout marquer comme lu',
              onPressed: _marquerTousCommeLus,
            ),
          IconButton(
            icon: Icon(Icons.filter_list),
            tooltip: 'Filtrer',
            onPressed: _showFilterDialog,
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'rafraichir') {
                _chargerMesNotifications();
              } else if (value == 'supprimer_lues') {
                _supprimerToutesLues();
              } else if (value == 'parametres') {
                _showParametresNotifications();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'rafraichir',
                child: Row(
                  children: [
                    Icon(Icons.refresh, size: 20),
                    SizedBox(width: 8),
                    Text('Rafraîchir'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'supprimer_lues',
                child: Row(
                  children: [
                    Icon(Icons.delete_sweep, size: 20, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Supprimer les lues'),
                  ],
                ),
              ),
              PopupMenuDivider(),
              PopupMenuItem(
                value: 'parametres',
                child: Row(
                  children: [
                    Icon(Icons.settings, size: 20),
                    SizedBox(width: 8),
                    Text('Paramètres'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text('Chargement de vos notifications...'),
                ],
              ),
            )
          : Column(
              children: [
                // En-tête avec statistiques et filtres
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatChip(
                            'Total',
                            '${_mesNotifications.length}',
                            Colors.blue,
                          ),
                          _buildStatChip(
                            'Non lues',
                            '$notificationsNonLues',
                            notificationsNonLues > 0 ? Colors.red : Colors.grey,
                          ),
                          _buildStatChip(
                            'Importantes',
                            '$notificationsImportantes',
                            Colors.orange,
                          ),
                        ],
                      ),
                      
                      SizedBox(height: 12),
                      
                      // Filtre actif
                      if (_filterType != 'tous')
                        Card(
                          elevation: 0,
                          color: Colors.blue.shade100,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.filter_alt, size: 14, color: Colors.blue.shade800),
                                SizedBox(width: 6),
                                Text(
                                  'Filtre: ${_getTypeLabel(_filterType)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.blue.shade800,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () {
                                    setState(() => _filterType = 'tous');
                                  },
                                  child: Icon(Icons.close, size: 14, color: Colors.blue.shade800),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Liste des notifications
                Expanded(
                  child: _mesNotifications.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.notifications_none,
                                  size: 80, color: Colors.grey.shade300),
                              SizedBox(height: 20),
                              Text(
                                'Aucune notification',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              SizedBox(height: 12),
                              Text(
                                'Vous serez notifié des activités concernant\nvotre compte et vos projets',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                ),
                              ),
                              SizedBox(height: 24),
                              ElevatedButton.icon(
                                onPressed: _chargerMesNotifications,
                                icon: Icon(Icons.refresh),
                                label: Text('Actualiser'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue.shade800,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: EdgeInsets.all(16),
                          itemCount: notificationsFiltrees.length,
                          separatorBuilder: (context, index) =>
                              SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final notification = notificationsFiltrees[index];
                            final isLu = notification['lu'] == true;
                            final isImportante = notification['important'] == true;

                            return Dismissible(
                              key: Key(notification['id'].toString()),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                alignment: Alignment.centerRight,
                                padding: EdgeInsets.only(right: 20),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Icon(Icons.delete, color: Colors.white),
                                    SizedBox(width: 8),
                                    Text(
                                      'Supprimer',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                              confirmDismiss: (direction) async {
                                return await showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text('Supprimer la notification'),
                                    content: Text(
                                        'Cette action est irréversible. Voulez-vous continuer ?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, false),
                                        child: Text('Annuler'),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, true),
                                        child: Text(
                                          'Supprimer',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              onDismissed: (_) {
                                // Trouver l'index réel dans la liste principale
                                final realIndex = _mesNotifications.indexWhere(
                                    (n) => n['id'] == notification['id']);
                                if (realIndex != -1) {
                                  _supprimerNotification(realIndex);
                                }
                              },
                              child: Card(
                                elevation: isLu ? 1 : 2,
                                color: isLu
                                    ? Colors.white
                                    : (notification['color'] as Color).withOpacity(0.05),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: isImportante && !isLu
                                      ? BorderSide(
                                          color: (notification['color'] as Color)
                                              .withOpacity(0.3),
                                          width: 2)
                                      : BorderSide.none,
                                ),
                                child: ListTile(
                                  leading: Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: (notification['color'] as Color)
                                          .withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Icon(
                                        notification['icon'] as IconData,
                                        color: notification['color'] as Color,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    notification['titre'].toString(),
                                    style: TextStyle(
                                      fontWeight: isLu
                                          ? FontWeight.normal
                                          : FontWeight.bold,
                                      color: isImportante && !isLu
                                          ? notification['color'] as Color
                                          : null,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        notification['message'].toString(),
                                        style: TextStyle(fontSize: 13),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(Icons.access_time,
                                              size: 12, color: Colors.grey),
                                          SizedBox(width: 4),
                                          Text(
                                            _getTempsEcoule(
                                                notification['date'] as DateTime),
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          if (isImportante) ...[
                                            SizedBox(width: 8),
                                            Icon(Icons.priority_high,
                                                size: 12, color: Colors.red),
                                            Text(
                                              'Important',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.red,
                                              ),
                                            ),
                                          ],
                                          Spacer(),
                                          Text(
                                            _getTypeLabel(notification['type'].toString()),
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  trailing: !isLu
                                      ? IconButton(
                                          icon: Icon(Icons.mark_email_read,
                                              color: Colors.blue),
                                          onPressed: () {
                                            final realIndex = _mesNotifications
                                                .indexWhere((n) =>
                                                    n['id'] ==
                                                    notification['id']);
                                            if (realIndex != -1) {
                                              _marquerCommeLu(realIndex);
                                            }
                                          },
                                          tooltip: 'Marquer comme lu',
                                        )
                                      : Icon(Icons.check_circle,
                                          color: Colors.green, size: 20),
                                  onTap: () {
                                    final realIndex = _mesNotifications
                                        .indexWhere((n) =>
                                            n['id'] == notification['id']);
                                    if (realIndex != -1 && !isLu) {
                                      _marquerCommeLu(realIndex);
                                    }
                                    _showDetailsNotification(notification);
                                  },
                                  onLongPress: () {
                                    _showDetailsNotification(notification);
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: notificationsNonLues > 0
          ? FloatingActionButton.extended(
              onPressed: _marquerTousCommeLus,
              icon: Icon(Icons.done_all),
              label: Text('Tout lire'),
              backgroundColor: Colors.blue.shade800,
            )
          : null,
    );
  }

  Widget _buildStatChip(String label, String value, Color color) {
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Center(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  String _getTempsEcoule(DateTime date) {
    final maintenant = DateTime.now();
    final difference = maintenant.difference(date);

    if (difference.inSeconds < 60) {
      return 'À l\'instant';
    } else if (difference.inMinutes < 60) {
      return 'Il y a ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Il y a ${difference.inHours} h';
    } else if (difference.inDays < 30) {
      return 'Il y a ${difference.inDays} j';
    } else {
      return DateFormat('dd/MM/yyyy').format(date);
    }
  }

  String _getTypeLabel(String type) {
    switch (type) {
      case 'paiement':
        return 'Paiement';
      case 'construction':
        return 'Construction';
      case 'terrain':
        return 'Terrain';
      case 'systeme':
        return 'Système';
      case 'rappel':
        return 'Rappel';
      case 'information':
        return 'Information';
      case 'securite':
        return 'Sécurité';
      default:
        return type;
    }
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setStateSheet) {
          return Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 60,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                
                Text(
                  'Filtrer les notifications',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                SizedBox(height: 20),
                
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildFilterChip('Tous', _filterType == 'tous', () {
                      setState(() => _filterType = 'tous');
                      Navigator.pop(context);
                    }),
                    _buildFilterChip('Paiements', _filterType == 'paiement', () {
                      setState(() => _filterType = 'paiement');
                      Navigator.pop(context);
                    }),
                    _buildFilterChip('Constructions', _filterType == 'construction', () {
                      setState(() => _filterType = 'construction');
                      Navigator.pop(context);
                    }),
                    _buildFilterChip('Terrains', _filterType == 'terrain', () {
                      setState(() => _filterType = 'terrain');
                      Navigator.pop(context);
                    }),
                    _buildFilterChip('Rappels', _filterType == 'rappel', () {
                      setState(() => _filterType = 'rappel');
                      Navigator.pop(context);
                    }),
                    _buildFilterChip('Informations', _filterType == 'information', () {
                      setState(() => _filterType = 'information');
                      Navigator.pop(context);
                    }),
                  ],
                ),
                
                SizedBox(height: 30),
                
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() => _filterType = 'tous');
                          Navigator.pop(context);
                        },
                        child: Text('Effacer'),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade800,
                        ),
                        child: Text('Fermer'),
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(String label, bool selected, VoidCallback onTap) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      selectedColor: Colors.blue.shade100,
      checkmarkColor: Colors.blue.shade800,
      onSelected: (selected) => onTap(),
    );
  }

  void _showDetailsNotification(Map<String, dynamic> notification) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final typeLabel = _getTypeLabel(notification['type'].toString());

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // En-tête
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: (notification['color'] as Color).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      notification['icon'] as IconData,
                      color: notification['color'] as Color,
                      size: 24,
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification['titre'].toString(),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 12, color: Colors.grey),
                          SizedBox(width: 4),
                          Text(
                            _getTempsEcoule(notification['date'] as DateTime),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(width: 12),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              typeLabel,
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 24),

            // Contenu
            Text(
              'Message',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            SizedBox(height: 8),
            Text(
              notification['message'].toString(),
              style: TextStyle(fontSize: 16),
            ),

            SizedBox(height: 20),

            // Informations supplémentaires
            if (notification['data'] != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(),
                  SizedBox(height: 10),
                  Text(
                    'Détails supplémentaires',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  SizedBox(height: 8),
                  if (notification['type'] == 'paiement' && notification['data'] is Map)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if ((notification['data'] as Map)['description'] != null)
                          Text('Description: ${(notification['data'] as Map)['description']}'),
                        if ((notification['data'] as Map)['montant'] != null)
                          Text('Montant: ${(notification['data'] as Map)['montant']}'),
                        if ((notification['data'] as Map)['date'] != null)
                          Text('Date: ${dateFormat.format(DateTime.parse((notification['data'] as Map)['date'].toString()))}'),
                      ],
                    ),
                  if (notification['type'] == 'construction' && notification['data'] is Map)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if ((notification['data'] as Map)['type'] != null)
                          Text('Type: ${(notification['data'] as Map)['type']}'),
                        if ((notification['data'] as Map)['progression'] != null)
                          Text('Progression: ${(notification['data'] as Map)['progression']}'),
                      ],
                    ),
                ],
              ),

            SizedBox(height: 30),

            // Boutons d'action
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Fermer'),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _handleNotificationAction(notification);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: notification['color'] as Color,
                    ),
                    child: Text('Voir plus'),
                  ),
                ),
              ],
            ),

            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void _handleNotificationAction(Map<String, dynamic> notification) {
    switch (notification['type']) {
      case 'paiement':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Redirection vers les paiements...'),
            action: SnackBarAction(
              label: 'OK',
              onPressed: () {},
            ),
          ),
        );
        break;
      case 'construction':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Redirection vers les constructions...'),
            action: SnackBarAction(
              label: 'OK',
              onPressed: () {},
            ),
          ),
        );
        break;
      case 'terrain':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Redirection vers les terrains...'),
            action: SnackBarAction(
              label: 'OK',
              onPressed: () {},
            ),
          ),
        );
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Action non disponible pour ce type de notification'),
          ),
        );
    }
  }

  void _showParametresNotifications() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Paramètres des notifications'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                title: Text('Notifications push'),
                subtitle: Text('Recevoir des notifications en temps réel'),
                value: true,
                onChanged: (value) {},
              ),
              SwitchListTile(
                title: Text('Notifications par email'),
                subtitle: Text('Recevoir des copies par email'),
                value: false,
                onChanged: (value) {},
              ),
              SwitchListTile(
                title: Text('Notifications importantes'),
                subtitle: Text('Toujours recevoir les notifications importantes'),
                value: true,
                onChanged: (value) {},
              ),
              Divider(),
              ListTile(
                title: Text('Fréquence des notifications'),
                subtitle: Text('Personnaliser la fréquence'),
                trailing: Icon(Icons.arrow_forward_ios, size: 14),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Fonctionnalité à venir')),
                  );
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Fermer'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Paramètres enregistrés'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: Text('Enregistrer'),
          ),
        ],
      ),
    );
  }
}