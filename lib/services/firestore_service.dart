import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

// --- Service Firestore ---
// Service générique pour effectuer des opérations CRUD (Create, Read, Update, Delete) sur Cloud Firestore.
class FirestoreService {
  FirebaseFirestore? _firestore;

  FirebaseFirestore get firestore {
    try {
      // Vérifier que Firebase est initialisé
      if (Firebase.apps.isEmpty) {
        throw Exception('Firebase is not initialized. Please call Firebase.initializeApp() first.');
      }
      _firestore ??= FirebaseFirestore.instance;
      return _firestore!;
    } catch (e) {
      throw Exception('Firestore service error: $e');
    }
  }

  Future<List<QueryDocumentSnapshot>> getAll(String collection) async {
    try {
      final snapshot = await firestore.collection(collection).get();
      return snapshot.docs;
    } catch (e) {
      throw Exception('Error fetching documents from $collection: $e');
    }
  }

  Future<List<QueryDocumentSnapshot>> getAllOrdered(
    String collection, {
    String? orderBy,
    bool descending = false,
    int? limit,
  }) async {
    try {
      CollectionReference collectionRef = firestore.collection(collection);
      Query query = collectionRef;
      
      if (orderBy != null) {
        query = query.orderBy(orderBy, descending: descending);
      }
      
      if (limit != null) {
        query = query.limit(limit);
      }
      
      final snapshot = await query.get();
      return snapshot.docs;
    } catch (e) {
      throw Exception('Error fetching ordered documents from $collection: $e');
    }
  }

  Future<DocumentSnapshot?> getById(String collection, String id) async {
    try {
      return await firestore.collection(collection).doc(id).get();
    } catch (e) {
      throw Exception('Error fetching document $id from $collection: $e');
    }
  }

  Future<void> add(String collection, Map<String, dynamic> data) async {
    try {
      await firestore.collection(collection).add(data);
    } catch (e) {
      throw Exception('Error adding document to $collection: $e');
    }
  }

  Future<void> update(String collection, String id, Map<String, dynamic> data) async {
    try {
      await firestore.collection(collection).doc(id).update(data);
    } catch (e) {
      throw Exception('Error updating document $id in $collection: $e');
    }
  }

  Future<void> delete(String collection, String id) async {
    try {
      await firestore.collection(collection).doc(id).delete();
    } catch (e) {
      throw Exception('Error deleting document $id from $collection: $e');
    }
  }

  Future<List<QueryDocumentSnapshot>> getSubCollection(String collection, String docId, String subCollection) async {
    try {
      final snapshot = await firestore
          .collection(collection)
          .doc(docId)
          .collection(subCollection)
          .get();
      return snapshot.docs;
    } catch (e) {
      throw Exception('Error fetching subcollection $subCollection from $collection/$docId: $e');
    }
  }

  Future<List<QueryDocumentSnapshot>> getWithFilter(String collection, String field, dynamic value) async {
    try {
      final snapshot = await firestore
          .collection(collection)
          .where(field, isEqualTo: value)
          .get();
      return snapshot.docs;
    } catch (e) {
      throw Exception('Error fetching specific documents from $collection where $field == $value: $e');
    }
  }
}
