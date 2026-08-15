/// Build-time environment the app was compiled for.
///
/// Selected via `--dart-define=APP_ENV=dev|staging|prod`. Defaults to [dev]
/// so a plain `flutter run` never accidentally behaves like production.
enum AppEnvironment {
  dev,
  staging,
  prod;

  static AppEnvironment fromName(String name) {
    return AppEnvironment.values.firstWhere(
      (env) => env.name == name,
      orElse: () => AppEnvironment.dev,
    );
  }
}
