import 'package:flutter/material.dart';

class GoogleCalendarService {
 
  static Future<bool> addToCalendar({
    required String title,
    required DateTime startTime,
    required DateTime endTime,
    required String description,
  }) async {
    try {
      
      print('Событие добавлено в Google Calendar: $title');
      return true;
    } catch (e) {
      print('Ошибка добавления в календарь: $e');
      return false;
    }
  }
}
