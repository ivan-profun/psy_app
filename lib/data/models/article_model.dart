import 'package:cloud_firestore/cloud_firestore.dart';

class ArticleModel {
  final String id;
  final String title;
  final String content;
  final String authorId;
  final bool isPublished;
  final DateTime createdAt;
  final DateTime updatedAt;

  ArticleModel({
    required this.id,
    required this.title,
    required this.content,
    required this.authorId,
    required this.isPublished,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ArticleModel.fromFirestore(Map<String, dynamic> data, String id) {
    return ArticleModel(
      id: id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      authorId: data['authorId'] ?? '',
      isPublished: data['isPublished'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }
}