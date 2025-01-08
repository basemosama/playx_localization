import '../../playx_localization.dart';

/// Locale config :
/// used to configure out app locales by providing the app with the supported locales and localization settings.
/// Create a class that extends the [PlayxLocaleConfig] class to implement your own locales.
class PlayxLocaleConfig {
  //App supported locales.
  final List<XLocale> supportedLocales;

  /// First Locale that the app starts with if there is not any saved locale.
  ///If equals null then it uses device locale.
  final XLocale? startLocale;

  /// Fallback Locale when the locale is not in the list.
  final XLocale? fallbackLocale;

  /// Trigger for using only language code for reading localization files.
  /// @Default value false
  /// Example:
  /// ```
  /// en.json //useOnlyLangCode: true
  /// en-US.json //useOnlyLangCode: false
  /// ```
  final bool useOnlyLangCode;

  /// If a localization key is not found in the locale file, try to use the fallbackLocale file.
  /// @Default value true
  /// Example:
  /// ```
  /// useFallbackTranslations: true
  /// ```
  final bool useFallbackTranslations;

  /// Path to your folder with localization files.
  /// Example:
  /// ```dart
  /// path: 'assets/translations',
  /// path: 'assets/translations/lang.csv',
  /// ```
  final String path;

  /// Class loader for localization files.
  /// You can use custom loaders from [Easy Localization Loader](https://github.com/aissat/easy_localization_loader) or create your own class.
  /// @Default value `const RootBundleAssetLoader()`
  // ignore: prefer_typing_uninitialized_variables
  final AssetLoader assetLoader;

  /// Save locale in device storage.
  /// @Default value true
  final bool saveLocale;

  /// Log missing keys in the console.
  final bool logMissingKeys;

  /// Migrate preferences to async storage.
  final bool migratePrefsToAsync;

  PlayxLocaleConfig({
    required this.supportedLocales,
    this.startLocale,
    this.fallbackLocale,
    this.useOnlyLangCode = false,
    this.useFallbackTranslations = true,
    this.path = 'assets/translations',
    this.assetLoader = const RootBundleAssetLoader(),
    this.saveLocale = true,
    this.logMissingKeys = false,
    this.migratePrefsToAsync = false,
  })  : assert(path.isNotEmpty, 'path can not be empty'),
        assert(
            supportedLocales.isNotEmpty, 'supportedLocales can not be empty');
}
