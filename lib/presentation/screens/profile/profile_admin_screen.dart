import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/firebase_service.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../data/models/user_model.dart';
import '../../widgets/avatar_picker.dart';

class ProfileAdminScreen extends StatefulWidget {
  const ProfileAdminScreen({super.key});

  @override
  State<ProfileAdminScreen> createState() => _ProfileAdminScreenState();
}

class _ProfileAdminScreenState extends State<ProfileAdminScreen> {
  int _totalUsers = 0;
  int _totalArticles = 0;
  int _totalAppointments = 0;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    // TODO: Реализовать загрузку статистики для админа
    setState(() {
      _totalUsers = 0;
      _totalArticles = 0;
      _totalAppointments = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<FirebaseService>().currentUser;
    final localizations = AppLocalizations.of(context) ?? AppLocalizations(const Locale('ru'));
    
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
                // Информация об админе
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
                          '${localizations.translate('role') ?? 'Роль'}:',
                          localizations.translate('admin') ?? 'Администратор',
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Статистика системы
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          localizations.translate('system_statistics') ?? 'Статистика системы',
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
                              icon: Icons.people,
                              title: localizations.translate('total_users') ?? 'Всего пользователей',
                              value: _totalUsers.toString(),
                              color: Colors.blue,
                            ),
                            _buildStatCard(
                              icon: Icons.article,
                              title: localizations.translate('total_articles') ?? 'Всего статей',
                              value: _totalArticles.toString(),
                              color: Colors.green,
                            ),
                            _buildStatCard(
                              icon: Icons.event,
                              title: localizations.translate('total_appointments') ?? 'Всего записей',
                              value: _totalAppointments.toString(),
                              color: Colors.purple,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Управление пользователями
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(Icons.people, color: Theme.of(context).primaryColor),
                        title: Text(localizations.translate('manage_users') ?? 'Управление пользователями'),
                        subtitle: Text(localizations.translate('view_all_users') ?? 'Просмотр и редактирование пользователей'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          _showUsersManagementDialog(context);
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: Icon(Icons.article, color: Theme.of(context).primaryColor),
                        title: Text(localizations.translate('manage_articles') ?? 'Управление статьями'),
                        subtitle: Text(localizations.translate('view_all_articles') ?? 'Просмотр всех статей'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          _showArticlesManagementDialog(context);
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: Icon(Icons.event, color: Theme.of(context).primaryColor),
                        title: Text(localizations.translate('manage_appointments') ?? 'Управление записями'),
                        subtitle: Text(localizations.translate('view_all_appointments') ?? 'Просмотр всех записей'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          _showAppointmentsManagementDialog(context);
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: Icon(Icons.assessment, color: Theme.of(context).primaryColor),
                        title: Text(localizations.translate('reports') ?? 'Отчёты'),
                        subtitle: Text(localizations.translate('view_reports') ?? 'Просмотр статистики и отчётов'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          _showReportsDialog(context);
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: Icon(Icons.settings, color: Theme.of(context).primaryColor),
                        title: Text(localizations.translate('system_settings') ?? 'Системные настройки'),
                        subtitle: Text(localizations.translate('app_settings') ?? 'Настройки приложения'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          _showSystemSettingsDialog(context);
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
                      localizations.translate('logout') ?? 'Выход',
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

  void _showUsersManagementDialog(BuildContext context) {
    final localizations = AppLocalizations.of(context) ?? AppLocalizations(const Locale('ru'));
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
            Text(localizations.translate('manage_users') ?? 'Управление пользователями'),
          ],
        ),
        content: Text(localizations.translate('users_management_desc') ?? 'Функционал управления пользователями будет реализован в следующей версии. Здесь вы сможете просматривать, редактировать и удалять пользователей, изменять их роли.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(localizations.translate('close') ?? 'Закрыть'),
          ),
        ],
      ),
    );
  }

  void _showArticlesManagementDialog(BuildContext context) {
    final localizations = AppLocalizations.of(context) ?? AppLocalizations(const Locale('ru'));
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.article, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            Text(localizations.translate('manage_articles') ?? 'Управление статьями'),
          ],
        ),
        content: Text(localizations.translate('articles_management_desc') ?? 'Функционал управления статьями будет реализован в следующей версии. Здесь вы сможете просматривать все статьи, публиковать, редактировать и удалять их.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(localizations.translate('close') ?? 'Закрыть'),
          ),
        ],
      ),
    );
  }

  void _showAppointmentsManagementDialog(BuildContext context) {
    final localizations = AppLocalizations.of(context) ?? AppLocalizations(const Locale('ru'));
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.event, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            Text(localizations.translate('manage_appointments') ?? 'Управление записями'),
          ],
        ),
        content: Text(localizations.translate('appointments_management_desc') ?? 'Функционал управления записями будет реализован в следующей версии. Здесь вы сможете просматривать все записи, отменять их и управлять расписанием.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(localizations.translate('close') ?? 'Закрыть'),
          ),
        ],
      ),
    );
  }

  void _showReportsDialog(BuildContext context) {
    final localizations = AppLocalizations.of(context) ?? AppLocalizations(const Locale('ru'));
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.assessment, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            Text(localizations.translate('reports') ?? 'Отчёты'),
          ],
        ),
        content: Text(localizations.translate('reports_desc') ?? 'Функционал отчётов будет реализован в следующей версии. Здесь вы сможете просматривать статистику использования приложения, экспортировать данные и генерировать отчёты.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(localizations.translate('close') ?? 'Закрыть'),
          ),
        ],
      ),
    );
  }

  void _showSystemSettingsDialog(BuildContext context) {
    final localizations = AppLocalizations.of(context) ?? AppLocalizations(const Locale('ru'));
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.settings, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            Text(localizations.translate('system_settings') ?? 'Системные настройки'),
          ],
        ),
        content: Text(localizations.translate('system_settings_desc') ?? 'Функционал системных настроек будет реализован в следующей версии. Здесь вы сможете настраивать параметры приложения, управлять уведомлениями и конфигурацией системы.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(localizations.translate('close') ?? 'Закрыть'),
          ),
        ],
      ),
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
            Text(localizations.translate('logout_title') ?? 'Выход из аккаунта'),
          ],
        ),
        content: Text(localizations.translate('logout_confirm') ?? 'Вы уверены, что хотите выйти из аккаунта?'),
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
            child: Text(localizations.translate('logout') ?? 'Выход'),
          ),
        ],
      ),
    );
  }
}
