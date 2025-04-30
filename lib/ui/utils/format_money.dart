import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CurrencyInputFormatter extends TextInputFormatter {
  final NumberFormat _formatter = NumberFormat.currency(
    locale: 'en',
    symbol: '',
    decimalDigits: 0,
  );

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Remove any characters that are not digits
    final newText = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    final newInt = int.tryParse(newText) ?? 0;

    // Format the value
    final formattedText = _formatter.format(newInt);

    // Calculate the new cursor position
    int offset = newValue.selection.baseOffset +
        formattedText.length -
        newValue.text.length;

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: offset),
    );
  }
}
