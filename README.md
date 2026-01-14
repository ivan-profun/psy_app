
 # Psy App — психологическая помощь (Flutter)

 Мобильное приложение на Flutter для организации и получения психологической помощи: пользователи могут читать статьи, записываться на консультации по свободным слотам и управлять настройками. Приложение использует Firebase (Auth + Cloud Firestore) и поддерживает локализацию.

 ## Возможности

 - **Аутентификация**
   - **[Firebase Auth]** вход/выход (см. `AuthWrapper`).
 - **Статьи**
   - **[Студент]** просмотр опубликованных статей.
   - **[Психолог]** создание/редактирование статей и публикация/черновики.
 - **Запись на консультацию**
   - **[Студент]** просмотр ближайших слотов и бронирование.
   - **[Психолог/админ]** добавление слотов, просмотр своих слотов и записей.
 - **Профиль по ролям**
   - Разные UI-блоки для ролей `student`, `psychologist`, `admin`.
 - **Настройки приложения**
   - Тема (light/dark/system), размер шрифта (через `textScaleFactor`), язык.
   - Персистентность настроек через `SharedPreferences`.
 - **Локализация**
   - Встроенная локализация через `AppLocalizations` (словарь строк внутри проекта).

 ## Технологии и зависимости

 - **Flutter / Dart** (SDK: `^3.10.7`)
 - **Provider** — внедрение зависимостей и управление состоянием (DI + state)
 - **Firebase**
   - `firebase_core` — инициализация
   - `firebase_auth` — авторизация
   - `cloud_firestore` — хранение данных
 - **Локальное хранилище**
   - `shared_preferences` — настройки
   - `sqflite`, `path_provider` — подключены (в текущей реализации основной упор на Firestore)
 - **Прочее**
   - `intl` — форматирование дат/локали
   - `http`, `google_sign_in`, `googleapis`, `googleapis_auth` — зависимости под интеграции (в проекте заложены, могут использоваться частично)

 ## Быстрый старт

 ### Предварительные требования

 - Установленный **Flutter SDK**
 - Настроенный **Android Studio / VS Code** или другой IDE
 - Аккаунт Firebase и настроенный проект Firebase

 ### Установка

 1. Установить зависимости:
    - `flutter pub get`
 2. Запуск:
    - `flutter run`

 ### Firebase

 Проект уже содержит файл `lib/firebase_options.dart` (генерируется FlutterFire CLI). В реальном публичном репозитории такие значения обычно не хранятся “как есть”; для сдачи/демо это допустимо, но для production лучше выносить конфигурации и ограничивать ключи правилами.

 Инициализация Firebase происходит в `lib/main.dart`:
 - `WidgetsFlutterBinding.ensureInitialized()`
 - `Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)`

 ## Структура проекта

 Основной код лежит в `lib/`:

 - **`lib/main.dart`**
   - Точка входа (`main()`), инициализация Firebase, сборка `MaterialApp`.
   - Регистрация провайдеров (`MultiProvider`).
 - **`lib/core/`** — “ядро” приложения
   - **`core/services/`**: сервисы, работа с внешним миром
     - `FirebaseService` — единая точка доступа к Auth/Firestore (CRUD + стримы)
   - **`core/providers/`**: состояние приложения
     - `SettingsProvider` — тема/язык/размер шрифта/переключатели уведомлений
   - **`core/l10n/`**: локализация
     - `AppLocalizations` — словари строк по языкам + delegate
   - **`core/navigation/`**
     - `navigatorKey` — глобальный ключ навигации
 - **`lib/data/`** — модели данных
   - `models/*.dart` — модели Firestore (`UserModel`, `ArticleModel`, `ScheduleSlot`, `AppointmentModel`, `NoteModel` и т.д.)
 - **`lib/presentation/`** — UI слой
   - `screens/` — экраны
   - `theme/` — тема приложения (`AppTheme`)
   - `widgets/` — переиспользуемые виджеты (если есть)

 ## Архитектура

 В проекте используется **слоистая архитектура** (layered):

 - **Presentation (UI)** — отображение и взаимодействия
   - Flutter-виджеты, `FutureBuilder/StreamBuilder`, обработка событий UI.
 - **Core (Application/Services/State)** — бизнес-доступ к данным и состоянию
   - `FirebaseService` скрывает детали Firestore/Auth.
   - `SettingsProvider` хранит настройки и уведомляет UI.
 - **Data (Models)** — типы данных и преобразование
   - Модели отвечают за преобразование `Map<String, dynamic>` (Firestore) в строгие типы Dart.

 Это не “чистая Clean Architecture” в полном виде (нет отдельных репозиториев/юзкейсов/интерфейсов), но **принцип разделения ответственности** уже соблюдён: UI не общается с Firestore напрямую и не хранит глобальные данные сам.

 ## Data Flow (поток данных)

 Пример: **показ списка статей**

 - **UI** (`ArticlesListScreen`) подписывается на поток: `FirebaseService.getArticlesStream()`.
 - **FirebaseService** делает запрос в Firestore (`collection('articles')`, фильтр `isPublished == true`) и отдаёт `Stream<List<ArticleModel>>`.
 - **Модель** `ArticleModel.fromFirestore(...)` превращает документ Firestore в типизированный объект.
 - **UI** строит список карточек.

 Пример: **запись студента на слот**

 - UI вызывает `FirebaseService.bookAppointment(slot)`.
 - Сервис:
   - проверяет авторизацию
   - проверяет роль пользователя
   - обновляет слот в `schedule` (делает `isAvailable=false`, пишет `studentId`)
   - создаёт документ в `appointments`

 ## Роли и доступ

 В приложении есть роли:
 - `student`
 - `psychologist`
 - `admin`

 Роль хранится в `users/{uid}.role` и читается через `FirebaseService.getUserRole()`.

 ## Модель данных Firestore (концептуально)

 На уровне кода видны коллекции:

 - **`users`**
   - поля: `email`, `name`, `role`, `avatarUrl?`, `createdAt`
 - **`articles`**
   - поля: `title`, `content`, `authorId`, `isPublished`, `createdAt`, `updatedAt`
 - **`schedule`** (слоты)
   - поля: `psychologistId`, `datetime`, `isAvailable`, `studentId?`, `createdAt`
 - **`appointments`** (записи)
   - поля: `studentId`, `psychologistId`, `datetime`, `status`, `comment?`, `createdAt`
 - **`notes`**
   - поля (по коду сервиса): `appointmentId`, `authorId`, `text`, `createdAt`

 Важно: в некоторых местах предусмотрена совместимость с полем `dateTime` (альтернативное имя) — это сделано для миграций/разных вариантов схемы.

 ## Локализация

 `AppLocalizations` реализован как словарь строк в коде.
 - Плюсы: просто, прозрачно, легко объяснить
 - Минусы: при росте проекта сложнее сопровождать, чем ARB/intl-генерация

 В `main.dart` локаль выбирается через `SettingsProvider.language`.

 ## Управление состоянием и DI

 Используется `provider`:

 - `Provider<FirebaseService>` — зависимость “сервис” (обычно singleton по жизненному циклу приложения)
 - `ChangeNotifierProvider<SettingsProvider>` — изменяемое состояние настроек

 UI подписывается через:
 - `context.watch<T>()` — перестроение при изменениях
 - `context.read<T>()` — доступ без подписки

 Это можно объяснять как:
 - **DI (Dependency Injection)**: сервис/провайдер предоставляются через дерево виджетов.
 - **Observer pattern**: `ChangeNotifier` оповещает слушателей через `notifyListeners()`.

 ## Темы и доступность

 Тема задаётся в `presentation/theme/app_theme.dart`:
 - `ThemeData` для light/dark, `Material 3`
 - Настройка `BottomNavigationBarThemeData`, `InputDecorationTheme`, кнопок, карточек

 Масштаб текста:
 - в `MaterialApp.builder` применяется `MediaQuery.copyWith(textScaleFactor: settings.textScaleFactor)`

 ## Тесты

 В проекте есть базовая папка `test/` (по умолчанию `widget_test.dart`). При необходимости можно добавлять:
 - widget tests (отрисовка экранов)
 - unit tests (модели, форматирование, валидации)
 - интеграционные тесты (Firebase обычно мокается)

 ## FAQ

 ### Почему `StatelessWidget` и `StatefulWidget`?

 - **`StatelessWidget`** — не хранит изменяемое состояние внутри; зависит только от входных параметров и внешних провайдеров.
 - **`StatefulWidget`** — хранит локальное состояние (например `_selectedIndex` в нижней навигации или флаги загрузки).

 ### Что такое `FutureBuilder` и `StreamBuilder`?

 - **`FutureBuilder`** строит UI по результату *однократной* асинхронной операции (например, прочитать роль пользователя).
 - **`StreamBuilder`** строит UI по *потоку событий* (например, live-обновления Firestore).

 ### Какие паттерны использованы?

 - **Observer**: `ChangeNotifier` + `notifyListeners()`.
 - **Dependency Injection**: `Provider`/`MultiProvider`.
 - **Repository-like Service**: `FirebaseService` как единый фасад к данным.
 - **MVC-like separation**: UI отдельно, данные/сервисы отдельно (хотя контроллеры в явном виде не выделены).

 ### Как соблюдается SRP (Single Responsibility Principle)?

 - UI-экраны отвечают за отображение и обработку действий пользователя.
 - `FirebaseService` отвечает за доступ к данным и операции над ними.
 - `SettingsProvider` отвечает за состояние настроек и их сохранение.
 - Модели отвечают за сериализацию/десериализацию.

 ### Почему не хранить состояние в глобальных переменных?

 Потому что:
 - сложно контролировать жизненный цикл
 - сложно тестировать
 - сложно обеспечивать реактивное обновление UI

 Provider даёт управляемый, предсказуемый способ распространять зависимости/состояние.

 ### Где “база” ООП в проекте?

 - **Инкапсуляция**: детали Firestore спрятаны внутри `FirebaseService`.
 - **Абстракции**: модели (`UserModel`, `ArticleModel`, …) дают типизированное представление данных.
 - **Полиморфизм**: используется через Flutter-виджеты (единый интерфейс `Widget`) и переопределение `build()`.

 ## Безопасность и правила Firestore (важно для реального использования)

 Для production необходимо:
 - настроить Firestore Security Rules (разрешения по ролям)
 - ограничить чтение/запись: например, студент не должен видеть чужие записи и т.п.
 - валидировать данные и защищать операции (например, бронирование слота делать транзакцией)

 ## Статус проекта

 Проект демонстрирует рабочий функционал (UI + Firebase) и может расширяться: добавить отдельный слой репозиториев/юзкейсов, транзакции Firestore, полноценную авторизацию по ролям, миграции схемы, более строгие тесты.
