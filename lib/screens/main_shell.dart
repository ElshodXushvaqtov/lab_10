import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../services/classifier.dart';
import '../services/history_entry.dart';
import '../services/image_sources.dart';
import 'history_screen.dart';
import 'home_screen.dart';
import 'model_screen.dart';
import 'result_screen.dart';

/// Holds the bottom navigation (Home, History, Model) and the history list.
/// All three image sources end in handleImage(), so classification code
/// exists only once.
class MainShell extends StatefulWidget {
  const MainShell({super.key, required this.classifier});

  final Classifier classifier;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  final _sources = ImageSources();
  final List<HistoryEntry> _history = []; // newest first
  int _tab = 0;

  // ---------------- The single path: bytes -> classify -> Result -> History

  Future<void> handleImage(Uint8List? bytes, String source) async {
    if (bytes == null) return; // user cancelled: do nothing

    _showLoading('Classifying…');
    // Let the dialog draw before the model blocks the UI thread.
    await Future.delayed(const Duration(milliseconds: 100));

    try {
      final watch = Stopwatch()..start();
      final predictions = widget.classifier.classify(bytes);
      watch.stop();
      debugPrint('classify took ${watch.elapsedMilliseconds} ms');

      final entry = HistoryEntry(
        bytes: bytes,
        predictions: predictions,
        source: source,
        time: DateTime.now(),
      );
      setState(() => _history.insert(0, entry));

      if (!mounted) return;
      Navigator.of(context).pop(); // close loading dialog
      openResult(entry);
    } on FormatException catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();
      _showError(e.message);
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();
      _showError('Something went wrong while classifying: $e');
    }
  }

  void openResult(HistoryEntry entry) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ResultScreen(entry: entry)),
    );
  }

  // ---------------- The three sources

  Future<void> _takePhoto() async {
    try {
      final bytes = await _sources.fromCamera();
      await handleImage(bytes, 'Camera');
    } catch (e) {
      _showError('Could not open the camera: $e');
    }
  }

  Future<void> _chooseFromGallery() async {
    try {
      final bytes = await _sources.fromGallery();
      await handleImage(bytes, 'Gallery');
    } catch (e) {
      _showError('Could not open the gallery: $e');
    }
  }

  Future<void> _downloadImage() async {
    final url = await _askForUrl();
    if (url == null || url.trim().isEmpty) return;

    _showLoading('Downloading…');
    Uint8List bytes;
    try {
      bytes = await _sources.fromUrl(url);
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();
      _showError(e.toString().replaceFirst('Exception: ', ''));
      return;
    }
    if (!mounted) return;
    Navigator.of(context).pop(); // close "Downloading…"
    await handleImage(bytes, 'Download');
  }

  Future<String?> _askForUrl() {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Download an image'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.url,
          decoration: const InputDecoration(
            labelText: 'Image address',
            hintText: 'https://example.com/mug.jpg',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('Download'),
          ),
        ],
      ),
    );
  }

  // ---------------- Small helpers

  void _showLoading(String text) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 20),
            Expanded(child: Text(text)),
          ],
        ),
      ),
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  // ---------------- Build

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(
        latest: _history.isEmpty ? null : _history.first,
        onCamera: _takePhoto,
        onGallery: _chooseFromGallery,
        onDownload: _downloadImage,
        onOpenLatest: openResult,
      ),
      HistoryScreen(history: _history, onOpen: openResult),
      ModelScreen(classifier: widget.classifier),
    ];

    return Scaffold(
      body: SafeArea(child: screens[_tab]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.history), label: 'History'),
          NavigationDestination(icon: Icon(Icons.memory), label: 'Model'),
        ],
      ),
    );
  }
}
