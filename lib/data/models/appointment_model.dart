import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentModel {
  final String id;
  final String studentId;
  final String psychologistId;
  final DateTime datetime;
  final String status;
  final String comment;
  final DateTime createdAt;

  AppointmentModel({
    required this.id,
    required this.studentId,
    required this.psychologistId,
    required this.datetime,
    required this.status,
    required this.comment,
    required this.createdAt,
  });

  factory AppointmentModel.fromFirestore(Map<String, dynamic> data, String id) {
    return AppointmentModel(
      id: id,
      studentId: data['studentId'] ?? '',
      psychologistId: data['psychologistId'] ?? '',
      datetime: (data['datetime'] as Timestamp?)?.toDate() ?? 
                (data['dateTime'] as Timestamp?)?.toDate() ?? 
                DateTime.now(),
      status: data['status'] ?? 'pending',
      comment: data['comment'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'studentId': studentId,
      'psychologistId': psychologistId,
      'datetime': Timestamp.fromDate(datetime),
      'status': status,
      'comment': comment,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}