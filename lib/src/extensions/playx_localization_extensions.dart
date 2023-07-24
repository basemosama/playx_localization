import 'package:easy_localization/easy_localization.dart' as ez;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Strings extension method for access to [tr] and [plural()]
/// Example :
/// ```dart
/// 'title'.tr
/// 'day'.plural(21)
extension PlayxLocalizationStringExtensions on String {
  /// ```
  /// {@macro tr}
  String get tr => ez.tr(this);

  bool trExists() => ez.trExists(this);

  /// {@macro plural}
  String  plural(
    num value, {
    List<String>? args,
    BuildContext? context,
    Map<String, String>? namedArgs,
    String? name,
    NumberFormat? format,
  }) =>
      ez.plural(
        this,
        value,
        context: context,
        args: args,
        namedArgs: namedArgs,
        name: name,
        format: format,
      );
}
