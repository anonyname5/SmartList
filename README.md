# SmartList

SmartList is a Flutter Android app for project-based checklist planning with automatic totals, budgeting, target dates, and calendar tracking.

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
- Android home screen widget with summary data
- Theme mode switching (System / Light / Dark)

## Tech Stack

- Flutter
- Riverpod
- Isar (local offline database)
- `table_calendar`
- `home_widget`
- `flutter_animate`

## Project Structure

- `lib/models` - Isar models (`Project`, `Item`)
- `lib/services` - database, repositories, home widget sync
- `lib/providers` - Riverpod providers and actions
- `lib/screens` - home, project detail, calendar tab
- `lib/widgets` - create/edit dialogs
- `lib/utils` - calculations, currency, filtering/sorting, money helpers

## Run Locally

1. Install dependencies:
   - `flutter pub get`
2. Generate Isar files:
   - `dart run build_runner build --delete-conflicting-outputs`
3. Run app:
   - `flutter run`

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
3. Add **SmartList Widget**

The widget displays:
- Today target item count
- Planned / Bought / Remaining totals

## Tests and Quality

- Static analysis:
  - `flutter analyze`
- Test suite:
  - `flutter test`
