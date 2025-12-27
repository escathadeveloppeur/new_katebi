import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:gestion_lotissement/screens/client/dashboard_client.dart';
import 'package:gestion_lotissement/screens/client/mes_terrains.dart';
import 'package:gestion_lotissement/screens/client/mes_paiements.dart';
import 'package:gestion_lotissement/screens/client/mes_constructions.dart';
import 'package:gestion_lotissement/screens/client/notifications.dart';
import 'package:gestion_lotissement/services/auth_service.dart';
import 'package:gestion_lotissement/services/secure_client_service.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ClientPage extends StatefulWidget {
  const ClientPage({Key? key}) : super(key: key);

  @override
  _ClientPageState createState() => _ClientPageState();
}

class _ClientPageState extends State<ClientPage> {
  int _selectedIndex = 0;
  Map<String, dynamic>? _clientData;
  bool _isLoading = true;

  // Pages du client - chacune reçoit les données filtrées
  final List<Widget> _clientPages = [];

  final List<String> _pageTitles = [
    'Tableau de Bord',
    'Mes Terrains',
    'Mes Paiements',
    'Mes Constructions',
  ];

  @override
  void initState() {
    super.initState();
    _loadClientData();
  }

  Future<void> _loadClientData() async {
    setState(() => _isLoading = true);

    try {
      // Récupérer SEULEMENT les données du client connecté
      _clientData = await SecureClientService.getCurrentClientData();
      
      if (_clientData == null) {
        print('⚠️ Aucune donnée trouvée pour ce client');
        // Charger les infos de base depuis AuthService
        _clientData = {
          'authInfo': AuthService.getCurrentClientInfo() ?? {},
          'terrains': [],
          'paiements': [],
          'constructions': []
        };
      }

      // Initialiser les pages avec les données filtrées
      _clientPages.clear();
      _clientPages.addAll([
        DashboardClient(),
        MesTerrainsPage(clientData: _clientData),
        MesPaiementsPage(clientData: _clientData),
        MesConstructionsPage(clientData: _clientData),
      ]);

      print('✅ Données client chargées pour l\'espace client');
      final authInfo = _clientData!['authInfo'];
      print('   Client ID: ${authInfo['clientId']}');
      print('   Terrains: ${_clientData!['terrains'].length}');
      print('   Paiements: ${_clientData!['paiements'].length}');
      print('   Constructions: ${_clientData!['constructions'].length}');
    } catch (e) {
      print('❌ Erreur chargement données client: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _refreshData() async {
    await _loadClientData();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text('Chargement de votre espace...'),
              SizedBox(height: 10),
              Text(
                'Veuillez patienter',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_pageTitles[_selectedIndex]),
        backgroundColor: Colors.green.shade800,
        elevation: 2,
        actions: [
          // Bouton notifications avec badge
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.notifications),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => NotificationsPage()),
                  );
                },
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  constraints: BoxConstraints(
                    minWidth: 14,
                    minHeight: 14,
                  ),
                  child: Text(
                    '0',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refreshData,
            tooltip: 'Actualiser les données',
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _handlePopupSelection(value),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'profil',
                child: Row(
                  children: [
                    Icon(Icons.person, size: 20),
                    SizedBox(width: 8),
                    Text('Mon profil'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'aide',
                child: Row(
                  children: [
                    Icon(Icons.help, size: 20),
                    SizedBox(width: 8),
                    Text('Aide et support'),
                  ],
                ),
              ),
              PopupMenuDivider(),
              PopupMenuItem(
                value: 'deconnexion',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 20, color: Colors.red),
                    SizedBox(width: 8),
                    Text(
                      'Déconnexion',
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
            ],
            icon: Icon(Icons.more_vert),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: _clientPages.isNotEmpty
            ? _clientPages[_selectedIndex]
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 60, color: Colors.red),
                    SizedBox(height: 20),
                    Text('Erreur de chargement'),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _refreshData,
                      child: Text('Réessayer'),
                    ),
                  ],
                ),
              ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
      drawer: _buildDrawer(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.green.shade800,
      unselectedItemColor: Colors.grey.shade600,
      selectedFontSize: 12,
      unselectedFontSize: 11,
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Tableau de bord',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.landscape),
          label: 'Terrains',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.payment),
          label: 'Paiements',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.construction),
          label: 'Constructions',
        ),
      ],
    );
  }

  Widget _buildDrawer() {
    final authInfo = _clientData?['authInfo'] ?? {};
    final clientName = '${authInfo['prenom'] ?? ''} ${authInfo['nom'] ?? ''}'.trim();
    final displayName = clientName.isNotEmpty ? clientName : AuthService.getCurrentUsername() ?? 'Espace Client';
    final clientId = authInfo['clientId'] ?? 'N/A';

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // En-tête du drawer
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.green.shade800,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.green.shade800,
                  Colors.green.shade600,
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Text(
                    displayName.substring(0, 1).toUpperCase(),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade800,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  displayName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 5),
                Text(
                  'Client ID: $clientId',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Statut: Actif',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Menu principal avec données réelles
          _buildDrawerItem(
            index: 0,
            icon: Icons.dashboard,
            title: 'Tableau de bord',
            color: Colors.green,
            count: _clientData?['terrains'].length ?? 0,
          ),
          _buildDrawerItem(
            index: 1,
            icon: Icons.landscape,
            title: 'Mes Terrains',
            color: Colors.green,
            count: _clientData?['terrains'].length ?? 0,
          ),
          _buildDrawerItem(
            index: 2,
            icon: Icons.payment,
            title: 'Mes Paiements',
            color: Colors.green,
            count: _clientData?['paiements'].length ?? 0,
          ),
          _buildDrawerItem(
            index: 3,
            icon: Icons.construction,
            title: 'Mes Constructions',
            color: Colors.green,
            count: _clientData?['constructions'].length ?? 0,
          ),

          Divider(),

          // Section notifications
          ListTile(
            leading: Icon(Icons.notifications, color: Colors.orange),
            title: Text('Notifications'),
            trailing: FutureBuilder<int>(
              future: _getNotificationCount(),
              builder: (context, snapshot) {
                final count = snapshot.data ?? 0;
                if (count > 0) {
                  return Container(
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      count.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }
                return SizedBox();
              },
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationsPage()),
              );
            },
          ),

          Divider(),

          // Section compte
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'MON COMPTE',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
                letterSpacing: 1,
              ),
            ),
          ),
          
          ListTile(
            leading: Icon(Icons.person, color: Colors.blue),
            title: Text('Mon profil'),
            onTap: () {
              Navigator.pop(context);
              _showProfilDialog();
            },
          ),
          
          ListTile(
            leading: Icon(Icons.assessment, color: Colors.blue),
            title: Text('Mes statistiques'),
            subtitle: Text(
              '${_clientData?['terrains'].length ?? 0} terrains • ${_clientData?['paiements'].length ?? 0} paiements',
              style: TextStyle(fontSize: 11),
            ),
            onTap: () {
              Navigator.pop(context);
              _showStatistiquesDialog();
            },
          ),
          
          ListTile(
            leading: Icon(Icons.settings, color: Colors.blue),
            title: Text('Paramètres'),
            onTap: () {
              Navigator.pop(context);
              _showParametresDialog();
            },
          ),

          Divider(),

          // Section support
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'SUPPORT',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
                letterSpacing: 1,
              ),
            ),
          ),
          
          ListTile(
            leading: Icon(Icons.help, color: Colors.orange),
            title: Text('Aide et support'),
            onTap: () {
              Navigator.pop(context);
              _showAideDialog();
            },
          ),
          
          ListTile(
            leading: Icon(Icons.phone, color: Colors.orange),
            title: Text('Contactez-nous'),
            onTap: () {
              Navigator.pop(context);
              _showContactDialog();
            },
          ),
          
          ListTile(
            leading: Icon(Icons.feedback, color: Colors.orange),
            title: Text('Donner votre avis'),
            onTap: () {
              Navigator.pop(context);
              _showFeedbackDialog();
            },
          ),

          Divider(),

          // Déconnexion
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red),
            title: Text(
              'Déconnexion',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: _logout,
          ),

          // Version de l'app
          Container(
            padding: EdgeInsets.all(16),
            child: Center(
              child: Column(
                children: [
                  Text(
                    'Espace Client',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Version 1.0.0',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required int index,
    required IconData icon,
    required String title,
    required Color color,
    required int count,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title),
      trailing: count > 0 ? Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.green.shade100,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          count.toString(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.green.shade800,
          ),
        ),
      ) : null,
      selected: _selectedIndex == index,
      selectedTileColor: Colors.green.shade50,
      selectedColor: Colors.green.shade800,
      onTap: () {
        setState(() => _selectedIndex = index);
        Navigator.pop(context);
      },
    );
  }

  Future<int> _getNotificationCount() async {
    // À implémenter avec le service de notifications
    return 0;
  }

  void _handlePopupSelection(String value) {
    switch (value) {
      case 'profil':
        _showProfilDialog();
        break;
      case 'aide':
        _showAideDialog();
        break;
      case 'deconnexion':
        _logout();
        break;
    }
  }

  void _showProfilDialog() {
    final authInfo = _clientData?['authInfo'] ?? {};
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.person, color: Colors.green),
            SizedBox(width: 10),
            Text('Mon profil'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.green.shade100,
                child: Icon(
                  Icons.person,
                  size: 60,
                  color: Colors.green.shade800,
                ),
              ),
              SizedBox(height: 20),
              
              // Informations principales
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildProfileRow('👤', 'Nom complet', '${authInfo['prenom'] ?? ''} ${authInfo['nom'] ?? ''}'),
                      Divider(),
                      _buildProfileRow('🆔', 'Client ID', authInfo['clientId'] ?? 'N/A'),
                      Divider(),
                      _buildProfileRow('📧', 'Email', authInfo['email'] ?? 'N/A'),
                      Divider(),
                      _buildProfileRow('📱', 'Téléphone', authInfo['telephone'] ?? 'N/A'),
                      Divider(),
                      _buildProfileRow('📅', 'Date d\'inscription', _formatDate(authInfo['createdAt'])),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: 16),
              
              // Statistiques rapides
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        'Vos statistiques',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.green.shade800,
                        ),
                      ),
                      SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatChip('${_clientData?['terrains'].length ?? 0}', 'Terrains'),
                          _buildStatChip('${_clientData?['paiements'].length ?? 0}', 'Paiements'),
                          _buildStatChip('${_clientData?['constructions'].length ?? 0}', 'Constructions'),
                        ],
                      ),
                    ],
                  ),
                ),
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
              _showEditProfileDialog();
            },
            child: Text('Modifier'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileRow(String emoji, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(emoji, style: TextStyle(fontSize: 18)),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.green.shade900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String value, String label) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.green.shade200),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.green.shade800,
            ),
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  void _showEditProfileDialog() {
    final authInfo = _clientData?['authInfo'] ?? {};
    final nomController = TextEditingController(text: authInfo['nom'] ?? '');
    final prenomController = TextEditingController(text: authInfo['prenom'] ?? '');
    final telephoneController = TextEditingController(text: authInfo['telephone'] ?? '');
    final emailController = TextEditingController(text: authInfo['email'] ?? '');

    bool _isSaving = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: Text('Modifier le profil'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: prenomController,
                    decoration: InputDecoration(
                      labelText: 'Prénom',
                      prefixIcon: Icon(Icons.person_outline),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: nomController,
                    decoration: InputDecoration(
                      labelText: 'Nom',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: telephoneController,
                    decoration: InputDecoration(
                      labelText: 'Téléphone',
                      prefixIcon: Icon(Icons.phone),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: 20),
                  if (_isSaving) CircularProgressIndicator(),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: _isSaving ? null : () => Navigator.pop(context),
                child: Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: _isSaving
                    ? null
                    : () async {
                        setStateDialog(() => _isSaving = true);

                        // Simuler la mise à jour
                        await Future.delayed(Duration(seconds: 1));

                        // Mettre à jour les données locales
                        if (_clientData != null) {
                          _clientData!['authInfo'] = {
                            ...authInfo,
                            'nom': nomController.text,
                            'prenom': prenomController.text,
                            'telephone': telephoneController.text,
                            'email': emailController.text,
                          };
                        }

                        setStateDialog(() => _isSaving = false);
                        Navigator.pop(context);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Profil mis à jour avec succès'),
                            backgroundColor: Colors.green,
                          ),
                        );

                        // Actualiser l'interface
                        setState(() {});
                      },
                child: Text('Enregistrer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade800,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showAideDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.help, color: Colors.orange),
            SizedBox(width: 10),
            Text('Aide et support'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Votre espace client',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade800,
                        ),
                      ),
                      SizedBox(height: 8),
                      _buildHelpStep('1', 'Tableau de bord', 'Vue d\'ensemble de vos données personnelles'),
                      _buildHelpStep('2', 'Mes Terrains', 'Gérez vos terrains et consultez les détails'),
                      _buildHelpStep('3', 'Mes Paiements', 'Suivez vos transactions et échéances'),
                      _buildHelpStep('4', 'Mes Constructions', 'Visualisez l\'avancement des travaux'),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: 16),
              
              Card(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Questions fréquentes',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade800,
                        ),
                      ),
                      SizedBox(height: 8),
                      _buildFAQ('Mes données ne s\'affichent pas', 'Actualisez l\'application en tirant vers le bas ou en cliquant sur l\'icône de rafraîchissement'),
                      _buildFAQ('Comment contacter le support ?', 'Utilisez le menu "Contactez-nous" dans le tiroir latéral'),
                      _buildFAQ('Mes paiements ne sont pas à jour', 'Les données sont mises à jour toutes les 24 heures'),
                      _buildFAQ('Je ne reçois pas de notifications', 'Vérifiez les paramètres de notification dans les paramètres de l\'appareil'),
                    ],
                  ),
                ),
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
              _showContactDialog();
            },
            child: Text('Contacter'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpStep(String number, String title, String description) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade800,
                ),
              ),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  description,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQ(String question, String answer) {
    return ExpansionTile(
      title: Text(
        question,
        style: TextStyle(fontSize: 14),
      ),
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Text(
            answer,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ),
      ],
    );
  }

  void _showStatistiquesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Vos statistiques'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStatisticCard(
                'Terrains',
                _clientData?['terrains'].length ?? 0,
                Icons.landscape,
                Colors.green,
                'Nombre de terrains que vous possédez',
              ),
              SizedBox(height: 10),
              _buildStatisticCard(
                'Paiements',
                _clientData?['paiements'].length ?? 0,
                Icons.payment,
                Colors.blue,
                'Transactions effectuées',
              ),
              SizedBox(height: 10),
              _buildStatisticCard(
                'Constructions',
                _clientData?['constructions'].length ?? 0,
                Icons.construction,
                Colors.orange,
                'Projets de construction en cours',
              ),
              SizedBox(height: 10),
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        'Prochain paiement',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade800,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Aucune échéance proche',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
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

  Widget _buildStatisticCard(String title, int value, IconData icon, Color color, String subtitle) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    value.toString(),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showContactDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Contactez-nous'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.phone, color: Colors.green),
                title: Text('Téléphone'),
                subtitle: Text('+243 81 234 5678'),
              ),
              ListTile(
                leading: Icon(Icons.chat, color: Colors.green),
                title: Text('WhatsApp'),
                subtitle: Text('+243 81 234 5678'),
              ),
              ListTile(
                leading: Icon(Icons.email, color: Colors.green),
                title: Text('Email'),
                subtitle: Text('support@lotissement.com'),
              ),
              ListTile(
                leading: Icon(Icons.location_on, color: Colors.green),
                title: Text('Adresse'),
                subtitle: Text('123 Avenue des Affaires, Kinshasa'),
              ),
              SizedBox(height: 16),
              Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Text(
                        'Horaires de support',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade800,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Lundi - Vendredi: 8h00 - 17h00\nSamedi: 9h00 - 13h00',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
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

  void _showFeedbackDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Donner votre avis'),
        content: Text(
          'Cette fonctionnalité sera bientôt disponible. '
          'Merci pour votre patience.',
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

  void _showParametresDialog() {
    bool notifications = true;
    bool darkMode = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Paramètres'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SwitchListTile(
                    title: Text('Notifications'),
                    subtitle: Text('Recevoir les notifications push'),
                    value: notifications,
                    onChanged: (value) => setState(() => notifications = value),
                  ),
                  Divider(),
                  SwitchListTile(
                    title: Text('Mode sombre'),
                    subtitle: Text('Activer l\'apparence sombre'),
                    value: darkMode,
                    onChanged: (value) => setState(() => darkMode = value),
                  ),
                  Divider(),
                  ListTile(
                    leading: Icon(Icons.language),
                    title: Text('Langue'),
                    subtitle: Text('Français'),
                    trailing: Icon(Icons.arrow_forward_ios, size: 14),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Sélection de langue')),
                      );
                    },
                  ),
                  Divider(),
                  ListTile(
                    leading: Icon(Icons.privacy_tip),
                    title: Text('Confidentialité'),
                    trailing: Icon(Icons.arrow_forward_ios, size: 14),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Politique de confidentialité')),
                      );
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Annuler'),
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
          );
        },
      ),
    );
  }

  Future<void> _logout() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Déconnexion'),
        content: Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await AuthService.logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: Text('Se déconnecter'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  // Méthodes utilitaires
  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}