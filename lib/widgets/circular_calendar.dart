import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../models/activity_event.dart';
import '../utils/calendar_date_utils.dart';
import 'circular_calendar_painter.dart';

class CircularCalendar extends StatefulWidget {
  final int selectedYear;
  final int selectedMonth;
  final int selectedWeek;
  final ValueChanged<int> onMonthSelected;
  final ValueChanged<int> onWeekSelected;
  final VoidCallback onCenterTapped;
  final ValueChanged<double>? onRotationChanged;
  final bool isDark;
  final List<ActivityEvent> events;

  const CircularCalendar({
    super.key,
    required this.selectedYear,
    required this.selectedMonth,
    required this.selectedWeek,
    required this.onMonthSelected,
    required this.onWeekSelected,
    required this.onCenterTapped,
    this.onRotationChanged,
    required this.isDark,
    this.events = const [],
  });

  @override
  State<CircularCalendar> createState() => _CircularCalendarState();
}

class _CircularCalendarState extends State<CircularCalendar> with SingleTickerProviderStateMixin {
  static const double monthSweep = 2 * math.pi / 12;
  static const double weekSweep = 2 * math.pi / 52;

  double _rotationAngle = 0;
  double? _lastPointerAngle;
  final bool _isCenterHovered = false;
  late AnimationController _snapController;
  Animation<double>? _snapAnimation;

  @override
  void initState() {
    super.initState();
    _snapController = AnimationController(vsync: this, duration: const Duration(milliseconds: 220));
    _rotationAngle = -(widget.selectedMonth * monthSweep);
    WidgetsBinding.instance.addPostFrameCallback((_) => widget.onRotationChanged?.call(_rotationAngle));
  }

  @override
  void didUpdateWidget(covariant CircularCalendar old) {
    super.didUpdateWidget(old);
    if (widget.selectedMonth != old.selectedMonth && _lastPointerAngle == null && !_snapController.isAnimating) {
      setState(() => _rotationAngle = -(widget.selectedMonth * monthSweep));
      widget.onRotationChanged?.call(_rotationAngle);
    }
  }

  @override
  void dispose() {
    _snapController.dispose();
    super.dispose();
  }

  double _normalize(double angle) {
    double a = angle % (2 * math.pi);
    if (a < 0) a += 2 * math.pi;
    return a;
  }

  int _monthUnderPointer() => (_normalize(-_rotationAngle) / monthSweep).floor() % 12;
  int _weekUnderPointer() => (_normalize(-_rotationAngle) / weekSweep).floor() % 52;

  void _reportSelection() {
    final m = _monthUnderPointer();
    final w = _weekUnderPointer();
    if (m != widget.selectedMonth) widget.onMonthSelected(m);
    if (w != widget.selectedWeek) widget.onWeekSelected(w);
  }

  void _onPanStart(DragStartDetails d, Offset center) {
    _snapController.stop();
    final local = d.localPosition;
    _lastPointerAngle = math.atan2(local.dy - center.dy, local.dx - center.dx);
  }

  void _onPanUpdate(DragUpdateDetails d, Offset center) {
    final local = d.localPosition;
    final angle = math.atan2(local.dy - center.dy, local.dx - center.dx);
    if (_lastPointerAngle != null) {
      double delta = angle - _lastPointerAngle!;
      if (delta > math.pi) delta -= 2 * math.pi;
      if (delta < -math.pi) delta += 2 * math.pi;
      setState(() => _rotationAngle += delta);
      widget.onRotationChanged?.call(_rotationAngle);
      _reportSelection();
    }
    _lastPointerAngle = angle;
  }

  void _onPanEnd(DragEndDetails d) {
    _lastPointerAngle = null;
    final target = -(_monthUnderPointer() * monthSweep);
    double diff = target - _rotationAngle;
    while (diff > math.pi) {
      diff -= 2 * math.pi;
    }
    while (diff < -math.pi) {
      diff += 2 * math.pi;
    }

    final from = _rotationAngle;
    final to = _rotationAngle + diff;
    _snapAnimation = Tween<double>(begin: from, end: to).animate(
      CurvedAnimation(parent: _snapController, curve: Curves.easeOutCubic),
    )..addListener(() {
        setState(() => _rotationAngle = _snapAnimation!.value);
        widget.onRotationChanged?.call(_rotationAngle);
      });
    _snapController.forward(from: 0);
  }

  void _handleTapDown(TapDownDetails details, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final local = details.localPosition;
    final distance = math.sqrt(math.pow(local.dx - center.dx, 2) + math.pow(local.dy - center.dy, 2));
    final rInner = math.min(size.width, size.height) * 0.15;
    if (distance < rInner) widget.onCenterTapped();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        final center = Offset(size.width / 2, size.height / 2);
        return GestureDetector(
          onTapDown: (d) => _handleTapDown(d, size),
          onPanStart: (d) => _onPanStart(d, center),
          onPanUpdate: (d) => _onPanUpdate(d, center),
          onPanEnd: _onPanEnd,
          child: CustomPaint(
            size: size,
            painter: CircularCalendarPainter(
              selectedYear: widget.selectedYear,
              selectedMonth: widget.selectedMonth,
              selectedWeek: widget.selectedWeek,
              rotationAngle: _rotationAngle,
              isCenterHovered: _isCenterHovered,
              todayYear: now.year,
              todayMonth: now.month - 1,
              todayWeek: CalendarDateUtils.getWeekOfYear(now) - 1,
              isDark: widget.isDark,
              events: widget.events,
            ),
          ),
        );
      },
    );
  }
}