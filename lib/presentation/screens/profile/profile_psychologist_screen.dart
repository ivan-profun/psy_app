import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/firebase_service.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/appointment_model.dart';
import '../articles/article_create_edit_screen.dart';
import '../schedule/schedule_screen.dart';
import '../../widgets/avatar_picker.dart';

class ProfilePsychologistScreen extends StatefulWidget {
  const ProfilePsychologistScreen({super.key});

  @override
  State<ProfilePsychologistScreen> createState() => _ProfilePsychologistScreenState();
}

class _ProfilePsychologistScreenState extends State<ProfilePsychologistScreen> {

  @override
  Widget build(BuildContext context) {
    final user = context.watch<FirebaseService>().currentUser;
    final userId = user?.uid;
    
    if (userId == null) {
      return const Center(child: Text('Пользователь не авторизован'));
    }
    
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
                
                StreamBuilder<Map<String, int>>(
                  stream: context.read<FirebaseService>().getPsychologistArticlesCountStream(userId),
                  builder: (context, articlesSnapshot) {
                    final articlesCount = articlesSnapshot.data ?? {'total': 0, 'published': 0, 'draft': 0};
                    return Card(
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
                            Column(
                              children: [
                                _buildStatCard(
                                  icon: Icons.article,
                                  title: AppLocalizations.of(context)?.translate('total_articles') ?? 'Всего статей',
                                  value: articlesCount['total'].toString(),
                                  color: Colors.blue,
                                ),
                                const SizedBox(height: 12),
                                _buildStatCard(
                                  icon: Icons.public,
                                  title: AppLocalizations.of(context)?.translate('published_articles') ?? 'Опубликовано',
                                  value: articlesCount['published'].toString(),
                                  color: Colors.green,
                                ),
                                const SizedBox(height: 12),
                                _buildStatCard(
                                  icon: Icons.drafts,
                                  title: AppLocalizations.of(context)?.translate('draft_articles') ?? 'Черновики',
                                  value: articlesCount['draft'].toString(),
                                  color: Colors.orange,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 16),
                
                StreamBuilder<Map<String, int>>(
                  stream: context.read<FirebaseService>().getPsychologistSessionsCountStream(userId),
                  builder: (context, sessionsSnapshot) {
                    final sessionsCount = sessionsSnapshot.data ?? {'total': 0, 'upcoming': 0, 'completed': 0};
                    return Card(
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
                            Column(
                              children: [
                                _buildStatCard(
                                  icon: Icons.event,
                                  title: AppLocalizations.of(context)?.translate('total_sessions') ?? 'Всего сессий',
                                  value: sessionsCount['total'].toString(),
                                  color: Colors.purple,
                                ),
                                const SizedBox(height: 12),
                                _buildStatCard(
                                  icon: Icons.event_available,
                                  title: AppLocalizations.of(context)?.translate('upcoming_sessions') ?? 'Предстоящие',
                                  value: sessionsCount['upcoming'].toString(),
                                  color: Colors.blue,
                                ),
                                const SizedBox(height: 12),
                                _buildStatCard(
                                  icon: Icons.check_circle,
                                  title: AppLocalizations.of(context)?.translate('completed_sessions_count') ?? 'Завершённые',
                                  value: sessionsCount['completed'].toString(),
                                  color: Colors.green,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 16),
                
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ScheduleScreen(),
                            ),
                          );
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
            Expanded(
              child: Text(
                localizations.translate('logout_title'),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
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
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
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
            const Expanded(
              child: Text(
                'Мои клиенты',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
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
