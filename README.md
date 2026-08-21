# banapp

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Environment variables

Copy `env.example.json` to `env.json` and fill in your Supabase/PowerSync
credentials. `env.json` is gitignored and never committed.

Run or build passing the file:

```
flutter run --dart-define-from-file=env.json
flutter build web --dart-define-from-file=env.json
```
