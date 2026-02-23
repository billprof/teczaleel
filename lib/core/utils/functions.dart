import 'package:intl/intl.dart';

class Utils {
  static String formatMoney(num value, {String symbol = 'GHS'}) {
    final formatter = NumberFormat.currency(
      symbol: '${symbol.toUpperCase()} ',
      decimalDigits: 2,
    );

    return formatter.format(value);
  }
}
