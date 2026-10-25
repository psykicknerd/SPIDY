import 'package:flutter/material.dart';

import '../domain/report.dart';
import 'app_state.dart';
import 'emergency_info_screen.dart';
import 'history_screen.dart';
import 'home_dashboard_screen.dart';
import 'report_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  Future<void> _openReport({IncidentCategory? category}) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => ReportFormScreen(
          initialCategory: category,
          onSubmitted: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final pages = [
      HomeDashboardScreen(
        onReport: (category) => _openReport(category: category),
        onHistory: () => setState(() => _selectedIndex = 1),
        onEmergencyInfo: () => setState(() => _selectedIndex = 2),
        reports: state.reports,
        loading: state.loading,
        loadError: state.loadError,
        onRetry: state.loadReports,
      ),
      HistoryScreen(onReport: () => _openReport()),
      const EmergencyInfoScreen(),
    ];

    return Scaffold(
      body: SafeArea(child: IndexedStack(index: _selectedIndex, children: pages)),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment_rounded),
            label: 'My Reports',
          ),
          NavigationDestination(
            icon: Icon(Icons.shield_outlined),
            selectedIcon: Icon(Icons.shield_rounded),
            label: 'Emergency Info',
          ),
        ],
      ),
    );
  }
}
