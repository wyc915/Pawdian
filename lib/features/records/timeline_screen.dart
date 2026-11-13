import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/paw_card.dart';

import 'package:go_router/go_router.dart';

import '../../core/domain/enums.dart';
import '../../core/router/app_router.dart';
import '../../core/settings/app_settings.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/formatting.dart';
import '../../shared/l10n_labels.dart';
import '../../shared/units.dart';
import '../weight/data/weight_repository.dart';
import '../weight/weight_screen.dart';
import 'data/record_repository.dart';
import 'domain/timeline.dart';
import 'widgets/record_tile.dart';

class TimelineScreen extends ConsumerStatefulWidget {
  const TimelineScreen({super.key, required this.petId});

  final String petId;

  @override
  ConsumerState<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends ConsumerState<TimelineScreen> {
  RecordCategory? _category;
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final unit = ref.watch(effectiveWeightUnitProvider);
    final records =
        ref.watch(allRecordsProvider(widget.petId)).value ?? const [];
    final weights =
        ref.watch(petWeightsProvider(widget.petId)).value ?? const [];
    final items = buildTimeline(
      records: records,
      weights: weights,
      l: l,
      category: _category,
      query: _search.text,
    );

    final p = context.paw;
    final rows = <Widget>[];
    var dayTiles = <Widget>[];
    DateTime? lastDay;
    void closeDay() {
      if (dayTiles.isEmpty) return;
      rows.add(
        PawCard(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(children: dayTiles),
        ),
      );
      dayTiles = <Widget>[];
    }

    for (final item in items) {
      final day = DateTime(item.at.year, item.at.month, item.at.day);
      if (day != lastDay) {
        closeDay();
        rows.add(SectionTitle(formatDate(context, day)));
        lastDay = day;
      }
      dayTiles.add(switch (item) {
        RecordItem(:final record) => RecordTile(
          record: record,
          showDate: false,
          onTap: () =>
              context.go(AppRoutes.editRecord(widget.petId, record.id)),
        ),
        WeightItem(:final entry) => ListTile(
          leading: ToneIcon(
            icon: Icons.monitor_weight_outlined,
            tone: p.sky,
            size: 40,
          ),
          title: Text(l.weightEntryTitle(formatWeight(entry.grams, unit))),
          subtitle: Text(
            [
              formatTime(context, entry.measuredAt),
              if (entry.notes.isNotEmpty) entry.notes,
            ].join(' · '),
          ),
          onTap: () => showWeightDialog(
            context,
            ref,
            petId: widget.petId,
            existing: entry,
          ),
        ),
      });
    }

    closeDay();

    return Scaffold(
      appBar: AppBar(title: Text(l.timelineTitle)),
      floatingActionButton: FloatingActionButton(
        tooltip: l.addRecord,
        onPressed: () => context.go(AppRoutes.newRecord(widget.petId)),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              key: const Key('timeline.search'),
              controller: _search,
              decoration: InputDecoration(
                hintText: l.searchHint,
                prefixIcon: const Icon(Icons.search),
                isDense: true,
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          SizedBox(
            height: 56,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: [
                for (final c in <RecordCategory?>[
                  null,
                  ...RecordCategory.values,
                ])
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      key: Key('timeline.filter.${c?.name ?? 'all'}'),
                      label: Text(categoryLabel(l, c)),
                      selected: _category == c,
                      onSelected: (_) => setState(() => _category = c),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: items.isEmpty
                ? EmptyState(
                    icon: Icons.timeline_outlined,
                    title: l.timelineEmpty,
                    body: '',
                  )
                : ListView(
                    padding: const EdgeInsets.only(bottom: 96),
                    children: rows,
                  ),
          ),
        ],
      ),
    );
  }
}
