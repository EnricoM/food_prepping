# Workspace Custom Instructions

These rules describe how AI assistants should author code in this Flutter project. Adjust them as the product vision evolves.

## Architectural preferences
- Use Melos to manage a multi-package workspace; each feature lives in its own package with a dedicated `pubspec.yaml`.
- Imports between feature packages are only allowed when the dependency is declared in the consuming package's `pubspec.yaml`.
- Build Flutter apps with Material 3, null safety, and current stable Flutter/Dart tooling.
- Organize `lib/` using a feature-first structure:
  - `lib/app/` for root config (router, theme, DI).
  - `lib/features/<feature_name>/` split into `data`, `domain`, and `presentation` layers.
- Favor Riverpod for state management and `dart_mappable` for model classes.
- Keep widgets small and composable; push business logic into controllers/use-cases.
- Define widgets in their own files unless co-locating them materially improves readability during analysis.
- Use the `http` package for REST API calls unless another client is explicitly required.

## Coding conventions
- Enable `lint` or `flutter_lints` and keep files formatted via `dart format`.
- Use explicit types and final/const where possible.
- Name async functions with verb phrases ending in `Async`.
- Prefer dependency injection—expose constructors that accept collaborators.

## Testing expectations
- Add meaningful unit/widget tests for every non-trivial feature; keep coverage in mind when modifying code.
- When generating new code, also provide unit, widget, and integration tests covering the change.
- Use `flutter_test` for widgets and `mocktail` for mocking dependencies.
- Include golden tests when introducing complex UI layouts.

## Delivery requirements
- Document new public APIs with Dart doc comments and short README updates when features affect setup.
- After sizable changes, describe manual QA steps or `flutter test` commands to run.
- Keep commit messages descriptive (present tense, 72 char subject).

## Collaboration notes
- Before generating scaffolding, explain the planned files and get confirmation if scope seems ambiguous.
- When trade-offs arise (e.g., blocking backend, missing assets) propose alternatives instead of stalling.
- Surface assumptions and TODOs inline using `// TODO(username): ...` so they are easy to track.

Customize any section above to better fit the workflow; these are only starter defaults.

## Multi-lingual Support

The app uses **slang** package for handling different languages and localization.

### Key Requirements
- The app must follow the language of the device (use device locale automatically)
- If no translations are available for the device language, the app must default to English
- All user-facing strings must be localized and stored in translation files managed by slang

### Implementation Guidelines
- Use slang's code generation to create typed translation keys
- Store translation files in the appropriate localization directory structure
- Configure the MaterialApp with proper locale resolution that:
  1. First checks if the device locale is supported
  2. Falls back to English (`en`) if the device locale is not available
  3. Uses slang's generated localization delegates
- Always provide English translations as the base/default language
- When adding new UI strings, immediately add them to all translation files or mark them as TODO if translations are pending

### Locale Resolution Example
```dart
MaterialApp(
  supportedLocales: AppLocaleUtils.supportedLocales,
  locale: _deviceLocale,
  localeResolutionCallback: (deviceLocale, supportedLocales) {
    // Check if device locale is supported
    for (var locale in supportedLocales) {
      if (locale.languageCode == deviceLocale?.languageCode) {
        return locale;
      }
    }
    // Default to English if device locale not supported
    return const Locale('en');
  },
  localizationsDelegates: AppLocaleUtils.localizationsDelegates,
  // ... rest of config
)
```

## Documentation
All documentation files are located in the `docs/` folder.

## Melos Workspace Setup

This project uses **Melos** for monorepo management. The workspace is configured in the root `pubspec.yaml` file (not `melos.yaml`).

### Workspace Structure

```
food_prepping/
├── pubspec.yaml              # Workspace root with melos: configuration
├── packages/                 # Shared packages
│   ├── core/
│   ├── parsing/
│   ├── data/
│   ├── shared_ui/
│   ├── meal_planner/
│   └── capture/
└── apps/                     # Applications
    └── recipe_keeper/        # Main Flutter app
```

### Configuration

1. **Root `pubspec.yaml`** contains the Melos configuration:
   ```yaml
   name: recipe_parser_workspace
   dev_dependencies:
     melos: ^7.0.0
   
   melos:
     packages:
       - packages/**
       - apps/**
     scripts:
       format:
         run: dart run melos exec -- dart format .
       analyze:
         run: dart run melos exec -- flutter analyze
       test:
         run: dart run melos exec -- flutter test
   ```

2. **Package `pubspec.yaml` files** should include:
   ```yaml
   name: package_name
   resolution: workspace  # ✅ Required for packages
   version: 0.1.0
   publish_to: 'none'
   
   dependencies:
     other_package:
       path: ../other_package  # Use path: for workspace dependencies
   ```

3. **App `pubspec.yaml` files** should NOT include `resolution: workspace`:
   ```yaml
   name: app_name
   # No resolution: workspace for apps
   
   dependencies:
     package_name:
       path: ../../packages/package_name
   ```

### Setup Commands

1. **Install workspace dependencies:**
   ```bash
   dart pub get  # From workspace root
   ```

2. **Install app dependencies:**
   ```bash
   cd apps/recipe_keeper
   flutter pub get
   ```

3. **Run Melos scripts:**
   ```bash
   dart run melos format    # Format all packages
   dart run melos analyze   # Analyze all packages
   dart run melos test      # Test all packages
   ```

### Key Points

- ✅ Use `pubspec.yaml` with `melos:` section (not `melos.yaml`)
- ✅ Add `resolution: workspace` to all **packages** (not apps)
- ✅ Use `path:` for workspace dependencies (not `workspace: true`)
- ✅ Run `dart pub get` from workspace root first
- ✅ Apps can run `flutter pub get` from their directory