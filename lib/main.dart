import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/main_shell.dart';
import 'screens/welcome_screen.dart';
import 'services/classifier.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const TmApp());
}

class TmApp extends StatefulWidget {
  const TmApp({super.key});

  @override
  State<TmApp> createState() => _TmAppState();
}

class _TmAppState extends State<TmApp> {
  Classifier? _classifier;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  Future<void> _loadModel() async {
    try {
      final classifier = await Classifier.load();
      setState(() => _classifier = classifier);
      if (kDebugMode) await _smokeTest(classifier);
    } catch (e) {
      setState(() {
        _error = 'Could not load the model.\n\n'
            'Expected files:\n'
            '• ${Classifier.modelPath}\n'
            '• ${Classifier.labelsPath}\n\n'
            'Check that they exist and that pubspec.yaml lists assets/model/.\n\n'
            'Details: $e';
      });
    }
  }

  Future<void> _smokeTest(Classifier classifier) async {
    try {
      final data = await rootBundle.load('assets/model/sample.jpg');
      final results = classifier.classify(data.buffer.asUint8List());
      var sum = 0.0;
      for (final p in results) {
        debugPrint('${p.label}: ${(p.confidence * 100).toStringAsFixed(1)} %');
        sum += p.confidence;
      }
      debugPrint('Classes: ${results.length}, sum = ${sum.toStringAsFixed(3)}');
    } catch (e) {
      debugPrint('Smoke test skipped: $e');
    }
  }

  @override
  void dispose() {
    _classifier?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TM Classifier',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: Builder(
        builder: (context) => WelcomeScreen(
          classifier: _classifier,
          error: _error,
          onStart: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => MainShell(classifier: _classifier!),
              ),
            );
          },
        ),
      ),
    );
  }
}
