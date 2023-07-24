import 'package:flutter/material.dart';
import 'package:playx_core/playx_core.dart';

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
