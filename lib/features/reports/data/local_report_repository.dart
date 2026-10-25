import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../domain/report.dart';
import '../domain/report_repository.dart';

class LocalReportRepository implements ReportRepository {
  LocalReportRepository({
    required DatabaseFactory databaseFactory,
    required String databasePath,
    required this.photoDirectory,
  }) : _database = databaseFactory.openDatabase(
         databasePath,
         options: OpenDatabaseOptions(
           version: 3,
           onCreate: _createSchema,
           onUpgrade: _upgradeSchema,
         ),
       );

  final Future<Database> _database;
  final Directory photoDirectory;

  static Future<LocalReportRepository> create() async {
    final databasePath = await getDatabasesPath();
    final documents = await getApplicationDocumentsDirectory();
    final photos = Directory(p.join(documents.path, 'report_photos'));
    await photos.create(recursive: true);
    return LocalReportRepository(
      databaseFactory: databaseFactory,
      databasePath: p.join(databasePath, 'spidy_reports.db'),
      photoDirectory: photos,
    );
  }

  static Future<void> _createSchema(DatabaseExecutor db, int version) async {
    await db.execute('''
      CREATE TABLE reports (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        report_id TEXT NOT NULL UNIQUE,
        category TEXT NOT NULL,
        description TEXT NOT NULL,
        location_text TEXT NOT NULL,
        latitude REAL CHECK (latitude IS NULL OR latitude BETWEEN -90 AND 90),
        longitude REAL CHECK (longitude IS NULL OR longitude BETWEEN -180 AND 180),
        photo_paths TEXT NOT NULL DEFAULT '[]',
        created_at TEXT NOT NULL,
        status TEXT NOT NULL CHECK (status IN ('localOnly', 'pending', 'sent', 'failed')),
        origin TEXT NOT NULL DEFAULT 'localDemo'
          CHECK (origin IN ('localDemo', 'serverSubmitted')),
        remote_id TEXT,
        failure_message TEXT
      )
    ''');
    await db.execute(
      'CREATE INDEX reports_created_at_index ON reports(created_at DESC, report_id DESC)',
    );
  }

  static Future<void> _upgradeSchema(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE reports ADD COLUMN report_id TEXT');
      await db.execute(
        "UPDATE reports SET report_id = 'legacy-' || id WHERE report_id IS NULL",
      );
      await db.execute(
        'CREATE UNIQUE INDEX reports_report_id_unique ON reports(report_id)',
      );
    }
    if (oldVersion < 3) {
      await db.execute(
        "ALTER TABLE reports ADD COLUMN origin TEXT NOT NULL DEFAULT 'localDemo'",
      );
      await db.execute(
        "UPDATE reports SET origin = 'serverSubmitted' WHERE status = 'sent'",
      );
      await db.execute(
        'CREATE INDEX reports_created_at_index ON reports(created_at DESC, report_id DESC)',
      );
    }
  }

  Future<String?> _persistPhoto(Report report) async {
    final sourcePath = report.photoPath;
    if (sourcePath == null) return null;

    final source = File(sourcePath);
    if (!await source.exists()) {
      throw FileSystemException(
        'The selected photo is no longer available.',
        source.path,
      );
    }
    final extension = p.extension(source.path);
    final destination = p.join(photoDirectory.path, '${report.id}$extension');
    await source.copy(destination);
    return destination;
  }

  @override
  Future<Report> saveReport(Report report) async {
    final savedPhotoPath = await _persistPhoto(report);
    final saved = Report(
      id: report.id,
      category: report.category,
      description: report.description,
      address: report.address,
      latitude: report.latitude,
      longitude: report.longitude,
      photoPath: savedPhotoPath,
      createdAt: report.createdAt.toUtc(),
      status: DeliveryStatus.localOnly,
      origin: ReportOrigin.localDemo,
    );
    try {
      final db = await _database;
      await db.insert('reports', {
        'report_id': saved.id,
        'category': saved.category.name,
        'description': saved.description,
        'location_text': saved.address,
        'latitude': saved.latitude,
        'longitude': saved.longitude,
        'photo_paths': jsonEncode(saved.photoPaths),
        'created_at': saved.createdAt.toUtc().toIso8601String(),
        'status': saved.status.name,
        'origin': saved.origin.name,
        'remote_id': null,
        'failure_message': null,
      });
      return saved;
    } catch (_) {
      if (savedPhotoPath != null) {
        await File(savedPhotoPath)
            .delete()
            .catchError((_) => File(savedPhotoPath));
      }
      rethrow;
    }
  }

  @override
  Future<List<Report>> getReports() async {
    final db = await _database;
    final rows = await db.query(
      'reports',
      orderBy: 'created_at DESC, report_id DESC',
    );
    return rows
        .map((row) {
          final photos = (jsonDecode(
            row['photo_paths']! as String,
          ) as List<dynamic>).cast<String>();
          return Report(
            id: (row['report_id'] as String?) ?? 'legacy-${row['id']}',
            category: IncidentCategory.values.byName(
              row['category']! as String,
            ),
            description: row['description']! as String,
            address: row['location_text']! as String,
            latitude: (row['latitude'] as num?)?.toDouble(),
            longitude: (row['longitude'] as num?)?.toDouble(),
            photoPaths: photos,
            createdAt: DateTime.parse(row['created_at']! as String),
            status: DeliveryStatus.values.byName(row['status']! as String),
            origin: ReportOrigin.values.byName(
              (row['origin'] as String?) ?? ReportOrigin.localDemo.name,
            ),
            remoteId: row['remote_id'] as String?,
            failureMessage: row['failure_message'] as String?,
          );
        })
        .toList(growable: false);
  }

  Future<void> close() async => (await _database).close();
}
