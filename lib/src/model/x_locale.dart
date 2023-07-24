import 'package:flutter/material.dart';
import 'package:playx_core/playx_core.dart';

///Defines locales with more information like id and name.
///These info can be used to change the current locale.
///display name of the locale and more.
class XLocale extends Equatable {
  final String id;
  final String name;
  final String languageCode;
  final String? countryCode;

  const XLocale({
    required this.id,
    required this.name,
    required this.languageCode,
    this.countryCode,
  });

  Locale get locale => Locale(languageCode, countryCode);

  @override
  List<Object?> get props => [id, name, languageCode, countryCode];
}
