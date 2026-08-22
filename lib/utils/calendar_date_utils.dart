import 'package:flutter/material.dart';

import '../models/season_info.dart';

/// Takvim ile ilgili tüm tarih hesaplamalarını tek yerde toplar.
/// Önceden bu fonksiyonlar TakvimHomeScreen, CircularCalendar ve
/// CircularCalendarPainter içinde ayrı ayrı kopyalanmıştı.
class CalendarDateUtils {
  CalendarDateUtils._(); // instantiate edilemesin

  static bool isLeapYear(int year) {
    return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
  }

  static int daysInYear(int year) => isLeapYear(year) ? 366 : 365;

  static int getWeekOfYear(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final daysOffset = date.difference(firstDayOfYear).inDays;
    int week = (daysOffset / 7).floor() + 1;
    if (week > 52) week = 52;
    return week;
  }

  static int getDayOfYearIndex(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    return date.difference(firstDayOfYear).inDays;
  }

  static const List<String> monthNames = [
    'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
    'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
  ];

  static const List<String> monthNamesShort = [
    'Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz', 'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara'
  ];

  static const List<String> weekdayNames = [
    'Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma', 'Cumartesi', 'Pazar'
  ];

  static String getMonthName(int index) => monthNames[index % 12];

  static int getMonthDays(int index, int year) {
    const days = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    int m = index % 12;
    if (m == 1 && isLeapYear(year)) {
      return 29;
    }
    return days[m];
  }

  static SeasonInfo getSeasonInfo(int monthIndex) {
    switch (monthIndex) {
      case 11: // Dec
      case 0: // Jan
      case 1: // Feb
        return const SeasonInfo('Kış', Colors.blue, 'Kar ve soğuk havalar');
      case 2: // Mar
      case 3: // Apr
      case 4: // May
        return const SeasonInfo('İlkbahar', Colors.green, 'Doğanın uyanışı');
      case 5: // Jun
      case 6: // Jul
      case 7: // Aug
        return const SeasonInfo('Yaz', Colors.orange, 'Sıcak tatil günleri');
      case 8: // Sep
      case 9: // Oct
      case 10: // Nov
        return const SeasonInfo('Sonbahar', Colors.brown, 'Hüzünlü güz ve dökülen yapraklar');
      default:
        return const SeasonInfo('Bilinmeyen', Colors.grey, '');
    }
  }

  /// [CircularCalendarPainter] içindeki ay renkleri, [getSeasonInfo] ile aynı
  /// mevsim eşlemesini kullanır ama koyu/açık tema için farklı ton döner.
  static Color getMonthRingColor(int monthIndex, bool isDark) {
    switch (monthIndex) {
      case 11:
      case 0:
      case 1:
        return isDark ? Colors.blue.shade900 : Colors.blue.shade200;
      case 2:
      case 3:
      case 4:
        return isDark ? Colors.green.shade900 : Colors.green.shade200;
      case 5:
      case 6:
      case 7:
        return isDark ? Colors.orange.shade900 : Colors.orange.shade200;
      case 8:
      case 9:
      case 10:
        return isDark ? Colors.brown.shade900 : Colors.brown.shade200;
      default:
        return Colors.teal;
    }
  }

  static int getMonthForWeek(int weekIndex, int year) {
    final firstDayOfYear = DateTime(year, 1, 1);
    final midDayOfWeek = firstDayOfYear.add(Duration(days: weekIndex * 7 + 3));
    return midDayOfWeek.month - 1;
  }

  static List<int> getWeeksForMonth(int monthIndex, int year) {
    List<int> weeks = [];
    for (int w = 0; w < 52; w++) {
      if (getMonthForWeek(w, year) == monthIndex) {
        weeks.add(w);
      }
    }
    return weeks;
  }

  static String getWeekRangeString(int weekIndex, int year) {
    final firstDayOfYear = DateTime(year, 1, 1);
    final startOfWeek = firstDayOfYear.add(Duration(days: weekIndex * 7));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    final startDay = startOfWeek.day;
    final startMonth = monthNamesShort[startOfWeek.month - 1];
    final endDay = endOfWeek.day;
    final endMonth = monthNamesShort[endOfWeek.month - 1];

    if (startOfWeek.month == endOfWeek.month) {
      return '$startDay - $endDay $startMonth $year';
    } else {
      return '$startDay $startMonth - $endDay $endMonth $year';
    }
  }
}