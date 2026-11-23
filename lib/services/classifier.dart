import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

/// One label and how sure the model is about it.
class Prediction {
  const Prediction(this.label, this.confidence);

  final String label;
  final double confidence; // 0.0 to 1.0
}

/// Turns the text of labels.txt into a list of names.
/// "0 Mug\n1 Bottle\n" becomes ['Mug', 'Bottle'].
/// Works with Windows line endings (\r\n) and blank lines too.
List<String> parseLabels(String raw) {
  final labels = <String>[];
  for (final line in raw.split('\n')) {
    final clean = line.trim(); // trim() also removes the \r from Windows files
    if (clean.isEmpty) continue;
    // Remove the number at the start: "2 Car keys" -> "Car keys"
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

  /// Loads the model and the labels. Slow, so call it only once.
  static Future<Classifier> load() async {
    final interpreter = await Interpreter.fromAsset(modelPath);
    final labelText = await rootBundle.loadString(labelsPath);
    return Classifier._(interpreter, parseLabels(labelText));
  }

  /// Image bytes in, sorted list of predictions out (highest first).
  List<Prediction> classify(Uint8List bytes) {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      throw const FormatException('This file is not a readable image.');
    }

    // Same crop as Teachable Machine: centre square, 224 x 224.
    final upright = img.bakeOrientation(decoded);
    final square = img.copyResizeCropSquare(upright, size: inputSize);

    // Input shape [1, 224, 224, 3], every value between -1 and 1.
    final input = [
      List.generate(inputSize, (y) {
        return List.generate(inputSize, (x) {
          final p = square.getPixel(x, y);
          return [p.r / 127.5 - 1, p.g / 127.5 - 1, p.b / 127.5 - 1];
        });
      }),
    ];

    // Output shape [1, number of classes].
    final output = [List<double>.filled(labels.length, 0)];
    _interpreter.run(input, output);

    // Pair each number with its label FIRST, then sort.
    final results = <Prediction>[];
    for (var i = 0; i < labels.length; i++) {
      results.add(Prediction(labels[i], output[0][i]));
    }
    results.sort((a, b) => b.confidence.compareTo(a.confidence));
    return results;
  }

  void close() => _interpreter.close();
}
