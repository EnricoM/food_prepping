import '../services/measurement_preferences.dart';

class IngredientConverter {
  IngredientConverter(this.targetSystem);

  final MeasurementSystem targetSystem;

  String convert(String input) {
    final rules = targetSystem == MeasurementSystem.metric
        ? _imperialToMetricRules
        : _metricToImperialRules;
    for (final rule in rules) {
      final match = rule.pattern.firstMatch(input);
      if (match == null) continue;
      final quantityStr = match.group(1);
      if (quantityStr == null) continue;
      final quantity = _parseQuantity(quantityStr);
      if (quantity == null) continue;
      final replacement = rule.buildReplacement(quantity);
      if (replacement == null || replacement.isEmpty) continue;
      return input.replaceRange(match.start, match.end, replacement);
    }
    return input;
  }
}

class _ConversionRule {
  _ConversionRule({
    required String pattern,
    required this.buildReplacement,
  }) : pattern = RegExp(pattern, caseSensitive: false);

  final RegExp pattern;
  final String? Function(double quantity) buildReplacement;
}

double? _parseQuantity(String value) {
  var text = value.trim();
  if (text.isEmpty) return null;
  text = text.replaceAll('-', ' ');
  double total = 0;
  for (final part in text.split(RegExp(r'\s+'))) {
    if (part.isEmpty) continue;
    final fractionMatch = RegExp(r'^(\d+)\/(\d+)$').firstMatch(part);
    if (fractionMatch != null) {
      final numerator = double.tryParse(fractionMatch.group(1)!);
      final denominator = double.tryParse(fractionMatch.group(2)!);
      if (numerator != null && denominator != null && denominator != 0) {
        total += numerator / denominator;
        continue;
      }
    }
    final number = double.tryParse(part);
    if (number != null) {
      total += number;
    }
  }
  return total == 0 ? null : total;
}

String _formatNumber(double value) {
  final rounded = (value * 10).round() / 10.0;
  if ((rounded - rounded.round()).abs() < 0.05) {
    return rounded.round().toString();
  }
  return rounded.toStringAsFixed(1).replaceAll(RegExp(r'\.?0+$'), '');
}

String _pluralize(String unit, double quantity) {
  final absValue = quantity.abs();
  if (absValue >= 1.1 || absValue <= 0.9) {
    if (unit.endsWith('foot')) return unit.replaceFirst('foot', 'feet');
    if (unit.endsWith('ch')) return '${unit}es';
    if (unit.endsWith('s')) return unit;
    return '${unit}s';
  }
  return unit;
}

String _formatWithUnit(double quantity, String unit) {
  final formatted = _formatNumber(quantity);
  final label = _pluralize(unit, quantity);
  return '$formatted $label';
}

final _imperialToMetricRules = <_ConversionRule>[
  _ConversionRule(
    pattern:
        r'((?:\d+\s+)?\d+(?:/\d+)?|\d+(?:\.\d+)?)\s*(cups?|c)\b',
    buildReplacement: (qty) => _formatWithUnit(qty * 240, 'ml'),
  ),
  _ConversionRule(
    pattern: r'((?:\d+\s+)?\d+(?:/\d+)?|\d+(?:\.\d+)?)\s*(tablespoons?|tbsp)\b',
    buildReplacement: (qty) => _formatWithUnit(qty * 15, 'ml'),
  ),
  _ConversionRule(
    pattern: r'((?:\d+\s+)?\d+(?:/\d+)?|\d+(?:\.\d+)?)\s*(teaspoons?|tsp)\b',
    buildReplacement: (qty) => _formatWithUnit(qty * 5, 'ml'),
  ),
  _ConversionRule(
    pattern:
        r'((?:\d+\s+)?\d+(?:/\d+)?|\d+(?:\.\d+)?)\s*(ounces?|oz)\b',
    buildReplacement: (qty) => _formatWithUnit(qty * 28.35, 'g'),
  ),
  _ConversionRule(
    pattern: r'((?:\d+\s+)?\d+(?:/\d+)?|\d+(?:\.\d+)?)\s*(pounds?|lbs?)\b',
    buildReplacement: (qty) => _formatWithUnit(qty * 453.59, 'g'),
  ),
  _ConversionRule(
    pattern: r'((?:\d+\s+)?\d+(?:/\d+)?|\d+(?:\.\d+)?)\s*(pints?)\b',
    buildReplacement: (qty) => _formatWithUnit(qty * 473.18, 'ml'),
  ),
  _ConversionRule(
    pattern: r'((?:\d+\s+)?\d+(?:/\d+)?|\d+(?:\.\d+)?)\s*(quarts?)\b',
    buildReplacement: (qty) => _formatWithUnit(qty * 946.35, 'ml'),
  ),
];

final _metricToImperialRules = <_ConversionRule>[
  _ConversionRule(
    pattern:
        r'((?:\d+\s+)?\d+(?:/\d+)?|\d+(?:\.\d+)?)\s*(millilit(er|re)s?|ml)\b',
    buildReplacement: (qty) {
      if (qty >= 240) {
        final cups = qty / 240;
        return _formatWithUnit(cups, 'cup');
      }
      if (qty >= 15) {
        final tbsp = qty / 15;
        return _formatWithUnit(tbsp, 'tbsp');
      }
      final tsp = qty / 5;
      return _formatWithUnit(tsp, 'tsp');
    },
  ),
  _ConversionRule(
    pattern: r'((?:\d+\s+)?\d+(?:/\d+)?|\d+(?:\.\d+)?)\s*(lit(er|re)s?|l)\b',
    buildReplacement: (qty) {
      final cups = qty * 4.22675;
      return _formatWithUnit(cups, 'cup');
    },
  ),
  _ConversionRule(
    pattern: r'((?:\d+\s+)?\d+(?:/\d+)?|\d+(?:\.\d+)?)\s*(grams?|g)\b',
    buildReplacement: (qty) {
      if (qty >= 453.59) {
        final pounds = qty / 453.59;
        return _formatWithUnit(pounds, 'lb');
      }
      final ounces = qty / 28.35;
      return _formatWithUnit(ounces, 'oz');
    },
  ),
  _ConversionRule(
    pattern: r'((?:\d+\s+)?\d+(?:/\d+)?|\d+(?:\.\d+)?)\s*(kilograms?|kg)\b',
    buildReplacement: (qty) {
      final pounds = qty * 2.20462;
      return _formatWithUnit(pounds, 'lb');
    },
  ),
];

