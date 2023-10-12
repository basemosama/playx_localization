import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl_standalone.dart';
import 'package:playx_core/playx_core.dart';
import 'package:playx_localization/src/config/x_locale_config.dart';
import 'package:playx_localization/src/delegate/playx_localization_delegate.dart';
import 'package:playx_localization/src/easy_localization/localization.dart';
import 'package:playx_localization/src/easy_localization/translations.dart';
import 'package:playx_localization/src/model/x_locale.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

const _lastKnownIndexKey = 'playx.locale.last_known_index';

///XLocaleController used to handle all operations on locales like how to change locale, etc.
class XLocaleController extends GetxController {
  XLocaleConfig get config => Get.find<XLocaleConfig>();

  late PlayxLocalizationDelegate delegate;

  XLocale? _current;


  Translations? _translations, _fallbackTranslations;
  Translations? get translations => _translations;
  Translations? get fallbackTranslations => _fallbackTranslations;

  ///Gets current locale to start the app with
  ///First return any saved locale
  ///If there isn't any save locale uses start locale from the config
  ///If there is no save locale, Then it uses device locale if it's supported in the config supported locales.
  ///If It's not supported then uses the first locale inf the config supported locales.
  XLocale get currentXLocale {
    if (_current != null) return _current!;

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

    return _getFallbackLocale();
  }

  // Returns the device locale.
  Locale? deviceLocale;

  /// current locale index
  int get currentIndex => config.supportedLocales.indexOf(currentXLocale);

  /// set up the base controller to load locales.
  Future<void> boot() async {
    final lastKnownIndex = PlayxPrefs.maybeGetInt(_lastKnownIndexKey);

    final foundPlatformLocale = await findSystemLocale();
    deviceLocale = foundPlatformLocale.toLocale();

    if (lastKnownIndex != null &&
        lastKnownIndex >= 0 &&
        lastKnownIndex < config.supportedLocales.length) {
      _current = config.supportedLocales.atOrNull(
        lastKnownIndex,
      );
    }
    EasyLocalization.logger('initialized current locale ✔');

    //Load translations from assets
    await loadTranslations();

    //load translations into exploitable data, kept in memory
    Localization.load(currentXLocale.locale,
        translations: translations,
        fallbackTranslations: fallbackTranslations);

    delegate = PlayxLocalizationDelegate(
      localizationController: this,
      supportedLocales: supportedLocales,
    );
    EasyLocalization.logger('translation booted ✔');
  }




  //Get fallback Locale
   XLocale _getFallbackLocale() {
     if (config.fallbackLocale != null) return config.fallbackLocale!;
     return config.supportedLocales.first;
  }


  Future loadTranslations() async {
    Map<String, dynamic> data;
    try {
      data = Map.from(await loadTranslationData(currentXLocale));
      _translations = Translations(data);
      if (config.useFallbackTranslations ) {
        Map<String, dynamic>? baseLangData;
        if (currentXLocale.countryCode != null && currentXLocale.countryCode!.isNotEmpty) {
          baseLangData =
          await loadBaseLangTranslationData(currentXLocale);
        }
        data = Map.from(await loadTranslationData(_getFallbackLocale()));
        if (baseLangData != null) {
          try {
            data.addAll(baseLangData);
          } on UnsupportedError {
            data = Map.of(data)..addAll(baseLangData);
          }
        }
        _fallbackTranslations = Translations(data);
      }
    } on FlutterError catch (e) {
      // onLoadError(e);
      EasyLocalization.logger.error(e.message);
    } catch (e) {
      EasyLocalization.logger.error(e);
      // onLoadError(FlutterError(e.toString()));
    }
  }

  Future<Map<String, dynamic>?> loadBaseLangTranslationData(
      XLocale locale) async {
    try {
      return await loadTranslationData(locale);
    } on FlutterError catch (e) {
      // Disregard asset not found FlutterError when attempting to load base language fallback
      EasyLocalization.logger.error(e.message);
    }
    return null;
  }

  Future<Map<String, dynamic>> loadTranslationData(XLocale locale) async {
    late Map<String, dynamic>? data;

    if (config.useOnlyLangCode) {
      data = await config.assetLoader.load(config.path, Locale(locale.languageCode));
    } else {
      data = await config.assetLoader.load(config.path, locale.locale);
    }

    if (data == null) return {};

    return data;
  }






  /// update the locale to be one of the supported locales.
  Future<bool> updateTo(
    XLocale locale,
  ) async {
    final index = supportedXLocales.indexOf(locale);
    if (index < 0) return false;
    return _updateLocale(locale: locale);
  }

  /// switch the locale to the next in the supported locales list
  /// if there is no next locale, it will switch to the first one
  Future<void> nextLocale() async {
    final isLastLocale = currentIndex == config.supportedLocales.length - 1;

    await updateByIndex(
      isLastLocale ? 0 : currentIndex + 1,
    );
  }

  /// update the locale to by index
  Future<bool> updateByIndex(int index, {bool forceUpdateTheme = true}) async {
    final locale = config.supportedLocales.atOrNull(index);
    if (locale == null) return false;
    return _updateLocale(locale: locale);
  }

  /// update the locale to by index
  Future<bool> updateById(String id, {bool forceUpdateTheme = true}) async {
    final locale =
        config.supportedLocales.firstWhereOrNull((element) => element.id == id);
    if (locale == null) return false;
    return _updateLocale(locale: locale);
  }

  /// update the locale to by language code and country code if available.
  Future<bool> updateByLanguageCode(
      {required String languageCode, String? countryCode}) async {
    final searchedLocaleByCountryCode = supportedXLocales.firstWhereOrNull(
        (e) => e.languageCode == languageCode && e.countryCode == countryCode);
    if (searchedLocaleByCountryCode != null) {
      await updateTo(searchedLocaleByCountryCode);
      return true;
    }
    final searchedLocaleByOnlyLanguageCode = supportedXLocales
        .firstWhereOrNull((e) => e.languageCode == languageCode);
    if (searchedLocaleByOnlyLanguageCode != null) {
      await updateTo(searchedLocaleByOnlyLanguageCode);
      return true;
    }
    return false;
  }

  /// Updates the locale to current device locale.
  Future<bool> updateToDeviceLocale() async {
    final locale = deviceLocale;
    if (locale == null) return false;
    final searchedLocaleByCountryCode = supportedXLocales.firstWhereOrNull(
        (e) =>
            e.languageCode == locale.languageCode &&
            e.countryCode == locale.countryCode);
    if (searchedLocaleByCountryCode != null) {
      return updateTo(searchedLocaleByCountryCode);
    }
    final searchedLocaleByOnlyLanguageCode = supportedXLocales
        .firstWhereOrNull((e) => e.languageCode == locale.languageCode);
    if (searchedLocaleByOnlyLanguageCode != null) {
      return updateTo(searchedLocaleByOnlyLanguageCode);
    }
    return false;
  }


  ///function to update the locale and save current locale.
  Future<bool> _updateLocale({required XLocale locale}) async {
    _current = locale;
    if (config.saveLocale) {
      await PlayxPrefs.setInt(_lastKnownIndexKey, currentIndex);
    }
    await loadTranslations();
    await Get.updateLocale(locale.locale);
    EasyLocalization.logger('Updated locale to ${locale.name} with code ${locale.locale.toStringWithSeparator()}');
    update();
    return true;
  }

  ///returns the current supported xLocales.
  List<XLocale> get supportedXLocales {
    return config.supportedLocales;
  }

  ///returns the current supported Locales.
  List<Locale> get supportedLocales {
    return config.supportedLocales.map((e) => e.locale).toList();
  }

  ///Check if current locale is arabic.
  bool isCurrentLocaleArabic() {
    return currentXLocale.languageCode == 'ar';
  }

  ///Check if current locale is english.
  bool isCurrentLocaleEnglish() {
    return currentXLocale.languageCode == 'en';
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
