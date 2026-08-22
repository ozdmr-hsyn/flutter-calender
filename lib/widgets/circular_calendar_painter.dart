import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../utils/calendar_date_utils.dart';

/// [CircularCalendar] için tüm çizim (dört halka: gün/hafta/ay/yıl,
/// etiketler, seçim/hover vurguları) burada yapılır.
class CircularCalendarPainter extends CustomPainter {
  final int selectedYear;
  final int? selectedMonth;
  final int? selectedWeek;
  final int? selectedDay;
  final int? hoveredMonth;
  final int? hoveredWeek;
  final int? hoveredDay;
  final bool isCenterHovered;
  final int todayYear;
  final int todayMonth;
  final int todayWeek;
  final int todayDay;
  final bool isDark;

  CircularCalendarPainter({
    required this.selectedYear,
    required this.selectedMonth,
    required this.selectedWeek,
    required this.selectedDay,
    required this.hoveredMonth,
    required this.hoveredWeek,
    required this.hoveredDay,
    required this.isCenterHovered,
    required this.todayYear,
    required this.todayMonth,
    required this.todayWeek,
    required this.todayDay,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final minDimension = math.min(size.width, size.height);

    // Radii of concentric circles (outer to inner):
    final r0 = minDimension * 0.48; // Outer boundary of DAYS ring
    final r1 = minDimension * 0.40; // Outer boundary of WEEKS ring / inner boundary of days
    final r2 = minDimension * 0.32; // Outer boundary of MONTHS ring / inner boundary of weeks
    final r3 = minDimension * 0.11; // Center circle (YEAR) / inner boundary of months

    final totalDays = CalendarDateUtils.daysInYear(selectedYear);

    // Helper path generator for rings
    Path getRingSectorPath(double innerRadius, double outerRadius, double startAngle, double sweepAngle) {
      Path path = Path();
      path.arcTo(Rect.fromCircle(center: center, radius: outerRadius), startAngle, sweepAngle, true);
      path.arcTo(Rect.fromCircle(center: center, radius: innerRadius), startAngle + sweepAngle, -sweepAngle, false);
      path.close();
      return path;
    }

    Color getMonthColor(int monthIndex) => CalendarDateUtils.getMonthRingColor(monthIndex, isDark);

    int monthForDayIndex(int dayIndex) {
      final date = DateTime(selectedYear, 1, 1).add(Duration(days: dayIndex));
      return date.month - 1;
    }

    // 1. Draw OUTERMOST RING: Days of the year (between r1 and r0)
    final double daySweep = 2 * math.pi / totalDays;
    for (int i = 0; i < totalDays; i++) {
      final double startAngle = math.pi / 2 + i * daySweep;
      final monthIdx = monthForDayIndex(i);
      final monthColor = getMonthColor(monthIdx);

      final isSelected = selectedDay == i;
      final isHovered = hoveredDay == i;
      final isToday = todayDay == i && todayYear == selectedYear;

      final double baseOpacity = (i % 2 == 0) ? 0.20 : 0.32;
      Color fillColor = monthColor.withOpacity(isDark ? baseOpacity : baseOpacity + 0.15);
      if (isSelected) {
        fillColor = monthColor.withOpacity(isDark ? 0.85 : 0.95);
      } else if (isHovered) {
        fillColor = monthColor.withOpacity(isDark ? 0.6 : 0.7);
      }

      final sectorPath = getRingSectorPath(r1, r0, startAngle, daySweep);

      final sectorPaint = Paint()
        ..color = fillColor
        ..style = PaintingStyle.fill;
      canvas.drawPath(sectorPath, sectorPaint);

      if (isSelected) {
        final outlinePaint = Paint()
          ..color = isDark ? Colors.tealAccent : Colors.teal.shade700
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0;
        canvas.drawPath(sectorPath, outlinePaint);
      } else if (isToday) {
        final todayOutline = Paint()
          ..color = Colors.redAccent
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2;
        canvas.drawPath(sectorPath, todayOutline);
      }

      // Only draw dividers every few days to avoid visual clutter
      if (i % 5 == 0) {
        final dividerPaint = Paint()
          ..color = isDark ? Colors.white10 : Colors.black12
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.4;
        canvas.drawLine(
          Offset(center.dx + r1 * math.cos(startAngle), center.dy + r1 * math.sin(startAngle)),
          Offset(center.dx + r0 * math.cos(startAngle), center.dy + r0 * math.sin(startAngle)),
          dividerPaint,
        );
      }
    }

    // 2. Draw WEEKS RING (between r2 and r1)
    final double weekSweep = 2 * math.pi / 52;
    for (int i = 0; i < 52; i++) {
      final double startAngle = math.pi / 2 + i * weekSweep;

      final int approxMonth = (i / 52 * 12).floor() % 12;
      final monthColor = getMonthColor(approxMonth);

      final isSelected = selectedWeek == i;
      final isHovered = hoveredWeek == i;
      final isToday = todayWeek == i && todayYear == selectedYear;

      final double baseOpacity = (i % 2 == 0) ? 0.15 : 0.25;
      Color fillColor = monthColor.withOpacity(isDark ? baseOpacity : baseOpacity + 0.15);

      if (isSelected) {
        fillColor = monthColor.withOpacity(isDark ? 0.8 : 0.9);
      } else if (isHovered) {
        fillColor = monthColor.withOpacity(isDark ? 0.6 : 0.7);
      }

      final sectorPath = getRingSectorPath(r2, r1, startAngle, weekSweep);

      final sectorPaint = Paint()
        ..color = fillColor
        ..style = PaintingStyle.fill;
      canvas.drawPath(sectorPath, sectorPaint);

      if (isSelected) {
        final outlinePaint = Paint()
          ..color = isDark ? Colors.tealAccent : Colors.teal.shade700
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5;
        canvas.drawPath(sectorPath, outlinePaint);
      } else if (isToday) {
        final todayOutline = Paint()
          ..color = Colors.redAccent
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;
        canvas.drawPath(sectorPath, todayOutline);
      }

      final dividerPaint = Paint()
        ..color = isDark ? Colors.white10 : Colors.black12
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5;
      canvas.drawLine(
        Offset(center.dx + r2 * math.cos(startAngle), center.dy + r2 * math.sin(startAngle)),
        Offset(center.dx + r1 * math.cos(startAngle), center.dy + r1 * math.sin(startAngle)),
        dividerPaint,
      );
    }

    // 3. Draw MONTHS RING (between r3 and r2)
    final double monthSweep = 2 * math.pi / 12;
    for (int i = 0; i < 12; i++) {
      final double startAngle = math.pi / 2 + i * monthSweep;
      final monthColor = getMonthColor(i);

      final isSelected = selectedMonth == i;
      final isHovered = hoveredMonth == i;
      final isToday = todayMonth == i && todayYear == selectedYear;

      Color fillColor = monthColor.withOpacity(isDark ? 0.35 : 0.55);
      if (isSelected) {
        fillColor = monthColor.withOpacity(isDark ? 0.8 : 0.9);
      } else if (isHovered) {
        fillColor = monthColor.withOpacity(isDark ? 0.6 : 0.7);
      }

      final sectorPath = getRingSectorPath(r3, r2, startAngle, monthSweep);

      final sectorPaint = Paint()
        ..color = fillColor
        ..style = PaintingStyle.fill;
      canvas.drawPath(sectorPath, sectorPaint);

      if (isSelected) {
        final outlinePaint = Paint()
          ..color = isDark ? Colors.tealAccent : Colors.teal.shade700
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.0;
        canvas.drawPath(sectorPath, outlinePaint);
      } else if (isToday) {
        final todayOutline = Paint()
          ..color = Colors.redAccent
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0;
        canvas.drawPath(sectorPath, todayOutline);
      }

      final dividerPaint = Paint()
        ..color = isDark ? Colors.white10 : Colors.black12
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
      canvas.drawLine(
        Offset(center.dx + r3 * math.cos(startAngle), center.dy + r3 * math.sin(startAngle)),
        Offset(center.dx + r2 * math.cos(startAngle), center.dy + r2 * math.sin(startAngle)),
        dividerPaint,
      );
    }

    // 4. Draw Concentric Circle Grid Lines
    final gridPaint = Paint()
      ..color = isDark ? Colors.white24 : Colors.black12
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, r0, gridPaint);
    canvas.drawCircle(center, r1, gridPaint);
    canvas.drawCircle(center, r2, gridPaint);

    // 5. Draw Center Circle (Year)
    final centerFillPaint = Paint()
      ..shader = RadialGradient(
        colors: isCenterHovered
            ? [Colors.teal.shade400, Colors.teal.shade700]
            : isDark
                ? [Colors.grey.shade800, Colors.grey.shade900]
                : [Colors.grey.shade100, Colors.grey.shade300],
      ).createShader(Rect.fromCircle(center: center, radius: r3))
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, r3, centerFillPaint);

    final circle3Border = Paint()
      ..color = isDark ? Colors.white54 : Colors.black45
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(center, r3, circle3Border);

    // 6. Draw TEXT labels

    // Draw Year in the center
    final yearTextPainter = TextPainter(
      text: TextSpan(
        text: selectedYear.toString(),
        style: TextStyle(
          color: isCenterHovered
              ? Colors.white
              : isDark
                  ? Colors.tealAccent
                  : Colors.teal.shade800,
          fontSize: (r3 * 0.55).clamp(9.0, 24.0),
          fontWeight: FontWeight.w900,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    yearTextPainter.layout();
    yearTextPainter.paint(
      canvas,
      Offset(center.dx - yearTextPainter.width / 2, center.dy - yearTextPainter.height / 2),
    );

    // Helper to compute a "radial" rotation (labels point outward, upright on both halves)
    double radialRotation(double midAngle) {
      double rotationAngle = midAngle;
      final double normAngle = (midAngle + 2 * math.pi) % (2 * math.pi);
      if (normAngle > math.pi / 2 && normAngle < 3 * math.pi / 2) {
        rotationAngle += math.pi;
      }
      return rotationAngle;
    }

    // Helper to compute a "tangential" rotation (labels run along the ring, upright on both halves)
    double tangentialRotation(double midAngle) {
      double rotationAngle = midAngle + math.pi / 2;
      final double normAngle = (midAngle + 2 * math.pi) % (2 * math.pi);
      if (normAngle > 0 && normAngle < math.pi) {
        rotationAngle += math.pi;
      }
      return rotationAngle;
    }

    // Draw Month labels (tangential, in the months ring)
    final List<String> months = CalendarDateUtils.monthNames;
    final double monthMaxFontSize = (minDimension * 0.030).clamp(9.0, 14.0);
    final double monthMidRadius = (r2 + r3) / 2;
    // Available arc length (chord approximation) for a single month sector at midRadius,
    // with a small margin so text never touches the sector's divider lines.
    final double monthArcLength = 2 * monthMidRadius * math.sin(monthSweep / 2) * 0.86;

    for (int i = 0; i < 12; i++) {
      final double midAngle = math.pi / 2 + i * monthSweep + monthSweep / 2;
      final double x = center.dx + monthMidRadius * math.cos(midAngle);
      final double y = center.dy + monthMidRadius * math.sin(midAngle);

      final double rotationAngle = tangentialRotation(midAngle);

      final isSelected = selectedMonth == i;
      final isToday = todayMonth == i && todayYear == selectedYear;

      final Color monthTextColor = isSelected
          ? (isDark ? Colors.black : Colors.white)
          : isToday
              ? Colors.redAccent
              : isDark
                  ? Colors.white70
                  : Colors.black87;
      final FontWeight monthFontWeight = isSelected || isToday ? FontWeight.bold : FontWeight.w500;

      // Shrink the font until the label fits within its sector's arc length.
      double fittedFontSize = monthMaxFontSize;
      TextPainter labelPainter = TextPainter(
        text: TextSpan(
          text: months[i],
          style: TextStyle(
            color: monthTextColor,
            fontSize: fittedFontSize,
            fontWeight: monthFontWeight,
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      )..layout();

      while (labelPainter.width > monthArcLength && fittedFontSize > 6.0) {
        fittedFontSize -= 0.5;
        labelPainter = TextPainter(
          text: TextSpan(
            text: months[i],
            style: TextStyle(
              color: monthTextColor,
              fontSize: fittedFontSize,
              fontWeight: monthFontWeight,
            ),
          ),
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center,
        )..layout();
      }

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rotationAngle);
      labelPainter.paint(canvas, Offset(-labelPainter.width / 2, -labelPainter.height / 2));
      canvas.restore();
    }

    // Draw Week numbers (radial, in the weeks ring)
    final double weekFontSize = (minDimension * 0.022).clamp(10.0, 14.0);

    for (int i = 0; i < 52; i++) {
      final double midAngle = math.pi / 2 + i * weekSweep + weekSweep / 2;
      final double midRadius = (r1 + r2) / 2;
      final double x = center.dx + midRadius * math.cos(midAngle);
      final double y = center.dy + midRadius * math.sin(midAngle);

      final double rotationAngle = radialRotation(midAngle);

      final isSelected = selectedWeek == i;
      final isToday = todayWeek == i && todayYear == selectedYear;

      final textStyle = TextStyle(
        color: isSelected
            ? (isDark ? Colors.black : Colors.white)
            : isToday
                ? Colors.redAccent
                : isDark
                    ? Colors.white54
                    : Colors.black54,
        fontSize: weekFontSize,
        fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
      );

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rotationAngle);

      final weekPainter = TextPainter(
        text: TextSpan(text: '${i + 1}', style: textStyle),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );
      weekPainter.layout();
      weekPainter.paint(canvas, Offset(-weekPainter.width / 2, -weekPainter.height / 2));
      canvas.restore();
    }

    // Draw Day numbers (radial, in the days ring) — only every Nth day to avoid clutter
    final double dayFontSize = (minDimension * 0.018).clamp(9.0, 12.0);
    // Show a label roughly every 5 days, plus always on the 1st of a visible interval
    final int dayLabelStep = totalDays > 200 ? 5 : 3;

    for (int i = 0; i < totalDays; i += dayLabelStep) {
      final double midAngle = math.pi / 2 + i * daySweep + daySweep / 2;
      final double midRadius = (r0 + r1) / 2;
      final double x = center.dx + midRadius * math.cos(midAngle);
      final double y = center.dy + midRadius * math.sin(midAngle);

      final double rotationAngle = radialRotation(midAngle);

      final isSelected = selectedDay == i;
      final isToday = todayDay == i && todayYear == selectedYear;

      final date = DateTime(selectedYear, 1, 1).add(Duration(days: i));

      final textStyle = TextStyle(
        color: isSelected
            ? (isDark ? Colors.black : Colors.white)
            : isToday
                ? Colors.redAccent
                : isDark
                    ? Colors.white38
                    : Colors.black45,
        fontSize: dayFontSize,
        fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
      );

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rotationAngle);

      final dayPainter = TextPainter(
        text: TextSpan(text: '${date.day}', style: textStyle),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );
      dayPainter.layout();
      dayPainter.paint(canvas, Offset(-dayPainter.width / 2, -dayPainter.height / 2));
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CircularCalendarPainter oldDelegate) {
    return oldDelegate.selectedYear != selectedYear ||
        oldDelegate.selectedMonth != selectedMonth ||
        oldDelegate.selectedWeek != selectedWeek ||
        oldDelegate.selectedDay != selectedDay ||
        oldDelegate.hoveredMonth != hoveredMonth ||
        oldDelegate.hoveredWeek != hoveredWeek ||
        oldDelegate.hoveredDay != hoveredDay ||
        oldDelegate.isCenterHovered != isCenterHovered ||
        oldDelegate.isDark != isDark;
  }
}