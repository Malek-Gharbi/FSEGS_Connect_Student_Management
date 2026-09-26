import '../models/message_contact.dart';
import '../services/firestore_service.dart';

class MessageContactController {
  final FirestoreService _firestore = FirestoreService();
  static const String _collection = 'messages_contact';
//envoyer un message
  Future<void> sendMessage(MessageContact message) async {
    await _firestore.add(_collection, message.toMap());
  }
//récupérer toutes les messages de l'utilisateur
  Future<List<MessageContact>> getMessagesByUser(String userId) async {
    try {
      final docs = await _firestore.firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .orderBy('dateEnvoi', descending: true)
          .get();
      
      return docs.docs
          .map((doc) => MessageContact.fromMap(doc.id, doc.data()))
          .toList();
    } catch (e) {
      // Fallback in case of index error
      final docs = await _firestore.firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .get();
      
      final list = docs.docs
          .map((doc) => MessageContact.fromMap(doc.id, doc.data()))
          .toList();
      
      list.sort((a, b) => b.dateEnvoi.compareTo(a.dateEnvoi));
      return list;
    }
  }
//mettre à jour le statut d'un message
  Future<void> updateMessageStatut(String id, String statut) async {
    await _firestore.update(_collection, id, {'statut': statut});
  }
}
