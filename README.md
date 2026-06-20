# JAMORE

Flutter HRM prototype reconstructed from `JAMORE Mobile App.zip`. The app runs on Android, iOS, Web, macOS, Windows, and Linux with adaptive navigation for phone, tablet, and desktop layouts.

## Included flows

- Demo login, remembered session, and simulated Face ID
- Dashboard, leave balances, announcements, schedules, and quick actions
- Leave requests with working-day calculation, half days, attachments metadata, history, cancellation, team calendar, and manager approval/rejection
- OT requests with date/time validation, rates, pay calculation, history, and cancellation
- Simulated GPS/selfie clock-in and clock-out with local work history
- TH/EN localization persisted locally
- Responsive bottom navigation and NavigationRail with stable URL routes
- Light theme, accessibility semantics, keyboard focus, scalable layout, and reduced-motion support
- Versioned JSON persistence and a demo-data reset action

Features shown in the source design without screen specifications open a themed “Coming soon” page rather than inventing product requirements.

## Demo credentials

```text
Username:   nattawut.c
Password:   jamore123
Company ID: JAMORE-TH
```

## Run

```bash
flutter pub get
flutter run
```

Select a target with `flutter devices`, for example `flutter run -d chrome` or `flutter run -d macos`.

## API configuration

The default API base URL is `https://universe.jamourthailand.com/api/`. Override it per environment without changing source code:

```bash
flutter run --dart-define=API_BASE_URL=https://staging.example.com/api/
```

`ApiClient` provides JSON requests, a 20-second timeout, normalized relative paths, typed API errors, and an optional Bearer-token provider. No endpoint is called until a feature repository is connected.

Login now calls `POST Authenticate/Login` with `UserName`, `Password`, and optional `CompanyID`. The returned JWT is attached to subsequent API requests for the current app process. It is intentionally not written to the prototype JSON store; add a secure-storage adapter before enabling persistent production sessions.

## Quality checks

```bash
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build web --release
flutter build apk --debug
```

CI runs format, analysis, unit/widget tests, Web build, and Android build on each push/PR. Manual workflows cover iOS, macOS, Windows, and Linux.

## Prototype constraints

- All business data is mock data stored locally. Repository boundaries are ready for an API implementation.
- GPS, selfie, and Face ID are simulations by design and request no device permissions.
- Web provides a real PDF/JPG/PNG picker. Native attachment picking has an adapter boundary but requires a file-picker plugin before production use.
- The IBM Plex Sans Thai font name and fallbacks are configured; add licensed font files under `assets/fonts/` before production to guarantee identical typography offline.
- Signing, backend authentication, telemetry, push notifications, and production secrets are intentionally not configured.

See [docs/architecture.md](docs/architecture.md) for structure and extension points.
