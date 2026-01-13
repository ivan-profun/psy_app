import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'ru': {
      'app_title': 'Психологическая помощь',
      'welcome': 'Добро пожаловать',
      'home': 'Главная',
      'articles': 'Статьи',
      'schedule': 'Запись',
      'profile': 'Профиль',
      'latest_articles': 'Свежие статьи',
      'all_articles': 'Все статьи',
      'available_slots': 'Ближайшие слоты',
      'all_slots': 'Все слоты',
      'book': 'Записаться',
      'service_info': 'Информация о службе',
      'working_hours': 'Время работы',
      'phone': 'Телефон',
      'email': 'Email',
      'address': 'Адрес',
      'confidential_help': 'Мы предоставляем конфиденциальную психологическую помощь студентам и сотрудникам университета.',
      'no_articles': 'Нет доступных статей',
      'no_slots': 'Нет доступных слотов',
      'loading': 'Загрузка...',
      'error': 'Ошибка',
      'cancel': 'Отмена',
      'confirm': 'Подтвердить',
      'settings': 'Настройки',
      'theme': 'Тема',
      'font_size': 'Размер шрифта',
      'language': 'Язык',
      'light_theme': 'Светлая',
      'dark_theme': 'Тёмная',
      'system_theme': 'Системная',
      'small_font': 'Малый',
      'medium_font': 'Средний',
      'large_font': 'Большой',
      'russian': 'Русский',
      'english': 'English',
      'uzbek': 'O\'zbek',
      'tajik': 'Тоҷикӣ',
      'elvish': 'Quenya',
      'ossetian': 'Ирон',
      'ukrainian': 'Українська',
      'yakut': 'Саха',
      'old_church_slavonic': 'Словѣньскъ',
      'notifications': 'Уведомления',
      'privacy': 'Конфиденциальность',
      'about': 'О приложении',
      'book_appointment': 'Запись на консультацию',
      'book_confirm': 'Вы уверены, что хотите записаться на эту консультацию?',
      'booking_success': 'Запись успешно создана!',
      'booking_error': 'Ошибка при записи',
      'permission_denied': 'Недостаточно прав доступа',
      'contact_admin': 'Обратитесь к администратору для настройки прав доступа',
      'push_notifications': 'Push-уведомления',
      'receive_notifications': 'Получать уведомления о записях',
      'email_notifications': 'Email-уведомления',
      'receive_email_notifications': 'Получать уведомления на email',
      'privacy_policy': 'Политика конфиденциальности',
      'privacy_policy_text': 'Все ваши данные защищены и хранятся в соответствии с политикой конфиденциальности. Мы не передаём вашу информацию третьим лицам.',
      'data_security': 'Безопасность данных',
      'data_security_text': 'Все данные передаются по защищённому соединению и хранятся в зашифрованном виде.',
      'app_version': 'Версия приложения',
      'terms_of_use': 'Условия использования',
      'terms_of_use_text': 'Используя это приложение, вы соглашаетесь с условиями использования службы психологической помощи.',
      'help_support': 'Помощь и поддержка',
      'help_support_text': 'Если у вас возникли вопросы, обратитесь в службу поддержки: psych-help@university.edu',
      'select_theme': 'Выберите тему',
      'select_language': 'Выберите язык',
      'close': 'Закрыть',
      'guest': 'Гость',
      'user': 'Пользователь',
      'logout': 'Выход',
      'logout_confirm': 'Вы уверены, что хотите выйти из аккаунта?',
      'logout_title': 'Выход из аккаунта',
      'avatar_updated': 'Аватарка успешно обновлена',
      'avatar_error': 'Ошибка загрузки аватарки',
      'service_name': 'Служба психологической помощи',
      'confirm_booking': 'Подтверждение записи',
      'my_schedule': 'Моё расписание',
      'add_slot': 'Добавить слот',
      'my_slots': 'Мои слоты',
      'appointments': 'Записи на консультации',
      'no_slots_available': 'Нет доступных слотов для записи',
      'please_come_later': 'Пожалуйста, зайдите позже',
      'schedule_management': 'Управление расписанием',
      'schedule_management_desc': 'Здесь вы можете управлять своим расписанием',
      'language_changed': 'Язык изменён',
      'draft': 'Черновик',
      'read_more': 'Читать →',
      'role': 'Роль',
      'student': 'Студент',
      'psychologist': 'Психолог',
      'admin': 'Администратор',
      'statistics': 'Статистика',
      'completed_sessions': 'Посещенных сессий',
      'app_settings': 'Настройки приложения',
      'articles_and_materials': 'Статьи и материалы',
      'you_have_no_articles': 'У вас нет статей',
      'total_articles': 'Всего статей',
      'published_articles': 'Опубликовано',
      'draft_articles': 'Черновиков',
      'total_sessions': 'Всего сессий',
      'upcoming_sessions': 'Предстоящих',
      'completed_sessions_count': 'Завершено',
      'create_article': 'Создать статью',
      'edit_article': 'Редактировать статью',
      'delete_article': 'Удалить статью',
      'publish_article': 'Опубликовать',
      'unpublish_article': 'Снять с публикации',
      'manage_users': 'Управление пользователями',
      'view_all_users': 'Все пользователи',
      'add_user': 'Добавить пользователя',
      'edit_user': 'Редактировать пользователя',
      'delete_user': 'Удалить пользователя',
      'change_role': 'Изменить роль',
      'system_settings': 'Системные настройки',
      'manage_articles': 'Управление статьями',
      'view_all_articles': 'Все статьи',
      'manage_appointments': 'Управление записями',
      'view_all_appointments': 'Все записи',
      'reports': 'Отчёты',
      'view_reports': 'Просмотр отчётов',
      'export_data': 'Экспорт данных',
      'articles_statistics': 'Статистика статей',
      'sessions_statistics': 'Статистика сессий',
      'my_clients': 'Мои клиенты',
      'system_statistics': 'Статистика системы',
      'total_users': 'Всего пользователей',
      'total_appointments': 'Всего записей',
      'users_management_desc': 'Функционал управления пользователями будет реализован в следующей версии.',
      'articles_management_desc': 'Функционал управления статьями будет реализован в следующей версии.',
      'appointments_management_desc': 'Функционал управления записями будет реализован в следующей версии.',
      'reports_desc': 'Функционал отчётов будет реализован в следующей версии.',
      'system_settings_desc': 'Функционал системных настроек будет реализован в следующей версии.',
      'past_date_error': 'Нельзя создать слот в прошлом',
      'slot_added': 'Слот успешно добавлен',
      'select_date_time': 'Пожалуйста, выберите дату и время',
      'available': 'Доступен',
      'booked': 'Забронирован',
      'slot_deleted': 'Слот удалён',
      'no_appointments': 'Нет записей',
      'mark_completed': 'Отметить завершённой',
      'status_updated': 'Статус обновлён',
      'completed': 'Завершена',
      'cancelled': 'Отменена',
      'pending': 'Ожидает',
      'no_users': 'Нет пользователей',
      'role_updated': 'Роль обновлена',
      'no_clients': 'Нет клиентов',
      'report_date': 'Дата отчёта',
    },
    'en': {
      'app_title': 'Psychological Help',
      'welcome': 'Welcome',
      'home': 'Home',
      'articles': 'Articles',
      'schedule': 'Schedule',
      'profile': 'Profile',
      'latest_articles': 'Latest Articles',
      'all_articles': 'All Articles',
      'available_slots': 'Available Slots',
      'all_slots': 'All Slots',
      'book': 'Book',
      'service_info': 'Service Information',
      'working_hours': 'Working Hours',
      'phone': 'Phone',
      'email': 'Email',
      'address': 'Address',
      'confidential_help': 'We provide confidential psychological help to students and university staff.',
      'no_articles': 'No articles available',
      'no_slots': 'No slots available',
      'loading': 'Loading...',
      'error': 'Error',
      'cancel': 'Cancel',
      'confirm': 'Confirm',
      'settings': 'Settings',
      'theme': 'Theme',
      'font_size': 'Font Size',
      'language': 'Language',
      'light_theme': 'Light',
      'dark_theme': 'Dark',
      'system_theme': 'System',
      'small_font': 'Small',
      'medium_font': 'Medium',
      'large_font': 'Large',
      'russian': 'Russian',
      'english': 'English',
      'uzbek': 'O\'zbek',
      'tajik': 'Тоҷикӣ',
      'elvish': 'Quenya',
      'ossetian': 'Ирон',
      'ukrainian': 'Українська',
      'yakut': 'Саха',
      'old_church_slavonic': 'Словѣньскъ',
      'notifications': 'Notifications',
      'privacy': 'Privacy',
      'about': 'About',
      'book_appointment': 'Book Appointment',
      'book_confirm': 'Are you sure you want to book this appointment?',
      'booking_success': 'Appointment booked successfully!',
      'booking_error': 'Error booking appointment',
      'permission_denied': 'Permission denied',
      'contact_admin': 'Contact administrator to configure access permissions',
      'push_notifications': 'Push Notifications',
      'receive_notifications': 'Receive notifications about appointments',
      'email_notifications': 'Email Notifications',
      'receive_email_notifications': 'Receive notifications via email',
      'privacy_policy': 'Privacy Policy',
      'privacy_policy_text': 'All your data is protected and stored in accordance with the privacy policy.',
      'data_security': 'Data Security',
      'data_security_text': 'All data is transmitted over a secure connection and stored in encrypted form.',
      'app_version': 'App Version',
      'terms_of_use': 'Terms of Use',
      'terms_of_use_text': 'By using this app, you agree to the terms of use.',
      'help_support': 'Help & Support',
      'help_support_text': 'Contact support: psych-help@university.edu',
      'select_theme': 'Select Theme',
      'select_language': 'Select Language',
      'close': 'Close',
      'guest': 'Guest',
      'user': 'User',
      'logout': 'Logout',
      'logout_confirm': 'Are you sure you want to logout?',
      'logout_title': 'Logout',
      'avatar_updated': 'Avatar updated successfully',
      'avatar_error': 'Error uploading avatar',
      'service_name': 'Psychological Help Service',
      'confirm_booking': 'Confirm Booking',
      'my_schedule': 'My Schedule',
      'add_slot': 'Add Slot',
      'my_slots': 'My Slots',
      'appointments': 'Appointments',
      'no_slots_available': 'No slots available for booking',
      'please_come_later': 'Please come back later',
      'schedule_management': 'Schedule Management',
      'schedule_management_desc': 'Here you can manage your schedule',
      'language_changed': 'Language changed',
      'draft': 'Draft',
      'read_more': 'Read →',
      'role': 'Role',
      'student': 'Student',
      'psychologist': 'Psychologist',
      'admin': 'Administrator',
      'statistics': 'Statistics',
      'completed_sessions': 'Completed Sessions',
      'app_settings': 'App Settings',
      'articles_and_materials': 'Articles and Materials',
      'you_have_no_articles': 'You have no articles',
      'total_articles': 'Total Articles',
      'published_articles': 'Published',
      'draft_articles': 'Drafts',
      'total_sessions': 'Total Sessions',
      'upcoming_sessions': 'Upcoming',
      'completed_sessions_count': 'Completed',
      'create_article': 'Create Article',
      'edit_article': 'Edit Article',
      'delete_article': 'Delete Article',
      'publish_article': 'Publish',
      'unpublish_article': 'Unpublish',
      'manage_users': 'Manage Users',
      'view_all_users': 'All Users',
      'add_user': 'Add User',
      'edit_user': 'Edit User',
      'delete_user': 'Delete User',
      'change_role': 'Change Role',
      'system_settings': 'System Settings',
      'manage_articles': 'Manage Articles',
      'view_all_articles': 'All Articles',
      'manage_appointments': 'Manage Appointments',
      'view_all_appointments': 'All Appointments',
      'reports': 'Reports',
      'view_reports': 'View Reports',
      'export_data': 'Export Data',
      'articles_statistics': 'Articles Statistics',
      'sessions_statistics': 'Sessions Statistics',
      'my_clients': 'My Clients',
      'system_statistics': 'System Statistics',
      'total_users': 'Total Users',
      'total_appointments': 'Total Appointments',
      'users_management_desc': 'User management features will be available in the next version.',
      'articles_management_desc': 'Article management features will be available in the next version.',
      'appointments_management_desc': 'Appointment management features will be available in the next version.',
      'reports_desc': 'Reporting features will be available in the next version.',
      'system_settings_desc': 'System settings will be available in the next version.',
      'past_date_error': 'Cannot create slot in the past',
      'slot_added': 'Slot added successfully',
      'select_date_time': 'Please select date and time',
      'available': 'Available',
      'booked': 'Booked',
      'slot_deleted': 'Slot deleted',
      'no_appointments': 'No appointments',
      'mark_completed': 'Mark as completed',
      'status_updated': 'Status updated',
      'completed': 'Completed',
      'cancelled': 'Cancelled',
      'pending': 'Pending',
      'no_users': 'No users',
      'role_updated': 'Role updated',
      'no_clients': 'No clients',
      'report_date': 'Report Date',
    },
    // ... Другие языки (uz, tg, sah, cu, os, qya) должны быть также синхронизированы по ключам
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? _localizedValues['en']?[key] ?? key;
  }

  // --- ГЕТТЕРЫ ДЛЯ ВСЕХ КЛЮЧЕЙ ---

  String get appTitle => translate('app_title');
  String get welcome => translate('welcome');
  String get home => translate('home');
  String get articles => translate('articles');
  String get schedule => translate('schedule');
  String get profile => translate('profile');
  String get latestArticles => translate('latest_articles');
  String get allArticles => translate('all_articles');
  String get availableSlots => translate('available_slots');
  String get allSlots => translate('all_slots');
  String get book => translate('book');
  String get serviceInfo => translate('service_info');
  String get workingHours => translate('working_hours');
  String get phone => translate('phone');
  String get email => translate('email');
  String get address => translate('address');
  String get confidentialHelp => translate('confidential_help');
  String get noArticles => translate('no_articles');
  String get noSlots => translate('no_slots');
  String get loading => translate('loading');
  String get error => translate('error');
  String get cancel => translate('cancel');
  String get confirm => translate('confirm');
  String get settings => translate('settings');
  String get theme => translate('theme');
  String get fontSize => translate('font_size');
  String get language => translate('language');
  String get lightTheme => translate('light_theme');
  String get darkTheme => translate('dark_theme');
  String get systemTheme => translate('system_theme');
  String get smallFont => translate('small_font');
  String get mediumFont => translate('medium_font');
  String get largeFont => translate('large_font');
  String get russian => translate('russian');
  String get english => translate('english');
  String get uzbek => translate('uzbek');
  String get tajik => translate('tajik');
  String get elvish => translate('elvish');
  String get ossetian => translate('ossetian');
  String get ukrainian => translate('ukrainian');
  String get yakut => translate('yakut');
  String get oldChurchSlavonic => translate('old_church_slavonic');
  String get notifications => translate('notifications');
  String get privacy => translate('privacy');
  String get about => translate('about');
  String get bookAppointment => translate('book_appointment');
  String get bookConfirm => translate('book_confirm');
  String get bookingSuccess => translate('booking_success');
  String get bookingError => translate('booking_error');
  String get permissionDenied => translate('permission_denied');
  String get contactAdmin => translate('contact_admin');
  String get pushNotifications => translate('push_notifications');
  String get receiveNotifications => translate('receive_notifications');
  String get emailNotifications => translate('email_notifications');
  String get receiveEmailNotifications => translate('receive_email_notifications');
  String get privacyPolicy => translate('privacy_policy');
  String get privacyPolicyText => translate('privacy_policy_text');
  String get dataSecurity => translate('data_security');
  String get dataSecurityText => translate('data_security_text');
  String get appVersion => translate('app_version');
  String get termsOfUse => translate('terms_of_use');
  String get termsOfUseText => translate('terms_of_use_text');
  String get helpSupport => translate('help_support');
  String get helpSupportText => translate('help_support_text');
  String get selectTheme => translate('select_theme');
  String get selectLanguage => translate('select_language');
  String get close => translate('close');
  String get guest => translate('guest');
  String get user => translate('user');
  String get logout => translate('logout');
  String get logoutConfirm => translate('logout_confirm');
  String get logoutTitle => translate('logout_title');
  String get avatarUpdated => translate('avatar_updated');
  String get avatarError => translate('avatar_error');
  String get serviceName => translate('service_name');
  String get confirmBooking => translate('confirm_booking');
  String get mySchedule => translate('my_schedule');
  String get addSlot => translate('add_slot');
  String get mySlots => translate('my_slots');
  String get appointments => translate('appointments');
  String get noSlotsAvailable => translate('no_slots_available');
  String get pleaseComeLater => translate('please_come_later');
  String get scheduleManagement => translate('schedule_management');
  String get scheduleManagementDesc => translate('schedule_management_desc');
  String get languageChanged => translate('language_changed');
  String get draft => translate('draft');
  String get readMore => translate('read_more');
  String get role => translate('role');
  String get student => translate('student');
  String get psychologist => translate('psychologist');
  String get admin => translate('admin');
  String get statistics => translate('statistics');
  String get completedSessions => translate('completed_sessions');
  String get appSettings => translate('app_settings');
  String get articlesAndMaterials => translate('articles_and_materials');
  String get youHaveNoArticles => translate('you_have_no_articles');
  String get totalArticles => translate('total_articles');
  String get publishedArticles => translate('published_articles');
  String get draftArticles => translate('draft_articles');
  String get totalSessions => translate('total_sessions');
  String get upcomingSessions => translate('upcoming_sessions');
  String get completedSessionsCount => translate('completed_sessions_count');
  String get createArticle => translate('create_article');
  String get editArticle => translate('edit_article');
  String get deleteArticle => translate('delete_article');
  String get publishArticle => translate('publish_article');
  String get unpublishArticle => translate('unpublish_article');
  String get manageUsers => translate('manage_users');
  String get viewAllUsers => translate('view_all_users');
  String get addUser => translate('add_user');
  String get editUser => translate('edit_user');
  String get deleteUser => translate('delete_user');
  String get changeRole => translate('change_role');
  String get systemSettings => translate('system_settings');
  String get manageArticles => translate('manage_articles');
  String get viewAllArticles => translate('view_all_articles');
  String get manageAppointments => translate('manage_appointments');
  String get viewAllAppointments => translate('view_all_appointments');
  String get reports => translate('reports');
  String get viewReports => translate('view_reports');
  String get exportData => translate('export_data');
  String get articlesStatistics => translate('articles_statistics');
  String get sessionsStatistics => translate('sessions_statistics');
  String get myClients => translate('my_clients');
  String get systemStatistics => translate('system_statistics');
  String get totalUsers => translate('total_users');
  String get totalAppointments => translate('total_appointments');
  String get pastDateError => translate('past_date_error');
  String get slotAdded => translate('slot_added');
  String get selectDateTime => translate('select_date_time');
  String get available => translate('available');
  String get booked => translate('booked');
  String get slotDeleted => translate('slot_deleted');
  String get noAppointments => translate('no_appointments');
  String get markCompleted => translate('mark_completed');
  String get statusUpdated => translate('status_updated');
  String get completed => translate('completed');
  String get cancelled => translate('cancelled');
  String get pending => translate('pending');
  String get noUsers => translate('no_users');
  String get roleUpdated => translate('role_updated');
  String get noClients => translate('no_clients');
  String get reportDate => translate('report_date');
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => 
    ['ru', 'en', 'uz', 'tg', 'qya', 'os', 'uk', 'sah', 'cu'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}