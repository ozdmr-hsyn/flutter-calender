import 'package:flutter/material.dart';

import '../utils/calendar_date_utils.dart';
import '../widgets/circular_calendar.dart';
import '../widgets/details_panel.dart';

class TakvimHomeScreen extends StatefulWidget {
  final VoidCallback onThemeToggle;

  const TakvimHomeScreen({super.key, required this.onThemeToggle});

  @override
  State<TakvimHomeScreen> createState() => _TakvimHomeScreenState();
}

class _TakvimHomeScreenState extends State<TakvimHomeScreen> {
  int _selectedYear = 2026;
  int? _selectedMonth;
  int? _selectedWeek;
  int? _selectedDay; // 0-based day-of-year index

  // Track today's details
  late DateTime _today;
  late int _todayYear;
  late int _todayMonthIndex;
  late int _todayDayIndex;

  @override
  void initState() {
    super.initState();
    _today = DateTime.now();
    _todayYear = _today.year;
    _todayMonthIndex = _today.month - 1;
    _todayDayIndex = CalendarDateUtils.getDayOfYearIndex(_today);
    _selectedYear = _todayYear;
  }

  void _goToToday() {
    setState(() {
      _selectedYear = _todayYear;
      _selectedMonth = null;
      _selectedWeek = null;
      _selectedDay = _todayDayIndex;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Bugünün tarihine gidildi!'),
        duration: Duration(milliseconds: 800),
      ),
    );
  }

  void _changeYear(int offset) {
    setState(() {
      _selectedYear += offset;
    });
  }

  Future<void> _selectYearDialog() async {
    int tempYear = _selectedYear;
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Yıl Seçin'),
          content: SizedBox(
            height: 200,
            width: 150,
            child: ListWheelScrollView(
              itemExtent: 50,
              physics: const FixedExtentScrollPhysics(),
              controller: FixedExtentScrollController(initialItem: _selectedYear - 2000),
              onSelectedItemChanged: (index) {
                tempYear = 2000 + index;
              },
              children: List.generate(100, (index) {
                final year = 2000 + index;
                return Center(
                  child: Text(
                    year.toString(),
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                );
              }),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _selectedYear = tempYear;
                });
                Navigator.pop(context);
              },
              child: const Text('Seç'),
            ),
          ],
        );
      },
    );
  }

  void _selectMonth(int month) {
    setState(() {
      _selectedMonth = month;
      _selectedWeek = null;
      _selectedDay = null;
    });
  }

  void _selectWeek(int week) {
    setState(() {
      _selectedWeek = week;
      _selectedMonth = null;
      _selectedDay = null;
    });
  }

  void _selectDay(int day) {
    setState(() {
      _selectedDay = day;
      _selectedMonth = null;
      _selectedWeek = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.calendar_view_day_rounded, color: Colors.teal),
            SizedBox(width: 8),
            Text(
              'Takvim',
              style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            tooltip: 'Bugüne Git',
            onPressed: _goToToday,
          ),
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            tooltip: 'Tema Değiştir',
            onPressed: widget.onThemeToggle,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Year Selector Bar (compact)
            Padding(
              padding: const EdgeInsets.fromLTRB(12.0, 6.0, 12.0, 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, size: 16),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => _changeYear(-1),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: _selectYearDialog,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
                      decoration: BoxDecoration(
                        color: Colors.teal.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.teal.withOpacity(0.3)),
                      ),
                      child: Text(
                        _selectedYear.toString(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Colors.teal,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios, size: 16),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => _changeYear(1),
                  ),
                ],
              ),
            ),

            // Circular Calendar View
            Expanded(
              flex: 8,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Center(
                  child: CircularCalendar(
                    selectedYear: _selectedYear,
                    selectedMonth: _selectedMonth,
                    selectedWeek: _selectedWeek,
                    selectedDay: _selectedDay,
                    onMonthSelected: _selectMonth,
                    onWeekSelected: _selectWeek,
                    onDaySelected: _selectDay,
                    onCenterTapped: _selectYearDialog,
                    isDark: isDark,
                  ),
                ),
              ),
            ),

            // Info & Details Card (compact)
            Expanded(
              flex: 2,
              child: DetailsPanel(
                selectedYear: _selectedYear,
                selectedMonth: _selectedMonth,
                selectedWeek: _selectedWeek,
                selectedDay: _selectedDay,
                today: _today,
                todayYear: _todayYear,
                todayMonthIndex: _todayMonthIndex,
                todayDayIndex: _todayDayIndex,
                onSelectMonth: _selectMonth,
                onSelectWeek: _selectWeek,
                onSelectDay: _selectDay,
              ),
            ),
          ],
        ),
      ),
    );
  }
}