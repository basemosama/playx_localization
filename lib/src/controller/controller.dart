import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl_standalone.dart';
import 'package:playx_localization/playx_localization.dart';
import 'package:playx_localization/src/delegate/playx_localization_delegate.dart';
import 'package:playx_localization/src/easy_localization/translations.dart';

import '../easy_localization/localization.dart';
import 'translation_manager.dart';

const _lastKnownIndexKey = 'playx.locale.last_known_index';

/// PlayxLocalizationController :
/// Used to update current app locale with id, index, device locale and more.
/// And holds reference to the current app locale.
class PlayxLocaleController extends ValueNotifier<XLocale?> {
  final PlayxLocaleConfig config;

  PlayxLocaleController({
    required this.config,
  }) : super(null);

  late PlayxLocalizationDelegate delegate;

  Translations? _translations, _fallbackTranslations;

  /// current translations loaded from assets.
  Translations? get translations => _translations;

  /// current fallback translations loaded from assets.
  Translations? get fallbackTranslations => _fallbackTranslations;

  // Returns the device locale.
  Locale? deviceLocale;

  /// current locale index
  int get currentIndex {
    if (value == null) {
      throw Exception(
          'Localization has not been initialized. You must call boot method before accessing any property.');
    }
    return config.supportedLocales.indexOf(value!);
  }

  /// set up the base controller to load locales.
  Future<void> boot() async {
    EasyLocalization.logger('Booting Localization');

    final lastKnownIndex = PlayxPrefs.maybeGetInt(_lastKnownIndexKey);

    final foundPlatformLocale = await findSystemLocale();
    deviceLocale = foundPlatformLocale.toLocale();
    EasyLocalization.logger(
        'Device Locale ${deviceLocale?.toStringWithSeparator()}');

    XLocale? lastSavedLocale;
    if (lastKnownIndex != null &&
        lastKnownIndex >= 0 &&
        lastKnownIndex < config.supportedLocales.length) {
      lastSavedLocale = config.supportedLocales.atOrNull(
        lastKnownIndex,
      );
      EasyLocalization.logger(
          'Last Saved Locale ${lastSavedLocale?.locale.toStringWithSeparator()}');
    }

    final locale = _getStartLocale(savedLocale: lastSavedLocale);

    EasyLocalization.logger(
        'Start Locale ${locale.locale.toStringWithSeparator()}');

    //Load translations from assets
    await loadTranslations(locale);
    EasyLocalization.logger('Loaded Translation from assets');

    delegate = PlayxLocalizationDelegate(
      localizationController: this,
      supportedLocales: supportedXLocales,
    );
    value = locale;

    EasyLocalization.logger(
        'translation booted with ${locale.locale.toStringWithSeparator()}✔');
  }

  ///Gets current locale to start the app with
  ///First return any saved locale
  ///If there isn't any save locale uses start locale from the config
  ///If there is no save locale, Then it uses device locale if it's supported in the config supported locales.
  ///If It's not supported then uses the first locale inf the config supported locales.
  XLocale _getStartLocale({XLocale? savedLocale}) {
    if (savedLocale != null) return savedLocale;

    if (config.startLocale != null) return config.startLocale!;

    if (deviceLocale != null) {
      final searchedLocaleByCountryCode = supportedXLocales.firstWhereOrNull(
          (e) =>
              e.languageCode == deviceLocale!.languageCode &&
              e.countryCode == deviceLocale!.countryCode);
      if (searchedLocaleByCountryCode != null) {
        return searchedLocaleByCountryCode;
      }

      final searchedLocaleByOnlyLanguageCode =
          supportedXLocales.firstWhereOrNull(
              (e) => e.languageCode == deviceLocale!.languageCode);
      if (searchedLocaleByOnlyLanguageCode != null) {
        return searchedLocaleByOnlyLanguageCode;
      }
    }
    return getFallbackLocale();
  }

  ///Get fallback Locale
  /// if fallbackLocale is not null then return it
  /// if fallbackLocale is null then return english locale if it's supported in the config supported locales.
  /// if english locale is not supported then return the first locale in the config supported locales.
  XLocale getFallbackLocale() {
    if (config.fallbackLocale != null) return config.fallbackLocale!;
    if (config.supportedLocales.any((e) => e.languageCode == 'en')) {
      return config.supportedLocales.firstWhere((e) => e.languageCode == 'en');
    }
    return config.supportedLocales.first;
  }

  /// Load translations from assets
  Future<void> loadTranslations(XLocale locale) async {
    final res = await TranslationManager.loadTranslations(
      locale: locale,
      config: config,
      fallbackLocale: getFallbackLocale(),
    );
    _translations = res.translations;
    _fallbackTranslations = res.fallbackTranslations;

    Localization.load(locale.locale,
        translations: translations, fallbackTranslations: fallbackTranslations);
  }

  /// update the locale to be one of the supported locales.
  /// if the locale is not supported it will return false.
  /// if [forceAppUpdate] is true it will force the app to update.
  Future<bool> updateTo(XLocale locale, {bool forceAppUpdate = false}) async {
    final index = supportedXLocales.indexOf(locale);
    if (index < 0) return false;
    return _updateLocale(
      locale: locale,
      forceAppUpdate: forceAppUpdate,
    );
  }

  /// switch the locale to the next in the supported locales list
  /// if there is no next locale, it will switch to the first one
  /// if [forceAppUpdate] is true it will force the app to update.
  Future<void> nextLocale({bool forceAppUpdate = false}) async {
    final isLastLocale = currentIndex == config.supportedLocales.length - 1;

    await updateByIndex(
      isLastLocale ? 0 : currentIndex + 1,
      forceAppUpdate: forceAppUpdate,
    );
  }

  /// update the locale by index
  /// if the index is out of range it will return false.
  /// if [forceAppUpdate] is true it will force the app to update.
  Future<bool> updateByIndex(int index, {bool forceAppUpdate = false}) async {
    final locale = config.supportedLocales.atOrNull(index);
    if (locale == null) return false;
    return _updateLocale(locale: locale, forceAppUpdate: forceAppUpdate);
  }

  /// update the locale to by id
  /// if the id is not found it will return false.
  Future<bool> updateById(String id, {bool forceAppUpdate = false}) async {
    final locale =
        config.supportedLocales.firstWhereOrNull((element) => element.id == id);
    if (locale == null) return false;
    return _updateLocale(locale: locale, forceAppUpdate: forceAppUpdate);
  }

  /// Search for locale by language code and country code if available.
  XLocale? searchLocaleByLanguageCode(
      {required String languageCode, String? countryCode}) {
    final searchedLocaleByCountryCode = supportedXLocales.firstWhereOrNull(
        (e) => e.languageCode == languageCode && e.countryCode == countryCode);
    if (searchedLocaleByCountryCode != null) {
      return searchedLocaleByCountryCode;
    }
    //if not found by country code then search by language code only.
    final searchedLocaleByOnlyLanguageCode = supportedXLocales
        .firstWhereOrNull((e) => e.languageCode == languageCode);
    if (searchedLocaleByOnlyLanguageCode != null) {
      return searchedLocaleByOnlyLanguageCode;
    }
    return null;
  }

  /// update the locale to by language code and country code if available.
  /// if the locale is not supported it will return false.
  /// if [forceAppUpdate] is true it will force the app to update.
  Future<bool> updateByLanguageCode(
      {required String languageCode,
      String? countryCode,
      bool forceAppUpdate = false}) async {
    final locale = searchLocaleByLanguageCode(
        languageCode: languageCode, countryCode: countryCode);
    if (locale != null) {
      return updateTo(
        locale,
        forceAppUpdate: forceAppUpdate,
      );
    }
    return false;
  }

  /// Updates the locale to current device locale.
  /// if the locale is not supported it will return false.
  /// if [forceAppUpdate] is true it will force the app to update.
  Future<bool> updateToDeviceLocale({bool forceAppUpdate = false}) async {
    final locale = deviceLocale;
    if (locale == null) return false;
    return updateByLanguageCode(
        languageCode: locale.languageCode,
        countryCode: locale.countryCode,
        forceAppUpdate: forceAppUpdate);
  }

  /// Update the locale to be one of the supported locales.
  /// if [forceAppUpdate] is true it will force the app to update.
  Future<bool> _updateLocale({
    required XLocale locale,
    bool forceAppUpdate = false,
  }) async {
    try {
      await loadTranslations(
        locale,
      );
      if (config.saveLocale) {
        await PlayxPrefs.setInt(_lastKnownIndexKey, currentIndex);
      }

      Get.locale = locale.locale;

      value = locale;

      if (forceAppUpdate) {
        await _forceAppUpdate();
      }

      EasyLocalization.logger(
          'Updated locale to ${locale.name} with code ${locale.locale.toStringWithSeparator()}');
      return true;
    } catch (e) {
      EasyLocalization.logger.error(e);
      return false;
    }
  }

  ///Force app update.
  Future<void> _forceAppUpdate() {
    return WidgetsFlutterBinding.ensureInitialized().performReassemble();
  }

  ///returns the current supported xLocales.
  List<XLocale> get supportedXLocales {
    return config.supportedLocales;
  }

  ///returns the current supported locales.
  List<Locale> get supportedLocales =>
      supportedXLocales.map((e) => e.locale).toList();

  ///Check if current locale is arabic.
  bool isCurrentLocaleArabic() {
    if (value == null) {
      throw Exception(
          'Localization has not been initialized. You must call boot method before accessing any property.');
    }
    return value!.languageCode == 'ar';
  }

  ///Check if current locale is english.
  bool isCurrentLocaleEnglish() {
    if (value == null) {
      throw Exception(
          'Localization has not been initialized. You must call boot method before accessing any property.');
    }
    return value!.languageCode == 'en';
  }

  ///Check if current locale is right to left.
  bool isCurrentLocaleRtl() {
    if (value == null) {
      throw Exception(
          'Localization has not been initialized. You must call boot method before accessing any property.');
    }
    return value!.locale.isRTL;
  }

  /// Convert current [locale] to String with custom [separator] representing language code and country code.
  String currentLocaleToString({String separator = '_'}) {
    if (value == null) {
      throw Exception(
          'Localization has not been initialized. You must call boot method before accessing any property.');
    }
    return value!.locale.toStringWithSeparator(separator: separator);
  }

  ///Reset saved locales.
  Future<void> deleteSavedLocale() async {
    return PlayxPrefs.remove(_lastKnownIndexKey);
  }

  //delegates to be used in material app.
  List<LocalizationsDelegate> get delegates => [
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ];
}
