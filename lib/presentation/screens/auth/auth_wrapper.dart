import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './login_screen.dart';
import '../main/main_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          // Пользователь вошел, показываем главный экран с навигацией
          return const MainScreen();
        }

        // Пользователь не вошел, показываем экран входа
        return const LoginScreen();
      },
    );
  }
}