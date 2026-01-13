import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/firebase_service.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../data/models/user_model.dart';
import '../articles/article_create_edit_screen.dart';
import '../../widgets/avatar_picker.dart';

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
                        Row(
                          children: [
                            AvatarPicker(
                              currentAvatarUrl: userData?.avatarUrl,
                              size: 80,
                              canEdit: true,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    userData?.name ?? 'Не указано',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    user?.email ?? 'Не указан',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          '${(AppLocalizations.of(context) ?? AppLocalizations(const Locale('ru'))).translate('role') ?? 'Роль'}:',
                          AppLocalizations.of(context)?.translate('psychologist') ?? 'Психолог',
                        ),
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
                        Text(
                          AppLocalizations.of(context)?.translate('articles_statistics') ?? 'Статистика статей',
                          style: const TextStyle(
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
                              title: AppLocalizations.of(context)?.translate('total_articles') ?? 'Всего статей',
                              value: _articlesCount['total'].toString(),
                              color: Colors.blue,
                            ),
                            _buildStatCard(
                              icon: Icons.public,
                              title: AppLocalizations.of(context)?.translate('published_articles') ?? 'Опубликовано',
                              value: _articlesCount['published'].toString(),
                              color: Colors.green,
                            ),
                            _buildStatCard(
                              icon: Icons.drafts,
                              title: AppLocalizations.of(context)?.translate('draft_articles') ?? 'Черновики',
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
                        Text(
                          AppLocalizations.of(context)?.translate('sessions_statistics') ?? 'Статистика сессий',
                          style: const TextStyle(
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
                              title: AppLocalizations.of(context)?.translate('total_sessions') ?? 'Всего сессий',
                              value: _sessionsCount['total'].toString(),
                              color: Colors.purple,
                            ),
                            _buildStatCard(
                              icon: Icons.event_available,
                              title: AppLocalizations.of(context)?.translate('upcoming_sessions') ?? 'Предстоящие',
                              value: _sessionsCount['upcoming'].toString(),
                              color: Colors.blue,
                            ),
                            _buildStatCard(
                              icon: Icons.check_circle,
                              title: AppLocalizations.of(context)?.translate('completed_sessions_count') ?? 'Завершённые',
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
                        title: Text(AppLocalizations.of(context)?.translate('create_article') ?? 'Написать статью'),
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
                        title: Text(AppLocalizations.of(context)?.translate('schedule_management') ?? 'Управление расписанием'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          _showScheduleInfoDialog(context);
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.people, color: Theme.of(context).primaryColor),
                        title: Text(AppLocalizations.of(context)?.translate('my_clients') ?? 'Мои клиенты'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          _showClientsDialog(context);
                        },
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Выход
                Card(
                  child: ListTile(
                    leading: Icon(Icons.logout, color: Colors.red),
                    title: Text(
                      AppLocalizations.of(context)?.translate('logout') ?? 'Выход',
                      style: const TextStyle(color: Colors.red),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => _showLogoutDialog(context),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final localizations = AppLocalizations.of(context) ?? AppLocalizations(const Locale('ru'));
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            const Icon(Icons.logout, color: Colors.red),
            const SizedBox(width: 8),
            Text(localizations.translate('logout_title')),
          ],
        ),
        content: Text(localizations.translate('logout_confirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(localizations.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await context.read<FirebaseService>().signOut();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(localizations.translate('logout')),
          ),
        ],
      ),
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