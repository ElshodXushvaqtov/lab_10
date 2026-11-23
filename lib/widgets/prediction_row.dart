import 'package:flutter/material.dart';

import '../services/classifier.dart';

/// Label name, a bar and the percentage. The top row is bold and coloured.
class PredictionRow extends StatelessWidget {
  const PredictionRow({super.key, required this.prediction, this.isTop = false});

  final Prediction prediction;
  final bool isTop;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percent = (prediction.confidence * 100).toStringAsFixed(1);

    final textStyle = isTop
        ? theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary)
        : theme.textTheme.bodyLarge;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(prediction.label, style: textStyle, overflow: TextOverflow.ellipsis),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: prediction.confidence,
                minHeight: isTop ? 12 : 8,
                color: isTop ? theme.colorScheme.primary : theme.colorScheme.secondary,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
              ),
            ),
          ),
          SizedBox(
            width: 70,
            child: Text('$percent %', style: textStyle, textAlign: TextAlign.right),
          ),
        ],
      ),
    );
  }
}
