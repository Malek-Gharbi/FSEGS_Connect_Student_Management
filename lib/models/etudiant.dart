class Etudiant {
  String id; // Document ID Firestore
  String matricule;
  String nom;
  String prenom;
  String email;
  String dateNaissance;
  String telephone;
  String? photoProfil;
  String specialite;
  String niveauEtude;
  DateTime? createdAt;

  Etudiant({
    required this.id,
    required this.matricule,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.dateNaissance,
    required this.telephone,
    this.photoProfil,
    required this.specialite,
    required this.niveauEtude,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'matricule': matricule,
      'nom': nom,
      'prenom': prenom,
      'email': email,
      'dateNaissance': dateNaissance,
      'telephone': telephone,
      'photoProfil': photoProfil,
      'specialite': specialite,
      'niveauEtude': niveauEtude,
      'createdAt': createdAt,
    };
  }

  factory Etudiant.fromMap(String id, Map<String, dynamic> map) {
    return Etudiant(
      id: id,
      matricule: map['matricule'],
      nom: map['nom'],
      prenom: map['prenom'],
      email: map['email'],
      dateNaissance: map['dateNaissance'],
      telephone: map['telephone'],
      photoProfil: map['photoProfil'],
      specialite: map['specialite'],
      niveauEtude: map['niveauEtude'],
      createdAt: map['createdAt']?.toDate(),
    );
  }
}
