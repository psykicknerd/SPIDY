import 'package:flutter/material.dart';

import '../../emergency_contacts/data/emergency_contact_config.dart';
import '../domain/report.dart';
import 'widgets/civic_widgets.dart';

class EmergencyInfoScreen extends StatelessWidget {
  const EmergencyInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return PageWidth(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
      child: ListView(
        children: [
          Text(
            'Emergency info',
            style: Theme.of(context).textTheme.headlineMedium
                ?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -.6),
          ),
          const SizedBox(height: 5),
          Text(
            'Important guidance and configured local contacts.',
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: colors.onSurfaceVariant),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFFEE9E4),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFF9C8BD)),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.emergency_rounded,
                  color: Color(0xFFB42318),
                  size: 23,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Immediate danger?',
                        style: TextStyle(
                          color: Color(0xFF7A271A),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Contact your local emergency service directly. SPIDY is a project prototype and does not notify responders.',
                        style: TextStyle(color: Color(0xFF7A271A), height: 1.4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),
          const SectionHeading(title: 'Verified local contacts'),
          const SizedBox(height: 7),
          if (verifiedEmergencyContacts.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(17),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.fact_check_outlined, color: colors.primary),
                    const SizedBox(width: 11),
                    const Expanded(
                      child: Text(
                        'Emergency numbers are not configured. Add only contact information verified for your project’s target region.',
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...verifiedEmergencyContacts.map(
              (contact) => Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: colors.primaryContainer,
                    foregroundColor: colors.primary,
                    child: const Icon(Icons.call_outlined),
                  ),
                  title: Text(
                    contact.label,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: Text('${contact.phoneNumber}\n${contact.source}'),
                  isThreeLine: true,
                ),
              ),
            ),
          const SizedBox(height: 23),
          const SectionHeading(title: 'Service directory'),
          const SizedBox(height: 7),
          ...IncidentCategory.values.map((category) {
            final (label, description) = switch (category) {
              IncidentCategory.fire => (
                'Fire & rescue',
                'Fire, smoke, or hazardous conditions',
              ),
              IncidentCategory.accident => (
                'Police / public safety',
                'Road incidents and immediate safety concerns',
              ),
              IncidentCategory.medical => (
                'Medical assistance',
                'Urgent health or injury assistance',
              ),
              IncidentCategory.suspiciousActivity => (
                'Community safety',
                'Concerns that may need local attention',
              ),
              IncidentCategory.other => (
                'Other incident',
                'Another incident type that needs attention',
              ),
            };
            return Card(
              margin: const EdgeInsets.only(bottom: 9),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 5,
                ),
                leading: Container(
                  width: 43,
                  height: 43,
                  decoration: BoxDecoration(
                    color: incidentTint(
                      context,
                      category,
                    ).withValues(alpha: .1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    incidentIcon(category),
                    color: incidentTint(context, category),
                  ),
                ),
                title: Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: Text(description),
                trailing: const Text(
                  'Not set',
                  style: TextStyle(
                    color: Color(0xFF8A4B16),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 14),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(17),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.lock_outline_rounded, color: colors.secondary),
                  const SizedBox(width: 11),
                  const Expanded(
                    child: Text(
                      'Your reports are stored locally on this device. They are not sent to emergency services or a remote server.',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
