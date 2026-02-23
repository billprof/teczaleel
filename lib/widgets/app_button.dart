import 'package:flutter/material.dart';
import 'package:gradient_coloured_buttons/gradient_coloured_buttons.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  const AppButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GradientButton(
      text: text,
      textStyle: TextStyle(
        fontWeight: FontWeight.bold,
        // fontSize: 15,
        color: Colors.white,
      ),
      gradientColors: [Color(0xFF1fc2f0), Color(0xFF7b32e8)],
      // width: 200,
      // height: 50,
      borderRadius: 16.0,
      onPressed: onPressed,
    );
  }
}
