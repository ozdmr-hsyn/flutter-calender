import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../models/activity_event.dart';
import '../utils/calendar_date_utils.dart';

/// AY (12) ve HAFTA (52) halkalarını çizer. Etiketler artık RADYAL:
/// tekerlek döndükçe onunla birlikte döner, merkezden dışa doğru "dik"
/// yazılır (enine değil uzunlamasına). Okunabilirlik için, mutlak açı
/// alt yarıya düştüğünde 180° çevrilir ki baş aşağı durmasın.
class CircularCalendarPainter extends CustomPainter {
  final int selectedYear;
  final int selectedMonth;
  final int selectedWeek;
  final double rotationAngle;
  final bool isCenterHovered;
  final int todayYear;
  final int todayMonth;
  final int todayWeek;
  final bool isDark;
  final List<ActivityEvent> events;

  CircularCalendarPainter({
    required this.selectedYear,
    required this.selectedMonth,
    required this.selectedWeek,
    required this.rotationAngle,
    required this.isCenterHovered,
    required this.todayYear,
    required this.todayMonth,
    required this.todayWeek,
    required this.isDark,
    this.events = const [],
  });

  static const double baseAngle = -math.pi / 2;

  double _normalize(double a) {
    double x = a % (2 * math.pi);
    if (x < 0) x += 2 * math.pi;
    return x;
  }

  /// Radyal dönüş: metin merkezden dışa bakar. [localMid] bu sektörün
  /// (dönmeyen) yerel orta açısıdır; okunabilirlik kontrolü ise dönme
  /// açısını da katan MUTLAK açıya göre yapılır, böylece tekerlek
  /// dönerken etiket asla baş aşağı kalmaz.
  double _radialRotation(double localMid) {
    double rotation = localMid;
    final double absAngle = _normalize(localMid + rotationAngle);
    if (absAngle > math.pi / 2 && absAngle < 3 * math.pi / 2) {
      rotation += math.pi;
    }
    return rotation;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final minDimension = math.min(size.width, size.height);

    final rOuter = minDimension * 0.48;
    final rMid = minDimension * 0.34;
    final rInner = minDimension * 0.15;

    Color getMonthColor(int i) => CalendarDateUtils.getMonthRingColor(i, isDark);

    Path ringSector(double innerR, double outerR, double startAngle, double sweep) {
      final path = Path();
      path.arcTo(Rect.fromCircle(center: center, radius: outerR), startAngle, sweep, true);
      path.arcTo(Rect.fromCircle(center: center, radius: innerR), startAngle + sweep, -sweep, false);
      path.close();
      return path;
    }

    final monthCounts = List<int>.filled(12, 0);
    final weekCounts = List<int>.filled(52, 0);
    for (final e in events) {
      if (e.startTime.year != selectedYear) continue;
      monthCounts[e.startTime.month - 1]++;
      final w = CalendarDateUtils.getWeekOfYear(e.startTime) - 1;
      if (w >= 0 && w < 52) weekCounts[w]++;
    }

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotationAngle);
    canvas.translate(-center.dx, -center.dy);

    // ---- HAFTA HALKASI (dış) — artık 52'sinin TAMAMI render ediliyor ----
    final weekSweep = 2 * math.pi / 52;
    final weekFontSize = (minDimension * 0.016).clamp(7.0, 9.5);

    for (int i = 0; i < 52; i++) {
      final start = baseAngle + i * weekSweep;
      final approxMonth = (i / 52 * 12).floor().clamp(0, 11);
      final monthColor = getMonthColor(approxMonth);
      final isSelected = selectedWeek == i;
      final isToday = todayWeek == i && todayYear == selectedYear;

      Color fill = monthColor.withValues(alpha: isDark ? 0.22 : 0.35);
      if (isSelected) fill = monthColor.withValues(alpha: isDark ? 0.85 : 0.95);

      final path = ringSector(rMid, rOuter, start, weekSweep);
      canvas.drawPath(path, Paint()..color = fill..style = PaintingStyle.fill);

      if (isSelected) {
        canvas.drawPath(
          path,
          Paint()
            ..color = isDark ? Colors.tealAccent : Colors.teal.shade700
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.5,
        );
      } else if (isToday) {
        canvas.drawPath(
          path,
          Paint()
            ..color = Colors.redAccent
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5,
        );
      }

      canvas.drawLine(
        Offset(center.dx + rMid * math.cos(start), center.dy + rMid * math.sin(start)),
        Offset(center.dx + rOuter * math.cos(start), center.dy + rOuter * math.sin(start)),
        Paint()
          ..color = isDark ? Colors.white10 : Colors.black12
          ..strokeWidth = 0.4,
      );

      // Etiket her sektörde çiziliyor — radyal (uzunlamasına), okunabilirlik
      // korunuyor çünkü metin dönüşü sektöre değil MUTLAK açıya göre düzeltiliyor.
      final mid = start + weekSweep / 2;
      final midR = (rMid + rOuter) / 2;
      final x = center.dx + midR * math.cos(mid);
      final y = center.dy + midR * math.sin(mid);

      final tp = TextPainter(
        text: TextSpan(
          text: '${i + 1}',
          style: TextStyle(
            fontSize: weekFontSize,
            fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
            color: isSelected
                ? (isDark ? Colors.black : Colors.white)
                : isToday
                    ? Colors.redAccent
                    : (isDark ? Colors.white54 : Colors.black54),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(_radialRotation(mid));
      tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
      canvas.restore();

      if (weekCounts[i] > 0) {
        final dotR = rOuter - 6;
        canvas.drawCircle(
          Offset(center.dx + dotR * math.cos(mid), center.dy + dotR * math.sin(mid)),
          2.0,
          Paint()..color = isDark ? Colors.white : Colors.black87,
        );
      }
    }

    // ---- AY HALKASI ----
    final monthSweep = 2 * math.pi / 12;
    final months = CalendarDateUtils.monthNames;
    final monthFontSize = (minDimension * 0.030).clamp(9.0, 14.0);
    final monthMidRadius = (rInner + rMid) / 2;
    final monthArcLength = 2 * monthMidRadius * math.sin(monthSweep / 2) * 0.82;

    for (int i = 0; i < 12; i++) {
      final start = baseAngle + i * monthSweep;
      final monthColor = getMonthColor(i);
      final isSelected = selectedMonth == i;
      final isToday = todayMonth == i && todayYear == selectedYear;

      Color fill = monthColor.withValues(alpha: isDark ? 0.4 : 0.6);
      if (isSelected) fill = monthColor.withValues(alpha: isDark ? 0.9 : 0.95);

      final path = ringSector(rInner, rMid, start, monthSweep);
      canvas.drawPath(path, Paint()..color = fill..style = PaintingStyle.fill);

      if (isSelected) {
        canvas.drawPath(
          path,
          Paint()
            ..color = isDark ? Colors.tealAccent : Colors.teal.shade700
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3,
        );
      } else if (isToday) {
        canvas.drawPath(
          path,
          Paint()
            ..color = Colors.redAccent
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
      }

      canvas.drawLine(
        Offset(center.dx + rInner * math.cos(start), center.dy + rInner * math.sin(start)),
        Offset(center.dx + rMid * math.cos(start), center.dy + rMid * math.sin(start)),
        Paint()
          ..color = isDark ? Colors.white10 : Colors.black12
          ..strokeWidth = 1,
      );

      final mid = start + monthSweep / 2;
      final x = center.dx + monthMidRadius * math.cos(mid);
      final y = center.dy + monthMidRadius * math.sin(mid);

      // Sığması için gerekirse fontu küçült (radyal düzende uzunluk = arc değil, radyal boşluk;
      // yine de arc uzunluğunu üst sınır olarak kullanmaya devam ediyoruz).
      double fittedSize = monthFontSize;
      TextPainter buildTp(double fs) => TextPainter(
            text: TextSpan(
              text: months[i],
              style: TextStyle(
                fontSize: fs,
                fontWeight: isSelected || isToday ? FontWeight.w900 : FontWeight.w600,
                color: isSelected
                    ? (isDark ? Colors.black : Colors.white)
                    : isToday
                        ? Colors.redAccent
                        : (isDark ? Colors.white70 : Colors.black87),
              ),
            ),
            textDirection: TextDirection.ltr,
          )..layout();

      TextPainter tp = buildTp(fittedSize);
      while (tp.width > monthArcLength && fittedSize > 6.5) {
        fittedSize -= 0.5;
        tp = buildTp(fittedSize);
      }

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(_radialRotation(mid));
      tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
      canvas.restore();

      if (monthCounts[i] > 0) {
        final dotR = monthMidRadius + tp.height / 2 + 5;
        canvas.drawCircle(
          Offset(center.dx + dotR * math.cos(mid), center.dy + dotR * math.sin(mid)),
          2.6,
          Paint()..color = isSelected ? Colors.white : Colors.orangeAccent,
        );
      }
    }

    final gridPaint = Paint()
      ..color = isDark ? Colors.white24 : Colors.black12
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, rOuter, gridPaint);
    canvas.drawCircle(center, rMid, gridPaint);

    canvas.restore(); // dönüşü geri al — merkez + pointer sabit kalır

    final centerFill = Paint()
      ..shader = RadialGradient(
        colors: isCenterHovered
            ? [Colors.teal.shade400, Colors.teal.shade700]
            : isDark
                ? [Colors.grey.shade800, Colors.grey.shade900]
                : [Colors.grey.shade100, Colors.grey.shade300],
      ).createShader(Rect.fromCircle(center: center, radius: rInner));
    canvas.drawCircle(center, rInner, centerFill);
    canvas.drawCircle(
      center,
      rInner,
      Paint()
        ..color = isDark ? Colors.white54 : Colors.black45
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    final yearTp = TextPainter(
      text: TextSpan(
        text: selectedYear.toString(),
        style: TextStyle(
          color: isCenterHovered ? Colors.white : (isDark ? Colors.tealAccent : Colors.teal.shade800),
          fontSize: (rInner * 0.5).clamp(11.0, 26.0),
          fontWeight: FontWeight.w900,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    yearTp.paint(canvas, Offset(center.dx - yearTp.width / 2, center.dy - yearTp.height / 2));

    final pointerPath = Path()
      ..moveTo(center.dx - 8, center.dy - rOuter - 4)
      ..lineTo(center.dx + 8, center.dy - rOuter - 4)
      ..lineTo(center.dx, center.dy - rOuter + 10)
      ..close();
    canvas.drawPath(pointerPath, Paint()..color = isDark ? Colors.tealAccent : Colors.teal.shade700);
  }

  @override
  bool shouldRepaint(covariant CircularCalendarPainter oldDelegate) {
    return oldDelegate.selectedYear != selectedYear ||
        oldDelegate.selectedMonth != selectedMonth ||
        oldDelegate.selectedWeek != selectedWeek ||
        oldDelegate.rotationAngle != rotationAngle ||
        oldDelegate.isCenterHovered != isCenterHovered ||
        oldDelegate.isDark != isDark ||
        oldDelegate.events != events;
  }
}