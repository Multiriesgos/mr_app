abstract final class Constants {
  // Injected at build time via --dart-define=MR_API_KEY=<value>
  // Never hardcode this value. See docs/SETUP.md for local dev setup.
  static const String kMrApiKey = String.fromEnvironment('MR_API_KEY');
}
