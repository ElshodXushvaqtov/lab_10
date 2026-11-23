import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'classifier.dart';

class HistoryEntry {
  HistoryEntry({
    required this.bytes,
    required this.predictions,
    required this.source,
    required this.time,
  });

  final Uint8List bytes;
  final List<Prediction> predictions;
  final String source;
  final DateTime time;

  Prediction get top => predictions.first;
}

IconData iconForSource(String source) {
  if (source == 'Camera') return Icons.photo_camera_outlined;
  if (source == 'Gallery') return Icons.photo_library_outlined;
  return Icons.cloud_download_outlined;
}
