import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:playx_localization/src/easy_localization/public.dart' as ez;

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
    Map<String, String>? namedArgs,
    String? name,
    NumberFormat? format,
  }) =>
      ez.plural(
        this,
        value,
        args: args,
        namedArgs: namedArgs,
        name: name,
        format: format,
      );
}


/// Text widget extension method for access to [tr()] and [plural()]
/// Example :
/// ```dart
/// Text('title').tr()
/// Text('day').plural(21)
/// ```
extension TextTranslateExtension on Text {
  /// {@macro tr}
  Text tr(
      {List<String>? args,
        Map<String, String>? namedArgs,
        String? gender}) =>
      Text(
          ez.tr(
            data ?? '',
            args: args,
            namedArgs: namedArgs,
            gender: gender,
          ),
          key: key,
          style: style,
          strutStyle: strutStyle,
          textAlign: textAlign,
          textDirection: textDirection,
          locale: locale,
          softWrap: softWrap,
          overflow: overflow,
          textScaleFactor: textScaleFactor,
          maxLines: maxLines,
          semanticsLabel: semanticsLabel,
          textWidthBasis: textWidthBasis);

  /// {@macro plural}
  Text plural(
      num value, {
        List<String>? args,
        Map<String, String>? namedArgs,
        String? name,
        NumberFormat? format,
      }) =>
      Text(
          ez.plural(
            data ?? '',
            value,
            args: args,
            namedArgs: namedArgs,
            name: name,
            format: format,
          ),
          key: key,
          style: style,
          strutStyle: strutStyle,
          textAlign: textAlign,
          textDirection: textDirection,
          locale: locale,
          softWrap: softWrap,
          overflow: overflow,
          textScaleFactor: textScaleFactor,
          maxLines: maxLines,
          semanticsLabel: semanticsLabel,
          textWidthBasis: textWidthBasis);
}


