import 'package:flutter/material.dart';
import 'package:playx_localization/playx_localization.dart';
import 'package:playx_localization/src/controller/controller.dart';

///PlayxLocalizationBuilder:
///It allows us to create a widget with current locale.
///It should rebuild the widget automatically after changing the locale.
class PlayxLocalizationBuilder extends StatelessWidget {
  /// Place for your main page widget.
  final Widget Function(XLocale xLocale) builder;

  const PlayxLocalizationBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<XLocaleController>(builder: (c) {
      return builder(c.currentXLocale);
    });
  }
}
