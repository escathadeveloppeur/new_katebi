import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '/services/auth_service.dart';
import '/screens/admin/enregistrement_client.dart';
import '/services/notification_service.dart';

class GestionClients extends StatefulWidget {
  @override
  _GestionClientsState createState() => _GestionClientsState();
}

class _GestionClientsState extends State<GestionClients> {
  List<Map<String, dynamic>> _clients = [];
  List<Map<String, dynamic>> _filteredClients = [];
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadClients();
    _searchController.addListener(_filterClients);
  }

  Future<void> _loadClients() async {
    // Récupérer les comptes clients depuis AuthService
    final clients = AuthService.getClientAccounts();

    setState(() {
      _clients = clients;
      _filteredClients = clients;
    });
  }

  void _filterClients() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredClients = _clients.where((client) {
        return client['nom'].toString().toLowerCase().contains(query) ||
            client['prenom'].toString().toLowerCase().contains(query) ||
            client['telephone'].toString().contains(query) ||
            client['email'].toString().toLowerCase().contains(query) ||
            client['clientId'].toString().contains(query);
      }).toList();
    });
  }

  Future<void> _supprimerClient(String username) async {
    final confirmed = await NotificationService.showConfirmationDialog(
      context,
      'Supprimer Client',
      'Êtes-vous sûr de vouloir supprimer ce compte client ?',
    );

    if (confirmed) {
      try {
        // Supprimer le compte de la base Auth
        await AuthService.authBox.delete(username);

        // Recharger la liste
        _loadClients();

        NotificationService.showSuccess(
            context, 'Compte client supprimé avec succès');
      } catch (e) {
        NotificationService.showError(
            context, 'Erreur lors de la suppression: $e');
      }
    }
  }

  Future<void> _changerStatutClient(
      String username, String currentStatus) async {
    final newStatus = currentStatus == 'active' ? 'inactive' : 'active';
    final action = newStatus == 'active' ? 'activer' : 'désactiver';

    final confirmed = await NotificationService.showConfirmationDialog(
      context,
      '$action le compte',
      'Voulez-vous $action ce compte client ?',
    );

    if (confirmed) {
      try {
        final success =
            await AuthService.toggleClientStatus(username, newStatus);

        if (success) {
          _loadClients();
          NotificationService.showSuccess(context,
              'Compte ${newStatus == 'active' ? 'activé' : 'désactivé'} avec succès');
        } else {
          NotificationService.showError(
              context, 'Erreur lors du changement de statut');
        }
      } catch (e) {
        NotificationService.showError(context, 'Erreur: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 0);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EnregistrementClient(),
            ),
          );
          _loadClients();
        },
        icon: Icon(Icons.person_add),
        label: Text('NOUVEAU CLIENT'),
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
                          Icon(Icons.people, color: Colors.white, size: 28),
                          SizedBox(width: 10),
                          Text(
                            'GESTION DES CLIENTS',
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
                        'Administration des comptes clients',
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
                onPressed: _loadClients,
              ),
            ],
          ),

          // Recherche
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
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Rechercher un client...',
                  prefixIcon: Icon(Icons.search, color: Colors.green),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.green),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, color: Colors.grey),
                          onPressed: () {
                            _searchController.clear();
                          },
                        )
                      : null,
                ),
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
                    '${_clients.length}',
                    Icons.people_outline,
                    Colors.blue.shade800,
                  ),
                  _buildStatCard(
                    'ACTIFS',
                    '${_clients.where((c) => c['status'] == 'active').length}',
                    Icons.check_circle,
                    Colors.green,
                  ),
                  _buildStatCard(
                    'INACTIFS',
                    '${_clients.where((c) => c['status'] != 'active').length}',
                    Icons.pause_circle,
                    Colors.orange,
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
                    'LISTE DES CLIENTS',
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
                      '${_filteredClients.length} clients',
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

          if (_filteredClients.isEmpty)
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
                    Icon(Icons.people_outline,
                        size: 80, color: Colors.grey.shade400),
                    SizedBox(height: 20),
                    Text(
                      _clients.isEmpty
                          ? 'Aucun compte client créé'
                          : 'Aucun client correspondant à la recherche',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10),
                    if (_clients.isEmpty)
                      Text(
                        'Ajoutez des clients via le bouton ci-dessous',
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
                          MaterialPageRoute(
                            builder: (context) => EnregistrementClient(),
                          ),
                        );
                        _loadClients();
                      },
                      icon: Icon(Icons.person_add),
                      label: Text('AJOUTER UN CLIENT'),
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
                  final client = _filteredClients[index];
                  final status = client['status'] ?? 'active';
                  final isActive = status == 'active';
                  final createdAt = client['createdAt']?.toString() ?? '';
                  final dateFormat = DateFormat('dd/MM/yyyy');

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
                      contentPadding: EdgeInsets.all(15),
                      leading: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isActive
                              ? Colors.blue.shade100
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.person,
                          color: isActive
                              ? Colors.blue.shade800
                              : Colors.grey.shade600,
                          size: 24,
                        ),
                      ),
                      title: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${client['nom']} ${client['prenom']}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: isActive
                                        ? Colors.grey.shade800
                                        : Colors.grey.shade600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.phone, size: 12, color: Colors.grey.shade600),
                                    SizedBox(width: 4),
                                    Text(
                                      client['telephone'] ?? '',
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
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? Colors.green.shade100
                                  : Colors.orange.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              isActive ? 'ACTIF' : 'INACTIF',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isActive
                                    ? Colors.green.shade800
                                    : Colors.orange.shade800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      subtitle: Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.email, size: 12, color: Colors.grey.shade600),
                                SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    client['email'] ?? '',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.calendar_today,
                                    size: 12, color: Colors.grey.shade600),
                                SizedBox(width: 4),
                                Text(
                                  'Créé: ${createdAt.isNotEmpty ? dateFormat.format(DateTime.parse(createdAt)) : 'N/A'}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      trailing: PopupMenuButton<String>(
                        icon: Icon(Icons.more_vert,
                            color: Colors.grey.shade600),
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'details',
                            child: Row(
                              children: [
                                Icon(Icons.info, color: Colors.blue, size: 18),
                                SizedBox(width: 8),
                                Text('Détails'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'toggle_status',
                            child: Row(
                              children: [
                                Icon(
                                  isActive
                                      ? Icons.pause_circle
                                      : Icons.play_circle,
                                  color: isActive ? Colors.orange : Colors.green,
                                  size: 18,
                                ),
                                SizedBox(width: 8),
                                Text(isActive ? 'Désactiver' : 'Activer'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'reset_password',
                            child: Row(
                              children: [
                                Icon(Icons.lock_reset,
                                    color: Colors.purple, size: 18),
                                SizedBox(width: 8),
                                Text('Réinitialiser MDP'),
                              ],
                            ),
                          ),
                          PopupMenuDivider(),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, color: Colors.red, size: 18),
                                SizedBox(width: 8),
                                Text('Supprimer'),
                              ],
                            ),
                          ),
                        ],
                        onSelected: (value) {
                          switch (value) {
                            case 'details':
                              _showClientDetails(client);
                              break;
                            case 'toggle_status':
                              _changerStatutClient(client['username'], status);
                              break;
                            case 'reset_password':
                              _resetPassword(client);
                              break;
                            case 'delete':
                              _supprimerClient(client['username']);
                              break;
                          }
                        },
                      ),
                      onTap: () => _showClientDetails(client),
                    ),
                  );
                },
                childCount: _filteredClients.length,
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

  void _showClientDetails(Map<String, dynamic> client) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final createdAt = client['createdAt']?.toString() ?? '';
    final status = client['status'] ?? 'active';
    final isActive = status == 'active';

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.person,
                        color: Colors.blue,
                        size: 28,
                      ),
                    ),
                    SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'DÉTAILS DU CLIENT',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade800,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Informations complètes du compte',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Avatar et statut
                    Column(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: isActive
                              ? Colors.blue.shade100
                              : Colors.grey.shade300,
                          child: Text(
                            '${client['nom'].toString().isNotEmpty ? client['nom'][0] : '?'}${client['prenom'].toString().isNotEmpty ? client['prenom'][0] : '?'}',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: isActive
                                  ? Colors.blue.shade800
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ),
                        SizedBox(height: 15),
                        Text(
                          '${client['nom']} ${client['prenom']}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        SizedBox(height: 8),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: isActive
                                ? Colors.green.shade100
                                : Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isActive
                                  ? Colors.green.shade300
                                  : Colors.orange.shade300,
                            ),
                          ),
                          child: Text(
                            isActive ? 'COMPTE ACTIF' : 'COMPTE INACTIF',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: isActive
                                  ? Colors.green.shade800
                                  : Colors.orange.shade800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    // Informations détaillées
                    Column(
                      children: [
                        _detailItem(
                          Icons.person_outline,
                          'Nom d\'utilisateur',
                          client['username'] ?? 'N/A',
                        ),
                        SizedBox(height: 10),
                        _detailItem(
                          Icons.confirmation_number,
                          'Client ID',
                          client['clientId'] ?? 'N/A',
                        ),
                        SizedBox(height: 10),
                        _detailItem(
                          Icons.phone,
                          'Téléphone',
                          client['telephone'] ?? 'N/A',
                        ),
                        SizedBox(height: 10),
                        _detailItem(
                          Icons.email,
                          'Email',
                          client['email'] ?? 'N/A',
                        ),
                        SizedBox(height: 10),
                        _detailItem(
                          Icons.date_range,
                          'Date d\'inscription',
                          createdAt.isNotEmpty
                              ? dateFormat.format(DateTime.parse(createdAt))
                              : 'N/A',
                        ),
                        if (client['lastLogin'] != null) ...[
                          SizedBox(height: 10),
                          _detailItem(
                            Icons.login,
                            'Dernière connexion',
                            dateFormat.format(
                                DateTime.parse(client['lastLogin'])),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close),
                      label: Text('FERMER'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _changerStatutClient(client['username'], status);
                      },
                      icon: Icon(isActive ? Icons.pause_circle : Icons.play_circle),
                      label: Text(isActive ? 'DÉSACTIVER' : 'ACTIVER'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isActive ? Colors.orange : Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailItem(IconData icon, String label, String value) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blue, size: 16),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade800,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _resetPassword(Map<String, dynamic> client) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Container(
          padding: EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.lock_reset,
                  color: Colors.orange,
                  size: 40,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'RÉINITIALISER LE MOT DE PASSE',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade900,
                ),
              ),
              SizedBox(height: 15),
              Text(
                'Pour: ${client['nom']} ${client['prenom']}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 5),
              Text(
                'ID: ${client['clientId']}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Text(
                  'Le nouveau mot de passe sera généré automatiquement.',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'ANNULER',
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      // Générer un nouveau mot de passe
                      final newPassword = _generateRandomPassword();

                      final success = await AuthService.resetPassword(
                        client['username'],
                        newPassword,
                      );

                      if (success) {
                        showDialog(
                          context: context,
                          builder: (context) => Dialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Container(
                              padding: EdgeInsets.all(25),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                    size: 50,
                                  ),
                                  SizedBox(height: 20),
                                  Text(
                                    'MOT DE PASSE RÉINITIALISÉ',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green.shade900,
                                    ),
                                  ),
                                  SizedBox(height: 15),
                                  Text(
                                    'Nouveau mot de passe :',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Container(
                                    padding: EdgeInsets.all(15),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                          color: Colors.blue.shade200),
                                    ),
                                    child: SelectableText(
                                      newPassword,
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue.shade800,
                                        letterSpacing: 2,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 15),
                                  Container(
                                    padding: EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                          color: Colors.orange.shade200),
                                    ),
                                    child: Text(
                                      '⚠️ IMPORTANT: Notez ce mot de passe et transmettez-le au client.',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.orange.shade800,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                  ElevatedButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text('FERMER'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      } else {
                        NotificationService.showError(
                            context, 'Erreur lors de la réinitialisation');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('RÉINITIALISER'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _generateRandomPassword() {
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    const length = 8;
    final random = DateTime.now().millisecondsSinceEpoch;

    String password = '';
    for (int i = 0; i < length; i++) {
      final index = (random * i) % chars.length;
      password += chars[index.toInt()];
    }

    return password;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}