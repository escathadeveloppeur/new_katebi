import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gestion_lotissement/screens/admin/dashboard_admin.dart';
import 'package:gestion_lotissement/screens/admin/gestion_lotissements.dart';
import 'package:gestion_lotissement/screens/admin/ajout_lotissement.dart';
import 'package:gestion_lotissement/screens/admin/gestion_blocs.dart';
import 'package:gestion_lotissement/screens/admin/gestion_clients.dart';
import 'package:gestion_lotissement/screens/admin/enregistrement_client.dart';
import 'package:gestion_lotissement/screens/admin/gestion_constructions.dart';
import 'package:gestion_lotissement/screens/admin/ajout_construction.dart';
import 'package:gestion_lotissement/screens/admin/gestion_catalogue.dart';
import 'package:gestion_lotissement/screens/admin/ajout_catalogue.dart';
import 'package:gestion_lotissement/screens/admin/gestion_paiements.dart';
import 'package:gestion_lotissement/screens/admin/enregistrement_paiement.dart';
import 'package:gestion_lotissement/screens/admin/caisse_entreprise.dart';
import 'package:gestion_lotissement/screens/admin/statistiques.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({Key? key}) : super(key: key);

  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  int _selectedIndex = 0;

  // Liste des pages de l'admin
  final List<Widget> _adminPages = [
    DashboardAdmin(),
    GestionLotissements(),
    GestionClients(),
    GestionConstructions(),
    GestionPaiements(),
    GestionCatalogue(),
    CaisseEntreprise(),
    StatistiquesPage(),
  ];

  // Titres des pages
  final List<String> _pageTitles = [
    'TABLEAU DE BORD',
    'LOTISSEMENTS',
    'CLIENTS',
    'CONSTRUCTIONS',
    'PAIEMENTS',
    'CATALOGUE',
    'CAISSE',
    'STATISTIQUES',
  ];

  // Icônes pour le bottom navigation
  final List<IconData> _bottomIcons = [
    Icons.dashboard,
    Icons.landscape,
    Icons.people,
    Icons.construction,
    Icons.payment,
    Icons.photo_library,
    Icons.account_balance_wallet,
    Icons.bar_chart,
  ];

  // Couleurs pour chaque section
  final List<Color> _pageColors = [
    Colors.green,
    Colors.blue,
    Colors.purple,
    Colors.orange,
    Colors.teal,
    Colors.indigo,
    Colors.brown,
    Colors.red.shade700,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(_bottomIcons[_selectedIndex], size: 24),
            SizedBox(width: 12),
            Text(
              _pageTitles[_selectedIndex],
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green.shade900,
        elevation: 4,
        actions: _buildAppBarActions(),
      ),
      drawer: _buildDrawer(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.grey.shade50,
              Colors.green.shade50,
            ],
          ),
        ),
        child: _adminPages[_selectedIndex],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  // Actions dans l'AppBar selon la page
  List<Widget> _buildAppBarActions() {
    switch (_selectedIndex) {
      case 0: // Dashboard
        return [
          IconButton(
            icon: Icon(Icons.notifications_outlined),
            onPressed: () {
              // Gérer les notifications
            },
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              // Rafraîchir les données
              setState(() {});
            },
          ),
        ];

      case 1: // Lotissements
        return [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AjoutLotissement()),
              ).then((_) => setState(() {}));
            },
          ),
        ];

      case 2: // Clients
        return [
          IconButton(
            icon: Icon(Icons.person_add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EnregistrementClient()),
              ).then((_) => setState(() {}));
            },
          ),
        ];

      case 3: // Constructions
        return [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AjoutConstruction()),
              ).then((_) => setState(() {}));
            },
          ),
        ];

      case 4: // Paiements
        return [
          IconButton(
            icon: Icon(Icons.payment),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => EnregistrementPaiement()),
              ).then((_) => setState(() {}));
            },
          ),
        ];

      case 5: // Catalogue
        return [
          IconButton(
            icon: Icon(Icons.add_photo_alternate),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AjoutCatalogue()),
              ).then((_) => setState(() {}));
            },
          ),
        ];

      default:
        return [];
    }
  }

  // Drawer avec toutes les options
  Widget _buildDrawer() {
    return Drawer(
      child: Container(
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
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // En-tête du drawer
            Container(
              height: 180,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.green.shade800,
                    Colors.green.shade900,
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: Icon(
                      Icons.admin_panel_settings,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 15),
                  Text(
                    'ADMINISTRATION',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Gestion Lotissement Katebi',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            // Sections du menu
            _buildDrawerSection(
              'GESTION PRINCIPALE',
              [
                _buildDrawerItem(Icons.dashboard, 'Tableau de Bord', 0),
                _buildDrawerItem(Icons.landscape, 'Lotissements', 1),
                _buildDrawerItem(Icons.people, 'Clients', 2),
                _buildDrawerItem(Icons.construction, 'Constructions', 3),
              ],
            ),

            Divider(color: Colors.green.shade400, height: 20),

            _buildDrawerSection(
              'FINANCES',
              [
                _buildDrawerItem(Icons.payment, 'Paiements', 4),
                _buildDrawerItem(Icons.account_balance_wallet, 'Caisse', 6),
                _buildDrawerItem(Icons.bar_chart, 'Statistiques', 7),
              ],
            ),

            Divider(color: Colors.green.shade400, height: 20),

            _buildDrawerSection(
              'CONFIGURATION',
              [
                _buildDrawerItem(Icons.photo_library, 'Catalogue', 5),
                _buildDrawerItem(Icons.settings, 'Paramètres', -1),
              ],
            ),

            Spacer(),

            // Déconnexion
            Container(
              margin: EdgeInsets.all(20),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/login');
                },
                icon: Icon(Icons.logout, size: 20),
                label: Text(
                  'DÉCONNEXION',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.green.shade900,
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Section du drawer
  Widget _buildDrawerSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 20, top: 20, bottom: 10),
          child: Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
        ...children,
      ],
    );
  }

  // Item du drawer
  Widget _buildDrawerItem(IconData icon, String title, int index) {
    final isSelected = _selectedIndex == index;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.8),
          size: 22,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.9),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
        trailing: isSelected
            ? Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: Colors.white,
              )
            : null,
        onTap: () {
          if (index >= 0 && index < _adminPages.length) {
            setState(() {
              _selectedIndex = index;
            });
            Navigator.pop(context); // Fermer le drawer
          } else if (index == -1) {
            // Page paramètres (à implémenter)
            Navigator.pop(context);
            _showSettingsDialog();
          }
        },
      ),
    );
  }

  // Bottom Navigation Bar
  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.green.shade900,
        unselectedItemColor: Colors.grey.shade600,
        selectedFontSize: 11,
        unselectedFontSize: 10,
        backgroundColor: Colors.white,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.landscape),
            label: 'Lotissements',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Clients',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.construction),
            label: 'Constructions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.payment),
            label: 'Paiements',
          ),
        ],
      ),
    );
  }

  // Floating Action Button contextuel
  Widget? _buildFloatingActionButton() {
    switch (_selectedIndex) {
      case 0: // Dashboard - pas de FAB
        return null;

      case 1: // Lotissements
        return FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AjoutLotissement()),
            ).then((_) => setState(() {}));
          },
          icon: Icon(Icons.add_business),
          label: Text('NOUVEAU'),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: 5,
        );

      case 2: // Clients
        return FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => EnregistrementClient()),
            ).then((_) => setState(() {}));
          },
          icon: Icon(Icons.person_add),
          label: Text('NOUVEAU'),
          backgroundColor: Colors.purple,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: 5,
        );

      case 3: // Constructions
        return FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AjoutConstruction()),
            ).then((_) => setState(() {}));
          },
          icon: Icon(Icons.add_circle_outline),
          label: Text('NOUVELLE'),
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: 5,
        );

      case 4: // Paiements
        return FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => EnregistrementPaiement()),
            ).then((_) => setState(() {}));
          },
          icon: Icon(Icons.payment),
          label: Text('NOUVEAU'),
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: 5,
        );

      case 5: // Catalogue
        return FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AjoutCatalogue()),
            ).then((_) => setState(() {}));
          },
          icon: Icon(Icons.add_photo_alternate),
          label: Text('NOUVEL ÉLÉMENT'),
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: 5,
        );

      default:
        return null;
    }
  }

  // Dialog des paramètres
  void _showSettingsDialog() {
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
              Row(
                children: [
                  Icon(Icons.settings, color: Colors.green, size: 28),
                  SizedBox(width: 10),
                  Text(
                    'PARAMÈTRES',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade900,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              ListTile(
                leading: Icon(Icons.notifications, color: Colors.blue),
                title: Text('Notifications'),
                subtitle: Text('Gérer les notifications système'),
                trailing: Switch(
                  value: true,
                  activeColor: Colors.green,
                  onChanged: (value) {},
                ),
              ),
              ListTile(
                leading: Icon(Icons.backup, color: Colors.orange),
                title: Text('Sauvegarde automatique'),
                subtitle: Text('Sauvegarde quotidienne des données'),
                trailing: Switch(
                  value: true,
                  activeColor: Colors.green,
                  onChanged: (value) {},
                ),
              ),
              ListTile(
                leading: Icon(Icons.security, color: Colors.purple),
                title: Text('Sécurité'),
                subtitle: Text('Paramètres de sécurité avancés'),
                onTap: () {
                  // Naviguer vers les paramètres de sécurité
                },
              ),
              ListTile(
                leading: Icon(Icons.help, color: Colors.teal),
                title: Text('Aide et support'),
                subtitle: Text('Documentation et support technique'),
                onTap: () {
                  // Naviguer vers l'aide
                },
              ),
              SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'FERMER',
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('ENREGISTRER'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}