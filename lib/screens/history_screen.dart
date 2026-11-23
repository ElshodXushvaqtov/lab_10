import 'package:flutter/material.dart';

import '../services/history_entry.dart';
import '../theme/app_theme.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key, required this.history, required this.onOpen});

  final List<HistoryEntry> history;
  final void Function(HistoryEntry) onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (history.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacing * 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.history, size: 64, color: theme.colorScheme.primary),
              const SizedBox(height: AppTheme.spacing),
              Text('No history yet', style: theme.textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                'Every picture you classify will show up here.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppTheme.spacing),
      itemCount: history.length + 1,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        if (i == 0) {
          return Text('History', style: theme.textTheme.headlineMedium);
        }
        final entry = history[i - 1];
        final percent = (entry.top.confidence * 100).toStringAsFixed(1);
        return Card(
          clipBehavior: Clip.antiAlias,
          child: ListTile(
            onTap: () => onOpen(entry),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.memory(entry.bytes,
                  width: 52, height: 52, fit: BoxFit.cover),
            ),
            title: Text(entry.top.label),
            subtitle: Text('$percent %'),
            trailing: Icon(iconForSource(entry.source)),
          ),
        );
      },
    );
  }
}
