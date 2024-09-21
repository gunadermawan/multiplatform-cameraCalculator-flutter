class AppConfig {
  static const bool useCameraRoll =
      bool.fromEnvironment('USE_CAMERA_ROLL', defaultValue: false);
  static const bool useBuiltInCamera =
      bool.fromEnvironment('USE_BUILT_IN_CAMERA', defaultValue: false);
  static const bool useEncryptedStorage =
      bool.fromEnvironment('USE_ENCRYPTED_STORAGE', defaultValue: false);
}
