import 'package:intl/intl.dart';

enum Currency {
  eur,
  none,
}

extension CurrencyExt on Currency {
  String get symbol {
    switch (this) {
      case Currency.eur:
        return '€';
      case Currency.none:
        return '';
    }
  }

  String format(double price, {bool noSymbol = false}) {
    switch (this) {
      case Currency.eur:
        final formatter = NumberFormat.currency(
          locale: 'sk_SK',
          symbol: noSymbol ? '' : symbol,
        );
        return formatter.format(price);
      case Currency.none:
        return '$price';
    }
  }

  String get displayName {
    switch (this) {
      case Currency.eur:
        return 'EUR';
      case Currency.none:
        return '';
    }
  }
}

abstract class CurrencyUtil {
  static Currency forName(String name) {
    for (final currency in Currency.values) {
      if (currency.name == name) {
        return currency;
      }
    }
    throw StateError('Currency with name $name does not exist');
  }
}
