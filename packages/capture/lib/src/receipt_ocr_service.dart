import 'dart:io';
import 'dart:math' as math;

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'models.dart';

class ReceiptOcrService {
  ReceiptOcrService({TextRecognizer? recognizer})
      : _recognizer =
            recognizer ?? TextRecognizer(script: TextRecognitionScript.latin);

  final TextRecognizer _recognizer;
  final _tempFiles = <File>[];

  Future<List<ReceiptItemSuggestion>> parseReceipt(XFile file) async {
    final suggestions = <ReceiptItemSuggestion>[];
    final preparedPath = await _prepareImage(file);
    final input = InputImage.fromFilePath(preparedPath);
    final result = await _recognizer.processImage(input);

    final lines = <String>[];
    for (final block in result.blocks) {
      for (final line in block.lines) {
        final text = line.text.trim();
        if (text.isNotEmpty) {
          lines.add(text);
        }
      }
    }

    final parsed = _parseLines(lines);
    suggestions.addAll(parsed);
    return suggestions;
  }

  Iterable<ReceiptItemSuggestion> _parseLines(List<String> lines) sync* {
    final itemPattern = RegExp(
      r'^(?<name>[A-Za-zÀ-ž0-9\s\-\/]+?)\s+(?<qty>\d+(?:[.,]\d+)?)?\s*(?<unit>kg|g|l|ml|pcs?|pack|pkt|btl|ct)?\s*(?<price>\d+[.,]\d{2})?$',
      caseSensitive: false,
    );
    final quantityFirstPattern = RegExp(
      r'^(?<qty>\d+(?:[.,]\d+)?)\s*(?<unit>kg|g|l|ml|pcs?|pack|pkt|btl|ct)?\s+(?<name>[A-Za-zÀ-ž0-9\s\-\/]+?)(?:\s+(?<price>\d+[.,]\d{2}))?$',
      caseSensitive: false,
    );

    for (final raw in lines) {
      final normalized = raw.replaceAll('*', '').trim();
      if (normalized.isEmpty) {
        continue;
      }
      final match = itemPattern.firstMatch(normalized) ??
          quantityFirstPattern.firstMatch(normalized);
      if (match == null) {
        continue;
      }
      final name = match.namedGroup('name')?.trim();
      if (name == null || name.length < 2) {
        continue;
      }
      final quantity = _parseDouble(match.namedGroup('qty'));
      final unit = match.namedGroup('unit')?.toLowerCase();
      final price = _parseDouble(match.namedGroup('price'));
      final confidence = price != null ? 0.9 : 0.7;
      yield ReceiptItemSuggestion(
        label: name,
        quantity: quantity,
        unit: unit,
        price: price,
        confidence: confidence,
      );
    }
  }

  double? _parseDouble(String? value) {
    if (value == null) {
      return null;
    }
    final normalized = value.replaceAll(',', '.');
    return double.tryParse(normalized);
  }

  Future<void> dispose() async {
    await _recognizer.close();
    for (final file in _tempFiles) {
      try {
        if (file.existsSync()) {
          await file.delete();
        }
      } catch (_) {
        // Ignore deletion errors
      }
    }
    _tempFiles.clear();
  }

  Future<String> _prepareImage(XFile xfile) async {
    try {
      final bytes = await xfile.readAsBytes();
      final decoded = img.decodeImage(bytes);
      if (decoded == null) {
        return xfile.path;
      }

      var processed = img.bakeOrientation(decoded);
      const maxDimension = 2000;
      final longestSide = math.max(processed.width, processed.height);
      if (longestSide > maxDimension) {
        final scale = maxDimension / longestSide;
        processed = img.copyResize(
          processed,
          width: (processed.width * scale).round(),
          height: (processed.height * scale).round(),
          interpolation: img.Interpolation.average,
        );
      }

      final tempDir = await getTemporaryDirectory();
      final tempPath = p.join(
        tempDir.path,
        'receipt_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      final tempFile = File(tempPath);
      await tempFile.writeAsBytes(img.encodeJpg(processed, quality: 90));
      _tempFiles.add(tempFile);
      return tempPath;
    } catch (_) {
      return xfile.path;
    }
  }
}
