import 'package:cloud_firestore/cloud_firestore.dart';

class ScheduleSlot {
  final String id;
  final String psychologistId;
  final DateTime datetime;
  final bool isAvailable;
  final String? studentId;
  final DateTime createdAt;

  ScheduleSlot({
    required this.id,
    required this.psychologistId,
    required this.datetime,
    this.isAvailable = true,
    this.studentId,
    required this.createdAt,
  });

  factory ScheduleSlot.fromFirestore(Map<String, dynamic> data, String id) {
    return ScheduleSlot(
      id: id,
      psychologistId: data['psychologistId'] ?? '',
      datetime: (data['datetime'] as Timestamp?)?.toDate() ?? 
                (data['dateTime'] as Timestamp?)?.toDate() ?? 
                DateTime.now(),
      isAvailable: data['isAvailable'] ?? true,
      studentId: data['studentId'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'psychologistId': psychologistId,
      'datetime': Timestamp.fromDate(datetime),
      'isAvailable': isAvailable,
      'studentId': studentId,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  ScheduleSlot copyWith({
    bool? isAvailable,
    String? studentId,
  }) {
    return ScheduleSlot(
      id: id,
      psychologistId: psychologistId,
      datetime: datetime,
      isAvailable: isAvailable ?? this.isAvailable,
      studentId: studentId ?? this.studentId,
      createdAt: createdAt,
    );
  }
}