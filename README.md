# SmartList

SmartList is a Flutter Android app for project-based checklist planning with automatic totals, budgeting, target dates, calendar tracking, and basic cloud sync.

## Features

- Create, edit, and delete projects
- Add, edit, and delete checklist items
- Mark items as purchased (checkbox)
- Exclude/include items from total calculations
- Automatic totals:
  - Total Planned
  - Total Bought
  - Remaining
- Optional budget per project with warning when exceeded
- Optional target date per item (calendar picker)
- Calendar tab with:
  - marked dates that have target items
  - semantic markers (Overdue / Today / Upcoming)
  - grouped selected-day list sections
- Search, sorting, and category filtering in project detail
- Android home screen widgets (Detailed + Compact)
- Theme mode switching (System / Light / Dark)
- Firebase sync (manual sync button)
- Auth modes:
  - Anonymous guest mode
  - Google Sign-In
  - Guest-to-Google account linking

## Tech Stack

- Flutter
- Riverpod
- Isar (local offline database)
- Firebase Core / Auth / Firestore
- Google Sign-In
- `table_calendar`
- `home_widget`
- `flutter_animate`

## Project Structure

- `lib/models` - Isar models (`Project`, `Item`)
- `lib/services` - database, repositories, auth, sync, home widget sync
- `lib/providers` - Riverpod providers and actions
- `lib/screens` - home, project detail, calendar tab
- `lib/widgets` - create/edit dialogs
- `lib/utils` - calculations, currency, filtering/sorting, money helpers

## Run Locally

1. Install dependencies:
   - `flutter pub get`
2. Generate Isar files:
   - `dart run build_runner build --delete-conflicting-outputs`
3. Firebase setup (required for sync/auth):
   - Put `google-services.json` at `android/app/google-services.json`
   - Run `flutterfire configure --project=smartlist-29db5`
   - Enable providers in Firebase Authentication:
     - Anonymous
     - Google
   - Create Firestore database (Native mode)
   - Apply Firestore rules (see section below)
4. Run app:
   - `flutter run`

If `flutterfire` is not recognized on Windows PowerShell:
- Use `& "$env:LOCALAPPDATA\Pub\Cache\bin\flutterfire.bat" configure --project=smartlist-29db5 --yes`
- Optional PATH fix: add `%LOCALAPPDATA%\Pub\Cache\bin` to user PATH

## Firestore Rules (Per-User Data Isolation)

SmartList sync stores data under:
- `users/{uid}/projects/{projectSyncId}`
- `users/{uid}/items/{itemSyncId}`

Use these rules:

```txt
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

## Google Sign-In Android Setup Notes

In Firebase Console, for Android app `com.anonyname5.smartlist`:

1. Add SHA-1 and SHA-256 fingerprints (debug and release).
2. Re-download `google-services.json`.
3. Re-run `flutterfire configure`.

If sign-in fails with `ApiException: 10`, it is usually SHA mismatch or outdated Firebase config.

## API Key Security Note

Firebase Android config includes a Google API key (`google-services.json` / `firebase_options.dart`).
This key is expected to be public in mobile apps, but it should still be restricted in Google Cloud Console:

- Application restriction: Android apps (package + SHA)
- API restriction: only required Firebase APIs

If a key was previously broad, rotate it and refresh Firebase config files.

## Build APK

- Debug APK:
  - `flutter build apk --debug`
  - Output: `build/app/outputs/flutter-apk/app-debug.apk`

- Release APK:
  - `flutter build apk --release`

## Android Home Widget

After installing the app:

1. Long press Android home screen
2. Open Widgets
3. Add SmartList Widget (Detailed) or SmartList Widget (Compact)

Widgets display:
- Today target item count
- Planned / Bought / Remaining totals

## Tests and Quality

- Static analysis:
  - `flutter analyze`
- Test suite:
  - `flutter test`
