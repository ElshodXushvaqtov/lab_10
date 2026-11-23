import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'classifier.dart';

/// One finished classification. Stored so the Result screen can be
/// reopened later without running the model again.
class HistoryEntry {
  HistoryEntry({
    required this.bytes,
    required this.predictions,
    required this.source,
    required this.time,
  });

  final Uint8List bytes;
  final List<Prediction> predictions; // already sorted, highest first
  final String source; // 'Camera', 'Gallery' or 'Download'
  final DateTime time;

  Prediction get top => predictions.first;
}

/// Icon for each image source.
IconData iconForSource(String source) {
  if (source == 'Camera') return Icons.photo_camera_outlined;
  if (source == 'Gallery') return Icons.photo_library_outlined;
  return Icons.cloud_download_outlined;
}
