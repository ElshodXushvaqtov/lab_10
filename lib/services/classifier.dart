import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class Prediction {
  const Prediction(this.label, this.confidence);

  final String label;
  final double confidence;
}

List<String> parseLabels(String raw) {
  final labels = <String>[];
  for (final line in raw.split('\n')) {
    final clean = line.trim();
    if (clean.isEmpty) continue;
    labels.add(clean.replaceFirst(RegExp(r'^\d+\s+'), ''));
  }
  return labels;
}

class Classifier {
  Classifier._(this._interpreter, this.labels);

  static const modelPath = 'assets/model/model_unquant.tflite';
  static const labelsPath = 'assets/model/labels.txt';
  static const inputSize = 224;

  final Interpreter _interpreter;
  final List<String> labels;

  static Future<Classifier> load() async {
    final interpreter = await Interpreter.fromAsset(modelPath);
    final labelText = await rootBundle.loadString(labelsPath);
    return Classifier._(interpreter, parseLabels(labelText));
  }

  List<Prediction> classify(Uint8List bytes) {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      throw const FormatException('This file is not a readable image.');
    }

    final upright = img.bakeOrientation(decoded);
    final square = img.copyResizeCropSquare(upright, size: inputSize);

    final input = [
      List.generate(inputSize, (y) {
        return List.generate(inputSize, (x) {
          final p = square.getPixel(x, y);
          return [p.r / 127.5 - 1, p.g / 127.5 - 1, p.b / 127.5 - 1];
        });
      }),
    ];

    final output = [List<double>.filled(labels.length, 0)];
    _interpreter.run(input, output);

    final results = <Prediction>[];
    for (var i = 0; i < labels.length; i++) {
      results.add(Prediction(labels[i], output[0][i]));
    }
    results.sort((a, b) => b.confidence.compareTo(a.confidence));
    return results;
  }

  void close() => _interpreter.close();
}
