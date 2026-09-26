// --- Écran de Profil ---
// Affiche les informations personnelles de l'étudiant et permet de les modifier (Email, Téléphone, etc.).

import 'package:flutter/material.dart';
import 'package:fsegs_connect/models/etudiant.dart';
import 'package:fsegs_connect/controllers/etudiant_controller.dart';
import 'login_screen.dart';
import '../main.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _etudiantController = EtudiantController();
  Etudiant? _etudiant;
  bool _isLoading = true;
  bool _isEditing = false;

  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _emailController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _dateNaissanceController = TextEditingController();
  final _matriculeController = TextEditingController();
  final _photoUrlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _telephoneController.dispose();
    _dateNaissanceController.dispose();
    _matriculeController.dispose();
    _photoUrlController.dispose();
    super.dispose();
  }

  // Charge les données de l'étudiant actuel depuis le contrôleur
  Future<void> _loadUserData() async {
    try {
      final etudiant = await _etudiantController.getCurrentEtudiant();
      
      if (etudiant == null) {
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
        return;
      }

      setState(() {
        _etudiant = etudiant;
        _nomController.text = '${_etudiant!.nom} ${_etudiant!.prenom}';
        _prenomController.text = ''; 
        _emailController.text = _etudiant!.email;
        _telephoneController.text = _etudiant!.telephone;
        _dateNaissanceController.text = _etudiant!.dateNaissance;
        _matriculeController.text = _etudiant!.matricule;
        if (_etudiant!.photoProfil != null) {
          _photoUrlController.text = _etudiant!.photoProfil!;
        }
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Enregistre les modifications apportées au profil dans Firestore
  Future<void> _saveUserData() async {
    if (_etudiant == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final updatedData = {
        'email': _emailController.text,
        'telephone': _telephoneController.text,
        'dateNaissance': _dateNaissanceController.text,
        'photoProfil': _photoUrlController.text.isNotEmpty ? _photoUrlController.text : null,
      };

      await _etudiantController.updateEtudiant(_etudiant!.id, updatedData);

      setState(() {
        _isEditing = false;
        _isLoading = false;
        // Mettre à jour l'objet local
        _etudiant!.email = _emailController.text;
        _etudiant!.telephone = _telephoneController.text;
        _etudiant!.dateNaissance = _dateNaissanceController.text;
        _etudiant!.photoProfil = _photoUrlController.text.isNotEmpty ? _photoUrlController.text : null;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil mis à jour avec succès'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la mise à jour: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Déconnecte l'utilisateur et le redirige vers l'écran de connexion via le contrôleur
  Future<void> _logout() async {
    try {
      await _etudiantController.signOut();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      locale: const Locale('fr', 'FR'),
    );
    if (picked != null && _isEditing) {
      setState(() {
        _dateNaissanceController.text =
            '${picked.day.toString().padLeft(2, '0')} / ${picked.month.toString().padLeft(2, '0')} / ${picked.year}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF6FAFF),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF6FAFF),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Color(0xFF1D9BB1)),
                      onPressed: () => Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => const FSEGSConnectHome()),
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        'Profile',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1D9BB1),
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
                const SizedBox(height: 24),
                // Profile picture
                // Image de profil avec boutons d'édition et de déconnexion
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: const Color(0xFF1D9BB1),
                        backgroundImage: _photoUrlController.text.isNotEmpty
                            ? NetworkImage(_photoUrlController.text)
                            : null,
                        child: _photoUrlController.text.isEmpty
                            ? const Icon(
                                Icons.person,
                                size: 60,
                                color: Colors.white,
                              )
                            : null,
                      ),
                      
                      // Bouton Éditer / Sauvegarder
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () {
                            if (_isEditing) {
                              _saveUserData();
                            } else {
                              setState(() {
                                _isEditing = true;
                              });
                            }
                          },
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: const Color(0xFFDFF2F7),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              _isEditing ? Icons.check : Icons.edit,
                              size: 18,
                              color: const Color(0xFF1D9BB1),
                            ),
                          ),
                        ),
                      ),
                      
                      // Bouton Déconnexion
                      Positioned(
                        bottom: 0,
                        right: 42,
                        child: GestureDetector(
                          onTap: _logout,
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFCDD2), // Fond rouge clair pour logout
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.logout,
                              size: 18,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                
                // Photo URL (Only visible in edit mode)
                if (_isEditing) ...[
                   const Text(
                    'URL Photo de Profil',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _photoUrlController,
                    onChanged: (val) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'https://example.com/image.jpg',
                      hintStyle: const TextStyle(color: Color(0xFF8FCFDD)),
                      filled: true,
                      fillColor: const Color(0xFFDFF2F7),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      suffixIcon: const Icon(Icons.link, color: Color(0xFF1D9BB1)),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Nom & Prénom (Lecture seule)
                const Text(
                  'Nom & Prénom',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _nomController,
                  enabled: false,
                  decoration: InputDecoration(
                    hintText: 'Nom et Prénom',
                    hintStyle: const TextStyle(color: Color(0xFF8FCFDD)),
                    filled: true,
                    fillColor: const Color(0xFFEEEEEE),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Matricule (Désormais lecture seule)
                const Text(
                  'Matricule',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _matriculeController,
                  enabled: false, // ALWAYS READ-ONLY
                  decoration: InputDecoration(
                    hintText: 'Matricule',
                    hintStyle: const TextStyle(color: Color(0xFF8FCFDD)),
                    filled: true,
                    fillColor: const Color(0xFFEEEEEE), 
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Numéro de téléphone
                const Text(
                  'Numéro De Téléphone',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _telephoneController,
                  enabled: _isEditing,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: '+216 XX XXX XXX',
                    hintStyle: const TextStyle(color: Color(0xFF8FCFDD)),
                    filled: true,
                    fillColor: _isEditing ? const Color(0xFFDFF2F7) : const Color(0xFFEEEEEE),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Email
                const Text(
                  'Email',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _emailController,
                  enabled: _isEditing,
                  decoration: InputDecoration(
                    hintText: 'example@example.com',
                    hintStyle: const TextStyle(color: Color(0xFF8FCFDD)),
                    filled: true,
                    fillColor: _isEditing ? const Color(0xFFDFF2F7) : const Color(0xFFEEEEEE),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Date de naissance
                const Text(
                  'Date De Naissance',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _dateNaissanceController,
                  enabled: _isEditing,
                  readOnly: true,
                  onTap: _isEditing ? _selectDate : null,
                  decoration: InputDecoration(
                    hintText: 'DD / MM / YYYY',
                    hintStyle: const TextStyle(color: Color(0xFF8FCFDD)),
                    filled: true,
                    fillColor: _isEditing ? const Color(0xFFDFF2F7) : const Color(0xFFEEEEEE),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    suffixIcon: _isEditing
                        ? const Icon(
                            Icons.calendar_today,
                            color: Color(0xFF1D9BB1),
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
