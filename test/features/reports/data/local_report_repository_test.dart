import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:spidy/features/reports/data/local_report_repository.dart';
import 'package:spidy/features/reports/domain/report.dart';

void main() {
  late Directory temporaryDirectory;
  late Directory photoDirectory;
  late String databasePath;
  late LocalReportRepository repository;

  setUpAll(() {
    sqfliteFfiInit();
  });

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'spidy_report_repository_test_',
    );
    photoDirectory = Directory(p.join(temporaryDirectory.path, 'photos'));
    await photoDirectory.create();
    databasePath = p.join(temporaryDirectory.path, 'reports.sqlite');
    repository = _createRepository(databasePath, photoDirectory);
  });

  tearDown(() async {
    await repository.close();
    await temporaryDirectory.delete(recursive: true);
  });

  test(
    'creates a local demo report with persisted fields and status',
    () async {
      final report = _report(
        id: 'report-create-1',
        createdAt: DateTime(2026, 1, 2, 3, 4, 5),
      );

      final saved = await repository.saveReport(report);

      expect(saved.id, report.id);
      expect(saved.status, DeliveryStatus.localOnly);
      expect(saved.origin, ReportOrigin.localDemo);
      expect(saved.createdAt.isUtc, isTrue);
      expect(saved.latitude, 37.4219983);
      expect(saved.longitude, -122.084);
    },
  );

  test('reads saved reports after repository is closed and reopened', () async {
    final report = _report(id: 'report-read-1');
    await repository.saveReport(report);
    await repository.close();
    repository = _createRepository(databasePath, photoDirectory);

    final reports = await repository.getReports();

    expect(reports, hasLength(1));
    expect(reports.single.id, report.id);
    expect(reports.single.category, IncidentCategory.medical);
    expect(reports.single.description, report.description);
    expect(reports.single.address, report.address);
    expect(reports.single.latitude, report.latitude);
    expect(reports.single.longitude, report.longitude);
    expect(reports.single.photoPath, isNull);
    expect(reports.single.createdAt.toUtc(), report.createdAt.toUtc());
    expect(reports.single.status, DeliveryStatus.localOnly);
    expect(reports.single.origin, ReportOrigin.localDemo);
  });

  test('retrieves reports newest first', () async {
    await repository.saveReport(
      _report(id: 'report-old', createdAt: DateTime.utc(2025, 1, 1)),
    );
    await repository.saveReport(
      _report(id: 'report-new', createdAt: DateTime.utc(2026, 1, 1)),
    );
    await repository.saveReport(
      _report(id: 'report-middle', createdAt: DateTime.utc(2025, 6, 1)),
    );

    final reports = await repository.getReports();

    expect(reports.map((report) => report.id), [
      'report-new',
      'report-middle',
      'report-old',
    ]);
  });

  test('migrates version 1 records and defaults them to local demo', () async {
    await repository.close();
    await databaseFactoryFfi.deleteDatabase(databasePath);
    final legacy = await databaseFactoryFfi.openDatabase(
      databasePath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE reports (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              category TEXT NOT NULL,
              description TEXT NOT NULL,
              location_text TEXT NOT NULL,
              latitude REAL,
              longitude REAL,
              photo_paths TEXT NOT NULL,
              created_at TEXT NOT NULL,
              status TEXT NOT NULL,
              remote_id TEXT,
              failure_message TEXT
            )
          ''');
          await db.insert('reports', {
            'category': IncidentCategory.fire.name,
            'description': 'Legacy report from the previous app version.',
            'location_text': 'Main Street, North District',
            'latitude': 37.4,
            'longitude': -122.1,
            'photo_paths': '[]',
            'created_at': DateTime.utc(2025).toIso8601String(),
            'status': DeliveryStatus.localOnly.name,
          });
        },
      ),
    );
    await legacy.close();
    repository = _createRepository(databasePath, photoDirectory);

    final reports = await repository.getReports();

    expect(reports, hasLength(1));
    expect(reports.single.id, 'legacy-1');
    expect(reports.single.origin, ReportOrigin.localDemo);
    expect(reports.single.status, DeliveryStatus.localOnly);
  });
}

LocalReportRepository _createRepository(
  String path,
  Directory photoDirectory,
) => LocalReportRepository(
  databaseFactory: databaseFactoryFfi,
  databasePath: path,
  photoDirectory: photoDirectory,
);

Report _report({required String id, DateTime? createdAt}) => Report(
  id: id,
  category: IncidentCategory.medical,
  description: 'A person needs medical assistance near the east entrance.',
  address: 'East Entrance, Civic Center',
  latitude: 37.4219983,
  longitude: -122.084,
  createdAt: createdAt ?? DateTime.utc(2026, 2, 3, 4, 5, 6),
);
