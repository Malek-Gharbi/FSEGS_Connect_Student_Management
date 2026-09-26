import 'package:flutter/foundation.dart'; // Pour kIsWeb
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fsegs_connect/firebase_options.dart';
import 'package:fsegs_connect/config/db_config.dart';
import 'package:fsegs_connect/controllers/actualite_controller.dart';
import 'package:fsegs_connect/models/actualite.dart';
import 'package:fsegs_connect/views/splash_screen.dart';
import 'package:fsegs_connect/views/profile_screen.dart';
import 'package:fsegs_connect/views/notes_screen.dart';
import 'package:fsegs_connect/views/absences_screen.dart';
import 'package:fsegs_connect/views/diplomes_screen.dart';
import 'package:fsegs_connect/views/annonces_screen.dart';
import 'package:fsegs_connect/views/demande_document_screen.dart';
import 'package:fsegs_connect/views/message_contact_screen.dart';
import 'package:fsegs_connect/services/firebase_auth_service.dart';
import 'package:fsegs_connect/services/firestore_service.dart';
import 'package:fsegs_connect/models/etudiant.dart';
import 'package:fsegs_connect/widgets/calendar_widget.dart';

void main() async {
  // Garantit que le moteur Flutter est prêt
  WidgetsFlutterBinding.ensureInitialized();
  // Initialisation de la base de données locale (Sqflite)
  configureDatabase();

  try {
    // Vérifier si Firebase est déjà initialisé
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
    // Continuer l'exécution même si Firebase échoue
  }

  runApp(const MyApp());
}

// La classe racine de l'application
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FSEGS Connect',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Segoe UI',
        scaffoldBackgroundColor: const Color(0xFFF6FAFF),
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('fr', 'FR'),
        Locale('en', 'US'),
      ],
      home: const SplashScreen(),
      //pour la navigation entre les écrans
      routes: {
        '/home': (context) => const FSEGSConnectHome(),
        '/profile': (context) => const ProfileScreen(),
        '/notes': (context) => const NotesScreen(),
        '/annonces': (context) => const AnnoncesScreen(),
        '/documents': (context) => const DemandeDocumentScreen(),
        '/contact': (context) => const MessageContactScreen(),
        '/diplomes': (context) => const DiplomesScreen(),
        '/absences': (context) => const AbsencesScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

// Couleurs de l'application
class AppColors {
  static const Color primaryBlue = Color(0xFF1D9BB1);
  static const Color lightCream = Color(0xFFE4EDCB);
  static const Color yellowGreen = Color(0xFFC3D540);
  static const Color darkBlue = Color(0xFF10537F);

  // Nouvelles couleurs
  static const Color bgLight = Color(0xFFF6FAFF);
  static const Color lightGreen = Color(0xFFA8DDE8);
  static const Color lightPink = Color(0xFFF4C2C2);
  static const Color lightBlue1 = Color(0xFFDFF2F7);
  static const Color lightBlue2 = Color(0xFF8FCFDD);
}

// Écran d'accueil principal après la connexion
class FSEGSConnectHome extends StatefulWidget {
  const FSEGSConnectHome({super.key});

  @override
  State<FSEGSConnectHome> createState() => _FSEGSConnectHomeState();
}

class _FSEGSConnectHomeState extends State<FSEGSConnectHome> {
  final ActualiteController _actualiteController = ActualiteController();
  List<Actualite> _actualites = [];
  bool _isLoadingActualites = true;

  final _authService = FirebaseAuthService();
  final _firestoreService = FirestoreService();
  Etudiant? _currentUser;
  bool _isLoadingUser = true;

  @override
  void initState() {
    super.initState();
    // Chargement des données au démarrage de l'écran
    _loadUserData();
    _loadActualites();
  }

  // Récupère les informations de l'étudiant connecté depuis Firestore
  Future<void> _loadUserData() async {
    try {
      final user = _authService.currentUser;
      if (user != null) {
        final docs = await _firestoreService.getAll('etudiants');
        for (var doc in docs) {
          final data = doc.data() as Map<String, dynamic>;
          if (data['email'] == user.email) {
            if (mounted) {
              setState(() {
                _currentUser = Etudiant.fromMap(doc.id, data);
                _isLoadingUser = false;
              });
            }
            return;
          }
        }
      }
      if (mounted) {
        setState(() {
          _isLoadingUser = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
      if (mounted) {
        setState(() {
          _isLoadingUser = false;
        });
      }
    }
  }

  Future<void> _loadActualites() async {
    try {
      final actualites = await _actualiteController.getActualites();
      if (mounted) {
        setState(() {
          _actualites = actualites;
          _isLoadingActualites = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading actualites: $e');
      if (mounted) {
        setState(() {
          _isLoadingActualites = false;
        });
      }
    }
  }

  // Scroll keys
  final GlobalKey _servicesKey = GlobalKey();
  final GlobalKey _calendarKey = GlobalKey();
  final GlobalKey _actualitesKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Fonction pour faire défiler la page vers une section spécifique via la recherche
  void _scrollToSection(String query) {
    query = query.toLowerCase();
    GlobalKey? key;

    if (query.contains('note') ||
        query.contains('diplome') ||
        query.contains('mon emploi') ||
        query.contains('service') ||
        query.contains('annonce')) {
      key = _servicesKey;
    } else if (query.contains('calendrier') ||
        query.contains('event') ||
        query.contains('date')) {
      key = _calendarKey;
    } else if (query.contains('actualités') || query.contains('news')) {
      key = _actualitesKey;
    }

    if (key != null) {
      Scrollable.ensureVisible(
        key.currentContext!,
        duration: const Duration(seconds: 1),
        curve: Curves.easeInOut,
        alignment: 0.1, // Offset a bit from top
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6FAFF),
      endDrawer: _buildDrawer(),
      body: SafeArea(
        child: Stack(
          children: [
            // Image de fond légère
            Positioned.fill(
              ////Étend automatiquement le widget enfant
              child: Image.asset(
                'assets/images/bg.png',
                fit: BoxFit
                    .cover, //Ajuste  l'image pour qu'elle couvre toute la zone
                opacity: const AlwaysStoppedAnimation(0.1),
              ),
            ),

            // Content
            SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
                  // Header avec profil et recherche
                  _buildHeader(),

                  // Bannière de bienvenue
                  _buildWelcomeBanner(),

                  // Section Services Étudiants
                  Container(key: _servicesKey, child: _buildServicesSection()),

                  // Section Calendrier
                  Container(
                      key: _calendarKey,
                      child: CalendarWidget(actualites: _actualites)),

                  // Section Actualités
                  Container(
                      key: _actualitesKey, child: _buildActualitesSection()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          bottomLeft: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          // Header Moderne
          Container(
            padding:
                const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 30),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaryBlue, AppColors.darkBlue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: CircleAvatar(
                    radius: 35,
                    backgroundColor: AppColors.lightBlue1,
                    backgroundImage: (_currentUser?.photoProfil != null &&
                            _currentUser!.photoProfil!.isNotEmpty)
                        ? NetworkImage(_currentUser!.photoProfil!)
                        : const AssetImage('assets/images/dashboard.png')
                            as ImageProvider,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _currentUser != null
                            ? '${_currentUser!.prenom} ${_currentUser!.nom}'
                            : 'Étudiant',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        _currentUser?.email ?? 'etudiant@fsegs.com',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Menu Items
          _buildDrawerItem(
            icon: Icons.home_rounded,
            title: 'Accueil',
            onTap: () => Navigator.pop(context),
          ),
          _buildDrawerItem(
            icon: Icons.person_rounded,
            title: 'Mon Profil',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/profile');
            },
          ),
          _buildDrawerItem(
            icon: Icons.info_rounded,
            title: 'À propos',
            onTap: () {
              Navigator.pop(context);
              showAboutDialog(
                context: context,
                applicationName: 'FSEGS Connect',
                applicationVersion: '1.0.0',
                applicationIcon:
                    Image.asset('assets/images/dashboard.png', width: 50),
                children: [
                  const Text(
                      'FSEGS Connect est l\'application officielle pour les étudiants de la faculté.'),
                ],
              );
            },
          ),
          const Spacer(),
          const Divider(indent: 20, endIndent: 20),
          // Logout Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: InkWell(
              onTap: () async {
                await _authService.signOut();
                if (mounted) {
                  Navigator.pushReplacementNamed(context, '/');
                }
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.logout_rounded, color: Colors.red),
                    SizedBox(width: 15),
                    Text(
                      'Se déconnecter',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Développement: Malek Gharbi',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 11,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
      {required IconData icon,
      required String title,
      required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primaryBlue),
        title: Text(
          title,
          style: const TextStyle(
            color: AppColors.darkBlue,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        onTap: onTap,
        hoverColor: AppColors.lightBlue1,
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Column(
        children: [
          // Ligne avec profil, salutation et icône de menu (hamburger)
          Row(
            children: [
              // Photo de profil
              ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: (_currentUser?.photoProfil != null &&
                        _currentUser!.photoProfil!.isNotEmpty)
                    ? Image.network(
                        _currentUser!.photoProfil!,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 50,
                            height: 50,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primaryBlue,
                            ),
                            child:
                                const Icon(Icons.person, color: Colors.white),
                          );
                        },
                      )
                    : Image.asset(
                        'assets/images/login.png',
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 50,
                            height: 50,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primaryBlue,
                            ),
                            child:
                                const Icon(Icons.person, color: Colors.white),
                          );
                        },
                      ),
              ),
              const SizedBox(width: 12),
              // Salutation
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bonjour,',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    Text(
                      _currentUser != null
                          ? '${_currentUser!.prenom} ${_currentUser!.nom} !'
                          : 'Étudiant !',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkBlue,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Hamburger Menu
              Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu, color: AppColors.darkBlue),
                  onPressed: () => Scaffold.of(context).openEndDrawer(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          // Barre de recherche
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: _searchController,
              onSubmitted: (value) => _scrollToSection(value),
              onChanged: (value) {
                // Optionnel : recherche en temps réel mais peut être gênant si ça saute
                if (value.length > 3) _scrollToSection(value);
              },
              decoration: const InputDecoration(
                hintText: 'Rechercher (ex: actualité, notes)...',
                border: InputBorder.none,
                prefixIcon: Icon(Icons.tune, color: AppColors.primaryBlue),
                suffixIcon: Icon(Icons.search, color: AppColors.primaryBlue),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        clipBehavior: Clip
            .none, //Permet de ne pas couper les éléments qui sortent de la zone
        children: [
          // Motif de vague à droite (plusieurs cercles pour créer un effet de vague)
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.15),
              ),
            ),
          ),
          Positioned(
            //Positionne un cercle blanc à gauche
            right: -10,
            top: -10,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          // Contenu
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start, //Aligne le texte à gauche
                  children: [
                    const Text(
                      'Bienvenue sur FSEGS Connect !',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Votre portail étudiant, simple et efficace.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              // Illustration de l'étudiant (dashboard.png)
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.asset(
                  'assets/images/dashboard.png',
                  width: 150,
                  height: 150,
                  //fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 90,
                      height: 90,
                      // decoration: BoxDecoration(
                      //   color: Colors.white.withOpacity(0.25),
                      //   borderRadius: BorderRadius.circular(15),
                      // ),
                      child: const Icon(
                        Icons.person,
                        size: 60,
                        color: Colors.white,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServicesSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, //Aligne le texte à gauche
        children: [
          Text(
            'Services Étudiants',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.darkBlue,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Accédez rapidement à tous vos services académiques',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 20),

          // Grille des services - 3 colonnes
          GridView.count(
            shrinkWrap:
                true, //Permet de ne pas couper les éléments qui sortent de la zone
            physics:
                const NeverScrollableScrollPhysics(), //Permet de ne pas faire défiler la grille
            crossAxisCount: 3, //Nombre de colonnes
            crossAxisSpacing: 10, //Espace entre les colonnes
            mainAxisSpacing: 10, //Espace entre les lignes
            childAspectRatio: 0.9, //Ratio de la taille des éléments
            children: [
              _buildServiceItem(
                //Création d'un service
                '📝',
                'Mes Notes',
                'Consultez vos notes',
                AppColors.yellowGreen,
                onTap: () {
                  Navigator.of(context)
                      .pushNamed('/notes'); //Navigation vers la page des notes
                },
              ),
              _buildServiceItem(
                //Création d'un service
                '🎓',
                'Diplômes',
                'Consultez vos certifications',
                AppColors.darkBlue,
                onTap: () {
                  Navigator.of(context).pushNamed(
                      '/diplomes'); //Navigation vers la page des diplômes
                },
              ),
              _buildServiceItem(
                //Création d'un service
                '👤',
                'Absences',
                'Consultez vos absences',
                AppColors.primaryBlue,
                onTap: () {
                  Navigator.of(context).pushNamed('/absences');
                },
              ),
              _buildServiceItem(
                '🔔',
                'Annonces',
                'Consultez vos annonces',
                AppColors.darkBlue,
                onTap: () {
                  Navigator.of(context).pushNamed('/annonces');
                },
              ),
              _buildServiceItem(
                '📄',
                'Documents',
                'Demander un document',
                AppColors.yellowGreen,
                onTap: () {
                  Navigator.of(context).pushNamed('/documents');
                },
              ),
              _buildServiceItem(
                '✉️',
                'Contact',
                'Administration',
                AppColors.primaryBlue,
                onTap: () {
                  Navigator.of(context).pushNamed('/contact');
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServiceItem(
    //Création d'un service
    String icon, //Icône du service
    String title, //Titre du service
    String subtitle, //Sous-titre du service
    Color iconColor, {
    //Couleur de l'icône
    VoidCallback? onTap, //Action à effectuer lors du clic
  }) {
    return GestureDetector(
      //Gestion des clics
      onTap: onTap, //Action à effectuer lors du clic
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.primaryBlue, //Couleur de la carte
          borderRadius: BorderRadius.circular(15), //Arrondi des coins
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlue.withOpacity(0.2), //Ombre de la carte
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: 8.0, vertical: 10.0), // Reduced vertical padding
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize:
                MainAxisSize.min, // Use min to avoid forcing expansion
            children: [
              // Icône
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  icon,
                  style: const TextStyle(fontSize: 22),
                ),
              ),
              const SizedBox(height: 8), // Reduced spacing
              // Titre et sous-titre
              Flexible(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13, // Slightly reduced
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Flexible(
                      child: Text(
                        subtitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.white.withOpacity(0.9),
                          height: 1.1,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
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

  Widget _buildActualitesSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Actualités',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.darkBlue,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Les dernières actualités de votre établissement',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 20),
          if (_isLoadingActualites)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(), //Indicateur de chargement
              ),
            )
          else if (_actualites.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Center(
                child: Text(
                  'Aucune actualité disponible',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ),
            )
          else
            ..._actualites.map((actualite) =>
                _buildActualiteItem(actualite)), //Affichage des actualités
        ],
      ),
    );
  }

//Création d'un widget pour afficher une actualité
  Widget _buildActualiteItem(Actualite actualite) {
    final months = [
      'Janvier',
      'Février',
      'Mars',
      'Avril',
      'Mai',
      'Juin',
      'Juillet',
      'Août',
      'Septembre',
      'Octobre',
      'Novembre',
      'Décembre'
    ];

    final day = actualite.datePublication.day;
    final month = months[actualite.datePublication.month - 1];

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: AppColors.yellowGreen,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: AppColors.yellowGreen.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            // Date
            Container(
              width: 60,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    '$day',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkBlue,
                    ),
                  ),
                  Text(
                    month,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.darkBlue.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 15),
            // Contenu
            Expanded(
              //Permet de ne pas couper les éléments qui sortent de la zone
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    actualite.titre,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkBlue,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    actualite.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.darkBlue.withOpacity(0.8),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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
