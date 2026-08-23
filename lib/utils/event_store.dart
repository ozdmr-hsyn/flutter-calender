import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/activity_event.dart';

class EventStore extends ChangeNotifier {
  static final EventStore _instance = EventStore._internal();
  factory EventStore() => _instance;
  EventStore._internal();

  List<ActivityEvent> _events = [];
  bool _isLoaded = false;

  List<ActivityEvent> get events => List.unmodifiable(_events);
  bool get isLoaded => _isLoaded;

  Future<void> loadEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final String? eventsJson = prefs.getString('events');
    if (eventsJson != null) {
      final List<dynamic> decoded = jsonDecode(eventsJson);
      _events = decoded.map((e) => ActivityEvent.fromJson(e)).toList();
    }
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> _saveEvents() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('events', jsonEncode(_events.map((e) => e.toJson()).toList()));
  }

  Future<void> addEvent(ActivityEvent event) async {
    _events.add(event);
    await _saveEvents();
    notifyListeners();
  }

  Future<void> updateEvent(ActivityEvent event) async {
    final index = _events.indexWhere((e) => e.id == event.id);
    if (index != -1) {
      _events[index] = event;
      await _saveEvents();
      notifyListeners();
    }
  }

  Future<void> deleteEvent(String id) async {
    _events.removeWhere((e) => e.id == id);
    await _saveEvents();
    notifyListeners();
  }

  Future<void> togglePin(String id) async {
    final index = _events.indexWhere((e) => e.id == id);
    if (index != -1) {
      _events[index] = _events[index].copyWith(isPinned: !_events[index].isPinned);
      await _saveEvents();
      notifyListeners();
    }
  }

  Future<void> toggleCompleted(String id) async {
    final index = _events.indexWhere((e) => e.id == id);
    if (index != -1) {
      _events[index] = _events[index].copyWith(isCompleted: !_events[index].isCompleted);
      await _saveEvents();
      notifyListeners();
    }
  }

  List<ActivityEvent> getEventsForDay(int year, int dayOfYearIndex) {
    return _events.where((e) {
      final eventDayIndex = _dayOfYearIndex(e.startTime);
      return e.startTime.year == year && eventDayIndex == dayOfYearIndex;
    }).toList();
  }

  int _dayOfYearIndex(DateTime date) {
    return date.difference(DateTime(date.year, 1, 1)).inDays;
  }
}