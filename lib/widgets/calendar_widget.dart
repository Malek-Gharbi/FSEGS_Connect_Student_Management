

import 'package:flutter/material.dart';
import 'package:fsegs_connect/models/actualite.dart';
import 'package:fsegs_connect/models/calendar_note.dart';
import 'package:fsegs_connect/controllers/calendar_controller.dart';

class CalendarWidget extends StatefulWidget {
  final List<Actualite> actualites;

  const CalendarWidget({super.key, required this.actualites});

  @override
  State<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  DateTime _currentMonth = DateTime.now();  //Date actuelle
  Map<String, CalendarNote> _notes = {};  //Notes
  bool _isLoadingNotes = true;  //Chargement des notes
  final CalendarController _calendarController = CalendarController();  //Controller

  // Liste fixe des jours fériés nationaux en Tunisie
  final Map<String, String> _fixedHolidays = {
    '01-01': 'Nouvel An',
    '14-01': 'Fête de la Révolution',
    '20-03': 'Fête de l\'Indépendance',
    '09-04': 'Fête des Martyrs',
    '01-05': 'Fête du Travail',
    '25-07': 'Fête de la République',
    '13-08': 'Fête de la Femme',
    '15-10': 'Fête de l\'Évacuation',
  };

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    try {
      final notesList = await _calendarController.getAllNotes();
      setState(() {
        _notes = {for (var note in notesList) note.date: note};
        _isLoadingNotes = false;
      });
    } catch (e) {
      debugPrint('Error loading notes: $e');
      setState(() => _isLoadingNotes = false);
    }
  }

  // Affiche une boîte de dialogue pour consulter ou ajouter une note sur un jour spécifique
  void _showNoteDialog(DateTime date) async {
    final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final holidayKey = '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}';
    final holidayName = _fixedHolidays[holidayKey];
    final existingNote = _notes[dateStr];
    final controller = TextEditingController(text: existingNote?.note ?? '');
//Affiche une boîte de dialogue pour consulter ou ajouter une note sur un jour spécifique
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${date.day}/${date.month}/${date.year}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1D9BB1),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.grey),
                  ),
                ],
              ),
              if (holidayName != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.red.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.celebration, color: Colors.red, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Jour Férié : $holidayName',
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),
              const Text(
                'Remarques & Notes',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF10537F),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Écrivez vos remarques ici...',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  filled: true,
                  fillColor: const Color(0xFFF6FAFF),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  if (existingNote != null)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          await _calendarController.deleteNote(dateStr);
                          await _loadNotes();
                          if (mounted) Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Supprimer'),
                      ),
                    ),
                  if (existingNote != null) const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        await _calendarController.addOrUpdateNote(dateStr, controller.text);
                        await _loadNotes();
                        if (mounted) Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(  //Style du bouton
                        backgroundColor: const Color(0xFF1D9BB1),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: const Text('Enregistrer'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final monthNames = [
      'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
      'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
    ];

    final firstDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    int firstDayIndex = firstDayOfMonth.weekday == 7 ? 0 : firstDayOfMonth.weekday;
    final daysInMonth = lastDayOfMonth.day;

    List<DateTime> calendarDateTimes = [];
    final prevMonthLastDay = DateTime(_currentMonth.year, _currentMonth.month, 0);
    for (int i = firstDayIndex - 1; i >= 0; i--) {
      calendarDateTimes.add(DateTime(prevMonthLastDay.year, prevMonthLastDay.month, prevMonthLastDay.day - i));
    }
    for (int i = 1; i <= daysInMonth; i++) {
      calendarDateTimes.add(DateTime(_currentMonth.year, _currentMonth.month, i));
    }
    int remainingDays = 42 - calendarDateTimes.length;
    for (int i = 1; i <= remainingDays; i++) {
      final nextMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
      calendarDateTimes.add(DateTime(nextMonth.year, nextMonth.month, i));
    }
//Retourne le widget de la page de calendrier
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${monthNames[_currentMonth.month - 1]} ${_currentMonth.year}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF10537F),
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: () => setState(() => _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1)),  //Retourne au mois précédent
                    color: const Color(0xFF10537F),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: () => setState(() => _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1)),
                    color: const Color(0xFF10537F),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: ['Dim', 'Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam']
                .map((day) => Expanded(
                      child: Text(
                        day,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF10537F),
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 15),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
            ),
            itemCount: 42,
            itemBuilder: (context, index) {
              final date = calendarDateTimes[index];
              final isCurrentMonth = date.month == _currentMonth.month;
              return _buildDayCell(date, isCurrentMonth);
            },
          ),
        ],
      ),
    );
  }

  // Construit une cellule individuelle pour un jour du calendrier
  Widget _buildDayCell(DateTime date, bool isCurrentMonth) {
    final dateKey = '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}';
    final fullDateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    
    final holidayName = _fixedHolidays[dateKey];
    final hasActualite = widget.actualites.any((a) => 
      a.datePublication.year == date.year && 
      a.datePublication.month == date.month && 
      a.datePublication.day == date.day);
    final hasNote = _notes.containsKey(fullDateKey);
    final isToday = date.year == DateTime.now().year && date.month == DateTime.now().month && date.day == DateTime.now().day;

    return GestureDetector(
      onTap: () => _showNoteDialog(date),
      child: Tooltip(
        message: holidayName ?? (hasNote ? _notes[fullDateKey]!.note : ''),
        child: Container(
          decoration: BoxDecoration(
            color: isToday ? const Color(0xFF1D9BB1).withOpacity(0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: holidayName != null ? Border.all(color: Colors.red.withOpacity(0.5)) : null,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Text(
                '${date.day}',
                style: TextStyle(
                  fontSize: 14,
                  color: holidayName != null 
                    ? Colors.red 
                    : (isCurrentMonth ? const Color(0xFF10537F) : Colors.grey[400]),
                  fontWeight: (isToday || holidayName != null) ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              Positioned(
                bottom: 2,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (hasActualite)
                      Container(
                        width: 4,
                        height: 4,
                        decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                      ),
                    if (hasActualite && hasNote) const SizedBox(width: 2),
                    if (hasNote)
                      Container(
                        width: 4,
                        height: 4,
                        decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
