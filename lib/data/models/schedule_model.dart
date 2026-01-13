import 'package:cloud_firestore/cloud_firestore.dart';

class ScheduleModel {
  final String id;
  final String psychologistId;
  final DateTime date;
  final String startTime;
  final String endTime;
  final bool isAvailable;
  final DateTime createdAt;

  ScheduleModel({
    required this.id,
    required this.psychologistId,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.isAvailable,
    required this.createdAt,
  });

  factory ScheduleModel.fromFirestore(Map<String, dynamic> data, String id) {
    return ScheduleModel(
      id: id,
      psychologistId: data['psychologistId'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      startTime: data['startTime'] ?? '',
      endTime: data['endTime'] ?? '',
      isAvailable: data['isAvailable'] ?? true,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'psychologistId': psychologistId,
      'date': Timestamp.fromDate(date),
      'startTime': startTime,
      'endTime': endTime,
      'isAvailable': isAvailable,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}