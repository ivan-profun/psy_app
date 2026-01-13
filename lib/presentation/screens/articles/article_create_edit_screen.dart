import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/firebase_service.dart';
import '../../../data/models/article_model.dart';

class ArticleCreateEditScreen extends StatefulWidget {
  final ArticleModel? article;

  const ArticleCreateEditScreen({super.key, this.article});

  @override
  State<ArticleCreateEditScreen> createState() => _ArticleCreateEditScreenState();
}

class _ArticleCreateEditScreenState extends State<ArticleCreateEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  bool _isPublished = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.article != null) {
      _titleController.text = widget.article!.title;
      _contentController.text = widget.article!.content;
      _isPublished = widget.article!.isPublished;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.article == null ? 'Новая статья' : 'Редактирование статьи'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveArticle,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Заголовок статьи',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Введите заголовок';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _contentController,
                        decoration: const InputDecoration(
                          labelText: 'Содержание статьи',
                          border: OutlineInputBorder(),
                          alignLabelWithHint: true,
                        ),
                        maxLines: null,
                        expands: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Введите содержание статьи';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Опубликовать сразу'),
                      subtitle: const Text('Если выключено, статья сохранится как черновик'),
                      value: _isPublished,
                      onChanged: (value) => setState(() => _isPublished = value),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _saveArticle,
                        child: const Text('Сохранить статью'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> _saveArticle() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final firebaseService = context.read<FirebaseService>();
      await firebaseService.saveArticle(
        articleId: widget.article?.id,
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        isPublished: _isPublished,
      );

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.article == null
                ? 'Статья успешно создана'
                : 'Статья успешно обновлена',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}