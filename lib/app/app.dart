import 'package:flutter/material.dart';

import '../features/reports/data/local_report_repository.dart';
import '../features/reports/presentation/app_state.dart';
import '../features/reports/presentation/home_screen.dart';

class SpidyApp extends StatefulWidget {
  const SpidyApp({super.key, required this.repository});

  final LocalReportRepository repository;

  @override
  State<SpidyApp> createState() => _SpidyAppState();
}

class _SpidyAppState extends State<SpidyApp> {
  late final AppState state = AppState(widget.repository)..loadReports();

  @override
  void dispose() {
    state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF193B66);
    const canvas = Color(0xFFF5F7FB);
    final colorScheme = ColorScheme.light(
      primary: navy,
      onPrimary: Colors.white,
      primaryContainer: const Color(0xFFE5EEF8),
      onPrimaryContainer: const Color(0xFF102A4A),
      secondary: const Color(0xFF526B88),
      onSecondary: Colors.white,
      secondaryContainer: const Color(0xFFE7EDF4),
      onSecondaryContainer: const Color(0xFF263B55),
      tertiary: const Color(0xFFD86A35),
      onTertiary: Colors.white,
      tertiaryContainer: const Color(0xFFFFE9DD),
      onTertiaryContainer: const Color(0xFF67270C),
      error: const Color(0xFFB42318),
      onError: Colors.white,
      errorContainer: const Color(0xFFFEE4E2),
      onErrorContainer: const Color(0xFF7A271A),
      surface: canvas,
      onSurface: const Color(0xFF17263C),
      onSurfaceVariant: const Color(0xFF526174),
      outline: const Color(0xFFCFD7E2),
      outlineVariant: const Color(0xFFE1E6ED),
      shadow: const Color(0xFF10243D),
      scrim: Colors.black,
      inverseSurface: const Color(0xFF25364C),
      onInverseSurface: Colors.white,
      inversePrimary: const Color(0xFFB4CBE4),
      surfaceTint: navy,
    );

    return AppStateScope(
      state: state,
      child: MaterialApp(
        title: 'SPIDY',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: colorScheme,
          scaffoldBackgroundColor: canvas,
          appBarTheme: const AppBarTheme(
            centerTitle: false,
            backgroundColor: canvas,
            foregroundColor: navy,
            surfaceTintColor: Colors.transparent,
          ),
          navigationBarTheme: NavigationBarThemeData(
            backgroundColor: Colors.white,
            indicatorColor: colorScheme.primaryContainer,
            labelTextStyle: WidgetStateProperty.resolveWith(
              (states) => TextStyle(
                fontSize: 12,
                fontWeight: states.contains(WidgetState.selected)
                    ? FontWeight.w700
                    : FontWeight.w500,
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFE1E7E5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: navy, width: 1.5),
            ),
          ),
          cardTheme: CardThemeData(
            color: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
              side: const BorderSide(color: Color(0xFFE3E8EF)),
            ),
          ),
          snackBarTheme: SnackBarThemeData(
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
