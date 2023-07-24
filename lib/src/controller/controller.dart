import 'dart:developer';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl_standalone.dart';
import 'package:playx_core/playx_core.dart';
import 'package:playx_localization/src/config/x_locale_config.dart';
export 'package:easy_localization/easy_localization.dart';
import 'package:easy_localization/src/easy_localization_controller.dart';
import 'package:easy_localization/src/localization.dart';
import 'package:playx_localization/src/delegate/playx_localization_delegate.dart';
import 'package:playx_localization/src/model/x_locale.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

const _lastKnownIndexKey = 'playx.locale.last_known_index';

///XThemeController used to handle all operations on themes like how to change theme, etc.
class XLocaleController extends GetxController {
  XLocaleConfig get config => Get.find<XLocaleConfig>();


  late EasyLocalizationController localizationController;
  late PlayxLocalizationDelegate delegate;

  XLocale? _current;

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

    if (config.fallbackLocale != null) return config.fallbackLocale!;

    return config.supportedLocales.first;
  }


  Locale? deviceLocale;

  /// current theme index
  int get currentIndex => config.supportedLocales.indexOf(currentXLocale);

  /// set up the base controller
  Future<void> boot() async {


    final lastKnownIndex = Prefs.getInt(_lastKnownIndexKey);

    final foundPlatformLocale = await findSystemLocale();
    deviceLocale = foundPlatformLocale.toLocale();

    if (lastKnownIndex != null &&
        lastKnownIndex >= 0 &&
        lastKnownIndex < config.supportedLocales.length) {
      _current = config.supportedLocales.atOrNull(
        lastKnownIndex,
      );
    }
    log('[playx_localization] booted ✔');

    localizationController = EasyLocalizationController(
      supportedLocales: supportedLocales,
      path: config.path,
      fallbackLocale: config.fallbackLocale?.locale,
      startLocale: currentXLocale.locale,
      useOnlyLangCode: config.useOnlyLangCode,
      useFallbackTranslations: config.useFallbackTranslations,
      assetLoader: config.assetLoader,
      saveLocale: false,
      onLoadError: (FlutterError e) {},
    );

    //Load translations from assets
    await localizationController.loadTranslations();

    //load translations into exploitable data, kept in memory
    Localization.load(localizationController.locale,
        translations: localizationController.translations,
        fallbackTranslations: localizationController.fallbackTranslations);

    delegate =  PlayxLocalizationDelegate(
      localizationController: localizationController,
      supportedLocales: supportedLocales,
    );
    log('[playx_localization] translation booted ✔');

  }

  /// update the theme to one of the theme list.
  Future<void> updateTo(
    XLocale locale,
  ) async {
    _current = locale;
    await Prefs.setInt(_lastKnownIndexKey, currentIndex);
    localizationController.setLocale(locale.locale);
    Get.updateLocale(locale.locale);
    update();
  }

  /// switch the theme to the next in the list
  /// if there is no next theme, it will switch to the first one
  Future<void> nextLocale() async {
    final isLastLocale = currentIndex == config.supportedLocales.length - 1;

    await updateByIndex(
      isLastLocale ? 0 : currentIndex + 1,
    );
  }

  /// update the theme to by index
  Future<void> updateByIndex(int index, {bool forceUpdateTheme = true}) async {
    try {
      final xLocale = config.supportedLocales[index];
      _current = xLocale;
      await Prefs.setInt(_lastKnownIndexKey, index);
      localizationController.setLocale(xLocale.locale);
      Get.updateLocale(xLocale.locale);
      update();
    } catch (err) {
      err.printError(info: 'Playx Locale :');
      if (err is! RangeError) rethrow;
    }
  }

  /// update the theme to by index
  Future<void> updateById(String id, {bool forceUpdateTheme = true}) async {
    try {
      final xLocale =
          config.supportedLocales.firstWhere((element) => element.id == id);
      _current = xLocale;
      await Prefs.setInt(_lastKnownIndexKey, currentIndex);
      localizationController.setLocale(xLocale.locale);
      Get.updateLocale(xLocale.locale);
      update();
    } catch (err) {
      err.printError(info: 'Playx Locale :');
      if (err is! RangeError) rethrow;
    }
  }

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


  List<XLocale> get supportedXLocales {
    return config.supportedLocales;
  }

  List<Locale> get supportedLocales {
    return config.supportedLocales.map((e) => e.locale).toList();
  }

  bool isCurrentLocaleArabic() {
    return currentXLocale.languageCode == 'ar';
  }

  bool isCurrentLocaleEnglish() {
    return currentXLocale.languageCode == 'en';
  }

  Future<void> resetSavedLocale() async {
    return Prefs.remove(_lastKnownIndexKey);
  }

  List<LocalizationsDelegate> get delegates => [
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

}
