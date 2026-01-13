import 'dart:async';
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
    final controller = StreamController<List<ArticleModel>>();
    
    _firestore
        .collection('articles')
        .where('isPublished', isEqualTo: true)
        .snapshots()
        .listen(
          (snapshot) {
            try {
              final articles = snapshot.docs
                  .map((doc) => ArticleModel.fromFirestore(doc.data(), doc.id))
                  .toList();
              
              // Сортируем на клиенте
              articles.sort((a, b) => b.createdAt.compareTo(a.createdAt));
              controller.add(articles);
            } catch (e) {
              print('Ошибка обработки статей: $e');
              controller.add(<ArticleModel>[]);
            }
          },
          onError: (error) {
            print('Ошибка при получении статей: $error');
            controller.add(<ArticleModel>[]);
          },
        );
    
    controller.onCancel = () {};
    return controller.stream;
  }

  // ========== APPOINTMENTS ==========
  Stream<List<AppointmentModel>> getUserAppointmentsStream() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.value([]);

    final controller = StreamController<List<AppointmentModel>>();
    
    _firestore
        .collection('appointments')
        .where('studentId', isEqualTo: userId)
        .snapshots()
        .listen(
          (snapshot) {
            try {
              final appointments = snapshot.docs
                  .map((doc) => AppointmentModel.fromFirestore(doc.data(), doc.id))
                  .toList();
              
              // Сортируем на клиенте
              appointments.sort((a, b) => b.datetime.compareTo(a.datetime));
              controller.add(appointments);
            } catch (e) {
              print('Ошибка обработки записей: $e');
              controller.add(<AppointmentModel>[]);
            }
          },
          onError: (error) {
            print('Ошибка при получении записей: $error');
            controller.add(<AppointmentModel>[]);
          },
        );
    
    controller.onCancel = () {};
    return controller.stream;
  }

  // ========== SCHEDULES ==========
  Stream<List<ScheduleModel>> getAvailableSchedulesStream() {
    final controller = StreamController<List<ScheduleModel>>();
    
    _firestore
        .collection('schedule')
        .where('isAvailable', isEqualTo: true)
        .snapshots()
        .listen(
          (snapshot) {
            try {
              final now = DateTime.now();
              final schedules = snapshot.docs
                  .map((doc) => ScheduleModel.fromFirestore(doc.data(), doc.id))
                  .where((schedule) => schedule.date.isAfter(now) || schedule.date.isAtSameMomentAs(now))
                  .toList();
              
              // Сортируем на клиенте
              schedules.sort((a, b) => a.date.compareTo(b.date));
              controller.add(schedules);
            } catch (e) {
              print('Ошибка обработки расписания: $e');
              controller.add(<ScheduleModel>[]);
            }
          },
          onError: (error) {
            print('Ошибка при получении расписания: $error');
            controller.add(<ScheduleModel>[]);
          },
        );
    
    controller.onCancel = () {};
    return controller.stream;
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
    final controller = StreamController<List<NoteModel>>();
    
    _firestore
        .collection('notes')
        .where('appointmentId', isEqualTo: appointmentId)
        .snapshots()
        .listen(
          (snapshot) {
            try {
              final notes = snapshot.docs
                  .map((doc) => NoteModel.fromFirestore(doc.data(), doc.id))
                  .toList();
              
              // Сортируем на клиенте
              notes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
              controller.add(notes);
            } catch (e) {
              print('Ошибка обработки заметок: $e');
              controller.add(<NoteModel>[]);
            }
          },
          onError: (error) {
            print('Ошибка при получении заметок: $error');
            controller.add(<NoteModel>[]);
          },
        );
    
    controller.onCancel = () {};
    return controller.stream;
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

  Future<void> updateScheduleSlot({
    required String slotId,
    DateTime? datetime,
    bool? isAvailable,
  }) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('Пользователь не авторизован');

    final slotDoc = await _firestore.collection('schedule').doc(slotId).get();
    if (!slotDoc.exists) throw Exception('Слот не найден');

    final slotData = slotDoc.data();
    if (slotData == null) throw Exception('Слот не найден');

    if ((slotData['psychologistId'] as String?) != userId) {
      throw Exception('Недостаточно прав для изменения слота');
    }

    if (slotData['studentId'] != null) {
      throw Exception('Нельзя редактировать забронированный слот');
    }

    final updateData = <String, dynamic>{};
    if (datetime != null) updateData['datetime'] = Timestamp.fromDate(datetime);
    if (isAvailable != null) updateData['isAvailable'] = isAvailable;

    if (updateData.isEmpty) return;
    await _firestore.collection('schedule').doc(slotId).update(updateData);
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
    final controller = StreamController<List<ScheduleSlot>>();
    
    _firestore
        .collection('schedule')
        .snapshots()
        .listen(
          (snapshot) {
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
              controller.add(slots.take(limit).toList());
            } catch (e) {
              print('Ошибка обработки слотов: $e');
              controller.add(<ScheduleSlot>[]);
            }
          },
          onError: (error) {
            print('Ошибка при получении слотов: $error');
            controller.add(<ScheduleSlot>[]);
          },
        );
    
    controller.onCancel = () {
      // Stream будет закрыт автоматически при отмене подписки
    };
    
    return controller.stream;
  }

  // Получить слоты психолога
  Stream<List<ScheduleSlot>> getPsychologistSlotsStream(String psychologistId) {
    final controller = StreamController<List<ScheduleSlot>>();
    
    _firestore
        .collection('schedule')
        .where('psychologistId', isEqualTo: psychologistId)
        .snapshots()
        .listen(
          (snapshot) {
            try {
              final slots = snapshot.docs
                  .map((doc) {
                    try {
                      final data = doc.data();
                      if (data['datetime'] == null && data['dateTime'] == null) {
                        return null;
                      }
                      return ScheduleSlot.fromFirestore(data, doc.id);
                    } catch (e) {
                      print('Ошибка парсинга слота ${doc.id}: $e');
                      return null;
                    }
                  })
                  .where((slot) => slot != null)
                  .cast<ScheduleSlot>()
                  .toList();
              
              // Сортируем на клиенте
              slots.sort((a, b) => a.datetime.compareTo(b.datetime));
              controller.add(slots);
            } catch (e) {
              print('Ошибка обработки слотов психолога: $e');
              controller.add(<ScheduleSlot>[]);
            }
          },
          onError: (error) {
            print('Ошибка при получении слотов психолога: $error');
            controller.add(<ScheduleSlot>[]);
          },
        );
    
    controller.onCancel = () {};
    return controller.stream;
  }

  // Получить записи психолога
  Stream<List<AppointmentModel>> getPsychologistAppointmentsStream(String psychologistId) {
    final controller = StreamController<List<AppointmentModel>>();
    
    _firestore
        .collection('appointments')
        .where('psychologistId', isEqualTo: psychologistId)
        .snapshots()
        .listen(
          (snapshot) {
            try {
              final appointments = snapshot.docs
                  .map((doc) => AppointmentModel.fromFirestore(doc.data(), doc.id))
                  .toList();
              
              // Сортируем на клиенте
              appointments.sort((a, b) => b.datetime.compareTo(a.datetime));
              controller.add(appointments);
            } catch (e) {
              print('Ошибка обработки записей психолога: $e');
              controller.add(<AppointmentModel>[]);
            }
          },
          onError: (error) {
            print('Ошибка при получении записей психолога: $error');
            controller.add(<AppointmentModel>[]);
          },
        );
    
    controller.onCancel = () {};
    return controller.stream;
  }

  // Добавить слот для психолога
  Future<void> addScheduleSlot({
    required String psychologistId,
    required DateTime datetime,
  }) async {
    await _firestore.collection('schedule').add({
      'psychologistId': psychologistId,
      'datetime': datetime,
      'isAvailable': true,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Удалить слот
  Future<void> deleteScheduleSlot(String slotId) async {
    await _firestore.collection('schedule').doc(slotId).delete();
  }

  // Обновить статус записи
  Future<void> updateAppointmentStatus(String appointmentId, String status) async {
    await _firestore.collection('appointments').doc(appointmentId).update({
      'status': status,
    });
  }

  // Создать запись (для психолога)
  Future<void> createAppointmentForPsychologist({
    required String psychologistId,
    required String studentId,
    required DateTime datetime,
    String? comment,
  }) async {
    await _firestore.collection('appointments').add({
      'studentId': studentId,
      'psychologistId': psychologistId,
      'datetime': datetime,
      'status': 'booked',
      'comment': comment ?? '',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Обновить запись (для психолога)
  Future<void> updateAppointment({
    required String appointmentId,
    String? studentId,
    DateTime? datetime,
    String? status,
    String? comment,
  }) async {
    final updateData = <String, dynamic>{};
    if (studentId != null) updateData['studentId'] = studentId;
    if (datetime != null) updateData['datetime'] = Timestamp.fromDate(datetime);
    if (status != null) updateData['status'] = status;
    if (comment != null) updateData['comment'] = comment;
    
    await _firestore.collection('appointments').doc(appointmentId).update(updateData);
  }

  // Удалить запись (для психолога)
  Future<void> deleteAppointment(String appointmentId) async {
    await _firestore.collection('appointments').doc(appointmentId).delete();
  }

  // Запись на сессию
  Future<void> bookAppointment(ScheduleSlot slot) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('Пользователь не авторизован');

    final role = await getUserRole();
    if (role == 'psychologist' || role == 'admin') {
      throw Exception('Психолог не может записаться на сессию');
    }

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
    final controller = StreamController<List<NoteModel>>();
    
    _firestore
        .collection('notes')
        .where('authorId', isEqualTo: userId)
        .snapshots()
        .listen(
          (snapshot) {
            try {
              final notes = snapshot.docs
                  .map((doc) => NoteModel.fromFirestore(doc.data(), doc.id))
                  .toList();
              
              // Сортируем на клиенте
              notes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
              controller.add(notes);
            } catch (e) {
              print('Ошибка обработки заметок студента: $e');
              controller.add(<NoteModel>[]);
            }
          },
          onError: (error) {
            print('Ошибка при получении заметок студента: $error');
            controller.add(<NoteModel>[]);
          },
        );
    
    controller.onCancel = () {};
    return controller.stream;
  }

  // Для психолога: получить количество статей (динамически)
  Stream<Map<String, int>> getPsychologistArticlesCountStream(String psychologistId) {
    return _firestore
        .collection('articles')
        .where('authorId', isEqualTo: psychologistId)
        .snapshots()
        .map((snapshot) {
          final total = snapshot.docs.length;
          final published = snapshot.docs
              .where((doc) => doc.data()['isPublished'] == true)
              .length;
          return {
            'total': total,
            'published': published,
            'draft': total - published,
          };
        })
        .handleError((error) {
          print('Ошибка при получении статистики статей: $error');
          return {'total': 0, 'published': 0, 'draft': 0};
        });
  }

  // Для психолога: получить количество сессий (динамически)
  Stream<Map<String, int>> getPsychologistSessionsCountStream(String psychologistId) {
    return _firestore
        .collection('appointments')
        .where('psychologistId', isEqualTo: psychologistId)
        .snapshots()
        .map((snapshot) {
          final now = DateTime.now();
          final all = snapshot.docs.length;
          final upcoming = snapshot.docs
              .where((doc) {
                final datetime = (doc.data()['datetime'] as Timestamp?)?.toDate();
                return datetime != null && datetime.isAfter(now);
              })
              .length;
          final completed = snapshot.docs
              .where((doc) => doc.data()['status'] == 'completed')
              .length;
          return {
            'total': all,
            'upcoming': upcoming,
            'completed': completed,
          };
        })
        .handleError((error) {
          print('Ошибка при получении статистики сессий: $error');
          return {'total': 0, 'upcoming': 0, 'completed': 0};
        });
  }

  // Для студента: получить количество завершенных сессий (динамически)
  Stream<int> getCompletedSessionsCountStream(String userId) {
    return _firestore
        .collection('appointments')
        .where('studentId', isEqualTo: userId)
        .where('status', isEqualTo: 'completed')
        .snapshots()
        .map((snapshot) => snapshot.docs.length)
        .handleError((error) {
          print('Ошибка при получении статистики сессий студента: $error');
          return 0;
        });
  }

  // Для админа: получить статистику системы (динамически)
  Stream<Map<String, int>> getSystemStatisticsStream() {
    final controller = StreamController<Map<String, int>>();
    Map<String, int> currentStats = {'total_users': 0, 'total_articles': 0, 'total_appointments': 0};
    StreamSubscription? usersSub;
    StreamSubscription? articlesSub;
    StreamSubscription? appointmentsSub;

    void updateStats() {
      if (!controller.isClosed) {
        controller.add(Map<String, int>.from(currentStats));
      }
    }

    usersSub = _firestore.collection('users').snapshots().listen((snapshot) {
      currentStats['total_users'] = snapshot.docs.length;
      updateStats();
    }, onError: (error) {
      print('Ошибка при получении пользователей: $error');
    });

    articlesSub = _firestore.collection('articles').snapshots().listen((snapshot) {
      currentStats['total_articles'] = snapshot.docs.length;
      updateStats();
    }, onError: (error) {
      print('Ошибка при получении статей: $error');
    });

    appointmentsSub = _firestore.collection('appointments').snapshots().listen((snapshot) {
      currentStats['total_appointments'] = snapshot.docs.length;
      updateStats();
    }, onError: (error) {
      print('Ошибка при получении записей: $error');
    });

    controller.onCancel = () {
      usersSub?.cancel();
      articlesSub?.cancel();
      appointmentsSub?.cancel();
    };

    return controller.stream.handleError((error) {
      print('Ошибка при получении статистики системы: $error');
      return {'total_users': 0, 'total_articles': 0, 'total_appointments': 0};
    });
  }

  // Получить всех пользователей (для админа)
  Stream<List<UserModel>> getAllUsersStream() {
    final controller = StreamController<List<UserModel>>();
    
    _firestore
        .collection('users')
        .snapshots()
        .listen(
          (snapshot) {
            try {
              final users = snapshot.docs
                  .map((doc) => UserModel.fromFirestore(doc.data(), doc.id))
                  .toList();
              
              // Сортируем на клиенте
              users.sort((a, b) => b.createdAt.compareTo(a.createdAt));
              controller.add(users);
            } catch (e) {
              print('Ошибка обработки пользователей: $e');
              controller.add(<UserModel>[]);
            }
          },
          onError: (error) {
            print('Ошибка при получении пользователей: $error');
            controller.add(<UserModel>[]);
          },
        );
    
    controller.onCancel = () {};
    return controller.stream;
  }

  // Получить всех студентов (для психолога)
  Future<List<UserModel>> getStudentsList() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'student')
          .get();
      
      final students = snapshot.docs
          .map((doc) => UserModel.fromFirestore(doc.data(), doc.id))
          .toList();
      
      students.sort((a, b) => a.name.compareTo(b.name));
      return students;
    } catch (e) {
      print('Ошибка получения студентов: $e');
      return [];
    }
  }

  // Обновить роль пользователя (для админа)
  Future<void> updateUserRole(String userId, String role) async {
    await _firestore.collection('users').doc(userId).update({
      'role': role,
      'updatedAt': FieldValue.serverTimestamp(),
    });
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
    final controller = StreamController<List<ArticleModel>>();
    
    _firestore
        .collection('articles')
        .where('authorId', isEqualTo: psychologistId)
        .snapshots()
        .listen(
          (snapshot) {
            try {
              final articles = snapshot.docs
                  .map((doc) => ArticleModel.fromFirestore(doc.data(), doc.id))
                  .toList();
              
              // Сортируем на клиенте
              articles.sort((a, b) => b.createdAt.compareTo(a.createdAt));
              controller.add(articles);
            } catch (e) {
              print('Ошибка обработки статей психолога: $e');
              controller.add(<ArticleModel>[]);
            }
          },
          onError: (error) {
            print('Ошибка при получении статей психолога: $error');
            controller.add(<ArticleModel>[]);
          },
        );
    
    controller.onCancel = () {};
    return controller.stream;
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
    final controller = StreamController<List<ArticleModel>>();
    
    _firestore
        .collection('articles')
        .snapshots()
        .listen(
          (snapshot) {
            try {
              final articles = snapshot.docs
                  .map((doc) => ArticleModel.fromFirestore(doc.data(), doc.id))
                  .where((article) => article.isPublished)
                  .toList();
              
              // Сортируем на клиенте
              articles.sort((a, b) => b.createdAt.compareTo(a.createdAt));
              controller.add(articles.take(limit).toList());
            } catch (e) {
              print('Ошибка обработки последних статей: $e');
              controller.add(<ArticleModel>[]);
            }
          },
          onError: (error) {
            print('Ошибка при получении последних статей: $error');
            controller.add(<ArticleModel>[]);
          },
        );
    
    controller.onCancel = () {};
    return controller.stream;
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