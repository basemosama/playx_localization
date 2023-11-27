import 'package:easy_localization/easy_localization.dart';

extension LocalizationStringExtensions on String {
  /// Check if the string is RTL
  bool get isRtl => Bidi.hasAnyRtl(this);

  /// Check if the string is LTR
  bool get isLtr => !isRtl;


  /// Regex for english characters
  RegExp get englishRegExp => RegExp(r'[a-zA-Z]');

  /// Regex for arabic characters
  RegExp get arabicRegExp => RegExp(r'[\u0600-\u06FF]');


  /// Check if the string is english
  bool get isEnglish => englishRegExp.hasMatch(this);

  /// Check if the string is arabic
  bool get isArabic => arabicRegExp.hasMatch(this);
}
