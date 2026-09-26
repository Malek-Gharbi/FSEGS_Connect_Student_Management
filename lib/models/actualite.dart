class Actualite {
  String id;
  String titre;
  String description;
  DateTime datePublication;

  Actualite({
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

  factory Actualite.fromMap(String id, Map<String, dynamic> map) {
    DateTime datePub;
    
    // Gérer différents formats de date depuis Firestore
    try {
      if (map['datePublication'] == null) {
        datePub = DateTime.now();
      } else {
        final dateValue = map['datePublication'];
        
        // Si c'est un Timestamp Firestore (a une méthode toDate)
        if (dateValue != null && dateValue.runtimeType.toString().contains('Timestamp')) {
          datePub = (dateValue as dynamic).toDate() as DateTime;
        } 
        // Si c'est déjà un DateTime
        else if (dateValue is DateTime) {
          datePub = dateValue;
        }
        // Si c'est un String, essayer de parser
        else if (dateValue is String) {
          datePub = DateTime.parse(dateValue);
        }
        // Si c'est un Timestamp Firestore (via méthode toDate)
        else {
          try {
            datePub = (dateValue as dynamic).toDate();
          } catch (e) {
            datePub = DateTime.now();
          }
        }
      }
    } catch (e) {
      // En cas d'erreur, utiliser la date actuelle
      datePub = DateTime.now();
    }

    return Actualite(
      id: id,
      titre: map['titre']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      datePublication: datePub,
    );
  }
}
