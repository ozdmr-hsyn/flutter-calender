import 'package:flutter/material.dart';

import '../models/activity_event.dart';
import '../utils/calendar_date_utils.dart';

/// Dairenin o anki dönüşüne göre sağ yarımda (180°) kalan ayların
/// TÜM kayıtlarını listeler. "Seçili ay" değil, geometrik pozisyon esas alınır.
class RightHalfEventsPanel extends StatelessWidget {
  final int selectedYear;
  final double rotationAngle;
  final List<ActivityEvent> events;

  const RightHalfEventsPanel({
    super.key,
    required this.selectedYear,
    required this.rotationAngle,
    required this.events,
  });

  @override
  Widget build(BuildContext context) {
    final rightMonths = CalendarDateUtils.monthsInRightHalf(rotationAngle);

    final visible = events
        .where((e) => e.startTime.year == selectedYear && rightMonths.contains(e.startTime.month - 1))
        .toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

    final monthLabel = rightMonths.map((m) => CalendarDateUtils.monthNamesShort[m]).join(' • ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 4, 16, 8),
          child: Text(
            'SAĞ YARIM: $monthLabel',
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.teal, letterSpacing: 0.6),
          ),
        ),
        Expanded(
          child: visible.isEmpty
              ? Center(
                  child: Text('Bu aylarda kayıt yok',
                      style: TextStyle(color: Colors.grey.shade500, fontStyle: FontStyle.italic, fontSize: 12)),
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(right: 16),
                  itemCount: visible.length,
                  itemBuilder: (context, i) => _EventRow(event: visible[i]),
                ),
        ),
      ],
    );
  }
}

class _EventRow extends StatelessWidget {
  final ActivityEvent event;
  const _EventRow({required this.event});

  IconData _icon(EventType t) {
    switch (t) {
      case EventType.event:
        return Icons.event;
      case EventType.note:
        return Icons.note;
      case EventType.task:
        return Icons.task_alt;
      case EventType.reminder:
        return Icons.notifications;
    }
  }

  @override
  Widget build(BuildContext context) {
    final monthName = CalendarDateUtils.getMonthName(event.startTime.month - 1);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: event.color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border(left: BorderSide(color: event.color, width: 3)),
      ),
      child: Row(
        children: [
          Icon(_icon(event.type), size: 15, color: event.color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text('${event.startTime.day} $monthName', style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
              ],
            ),
          ),
          if (event.isPinned) const Icon(Icons.push_pin, size: 13, color: Colors.orange),
        ],
      ),
    );
  }
}