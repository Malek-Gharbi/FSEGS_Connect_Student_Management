class Matiere {
  String id;
  String ref;
  String nom;
  String regime;
  double coefficient;
  String? semestre; 

  Matiere({
    required this.id,
    required this.ref,
    required this.nom,
    required this.regime,
    required this.coefficient,
    this.semestre,
    });

  Map<String, dynamic> toMap() {
    return {
      'ref': ref,
      'nom': nom,
      'regime': regime,
      'coefficient': coefficient,
      'semestre': semestre,
    };
  }

  factory Matiere.fromMap(String id, Map<String, dynamic> map) {
    return Matiere(
      id: id,
      ref: map['ref'].toString(),
      nom: map['nom'].toString(),
      regime: map['regime'].toString(),
      coefficient: (map['coefficient'] as num).toDouble(),
      semestre: map['semestre']?.toString()
    );
  }
}
