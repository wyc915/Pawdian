import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';

import '../../core/settings/app_settings.dart';
import '../../l10n/app_localizations.dart';
import '../pets/data/pet_repository.dart';
import '../records/data/record_repository.dart';
import '../weight/data/weight_repository.dart';
import 'report_builder.dart';

const kReportFontAsset = 'assets/fonts/NotoSansTC-Subset.ttf';

final reportFontProvider = FutureProvider<ByteData>(
  (ref) => rootBundle.load(kReportFontAsset),
);

/// Preview, print or share the vet report for one pet (Pro).
class ReportScreen extends ConsumerStatefulWidget {
  const ReportScreen({super.key, required this.petId});

  final String petId;

  @override
  ConsumerState<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends ConsumerState<ReportScreen> {
  int _days = 90;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final pet = ref.watch(petProvider(widget.petId)).value;
    final records = ref.watch(allRecordsProvider(widget.petId)).value;
    final weights = ref.watch(petWeightsProvider(widget.petId)).value;
    final font = ref.watch(reportFontProvider).value;
    final unit = ref.watch(effectiveWeightUnitProvider);
    final ready =
        pet != null && records != null && weights != null && font != null;

    return Scaffold(
      appBar: AppBar(title: Text(l.reportTitle)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: SegmentedButton<int>(
              segments: [
                for (final d in const [30, 90, 365])
                  ButtonSegment(value: d, label: Text(l.reportDays(d))),
              ],
              selected: {_days},
              onSelectionChanged: (s) => setState(() => _days = s.first),
            ),
          ),
          Expanded(
            child: !ready
                ? const Center(child: CircularProgressIndicator())
                : PdfPreview(
                    key: ValueKey(_days),
                    canChangePageFormat: false,
                    canChangeOrientation: false,
                    canDebug: false,
                    pdfFileName: 'Pawdian-${pet.name}.pdf',
                    build: (format) {
                      final now = DateTime.now();
                      return buildVetReport(
                        data: ReportData(
                          pet: pet,
                          records: records,
                          weights: weights,
                          from: DateTime(now.year, now.month, now.day - _days),
                          to: now,
                        ),
                        l: l,
                        unit: unit,
                        fontData: font,
                        now: now,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
