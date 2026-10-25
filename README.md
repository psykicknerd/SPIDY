# CivicShield

CivicShield is an Android-first Flutter prototype for citizen incident reporting. Report records and photos are stored locally on the device. There is no backend connection, and reports are not sent to emergency services.

## Run on Android

Install Flutter and Android Studio/Android SDK, then from this directory run:

```powershell
flutter pub get
flutter run
```

## Current experience

- Home dashboard with report action, category shortcuts, recent report previews, and emergency information.
- Incident form for fire, accident, medical emergency, and suspicious activity, with manual/GPS location and optional photos.
- Local report history and report details.
- Emergency information screen. Verified regional contact numbers have not been configured; the UI does not invent or call mock numbers.
- Sample report cards on Home are marked as sample and are never saved.

## Structure

```text
lib/
  app/                       app theme and composition
  features/
    emergency_contacts/      verified contact configuration
    reports/
      data/                  SQLite repository and demo previews
      domain/                report model and repository contract
      presentation/          home, report, history, details, and shared UI
```

The repository interface is ready for a future REST implementation once an API contract is provided.
