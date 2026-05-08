/// Reference ranges for common blood test biomarkers.
/// Values are in standard units.
class ReferenceRange {
  final String name;
  final String unit;
  final double min;
  final double max;
  final List<String> aliases;

  const ReferenceRange({
    required this.name,
    required this.unit,
    required this.min,
    required this.max,
    this.aliases = const [],
  });

  bool isAbnormal(double value) => value < min || value > max;

  String get rangeString => '$min - $max $unit';
}

class ReferenceRanges {
  ReferenceRanges._();

  static const List<ReferenceRange> ranges = [
    ReferenceRange(
      name: 'Hemoglobin',
      unit: 'g/dL',
      min: 12.0,
      max: 17.5,
      aliases: ['hb', 'hgb', 'haemoglobin'],
    ),
    ReferenceRange(
      name: 'WBC',
      unit: '×10³/µL',
      min: 4.0,
      max: 11.0,
      aliases: ['white blood cell', 'wbc count', 'leucocytes', 'leukocytes'],
    ),
    ReferenceRange(
      name: 'RBC',
      unit: '×10⁶/µL',
      min: 4.2,
      max: 6.1,
      aliases: ['red blood cell', 'rbc count', 'erythrocytes'],
    ),
    ReferenceRange(
      name: 'Platelets',
      unit: '×10³/µL',
      min: 150.0,
      max: 400.0,
      aliases: ['platelet count', 'plt', 'thrombocytes'],
    ),
    ReferenceRange(
      name: 'Glucose',
      unit: 'mg/dL',
      min: 70.0,
      max: 100.0,
      aliases: ['blood sugar', 'fasting glucose', 'fbs', 'blood glucose'],
    ),
    ReferenceRange(
      name: 'Cholesterol',
      unit: 'mg/dL',
      min: 0.0,
      max: 200.0,
      aliases: ['total cholesterol', 'tc'],
    ),
    ReferenceRange(
      name: 'HDL',
      unit: 'mg/dL',
      min: 40.0,
      max: 60.0,
      aliases: ['hdl cholesterol', 'good cholesterol'],
    ),
    ReferenceRange(
      name: 'LDL',
      unit: 'mg/dL',
      min: 0.0,
      max: 100.0,
      aliases: ['ldl cholesterol', 'bad cholesterol'],
    ),
    ReferenceRange(
      name: 'Triglycerides',
      unit: 'mg/dL',
      min: 0.0,
      max: 150.0,
      aliases: ['tg', 'trigs'],
    ),
    ReferenceRange(
      name: 'Creatinine',
      unit: 'mg/dL',
      min: 0.6,
      max: 1.2,
      aliases: ['serum creatinine', 'cr'],
    ),
    ReferenceRange(
      name: 'ALT',
      unit: 'U/L',
      min: 7.0,
      max: 56.0,
      aliases: ['sgpt', 'alanine aminotransferase'],
    ),
    ReferenceRange(
      name: 'AST',
      unit: 'U/L',
      min: 10.0,
      max: 40.0,
      aliases: ['sgot', 'aspartate aminotransferase'],
    ),
    ReferenceRange(
      name: 'TSH',
      unit: 'mIU/L',
      min: 0.4,
      max: 4.0,
      aliases: ['thyroid stimulating hormone', 'thyroid'],
    ),
    ReferenceRange(
      name: 'HbA1c',
      unit: '%',
      min: 4.0,
      max: 5.6,
      aliases: ['glycated hemoglobin', 'a1c', 'hba1c'],
    ),
    ReferenceRange(
      name: 'Vitamin D',
      unit: 'ng/mL',
      min: 30.0,
      max: 100.0,
      aliases: ['vit d', '25-hydroxyvitamin d', 'vitamin d3'],
    ),
    ReferenceRange(
      name: 'Iron',
      unit: 'µg/dL',
      min: 60.0,
      max: 170.0,
      aliases: ['serum iron', 'fe'],
    ),
  ];

  /// Tries to find a matching reference range for the given test name.
  static ReferenceRange? findRange(String testName) {
    final lower = testName.toLowerCase().trim();
    for (final range in ranges) {
      if (range.name.toLowerCase() == lower) return range;
      for (final alias in range.aliases) {
        if (alias == lower) return range;
      }
    }
    return null;
  }
}
