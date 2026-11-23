import 'package:flutter/material.dart';

import '../services/classifier.dart';
import '../theme/app_theme.dart';

/// Screen 1. Also the loading screen while the model loads.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({
    super.key,
    required this.classifier,
    required this.error,
    required this.onStart,
  });

  final Classifier? classifier; // null while loading
  final String? error;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.spacing * 1.5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              Icon(Icons.center_focus_strong, size: 72, color: theme.colorScheme.primary),
              const SizedBox(height: AppTheme.spacing),
              Text('TM Classifier',
                  textAlign: TextAlign.center, style: theme.textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text(
                'Point your phone at an object and it tells you what it is, '
                'fully offline.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: AppTheme.spacing * 2),
              _buildBottom(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottom(BuildContext context) {
    final theme = Theme.of(context);

    // Error state
    if (error != null) {
      return Card(
        color: theme.colorScheme.errorContainer,
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacing),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.error_outline, color: theme.colorScheme.error),
              const SizedBox(height: 8),
              Text(error!, style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
      );
    }

    // Loading state
    if (classifier == null) {
      return Column(
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: AppTheme.spacing),
          Text('Loading the model…', style: theme.textTheme.bodyMedium),
        ],
      );
    }

    // Ready state: show the classes as chips and the button
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('It can recognise:', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final label in classifier!.labels) Chip(label: Text(label)),
          ],
        ),
        const SizedBox(height: AppTheme.spacing * 2),
        FilledButton(onPressed: onStart, child: const Text('Get started')),
      ],
    );
  }
}
