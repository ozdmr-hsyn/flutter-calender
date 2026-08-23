import 'package:flutter/material.dart';

import '../models/activity_event.dart';
import '../screens/event_form_screen.dart';
import '../utils/calendar_date_utils.dart';
import '../utils/event_store.dart';

class DetailsPanel extends StatelessWidget {
  final int selectedYear;
  final int selectedMonth;
  final int? selectedDay; // null = ay özeti göster
  final DateTime today;
  final int todayYear;
  final int todayDayIndex;

  const DetailsPanel({
    super.key,
    required this.selectedYear,
    required this.selectedMonth,
    required this.selectedDay,
    required this.today,
    required this.todayYear,
    required this.todayDayIndex,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedDay != null) return _buildDayCard(context, selectedDay!);
    return _buildMonthCard(context);
  }

  Widget _buildMonthCard(BuildContext context) {
    final monthName = CalendarDateUtils.getMonthName(selectedMonth);
    final seasonInfo = CalendarDateUtils.getSeasonInfo(selectedMonth);
    final daysInMonth = CalendarDateUtils.getMonthDays(selectedMonth, selectedYear);

    return _DetailCard(
      title: '$monthName $selectedYear',
      subtitle: '$daysInMonth Gün',
      badgeText: seasonInfo.name,
      badgeColor: seasonInfo.color,
      content: Text(seasonInfo.description, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
    );
  }

  Widget _buildDayCard(BuildContext context, int dayIndex) {
    final date = DateTime(selectedYear, 1, 1).add(Duration(days: dayIndex));
    final monthIndex = date.month - 1;
    final monthName = CalendarDateUtils.getMonthName(monthIndex);
    final weekdayName = CalendarDateUtils.weekdayNames[date.weekday - 1];
    final isToday = selectedYear == todayYear && dayIndex == todayDayIndex;

    return _DetailCard(
      title: '${date.day} $monthName',
      subtitle: weekdayName,
      badgeText: isToday ? 'Bugün' : '${dayIndex + 1}. gün',
      badgeColor: isToday ? Colors.redAccent : CalendarDateUtils.getSeasonInfo(monthIndex).color,
      content: _buildEventsList(context, selectedYear, dayIndex, date),
    );
  }

  Widget _buildEventsList(BuildContext context, int year, int dayIndex, DateTime date) {
    final events = EventStore().getEventsForDay(year, dayIndex);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (events.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 4.0),
            child: Text('Bu gün için planlanmış bir kayıt yok.',
                style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.grey)),
          )
        else
          ...events.map((e) => _buildEventItem(context, e)),
        Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: OutlinedButton.icon(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => EventFormScreen(initialDate: date))),
            icon: const Icon(Icons.add, size: 14),
            label: const Text('Kayıt Ekle', style: TextStyle(fontSize: 11)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
              visualDensity: VisualDensity.compact,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEventItem(BuildContext context, ActivityEvent event) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => EventFormScreen(initialEvent: event))),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: event.color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: event.color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(_getIconForType(event.type), size: 14, color: event.color),
            const SizedBox(width: 8),
            Expanded(
              child: Text(event.title,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ),
            if (event.isPinned) const Icon(Icons.push_pin, size: 12, color: Colors.orange),
            if (event.isCompleted) const Icon(Icons.check_circle, size: 12, color: Colors.green),
          ],
        ),
      ),
    );
  }

  IconData _getIconForType(EventType type) {
    switch (type) {
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
}

class _DetailCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String badgeText;
  final Color badgeColor;
  final Widget content;

  const _DetailCard({
    required this.title,
    required this.subtitle,
    required this.badgeText,
    required this.badgeColor,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(title.toUpperCase(),
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 0.8)),
                        const SizedBox(width: 6),
                        Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.teal, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: badgeColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: badgeColor, width: 1.2),
                    ),
                    child: Text(badgeText, style: TextStyle(color: badgeColor, fontWeight: FontWeight.bold, fontSize: 10)),
                  ),
                ],
              ),
              const Padding(padding: EdgeInsets.symmetric(vertical: 4.0), child: Divider(height: 1)),
              content,
            ],
          ),
        ),
      ),
    );
  }
}