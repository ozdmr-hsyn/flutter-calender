import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'screens/takvim_home_screen.dart';
import 'utils/event_store.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final store = EventStore();
  await store.loadEvents();
  runApp(const TakvimApp());
}

class TakvimApp extends StatefulWidget {
  const TakvimApp({super.key});

  @override
  State<TakvimApp> createState() => _TakvimAppState();
}

class _TakvimAppState extends State<TakvimApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  ThemeData _buildTheme(Brightness brightness) {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal, brightness: brightness),
    );
    // Tarih/saat seçicileri temaya (teal, yuvarlak köşeler) uydur.
    return base.copyWith(
      datePickerTheme: DatePickerThemeData(
        backgroundColor: base.colorScheme.surface,
        headerBackgroundColor: Colors.teal,
        headerForegroundColor: Colors.white,
        todayBorder: const BorderSide(color: Colors.teal, width: 1.5),
        dayShape: WidgetStateProperty.all(const CircleBorder()),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      timePickerTheme: TimePickerThemeData(
        backgroundColor: base.colorScheme.surface,
        dialHandColor: Colors.teal,
        hourMinuteShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: EventStore(),
      builder: (context, _) {
        return MaterialApp(
          title: 'Döngüsel Takvim',
          debugShowCheckedModeBanner: false,
          themeMode: _themeMode,
          theme: _buildTheme(Brightness.light),
          darkTheme: _buildTheme(Brightness.dark),
          // Türkçe yerelleştirme — picker'lar artık "Cancel/OK" değil "İptal/Tamam" gösterir.
          locale: const Locale('tr', 'TR'),
          supportedLocales: const [Locale('tr', 'TR')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: TakvimHomeScreen(onThemeToggle: _toggleTheme),
        );
      },
    );
  }
}