

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:playx_localization/src/controller/controller.dart';
import 'package:playx_localization/src/easy_localization/localization.dart';


///The delegates for this app's Localizations widget.
///
/// The delegates collectively define all of the localized resources for this application's Localizations widget
class PlayxLocalizationDelegate extends LocalizationsDelegate<Localization> {
  final List<Locale>? supportedLocales;
  final XLocaleController? localizationController;

  ///  * use only the lang code to generate i18n file path like en.json or ar.json
  // final bool useOnlyLangCode;

  PlayxLocalizationDelegate(
      {this.localizationController, this.supportedLocales}) {
    EasyLocalization.logger.debug('Init Localization Delegate');
  }

  @override
  bool isSupported(Locale locale) => supportedLocales!.contains(locale);

  @override
  Future<Localization> load(Locale locale) async {
    EasyLocalization.logger.debug('Load Localization Delegate');
    if (localizationController!.translations == null) {
      await localizationController!.loadTranslations();
    }

    Localization.load(locale,
        translations: localizationController!.translations,
        fallbackTranslations: localizationController!.fallbackTranslations);
    
    return Future.value(Localization.instance);
  }

  @override
  bool shouldReload(LocalizationsDelegate<Localization> old) => false;
}

