# Architecture

## Structure

```text
lib/
  core/          theme, route parser/delegate, localization helpers
  data/          serializable models, seed data, persistence and attachment adapters
  l10n/          TH/EN ARB sources and generated localizations
  presentation/  adaptive shell, shared components, feature screens
  state/         application state and business operations
```

The UI depends on `AppState`; `AppState` depends on `AppRepository`; the repository depends on the `LocalStore` interface. Native builds persist versioned JSON in the application-support directory. Web persists the same JSON schema in `localStorage`. This boundary can be replaced with API and secure-auth repositories without rewriting feature widgets.

Provider is the composition/listening mechanism available in the offline toolchain. State and repository APIs remain package-neutral so migration to Riverpod is mechanical when that dependency is available.

## Navigation

The app uses Flutter Router APIs directly. Each user-visible state has a stable path, including:

- `/dashboard`
- `/leave`, `/leave/request`, `/leave/calendar`, `/leave/approvals`, `/leave/:id`
- `/overtime`, `/overtime/request`, `/overtime/:id`
- `/worktime`, `/worktime/check-in`, `/worktime/history`
- `/profile`, `/soon/:feature`

Phone layouts use floating bottom navigation. Widths from 720 px use NavigationRail, extended at 1120 px. Page content has bounded readable widths.

## Domain rules

- Leave duration counts Monday–Friday and excludes seeded holidays. Half days are allowed only for a single working day.
- Pending leave and OT requests can be cancelled; decided requests are read-only.
- Rejection requires a reason and records a decision timestamp.
- OT uses the employee model’s mock hourly wage (`฿250`) and 1.5×, 2×, or 3× rates.
- Worktime is a two-state daily transition: clock in, then clock out. Duplicate/out-of-order actions are ignored.
- Seed dates are relative to the device date so “today” data does not age.

## Persistence and migration

`DemoData.toJson()` includes `schemaVersion: 1`. Unknown versions or corrupt data fall back to a clean seed. Production migrations should be added in `AppRepository.load()` before increasing the version.

## Production replacement checklist

1. Implement authenticated API repositories behind the current state methods.
2. Store tokens in platform secure storage; never reuse demo credentials.
3. Add a native file-picker/upload adapter and server-side file validation.
4. Replace simulated biometrics, location, and selfie verification with permission-aware services.
5. Add staging-backed integration tests, telemetry consent, crash reporting, and push notifications.
6. Bundle the approved IBM Plex Sans Thai font files and replace placeholder branding assets.
