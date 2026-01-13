import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/firebase_service.dart';
import '../../../core/l10n/app_localizations.dart';
import './profile_student_screen.dart';
import './profile_psychologist_screen.dart';
import './profile_admin_screen.dart';
import '../settings/settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<FirebaseService>().currentUser;
    final firebaseService = context.watch<FirebaseService>();
    final localizations = AppLocalizations.of(context) ?? AppLocalizations(const Locale('ru'));
    
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.profile),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<String>(
        future: firebaseService.getUserRole(),
        builder: (context, snapshot) {
          final role = snapshot.data ?? 'student';
          final isPsychologist = role == 'psychologist';
          final isAdmin = role == 'admin';
          
          if (isAdmin) {
            return const ProfileAdminScreen();
          } else if (isPsychologist) {
            return const ProfilePsychologistScreen();
          } else {
            return const ProfileStudentScreen();
          }
        },
      ),
    );
  }
}