import 'package:fsegs_connect/models/matiere.dart';
import 'package:fsegs_connect/models/etudiant_matiere.dart';
import 'package:fsegs_connect/services/firestore_service.dart';
import 'package:flutter/foundation.dart';

class NoteDisplayItem {
  final Matiere matiere;
  final EtudiantMatiere? note;

  NoteDisplayItem({required this.matiere, this.note});
}

class NotesController {
  final FirestoreService _firestoreService = FirestoreService();
//récupérer toutes les notes d'un étudiant
  Future<List<NoteDisplayItem>> getNotesForStudent(String studentId, {String? semestreFilter}) async { // Added filter param
    try {
      // 1. Fetch all subjects (Matieres)
      final matieresDocs = await _firestoreService.getAll('matieres');
      final matieres = matieresDocs
          .map((doc) => Matiere.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();

      // 2. Fetch student grades (EtudiantMatieres)
      final notesDocs = await _firestoreService.getWithFilter(
        'etudiants_matieres', 
        'etudiant_id', 
        studentId
      );
      
      final notes = notesDocs
          .map((doc) => EtudiantMatiere.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      // 3. Combine data
      List<NoteDisplayItem> combinedList = [];
      
      for (var m in matieres) {
        // Filter by semester if needed
        if (semestreFilter != null && semestreFilter != 'Tous') {
          final String matiereSemestre = (m.semestre ?? '').trim().toUpperCase();
          final String filter = semestreFilter.trim().toUpperCase();
          
          bool match = false;
          if (filter == 'S1') {
             match = matiereSemestre == 'S1' || matiereSemestre == '1';
          } else if (filter == 'S2') {
             match = matiereSemestre == 'S2' || matiereSemestre == '2';
          } else {
             // Fallback for strict match
             match = matiereSemestre == filter; 
          }

          if (!match) continue;
        }

        EtudiantMatiere? note;
        try {
           // Matching logic: note.matiereId == m.id OR note.matiereId == m.ref
           note = notes.firstWhere(
             (n) => n.matiereId.trim() == m.id.trim() || n.matiereId.trim() == m.ref.trim(), 
           );
        } catch (e) {
          note = null;
        }
         
         combinedList.add(NoteDisplayItem(matiere: m, note: note));
      }
      return combinedList;

    } catch (e) {
      debugPrint('Error loading notes in controller: $e');
      rethrow;
    }
  }
//calculer la moyenne d'un semestre
  double calculateSemesterAverage(List<NoteDisplayItem> notesList, String semester) {
    final semesterNotes = notesList.where((item) {
      final String matiereSemestre = (item.matiere.semestre ?? '').trim().toUpperCase();  //indique le semestre de la matière
      final String target = semester.trim().toUpperCase();  // Convert to uppercase for comparison
      return matiereSemestre == target || matiereSemestre == target.replaceAll('S', '');
    }).toList();
  //Cas limite : aucune matière pour ce semestre
    if (semesterNotes.isEmpty) return 0.0;  //Évite :division par zéro , erreurs de calcul
//Initialisation des variables de calcul
    double totalPoints = 0.0;
    double totalCoef = 0.0;

    for (var item in semesterNotes) {
      if (item.matiere.coefficient > 0) {   //Vérification du coefficient 
        // Use 0 if note is missing to avoid Exception, as requested to fix logic
        double moy = item.note?.moyenne ?? 0.0;  //Vérification moyenne de la matière
        totalPoints += moy * item.matiere.coefficient;  //Calcul du total des points pondérés
        totalCoef += item.matiere.coefficient;  //Calcul du total des coefficients
      }
    }
//Calcul de la moyenne pondérée
    return totalCoef > 0 ? totalPoints / totalCoef : 0.0;  //Calcul de la moyenne pondérée
  }
//Calculer la moyenne annuelle
  double calculateAnnualAverage(List<NoteDisplayItem> allNotes) {
    final s1 = calculateSemesterAverage(allNotes, "S1");  //Calcul de la moyenne du semestre 1
    final s2 = calculateSemesterAverage(allNotes, "S2");  //Calcul de la moyenne du semestre 2

    // Si on a des notes dans les deux semestres ou si on veut juste la moyenne simple des deux
    return (s1 + s2) / 2;  //Calcul de la moyenne simple des deux
  }
//Calculer la moyenne
  double calculateAverage(List<NoteDisplayItem> notesList, String currentFilter) {
    if (currentFilter == 'Tous') {
      return calculateAnnualAverage(notesList);
    } else {
      return calculateSemesterAverage(notesList, currentFilter);
    }
  }
}
