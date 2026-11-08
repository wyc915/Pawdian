import 'package:flutter_test/flutter_test.dart';
import 'package:pawdian/core/domain/enums.dart';
import 'package:pawdian/features/reminders/domain/recurrence.dart';

void main() {
  group('times of day', () {
    test('parses, sorts and de-duplicates', () {
      expect(parseTimesOfDay('20:00, 08:30,08:30'), [510, 1200]);
    });
    test('falls back on garbage', () {
      expect(parseTimesOfDay('xx', fallback: 600), [600]);
      expect(parseTimesOfDay('25:00', fallback: 600), [600]);
    });
    test('round-trips', () {
      expect(encodeTimesOfDay([1200, 510]), '08:30,20:00');
    });
  });

  group('addMonthsClamped', () {
    test('clamps to month end', () {
      expect(addMonthsClamped(DateTime(2026, 1, 31), 1), DateTime(2026, 2, 28));
      expect(addMonthsClamped(DateTime(2028, 1, 31), 1), DateTime(2028, 2, 29));
    });
    test('crosses years', () {
      expect(addMonthsClamped(DateTime(2026, 11, 15), 3), DateTime(2027, 2, 15));
    });
  });

  group('Recurrence.nextAfter', () {
    test('monthly from the 31st does not drift', () {
      final r = Recurrence(
        startDate: DateTime(2026, 1, 31),
        times: [540],
        unit: RepeatUnit.month,
      );
      expect(r.nextAfter(DateTime(2026, 2, 1)), DateTime(2026, 2, 28, 9));
      expect(r.nextAfter(DateTime(2026, 2, 28, 9)), DateTime(2026, 3, 31, 9));
    });

    test('daily with two doses', () {
      final r = Recurrence(
        startDate: DateTime(2026, 11, 1),
        times: [480, 1200],
        unit: RepeatUnit.day,
      );
      expect(r.nextAfter(DateTime(2026, 11, 8, 7)), DateTime(2026, 11, 8, 8));
      expect(r.nextAfter(DateTime(2026, 11, 8, 8)), DateTime(2026, 11, 8, 20));
      expect(r.nextAfter(DateTime(2026, 11, 8, 21)), DateTime(2026, 11, 9, 8));
    });

    test('every 3 months, far in the future, stays on schedule', () {
      final r = Recurrence(
        startDate: DateTime(2020, 1, 10),
        times: [540],
        unit: RepeatUnit.month,
        interval: 3,
      );
      expect(r.nextAfter(DateTime(2026, 11, 8)), DateTime(2027, 1, 10, 9));
    });

    test('one-off ends', () {
      final r = Recurrence(
        startDate: DateTime(2026, 11, 8),
        times: [540],
        unit: RepeatUnit.none,
      );
      expect(r.nextAfter(DateTime(2026, 11, 1)), DateTime(2026, 11, 8, 9));
      expect(r.nextAfter(DateTime(2026, 11, 8, 9)), isNull);
    });

    test('weekly', () {
      final r = Recurrence(
        startDate: DateTime(2026, 11, 2),
        times: [600],
        unit: RepeatUnit.week,
        interval: 2,
      );
      expect(
        r.occurrencesBetween(DateTime(2026, 11, 1), DateTime(2026, 12, 1)),
        [
          DateTime(2026, 11, 2, 10),
          DateTime(2026, 11, 16, 10),
          DateTime(2026, 11, 30, 10),
        ],
      );
    });
  });

  group('initialNextDue', () {
    final now = DateTime(2026, 11, 8, 13);

    test('future start is used as is', () {
      final r = Recurrence(
        startDate: DateTime(2026, 12, 1),
        times: [540],
        unit: RepeatUnit.year,
      );
      expect(initialNextDue(r, now), DateTime(2026, 12, 1, 9));
    });

    test('today keeps an earlier time (shown as overdue today)', () {
      final r = Recurrence(
        startDate: DateTime(2026, 11, 8),
        times: [540],
        unit: RepeatUnit.month,
      );
      expect(initialNextDue(r, now), DateTime(2026, 11, 8, 9));
    });

    test('old repeating start skips to today or later', () {
      final r = Recurrence(
        startDate: DateTime(2026, 1, 1),
        times: [540],
        unit: RepeatUnit.day,
      );
      expect(initialNextDue(r, now), DateTime(2026, 11, 8, 9));
    });

    test('old one-off stays overdue', () {
      final r = Recurrence(
        startDate: DateTime(2026, 10, 1),
        times: [540],
        unit: RepeatUnit.none,
      );
      expect(initialNextDue(r, now), DateTime(2026, 10, 1, 9));
    });
  });

  group('completeOccurrence', () {
    test('yearly vaccine re-anchors on the day it was done', () {
      final r = Recurrence(
        startDate: DateTime(2025, 10, 1),
        times: [540],
        unit: RepeatUnit.year,
      );
      final result = completeOccurrence(
        recurrence: r,
        currentDue: DateTime(2026, 10, 1, 9),
        now: DateTime(2026, 11, 8, 15),
      );
      expect(result.startDate, DateTime(2026, 11, 8));
      expect(result.nextDueAt, DateTime(2027, 11, 8, 9));
    });

    test('daily medication skips missed doses', () {
      final r = Recurrence(
        startDate: DateTime(2026, 11, 1),
        times: [480, 1200],
        unit: RepeatUnit.day,
      );
      final result = completeOccurrence(
        recurrence: r,
        currentDue: DateTime(2026, 11, 6, 8),
        now: DateTime(2026, 11, 8, 9),
      );
      expect(result.nextDueAt, DateTime(2026, 11, 8, 20));
    });

    test('early completion moves to the following dose', () {
      final r = Recurrence(
        startDate: DateTime(2026, 11, 1),
        times: [480, 1200],
        unit: RepeatUnit.day,
      );
      final result = completeOccurrence(
        recurrence: r,
        currentDue: DateTime(2026, 11, 8, 8),
        now: DateTime(2026, 11, 8, 7, 50),
      );
      expect(result.nextDueAt, DateTime(2026, 11, 8, 20));
    });

    test('one-off finishes', () {
      final r = Recurrence(
        startDate: DateTime(2026, 11, 8),
        times: [540],
        unit: RepeatUnit.none,
      );
      final result = completeOccurrence(
        recurrence: r,
        currentDue: DateTime(2026, 11, 8, 9),
        now: DateTime(2026, 11, 8, 10),
      );
      expect(result.nextDueAt, isNull);
    });
  });
}
