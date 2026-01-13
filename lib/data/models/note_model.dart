import 'package:cloud_firestore/cloud_firestore.dart';

class NoteModel {
  final String id;
  final String appointmentId;
  final String authorId;
  final String text;
  final DateTime createdAt;

  NoteModel({
    required this.id,
    required this.appointmentId,
    required this.authorId,
    required this.text,
    required this.createdAt,
  });

  factory NoteModel.fromFirestore(Map<String, dynamic> data, String id) {
    return NoteModel(
      id: id,
      appointmentId: data['appointmentId'] ?? '',
      authorId: data['authorId'] ?? '',
      text: data['text'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'appointmentId': appointmentId,
      'authorId': authorId,
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}