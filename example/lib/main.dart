import 'package:flutter/material.dart';
import 'package:playx_localization/playx_localization.dart';
import 'package:playx_localization_example/app_locale_config.dart';
import 'package:playx_localization_example/translation/app_trans.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PlayxCore.bootCore();
  await PlayxLocalization.boot(config: AppLocaleConfig());


  runApp(PlayxLocalizationBuilder(
    builder: (XLocale xLocale) {
      return const MyApp();
    },
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      supportedLocales: PlayxLocalization.supportedLocales,
      localizationsDelegates: PlayxLocalization.localizationDelegates,
      locale: PlayxLocalization.currentLocale,
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppTrans.appName.tr),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${AppTrans.changeLanguageTitle.tr} : بلاي',
                style:  TextStyle(fontSize: 18,
                    color: ('${AppTrans.changeLanguageTitle.tr} : بلاي').isArabic ? Colors.blueAccent : Colors.black),

              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                  onPressed: () {
                    Get.dialog(Center(
                        child: Card(
                      margin: const EdgeInsets.all(8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            AppTrans.changeLanguageTitle.tr,
                            style: const TextStyle(fontSize: 20),
                          ),
                          ...PlayxLocalization.supportedXLocales
                              .map((e) => ListTile(
                                    onTap: () {
                                      PlayxLocalization.updateById(e.id);
                                      Get.back();
                                    },
                                    title: Text(e.name),
                                    trailing:
                                        PlayxLocalization.currentXLocale.id ==
                                                e.id
                                            ? const Icon(
                                                Icons.done,
                                                color: Colors.lightBlue,
                                              )
                                            : const SizedBox.shrink(),
                                  ))
                              .toList(),
                        ],
                      ),
                    )));
                  },
                  child: Text(AppTrans.chooseLanguage.tr))
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          PlayxLocalization.updateByIndex(
              PlayxLocalization.isCurrentLocaleArabic() ? 0 : 1);
        },
        label: Text('change_language_title'.tr),
        icon: const Icon(Icons.update),
      ),
    );
  }
}
