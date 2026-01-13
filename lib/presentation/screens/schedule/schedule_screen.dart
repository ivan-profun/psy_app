// lib/presentation/screens/schedule/schedule_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/services/firebase_service.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../data/models/schedule_slot_model.dart';
import '../../../data/models/user_model.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  // Метод для определения, является ли пользователь психологом
  bool _isPsychologist(BuildContext context) {
    final user = context.watch<FirebaseService>().currentUser;
    return user != null && 
        (user.email?.contains('psych') == true || 
         user.email?.contains('психолог') == true ||
         (user.displayName?.toLowerCase().contains('psych') ?? false));
  }

  @override
  Widget build(BuildContext context) {
    final isPsychologist = _isPsychologist(context);
    final localizations = AppLocalizations.of(context) ?? AppLocalizations(const Locale('ru'));
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isPsychologist 
            ? localizations.translate('my_schedule') ?? 'Моё расписание'
            : localizations.bookAppointment),
      ),
      body: isPsychologist 
          ? _buildPsychologistSchedule(context)
          : _buildStudentSchedule(context),
    );
  }

  // ========== ДЛЯ СТУДЕНТА ==========
  Widget _buildStudentSchedule(BuildContext context) {
    final firebaseService = context.read<FirebaseService>();

    return StreamBuilder<List<ScheduleSlot>>(
      stream: firebaseService.getAvailableSlotsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          final error = snapshot.error.toString();
          final isPermissionError = error.contains('permission-denied') || 
                                   error.contains('PERMISSION_DENIED');
          
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isPermissionError ? Icons.lock : Icons.error_outline,
                    size: 64,
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    isPermissionError 
                        ? 'Недостаточно прав доступа'
                        : 'Ошибка загрузки',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isPermissionError
                        ? 'Обратитесь к администратору для настройки прав доступа к расписанию в Firestore'
                        : 'Проверьте подключение к интернету и попробуйте снова',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final slots = snapshot.data ?? [];

        if (slots.isEmpty) {
          final localizations = AppLocalizations.of(context) ?? AppLocalizations(const Locale('ru'));
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.calendar_today,
                    size: 60,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  localizations.translate('no_slots_available') ?? 'Нет доступных слотов для записи',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  localizations.translate('please_come_later') ?? 'Пожалуйста, зайдите позже',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: slots.length,
          itemBuilder: (context, index) {
            final slot = slots[index];
            final theme = Theme.of(context);
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
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
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.tertiary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.calendar_today,
                                  color: theme.colorScheme.tertiary,
                                  size: 20,
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
                    const SizedBox(height: 16),
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
                    FutureBuilder<UserModel>(
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
                        return Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 18,
                              color: Colors.red,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Информация недоступна',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    Material(
                      color: Colors.transparent,
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            _showBookingDialog(context, slot);
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
          },
        );
      },
    );
  }

  // ========== ДЛЯ ПСИХОЛОГА ==========
  Widget _buildPsychologistSchedule(BuildContext context) {
    final user = context.watch<FirebaseService>().currentUser;
    
    if (user == null) {
      return const Center(child: Text('Пользователь не авторизован'));
    }

    final theme = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.calendar_month,
                size: 80,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Управление расписанием',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Здесь вы можете управлять своим расписанием',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 40),
            Builder(
              builder: (context) {
                final localizations = AppLocalizations.of(context) ?? AppLocalizations(const Locale('ru'));
                return Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _showAddSlotDialog(context, user.uid);
                        },
                        icon: const Icon(Icons.add_circle_outline),
                        label: Text(localizations.translate('add_slot') ?? 'Добавить слот'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          _showMySlotsDialog(context, user.uid);
                        },
                        icon: const Icon(Icons.list),
                        label: Text(localizations.translate('my_slots') ?? 'Мои слоты'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          _showAppointmentsDialog(context, user.uid);
                        },
                        icon: const Icon(Icons.event_available),
                        label: Text(localizations.translate('appointments') ?? 'Записи на консультации'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ========== ОБЩИЕ МЕТОДЫ ==========
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
            Text(localizations.translate('confirm_booking') ?? 'Подтверждение записи'),
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

  void _showAddSlotDialog(BuildContext context, String psychologistId) {
    final dateController = TextEditingController();
    final timeController = TextEditingController();
    DateTime? selectedDate;
    TimeOfDay? selectedTime;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.add_circle, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            const Text('Добавить слот'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Выберите дату и время для нового слота'),
            const SizedBox(height: 16),
            TextField(
              controller: dateController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Дата',
                prefixIcon: const Icon(Icons.calendar_today),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 90)),
                );
                if (date != null) {
                  selectedDate = date;
                  dateController.text = DateFormat('dd.MM.yyyy').format(date);
                }
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: timeController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Время',
                prefixIcon: const Icon(Icons.access_time),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (time != null) {
                  selectedTime = time;
                  timeController.text = time.format(context);
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              if (selectedDate != null && selectedTime != null) {
                // TODO: Реализовать добавление слота в Firebase
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Функционал добавления слотов будет реализован в следующей версии'),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Пожалуйста, выберите дату и время'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
            child: const Text('Добавить'),
          ),
        ],
      ),
    );
  }

  void _showMySlotsDialog(BuildContext context, String psychologistId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.list, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            const Text('Мои слоты'),
          ],
        ),
        content: const Text('Функционал просмотра слотов будет реализован в следующей версии.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  void _showAppointmentsDialog(BuildContext context, String psychologistId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.event_available, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            const Text('Записи на консультации'),
          ],
        ),
        content: const Text('Функционал просмотра записей будет реализован в следующей версии.'),
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