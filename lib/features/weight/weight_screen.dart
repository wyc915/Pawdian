import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/database/app_database.dart';
import '../../core/domain/enums.dart';
import '../../core/settings/app_settings.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/formatting.dart';
import '../../shared/units.dart';
import '../records/domain/timeline.dart';
import 'data/weight_repository.dart';

enum WeightRange {
  month(30),
  threeMonths(90),
  year(365),
  all(null);

  const WeightRange(this.days);

  final int? days;

  /// Free users only see the last three months.
  bool get needsPro => this == year || this == all;
}

String _rangeLabel(AppLocalizations l, WeightRange r) => switch (r) {
  WeightRange.month => l.rangeMonth,
  WeightRange.threeMonths => l.range3Months,
  WeightRange.year => l.rangeYear,
  WeightRange.all => l.rangeAll,
};

class WeightScreen extends ConsumerStatefulWidget {
  const WeightScreen({super.key, required this.petId});

  final String petId;

  @override
  ConsumerState<WeightScreen> createState() => _WeightScreenState();
}

class _WeightScreenState extends ConsumerState<WeightScreen> {
  WeightRange _range = WeightRange.threeMonths;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final unit = ref.watch(effectiveWeightUnitProvider);
    final all = ref.watch(petWeightsProvider(widget.petId)).value ?? const [];
    final shown = weightsWithin(all, DateTime.now(), _range.days);
    return Scaffold(
      appBar: AppBar(title: Text(l.weightTitle)),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('weight.add'),
        onPressed: () => showWeightDialog(context, ref, petId: widget.petId),
        icon: const Icon(Icons.add),
        label: Text(l.addWeight),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 96),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SegmentedButton<WeightRange>(
              segments: [
                for (final r in WeightRange.values)
                  ButtonSegment(value: r, label: Text(_rangeLabel(l, r))),
              ],
              selected: {_range},
              onSelectionChanged: (s) {
                final r = s.first;
                if (r.needsPro && !ref.read(isProProvider)) {
                  showProDialog(context, l.proWeightHistory);
                  return;
                }
                setState(() => _range = r);
              },
            ),
          ),
          SizedBox(
            height: 220,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 24, 8),
              child: shown.length < 2
                  ? Center(
                      child: Text(
                        all.isEmpty
                            ? l.weightEmpty
                            : formatWeight(all.last.grams, unit),
                      ),
                    )
                  : WeightChart(entries: shown, unit: unit),
            ),
          ),
          const Divider(),
          for (final w in all.reversed)
            ListTile(
              leading: const Icon(Icons.monitor_weight_outlined),
              title: Text(formatWeight(w.grams, unit)),
              subtitle: Text(
                [
                  formatDate(context, w.measuredAt),
                  if (w.notes.isNotEmpty) w.notes,
                ].join(' · '),
              ),
              onTap: () => showWeightDialog(
                context,
                ref,
                petId: widget.petId,
                existing: w,
              ),
            ),
        ],
      ),
    );
  }
}

class WeightChart extends StatelessWidget {
  const WeightChart({super.key, required this.entries, required this.unit});

  /// Oldest first, at least two entries.
  final List<WeightEntry> entries;
  final WeightUnit unit;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final localeName = AppLocalizations.of(context).localeName;
    double x(DateTime d) => d.millisecondsSinceEpoch / Duration.millisecondsPerDay;
    final spots = [
      for (final e in entries) FlSpot(x(e.measuredAt), unit.fromGrams(e.grams)),
    ];
    final ys = spots.map((s) => s.y);
    final minY = ys.reduce((a, b) => a < b ? a : b);
    final maxY = ys.reduce((a, b) => a > b ? a : b);
    final pad = ((maxY - minY) * 0.2).clamp(0.2, double.infinity);
    final spanDays = spots.last.x - spots.first.x;
    final xInterval = spanDays <= 0 ? 1.0 : (spanDays / 4).ceilToDouble();
    final dateFormat = DateFormat.Md(localeName);
    return LineChart(
      LineChartData(
        minY: (minY - pad).clamp(0, double.infinity),
        maxY: maxY + pad,
        gridData: const FlGridData(drawVerticalLine: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(),
          rightTitles: const AxisTitles(),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                // fl_chart always adds the axis min/max, which collide with
                // the regular grid labels; show grid labels only.
                if (value == meta.min || value == meta.max) {
                  return const SizedBox.shrink();
                }
                return SideTitleWidget(
                  meta: meta,
                  child: Text(
                    value.toStringAsFixed(1),
                    style: const TextStyle(fontSize: 11),
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: xInterval,
              getTitlesWidget: (value, meta) {
                // Keep the first and last dates; drop grid labels that would
                // crowd them.
                final isEdge = value == meta.min || value == meta.max;
                if (!isEdge &&
                    (value - meta.min < xInterval * 0.6 ||
                        meta.max - value < xInterval * 0.6)) {
                  return const SizedBox.shrink();
                }
                return SideTitleWidget(
                  meta: meta,
                  child: Text(
                    dateFormat.format(
                      DateTime.fromMillisecondsSinceEpoch(
                        (value * Duration.millisecondsPerDay).round(),
                      ),
                    ),
                    style: const TextStyle(fontSize: 11),
                  ),
                );
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            color: scheme.primary,
            barWidth: 3,
            dotData: const FlDotData(),
            belowBarData: BarAreaData(
              show: true,
              color: scheme.primary.withValues(alpha: 0.12),
            ),
          ),
        ],
      ),
    );
  }
}

/// Add or edit a weight entry.
Future<void> showWeightDialog(
  BuildContext context,
  WidgetRef ref, {
  required String petId,
  WeightEntry? existing,
}) => showDialog<void>(
  context: context,
  builder: (context) => _WeightDialog(petId: petId, existing: existing),
);

class _WeightDialog extends ConsumerStatefulWidget {
  const _WeightDialog({required this.petId, this.existing});

  final String petId;
  final WeightEntry? existing;

  @override
  ConsumerState<_WeightDialog> createState() => _WeightDialogState();
}

class _WeightDialogState extends ConsumerState<_WeightDialog> {
  late final WeightUnit _unit = ref.read(effectiveWeightUnitProvider);
  late final _value = TextEditingController(
    text: widget.existing == null
        ? ''
        : formatWeightNumber(widget.existing!.grams, _unit),
  );
  late final _notes = TextEditingController(text: widget.existing?.notes ?? '');
  late DateTime _date = widget.existing?.measuredAt ?? DateTime.now();
  String? _error;

  @override
  void dispose() {
    _value.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l = AppLocalizations.of(context);
    final grams = parseWeightToGrams(_value.text, _unit);
    if (grams == null) {
      setState(() => _error = l.weightInvalid);
      return;
    }
    final repo = ref.read(weightRepositoryProvider);
    if (widget.existing == null) {
      await repo.add(
        widget.petId,
        measuredAt: _date,
        grams: grams,
        notes: _notes.text,
      );
    } else {
      await repo.update(
        widget.existing!.id,
        measuredAt: _date,
        grams: grams,
        notes: _notes.text,
      );
    }
    if (mounted) Navigator.pop(context);
  }

  Future<void> _delete() async {
    final l = AppLocalizations.of(context);
    if (await confirmDialog(
      context,
      message: l.deleteWeightConfirm,
      confirmLabel: l.actionDelete,
    )) {
      await ref.read(weightRepositoryProvider).softDelete(widget.existing!.id);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l.addWeight),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            key: const Key('weight.value'),
            controller: _value,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: l.fieldWeight,
              suffixText: weightUnitSymbol(_unit),
              errorText: _error,
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l.fieldDate),
            subtitle: Text(formatDateTime(context, _date)),
            onTap: () async {
              final picked = await pickDateTime(context, _date);
              if (picked != null) setState(() => _date = picked);
            },
          ),
          TextField(
            controller: _notes,
            decoration: InputDecoration(labelText: l.fieldNotes),
          ),
        ],
      ),
      actions: [
        if (widget.existing != null)
          TextButton(onPressed: _delete, child: Text(l.actionDelete)),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l.actionCancel),
        ),
        FilledButton(
          key: const Key('weight.save'),
          onPressed: _save,
          child: Text(l.actionSave),
        ),
      ],
    );
  }
}
