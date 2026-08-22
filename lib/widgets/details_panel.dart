import 'package:flutter/material.dart';

import '../utils/calendar_date_utils.dart';

/// Seçili gün/hafta/ay için (ya da hiçbiri seçili değilse bugün için)
/// detay kartını gösteren panel.
///
/// Önceden [_TakvimHomeScreenState._buildDetailsPanel] ve
/// [_TakvimHomeScreenState._buildDetailCard] metodlarının içindeydi.
class DetailsPanel extends StatelessWidget {
  final int selectedYear;
  final int? selectedMonth;
  final int? selectedWeek;
  final int? selectedDay;

  final DateTime today;
  final int todayYear;
  final int todayMonthIndex;
  final int todayDayIndex;

  final ValueChanged<int> onSelectMonth;
  final ValueChanged<int> onSelectWeek;
  final ValueChanged<int> onSelectDay;

  const DetailsPanel({
    super.key,
    required this.selectedYear,
    required this.selectedMonth,
    required this.selectedWeek,
    required this.selectedDay,
    required this.today,
    required this.todayYear,
    required this.todayMonthIndex,
    required this.todayDayIndex,
    required this.onSelectMonth,
    required this.onSelectWeek,
    required this.onSelectDay,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedMonth == null && selectedWeek == null && selectedDay == null) {
      return _buildTodayCard();
    }
    if (selectedMonth != null) {
      return _buildMonthCard(selectedMonth!);
    }
    if (selectedWeek != null) {
      return _buildWeekCard(selectedWeek!);
    }
    if (selectedDay != null) {
      return _buildDayCard(selectedDay!);
    }
    return const SizedBox.shrink();
  }

  Widget _buildTodayCard() {
    final todayFormatted =
        "${today.day} ${CalendarDateUtils.getMonthName(todayMonthIndex)} $todayYear";

    return _DetailCard(
      title: 'BUGÜN',
      subtitle: todayFormatted,
      badgeText: 'Şimdi',
      badgeColor: Colors.redAccent,
      content: Text(
        'Yılın ${todayDayIndex + 1}. günü, ${CalendarDateUtils.getWeekOfYear(today)}. haftası '
        've ${CalendarDateUtils.getMonthName(todayMonthIndex)} ayındayız.',
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildMonthCard(int monthIndex) {
    final monthName = CalendarDateUtils.getMonthName(monthIndex);
    final seasonInfo = CalendarDateUtils.getSeasonInfo(monthIndex);
    final monthWeeks = CalendarDateUtils.getWeeksForMonth(monthIndex, selectedYear);

    return _DetailCard(
      title: '$monthName $selectedYear',
      subtitle: '${CalendarDateUtils.getMonthDays(monthIndex, selectedYear)} Gün',
      badgeText: seasonInfo.name,
      badgeColor: seasonInfo.color,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mevsim: ${seasonInfo.name} (${seasonInfo.description})',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 4.0,
            runSpacing: 4.0,
            children: monthWeeks.map<Widget>((wIndex) {
              final wNum = wIndex + 1;
              return ActionChip(
                visualDensity: VisualDensity.compact,
                labelPadding: const EdgeInsets.symmetric(horizontal: 2.0),
                labelStyle: const TextStyle(fontSize: 11),
                label: Text('$wNum'),
                backgroundColor: Colors.teal.withOpacity(0.1),
                onPressed: () => onSelectWeek(wIndex),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekCard(int weekIndex) {
    final parentMonthIndex = CalendarDateUtils.getMonthForWeek(weekIndex, selectedYear);
    final parentMonthName = CalendarDateUtils.getMonthName(parentMonthIndex);
    final dateRangeStr = CalendarDateUtils.getWeekRangeString(weekIndex, selectedYear);

    return _DetailCard(
      title: '${weekIndex + 1}. HAFTA',
      subtitle: dateRangeStr,
      badgeText: '$parentMonthName Ayı',
      badgeColor: CalendarDateUtils.getSeasonInfo(parentMonthIndex).color,
      content: Row(
        children: [
          Expanded(
            child: Text(
              'Bu hafta, $parentMonthName ayı sınırları içerisindedir.',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(width: 8),
          TextButton.icon(
            icon: const Icon(Icons.calendar_month, size: 16),
            label: Text(parentMonthName, style: const TextStyle(fontSize: 12)),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              visualDensity: VisualDensity.compact,
            ),
            onPressed: () => onSelectMonth(parentMonthIndex),
          ),
        ],
      ),
    );
  }

  Widget _buildDayCard(int dayIndex) {
    final date = DateTime(selectedYear, 1, 1).add(Duration(days: dayIndex));
    final monthIndex = date.month - 1;
    final monthName = CalendarDateUtils.getMonthName(monthIndex);
    final weekIndex = CalendarDateUtils.getWeekOfYear(date) - 1;
    final weekdayName = CalendarDateUtils.weekdayNames[date.weekday - 1];

    return _DetailCard(
      title: '${date.day} $monthName',
      subtitle: weekdayName,
      badgeText: '${dayIndex + 1}. gün',
      badgeColor: CalendarDateUtils.getSeasonInfo(monthIndex).color,
      content: Row(
        children: [
          Expanded(
            child: Text(
              'Bu gün, $monthName ayının ${weekIndex + 1}. haftasında yer alıyor.',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(width: 4),
          TextButton(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              visualDensity: VisualDensity.compact,
            ),
            onPressed: () => onSelectWeek(weekIndex),
            child: Text('${weekIndex + 1}. Hf', style: const TextStyle(fontSize: 12)),
          ),
          TextButton(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              visualDensity: VisualDensity.compact,
            ),
            onPressed: () => onSelectMonth(monthIndex),
            child: Text(monthName, style: const TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

/// Detay panelindeki ortak kart çerçevesi (başlık, alt başlık, rozet, içerik).
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
                        Text(
                          title.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.teal,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: badgeColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: badgeColor, width: 1.2),
                    ),
                    child: Text(
                      badgeText,
                      style: TextStyle(
                        color: badgeColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 4.0),
                child: Divider(height: 1),
              ),
              content,
            ],
          ),
        ),
      ),
    );
  }
}