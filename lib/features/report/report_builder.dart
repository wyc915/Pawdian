import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../core/database/app_database.dart';
import '../../core/domain/enums.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/l10n_labels.dart';
import '../../shared/units.dart';

const _brand = PdfColor.fromInt(0xFF2E7D6B);
const _muted = PdfColor.fromInt(0xFF5F6B68);

/// Everything the report needs, already filtered to the pet.
class ReportData {
  const ReportData({
    required this.pet,
    required this.records,
    required this.weights,
    required this.from,
    required this.to,
  });

  final Pet pet;
  final List<CareRecord> records;
  final List<WeightEntry> weights;
  final DateTime from;
  final DateTime to;
}

/// Records that belong to [section] within the report period.
List<CareRecord> recordsForSection(
  List<CareRecord> records,
  RecordCategory section,
) => records.where((r) {
  final c = r.type.category;
  if (section == RecordCategory.symptom) {
    // Daily entries matter to a vet only when something was noted.
    return c == RecordCategory.symptom ||
        (c == RecordCategory.daily &&
            (r.severity != null || r.notes.isNotEmpty));
  }
  return c == section;
}).toList();

/// Builds the vet report PDF. [fontData] must be a TrueType font covering
/// Chinese (the bundled Noto Sans TC).
Future<Uint8List> buildVetReport({
  required ReportData data,
  required AppLocalizations l,
  required WeightUnit unit,
  required ByteData fontData,
  DateTime? now,
}) async {
  final generated = now ?? DateTime.now();
  final font = pw.Font.ttf(fontData);
  final dateFmt = DateFormat.yMMMd(l.localeName);
  final dateTimeFmt = DateFormat.yMMMd(l.localeName).add_Hm();
  final pet = data.pet;

  bool inRange(DateTime d) => !d.isBefore(data.from) && !d.isAfter(data.to);
  final records =
      data.records.where((r) => inRange(r.occurredAt)).toList()
        ..sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
  final weights = data.weights.where((w) => inRange(w.measuredAt)).toList()
    ..sort((a, b) => a.measuredAt.compareTo(b.measuredAt));

  final doc = pw.Document(
    title: '${l.reportTitle} - ${pet.name}',
    author: 'Pawdian',
    theme: pw.ThemeData.withFont(base: font, bold: font),
  );

  pw.Widget heading(String text) => pw.Padding(
    padding: const pw.EdgeInsets.only(top: 14, bottom: 6),
    child: pw.Text(
      text,
      style: pw.TextStyle(fontSize: 13, color: _brand),
    ),
  );

  pw.Widget none() => pw.Text(
    l.reportNone,
    style: const pw.TextStyle(fontSize: 10, color: _muted),
  );

  pw.Widget table(List<List<String>> rows) => pw.TableHelper.fromTextArray(
    headers: [l.reportColDate, l.reportColItem, l.reportColDetails],
    data: rows,
    headerStyle: const pw.TextStyle(fontSize: 10, color: PdfColors.white),
    headerDecoration: const pw.BoxDecoration(color: _brand),
    cellStyle: const pw.TextStyle(fontSize: 9.5),
    columnWidths: {
      0: const pw.FixedColumnWidth(95),
      1: const pw.FixedColumnWidth(95),
      2: const pw.FlexColumnWidth(),
    },
    cellAlignment: pw.Alignment.topLeft,
  );

  String details(CareRecord r) => [
    if (r.severity != null) severityLabel(l, r.severity),
    if (r.vetClinic.isNotEmpty) r.vetClinic,
    if (r.diagnosis.isNotEmpty) r.diagnosis,
    if (r.cost != null) l.costLabel(NumberFormat.decimalPattern(l.localeName).format(r.cost)),
    if (r.notes.isNotEmpty) r.notes,
  ].join('\n');

  pw.Widget section(String title, RecordCategory category) {
    final rows = recordsForSection(records, category);
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        heading(title),
        if (rows.isEmpty)
          none()
        else
          table([
            for (final r in rows)
              [
                dateTimeFmt.format(r.occurredAt),
                recordDisplayTitle(l, r),
                details(r),
              ],
          ]),
      ],
    );
  }

  final profile = <(String, String)>[
    (l.fieldSpecies, speciesLabel(l, pet.species)),
    if (pet.breed.isNotEmpty) (l.fieldBreed, pet.breed),
    (l.fieldSex, sexLabel(l, pet.sex)),
    if (pet.neutered != null) (l.fieldNeutered, pet.neutered! ? '✓' : '—'),
    if (pet.birthDate != null)
      (
        l.fieldBirthDate,
        '${dateFmt.format(pet.birthDate!)}  (${ageLabel(l, pet, generated)})',
      ),
    if (pet.microchipId.isNotEmpty) (l.fieldMicrochip, pet.microchipId),
    if (weights.isNotEmpty)
      (l.fieldWeight, formatWeight(weights.last.grams, unit)),
  ];

  pw.Widget weightChart() {
    final first = weights.first.measuredAt;
    double x(DateTime d) => d.difference(first).inHours / 24;
    final ys = weights.map((w) => unit.fromGrams(w.grams)).toList();
    final minY = ys.reduce((a, b) => a < b ? a : b);
    final maxY = ys.reduce((a, b) => a > b ? a : b);
    final pad = ((maxY - minY) * 0.2).clamp(0.2, double.infinity);
    final lo = (minY - pad).clamp(0, double.infinity).toDouble();
    final hi = maxY + pad;
    final span = x(weights.last.measuredAt);
    final xTicks = span <= 0
        ? <double>[0, 1]
        : [for (var i = 0; i <= 4; i++) span * i / 4];
    return pw.SizedBox(
      height: 150,
      child: pw.Chart(
        grid: pw.CartesianGrid(
          xAxis: pw.FixedAxis(
            xTicks,
            format: (v) => DateFormat.Md(
              l.localeName,
            ).format(first.add(Duration(hours: (v * 24).round()))),
            textStyle: const pw.TextStyle(fontSize: 8, color: _muted),
          ),
          yAxis: pw.FixedAxis(
            [for (var i = 0; i <= 4; i++) lo + (hi - lo) * i / 4],
            format: (v) => v.toStringAsFixed(1),
            textStyle: const pw.TextStyle(fontSize: 8, color: _muted),
            divisions: true,
          ),
        ),
        datasets: [
          pw.LineDataSet(
            data: [
              for (final w in weights)
                pw.PointChartValue(x(w.measuredAt), unit.fromGrams(w.grams)),
            ],
            color: _brand,
            pointSize: 2.5,
          ),
        ],
      ),
    );
  }

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(36),
      header: (context) => pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            '${l.reportTitle} · ${pet.name}',
            style: const pw.TextStyle(fontSize: 18),
          ),
          pw.Text(
            'Pawdian',
            style: const pw.TextStyle(fontSize: 10, color: _brand),
          ),
        ],
      ),
      footer: (context) => pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Expanded(
            child: pw.Text(
              l.reportDisclaimer,
              style: const pw.TextStyle(fontSize: 8, color: _muted),
            ),
          ),
          pw.Text(
            '${context.pageNumber} / ${context.pagesCount}',
            style: const pw.TextStyle(fontSize: 8, color: _muted),
          ),
        ],
      ),
      build: (context) => [
        pw.SizedBox(height: 4),
        pw.Text(
          '${l.reportGenerated(dateFmt.format(generated))}    '
          '${l.reportPeriod(dateFmt.format(data.from), dateFmt.format(data.to))}',
          style: const pw.TextStyle(fontSize: 10, color: _muted),
        ),
        heading(l.reportProfile),
        pw.Table(
          columnWidths: {
            0: const pw.FixedColumnWidth(110),
            1: const pw.FlexColumnWidth(),
          },
          children: [
            for (final (k, v) in profile)
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 2),
                    child: pw.Text(
                      k,
                      style: const pw.TextStyle(fontSize: 10, color: _muted),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 2),
                    child: pw.Text(v, style: const pw.TextStyle(fontSize: 10)),
                  ),
                ],
              ),
          ],
        ),
        heading(l.reportWeights),
        if (weights.isEmpty)
          none()
        else ...[
          if (weights.length >= 2) weightChart(),
          pw.SizedBox(height: 6),
          pw.Wrap(
            spacing: 12,
            runSpacing: 2,
            children: [
              for (final w in weights.reversed.take(12))
                pw.Text(
                  '${dateFmt.format(w.measuredAt)}  ${formatWeight(w.grams, unit)}',
                  style: const pw.TextStyle(fontSize: 9),
                ),
            ],
          ),
        ],
        section(l.reportSymptoms, RecordCategory.symptom),
        section(l.reportMedication, RecordCategory.medication),
        section(l.reportVetVisits, RecordCategory.vet),
        section(l.reportCare, RecordCategory.care),
      ],
    ),
  );
  return doc.save();
}
