import 'package:fsegs_connect/models/calendar_note.dart';
import 'package:fsegs_connect/services/database_service.dart';

class CalendarController {
  //ici on a utilisé le service de base de données (SQLite)
  final DatabaseService _dbService = DatabaseService.instance;

//récupérer toutes les notes
  Future<List<CalendarNote>> getAllNotes() async {
    return await _dbService.readAllCalendarNotes();
  }

//récupérer une note par date
  Future<CalendarNote?> getNoteByDate(String date) async {
    return await _dbService.readCalendarNoteByDate(date);
  }
//ajouter ou mettre à jour une note
  Future<void> addOrUpdateNote(String date, String noteText) async {
    final existingNote = await getNoteByDate(date);
    if (noteText.isEmpty) {
      if (existingNote != null) {
        await _dbService.deleteCalendarNote(date);
      }
      return;
    }
//faire un objet note
    final note = CalendarNote(date: date, note: noteText);
    if (existingNote != null) {
      await _dbService.updateCalendarNote(note);  //cas de mise à jour
    } else {
      await _dbService.createCalendarNote(note); //cas d'ajout
    }
  }
//supprimer une note
  Future<void> deleteNote(String date) async {
    await _dbService.deleteCalendarNote(date); //supprimer une note
  }
}
