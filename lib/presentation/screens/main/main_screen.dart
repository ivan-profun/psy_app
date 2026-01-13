import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/firebase_service.dart';
import '../home/home_screen.dart';
import '../articles/articles_list_screen.dart';
import '../schedule/schedule_screen.dart';
import '../profile/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // Разные экраны для разных ролей
  final List<Widget> _studentScreens = [
    const HomeScreen(),
    const ArticlesListScreen(),
    const ScheduleScreen(), // Убрали параметр
    const ProfileScreen(),
  ];

  final List<Widget> _psychologistScreens = [
    const HomeScreen(),
    const ArticlesListScreen(showCreateButton: true),
    const ScheduleScreen(), // Убрали параметр
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final user = context.watch<FirebaseService>().currentUser;
    final firebaseService = context.watch<FirebaseService>();
    
    // Используем FutureBuilder для получения роли
    return FutureBuilder<String>(
      future: firebaseService.getUserRole(),
      builder: (context, snapshot) {
        final isPsychologist = snapshot.data == 'psychologist' || 
            snapshot.data == 'admin' ||
            (user?.email?.contains('psych') == true);
        
        final screens = isPsychologist ? _psychologistScreens : _studentScreens;
        
        return Scaffold(
          body: screens[_selectedIndex],
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _selectedIndex,
            onTap: (index) => setState(() => _selectedIndex = index),
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.home_outlined),
                activeIcon: const Icon(Icons.home),
                label: 'Главная',
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.article_outlined),
                activeIcon: const Icon(Icons.article),
                label: 'Статьи',
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.calendar_today_outlined),
                activeIcon: const Icon(Icons.calendar_today),
                label: 'Запись',
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.person_outline),
                activeIcon: const Icon(Icons.person),
                label: 'Профиль',
              ),
            ],
          ),
        );
      },
    );
  }
}