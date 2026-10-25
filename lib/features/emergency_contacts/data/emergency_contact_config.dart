import '../domain/emergency_contact.dart';

/// Add only verified contacts and set the geographic region they serve.
const verifiedEmergencyContactRegion = 'India (nationwide)';

const verifiedEmergencyContacts = <EmergencyContact>[
  EmergencyContact(
    label: 'Emergency Response Support System (ERSS)',
    phoneNumber: '112',
    region: 'India (nationwide)',
    source: 'Ministry of Home Affairs, Government of India · 112.gov.in',
  ),
];
