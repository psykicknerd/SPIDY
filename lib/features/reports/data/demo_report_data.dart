import '../domain/report.dart';

/// Illustrative previews for the interface only. These are never persisted or submitted.
final demoReports = <Report>[
  Report(
    category: IncidentCategory.accident,
    description: 'A vehicle collision is blocking one lane. No injuries reported in this sample.',
    address: 'Market Street · Central District',
    photoPaths: const [],
    createdAt: DateTime.now().subtract(const Duration(hours: 2)),
  ),
  Report(
    category: IncidentCategory.medical,
    description:
        'A person may need assistance near the south entrance. Sample record.',
    address: 'Riverside Park · South Gate',
    photoPaths: const [],
    createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
  ),
  Report(
    category: IncidentCategory.suspiciousActivity,
    description:
        'Example of a submitted incident description for the history preview.',
    address: 'Civic Plaza · East Walkway',
    photoPaths: const [],
    createdAt: DateTime.now().subtract(const Duration(days: 3)),
  ),
];
