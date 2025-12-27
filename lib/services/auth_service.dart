import 'package:hive/hive.dart';
import 'package:flutter/material.dart';
import 'package:gestion_lotissement/services/database_service.dart';

class AuthService {
  static late Box authBox;

  static Future<void> init() async {
    authBox = await Hive.openBox('auth');

    // Créer un admin par défaut si nécessaire
    if (!authBox.containsKey('admin')) {
      authBox.put('admin', {
        'username': 'admin',
        'password': 'admin123',
        'role': 'admin',
        'createdAt': DateTime.now().toIso8601String(),
      });
    }
  }

  static Future<bool> login(String username, String password) async {
    await Future.delayed(Duration(seconds: 1));

    // Vérifier l'admin
    if (username == 'admin' && password == 'admin123') {
      authBox.put('currentUser', {
        'username': username,
        'role': 'admin',
        'isLoggedIn': true,
        'loginTime': DateTime.now().toIso8601String(),
      });
      return true;
    }

    // Vérifier les clients inscrits
    final storedUser = authBox.get(username);
    if (storedUser != null && 
        storedUser['password'] == password) {
      // Vérifier si le compte est actif
      if (storedUser['status'] != null && storedUser['status'] != 'active') {
        return false;
      }
      
      authBox.put('currentUser', {
        'username': username,
        'role': storedUser['role'],
        'clientId': storedUser['clientId'],
        'isLoggedIn': true,
        'loginTime': DateTime.now().toIso8601String(),
      });
      return true;
    }

    return false;
  }

  // Méthode pour qu'un client s'inscrive
  static Future<Map<String, dynamic>> registerClient({
    required String username,
    required String password,
    required String nom,
    required String prenom,
    required String telephone,
    required String email,
  }) async {
    // Vérifications
    if (username.isEmpty || password.isEmpty || 
        nom.isEmpty || prenom.isEmpty || telephone.isEmpty || email.isEmpty) {
      return {
        'success': false,
        'message': 'Tous les champs sont obligatoires',
      };
    }

    // Vérifier si le username existe déjà
    if (authBox.containsKey(username)) {
      return {
        'success': false,
        'message': 'Ce nom d\'utilisateur est déjà utilisé',
      };
    }

    // Vérifier si l'email est déjà utilisé
    for (var key in authBox.keys) {
      if (key != 'currentUser') {
        final user = authBox.get(key);
        if (user is Map && user['email'] == email) {
          return {
            'success': false,
            'message': 'Cet email est déjà utilisé',
          };
        }
      }
    }

    // Validation email
    if (!email.contains('@') || !email.contains('.')) {
      return {
        'success': false,
        'message': 'Email invalide',
      };
    }

    // Validation téléphone (au moins 8 chiffres)
    final phoneDigits = telephone.replaceAll(RegExp(r'\D'), '');
    if (phoneDigits.length < 8) {
      return {
        'success': false,
        'message': 'Numéro de téléphone invalide',
      };
    }

    try {
      // Générer un ID client unique
      final clientId = await DatabaseService.genererNumeroOrdre();
      
      // Créer le compte client
      authBox.put(username, {
        'username': username,
        'password': password,
        'role': 'client',
        'clientId': clientId.toString(),
        'nom': nom.toUpperCase(), // Stocker en majuscules
        'prenom': prenom,
        'telephone': telephone,
        'email': email.toLowerCase(), // Stocker en minuscules
        'createdAt': DateTime.now().toIso8601String(),
        'status': 'active',
        'lastLogin': null,
        'passwordChangedAt': null,
      });

      // Informations de connexion à retourner
      final loginInfo = {
        'username': username,
        'password': password, // À afficher une seule fois
      };

      return {
        'success': true,
        'message': 'Compte créé avec succès!',
        'clientId': clientId,
        'loginInfo': loginInfo,
        'username': username,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur technique: $e',
      };
    }
  }
// Ajoutez cette méthode pour remplacer les appels manquants
static List<Map<String, dynamic>> getClientAccounts() {
  return getAllClients(); // Appelle simplement la méthode existante
}
  // Reste du code inchangé...
  static Future<bool> changePassword({
    required String username,
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = authBox.get(username);
    
    if (user == null || user['password'] != currentPassword) {
      return false;
    }

    try {
      user['password'] = newPassword;
      user['passwordChangedAt'] = DateTime.now().toIso8601String();
      authBox.put(username, user);
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> resetPassword(String username, String newPassword) async {
    if (!isAdmin()) {
      return false;
    }

    final user = authBox.get(username);
    if (user == null) {
      return false;
    }

    try {
      user['password'] = newPassword;
      user['passwordChangedAt'] = DateTime.now().toIso8601String();
      user['passwordResetByAdmin'] = true;
      authBox.put(username, user);
      return true;
    } catch (e) {
      return false;
    }
  }

  static List<Map<String, dynamic>> getAllClients() {
    if (!isAdmin()) {
      return [];
    }

    List<Map<String, dynamic>> clients = [];
    
    for (var key in authBox.keys) {
      if (key != 'currentUser' && key != 'admin') {
        final user = authBox.get(key);
        if (user is Map && user['role'] == 'client') {
          clients.add({
            'username': key,
            'nom': user['nom'] ?? '',
            'prenom': user['prenom'] ?? '',
            'telephone': user['telephone'] ?? '',
            'email': user['email'] ?? '',
            'clientId': user['clientId'] ?? '',
            'createdAt': user['createdAt'] ?? '',
            'status': user['status'] ?? 'active',
            'lastLogin': user['lastLogin'] ?? '',
          });
        }
      }
    }

    return clients;
  }

  static Future<bool> toggleClientStatus(String username, String status) async {
    if (!isAdmin()) {
      return false;
    }

    final user = authBox.get(username);
    if (user == null || user['role'] != 'client') {
      return false;
    }

    try {
      user['status'] = status;
      authBox.put(username, user);
      return true;
    } catch (e) {
      return false;
    }
  }

  static Map<String, dynamic>? getCurrentClientInfo() {
    final currentUser = authBox.get('currentUser');
    if (currentUser == null || currentUser['role'] != 'client') {
      return null;
    }

    final username = currentUser['username'];
    final clientData = authBox.get(username);
    
    if (clientData == null) {
      return null;
    }

    return {
      'username': clientData['username'],
      'nom': clientData['nom'] ?? '',
      'prenom': clientData['prenom'] ?? '',
      'telephone': clientData['telephone'] ?? '',
      'email': clientData['email'] ?? '',
      'clientId': clientData['clientId'] ?? '',
      'createdAt': clientData['createdAt'] ?? '',
      'status': clientData['status'] ?? 'active',
    };
  }

  static List<Map<String, dynamic>> getAllUsers() {
    if (!isAdmin()) {
      return [];
    }

    List<Map<String, dynamic>> users = [];
    
    for (var key in authBox.keys) {
      if (key != 'currentUser') {
        final user = authBox.get(key);
        if (user is Map) {
          users.add({
            'username': key,
            'role': user['role'] ?? 'inconnu',
            'createdAt': user['createdAt'] ?? 'date inconnue',
            'nom': user['nom'] ?? '',
            'prenom': user['prenom'] ?? '',
            'email': user['email'] ?? '',
            'status': user['status'] ?? 'active',
          });
        }
      }
    }

    return users;
  }

  static Future<void> logout() async {
    final currentUser = authBox.get('currentUser');
    if (currentUser != null) {
      final username = currentUser['username'];
      final userData = authBox.get(username);
      if (userData != null) {
        userData['lastLogout'] = DateTime.now().toIso8601String();
        authBox.put(username, userData);
      }
    }
    
    authBox.delete('currentUser');
  }

  static bool isLoggedIn() {
    final user = authBox.get('currentUser');
    return user != null && user['isLoggedIn'] == true;
  }

  static bool isAdmin() {
    final user = authBox.get('currentUser');
    return user != null && user['role'] == 'admin';
  }

  static bool isClient() {
    final user = authBox.get('currentUser');
    return user != null && user['role'] == 'client';
  }

  static String? getCurrentUsername() {
    final user = authBox.get('currentUser');
    return user?['username'];
  }

  static String? getCurrentClientId() {
    final user = authBox.get('currentUser');
    return user?['clientId'];
  }

  static bool isAccountActive(String username) {
    final user = authBox.get(username);
    if (user == null) return false;
    
    return user['status'] == 'active' || user['status'] == null;
  }

  static bool shouldChangePassword() {
    final currentUser = authBox.get('currentUser');
    if (currentUser == null) return false;

    final username = currentUser['username'];
    final userData = authBox.get(username);
    
    if (userData == null || userData['passwordChangedAt'] == null) {
      return false;
    }

    try {
      final lastChange = DateTime.parse(userData['passwordChangedAt']);
      final daysSinceChange = DateTime.now().difference(lastChange).inDays;
      return daysSinceChange >= 90;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> verifyCredentials(String username, String password) async {
    final user = authBox.get(username);
    if (user == null) return false;
    
    return user['password'] == password;
  }

  // Widget pour le formulaire d'inscription client
  static Widget buildRegistrationForm({
    required BuildContext context,
    required Function(Map<String, dynamic>) onSuccess,
    required Function(String) onError,
  }) {
    return _RegistrationFormWidget(
      onSuccess: onSuccess,
      onError: onError,
    );
  }
}

// Widget pour le formulaire d'inscription
class _RegistrationFormWidget extends StatefulWidget {
  final Function(Map<String, dynamic>) onSuccess;
  final Function(String) onError;

  const _RegistrationFormWidget({
    required this.onSuccess,
    required this.onError,
  });

  @override
  __RegistrationFormWidgetState createState() => __RegistrationFormWidgetState();
}

class __RegistrationFormWidgetState extends State<_RegistrationFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Fonction de validation de téléphone
  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer votre téléphone';
    }
    
    // Supprimer tous les caractères non numériques
    final digits = value.replaceAll(RegExp(r'\D'), '');
    
    // Vérifier la longueur
    if (digits.length < 8) {
      return 'Numéro de téléphone trop court (min 8 chiffres)';
    }
    
    // Vérifier le format (peut commencer par +, 00, ou directement)
    final phoneRegex = RegExp(r'^(\+?\d{1,4}?[\s\-]?)?(\(?\d{1,4}\)?[\s\-]?)?[\d\s\-]{8,}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Format de téléphone invalide';
    }
    
    return null;
  }

  // Fonction de validation d'email
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer votre email';
    }
    
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Email invalide (exemple: nom@domaine.com)';
    }
    
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titre avec instructions
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade100),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '⚠️ IMPORTANT',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Gardez bien vos identifiants de connexion. Ils vous seront nécessaires pour accéder à votre espace client.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 20),
            
            Text(
              'Création de compte client',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade800,
              ),
            ),
            
            SizedBox(height: 8),
            
            Text(
              'Remplissez tous les champs pour créer votre compte',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            
            SizedBox(height: 24),

            // Nom
            Text(
              'Nom *',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
            SizedBox(height: 4),
            TextFormField(
              controller: _nomController,
              decoration: InputDecoration(
                hintText: 'Entrez votre nom de famille',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: Icon(Icons.person_outline),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Le nom est obligatoire';
                }
                if (value.length < 2) {
                  return 'Nom trop court';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            
            // Prénom
            Text(
              'Prénom *',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
            SizedBox(height: 4),
            TextFormField(
              controller: _prenomController,
              decoration: InputDecoration(
                hintText: 'Entrez votre prénom',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: Icon(Icons.person_outlined),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Le prénom est obligatoire';
                }
                if (value.length < 2) {
                  return 'Prénom trop court';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            
            // Téléphone
            Text(
              'Téléphone *',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
            SizedBox(height: 4),
            TextFormField(
              controller: _telephoneController,
              decoration: InputDecoration(
                hintText: 'Ex: 0612345678 ou +212612345678',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
              validator: _validatePhone,
            ),
            SizedBox(height: 16),
            
            // Email
            Text(
              'Email *',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
            SizedBox(height: 4),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                hintText: 'exemple@domaine.com',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: _validateEmail,
            ),
            SizedBox(height: 16),
            
            // Nom d'utilisateur
            Text(
              'Nom d\'utilisateur *',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
            SizedBox(height: 4),
            TextFormField(
              controller: _usernameController,
              decoration: InputDecoration(
                hintText: 'Choisissez un nom d\'utilisateur unique',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Le nom d\'utilisateur est obligatoire';
                }
                if (value.length < 3) {
                  return 'Minimum 3 caractères';
                }
                if (value.contains(' ')) {
                  return 'Pas d\'espaces autorisés';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            
            // Mot de passe
            Text(
              'Mot de passe *',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
            SizedBox(height: 4),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                hintText: 'Minimum 6 caractères',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Le mot de passe est obligatoire';
                }
                if (value.length < 6) {
                  return 'Minimum 6 caractères';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            
            // Confirmation mot de passe
            Text(
              'Confirmer le mot de passe *',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
            SizedBox(height: 4),
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              decoration: InputDecoration(
                hintText: 'Répétez le même mot de passe',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez confirmer le mot de passe';
                }
                if (value != _passwordController.text) {
                  return 'Les mots de passe ne correspondent pas';
                }
                return null;
              },
            ),
            
            SizedBox(height: 32),
            
            // Bouton d'inscription
            if (_isLoading)
              Center(child: CircularProgressIndicator())
            else
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      setState(() {
                        _isLoading = true;
                      });
                      
                      final result = await AuthService.registerClient(
                        username: _usernameController.text.trim(),
                        password: _passwordController.text,
                        nom: _nomController.text.trim(),
                        prenom: _prenomController.text.trim(),
                        telephone: _telephoneController.text.trim(),
                        email: _emailController.text.trim(),
                      );
                      
                      setState(() {
                        _isLoading = false;
                      });
                      
                      if (result['success'] == true) {
                        widget.onSuccess(result);
                      } else {
                        widget.onError(result['message']);
                      }
                    }
                  },
                  icon: Icon(Icons.person_add_alt_1),
                  label: Text(
                    'CRÉER MON COMPTE',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              
            SizedBox(height: 16),
            
            // Note sur les identifiants
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.amber.shade700, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Vos identifiants de connexion seront :\n'
                      '• Nom d\'utilisateur: celui que vous venez de choisir\n'
                      '• Mot de passe: celui que vous venez de créer',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.amber.shade800,
                      ),
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
}