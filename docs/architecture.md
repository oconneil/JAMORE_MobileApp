# Architecture

## Dependency rule

The project follows Clean Architecture with dependencies pointing inward:

```text
presentation ──> application ──> domain
                       ▲             ▲
                       │             │
               infrastructure      data

main.dart = composition root
```

`domain/` and `application/` do not import Flutter, HTTP, storage, data adapters, or presentation modules. `test/architecture_dependency_test.dart` enforces these rules.

## Structure

```text
lib/
  domain/
    entities/          business entities and invariants
    repositories/      repository contracts
  application/
    session/           authenticated-session orchestration
    hr/                HR workspace workflows
    ports/             outbound interfaces used by application/presentation
  data/
    repositories/      repository adapters
    mappers/           transport and persistence mapping
    seed/              prototype seed data
  infrastructure/
    network/           Universe and customer HTTP clients
    storage/           native and web local storage adapters
    platform/          platform attachment-picker adapter
  presentation/        screens and widgets
  state/               Flutter presentation state
  core/                routing, theme, config, and UI helpers
  main.dart             dependency composition
```

## Authenticated session flow

```text
LoginScreen
  -> AppState.login()
  -> SessionCoordinator.signIn()
  -> AuthGateway
  -> CompanyGateway
  -> CustomerApiSession.configure()
  -> UserGateway
  -> EmployeeGateway (when EmployeeID exists)
  -> AuthenticatedSession
```

`SessionCoordinator` owns ordering and failure translation. `AppState` only maps the result to presentation state and navigation.

## HR workspace

`HrWorkspace` owns leave, overtime, approvals, worktime, locale, session flags, and persistence orchestration. It depends on `AppDataRepository`; `LocalAppDataRepository` maps the pure domain snapshot to versioned JSON through `DemoDataMapper`.

## Platform seams

- `CustomerApiSession` is implemented by `JamoreApiConnection`.
- `AttachmentPicker` is implemented by `PlatformAttachmentPicker`.
- `LocalStore` has native and web adapters selected through conditional imports.

## Production replacement checklist

1. Replace local HR persistence with repository adapters backed by authenticated endpoints.
2. Store tokens in platform secure storage.
3. Add a native file-picker/upload adapter and server-side file validation.
4. Replace simulated biometrics, location, and selfie verification with permission-aware adapters.
5. Add staging integration tests, telemetry consent, crash reporting, and push notifications.
