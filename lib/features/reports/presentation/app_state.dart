import 'package:flutter/widgets.dart';

import '../domain/report.dart';
import '../domain/report_repository.dart';

class AppState extends ChangeNotifier {
  AppState(this._repository);

  final ReportRepository _repository;
  List<Report> reports = const [];
  bool loading = true;
  String? loadError;

  Future<void> loadReports() async {
    loading = true;
    notifyListeners();
    try {
      reports = await _repository.getReports();
      loadError = null;
    } catch (_) {
      loadError = 'Could not load reports stored on this device.';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> addReport(Report report) async {
    final saved = await _repository.saveReport(report);
    reports = [saved, ...reports];
    notifyListeners();
  }
}

class AppStateScope extends InheritedNotifier<AppState> {
  const AppStateScope({
    super.key,
    required AppState state,
    required super.child,
  }) : super(notifier: state);

  static AppState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppStateScope>()!.notifier!;
}
