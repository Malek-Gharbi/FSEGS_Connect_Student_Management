// services/storage_service.dart
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadProfileImage({
    required String userId,
    required File imageFile,
  }) async {
    try {
      // Chemin unique pour éviter les conflits
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final path = 'profile_images/$userId/profile_$timestamp.jpg';
      
      final ref = _storage.ref().child(path);
      
      // Upload avec compression
      final uploadTask = await ref.putFile(
        imageFile,
        SettableMetadata(
          contentType: 'image/jpeg',
        ),
      );
      
      // Obtenir l'URL
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      throw Exception('Erreur lors de l\'upload de l\'image: $e');
    }
  }
}