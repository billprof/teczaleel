import 'package:flutter/material.dart';
import 'package:teczaleel/generated/assets.dart';

class EmptyList extends StatelessWidget {
  final String title;
  final double height;
  const EmptyList({super.key, required this.title, this.height = 120});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Image(image: AssetImage(Assets.imagesNoProduct), height: height),
        SizedBox(height: 16),
        Text(title),
      ],
    );
  }
}
