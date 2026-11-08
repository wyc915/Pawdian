import '../../../core/domain/enums.dart';

/// Minutes since local midnight, e.g. 08:30 -> 510.
typedef MinuteOfDay = int;

String formatMinuteOfDay(MinuteOfDay m) =>
    '${(m ~/ 60).toString().padLeft(2, '0')}:${(m % 60).toString().padLeft(2, '0')}';

/// Parses "08:00,20:00" into sorted, de-duplicated minutes. Invalid parts are
/// skipped; an empty result falls back to [fallback].
List<MinuteOfDay> parseTimesOfDay(String raw, {MinuteOfDay fallback = 540}) {
  final result = <MinuteOfDay>{};
  for (final part in raw.split(',')) {
    final pieces = part.trim().split(':');
    if (pieces.length != 2) continue;
    final h = int.tryParse(pieces[0]);
    final m = int.tryParse(pieces[1]);
    if (h == null || m == null || h < 0 || h > 23 || m < 0 || m > 59) continue;
    result.add(h * 60 + m);
  }
  if (result.isEmpty) return [fallback];
  return result.toList()..sort();
}

String encodeTimesOfDay(List<MinuteOfDay> times) =>
    (times.toSet().toList()..sort()).map(formatMinuteOfDay).join(',');

/// Adds [months] to a calendar date, clamping the day so Jan 31 + 1 month is
/// the last day of February rather than overflowing into March.
DateTime addMonthsClamped(DateTime date, int months) {
  final totalMonths = date.year * 12 + (date.month - 1) + months;
  final year = totalMonths ~/ 12;
  final month = totalMonths % 12 + 1;
  final lastDay = DateTime(year, month + 1, 0).day;
  final day = date.day > lastDay ? lastDay : date.day;
  return DateTime(year, month, day);
}

/// A repeating schedule anchored on [startDate] (local calendar date).
///
/// Occurrence dates are always computed from the anchor (start + n * interval)
/// instead of step by step, so month clamping never drifts (Jan 31 -> Feb 28
/// -> Mar 31, not Mar 28).
class Recurrence {
  Recurrence({
    required DateTime startDate,
    required List<MinuteOfDay> times,
    required this.unit,
    int interval = 1,
  }) : startDate = DateTime(startDate.year, startDate.month, startDate.day),
       times = (times.isEmpty ? const [540] : (times.toSet().toList()..sort())),
       interval = interval < 1 ? 1 : interval;

  final DateTime startDate;
  final List<MinuteOfDay> times;
  final RepeatUnit unit;
  final int interval;

  bool get repeats => unit != RepeatUnit.none;

  /// Calendar date of the [n]-th period, or null past the end of a one-off.
  DateTime? periodDate(int n) {
    if (n < 0) return null;
    final s = startDate;
    return switch (unit) {
      RepeatUnit.none => n == 0 ? s : null,
      RepeatUnit.day => DateTime(s.year, s.month, s.day + n * interval),
      RepeatUnit.week => DateTime(s.year, s.month, s.day + 7 * n * interval),
      RepeatUnit.month => addMonthsClamped(s, n * interval),
      RepeatUnit.year => addMonthsClamped(s, 12 * n * interval),
    };
  }

  DateTime _at(DateTime date, MinuteOfDay m) =>
      DateTime(date.year, date.month, date.day, m ~/ 60, m % 60);

  /// The very first occurrence.
  DateTime get first => _at(startDate, times.first);

  /// First occurrence strictly after [t], or null if the schedule has ended.
  DateTime? nextAfter(DateTime t) {
    var n = _estimatePeriodBefore(t);
    for (var guard = 0; guard < 100000; guard++, n++) {
      final date = periodDate(n);
      if (date == null) return null;
      for (final m in times) {
        final candidate = _at(date, m);
        if (candidate.isAfter(t)) return candidate;
      }
    }
    return null;
  }

  /// Occurrences in (after, until], at most [limit].
  List<DateTime> occurrencesBetween(
    DateTime after,
    DateTime until, {
    int limit = 50,
  }) {
    final result = <DateTime>[];
    var cursor = after;
    while (result.length < limit) {
      final next = nextAfter(cursor);
      if (next == null || next.isAfter(until)) break;
      result.add(next);
      cursor = next;
    }
    return result;
  }

  /// A period index safely at or before the one containing [t], so the
  /// forward scan in [nextAfter] stays short for old anchors.
  int _estimatePeriodBefore(DateTime t) {
    if (!t.isAfter(startDate)) return 0;
    final days = DateTime(t.year, t.month, t.day)
        .difference(startDate)
        .inDays;
    final n = switch (unit) {
      RepeatUnit.none => 0,
      RepeatUnit.day => days ~/ interval,
      RepeatUnit.week => days ~/ (7 * interval),
      RepeatUnit.month =>
        ((t.year - startDate.year) * 12 + t.month - startDate.month) ~/
            interval,
      RepeatUnit.year => (t.year - startDate.year) ~/ interval,
    };
    return n > 1 ? n - 1 : 0;
  }
}

/// Next due time when a reminder is created or edited.
///
/// One-off reminders keep their date even if it is in the past (they show as
/// overdue). Repeating reminders whose anchor is in the past start from the
/// first occurrence today or later, so an old start date does not create a
/// backlog of missed doses.
DateTime? initialNextDue(Recurrence r, DateTime now) {
  if (!r.repeats) return r.first;
  final startOfToday = DateTime(now.year, now.month, now.day);
  if (!r.first.isBefore(startOfToday)) return r.first;
  return r.nextAfter(startOfToday.subtract(const Duration(seconds: 1)));
}

/// Result of completing the current occurrence of a reminder.
class CompletionResult {
  const CompletionResult({required this.startDate, required this.nextDueAt});

  /// Possibly re-anchored start date.
  final DateTime startDate;

  /// Next occurrence, or null when a one-off reminder is finished.
  final DateTime? nextDueAt;
}

/// Decides the next due time after the user completes [currentDue] at [now].
///
/// * One-off: finished.
/// * Monthly / yearly (vaccines, deworming…): re-anchor on the day it was
///   actually done, so the next dose is one full interval after real care.
/// * Daily / weekly (medication…): keep the fixed timetable and skip any
///   occurrences that were missed while overdue.
CompletionResult completeOccurrence({
  required Recurrence recurrence,
  required DateTime currentDue,
  required DateTime now,
}) {
  switch (recurrence.unit) {
    case RepeatUnit.none:
      return CompletionResult(startDate: recurrence.startDate, nextDueAt: null);
    case RepeatUnit.month:
    case RepeatUnit.year:
      final anchored = Recurrence(
        startDate: now,
        times: recurrence.times,
        unit: recurrence.unit,
        interval: recurrence.interval,
      );
      return CompletionResult(
        startDate: anchored.startDate,
        nextDueAt: anchored.periodDate(1) == null
            ? null
            : DateTime(
                anchored.periodDate(1)!.year,
                anchored.periodDate(1)!.month,
                anchored.periodDate(1)!.day,
                recurrence.times.first ~/ 60,
                recurrence.times.first % 60,
              ),
      );
    case RepeatUnit.day:
    case RepeatUnit.week:
      final from = currentDue.isAfter(now) ? currentDue : now;
      return CompletionResult(
        startDate: recurrence.startDate,
        nextDueAt: recurrence.nextAfter(from),
      );
  }
}
