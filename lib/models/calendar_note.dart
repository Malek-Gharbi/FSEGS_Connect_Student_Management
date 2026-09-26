class CalendarNote {
  final int? id;
  final String date; // Format: YYYY-MM-DD
  final String note;

  CalendarNote({
    this.id,
    required this.date,
    required this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'date': date,
      'note': note,
    };
  }

  factory CalendarNote.fromMap(Map<String, dynamic> map) {
    return CalendarNote(
      id: map['id'] as int?,
      date: map['date'] as String,
      note: map['note'] as String,
    );
  }
}
