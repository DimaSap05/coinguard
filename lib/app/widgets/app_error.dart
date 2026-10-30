import 'package:flutter/material.dart';

class AppError extends StatelessWidget {
  const AppError({super.key, required this.description, required this.onTap});
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 16,
        children: [
          Text(description, textAlign: TextAlign.center),
          FilledButton(onPressed: onTap, child: const Text('Повторить')),
        ],
      ),
    ),
  );
}
