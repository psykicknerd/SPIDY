import 'dart:math';

enum IncidentCategory {
  fire('Fire', 'Local fire or smoke emergency', 'local_fire_department'),
  accident('Road accident', 'Road or other serious accident', 'car_crash'),
  medical(
    'Medical emergency',
    'Someone needs urgent medical help',
    'medical_services',
  ),
  suspiciousActivity(
    'Suspicious activity',
    'Something that may need attention',
    'visibility',
  ),
  other('Other', 'Another incident type', 'report_problem');

  const IncidentCategory(this.label, this.description, this.iconName);

  final String label;
  final String description;
  final String iconName;
}

enum DeliveryStatus { localOnly, pending, sent, failed }

enum ReportOrigin { localDemo, serverSubmitted }

class IncidentReport {
  IncidentReport({
    String? id,
    required this.category,
    required this.description,
    required this.address,
    this.latitude,
    this.longitude,
    String? photoPath,
    List<String> photoPaths = const [],
    required this.createdAt,
    this.status = DeliveryStatus.localOnly,
    this.origin = ReportOrigin.localDemo,
    this.remoteId,
    this.failureMessage,
  }) : id = id ?? _newReportId(),
       photoPath = photoPath ?? (photoPaths.isEmpty ? null : photoPaths.first);

  final String id;
  final IncidentCategory category;
  final String description;
  final String address;
  final double? latitude;
  final double? longitude;
  final String? photoPath;
  List<String> get photoPaths => photoPath == null ? const [] : [photoPath!];
  String get locationText => address;
  final DateTime createdAt;
  final DeliveryStatus status;
  final ReportOrigin origin;
  final String? remoteId;
  final String? failureMessage;

  IncidentReport withId(String value) => IncidentReport(
    id: value,
    category: category,
    description: description,
    address: address,
    latitude: latitude,
    longitude: longitude,
    photoPath: photoPath,
    createdAt: createdAt,
    status: status,
    origin: origin,
    remoteId: remoteId,
    failureMessage: failureMessage,
  );
}

typedef Report = IncidentReport;

String _newReportId() {
  final random = Random.secure();
  final bytes = List<int>.generate(16, (_) => random.nextInt(256));
  bytes[6] = (bytes[6] & 0x0f) | 0x40;
  bytes[8] = (bytes[8] & 0x3f) | 0x80;
  final hex = bytes
      .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
      .join();
  return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-'
      '${hex.substring(16, 20)}-${hex.substring(20)}';
}
