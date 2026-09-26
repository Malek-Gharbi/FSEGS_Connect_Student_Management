import 'package:fsegs_connect/models/matiere.dart';
import 'package:fsegs_connect/models/etudiant_matiere.dart';
import 'package:fsegs_connect/services/firestore_service.dart';
import 'package:flutter/foundation.dart';

class AbsenceDisplayItem {
  final Matiere matiere;
  final EtudiantMatiere? data;

  AbsenceDisplayItem({required this.matiere, this.data});
}

// --- Contrôleur des Absences ---
// Combine les données des matières et les relevés d'absences pour un étudiant.
class AbsenceController {
  final FirestoreService _firestoreService = FirestoreService();

  Future<List<AbsenceDisplayItem>> getAbsencesForStudent(String studentId, {String? semestreFilter}) async {
    try {
      // 1. Fetch all subjects
      final matieresDocs = await _firestoreService.getAll('matieres');
      final matieres = matieresDocs
          .map((doc) => Matiere.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();

      // 2. Fetch student data
      final recordsDocs = await _firestoreService.getWithFilter(
        'etudiants_matieres', 
        'etudiant_id', 
        studentId
      );
      
      final records = recordsDocs
          .map((doc) => EtudiantMatiere.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      // 3. Combine
      List<AbsenceDisplayItem> combinedList = [];
      
      for (var m in matieres) {
        // Filter by semester
        if (semestreFilter != null && semestreFilter != 'Tous') {
          final String matiereSemestre = (m.semestre ?? '').trim().toUpperCase();
          final String filter = semestreFilter.trim().toUpperCase();
          
          bool match = false;
          if (filter == 'S1') {
             match = matiereSemestre == 'S1' || matiereSemestre == '1';
          } else if (filter == 'S2') {
             match = matiereSemestre == 'S2' || matiereSemestre == '2';
          } else {
             match = matiereSemestre == filter; 
          }

          if (!match) continue;
        }

        EtudiantMatiere? record;
        try {
           record = records.firstWhere(
             (n) => n.matiereId.trim() == m.id.trim() || n.matiereId.trim() == m.ref.trim(), 
           );
        } catch (e) {
          record = null;
        }
         
         combinedList.add(AbsenceDisplayItem(matiere: m, data: record));
      }
      return combinedList;

    } catch (e) {
      debugPrint('Error loading absences in controller: $e');
      rethrow;
    }
  }

  // Helper to filter list locally
  List<AbsenceDisplayItem> filterAbsences(
      List<AbsenceDisplayItem> items, 
      String searchQuery, 
      String statusFilter
  ) {
    return items.where((item) {
      // Search filter
      final matchesSearch = item.matiere.nom.toLowerCase().contains(searchQuery.toLowerCase());
      if (!matchesSearch) return false;

      // Status filter
      if (statusFilter == 'Tous') return true;
      
      final int absences = item.data?.absences ?? 0;
      
      if (statusFilter == '> 4') {
        return absences > 4;
      } else if (statusFilter == '2 - 4') {
        return absences > 2 && absences <= 4; // Interpreting "entre 2 et 4" roughly
      } else if (statusFilter == '0 Absences') {
        return absences == 0;
      }
      
      return true;
    }).toList();
  }
}
