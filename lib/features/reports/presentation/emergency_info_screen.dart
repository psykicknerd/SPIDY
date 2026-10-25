import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../emergency_contacts/data/emergency_contact_config.dart';
import '../../emergency_contacts/domain/emergency_contact.dart';
import 'widgets/civic_widgets.dart';

class EmergencyInfoScreen extends StatelessWidget {
  const EmergencyInfoScreen({super.key});

  Future<void> _openDialer(
    BuildContext context,
    EmergencyContact contact,
  ) async {
    final uri = Uri(scheme: 'tel', path: contact.phoneNumber);
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!context.mounted) return;
      if (!launched) {
        _showMessage(context, 'The device could not open its phone dialer.');
      }
    } catch (_) {
      if (!context.mounted) return;
      _showMessage(context, 'Could not open the phone dialer.');
    }
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.maybeOf(context)
        ?.showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return PageWidth(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
      child: ListView(
        children: [
          Text(
            'Emergency information',
            style: Theme.of(context).textTheme.headlineMedium
                ?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -.6),
          ),
          const SizedBox(height: 5),
          Text(
            'Verified emergency services for the configured region.',
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: colors.onSurfaceVariant),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: colors.errorContainer,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: colors.error.withValues(alpha: .25)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.emergency_rounded, color: colors.error, size: 23),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'SPIDY is a college project and is not monitored by emergency responders. Do not rely on this app to request help. Contact your local emergency service directly.',
                    style: TextStyle(
                      color: colors.onErrorContainer,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Emergency services',
                  style: Theme.of(context).textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              Flexible(
                child: Text(
                  'Region: $verifiedEmergencyContactRegion',
                  textAlign: TextAlign.end,
                  style: Theme.of(context).textTheme.labelSmall
                      ?.copyWith(color: colors.onSurfaceVariant),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (verifiedEmergencyContacts.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.fact_check_outlined, color: colors.primary),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'No verified emergency phone numbers are configured for a target region yet. Call actions will appear here after approved local contacts are added.',
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...verifiedEmergencyContacts.map(
              (contact) => _EmergencyContactCard(
                contact: contact,
                onCall: () => _openDialer(context, contact),
              ),
            ),
          const SizedBox(height: 18),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(17),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline_rounded, color: colors.secondary),
                  const SizedBox(width: 11),
                  const Expanded(
                    child: Text(
                      'Tapping Call only opens the device dialer with the selected number. SPIDY does not place calls automatically.',
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Incident reports are stored on this device and are not sent to responders.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: colors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _EmergencyContactCard extends StatelessWidget {
  const _EmergencyContactCard({required this.contact, required this.onCall});

  final EmergencyContact contact;
  final VoidCallback onCall;

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 10),
    child: Padding(
      padding: const EdgeInsets.all(15),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            foregroundColor: Theme.of(context).colorScheme.primary,
            child: const Icon(Icons.health_and_safety_outlined),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contact.label,
                  style: Theme.of(context).textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 3),
                SelectableText(
                  contact.phoneNumber,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  '${contact.region} · Verified: ${contact.source}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          FilledButton.icon(
            onPressed: onCall,
            icon: const Icon(Icons.call_outlined),
            label: const Text('Call'),
          ),
        ],
      ),
    ),
  );
}
