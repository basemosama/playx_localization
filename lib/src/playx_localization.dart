import 'package:flutter/material.dart';
import 'package:playx_core/playx_core.dart';
import 'package:playx_localization/src/config/x_locale_config.dart';
import 'package:playx_localization/src/controller/controller.dart';
import 'package:playx_localization/src/model/x_locale.dart';

abstract class PlayxLocalization {
  static XLocaleConfig get localeConfig => Get.find<XLocaleConfig>();

  static XLocaleController get _controller => Get.find<XLocaleController>();

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

  static XLocale get currentXLocale => _controller.currentXLocale;

  static Locale get currentLocale => _controller.currentXLocale.locale;

  static Locale? get deviceLocale => _controller.deviceLocale;

  /// current theme index
  static int get currentIndex => _controller.currentIndex;

  /// update the theme to one of the theme list.
  static Future<void> updateTo(
    XLocale locale,
  ) =>
      _controller.updateTo(locale);

  /// switch the theme to the next in the list
  /// if there is no next theme, it will switch to the first one
  static Future<void> nextLocale() => _controller.nextLocale();

  /// update the theme to by index
  static Future<void> updateByIndex(int index) =>
      _controller.updateByIndex(index);

  /// update the theme to by index
  static Future<void> updateById(
    String id,
  ) =>
      _controller.updateById(id);

  /// update the theme to by index
  static Future<bool> updateByLanguageCode(
          {required String languageCode, String? countryCode}) =>
      _controller.updateByLanguageCode(
          languageCode: languageCode, countryCode: countryCode);

  static List<XLocale> get supportedXLocales => _controller.supportedXLocales;

  static List<Locale> get supportedLocales =>_controller.supportedLocales;

  static bool isCurrentLocaleArabic() => _controller.isCurrentLocaleArabic();

  static bool isCurrentLocaleEnglish() => _controller.isCurrentLocaleEnglish();

  static Future<void> resetSavedLocale() => _controller.resetSavedLocale();

 static List<LocalizationsDelegate> get localizationDelegates =>_controller.delegates;

}
