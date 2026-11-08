import '../core/domain/enums.dart';

String weightUnitSymbol(WeightUnit unit) => unit.name;

/// "4.25 kg" / "9.4 lb": at most two decimals, trailing zeros removed.
String formatWeight(int grams, WeightUnit unit) =>
    '${formatWeightNumber(grams, unit)} ${weightUnitSymbol(unit)}';

String formatWeightNumber(int grams, WeightUnit unit) {
  var s = unit.fromGrams(grams).toStringAsFixed(2);
  if (s.contains('.')) {
    s = s.replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
  }
  return s;
}

/// Parses user input such as "4.2" or "4,2" into grams. Returns null for
/// empty, non-numeric, zero/negative or absurd (> 200 kg) values.
int? parseWeightToGrams(String input, WeightUnit unit) {
  final value = double.tryParse(input.trim().replaceAll(',', '.'));
  if (value == null || value <= 0) return null;
  final grams = unit.toGrams(value);
  if (grams <= 0 || grams > 200000) return null;
  return grams;
}
