import 'package:flutter/material.dart';
import 'package:playx_core/playx_core.dart';
import 'package:playx_localization/src/config/x_locale_config.dart';
import 'package:playx_localization/src/controller/controller.dart';
import 'package:playx_localization/src/model/x_locale.dart';

/// PlayxLocalization :
/// Used to update current app locale with id, index, device locale and more.
/// And holds reference to the current app locale.
/// With other utilities to be used.
/// Must be initialized by calling [boot] before calling any method.
abstract class PlayxLocalization {
  static XLocaleController get _controller => Get.find<XLocaleController>();

  ///Setup the current app locales with your configuration.
  ///And loads app supported translations.
  /// Must be called before calling any other method to initialize dependencies.
  static Future<void> boot({
    required XLocaleConfig config,
  }) async {
    WidgetsFlutterBinding.ensureInitialized();
    await EasyLocalization.ensureInitialized();
    final controller = XLocaleController();
    Get
      ..put<XLocaleConfig>(config)
      ..put<XLocaleController>(controller);
    return controller.boot();
  }

  ///Returns current x locale to start the app with.
  ///First return any saved locale.
  ///If there isn't any save locale uses start locale from the config.
  ///If there is no save locale, Then it uses device locale if it's supported in the config supported locales.
  ///If It's not supported then uses the first locale inf the config supported locales.
  static XLocale get currentXLocale => _controller.currentXLocale;

  /// Returns the locale of [currentXLocale].
  static Locale get currentLocale => _controller.currentXLocale.locale;

  /// Returns the locale of device.
  static Locale? get deviceLocale => _controller.deviceLocale;

  /// Returns current locale index.
  static int get currentIndex => _controller.currentIndex;

  /// Switch the locale to the next in the supported locales list
  /// if there is no next locale, it will switch to the first one
  static Future<void> nextLocale() => _controller.nextLocale();

  ///Update the locale to be one of the supported locales.
  static Future<bool> updateTo(
    XLocale locale,
  ) =>
      _controller.updateTo(locale);

  /// Update the locale by index
  static Future<bool> updateByIndex(int index) =>
      _controller.updateByIndex(index);

  /// update the theme to by id
  static Future<bool> updateById(
    String id,
  ) =>
      _controller.updateById(id);

  /// update the locale to by language code and country code if available.
  static Future<bool> updateByLanguageCode(
          {required String languageCode, String? countryCode}) =>
      _controller.updateByLanguageCode(
          languageCode: languageCode, countryCode: countryCode);

  /// Updates the locale to current device locale.
  static Future<bool> updateToDeviceLocale() =>
      _controller.updateToDeviceLocale();

  ///returns the current supported xLocales.
  static List<XLocale> get supportedXLocales => _controller.supportedXLocales;

  ///returns the current supported Locales.
  static List<Locale> get supportedLocales => _controller.supportedLocales;

  ///Check if current locale is arabic.
  static bool isCurrentLocaleArabic() => _controller.isCurrentLocaleArabic();

  ///Check if current locale is english.
  static bool isCurrentLocaleEnglish() => _controller.isCurrentLocaleEnglish();

  ///Reset saved locale.
  static Future<void> resetSavedLocale() => _controller.resetSavedLocale();

  //delegates to be used in material app.
  static List<LocalizationsDelegate> get localizationDelegates => _controller.delegates;
}
