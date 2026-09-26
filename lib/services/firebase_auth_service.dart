import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// --- Service Firebase Auth ---
// Gère l'authentification (Email/Password) et la liaison avec les données Firestore de l'étudiant.
class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // AJOUT

  // Obtenir l'utilisateur actuel
  User? get currentUser => _auth.currentUser;

  // Stream de l'état d'authentification
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // INSCRIPTION AVEC CRÉATION ÉTUDIANT
  Future<UserCredential> signUpWithEmailAndPassword(
    String email,
    String password, {
    // AJOUTEZ CES PARAMÈTRES POUR L'ÉTUDIANT
    required String matricule,
    required String nom,
    required String prenom,
    required String dateNaissance,
    required String telephone,
    required String specialite,
    required String niveauEtude,
    String? photoProfil,
  }) async {
    try {
      // VÉRIFIER SI LE MATRICULE EXISTE DÉJÀ
      final matriculeQuery = await _firestore
          .collection('etudiants')
          .where('matricule', isEqualTo: matricule)
          .limit(1)
          .get();
      
      if (matriculeQuery.docs.isNotEmpty) {
        throw Exception('Ce matricule est déjà utilisé');
      }

      // VÉRIFIER SI L'EMAIL EXISTE DÉJÀ
      final emailQuery = await _firestore
          .collection('etudiants')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      
      if (emailQuery.docs.isNotEmpty) {
        throw Exception('Cet email est déjà utilisé');
      }

      // 1. Créer l'utilisateur dans Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      
      final user = userCredential.user;
      if (user != null) {
        // 2. Créer le document étudiant dans Firestore AVEC L'UID COMME DOCUMENT ID
        await _firestore.collection('etudiants').doc(user.uid).set({
          'matricule': matricule,
          'nom': nom,
          'prenom': prenom,
          'email': email,
          'dateNaissance': dateNaissance,
          'telephone': telephone,
          'photoProfil': photoProfil,
          'specialite': specialite,
          'niveauEtude': niveauEtude,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
      
      return userCredential;
    } on FirebaseAuthException catch (e) {
      // Gestion des erreurs Firebase Auth
      String message;
      switch (e.code) {
        case 'email-already-in-use':
          message = 'Cet email est déjà utilisé';
          break;
        case 'weak-password':
          message = 'Le mot de passe est trop faible';
          break;
        case 'invalid-email':
          message = 'Email invalide';
          break;
        default:
          message = 'Erreur d\'inscription: ${e.message}';
      }
      throw Exception(message);
    } catch (e) {
      throw Exception('Erreur lors de l\'inscription: $e');
    }
  }

  // Connexion avec email et mot de passe
  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'Aucun compte trouvé avec cet email';
          break;
        case 'wrong-password':
          message = 'Mot de passe incorrect';
          break;
        case 'invalid-credential':
          message = 'Identifiants incorrects';
          break;
        default:
          message = 'Erreur de connexion: ${e.message}';
      }
      throw Exception(message);
    } catch (e) {
      throw Exception('Erreur lors de la connexion: $e');
    }
  }

  // Déconnexion
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Erreur lors de la déconnexion: $e');
    }
  }

  // Réinitialiser le mot de passe
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } catch (e) {
      throw Exception('Erreur lors de la réinitialisation: $e');
    }
  }

  // Mettre à jour le profil utilisateur
  Future<void> updateProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      await currentUser?.updateDisplayName(displayName);
      if (photoURL != null) {
        await currentUser?.updatePhotoURL(photoURL);
      }
      await currentUser?.reload();
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du profil: $e');
    }
  }

  // NOUVELLE MÉTHODE : Récupérer les données de l'étudiant
  Future<Map<String, dynamic>?> getEtudiantData() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      final doc = await _firestore.collection('etudiants').doc(user.uid).get();
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      throw Exception('Erreur lors de la récupération des données étudiant: $e');
    }
  }

  // NOUVELLE MÉTHODE : Stream des données étudiant
  Stream<Map<String, dynamic>?> etudiantDataStream() {
    return _auth.authStateChanges().asyncExpand((user) {
      if (user == null) return Stream.value(null);
      
      return _firestore
          .collection('etudiants')
          .doc(user.uid)
          .snapshots()
          .map((snapshot) => snapshot.data());
    });
  }
}