import '../models/demande_document.dart';
import '../services/firestore_service.dart';

class DemandeDocumentController {
  final FirestoreService _firestore = FirestoreService();
  static const String _collection = 'demandes_documents';

  Future<void> createDemande(DemandeDocument demande) async {
    await _firestore.add(_collection, demande.toMap());
  }
//récupérer toutes les demandes de l'utilisateur
  Future<List<DemandeDocument>> getDemandesByUser(String userId) async {
    try {
      // Tenter la requête avec tri 
      final docs = await _firestore.firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .orderBy('dateDemande', descending: true)
          .get();
      
      return docs.docs
          .map((doc) => DemandeDocument.fromMap(doc.id, doc.data()))
          .toList();
    } catch (e) {
      print('Firestore index error or connectivity issue: $e');
      // Fallback : Récupérer sans tri et trier en mémoire (utile si l'index n'est pas encore créé)
      try {
        final docs = await _firestore.firestore
            .collection(_collection)
            .where('userId', isEqualTo: userId)
            .get();
        
        final list = docs.docs
            .map((doc) => DemandeDocument.fromMap(doc.id, doc.data()))
            .toList();
        
        // Tri manuel par date décroissante
        list.sort((a, b) => b.dateDemande.compareTo(a.dateDemande));
        return list;
      } catch (e2) {
        print('Error fetching documents without order: $e2');
        return [];
      }
    }
  }

  Future<void> updateDemande(String id, Map<String, dynamic> data) async {
    await _firestore.update(_collection, id, data);
  }

  Future<void> deleteDemande(String id) async {
    await _firestore.delete(_collection, id);
  }
}
