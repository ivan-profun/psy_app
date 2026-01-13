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
      'privacy_policy_text': 'All your data is protected and stored in accordance with the privacy policy. We do not share your information with third parties.',
      'data_security': 'Data Security',
      'data_security_text': 'All data is transmitted over a secure connection and stored in encrypted form.',
      'app_version': 'App Version',
      'terms_of_use': 'Terms of Use',
      'terms_of_use_text': 'By using this app, you agree to the terms of use of the psychological help service.',
      'help_support': 'Help & Support',
      'help_support_text': 'If you have any questions, please contact support: psych-help@university.edu',
      'select_theme': 'Select Theme',
      'select_language': 'Select Language',
      'close': 'Close',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }

  // Геттеры для удобства
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
  String get notifications => translate('notifications');
  String get privacy => translate('privacy');
  String get about => translate('about');
  String get bookAppointment => translate('book_appointment');
  String get bookConfirm => translate('book_confirm');
  String get bookingSuccess => translate('booking_success');
  String get bookingError => translate('booking_error');
  String get permissionDenied => translate('permission_denied');
  String get contactAdmin => translate('contact_admin');
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['ru', 'en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
