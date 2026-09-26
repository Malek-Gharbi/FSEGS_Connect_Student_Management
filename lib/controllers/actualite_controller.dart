import 'package:flutter/foundation.dart';
import '../models/actualite.dart';
import '../services/firestore_service.dart';


// Gère la récupération et le flux de données des actualités/annonces depuis Firestore.
class ActualiteController {
  final FirestoreService _firestore = FirestoreService();

  Future<List<Actualite>> getActualites() async {
    try {
      // Récupérer les actualités triées par date de publication (plus récentes en premier)
      final docs = await _firestore.getAllOrdered(
        'Actualite',  //Récupère tous les documents de la collection Actualite
        orderBy: 'datePublication', //Triés par datePublication
        descending: true, //En ordre décroissant
      );
      
      final actualites = docs
          .map((doc) {  
            try {
              final data = doc.data() as Map<String, dynamic>;    //données Firestore (JSON)
              return Actualite.fromMap(doc.id, data);
            } catch (e) {
              debugPrint('Error parsing actualite ${doc.id}: $e');
              return null;
            }
          })//supprime les null (documents invalides)
          .whereType<Actualite>()
          .toList();
      
      return actualites;
    } catch (e) {
      debugPrint('Error fetching actualites: $e');
      // Si l'ordre par datePublication échoue (index manquant), essayer sans ordre
      try {
        final docs = await _firestore.getAll('Actualite');
        final actualites = docs
            .map((doc) {
              try {
                final data = doc.data() as Map<String, dynamic>;
                return Actualite.fromMap(doc.id, data);
              } catch (e) {
                debugPrint('Error parsing actualite ${doc.id}: $e');
                return null;
              }
            })  //supprime les null (documents invalides)
            .whereType<Actualite>()
            .toList();
        
        // Trier manuellement par date
        actualites.sort((a, b) => b.datePublication.compareTo(a.datePublication));
        return actualites;
      } catch (e2) {
        debugPrint('Error fetching actualites without order: $e2');
        return [];
      }
    }
  }

  Stream<List<Actualite>> getActualitesStream() {
    try {
      // Utiliser le service Firestore au lieu d'accéder directement
      return _firestore.firestore
          .collection('Actualite')
          .orderBy('datePublication', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) {
                try {
                  return Actualite.fromMap(doc.id, doc.data());
                } catch (e) {
                  throw Exception('Error parsing actualite ${doc.id}: $e');
                }
              })
              .toList())
          .handleError((error) {
            throw Exception('Error in actualites stream: $error');
          });
    } catch (e) {
      throw Exception('Error creating actualites stream: $e');
    }
  }
}
