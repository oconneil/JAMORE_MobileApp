# JAMORE Design System

The canonical visual language for the app. Apply this to **every** screen so the
product stays cohesive. New pages should reuse these tokens and patterns rather
than inventing their own.

## Branding

- **App name:** written as **"Jamore"** (not all-caps). Source of truth for the
  in-app name is `l10n.appName`; launcher labels live in each platform manifest
  (Android `android:label`, iOS `CFBundleDisplayName`, web `manifest.json`).
- **Login wordmark:** `assets/branding/app_Logo_Login_blue.png` — blue "Jamore"
  wordmark. It is blue-on-transparent, so always place it on a **white surface**
  (never directly on the blue glass/gradient).
- **App launcher icon:** `assets/branding/icon_J32_2.png` (the "J" mark).
  Configured via `flutter_launcher_icons` in `pubspec.yaml`; regenerate with
  `dart run flutter_launcher_icons`. Provide a 1024×1024 master to also cover
  web/macOS/Windows (the 512×512 source only satisfies Android + iOS).

## Core direction

- **Primary brand color:** `#0099CC` (`JamoreColors.primary`), dark variant
  `#007FA8` (`JamoreColors.primaryDark`).
- **Mode:** Light style. Light canvas (`#F4F6FA`), white surfaces, dark ink text
  (`#0F172A`), muted slate for secondary text (`#64748B`).
- **Signature treatment:** Glass morphism — frosted translucent cards
  (`BackdropFilter` blur) with white hairline borders, floating over a brand
  gradient background with soft blurred light "blobs". Used prominently on the
  login screen; reuse for hero/auth/empty-state surfaces.

## Where the tokens live

`lib/core/theme.dart` is the single source of truth:

- `JamoreColors` — all palette constants (`primary`, `primaryDark`, `canvas`,
  `surface`, `ink`, `muted`, `line`, `success`, `warning`, `danger`).
- `JamoreTheme.light` — the `ThemeData`, input decoration, snackbar, and page
  transition defaults. Font family: `IBM Plex Sans Thai Looped` (TH/EN).

Always pull colors from `JamoreColors`; never hardcode hex values in screens.

## Glass morphism recipe (reference: `lib/presentation/login_screen.dart`)

1. **Page background** — keep the app's **light canvas** (`JamoreColors.canvas`
   `#F4F6FA`), same as every other screen, so login stays consistent. Add 2–3
   faint brand-tinted blurred blobs (`primary @ 0.08–0.16`, amber `#FDE68A @
   0.22`) for subtle depth (`_AuroraBackground`). Do **not** flood the page with
   brand colour.
2. **Card** — the brand colour lives *here*, echoing the dashboard's blue
   `_WorkHero`: `ClipRRect(28–30)` + `BackdropFilter(blur ~22)` + brand gradient
   (`primary @ .94 → primaryDark @ .97`) + white border at `~0.35` opacity +
   shadow `#0099CC @ 25%`. White text/labels read on this blue card.
3. **Text on glass** — white for labels/headings; keep field labels **above**
   inputs (a floating label notches into the border and loses contrast).
4. **Inputs on glass** — near-opaque white fill (`white @ 0.92`), dark ink text,
   `primary` prefix icons, rounded `16`. Interactive icons inside a white field
   must use `primaryDark` (never white — it disappears).
5. **Buttons on glass** — primary action is a solid **white** button with
   `primaryDark` label; secondary is a white-outline button.

## Dialogs / alerts

Centered rounded dialog (`radius 26`), tinted icon circle (e.g. danger
`#FDECEC` + `danger` icon), bold title, muted body, full-width primary action.
Reference: `_LoginFailedDialog`.
