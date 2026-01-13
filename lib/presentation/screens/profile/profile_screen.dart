import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/firebase_service.dart';
import './profile_student_screen.dart';
import './profile_psychologist_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<FirebaseService>().currentUser;
    final isPsychologist = user != null && user.email?.contains('psych') == true;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Профиль'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
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
                      const Text('Настройки'),
                    ],
                  ),
                  content: const Text('Функционал настроек будет реализован в следующей версии.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Закрыть'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: isPsychologist 
          ? const ProfilePsychologistScreen()
          : const ProfileStudentScreen(),
    );
  }
}