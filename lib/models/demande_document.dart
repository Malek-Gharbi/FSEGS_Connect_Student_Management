import 'package:cloud_firestore/cloud_firestore.dart';

class DemandeDocument {
  String? id;
  String userId;
  String nom;
  String prenom;
  String cin;
  String email;
  String groupe;
  String telephone;
  String typeDocument;
  DateTime dateDemande;
  String statut; // envoyé, lu, accepté, refusé

  DemandeDocument({
    this.id,
    required this.userId,
    required this.nom,
    required this.prenom,
    required this.cin,
    required this.email,
    required this.groupe,
    required this.telephone,
    required this.typeDocument,
    required this.dateDemande,
    this.statut = 'envoyé',
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'nom': nom,
      'prenom': prenom,
      'cin': cin,
      'email': email,
      'groupe': groupe,
      'telephone': telephone,
      'typeDocument': typeDocument,
      'dateDemande': dateDemande,
      'statut': statut,
    };
  }

  factory DemandeDocument.fromMap(String id, Map<String, dynamic> map) {
    return DemandeDocument(
      id: id,
      userId: map['userId'] ?? '',
      nom: map['nom'] ?? '',
      prenom: map['prenom'] ?? '',
      cin: map['cin'] ?? '',
      email: map['email'] ?? '',
      groupe: map['groupe'] ?? '',
      telephone: map['telephone'] ?? '',
      typeDocument: map['typeDocument'] ?? '',
      dateDemande: (map['dateDemande'] as Timestamp).toDate(),
      statut: map['statut'] ?? 'envoyé',
    );
  }
}
