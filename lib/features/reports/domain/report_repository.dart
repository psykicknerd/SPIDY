import 'report.dart';

abstract interface class ReportRepository {
  Future<List<Report>> getReports();
  Future<Report> saveReport(Report report);
}
