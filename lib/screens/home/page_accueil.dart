import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class PageAccueil extends StatelessWidget {
  const PageAccueil({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // AppBar avec menu
          SliverAppBar(
            expandedHeight: 300,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(
                      'https://images.unsplash.com/photo-1560518883-ce09059eeffa?ixlib=rb-4.0.3&auto=format&fit=crop&w=1927&q=80',
                    ),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.5),
                      BlendMode.darken,
                    ),
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.landscape,
                        size: 80,
                        color: Colors.white,
                      ),
                      SizedBox(height: 20),
                      Text(
                        'new africa investissement',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Votre espace de vie idéal',
                        style: TextStyle(
                          fontSize: 18,
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
                icon: Icon(Icons.language, color: Colors.white),
                onPressed: () {},
              ),
            ],
          ),

          // Section de présentation
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 50),
              decoration: BoxDecoration(
                color: Colors.white,
              ),
              child: Column(
                children: [
                  Text(
                    'À PROPOS DE NOUS',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade900,
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    width: 80,
                    height: 3,
                    color: Colors.green,
                  ),
                  SizedBox(height: 30),
                  Text(
                    'Fondée en 2010, new africa investissement s\'est imposée comme le leader dans le développement de lotissements modernes et écologiques en République Démocratique du Congo. Notre mission est de créer des espaces de vie harmonieux qui combinent confort moderne, sécurité et respect de l\'environnement.',
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.6,
                      color: Colors.grey.shade700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildStatItem('10+', 'Années d\'expérience'),
                      SizedBox(width: 30),
                      _buildStatItem('500+', 'Terrains vendus'),
                      SizedBox(width: 30),
                      _buildStatItem('100%', 'Clients satisfaits'),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Section services
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 50),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
              ),
              child: Column(
                children: [
                  Text(
                    'NOS SERVICES',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade900,
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    width: 80,
                    height: 3,
                    color: Colors.green,
                  ),
                  SizedBox(height: 40),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Wrap(
                      spacing: 20,
                      runSpacing: 20,
                      alignment: WrapAlignment.center,
                      children: [
                        _buildServiceCard(
                          Icons.landscape,
                          'Vente de Terrains',
                          'Terrains viabilisés avec titres fonciers sécurisés',
                          Colors.green,
                        ),
                        _buildServiceCard(
                          Icons.construction,
                          'Construction',
                          'Accompagnement dans vos projets de construction',
                          Colors.blue,
                        ),
                        _buildServiceCard(
                          Icons.attach_money,
                          'Financement',
                          'Solutions de paiement flexibles et adaptées',
                          Colors.orange,
                        ),
                        _buildServiceCard(
                          Icons.security,
                          'Sécurisation',
                          'Système de sécurité 24h/24 et clôture périmétrique',
                          Colors.purple,
                        ),
                        _buildServiceCard(
                          Icons.lightbulb,
                          'Viabilisation',
                          'Électricité, eau potable et voirie aménagées',
                          Colors.red,
                        ),
                        _buildServiceCard(
                          Icons.groups,
                          'Accompagnement',
                          'Support administratif et juridique complet',
                          Colors.teal,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Section publicité
          SliverToBoxAdapter(
            child: Container(
              height: 300,
              margin: EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                image: DecorationImage(
                  image: NetworkImage(
                    'https://images.unsplash.com/photo-1568605114967-8130f3a36994?ixlib=rb-4.0.3&auto=format&fit=crop&w=1925&q=80',
                  ),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.6),
                    BlendMode.darken,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PROJET EXCLUSIF',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade300,
                        letterSpacing: 2,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Villa Moderne 4 Chambres',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 15),
                    Text(
                      'À partir de 150,000\$ seulement\nLivraison sous 12 mois',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white70,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 25),
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: Icon(Icons.arrow_forward),
                      label: Text('DÉCOUVRIR LE PROJET'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: 25,
                          vertical: 15,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Section galerie
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 50),
              color: Colors.white,
              child: Column(
                children: [
                  Text(
                    'GALERIE',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade900,
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    width: 80,
                    height: 3,
                    color: Colors.green,
                  ),
                  SizedBox(height: 30),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        _buildGalleryImage(
                          'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?ixlib=rb-4.0.3&auto=format&fit=crop&w=1350&q=80',
                          'Infrastructures',
                        ),
                        SizedBox(width: 15),
                        _buildGalleryImage(
                          'https://images.unsplash.com/photo-1518780664697-55e3ad937233?ixlib=rb-4.0.3&auto=format&fit=crop&w=1350&q=80',
                          'Maisons Modernes',
                        ),
                        SizedBox(width: 15),
                        _buildGalleryImage(
                          'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?ixlib=rb-4.0.3&auto=format&fit=crop&w=1350&q=80',
                          'Espaces Verts',
                        ),
                        SizedBox(width: 15),
                        _buildGalleryImage(
                          'https://images.unsplash.com/photo-1560518883-ce09059eeffa?ixlib=rb-4.0.3&auto=format&fit=crop&w=1350&q=80',
                          'Plan d\'Urbanisme',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Section pourquoi nous choisir
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 50, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
              ),
              child: Column(
                children: [
                  Text(
                    'POURQUOI NOUS CHOISIR ?',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade900,
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    width: 80,
                    height: 3,
                    color: Colors.green,
                  ),
                  SizedBox(height: 40),
                  GridView.count(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    childAspectRatio: 1.2,
                    children: [
                      _buildFeatureCard(
                        FontAwesomeIcons.shieldAlt,
                        'Sécurité Garantie',
                        'Système de sécurité avancé et surveillance 24h/24',
                      ),
                      _buildFeatureCard(
                        FontAwesomeIcons.fileContract,
                        'Titres Légaux',
                        'Documents fonciers légaux et certifiés',
                      ),
                      _buildFeatureCard(
                        FontAwesomeIcons.leaf,
                        'Écologique',
                        'Respect de l\'environnement et espaces verts',
                      ),
                      _buildFeatureCard(
                        FontAwesomeIcons.handshake,
                        'Confiance',
                        '10 ans d\'expérience et 500+ clients satisfaits',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Section témoignages
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 50, horizontal: 20),
              color: Colors.white,
              child: Column(
                children: [
                  Text(
                    'TÉMOIGNAGES',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade900,
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    width: 80,
                    height: 3,
                    color: Colors.green,
                  ),
                  SizedBox(height: 40),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildTestimonialCard(
                          'Jean-Paul K.',
                          'Entrepreneur',
                          '« Excellent service ! J\'ai acheté deux terrains et tout s\'est passé très professionnellement. Les documents étaient en ordre et l\'accompagnement était parfait. »',
                          Icons.star,
                          Icons.star,
                          Icons.star,
                          Icons.star,
                          Icons.star,
                        ),
                        SizedBox(width: 20),
                        _buildTestimonialCard(
                          'Marie-Louise M.',
                          'Fonctionnaire',
                          '« Après des mauvaises expériences avec d\'autres promoteurs, Lotissement Katebi a restauré ma confiance. Transparent et fiable ! »',
                          Icons.star,
                          Icons.star,
                          Icons.star,
                          Icons.star,
                          Icons.star_half,
                        ),
                        SizedBox(width: 20),
                        _buildTestimonialCard(
                          'David T.',
                          'Ingénieur',
                          '« La qualité des infrastructures est remarquable. L\'électricité, l\'eau et les routes sont bien aménagées. Je recommande vivement ! »',
                          Icons.star,
                          Icons.star,
                          Icons.star,
                          Icons.star,
                          Icons.star,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Section contact et CTA
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 60, horizontal: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.green.shade900,
                    Colors.green.shade800,
                  ],
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'PRÊT À COMMENCER VOTRE PROJET ?',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 15),
                  Text(
                    'Rejoignez notre communauté de propriétaires satisfaits',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 40),
                  
                  // Bouton de connexion principale
                  Container(
                    width: double.infinity,
                    height: 60,
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, '/login');
                      },
                      icon: Icon(Icons.login, size: 24),
                      label: Text(
                        'ACCÉDER À MON ESPACE',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.green.shade900,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 5,
                        shadowColor: Colors.black.withOpacity(0.3),
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 20),
                  
                  // Bouton secondaire
                  OutlinedButton.icon(
                    onPressed: () {
                      // Action pour contact rapide
                      _showContactDialog(context);
                    },
                    icon: Icon(Icons.phone),
                    label: Text(
                      'NOUS CONTACTER',
                      style: TextStyle(fontSize: 16),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(color: Colors.white),
                      padding: EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 40),
                  
                  // Informations de contact
                  Wrap(
                    spacing: 40,
                    runSpacing: 20,
                    alignment: WrapAlignment.center,
                    children: [
                      _buildContactInfo(
                        Icons.location_on,
                        'Av. Lumumba, Quartier Industriel\nKinshasa, RDC',
                      ),
                      _buildContactInfo(
                        Icons.phone,
                        '+243 81 123 4567\n+243 89 987 6543',
                      ),
                      _buildContactInfo(
                        Icons.email,
                        'info@newafricainvestissement.cd\ncontact@newafricainvestissement.cd',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Footer
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.all(30),
              color: Colors.green.shade900,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.landscape,
                                color: Colors.white,
                                size: 30,
                              ),
                              SizedBox(width: 10),
                              Text(
                                'new afica investissement',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          Text(
                            '© 2024 Lotissement Katebi. Tous droits réservés.',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      Wrap(
                        spacing: 20,
                        children: [
                          IconButton(
                            icon: Icon(FontAwesomeIcons.facebookF, color: Colors.white),
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: Icon(FontAwesomeIcons.twitter, color: Colors.white),
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: Icon(FontAwesomeIcons.instagram, color: Colors.white),
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: Icon(FontAwesomeIcons.linkedinIn, color: Colors.white),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                  Divider(color: Colors.white30),
                  SizedBox(height: 20),
                  Text(
                    'Conçu avec ❤️ pour nos clients',
                    style: TextStyle(
                      color: Colors.white70,
                      fontStyle: FontStyle.italic,
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

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.green.shade800,
          ),
        ),
        SizedBox(height: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildServiceCard(IconData icon, String title, String description, Color color) {
    return Container(
      width: 300,
      padding: EdgeInsets.all(25),
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
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 40,
              color: color,
            ),
          ),
          SizedBox(height: 20),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 10),
          Text(
            description,
            style: TextStyle(
              color: Colors.grey.shade600,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildGalleryImage(String imageUrl, String title) {
    return Container(
      width: 250,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black.withOpacity(0.7),
              Colors.transparent,
            ],
          ),
        ),
        child: Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(IconData icon, String title, String description) {
    return Container(
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 40,
            color: Colors.green,
          ),
          SizedBox(height: 15),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.green.shade900,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 10),
          Text(
            description,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTestimonialCard(
    String name,
    String profession,
    String testimonial,
    IconData star1,
    IconData star2,
    IconData star3,
    IconData star4,
    IconData star5,
  ) {
    return Container(
      width: 300,
      padding: EdgeInsets.all(25),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.green.shade100,
                child: Icon(
                  Icons.person,
                  color: Colors.green,
                ),
              ),
              SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    profession,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 20),
          Text(
            testimonial,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade700,
              fontStyle: FontStyle.italic,
              height: 1.6,
            ),
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Icon(star1, color: Colors.amber, size: 18),
              Icon(star2, color: Colors.amber, size: 18),
              Icon(star3, color: Colors.amber, size: 18),
              Icon(star4, color: Colors.amber, size: 18),
              Icon(star5, color: Colors.amber, size: 18),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfo(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white, size: 24),
        SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var line in text.split('\n'))
              Text(
                line,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
          ],
        ),
      ],
    );
  }

  void _showContactDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Contactez-nous'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: Icon(Icons.phone, color: Colors.green),
              title: Text('Téléphone'),
              subtitle: Text('+243 81 123 4567'),
            ),
            ListTile(
              leading: Icon(Icons.message, color: Colors.green),
              title: Text('WhatsApp'),
              subtitle: Text('+243 81 123 4567'),
            ),
            ListTile(
              leading: Icon(Icons.email, color: Colors.green),
              title: Text('Email'),
              subtitle: Text('contact@lotissementkatebi.cd'),
            ),
            ListTile(
              leading: Icon(Icons.location_on, color: Colors.green),
              title: Text('Adresse'),
              subtitle: Text('Av. Lumumba, Quartier Industriel, Kinshasa'),
            ),
          ],
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
}