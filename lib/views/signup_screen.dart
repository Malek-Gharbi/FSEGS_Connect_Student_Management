// --- Écran d'Inscription ---
// Permet aux nouveaux étudiants de créer un compte en remplissant leurs informations personnelles.

import 'package:flutter/material.dart';
import 'package:fsegs_connect/services/firebase_auth_service.dart';
import 'package:fsegs_connect/services/firestore_service.dart';
import 'dart:io';
import 'login_screen.dart';
import '../main.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _matriculeController = TextEditingController();
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _dateNaissanceController = TextEditingController();
  final _specialiteController = TextEditingController();
  final _niveauEtudeController = TextEditingController();
  final _photoUrlController = TextEditingController(); // Added for URL input

  final _authService = FirebaseAuthService();
  
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _matriculeController.dispose();
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _telephoneController.dispose();
    _dateNaissanceController.dispose();
    _specialiteController.dispose();
    _niveauEtudeController.dispose();
    _photoUrlController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)), // Default to 18 years ago
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      locale: const Locale('fr', 'FR'),
    );
    if (picked != null) {
      setState(() {
        _dateNaissanceController.text =
            '${picked.day.toString().padLeft(2, '0')} / ${picked.month.toString().padLeft(2, '0')} / ${picked.year}';
      });
    }
  }

  // Méthode principale pour soumettre le formulaire d'inscription
  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Utiliser l'URL fournie directement
      String? photoUrl = _photoUrlController.text.trim();
      if (photoUrl.isEmpty) {
        photoUrl = null;
      }

      // 2. Créer le compte et l'étudiant via le service
      await _authService.signUpWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text,
        matricule: _matriculeController.text.trim(),
        nom: _nomController.text.trim(),
        prenom: _prenomController.text.trim(),
        dateNaissance: _dateNaissanceController.text.trim(),
        telephone: _telephoneController.text.trim(),
        specialite: _specialiteController.text.trim(),
        niveauEtude: _niveauEtudeController.text.trim(),
        photoProfil: photoUrl,
      );

      if (!mounted) return;

      // 3. Rediriger vers la page d'accueil
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const FSEGSConnectHome()),
        (route) => false,
      );

    } catch (e) {
      if (!mounted) return; //Si le widget n'est plus monté, on quitte la fonction
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Widget utilitaire pour créer des champs de texte uniformes
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,  //Label du champ
    required String hint, //Indice du champ
    IconData? icon, //Icône du champ
    bool isPassword = false, //Si le champ est un mot de passe
    bool isDate = false, //Si le champ est une date
    TextInputType keyboardType = TextInputType.text, //Type de clavier
    String? Function(String?)? validator, //Vérifie si le champ est valide
    void Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isPassword && _obscurePassword,
          readOnly: isDate,
          onTap: isDate ? _selectDate : null,
          keyboardType: keyboardType,
          style: const TextStyle(color: Colors.black),
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
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
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: const Color(0xFF1D9BB1),
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  )
                : icon != null
                    ? Icon(icon, color: const Color(0xFF1D9BB1))
                    : null,
          ),
          validator: validator,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6FAFF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back button
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF1D9BB1)),
                onPressed: () => Navigator.of(context).pop(),
              ),
              const SizedBox(height: 20),
              // Title
              const Text(
                'Nouveau Compte',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1D9BB1),
                ),
              ),
              const SizedBox(height: 20),
              
              // Photo de profil Preview
              Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: const Color(0xFFDFF2F7),
                  backgroundImage: _photoUrlController.text.isNotEmpty
                      ? NetworkImage(_photoUrlController.text)
                      : null,
                  onBackgroundImageError: _photoUrlController.text.isNotEmpty
                      ? (_, __) {
                          // Handle error if URL is invalid (optional)
                        }
                      : null,
                  child: _photoUrlController.text.isEmpty
                      ? const Icon(
                          Icons.person,
                          size: 50,
                          color: Color(0xFF1D9BB1),
                        )
                      : null,
                ),
              ),

              const SizedBox(height: 32),
              // Form
              // Formulaire d'inscription avec validation
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // URL Photo
                    _buildTextField(
                      controller: _photoUrlController,
                      label: 'URL Photo de Profil (Optionnel)',
                      hint: 'https://example.com/photo.jpg', 
                      icon: Icons.link,
                      onChanged: (value) {
                         setState(() {}); // Update to show preview
                      },
                    ),

                    // Matricule
                    _buildTextField(
                      controller: _matriculeController,
                      label: 'Matricule',
                      hint: 'Votre matricule',
                      validator: (value) => 
                          (value == null || value.isEmpty) ? 'Veuillez entrer votre matricule' : null,
                    ),

                    // Nom
                    _buildTextField(
                      controller: _nomController,
                      label: 'Nom',
                      hint: 'Votre nom',
                      validator: (value) => 
                          (value == null || value.isEmpty) ? 'Veuillez entrer votre nom' : null,
                    ),

                    // Prénom
                    _buildTextField(
                      controller: _prenomController,
                      label: 'Prénom',
                      hint: 'Votre prénom',
                      validator: (value) => 
                          (value == null || value.isEmpty) ? 'Veuillez entrer votre prénom' : null,
                    ),

                    // Email
                    _buildTextField(
                      controller: _emailController,
                      label: 'Email',
                      hint: 'example@example.com',
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Veuillez entrer votre email';
                        if (!value.contains('@')) return 'Veuillez entrer un email valide';
                        return null;
                      },
                    ),

                    // Mot de passe
                    _buildTextField(
                      controller: _passwordController,
                      label: 'Mot De Passe',
                      hint: '••••••••••••', 
                      isPassword: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Veuillez entrer un mot de passe';
                        if (value.length < 6) return 'Le mot de passe doit contenir au moins 6 caractères';
                        return null;
                      },
                    ),

                    // Téléphone
                    _buildTextField(
                      controller: _telephoneController,
                      label: 'Numéro de Téléphone',
                      hint: '+216 XX XXX XXX',
                      keyboardType: TextInputType.phone,
                      validator: (value) => 
                          (value == null || value.isEmpty) ? 'Veuillez entrer votre numéro de téléphone' : null,
                    ),

                    // Date de naissance
                    _buildTextField(
                      controller: _dateNaissanceController,
                      label: 'Date De Naissance',
                      hint: 'DD / MM / YYYY',
                      isDate: true,
                      icon: Icons.calendar_today,
                      validator: (value) => 
                          (value == null || value.isEmpty) ? 'Veuillez sélectionner votre date de naissance' : null,
                    ),

                    // Spécialité
                    _buildTextField(
                      controller: _specialiteController,
                      label: 'Spécialité',
                      hint: 'Ex: Informatique, Gestion...',
                      validator: (value) => 
                          (value == null || value.isEmpty) ? 'Veuillez entrer votre spécialité' : null,
                    ),

                    // Niveau d'étude
                    _buildTextField(
                      controller: _niveauEtudeController,
                      label: 'Niveau d\'étude',
                      hint: 'Ex: Licence 1, Master 2...',
                      validator: (value) => 
                          (value == null || value.isEmpty) ? 'Veuillez entrer votre niveau d\'étude' : null,
                    ),

                    const SizedBox(height: 16),
                    
                    // Sign up button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _signUp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1D9BB1),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                'S\'inscrire',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Login link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Vous avez un compte ? ',
                          style: TextStyle(color: Colors.black87),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                            );
                          },
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              'Connectez-vous',
                              style: TextStyle(
                                color: Color(0xFF1D9BB1),
                                fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 30),
                    // Image en bas sous les boutons
                    Center(
                      child: Image.asset(
                        'assets/images/signUp.png',
                        height: 150,
                        fit: BoxFit.contain,
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
}
