import 'package:cloud_firestore/cloud_firestore.dart';

class MessageContact {
  String? id;
  String userId;
  String objet;
  String body;
  String destinataire;
  DateTime dateEnvoi;
  String statut; // envoyé, lu, répondu

  MessageContact({
    this.id,
    required this.userId,
    required this.objet,
    required this.body,
    required this.destinataire,
    required this.dateEnvoi,
    this.statut = 'envoyé',
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'objet': objet,
      'body': body,
      'destinataire': destinataire,
      'dateEnvoi': dateEnvoi,
      'statut': statut,
    };
  }

  factory MessageContact.fromMap(String id, Map<String, dynamic> map) {
    return MessageContact(
      id: id,
      userId: map['userId'] ?? '',
      objet: map['objet'] ?? '',
      body: map['body'] ?? '',
      destinataire: map['destinataire'] ?? '',
      dateEnvoi: (map['dateEnvoi'] as Timestamp).toDate(),
      statut: map['statut'] ?? 'envoyé',
    );
  }
}
