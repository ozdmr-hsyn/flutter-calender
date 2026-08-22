import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../utils/calendar_date_utils.dart';
import 'circular_calendar_painter.dart';

/// İç içe halkalardan oluşan dairesel takvim: gün / hafta / ay / yıl.
/// Dokunma ve sürükleme etkileşimlerini yönetir; çizimi
/// [CircularCalendarPainter]'a devreder.
class CircularCalendar extends StatefulWidget {
  final int selectedYear;
  final int? selectedMonth;
  final int? selectedWeek;
  final int? selectedDay;
  final ValueChanged<int> onMonthSelected;
  final ValueChanged<int> onWeekSelected;
  final ValueChanged<int> onDaySelected;
  final VoidCallback onCenterTapped;
  final bool isDark;

  const CircularCalendar({
    super.key,
    required this.selectedYear,
    required this.selectedMonth,
    required this.selectedWeek,
    required this.selectedDay,
    required this.onMonthSelected,
    required this.onWeekSelected,
    required this.onDaySelected,
    required this.onCenterTapped,
    required this.isDark,
  });

  @override
  State<CircularCalendar> createState() => _CircularCalendarState();
}

class _CircularCalendarState extends State<CircularCalendar> {
  int? _hoveredMonth;
  int? _hoveredWeek;
  int? _hoveredDay;
  bool _isCenterHovered = false;

  // Returns (r0 outer, r1, r2, r3) radii for the four rings, dıştan içe:
  // r0-r1 = DAYS (outermost)
  // r1-r2 = WEEKS
  // r2-r3 = MONTHS
  // r3 (center circle) = YEAR
  List<double> _radii(Size size) {
    final minDimension = math.min(size.width, size.height);
    final r0 = minDimension * 0.48; // Outermost - days
    final r1 = minDimension * 0.40; // Weeks
    final r2 = minDimension * 0.32; // Months
    final r3 = minDimension * 0.11; // Center - year
    return [r0, r1, r2, r3];
  }

  void _handleTapDown(TapDownDetails details, Size size) {
    final radii = _radii(size);
    final r0 = radii[0], r1 = radii[1], r2 = radii[2], r3 = radii[3];
    final center = Offset(size.width / 2, size.height / 2);

    final localPosition = details.localPosition;
    final dx = localPosition.dx - center.dx;
    final dy = localPosition.dy - center.dy;
    final distance = math.sqrt(dx * dx + dy * dy);

    if (distance < r3) {
      widget.onCenterTapped();
      return;
    }

    double angle = math.atan2(dy, dx);
    double normalizedAngle = angle - math.pi / 2;
    if (normalizedAngle < 0) {
      normalizedAngle += 2 * math.pi;
    }

    if (distance >= r1 && distance <= r0) {
      final totalDays = CalendarDateUtils.daysInYear(widget.selectedYear);
      final dayIndex = (normalizedAngle / (2 * math.pi) * totalDays).floor().clamp(0, totalDays - 1);
      widget.onDaySelected(dayIndex);
    } else if (distance >= r2 && distance < r1) {
      final weekIndex = (normalizedAngle / (2 * math.pi) * 52).floor() % 52;
      widget.onWeekSelected(weekIndex);
    } else if (distance >= r3 && distance < r2) {
      final monthIndex = (normalizedAngle / (2 * math.pi) * 12).floor() % 12;
      widget.onMonthSelected(monthIndex);
    }
  }

  void _handlePanUpdate(DragUpdateDetails details, Size size) {
    final radii = _radii(size);
    final r0 = radii[0], r1 = radii[1], r2 = radii[2], r3 = radii[3];
    final center = Offset(size.width / 2, size.height / 2);

    final localPosition = details.localPosition;
    final dx = localPosition.dx - center.dx;
    final dy = localPosition.dy - center.dy;
    final distance = math.sqrt(dx * dx + dy * dy);

    double angle = math.atan2(dy, dx);
    double normalizedAngle = angle - math.pi / 2;
    if (normalizedAngle < 0) {
      normalizedAngle += 2 * math.pi;
    }

    setState(() {
      if (distance < r3) {
        _isCenterHovered = true;
        _hoveredMonth = null;
        _hoveredWeek = null;
        _hoveredDay = null;
      } else if (distance >= r1 && distance <= r0) {
        _isCenterHovered = false;
        final totalDays = CalendarDateUtils.daysInYear(widget.selectedYear);
        _hoveredDay = (normalizedAngle / (2 * math.pi) * totalDays).floor().clamp(0, totalDays - 1);
        _hoveredMonth = null;
        _hoveredWeek = null;
      } else if (distance >= r2 && distance < r1) {
        _isCenterHovered = false;
        _hoveredWeek = (normalizedAngle / (2 * math.pi) * 52).floor() % 52;
        _hoveredMonth = null;
        _hoveredDay = null;
      } else if (distance >= r3 && distance < r2) {
        _isCenterHovered = false;
        _hoveredWeek = null;
        _hoveredMonth = (normalizedAngle / (2 * math.pi) * 12).floor() % 12;
        _hoveredDay = null;
      } else {
        _isCenterHovered = false;
        _hoveredMonth = null;
        _hoveredWeek = null;
        _hoveredDay = null;
      }
    });
  }

  void _handlePanEnd(DragEndDetails details) {
    setState(() {
      _hoveredMonth = null;
      _hoveredWeek = null;
      _hoveredDay = null;
      _isCenterHovered = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final todayMonth = now.month - 1;
    final firstDayOfYear = DateTime(now.year, 1, 1);
    final daysOffset = now.difference(firstDayOfYear).inDays;
    int todayWeek = (daysOffset / 7).floor();
    if (todayWeek > 51) todayWeek = 51;
    final todayDay = daysOffset;

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        return GestureDetector(
          onTapDown: (details) => _handleTapDown(details, size),
          onPanUpdate: (details) => _handlePanUpdate(details, size),
          onPanEnd: _handlePanEnd,
          child: CustomPaint(
            size: size,
            painter: CircularCalendarPainter(
              selectedYear: widget.selectedYear,
              selectedMonth: widget.selectedMonth,
              selectedWeek: widget.selectedWeek,
              selectedDay: widget.selectedDay,
              hoveredMonth: _hoveredMonth,
              hoveredWeek: _hoveredWeek,
              hoveredDay: _hoveredDay,
              isCenterHovered: _isCenterHovered,
              todayYear: now.year,
              todayMonth: todayMonth,
              todayWeek: todayWeek,
              todayDay: todayDay,
              isDark: widget.isDark,
            ),
          ),
        );
      },
    );
  }
}