import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/firebase_service.dart';
import '../../../data/models/user_model.dart';

class ProfileStudentScreen extends StatefulWidget {
  const ProfileStudentScreen({super.key});

  @override
  State<ProfileStudentScreen> createState() => _ProfileStudentScreenState();
}

class _ProfileStudentScreenState extends State<ProfileStudentScreen> {
  int _completedSessions = 0;

  @override
  void initState() {
    super.initState();
    _loadCompletedSessions();
  }

  Future<void> _loadCompletedSessions() async {
    final userId = context.read<FirebaseService>().currentUser?.uid;
    if (userId != null) {
      final count = await context.read<FirebaseService>().getCompletedSessionsCount(userId);
      setState(() => _completedSessions = count);
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
                // Информация о студенте
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Личная информация',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow('Имя:', userData?.name ?? 'Не указано'),
                        _buildInfoRow('Email:', user?.email ?? 'Не указан'),
                        _buildInfoRow('Роль:', 'Студент'),
                        // УБРАЛИ ID: _buildInfoRow('ID:', user?.uid.substring(0, 8) ?? ''),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Статистика
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Статистика',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildStatCard(
                          icon: Icons.event_available,
                          title: 'Посещенных сессий',
                          value: _completedSessions.toString(),
                          color: Colors.green,
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Настройки
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(Icons.settings, color: Theme.of(context).primaryColor),
                        title: const Text('Настройки аккаунта'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          _showSettingsDialog(context);
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.notifications, color: Theme.of(context).primaryColor),
                        title: const Text('Уведомления'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          _showNotificationsDialog(context);
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.security, color: Theme.of(context).primaryColor),
                        title: const Text('Конфиденциальность'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          _showPrivacyDialog(context);
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
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
        ],
      ),
    );
  }

  void _showSettingsDialog(BuildContext context) {
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
            const Text('Настройки аккаунта'),
          ],
        ),
        content: const Text('Функционал настроек аккаунта будет реализован в следующей версии.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  void _showNotificationsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.notifications, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            const Text('Уведомления'),
          ],
        ),
        content: const Text('Функционал управления уведомлениями будет реализован в следующей версии.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.security, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            const Text('Конфиденциальность'),
          ],
        ),
        content: const Text('Все ваши данные защищены и хранятся в соответствии с политикой конфиденциальности.'),
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