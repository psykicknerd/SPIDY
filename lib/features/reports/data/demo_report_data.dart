import '../domain/report.dart';

/// Illustrative previews for the interface only. These are never persisted or submitted.
final demoReports = <Report>[
  Report(
    id: -1,
    category: IncidentCategory.accident,
    description: 'A vehicle collision is blocking one lane. No injuries reported in this sample.',
    locationText: 'Market Street · Central District',
    photoPaths: const [],
    createdAt: DateTime.now().subtract(const Duration(hours: 2)),
  ),
  Report(
    id: -2,
    category: IncidentCategory.medical,
    description: 'A person may need assistance near the south entrance. Sample record.',
    locationText: 'Riverside Park · South Gate',
    photoPaths: const [],
    createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
  ),
  Report(
    id: -3,
    category: IncidentCategory.suspiciousActivity,
    description: 'Example of a submitted incident description for the history preview.',
    locationText: 'Civic Plaza · East Walkway',
    photoPaths: const [],
    createdAt: DateTime.now().subtract(const Duration(days: 3)),
  ),
];
