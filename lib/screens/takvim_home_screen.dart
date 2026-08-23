import 'package:flutter/material.dart';

import '../utils/calendar_date_utils.dart';
import '../utils/event_store.dart';
import '../widgets/circular_calendar.dart';
import '../widgets/day_strip_selector.dart';
import '../widgets/details_panel.dart';
import '../widgets/right_half_events_panel.dart';
import 'event_form_screen.dart';

class TakvimHomeScreen extends StatefulWidget {
  final VoidCallback onThemeToggle;
  const TakvimHomeScreen({super.key, required this.onThemeToggle});

  @override
  State<TakvimHomeScreen> createState() => _TakvimHomeScreenState();
}

class _TakvimHomeScreenState extends State<TakvimHomeScreen> {
  late int _selectedYear;
  late int _selectedMonth;
  late int _selectedWeek;
  int? _selectedDay;
  double _rotationAngle = 0;

  late DateTime _today;
  late int _todayYear;
  late int _todayDayIndex;

  @override
  void initState() {
    super.initState();
    _today = DateTime.now();
    _todayYear = _today.year;
    _todayDayIndex = CalendarDateUtils.getDayOfYearIndex(_today);
    _selectedYear = _todayYear;
    _selectedMonth = _today.month - 1;
    _selectedWeek = CalendarDateUtils.getWeekOfYear(_today) - 1;
  }

  void _goToToday() {
    setState(() {
      _selectedYear = _todayYear;
      _selectedMonth = _today.month - 1;
      _selectedWeek = CalendarDateUtils.getWeekOfYear(_today) - 1;
      _selectedDay = _todayDayIndex;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bugünün tarihine gidildi!'), duration: Duration(milliseconds: 800)),
    );
  }

  void _changeYear(int offset) => setState(() {
        _selectedYear += offset;
        _selectedDay = null;
      });

  Future<void> _selectYearDialog() async {
    int tempYear = _selectedYear;
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yıl Seçin'),
        content: SizedBox(
          height: 200,
          width: 150,
          child: ListWheelScrollView(
            itemExtent: 50,
            physics: const FixedExtentScrollPhysics(),
            controller: FixedExtentScrollController(initialItem: _selectedYear - 2000),
            onSelectedItemChanged: (index) => tempYear = 2000 + index,
            children: List.generate(
              100,
              (index) {
                final year = 2000 + index;
                return Center(child: Text(year.toString(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)));
              },
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('İptal')),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _selectedYear = tempYear;
                _selectedDay = null;
              });
              Navigator.pop(context);
            },
            child: const Text('Seç'),
          ),
        ],
      ),
    );
  }

  void _onMonthSelected(int month) => setState(() {
        _selectedMonth = month;
        _selectedDay = null;
      });

  void _onWeekSelected(int week) => setState(() => _selectedWeek = week);
  void _onDaySelected(int day) => setState(() => _selectedDay = day);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final events = EventStore().events;

    return Scaffold(
      appBar: AppBar(
        title: const Row(children: [
          Icon(Icons.calendar_view_day_rounded, color: Colors.teal),
          SizedBox(width: 8),
          Text('Takvim', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        ]),
        actions: [
          IconButton(icon: const Icon(Icons.today), tooltip: 'Bugüne Git', onPressed: _goToToday),
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
            Padding(
              padding: const EdgeInsets.fromLTRB(12.0, 6.0, 12.0, 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, size: 16),
                    visualDensity: VisualDensity.compact,
                    onPressed: () => _changeYear(-1),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: _selectYearDialog,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
                      decoration: BoxDecoration(
                        color: Colors.teal.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.teal.withValues(alpha: 0.3)),
                      ),
                      child: Text(_selectedYear.toString(),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.teal)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios, size: 16),
                    visualDensity: VisualDensity.compact,
                    onPressed: () => _changeYear(1),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 6,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 5,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: CircularCalendar(
                            selectedYear: _selectedYear,
                            selectedMonth: _selectedMonth,
                            selectedWeek: _selectedWeek,
                            onMonthSelected: _onMonthSelected,
                            onWeekSelected: _onWeekSelected,
                            onCenterTapped: _selectYearDialog,
                            onRotationChanged: (a) => setState(() => _rotationAngle = a),
                            isDark: isDark,
                            events: events,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 6,
                      child: RightHalfEventsPanel(
                        selectedYear: _selectedYear,
                        rotationAngle: _rotationAngle,
                        events: events,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            DayStripSelector(
              year: _selectedYear,
              monthIndex: _selectedMonth,
              selectedDayOfYear: _selectedDay,
              todayYear: _todayYear,
              todayDayOfYear: _todayDayIndex,
              isDark: isDark,
              onDaySelected: _onDaySelected,
            ),
            Expanded(
              flex: 3,
              child: DetailsPanel(
                selectedYear: _selectedYear,
                selectedMonth: _selectedMonth,
                selectedDay: _selectedDay,
                today: _today,
                todayYear: _todayYear,
                todayDayIndex: _todayDayIndex,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final initialDate = _selectedDay != null
              ? DateTime(_selectedYear, 1, 1).add(Duration(days: _selectedDay!))
              : DateTime(_selectedYear, _selectedMonth + 1, 1);
          Navigator.push(context, MaterialPageRoute(builder: (c) => EventFormScreen(initialDate: initialDate)));
        },
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        tooltip: 'Yeni Kayıt Ekle',
        child: const Icon(Icons.add),
      ),
    );
  }
}