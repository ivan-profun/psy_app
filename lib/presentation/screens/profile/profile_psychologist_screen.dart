import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/firebase_service.dart';
import '../../../data/models/user_model.dart';
import '../articles/article_create_edit_screen.dart';

class ProfilePsychologistScreen extends StatefulWidget {
  const ProfilePsychologistScreen({super.key});

  @override
  State<ProfilePsychologistScreen> createState() => _ProfilePsychologistScreenState();
}

class _ProfilePsychologistScreenState extends State<ProfilePsychologistScreen> {
  Map<String, int> _articlesCount = {'total': 0, 'published': 0, 'draft': 0};
  Map<String, int> _sessionsCount = {'total': 0, 'upcoming': 0, 'completed': 0};

  @override
  void initState() {
    super.initState();
    _loadCounts();
  }

  Future<void> _loadCounts() async {
    final userId = context.read<FirebaseService>().currentUser?.uid;
    if (userId != null) {
      final articles = await context.read<FirebaseService>().getPsychologistArticlesCount(userId);
      final sessions = await context.read<FirebaseService>().getPsychologistSessionsCount(userId);
      
      setState(() {
        _articlesCount = articles;
        _sessionsCount = sessions;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<FirebaseService>().currentUser;
    
    return StreamBuilder<UserModel?>(
      stream: context.read<FirebaseService>().getCurrentUserStream(),
      builder: (context, snapshot) {
        final userData = snapshot.data;
        
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Информация о психологе
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Информация о психологе',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow('Имя:', userData?.name ?? 'Не указано'),
                        _buildInfoRow('Email:', user?.email ?? 'Не указан'),
                        _buildInfoRow('Роль:', 'Психолог'),
                        // УБРАЛИ ID
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Статистика статей
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Статистика статей',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            _buildStatCard(
                              icon: Icons.article,
                              title: 'Всего статей',
                              value: _articlesCount['total'].toString(),
                              color: Colors.blue,
                            ),
                            _buildStatCard(
                              icon: Icons.public,
                              title: 'Опубликовано',
                              value: _articlesCount['published'].toString(),
                              color: Colors.green,
                            ),
                            _buildStatCard(
                              icon: Icons.drafts,
                              title: 'Черновики',
                              value: _articlesCount['draft'].toString(),
                              color: Colors.orange,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Статистика сессий
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Статистика сессий',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            _buildStatCard(
                              icon: Icons.event,
                              title: 'Всего сессий',
                              value: _sessionsCount['total'].toString(),
                              color: Colors.purple,
                            ),
                            _buildStatCard(
                              icon: Icons.event_available,
                              title: 'Предстоящие',
                              value: _sessionsCount['upcoming'].toString(),
                              color: Colors.blue,
                            ),
                            _buildStatCard(
                              icon: Icons.check_circle,
                              title: 'Завершённые',
                              value: _sessionsCount['completed'].toString(),
                              color: Colors.green,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Быстрые действия
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(Icons.add_circle, color: Theme.of(context).primaryColor),
                        title: const Text('Написать статью'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ArticleCreateEditScreen(),
                            ),
                          );
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.schedule, color: Theme.of(context).primaryColor),
                        title: const Text('Управление расписанием'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          // Уже на странице расписания, можно показать диалог
                          _showScheduleInfoDialog(context);
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.people, color: Theme.of(context).primaryColor),
                        title: const Text('Мои клиенты'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          _showClientsDialog(context);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      width: 150,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _showScheduleInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.schedule, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            const Text('Управление расписанием'),
          ],
        ),
        content: const Text('Перейдите на вкладку "Запись" для управления своим расписанием.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  void _showClientsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.people, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            const Text('Мои клиенты'),
          ],
        ),
        content: const Text('Функционал просмотра клиентов будет реализован в следующей версии.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }
}