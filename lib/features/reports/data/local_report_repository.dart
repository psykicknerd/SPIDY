import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../domain/report.dart';
import '../domain/report_repository.dart';

class LocalReportRepository implements ReportRepository {
  LocalReportRepository._(this._database, this._photoDirectory);

  final Database _database;
  final Directory _photoDirectory;

  static Future<LocalReportRepository> create() async {
    final databasePath = await getDatabasesPath();
    final database = await openDatabase(
      p.join(databasePath, 'spidy_reports.db'),
      version: 2,
      onCreate: (db, version) => db.execute('''
        CREATE TABLE reports (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          report_id TEXT NOT NULL UNIQUE,
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
      '''),
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE reports ADD COLUMN report_id TEXT');
          await db.execute(
            "UPDATE reports SET report_id = 'legacy-' || id WHERE report_id IS NULL",
          );
          await db.execute(
            'CREATE UNIQUE INDEX reports_report_id_unique ON reports(report_id)',
          );
        }
      },
    );
    final documents = await getApplicationDocumentsDirectory();
    final photos = Directory(p.join(documents.path, 'report_photos'));
    await photos.create(recursive: true);
    return LocalReportRepository._(database, photos);
  }

  Future<List<String>> _persistPhotos(List<String> paths) async {
    final saved = <String>[];
    for (var index = 0; index < paths.length; index++) {
      final source = File(paths[index]);
      if (!await source.exists()) {
        throw FileSystemException(
          'The selected photo is no longer available.',
          source.path,
        );
      }
      final extension = p.extension(source.path);
      final destination = p.join(
        _photoDirectory.path,
        '${DateTime.now().microsecondsSinceEpoch}_$index$extension',
      );
      await source.copy(destination);
      saved.add(destination);
    }
    return saved;
  }

  @override
  Future<Report> saveReport(Report report) async {
    final photoPaths = await _persistPhotos(report.photoPaths);
    final saved = Report(
      category: report.category,
      description: report.description,
      address: report.address,
      latitude: report.latitude,
      longitude: report.longitude,
      photoPath: photoPaths.isEmpty ? null : photoPaths.first,
      createdAt: report.createdAt,
      status: DeliveryStatus.localOnly,
      id: report.id,
    );
    await _database.insert('reports', {
      'report_id': saved.id,
      'category': saved.category.name,
      'description': saved.description,
      'location_text': saved.locationText,
      'latitude': saved.latitude,
      'longitude': saved.longitude,
      'photo_paths': jsonEncode(saved.photoPaths),
      'created_at': saved.createdAt.toIso8601String(),
      'status': saved.status.name,
      'remote_id': null,
      'failure_message': null,
    });
    return saved;
  }

  @override
  Future<List<Report>> getReports() async {
    final rows = await _database.query('reports', orderBy: 'created_at DESC');
    return rows.map((row) {
      final photos = (jsonDecode(
        row['photo_paths']! as String,
      ) as List<dynamic>).cast<String>();
      return Report(
        id: (row['report_id'] as String?) ?? 'legacy-${row['id']}',
        category: IncidentCategory.values.byName(row['category']! as String),
        description: row['description']! as String,
        address: row['location_text']! as String,
        latitude: row['latitude'] as double?,
        longitude: row['longitude'] as double?,
        photoPaths: photos,
        createdAt: DateTime.parse(row['created_at']! as String),
        status: DeliveryStatus.values.byName(row['status']! as String),
        remoteId: row['remote_id'] as String?,
        failureMessage: row['failure_message'] as String?,
      );
    }).toList();
  }
}
