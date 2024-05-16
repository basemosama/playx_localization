import 'dart:math';

import 'package:intl/intl.dart';
import 'package:playx_localization/src/playx_localization.dart';

/// Extension functions to help operations on numbers.
extension NumExtensions on num {
  ///Extension function to round number to certain number
  double roundToPrecision({int numbersToRoundTo = 2}) {
    final fac = pow(10, numbersToRoundTo).toInt();
    return (this * fac).round() / fac;
  }

  /// Extension function to format number to currency number
  /// ```
  /// 1000000 => will be converted to 1000,000.00
  /// ```
  String toFormattedCurrencyNumber(
      {String format = "#,##0.00", String locale = 'en'}) {
    final numberFormat = NumberFormat(format, locale);
    return numberFormat.format(this);
  }

  /// Extension function to format number to  String
  String toFormattedNumber({required String format, String locale = 'en'}) {
    final numberFormat = NumberFormat(format, locale);
    return numberFormat.format(this);
  }

  /// Extension function to format number to arabic numbers String
  String toLocalizedArabicNumber() {
    return NumberFormat('#.##', 'ar_EG').format(this);
  }

  /// Extension function to format number to english numbers String
  String toLocalizedEnglishNumber() {
    return NumberFormat('#.##', 'en_US').format(this);
  }

  /// Extension function to format number to current arabic or english numbers String
  String toLocalizedArabicOrEnglishNumber() {
    return PlayxLocalization.isCurrentLocaleArabic()
        ? toLocalizedArabicNumber()
        : toLocalizedEnglishNumber();
  }

  /// Extension function to format number to localized numbers String
  String toLocalizedNumber({String locale = 'en'}) {
    return NumberFormat('#.##', locale).format(this);
  }
}
