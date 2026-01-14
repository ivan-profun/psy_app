import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/services/firebase_service.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../data/models/schedule_slot_model.dart';
import '../../../data/models/appointment_model.dart';
import '../../../data/models/user_model.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  bool _isPsychologist(BuildContext context) {
    final user = context.watch<FirebaseService>().currentUser;
    return user != null && 
        (user.email?.contains('psych') == true || 
         user.email?.contains('психолог') == true ||
         (user.displayName?.toLowerCase().contains('psych') ?? false));
  }

  void _showStudentAppointmentsDialog(BuildContext context) {
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
                    Icon(Icons.event_note, color: Theme.of(context).primaryColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        localizations.translate('my_appointments') ?? 'Мои записи',
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
                child: StreamBuilder<List<AppointmentModel>>(
                  stream: firebaseService.getUserAppointmentsStream(),
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

                    final appointments = snapshot.data ?? [];
                    if (appointments.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(localizations.translate('no_appointments') ?? 'Нет записей'),
                        ),
                      );
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: appointments.length,
                      itemBuilder: (context, index) {
                        final appointment = appointments[index];
                        return FutureBuilder<UserModel>(
                          future: firebaseService.getUserData(appointment.psychologistId),
                          builder: (context, userSnapshot) {
                            final psychologistName = userSnapshot.data?.name ?? (localizations.translate('psychologist') ?? 'Психолог');
                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              child: ListTile(
                                leading: const Icon(Icons.event_available),
                                title: Text(psychologistName),
                                subtitle: Text(
                                  DateFormat('dd.MM.yyyy HH:mm').format(appointment.datetime),
                                ),
                              ),
                            );
                          },
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

  @override
  Widget build(BuildContext context) {
    final firebaseService = context.watch<FirebaseService>();
    final localizations = AppLocalizations.of(context) ?? AppLocalizations(const Locale('ru'));

    return FutureBuilder<String>(
      future: firebaseService.getUserRole(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final role = snapshot.data ?? 'student';
        final isPsychologist = role == 'psychologist' || role == 'admin';

        return Scaffold(
          appBar: AppBar(
            title: Text(
              isPsychologist
                  ? localizations.translate('my_schedule') ?? 'Моё расписание'
                  : localizations.bookAppointment,
            ),
            actions: [
              if (!isPsychologist)
                IconButton(
                  icon: const Icon(Icons.event_note),
                  onPressed: () {
                    _showStudentAppointmentsDialog(context);
                  },
                ),
            ],
          ),
          body: isPsychologist
              ? _buildPsychologistSchedule(context)
              : _buildStudentSchedule(context),
        );
      },
    );
  }

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
                          final name = userSnapshot.data!.name.trim();
                          return Row(
                            children: [
                              Icon(
                                Icons.person,
                                size: 18,
                                color: theme.colorScheme.secondary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Психолог: ${name.isNotEmpty ? name : (AppLocalizations.of(context)?.translate('psychologist') ?? 'Психолог')}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ],
                          );
                        }
                        final hasId = slot.psychologistId.trim().isNotEmpty;
                        return Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 18,
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                hasId
                                    ? 'Психолог: (не удалось загрузить)'
                                    : 'Психолог не указан',
                                style: TextStyle(
                                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                                  fontSize: 12,
                                ),
                                overflow: TextOverflow.ellipsis,
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
                          onPressed: () async {
                            final role = await firebaseService.getUserRole();
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
          },
        );
      },
    );
  }

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
                localizations.translate('confirm_booking') ?? 'Подтверждение записи',
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
              } finally {
                if (context.mounted) {
                  final nav = Navigator.of(context, rootNavigator: true);
                  if (nav.canPop()) {
                    nav.pop();
                  }
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
            const Expanded(
              child: Text(
                'Добавить слот',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
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
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (selectedDate != null && selectedTime != null) {
                final firebaseService = context.read<FirebaseService>();
                final localizations = AppLocalizations.of(context) ?? AppLocalizations(const Locale('ru'));
                
                final datetime = DateTime(
                  selectedDate!.year,
                  selectedDate!.month,
                  selectedDate!.day,
                  selectedTime!.hour,
                  selectedTime!.minute,
                );
                
                if (datetime.isBefore(DateTime.now())) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(localizations.translate('past_date_error') ?? 'Нельзя создать слот в прошлом'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }
                
                try {
                  Navigator.pop(context);
                  await firebaseService.addScheduleSlot(
                    psychologistId: psychologistId,
                    datetime: datetime,
                  );
                  
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(localizations.translate('slot_added') ?? 'Слот успешно добавлен'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${localizations.translate('error') ?? 'Ошибка'}: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              } else {
                final localizations = AppLocalizations.of(context) ?? AppLocalizations(const Locale('ru'));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(localizations.translate('select_date_time') ?? 'Пожалуйста, выберите дату и время'),
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
                    Icon(Icons.list, color: Theme.of(context).primaryColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        localizations.translate('my_slots') ?? 'Мои слоты',
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
                child: StreamBuilder<List<ScheduleSlot>>(
                  stream: firebaseService.getPsychologistSlotsStream(psychologistId),
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
                    
                    final slots = snapshot.data ?? [];
                    
                    if (slots.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(localizations.translate('no_slots') ?? 'Нет слотов'),
                        ),
                      );
                    }
                    
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: slots.length,
                      itemBuilder: (context, index) {
                        final slot = slots[index];
                        final canManage = slot.studentId == null;
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: ListTile(
                            leading: Icon(
                              slot.isAvailable ? Icons.event_available : Icons.event_busy,
                              color: slot.isAvailable ? Colors.green : Colors.grey,
                            ),
                            title: Text(
                              DateFormat('dd.MM.yyyy HH:mm').format(slot.datetime),
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              slot.studentId != null
                                  ? (localizations.translate('booked') ?? 'Забронирован')
                                  : (slot.isAvailable
                                      ? (localizations.translate('available') ?? 'Доступен')
                                      : (localizations.translate('hidden') ?? 'Скрыт')),
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: PopupMenuButton<String>(
                              itemBuilder: (context) => [
                                if (canManage)
                                  PopupMenuItem(
                                    value: 'edit',
                                    child: Text(localizations.translate('edit') ?? 'Редактировать'),
                                  ),
                                if (canManage)
                                  PopupMenuItem(
                                    value: 'toggle',
                                    child: Text(
                                      slot.isAvailable
                                          ? (localizations.translate('hide') ?? 'Скрыть')
                                          : (localizations.translate('show') ?? 'Показать'),
                                    ),
                                  ),
                                if (canManage)
                                  PopupMenuItem(
                                    value: 'delete',
                                    child: Text(
                                      localizations.translate('delete') ?? 'Удалить',
                                      style: const TextStyle(color: Colors.red),
                                    ),
                                  ),
                              ],
                              onSelected: (value) async {
                                try {
                                  if (value == 'edit') {
                                    Navigator.pop(context);
                                    _showEditSlotDialog(context, psychologistId, slot);
                                    return;
                                  }

                                  if (value == 'toggle') {
                                    await firebaseService.updateScheduleSlot(
                                      slotId: slot.id,
                                      isAvailable: !slot.isAvailable,
                                    );
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(localizations.translate('status_updated') ?? 'Статус обновлён'),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    }
                                    return;
                                  }

                                  if (value == 'delete') {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: Text(localizations.translate('delete_slot') ?? 'Удалить слот?'),
                                        content: Text(localizations.translate('delete_slot_confirm') ?? 'Вы уверены, что хотите удалить этот слот?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context, false),
                                            child: Text(localizations.cancel),
                                          ),
                                          ElevatedButton(
                                            onPressed: () => Navigator.pop(context, true),
                                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                            child: Text(localizations.translate('delete') ?? 'Удалить'),
                                          ),
                                        ],
                                      ),
                                    );

                                    if (confirm == true) {
                                      await firebaseService.deleteScheduleSlot(slot.id);
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(localizations.translate('slot_deleted') ?? 'Слот удалён'),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                      }
                                    }
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

  void _showEditSlotDialog(BuildContext context, String psychologistId, ScheduleSlot slot) {
    final dateController = TextEditingController(
      text: DateFormat('dd.MM.yyyy').format(slot.datetime),
    );
    final timeController = TextEditingController(
      text: DateFormat('HH:mm').format(slot.datetime),
    );
    DateTime selectedDate = DateTime(slot.datetime.year, slot.datetime.month, slot.datetime.day);
    TimeOfDay selectedTime = TimeOfDay(hour: slot.datetime.hour, minute: slot.datetime.minute);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.edit, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Редактировать слот',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Измените дату и время слота'),
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
                    initialDate: selectedDate,
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
                    initialTime: selectedTime,
                  );
                  if (time != null) {
                    selectedTime = time;
                    timeController.text = time.format(context);
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () async {
              final firebaseService = context.read<FirebaseService>();
              final localizations = AppLocalizations.of(context) ?? AppLocalizations(const Locale('ru'));

              final datetime = DateTime(
                selectedDate.year,
                selectedDate.month,
                selectedDate.day,
                selectedTime.hour,
                selectedTime.minute,
              );

              if (datetime.isBefore(DateTime.now())) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(localizations.translate('past_date_error') ?? 'Нельзя создать слот в прошлом'),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }

              try {
                Navigator.pop(context);
                await firebaseService.updateScheduleSlot(
                  slotId: slot.id,
                  datetime: datetime,
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(localizations.translate('slot_updated') ?? 'Слот обновлён'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${localizations.translate('error') ?? 'Ошибка'}: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  void _showAppointmentsDialog(BuildContext context, String psychologistId) {
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
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.event_available, color: Theme.of(context).primaryColor),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            localizations.translate('appointments') ?? 'Записи на консультации',
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
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _showCreateAppointmentDialog(context, psychologistId);
                        },
                        icon: const Icon(Icons.add),
                        label: Text(localizations.translate('create_appointment') ?? 'Создать запись'),
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: StreamBuilder<List<AppointmentModel>>(
                  stream: firebaseService.getPsychologistAppointmentsStream(psychologistId),
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
                    
                    final appointments = snapshot.data ?? [];
                    
                    if (appointments.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(localizations.translate('no_appointments') ?? 'Нет записей'),
                        ),
                      );
                    }
                    
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: appointments.length,
                      itemBuilder: (context, index) {
                        final appointment = appointments[index];
                        return FutureBuilder<UserModel>(
                          future: firebaseService.getUserData(appointment.studentId),
                          builder: (context, userSnapshot) {
                            final studentName = userSnapshot.data?.name ?? 'Неизвестно';
                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              child: ListTile(
                                leading: Icon(
                                  _getStatusIcon(appointment.status),
                                  color: _getStatusColor(appointment.status),
                                ),
                                title: Text(studentName),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(DateFormat('dd.MM.yyyy HH:mm').format(appointment.datetime)),
                                    Text(
                                      _getStatusText(appointment.status, localizations),
                                      style: TextStyle(
                                        color: _getStatusColor(appointment.status),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: PopupMenuButton(
                                  itemBuilder: (context) => [
                                    if (appointment.status == 'booked') ...[
                                      PopupMenuItem(
                                        value: 'edit',
                                        child: Text(localizations.translate('edit') ?? 'Редактировать'),
                                      ),
                                      PopupMenuItem(
                                        value: 'complete',
                                        child: Text(localizations.translate('mark_completed') ?? 'Отметить завершённой'),
                                      ),
                                      PopupMenuItem(
                                        value: 'cancel',
                                        child: Text(localizations.translate('cancel') ?? 'Отменить'),
                                      ),
                                    ],
                                    PopupMenuItem(
                                      value: 'delete',
                                      child: Text(localizations.translate('delete') ?? 'Удалить', style: const TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                  onSelected: (value) async {
                                    try {
                                      if (value == 'edit') {
                                        Navigator.pop(context);
                                        _showEditAppointmentDialog(context, appointment, psychologistId);
                                      } else if (value == 'complete') {
                                        await firebaseService.updateAppointmentStatus(appointment.id, 'completed');
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(localizations.translate('status_updated') ?? 'Статус обновлён'),
                                              backgroundColor: Colors.green,
                                            ),
                                          );
                                        }
                                      } else if (value == 'cancel') {
                                        await firebaseService.updateAppointmentStatus(appointment.id, 'cancelled');
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(localizations.translate('status_updated') ?? 'Статус обновлён'),
                                              backgroundColor: Colors.green,
                                            ),
                                          );
                                        }
                                      } else if (value == 'delete') {
                                        final confirm = await showDialog<bool>(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: Text(localizations.translate('delete_appointment') ?? 'Удалить запись?'),
                                            content: Text(localizations.translate('delete_appointment_confirm') ?? 'Вы уверены, что хотите удалить эту запись?'),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(context, false),
                                                child: Text(localizations.cancel),
                                              ),
                                              ElevatedButton(
                                                onPressed: () => Navigator.pop(context, true),
                                                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                                child: Text(localizations.translate('delete') ?? 'Удалить'),
                                              ),
                                            ],
                                          ),
                                        );
                                        if (confirm == true) {
                                          await firebaseService.deleteAppointment(appointment.id);
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text(localizations.translate('appointment_deleted') ?? 'Запись удалена'),
                                                backgroundColor: Colors.green,
                                              ),
                                            );
                                          }
                                        }
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

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'completed':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      case 'booked':
        return Icons.event_available;
      default:
        return Icons.pending;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'booked':
        return Colors.blue;
      default:
        return Colors.orange;
    }
  }

  String _getStatusText(String status, AppLocalizations localizations) {
    switch (status) {
      case 'completed':
        return localizations.translate('completed') ?? 'Завершена';
      case 'cancelled':
        return localizations.translate('cancelled') ?? 'Отменена';
      case 'booked':
        return localizations.translate('booked') ?? 'Забронирована';
      default:
        return localizations.translate('pending') ?? 'Ожидает';
    }
  }

  void _showCreateAppointmentDialog(BuildContext context, String psychologistId) async {
    final firebaseService = context.read<FirebaseService>();
    final localizations = AppLocalizations.of(context) ?? AppLocalizations(const Locale('ru'));
    
    final students = await firebaseService.getStudentsList();
    if (students.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localizations.translate('no_students') ?? 'Нет студентов'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    String? selectedStudentId = students.first.id;
    final dateController = TextEditingController();
    final timeController = TextEditingController();
    DateTime? selectedDate;
    TimeOfDay? selectedTime;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.add, color: Theme.of(context).primaryColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  localizations.translate('create_appointment') ?? 'Создать запись',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedStudentId,
                  decoration: InputDecoration(
                    labelText: localizations.translate('student') ?? 'Студент',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: students.map((student) => DropdownMenuItem(
                    value: student.id,
                    child: Text(student.name),
                  )).toList(),
                  onChanged: (value) => setState(() => selectedStudentId = value),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: dateController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: localizations.translate('date') ?? 'Дата',
                    prefixIcon: const Icon(Icons.calendar_today),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setState(() {
                        selectedDate = date;
                        dateController.text = DateFormat('dd.MM.yyyy').format(date);
                      });
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: timeController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: localizations.translate('time') ?? 'Время',
                    prefixIcon: const Icon(Icons.access_time),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (time != null) {
                      setState(() {
                        selectedTime = time;
                        timeController.text = time.format(context);
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(localizations.cancel),
            ),
            ElevatedButton(
              onPressed: () async {
                if (selectedStudentId != null && selectedDate != null && selectedTime != null) {
                  final datetime = DateTime(
                    selectedDate!.year,
                    selectedDate!.month,
                    selectedDate!.day,
                    selectedTime!.hour,
                    selectedTime!.minute,
                  );
                  try {
                    Navigator.pop(context);
                    await firebaseService.createAppointmentForPsychologist(
                      psychologistId: psychologistId,
                      studentId: selectedStudentId!,
                      datetime: datetime,
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(localizations.translate('appointment_created') ?? 'Запись создана'),
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
                }
              },
              child: Text(localizations.translate('create') ?? 'Создать'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditAppointmentDialog(BuildContext context, AppointmentModel appointment, String psychologistId) async {
    final firebaseService = context.read<FirebaseService>();
    final localizations = AppLocalizations.of(context) ?? AppLocalizations(const Locale('ru'));
    
    final students = await firebaseService.getStudentsList();
    String? selectedStudentId = appointment.studentId;
    final dateController = TextEditingController(text: DateFormat('dd.MM.yyyy').format(appointment.datetime));
    final timeController = TextEditingController(text: DateFormat('HH:mm').format(appointment.datetime));
    DateTime? selectedDate = appointment.datetime;
    TimeOfDay? selectedTime = TimeOfDay.fromDateTime(appointment.datetime);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.edit, color: Theme.of(context).primaryColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  localizations.translate('edit_appointment') ?? 'Редактировать запись',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedStudentId,
                  decoration: InputDecoration(
                    labelText: localizations.translate('student') ?? 'Студент',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: students.map((student) => DropdownMenuItem(
                    value: student.id,
                    child: Text(student.name),
                  )).toList(),
                  onChanged: (value) => setState(() => selectedStudentId = value),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: dateController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: localizations.translate('date') ?? 'Дата',
                    prefixIcon: const Icon(Icons.calendar_today),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setState(() {
                        selectedDate = date;
                        dateController.text = DateFormat('dd.MM.yyyy').format(date);
                      });
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: timeController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: localizations.translate('time') ?? 'Время',
                    prefixIcon: const Icon(Icons.access_time),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: selectedTime ?? TimeOfDay.now(),
                    );
                    if (time != null) {
                      setState(() {
                        selectedTime = time;
                        timeController.text = time.format(context);
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(localizations.cancel),
            ),
            ElevatedButton(
              onPressed: () async {
                if (selectedStudentId != null && selectedDate != null && selectedTime != null) {
                  final datetime = DateTime(
                    selectedDate!.year,
                    selectedDate!.month,
                    selectedDate!.day,
                    selectedTime!.hour,
                    selectedTime!.minute,
                  );
                  try {
                    Navigator.pop(context);
                    await firebaseService.updateAppointment(
                      appointmentId: appointment.id,
                      studentId: selectedStudentId != appointment.studentId ? selectedStudentId : null,
                      datetime: datetime != appointment.datetime ? datetime : null,
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(localizations.translate('appointment_updated') ?? 'Запись обновлена'),
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
                }
              },
              child: Text(localizations.translate('save') ?? 'Сохранить'),
            ),
          ],
        ),
      ),
    );
  }
}
