import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/models/article_model.dart';
import '../../data/models/appointment_model.dart';
import '../../data/models/schedule_model.dart';
import '../../data/models/schedule_slot_model.dart';
import '../../data/models/user_model.dart';
import '../../data/models/note_model.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Получение текущего пользователя
  User? get currentUser => _auth.currentUser;
  
  // Получение потока изменений состояния аутентификации
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ========== USERS ==========
  Future<UserModel> getUserData(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (!doc.exists) throw Exception('Пользователь не найден');
    return UserModel.fromFirestore(doc.data()!, doc.id);
  }

  // ========== ARTICLES ==========
  Stream<List<ArticleModel>> getArticlesStream() {
    return _firestore
        .collection('articles')
        .where('isPublished', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ArticleModel.fromFirestore(doc.data(), doc.id))
          .toList();
    });
  }

  // ========== APPOINTMENTS ==========
  Stream<List<AppointmentModel>> getUserAppointmentsStream() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.value([]);

    return _firestore
        .collection('appointments')
        .where('studentId', isEqualTo: userId)
        .orderBy('datetime', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => AppointmentModel.fromFirestore(doc.data(), doc.id))
          .toList();
    });
  }

  // ========== SCHEDULES ==========
  Stream<List<ScheduleModel>> getAvailableSchedulesStream() {
    return _firestore
        .collection('schedule')
        .where('isAvailable', isEqualTo: true)
        .where('datetime', isGreaterThanOrEqualTo: DateTime.now())
        .orderBy('datetime')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ScheduleModel.fromFirestore(doc.data(), doc.id))
          .toList();
    });
  }

  Future<void> createAppointment({
    required String scheduleId,
    required DateTime datetime,
    required String psychologistId,
    String? comment,
  }) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('Пользователь не авторизован');

    await _firestore.collection('appointments').add({
      'studentId': userId,
      'psychologistId': psychologistId,
      'datetime': datetime,
      'status': 'pending',
      'comment': comment ?? '',
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Обновляем расписание
    await _firestore
        .collection('schedule')
        .doc(scheduleId)
        .update({'isAvailable': false});
  }

  // ========== NOTES ==========
  Stream<List<NoteModel>> getNotesByAppointmentId(String appointmentId) {
    return _firestore
        .collection('notes')
        .where('appointmentId', isEqualTo: appointmentId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => NoteModel.fromFirestore(doc.data(), doc.id))
          .toList();
    });
  }

  Future<void> createNote({
    required String appointmentId,
    required String text,
  }) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('Пользователь не авторизован');

    await _firestore.collection('notes').add({
      'appointmentId': appointmentId,
      'authorId': userId,
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // ========== AUTH ==========
  Future<UserCredential> signIn(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> signUp({
    required String email,
    required String password,
    required String name,
    String role = 'student',
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Создаем документ пользователя в Firestore
    await _firestore.collection('users').doc(credential.user!.uid).set({
      'email': email,
      'name': name,
      'role': role,
      'createdAt': FieldValue.serverTimestamp(),
    });

    return credential;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Обновить аватарку пользователя
  Future<void> updateUserAvatar(String base64Avatar) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('Пользователь не авторизован');

    await _firestore.collection('users').doc(userId).update({
      'avatarUrl': base64Avatar,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Получить аватарку пользователя
  Future<String?> getUserAvatar(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (!doc.exists) return null;
    return doc.data()?['avatarUrl'] as String?;
  }

  Stream<List<ScheduleSlot>> getAvailableSlotsStream({int limit = 10}) {
    try {
      // Пробуем получить все слоты и фильтровать на клиенте из-за возможных проблем с правами
      return _firestore
          .collection('schedule')
          .snapshots()
          .map((snapshot) {
            try {
              final now = DateTime.now();
              final slots = snapshot.docs
                  .map((doc) {
                    try {
                      final data = doc.data();
                      // Проверяем наличие необходимых полей (datetime или dateTime)
                      if (data['datetime'] == null && data['dateTime'] == null) {
                        return null;
                      }
                      return ScheduleSlot.fromFirestore(data, doc.id);
                    } catch (e) {
                      print('Ошибка парсинга слота ${doc.id}: $e');
                      return null;
                    }
                  })
                  .where((slot) => slot != null && slot!.isAvailable && slot.datetime.isAfter(now))
                  .cast<ScheduleSlot>()
                  .toList();
              
              // Сортируем и ограничиваем
              slots.sort((a, b) => a.datetime.compareTo(b.datetime));
              return slots.take(limit).toList();
            } catch (e) {
              print('Ошибка обработки слотов: $e');
              return <ScheduleSlot>[];
            }
          })
          .handleError((error) {
            print('Ошибка при получении слотов: $error');
            // Возвращаем пустой список при ошибке
            return <ScheduleSlot>[];
          });
    } catch (e) {
      print('Ошибка инициализации потока слотов: $e');
      return Stream.value(<ScheduleSlot>[]);
    }
  }

  // Запись на сессию
  Future<void> bookAppointment(ScheduleSlot slot) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('Пользователь не авторизован');

    // Обновляем слот
    await _firestore.collection('schedule').doc(slot.id).update({
      'isAvailable': false,
      'studentId': userId,
    });

    // Создаем запись в appointments
    await _firestore.collection('appointments').add({
      'studentId': userId,
      'psychologistId': slot.psychologistId,
      'datetime': slot.datetime,
      'status': 'booked',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Получить количество посещенных сессий для студента
  Future<int> getCompletedSessionsCount(String userId) async {
    final snapshot = await _firestore
        .collection('appointments')
        .where('studentId', isEqualTo: userId)
        .where('status', isEqualTo: 'completed')
        .get();
    return snapshot.docs.length;
  }

  // Получить заметки студента
  Stream<List<NoteModel>> getStudentNotesStream(String userId) {
    return _firestore
        .collection('notes')
        .where('authorId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => NoteModel.fromFirestore(doc.data(), doc.id))
          .toList();
    });
  }

  // Для психолога: получить количество статей
  Future<Map<String, int>> getPsychologistArticlesCount(String psychologistId) async {
    final totalSnapshot = await _firestore
        .collection('articles')
        .where('authorId', isEqualTo: psychologistId)
        .get();
    
    final publishedSnapshot = await _firestore
        .collection('articles')
        .where('authorId', isEqualTo: psychologistId)
        .where('isPublished', isEqualTo: true)
        .get();
    
    return {
      'total': totalSnapshot.docs.length,
      'published': publishedSnapshot.docs.length,
      'draft': totalSnapshot.docs.length - publishedSnapshot.docs.length,
    };
  }

  // Для психолога: получить количество сессий
  Future<Map<String, int>> getPsychologistSessionsCount(String psychologistId) async {
    final allSnapshot = await _firestore
        .collection('appointments')
        .where('psychologistId', isEqualTo: psychologistId)
        .get();
    
    final upcomingSnapshot = await _firestore
        .collection('appointments')
        .where('psychologistId', isEqualTo: psychologistId)
        .where('datetime', isGreaterThanOrEqualTo: DateTime.now())
        .get();
    
    final completedSnapshot = await _firestore
        .collection('appointments')
        .where('psychologistId', isEqualTo: psychologistId)
        .where('status', isEqualTo: 'completed')
        .get();
    
    return {
      'total': allSnapshot.docs.length,
      'upcoming': upcomingSnapshot.docs.length,
      'completed': completedSnapshot.docs.length,
    };
  }

  // Создание/редактирование статьи (для психолога)
  Future<void> saveArticle({
    String? articleId,
    required String title,
    required String content,
    required bool isPublished,
  }) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('Пользователь не авторизован');

    final articleData = {
      'title': title,
      'content': content,
      'authorId': userId,
      'isPublished': isPublished,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (articleId == null) {
      // Создание новой статьи
      articleData['createdAt'] = FieldValue.serverTimestamp();
      await _firestore.collection('articles').add(articleData);
    } else {
      // Обновление существующей
      await _firestore.collection('articles').doc(articleId).update(articleData);
    }
  }

  // Получить статьи психолога
  Stream<List<ArticleModel>> getPsychologistArticlesStream(String psychologistId) {
    return _firestore
        .collection('articles')
        .where('authorId', isEqualTo: psychologistId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ArticleModel.fromFirestore(doc.data(), doc.id))
          .toList();
    });
  }

  // Получить роль пользователя из Firestore
  Future<String> getUserRole() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return 'student';
    
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return doc.data()?['role'] ?? 'student';
      }
      return 'student';
    } catch (e) {
      print('Ошибка получения роли: $e');
      return 'student';
    }
  }

  // Stream для отслеживания роли
  Stream<String> getUserRoleStream() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.value('student');
    
    return _firestore.collection('users').doc(userId).snapshots().map((doc) {
      return doc.data()?['role'] ?? 'student';
    });
  }

  Stream<List<ArticleModel>> getLatestArticlesStream({int limit = 3}) {
    return _firestore
        .collection('articles')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ArticleModel.fromFirestore(doc.data(), doc.id))
          .where((article) => article.isPublished)
          .toList();
    });
  }

  Stream<UserModel?> getCurrentUserStream() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.value(null);

    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((snapshot) {
          if (!snapshot.exists) return null;
          return UserModel.fromFirestore(snapshot.data()!, snapshot.id);
        });
  }
}