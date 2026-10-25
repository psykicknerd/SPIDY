import 'package:flutter/material.dart';

import 'app/app.dart';
import 'features/reports/data/local_report_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final repository = await LocalReportRepository.create();
  runApp(CivicShieldApp(repository: repository));
}
