# SPIDY

SPIDY is an Android-first Flutter prototype for creating and reviewing citizen incident reports. Reports are stored locally on the device. The app does not currently send reports to a server or emergency services.

## Current features

- Create a report for fire, accident, medical emergency, or suspicious activity.
- Enter an incident description and a manual location, or request current GPS coordinates.
- Optionally attach up to four photos.
- Save reports and photo copies locally, then review them in report history.
- Show a clear **Local only** status.
- Keep emergency contact configuration empty until verified contacts for a target region are supplied.

## Run on Android

Install Flutter and Android Studio/Android SDK, then from this directory run:

```powershell
flutter doctor
flutter pub get
flutter run
```

The first run needs access to the Flutter package registry to resolve the dependencies in `pubspec.yaml`.

## Structure

```text
lib/
  app/                       app theme and composition
  core/                      shared infrastructure (reserved)
  features/
    emergency_contacts/      configurable verified contacts
    reports/
      data/                  local SQLite persistence
      domain/                report model and repository contract
      presentation/          report form, history, and app state
```

The report repository is an interface so a REST implementation can be introduced later without making screens depend on HTTP or a specific backend. No endpoints are configured.
