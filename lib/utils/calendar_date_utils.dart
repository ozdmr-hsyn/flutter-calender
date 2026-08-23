import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../models/season_info.dart';

class CalendarDateUtils {
  CalendarDateUtils._();

  static const double baseAngle = -math.pi / 2; // painter/circular_calendar ile aynı sabit

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
    if (m == 1 && isLeapYear(year)) return 29;
    return days[m];
  }

  static SeasonInfo getSeasonInfo(int monthIndex) {
    switch (monthIndex) {
      case 11:
      case 0:
      case 1:
        return const SeasonInfo('Kış', Colors.blue, 'Kar ve soğuk havalar');
      case 2:
      case 3:
      case 4:
        return const SeasonInfo('İlkbahar', Colors.green, 'Doğanın uyanışı');
      case 5:
      case 6:
      case 7:
        return const SeasonInfo('Yaz', Colors.orange, 'Sıcak tatil günleri');
      case 8:
      case 9:
      case 10:
        return const SeasonInfo('Sonbahar', Colors.brown, 'Hüzünlü güz ve dökülen yapraklar');
      default:
        return const SeasonInfo('Bilinmeyen', Colors.grey, '');
    }
  }

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
      if (getMonthForWeek(w, year) == monthIndex) weeks.add(w);
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

  /// Verilen dönüş açısında (radyan), tekerleğin SAĞ yarımında (ekranın
  /// sağ yarısında, x>0 tarafında) hangi ayların sektörü düşüyorsa onları
  /// döner. Painter'daki baseAngle ile aynı referans kullanılıyor.
  static List<int> monthsInRightHalf(double rotationAngle) {
    const monthSweep = 2 * math.pi / 12;
    final result = <int>[];
    for (int i = 0; i < 12; i++) {
      final mid = baseAngle + i * monthSweep + monthSweep / 2 + rotationAngle;
      double norm = mid % (2 * math.pi);
      if (norm < 0) norm += 2 * math.pi;
      if (norm < math.pi / 2 || norm > 3 * math.pi / 2) {
        result.add(i);
      }
    }
    return result;
  }
}