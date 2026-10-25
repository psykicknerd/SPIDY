enum IncidentCategory {
  fire('Fire', 'Local fire or smoke emergency', 'local_fire_department'),
  accident('Accident', 'Road or other serious accident', 'car_crash'),
  medical(
    'Medical emergency',
    'Someone needs urgent medical help',
    'medical_services',
  ),
  suspiciousActivity(
    'Suspicious activity',
    'Something that may need attention',
    'visibility',
  );

  const IncidentCategory(this.label, this.description, this.iconName);

  final String label;
  final String description;
  final String iconName;
}

enum DeliveryStatus { localOnly, pending, sent, failed }

class Report {
  const Report({
    this.id,
    required this.category,
    required this.description,
    required this.locationText,
    this.latitude,
    this.longitude,
    required this.photoPaths,
    required this.createdAt,
    this.status = DeliveryStatus.localOnly,
    this.remoteId,
    this.failureMessage,
  });

  final int? id;
  final IncidentCategory category;
  final String description;
  final String locationText;
  final double? latitude;
  final double? longitude;
  final List<String> photoPaths;
  final DateTime createdAt;
  final DeliveryStatus status;
  final String? remoteId;
  final String? failureMessage;

  Report withId(int value) => Report(
    id: value,
    category: category,
    description: description,
    locationText: locationText,
    latitude: latitude,
    longitude: longitude,
    photoPaths: photoPaths,
    createdAt: createdAt,
    status: status,
    remoteId: remoteId,
    failureMessage: failureMessage,
  );
}
