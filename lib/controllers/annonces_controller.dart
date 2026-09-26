import 'package:fsegs_connect/models/annonce.dart';
import 'package:fsegs_connect/services/firestore_service.dart';

class AnnonceController {
  final FirestoreService _firestoreService = FirestoreService();
//récupérer tous les annonces triées par date de publication
  Future<List<Annonce>> getAnnonces() async {
    final docs = await _firestoreService.getAllOrdered('annonces', orderBy: 'date_publication', descending: true);
    return docs.map((doc) => Annonce.fromMap(doc.id, doc.data() as Map<String, dynamic>)).toList();
  }

//récupérer les annonces par date
  Future<List<Annonce>> getAnnoncesByDate(DateTime date) async {
    // Firestore stores dates as Timestamp. Filtering by exact date match might be tricky with simple equality on timestamp if times differ.
    // Usually we filter by range [startOfDay, endOfDay].
    
    DateTime start = DateTime(date.year, date.month, date.day);
    DateTime end = DateTime(date.year, date.month, date.day, 23, 59, 59);

    final snapshot = await _firestoreService.firestore.collection('annonces')
        .where('date_publication', isGreaterThanOrEqualTo: start)
        .where('date_publication', isLessThanOrEqualTo: end)
        .orderBy('date_publication', descending: true)
        .get();

    return snapshot.docs.map((doc) => Annonce.fromMap(doc.id, doc.data())).toList();
  }
}
