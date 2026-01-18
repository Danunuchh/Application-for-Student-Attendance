import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class UpperCaseEnglishFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final upperText = newValue.text.replaceAllMapped(
      RegExp(r'[a-z]'),
      (m) => m.group(0)!.toUpperCase(),
    );

    return TextEditingValue(
      text: upperText,
      selection: newValue.selection,
    );
  }
}
