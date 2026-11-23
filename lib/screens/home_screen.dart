import 'package:flutter/material.dart';

import '../services/history_entry.dart';
import '../theme/app_theme.dart';

/// Screen 2. Three actions and the most recent result.
class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.latest,
    required this.onCamera,
    required this.onGallery,
    required this.onDownload,
    required this.onOpenLatest,
  });

  final HistoryEntry? latest;
  final VoidCallback onCamera;
  final VoidCallback onGallery;
  final VoidCallback onDownload;
  final void Function(HistoryEntry) onOpenLatest;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(AppTheme.spacing),
      children: [
        Text('What do you want to check?', style: theme.textTheme.headlineMedium),
        const SizedBox(height: AppTheme.spacing * 1.5),
        _ActionCard(
          icon: Icons.photo_camera_outlined,
          title: 'Take a photo',
          subtitle: 'Use the phone camera',
          onTap: onCamera,
        ),
        const SizedBox(height: 12),
        _ActionCard(
          icon: Icons.photo_library_outlined,
          title: 'Choose from gallery',
          subtitle: 'Pick a saved picture or screenshot',
          onTap: onGallery,
        ),
        const SizedBox(height: 12),
        _ActionCard(
          icon: Icons.cloud_download_outlined,
          title: 'Download an image',
          subtitle: 'Paste an image address from the internet',
          onTap: onDownload,
        ),
        const SizedBox(height: AppTheme.spacing * 2),
        Text('Most recent result', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        if (latest == null)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacing),
              child: Text('Nothing yet. Try one of the options above.',
                  style: theme.textTheme.bodyMedium),
            ),
          )
        else
          Card(
            clipBehavior: Clip.antiAlias,
            child: ListTile(
              onTap: () => onOpenLatest(latest!),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.memory(latest!.bytes, width: 48, height: 48, fit: BoxFit.cover),
              ),
              title: Text(latest!.top.label),
              subtitle: Text(
                  '${(latest!.top.confidence * 100).toStringAsFixed(1)} % · ${latest!.source}'),
              trailing: const Icon(Icons.chevron_right),
            ),
          ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias, // so the ripple (pressed state) stays rounded
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacing),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Icon(icon, color: theme.colorScheme.primary),
              ),
              const SizedBox(width: AppTheme.spacing),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.titleMedium),
                    Text(subtitle, style: theme.textTheme.bodyMedium),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
