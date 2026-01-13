import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/services/firebase_service.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../data/models/article_model.dart';
import '../../../data/models/schedule_slot_model.dart';
import '../articles/articles_list_screen.dart';
import '../articles/article_detail_screen.dart';
import '../schedule/schedule_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    try {
      // Проверяем, авторизован ли пользователь
      final user = await Provider.of<FirebaseService>(context, listen: false).currentUser;
      if (user == null) {
        setState(() {
          _errorMessage = 'Требуется авторизация';
          _isLoading = false;
        });
        return;
      }
      
      setState(() {
        _errorMessage = null;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Ошибка проверки прав доступа: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 60, color: Colors.red),
              const SizedBox(height: 20),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _checkPermissions,
                child: const Text('Повторить'),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          // Заголовок и приветствие
          _buildHeader(context),
          
          // Информация о службе
          _buildServiceInfo(),
          
          // Свежие статьи
          _buildLatestArticles(context),
          
          // Ближайшие свободные слоты
          _buildAvailableSlots(context),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final user = context.watch<FirebaseService>().currentUser;
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context) ?? AppLocalizations(const Locale('ru'));
    
    // Безопасное извлечение имени пользователя
    String getUserName() {
      if (user == null) return localizations.translate('guest') ?? 'Гость';
      
      if (user.email != null && user.email!.isNotEmpty) {
        final email = user.email!;
        final username = email.split('@').first;
        return username;
      }
      
      if (user.displayName != null && user.displayName!.isNotEmpty) {
        return user.displayName!;
      }
      
      return localizations.translate('user') ?? 'Пользователь';
    }
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.secondary,
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.psychology,
                  size: 32,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${localizations.welcome},',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      getUserName(),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.favorite,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    localizations.translate('service_name') ?? 'Служба психологической помощи',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.95),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceInfo() {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context) ?? AppLocalizations(const Locale('ru'));
    
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.info_outline,
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  localizations.serviceInfo,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildInfoRow(Icons.access_time, '${localizations.workingHours}:', 'Пн-Пт: 9:00-18:00'),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.phone, '${localizations.phone}:', '+7 (XXX) XXX-XX-XX'),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.email, '${localizations.email}:', 'psych-help@university.edu'),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.location_on, '${localizations.address}:', 'ул. Университетская, д. 1, каб. 101'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.tertiary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.shield,
                    color: theme.colorScheme.tertiary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      localizations.confidentialHelp,
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 18,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLatestArticles(BuildContext context) {
    final firebaseService = context.read<FirebaseService>();
    final localizations = AppLocalizations.of(context) ?? AppLocalizations(const Locale('ru'));
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.article,
                      color: Theme.of(context).colorScheme.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        localizations.latestArticles,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ArticlesListScreen(),
                    ),
                  );
                },
                child: Text('${localizations.allArticles} →'),
              ),
            ],
          ),
          StreamBuilder<List<ArticleModel>>(
            stream: firebaseService.getArticlesStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                );
              }

              if (snapshot.hasError) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: Column(
                        children: [
                          const Icon(Icons.error, color: Colors.red),
                          const SizedBox(height: 10),
                          Text('Ошибка: ${snapshot.error}'),
                        ],
                      ),
                    ),
                  ),
                );
              }

              final articles = snapshot.data ?? [];

              if (articles.isEmpty) {
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.article, size: 40, color: Colors.grey),
                          SizedBox(height: 10),
                          Text('Нет доступных статей'),
                        ],
                      ),
                    ),
                  ),
                );
              }

              // Берем только 3 последние статьи
              final latestArticles = articles.take(3).toList();

              // Используем PageView для SwipeView
              return SizedBox(
                height: 280,
                child: PageView.builder(
                  itemCount: latestArticles.length,
                  controller: PageController(viewportFraction: 0.95),
                  itemBuilder: (context, index) {
                    final article = latestArticles[index];
                    final theme = Theme.of(context);
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ArticleDetailScreen(
                                  article: article,
                                ),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.primary.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.article,
                                        color: theme.colorScheme.primary,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        article.title,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Expanded(
                                  child: Text(
                                    article.content.length > 150
                                        ? '${article.content.substring(0, 150)}...'
                                        : article.content,
                                    maxLines: 5,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      size: 14,
                                      color: theme.colorScheme.primary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      DateFormat('dd.MM.yyyy').format(article.createdAt),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                                      ),
                                    ),
                                    const Spacer(),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      size: 14,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAvailableSlots(BuildContext context) {
    final firebaseService = context.read<FirebaseService>();
    final localizations = AppLocalizations.of(context) ?? AppLocalizations(const Locale('ru'));
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: Theme.of(context).colorScheme.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        localizations.availableSlots,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ScheduleScreen(),
                    ),
                  );
                },
                child: Text('${localizations.allSlots} →'),
              ),
            ],
          ),
          StreamBuilder<List<ScheduleSlot>>(
            stream: firebaseService.getAvailableSlotsStream(limit: 3),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                );
              }

              if (snapshot.hasError) {
                final error = snapshot.error.toString();
                final isPermissionError = error.contains('permission-denied') || 
                                         error.contains('PERMISSION_DENIED');
                
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            isPermissionError ? Icons.lock : Icons.error,
                            color: Colors.orange,
                            size: 48,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            isPermissionError 
                                ? 'Недостаточно прав доступа'
                                : 'Ошибка загрузки',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            isPermissionError
                                ? 'Обратитесь к администратору для настройки прав доступа к расписанию'
                                : 'Проверьте подключение к интернету',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              final slots = snapshot.data ?? [];

              if (slots.isEmpty) {
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.calendar_today, size: 40, color: Colors.grey),
                          SizedBox(height: 10),
                          Text('Нет доступных слотов'),
                          SizedBox(height: 5),
                          Text(
                            'Новых слотов пока нет',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              return Column(
                children: slots.map((slot) {
                  final theme = Theme.of(context);
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.tertiary.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.calendar_today,
                                        color: theme.colorScheme.tertiary,
                                        size: 18,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        DateFormat('EEEE, dd MMMM', 'ru_RU').format(slot.datetime),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Chip(
                                avatar: const Icon(Icons.check_circle, size: 16, color: Colors.green),
                                label: const Text('Свободно'),
                                backgroundColor: Colors.green.withOpacity(0.15),
                                labelStyle: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 18,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                DateFormat('HH:mm').format(slot.datetime),
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          FutureBuilder(
                            future: firebaseService.getUserData(slot.psychologistId),
                            builder: (context, userSnapshot) {
                              if (userSnapshot.connectionState == ConnectionState.waiting) {
                                return Row(
                                  children: [
                                    SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Загрузка...',
                                      style: TextStyle(
                                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                                      ),
                                    ),
                                  ],
                                );
                              }
                              if (userSnapshot.hasData) {
                                return Row(
                                  children: [
                                    Icon(
                                      Icons.person,
                                      size: 18,
                                      color: theme.colorScheme.secondary,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Психолог: ${userSnapshot.data!.name}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: theme.colorScheme.onSurface,
                                      ),
                                    ),
                                  ],
                                );
                              }
                              if (userSnapshot.hasError) {
                                return Row(
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      size: 18,
                                      color: Colors.red,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Информация о психологе недоступна',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                );
                              }
                              return const SizedBox();
                            },
                          ),
                          const SizedBox(height: 16),
                          Material(
                            color: Colors.transparent,
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  final role = await context.read<FirebaseService>().getUserRole();
                                  if (role == 'psychologist' || role == 'admin') {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Психолог не может записаться на сессию'),
                                          backgroundColor: Colors.orange,
                                        ),
                                      );
                                    }
                                    return;
                                  }
                                  if (context.mounted) {
                                    _showBookingDialog(context, slot);
                                  }
                                },
                              icon: const Icon(Icons.event_available),
                              label: Text(AppLocalizations.of(context)?.book ?? 'Записаться'),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showBookingDialog(BuildContext context, ScheduleSlot slot) async {
    final firebaseService = context.read<FirebaseService>();
    final localizations = AppLocalizations.of(context) ?? AppLocalizations(const Locale('ru'));
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.calendar_today, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                localizations.bookAppointment,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizations.bookConfirm,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 16, color: Theme.of(context).primaryColor),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('dd.MM.yyyy, EEEE', 'ru_RU').format(slot.datetime),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.schedule, size: 16, color: Theme.of(context).primaryColor),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('HH:mm').format(slot.datetime),
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(localizations.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              
              // Показываем индикатор загрузки
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(
                  child: CircularProgressIndicator(),
                ),
              );
              
              try {
                await firebaseService.bookAppointment(slot);
                
                if (context.mounted) {
                  Navigator.pop(context); // Закрываем индикатор
                  final loc = AppLocalizations.of(context) ?? AppLocalizations(const Locale('ru'));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.white),
                          const SizedBox(width: 8),
                          Text(loc.bookingSuccess),
                        ],
                      ),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context); // Закрываем индикатор
                  final loc = AppLocalizations.of(context) ?? AppLocalizations(const Locale('ru'));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.error, color: Colors.white),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${loc.bookingError}: ${e.toString().contains('Permission denied') ? loc.contactAdmin : e.toString()}',
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      duration: const Duration(seconds: 4),
                    ),
                  );
                }
              }
            },
            child: Text(localizations.confirm),
          ),
        ],
      ),
    );
  }
}