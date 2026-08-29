class AppEnv {
  const AppEnv._();

  static const bool useFakeData = bool.fromEnvironment(
    'USE_FAKE_DATA',
    defaultValue: true,
  );

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000',
  );

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 20);

  static const int feedPageSize = 10;
  static const int commentsPageSize = 15;
}
