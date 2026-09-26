import '../services/firebase_auth_service.dart';

class AuthController {
  final FirebaseAuthService _authService = FirebaseAuthService();

  // INSCRIPTION AVEC TOUTES LES DONNÉES
  Future<void> signUp({
    required String email,
    required String password,
    required String matricule,
    required String nom,
    required String prenom,
    required String dateNaissance,
    required String telephone,
    required String specialite,
    required String niveauEtude,
    String? photoProfil,
  }) async {
    await _authService.signUpWithEmailAndPassword(
      email,
      password,
      matricule: matricule,
      nom: nom,
      prenom: prenom,
      dateNaissance: dateNaissance,
      telephone: telephone,
      specialite: specialite,
      niveauEtude: niveauEtude,
      photoProfil: photoProfil,
    );
  }

  // CONNEXION
  Future<void> login(String email, String password) async {
    await _authService.signInWithEmailAndPassword(email, password);
  }

  // DÉCONNEXION
  Future<void> logout() async {
    await _authService.signOut();
  }

  // RÉINITIALISER MOT DE PASSE
  Future<void> resetPassword(String email) async {
    await _authService.resetPassword(email);
  }

  // RÉCUPÉRER DONNÉES ÉTUDIANT
  Future<Map<String, dynamic>?> getEtudiantData() async {
    return await _authService.getEtudiantData();
  }

  // STREAM DONNÉES ÉTUDIANT
  Stream<Map<String, dynamic>?> etudiantDataStream() {
    return _authService.etudiantDataStream();
  }

  // VÉRIFIER SI CONNECTÉ
  bool get isLoggedIn => _authService.currentUser != null;

  // OBENIR UID
  String? get currentUserId => _authService.currentUser?.uid;
}