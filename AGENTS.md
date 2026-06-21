# Repository Guidelines

## Project Structure & Module Organization

JAMORE is a cross-platform Flutter HRM prototype. Application code lives in `lib/` and follows Clean Architecture: `domain/` contains entities and repository contracts; `application/` coordinates use cases; `data/` implements repositories and mappings; `infrastructure/` contains network, storage, and platform adapters; `presentation/`, `state/`, and `core/` provide UI, state, routing, configuration, and theming. Keep dependency direction inward and use `lib/main.dart` only as the composition root. The dependency rules are enforced by `test/architecture_dependency_test.dart`.

Tests live in `test/` and use the `*_test.dart` suffix. Static assets are under `assets/`; translations are in `lib/l10n/*.arb`. Platform runners live in `android/`, `ios/`, `web/`, `macos/`, `windows/`, and `linux/`. Architectural decisions and design guidance belong in `docs/`.

## Build, Test, and Development Commands

- `flutter pub get` installs dependencies.
- `flutter run` starts the app on a selected device; use `flutter run -d chrome` for Web.
- `flutter run --dart-define=API_BASE_URL=<url>` overrides the Universe API endpoint.
- `dart format lib test` formats Dart sources.
- `flutter analyze` applies `flutter_lints` and static checks.
- `flutter test` runs all unit, architecture, and widget tests.
- `flutter build web --release` or `flutter build apk --debug` validates deployable builds.

Run formatting, analysis, and tests before opening a pull request.

## Coding Style & Naming Conventions

Use Dart's standard two-space indentation and formatter output. Name files `snake_case.dart`, types `UpperCamelCase`, and members `lowerCamelCase`. Prefer small widgets, immutable models, constructor injection, and repository interfaces defined in `domain/`. Do not import Flutter, HTTP, storage, data adapters, or presentation code from `domain/` or `application/`. Never commit API tokens or production credentials.

## Testing Guidelines

Use `flutter_test`. Mirror the production behavior in focused files such as `test/auth_repository_test.dart`; describe observable outcomes and cover success and failure paths. Update architecture tests when adding module boundaries, but do not weaken existing dependency rules.

## Commit & Pull Request Guidelines

Recent commits use Conventional Commits, for example `feat(auth): load customer profile data after login` and `refactor(architecture): enforce clean dependency boundaries`. Keep commits scoped and imperative. PRs should explain behavior and architecture impact, link the GitHub issue, list verification commands, and include screenshots for UI changes. Use the triage labels documented in `docs/agents/triage-labels.md`.
