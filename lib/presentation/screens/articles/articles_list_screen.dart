import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/services/firebase_service.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../data/models/article_model.dart';
import 'article_detail_screen.dart';
import 'article_create_edit_screen.dart';

class ArticlesListScreen extends StatelessWidget {
  final bool showCreateButton;

  const ArticlesListScreen({
    super.key,
    this.showCreateButton = false,
  });

  @override
  Widget build(BuildContext context) {
    final user = context.watch<FirebaseService>().currentUser;
    final isPsychologist = user != null && user.email?.contains('psych') == true;
    final localizations = AppLocalizations.of(context) ?? AppLocalizations(const Locale('ru'));

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.articles),
      ),
      body: StreamBuilder<List<ArticleModel>>(
        stream: isPsychologist && showCreateButton
            ? context.read<FirebaseService>().getPsychologistArticlesStream(user.uid)
            : context.read<FirebaseService>().getArticlesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('${localizations.error}: ${snapshot.error}'));
          }

          final articles = snapshot.data ?? [];

          if (articles.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.article, size: 60, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    isPsychologist && showCreateButton
                        ? localizations.translate('no_articles') ?? 'У вас нет статей'
                        : localizations.noArticles,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: articles.length,
            itemBuilder: (context, index) {
              final article = articles[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ArticleDetailScreen(
                          article: article,
                          canEdit: isPsychologist && showCreateButton,
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                article.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isPsychologist && showCreateButton && !article.isPublished)
                              Chip(
                                label: Text(localizations.translate('draft') ?? 'Черновик'),
                                backgroundColor: Colors.orange,
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          article.content.length > 150
                              ? '${article.content.substring(0, 150)}...'
                              : article.content,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              DateFormat('dd.MM.yyyy').format(article.createdAt),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            if (article.updatedAt != article.createdAt) ...[
                              const SizedBox(width: 8),
                              const Icon(Icons.edit, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                'ред. ${DateFormat('dd.MM.yyyy').format(article.updatedAt)}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                            const Spacer(),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ArticleDetailScreen(
                                      article: article,
                                      canEdit: isPsychologist && showCreateButton,
                                    ),
                                  ),
                                );
                              },
                              child: Text(localizations.translate('read_more') ?? 'Читать →'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: (isPsychologist && showCreateButton)
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ArticleCreateEditScreen(),
                  ),
                );
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}