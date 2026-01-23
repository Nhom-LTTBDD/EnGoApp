import 'package:flutter/material.dart';
import '../../../core/constants/app_spacing.dart';

class TranslationErrorWidget extends StatelessWidget {
  final String? errorMessage;

  const TranslationErrorWidget({super.key, this.errorMessage});

  @override
  Widget build(BuildContext context) {
    if (errorMessage == null) {
      return const SizedBox.shrink();
    }
    return buildErrorMessage(errorMessage: errorMessage);
  }
}

Widget buildErrorMessage({String? errorMessage}) {
  return Container(
    padding: const EdgeInsets.all(spaceMd),
    decoration: BoxDecoration(
      color: Colors.red.shade50,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.red.shade200),
    ),
    child: Row(
      children: [
        Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
        const SizedBox(width: spaceSm),
        Expanded(
          child: Text(
            errorMessage!,
            style: TextStyle(fontSize: 14, color: Colors.red.shade700),
          ),
        ),
      ],
    ),
  );
}
