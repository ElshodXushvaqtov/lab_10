import 'package:flutter/material.dart';

import '../services/classifier.dart';
import '../theme/app_theme.dart';

/// Screen 5. Information about the model and the design credit.
/// Labels come from the already-loaded classifier (not read from the file again).
class ModelScreen extends StatelessWidget {
  const ModelScreen({super.key, required this.classifier});

  final Classifier classifier;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fileName = Classifier.modelPath.split('/').last;

    return ListView(
      padding: const EdgeInsets.all(AppTheme.spacing),
      children: [
        Text('Model', style: theme.textTheme.headlineMedium),
        const SizedBox(height: AppTheme.spacing),
        Card(
          child: Column(
            children: [
              _infoTile(Icons.insert_drive_file_outlined, 'Model file', fileName),
              _infoTile(Icons.category_outlined, 'Number of classes',
                  '${classifier.labels.length}'),
              _infoTile(Icons.photo_size_select_large, 'Input size',
                  '${Classifier.inputSize} × ${Classifier.inputSize} × 3'),
            ],
          ),
        ),
        const SizedBox(height: AppTheme.spacing * 1.5),
        Text('Labels', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        Card(
          child: Column(
            children: [
              for (var i = 0; i < classifier.labels.length; i++)
                ListTile(
                  leading: CircleAvatar(radius: 14, child: Text('$i')),
                  title: Text(classifier.labels[i]),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppTheme.spacing * 1.5),
        Text('Design credit', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacing),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(DesignCredit.name, style: theme.textTheme.titleMedium),
                Text('by ${DesignCredit.author}', style: theme.textTheme.bodyMedium),
                const SizedBox(height: 4),
                Text(DesignCredit.link, style: theme.textTheme.bodyMedium),
                Text('Licence: ${DesignCredit.license}', style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _infoTile(IconData icon, String title, String value) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: Text(value),
    );
  }
}
