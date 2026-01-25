import 'package:flutter/material.dart';
import '../../../core/theme/theme_helper.dart';

class BuildInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const BuildInfoRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 16, color: getTextPrimary(context)),
            ),
          ],
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: getTextPrimary(context),
          ),
        ),
      ],
    );
  }
}
