import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/article_model.dart';
import 'article_create_edit_screen.dart';

class ArticleDetailScreen extends StatelessWidget {
  final ArticleModel article;
  final bool canEdit;

  const ArticleDetailScreen({
    super.key,
    required this.article,
    this.canEdit = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Статья'),
        actions: [
          if (canEdit)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ArticleCreateEditScreen(
                      article: article,
                    ),
                  ),
                );
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              article.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16),
                const SizedBox(width: 8),
                Text(
                  'Создано: ${DateFormat('dd.MM.yyyy HH:mm').format(article.createdAt)}',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            if (article.updatedAt != article.createdAt) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.edit, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Обновлено: ${DateFormat('dd.MM.yyyy HH:mm').format(article.updatedAt)}',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
            if (!article.isPublished) ...[
              const SizedBox(height: 8),
              Chip(
                label: const Text('Черновик'),
                backgroundColor: Colors.orange.withOpacity(0.2),
              ),
            ],
            
            const Divider(height: 32),

            Text(
              article.content,
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Назад к списку статей'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
