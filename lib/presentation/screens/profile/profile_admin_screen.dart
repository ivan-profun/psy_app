import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
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
                
                StreamBuilder<Map<String, int>>(
                  stream: context.read<FirebaseService>().getSystemStatisticsStream(),
                  builder: (context, snapshot) {
                    final stats = snapshot.data ?? {'total_users': 0, 'total_articles': 0, 'total_appointments': 0};
                    return Card(
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
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final isWide = constraints.maxWidth > 400;
                                final children = [
                                  _buildStatCard(
                                    icon: Icons.people,
                                    title: localizations.translate('total_users') ?? 'Всего пользователей',
                                    value: stats['total_users'].toString(),
                                    color: Colors.blue,
                                  ),
                                  _buildStatCard(
                                    icon: Icons.article,
                                    title: localizations.translate('total_articles') ?? 'Всего статей',
                                    value: stats['total_articles'].toString(),
                                    color: Colors.green,
                                  ),
                                  _buildStatCard(
                                    icon: Icons.event,
                                    title: localizations.translate('total_appointments') ?? 'Всего записей',
                                    value: stats['total_appointments'].toString(),
                                    color: Colors.purple,
                                  ),
                                ];
                                
                                if (isWide) {
                                  return Wrap(
                                    spacing: 12,
                                    runSpacing: 12,
                                    children: children,
                                  );
                                } else {
                                  return Column(
                                    children: children.map((card) => Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: card,
                                    )).toList(),
                                  );
                                }
                              },
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
      constraints: const BoxConstraints(minWidth: 120, maxWidth: 200),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
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
    final firebaseService = context.read<FirebaseService>();
    final localizations = AppLocalizations.of(context) ?? AppLocalizations(const Locale('ru'));
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          width: double.maxFinite,
          constraints: const BoxConstraints(maxHeight: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.people, color: Theme.of(context).primaryColor),
                    const SizedBox(width: 8),
                    Text(
                      localizations.translate('manage_users') ?? 'Управление пользователями',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: StreamBuilder<List<UserModel>>(
                  stream: firebaseService.getAllUsersStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    
                    if (snapshot.hasError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text('${localizations.error}: ${snapshot.error}'),
                        ),
                      );
                    }
                    
                    final users = snapshot.data ?? [];
                    
                    if (users.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(localizations.translate('no_users') ?? 'Нет пользователей'),
                        ),
                      );
                    }
                    
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final user = users[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          child: ListTile(
                            leading: CircleAvatar(
                              child: Text(user.name.isNotEmpty ? user.name[0].toUpperCase() : '?'),
                            ),
                            title: Text(user.name),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(user.email),
                                Text(
                                  _getRoleText(user.role, localizations),
                                  style: TextStyle(
                                    color: _getRoleColor(user.role),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            trailing: PopupMenuButton(
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: 'student',
                                  child: Text(localizations.translate('student') ?? 'Студент'),
                                ),
                                PopupMenuItem(
                                  value: 'psychologist',
                                  child: Text(localizations.translate('psychologist') ?? 'Психолог'),
                                ),
                                PopupMenuItem(
                                  value: 'admin',
                                  child: Text(localizations.translate('admin') ?? 'Администратор'),
                                ),
                              ],
                              onSelected: (value) async {
                                try {
                                  await firebaseService.updateUserRole(user.id, value.toString());
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(localizations.translate('role_updated') ?? 'Роль обновлена'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('${localizations.error}: $e'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              },
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getRoleText(String role, AppLocalizations localizations) {
    switch (role) {
      case 'student':
        return localizations.translate('student') ?? 'Студент';
      case 'psychologist':
        return localizations.translate('psychologist') ?? 'Психолог';
      case 'admin':
        return localizations.translate('admin') ?? 'Администратор';
      default:
        return role;
    }
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'student':
        return Colors.blue;
      case 'psychologist':
        return Colors.green;
      case 'admin':
        return Colors.purple;
      default:
        return Colors.grey;
    }
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
            Expanded(
              child: Text(
                localizations.translate('manage_articles') ?? 'Управление статьями',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
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
            Expanded(
              child: Text(
                localizations.translate('manage_appointments') ?? 'Управление записями',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
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
    final firebaseService = context.read<FirebaseService>();
    final localizations = AppLocalizations.of(context) ?? AppLocalizations(const Locale('ru'));
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          width: double.maxFinite,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.assessment, color: Theme.of(context).primaryColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        localizations.translate('reports') ?? 'Отчёты',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: StreamBuilder<Map<String, int>>(
                  stream: firebaseService.getSystemStatisticsStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    
                    if (snapshot.hasError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text('${localizations.error}: ${snapshot.error}'),
                        ),
                      );
                    }
                    
                    final stats = snapshot.data ?? {'total_users': 0, 'total_articles': 0, 'total_appointments': 0};
                    
                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            localizations.translate('system_statistics') ?? 'Статистика системы',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          _buildReportCard(
                            icon: Icons.people,
                            title: localizations.translate('total_users') ?? 'Всего пользователей',
                            value: stats['total_users'].toString(),
                            color: Colors.blue,
                          ),
                          const SizedBox(height: 12),
                          _buildReportCard(
                            icon: Icons.article,
                            title: localizations.translate('total_articles') ?? 'Всего статей',
                            value: stats['total_articles'].toString(),
                            color: Colors.green,
                          ),
                          const SizedBox(height: 12),
                          _buildReportCard(
                            icon: Icons.event,
                            title: localizations.translate('total_appointments') ?? 'Всего записей',
                            value: stats['total_appointments'].toString(),
                            color: Colors.purple,
                          ),
                          const SizedBox(height: 24),
                          Text(
                            localizations.translate('report_date') ?? 'Дата отчёта',
                            style: const TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          Text(
                            DateFormat('dd.MM.yyyy HH:mm').format(DateTime.now()),
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(
          title,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
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
            Expanded(
              child: Text(
                localizations.translate('system_settings') ?? 'Системные настройки',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
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
            Expanded(
              child: Text(
                localizations.translate('logout_title') ?? 'Выход из аккаунта',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
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
