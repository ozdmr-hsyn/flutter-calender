import 'package:flutter/material.dart';

enum EventType { event, note, task, reminder }

class ActivityEvent {
  final String id;
  final String title;
  final String description;
  final EventType type;
  final Color color;
  final DateTime startTime;
  final bool isAllDay;
  final bool isCompleted;
  final bool isPinned;
  final DateTime createdAt;

  ActivityEvent({
    required this.id,
    required this.title,
    this.description = '',
    this.type = EventType.event,
    this.color = Colors.teal,
    required this.startTime,
    this.isAllDay = true,
    this.isCompleted = false,
    this.isPinned = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'type': type.index,
        'color': color.toARGB32(),
        'startTime': startTime.toIso8601String(),
        'isAllDay': isAllDay,
        'isCompleted': isCompleted,
        'isPinned': isPinned,
        'createdAt': createdAt.toIso8601String(),
      };

  factory ActivityEvent.fromJson(Map<String, dynamic> json) => ActivityEvent(
        id: json['id'],
        title: json['title'],
        description: json['description'] ?? '',
        type: EventType.values[json['type'] ?? 0],
        color: Color(json['color'] ?? Colors.teal.value),
        startTime: DateTime.parse(json['startTime']),
        isAllDay: json['isAllDay'] ?? true,
        isCompleted: json['isCompleted'] ?? false,
        isPinned: json['isPinned'] ?? false,
        createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      );

  ActivityEvent copyWith({
    String? title,
    String? description,
    EventType? type,
    Color? color,
    DateTime? startTime,
    bool? isAllDay,
    bool? isCompleted,
    bool? isPinned,
  }) {
    return ActivityEvent(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      color: color ?? this.color,
      startTime: startTime ?? this.startTime,
      isAllDay: isAllDay ?? this.isAllDay,
      isCompleted: isCompleted ?? this.isCompleted,
      isPinned: isPinned ?? this.isPinned,
      createdAt: createdAt,
    );
  }
}