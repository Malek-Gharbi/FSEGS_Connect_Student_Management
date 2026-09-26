class EtudiantMatiere {
  int? id;
  String etudiantId;
  String matiereId;
  double noteControle;
  double noteSynthese;
  int absences;
  int presences;

  EtudiantMatiere({
    this.id,
    required this.etudiantId,
    required this.matiereId,
    required this.noteControle,
    required this.noteSynthese,
    required this.absences,
    required this.presences,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'etudiant_id': etudiantId,
      'matiere_id': matiereId,
      'note_controle': noteControle,
      'note_synthese': noteSynthese,
      'absences': absences,
      'presences': presences,
    };
  }

  factory EtudiantMatiere.fromMap(Map<String, dynamic> map) {
    return EtudiantMatiere(
      id: map['id'],
      etudiantId: map['etudiant_id'].toString(),
      matiereId: map['matiere_id'].toString(),
      noteControle: (map['note_controle'] as num?)?.toDouble() ?? 0.0,
      noteSynthese: (map['note_synthese'] as num?)?.toDouble() ?? 0.0,
      absences: (map['absences'] as int?) ?? 0,
      presences: (map['presences'] as int?) ?? 0,
    );
  }

  /// Calcul de la moyenne (exemple 30% / 70%)
  double get moyenne => (noteControle * 0.3) + (noteSynthese * 0.7);
}
