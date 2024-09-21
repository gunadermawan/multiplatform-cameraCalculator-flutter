class AppConfig {
  static const bool isRedTheme =
      bool.fromEnvironment('IS_RED_THEME', defaultValue: false);
  static const bool isGreenTheme =
      bool.fromEnvironment('IS_GREEN_THEME', defaultValue: false);
  static const bool useCameraRoll =
      bool.fromEnvironment('USE_CAMERA_ROLL', defaultValue: true);
  static const bool useBuiltInCamera =
      bool.fromEnvironment('USE_BUILT_IN_CAMERA', defaultValue: false);
  static const bool useEncryptedStorage =
      bool.fromEnvironment('USE_ENCRYPTED_STORAGE', defaultValue: false);
}
