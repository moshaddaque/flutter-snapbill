# SnapBill

SnapBill is an offline-first Flutter portfolio application for personal expense and receipt management. It is designed as a polished startup-style MVP that demonstrates product thinking, clean Flutter architecture, Riverpod state composition, local persistence, analytics, testing, and responsible AI-assisted engineering.

## Why I Built This

Expense apps are a strong portfolio domain because they require real user flows, validation, persistence, filtering, derived analytics, and careful mobile UI decisions. SnapBill turns those requirements into a compact but production-minded Flutter project rather than a generic CRUD demo.

## Product Preview

Screens included:

- Splash and premium onboarding
- Dashboard with monthly spending, quick actions, categories, recent transactions, and local insights
- Add Expense with validation and receipt attachment
- Receipt attachment with gallery/camera image support
- Expense History with search and category filters
- Expense Details
- Analytics
- Settings with demo data reset

## Key Features

- Offline SQLite persistence with realistic seeded data
- Manual expense creation with category, date, note, and receipt image
- Receipt image attachment from gallery or camera
- Monthly totals, previous month comparison, category breakdown, trend chart, highest category, average daily spend, and transaction count
- Light and dark Material 3 themes
- Responsive mobile-first UI
- Unit and widget tests for real business behavior

## Architecture

SnapBill uses a feature-first structure:

```text
lib/
  app/
    router/
    theme/
  core/
    extensions/
    utils/
    widgets/
  features/
    analytics/
    dashboard/
    expenses/
    onboarding/
    receipt_parser/
    settings/
```

The code separates presentation widgets, domain models, repository contracts, data implementations, service abstractions, and analytics calculations.

## Why Riverpod?

SnapBill has dependent and derived state relationships:

```text
expense list
  -> filtered expenses
  -> selected month expenses
  -> totals, category breakdowns, trends, and insights
```

Riverpod keeps source state small and composes derived values without manually synchronizing duplicated state.

## Receipt Attachment

SnapBill lets users attach receipt images from the gallery or camera while entering expense details manually.

No OCR, remote AI API, cloud OCR API, or paid parsing service is used.

## Tech Stack

- Flutter stable and Dart
- Material 3
- Riverpod
- SQLite via `sqflite`
- `image_picker`
- `fl_chart`
- `intl`
- `go_router`

## Project Structure

Important files:

- `lib/features/expenses/domain/expense.dart`
- `lib/features/expenses/domain/expense_repository.dart`
- `lib/features/expenses/data/sqlite_expense_repository.dart`
- `lib/features/expenses/presentation/expense_providers.dart`
- `lib/features/analytics/domain/expense_analytics.dart`
- `lib/features/receipt_parser/presentation/receipt_preview_screen.dart`

## Screenshots

Add screenshots here after running the app on a simulator or device:

- Dashboard
- Add Expense
- Attach Receipt
- Analytics
- Dark Theme

## Getting Started

```bash
flutter pub get
flutter run
```

## Running Tests

```bash
flutter test
flutter analyze
```

## Current Limitations

- Expense details are entered manually; receipt images are stored by local file path.
- Authentication, cloud sync, budgets, and export flows are not included.
- Receipt images are referenced by local file path.

## Future Improvements

- Optional OCR can be revisited later with a stable plugin strategy
- Budget goals and recurring expense detection
- CSV/PDF export
- Cloud sync and encrypted backup
- Golden tests for visual regressions

## AI-Assisted Development

AI coding tools were used to accelerate implementation and iteration. Architecture decisions, requirement definition, code review, debugging, and final engineering validation were performed as part of the development workflow.

## Engineering Decisions

- Riverpod is used for composed state instead of copying derived values into multiple providers.
- SQLite keeps the MVP fully offline and interview-friendly.
- Analytics logic is isolated in pure Dart utilities so it can be tested independently from Flutter UI.
- Receipt image support is intentionally simple and stable for Android release builds.

## License

MIT License. Add a `LICENSE` file before publishing publicly if needed.
# flutter-snapbill
