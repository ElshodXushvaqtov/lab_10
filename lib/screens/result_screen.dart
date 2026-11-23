import 'package:flutter/material.dart';

import '../services/history_entry.dart';
import '../theme/app_theme.dart';
import '../widgets/prediction_row.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key, required this.entry});

  final HistoryEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final halfScreen = MediaQuery.of(context).size.height * 0.45;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Result'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppTheme.spacing),
            child: Chip(
              avatar: Icon(iconForSource(entry.source), size: 18),
              label: Text(entry.source),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.spacing),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: halfScreen),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppTheme.radius),
                child: Image.memory(entry.bytes, fit: BoxFit.contain),
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spacing * 1.5),
          Text('Predictions', style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          for (var i = 0; i < entry.predictions.length; i++)
            PredictionRow(prediction: entry.predictions[i], isTop: i == 0),
        ],
      ),
    );
  }
}
