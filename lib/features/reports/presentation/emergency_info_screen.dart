import 'package:flutter/material.dart';

import '../../emergency_contacts/data/emergency_contact_config.dart';

class EmergencyInfoScreen extends StatelessWidget {
  const EmergencyInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF1EC),
            borderRadius: BorderRadius.circular(22),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, color: Color(0xFFB43B2D)),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'SPIDY saves reports on this device. It is not connected to emergency services. If someone is in immediate danger, contact your local emergency service directly.',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Verified contacts',
          style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        if (verifiedEmergencyContacts.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.phone_in_talk_outlined, color: colors.primary),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'No verified emergency contacts are configured yet. Add contacts for the project’s target region in the emergency contact configuration.',
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
                leading: Icon(Icons.call_outlined, color: colors.primary),
                title: Text(contact.label),
                subtitle: Text('${contact.phoneNumber}\n${contact.source}'),
                isThreeLine: true,
              ),
            ),
          ),
      ],
    );
  }
}
