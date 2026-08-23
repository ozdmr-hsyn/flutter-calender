import 'package:flutter/material.dart';

import '../utils/calendar_date_utils.dart';
import '../utils/event_store.dart';

/// Seçili ayın günleri — artık "buton/chip" değil, dairesel takvimin
/// kendi diliyle (ince alt çizgi + ay rengi vurgusu) uyumlu, düz bir şerit.
class DayStripSelector extends StatelessWidget {
  final int year;
  final int monthIndex;
  final int? selectedDayOfYear;
  final int todayYear;
  final int todayDayOfYear;
  final bool isDark;
  final ValueChanged<int> onDaySelected;

  const DayStripSelector({
    super.key,
    required this.year,
    required this.monthIndex,
    required this.selectedDayOfYear,
    required this.todayYear,
    required this.todayDayOfYear,
    required this.isDark,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    final daysInMonth = CalendarDateUtils.getMonthDays(monthIndex, year);
    final firstOfMonth = DateTime(year, monthIndex + 1, 1);
    final firstDayOfYearIndex = CalendarDateUtils.getDayOfYearIndex(firstOfMonth);
    final accent = CalendarDateUtils.getSeasonInfo(monthIndex).color;

    return SizedBox(
      height: 58,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: daysInMonth,
        itemBuilder: (context, i) {
          final dayOfYearIndex = firstDayOfYearIndex + i;
          final date = firstOfMonth.add(Duration(days: i));
          final isSelected = selectedDayOfYear == dayOfYearIndex;
          final isToday = todayYear == year && todayDayOfYear == dayOfYearIndex;
          final hasEvents = EventStore().getEventsForDay(year, dayOfYearIndex).isNotEmpty;

          final textColor = isSelected
              ? accent
              : isToday
                  ? Colors.redAccent
                  : (isDark ? Colors.white70 : Colors.black87);

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onDaySelected(dayOfYearIndex),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 34,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.only(top: 6),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isSelected ? accent : Colors.transparent,
                    width: 2.5,
                  ),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    CalendarDateUtils.weekdayNames[date.weekday - 1].substring(0, 2),
                    style: TextStyle(
                      fontSize: 10,
                      color: isDark ? Colors.white38 : Colors.black38,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${date.day}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: isSelected || isToday ? FontWeight.w900 : FontWeight.w500,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: hasEvents ? accent : Colors.transparent,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}