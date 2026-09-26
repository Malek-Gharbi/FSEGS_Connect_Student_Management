import 'package:fsegs_connect/models/etudiant.dart';
import 'package:fsegs_connect/services/firebase_auth_service.dart';
import 'package:fsegs_connect/services/firestore_service.dart';

class EtudiantController {
  final FirebaseAuthService _authService = FirebaseAuthService();
  final FirestoreService _firestoreService = FirestoreService();

  // Méthode pour récupérer les données de l'étudiant connecté
  Future<Etudiant?> getCurrentEtudiant() async {
    try {
      final user = _authService.currentUser;
      if (user == null) return null;

      final docs = await _firestoreService.getAll('etudiants');
      for (var doc in docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (data['email'] == user.email) {
          return Etudiant.fromMap(doc.id, data);
        }
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // Méthode pour mettre à jour les informations de l'étudiant
  Future<void> updateEtudiant(String id, Map<String, dynamic> data) async {
    try {
      await _firestoreService.update('etudiants', id, data);
    } catch (e) {
      rethrow;
    }
  }

  // Méthode pour la déconnexion
  Future<void> signOut() async {
    await _authService.signOut();
  }
}
