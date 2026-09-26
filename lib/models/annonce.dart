class Annonce {
  String id;
  String titre;
  String description;
  DateTime datePublication;

  Annonce({
    required this.id,
    required this.titre,
    required this.description,
    required this.datePublication,
  });

  Map<String, dynamic> toMap() {
    return {
      'titre': titre,
      'description': description,
      'datePublication': datePublication,
    };
  }

  factory Annonce.fromMap(String id, Map<String, dynamic> map) {
    return Annonce(
      id: id,
      titre: map['titre'] ?? '',
      description: map['description'] ?? '',
      datePublication: (map['date_publication'] != null) 
          ? map['date_publication'].toDate() 
          : DateTime.now(),
    );
  }
}
