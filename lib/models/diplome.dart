class Diplome {
  final int? id;
  final String titre;
  final String etablissement;
  final DateTime dateObtention;
  final String? pdfPath; // Path sur le device local

  Diplome({
    this.id,
    required this.titre,
    required this.etablissement,
    required this.dateObtention,
    this.pdfPath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titre': titre,
      'etablissement': etablissement,
      'date_obtention': dateObtention.toIso8601String(),
      'pdf_path': pdfPath,
    };
  }

  factory Diplome.fromMap(Map<String, dynamic> map) {
    return Diplome(
      id: map['id'],
      titre: map['titre'],
      etablissement: map['etablissement'],
      dateObtention: DateTime.parse(map['date_obtention']),
      pdfPath: map['pdf_path'],
    );
  }
}
