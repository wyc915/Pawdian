import 'dart:ui';

import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:pawdian/core/database/app_database.dart';
import 'package:pawdian/core/domain/enums.dart';
import 'package:pawdian/features/pets/data/pet_repository.dart';
import 'package:pawdian/features/reminders/data/reminder_repository.dart';
import 'package:pawdian/features/templates/care_templates.dart';
import 'package:pawdian/l10n/app_localizations.dart';
import 'package:pawdian/shared/l10n_labels.dart';

import 'helpers.dart';

final en = lookupAppLocalizations(const Locale('en'));
final zh = lookupAppLocalizations(const Locale('zh'));

void main() {
  test('template titles follow the current app language', () async {
    final db = memoryDatabase();
    addTearDown(db.close);
    final petId = await PetRepository(db).create(
      const PetsCompanion(name: Value('Mochi'), species: Value(Species.dog)),
    );
    final rabies = templatesFor(
      CareRegion.tw,
      Species.dog,
    ).firstWhere((t) => t.key == 'rabies');
    final heartworm = templatesFor(
      CareRegion.tw,
      Species.dog,
    ).firstWhere((t) => t.key == 'heartworm');
    expect(rabies.storedTitle, 'tpl:rabies');
    expect(heartworm.storedTitle, '');

    final repo = ReminderRepository(db);
    final id = await repo.create(
      petId,
      ReminderDraft(
        type: rabies.type,
        title: rabies.storedTitle,
        startDate: DateTime(2027, 1, 1),
        times: const [540],
        unit: rabies.unit,
      ),
    );
    final rule = (await repo.get(id))!;
    expect(reminderDisplayTitle(en, rule), 'Rabies vaccine');
    expect(reminderDisplayTitle(zh, rule), '狂犬病疫苗');

    // Completing copies the marker to the record, which also translates.
    await repo.complete(id);
    final record = (await db.select(db.careRecords).get()).single;
    expect(recordDisplayTitle(zh, record), '狂犬病疫苗');
  });

  test('editing keeps the template marker unless the text changes', () {
    expect(editableTitle(zh, 'tpl:coreCat'), '貓三合一疫苗');
    expect(titleToStore(zh, 'tpl:coreCat', '貓三合一疫苗'), 'tpl:coreCat');
    expect(titleToStore(zh, 'tpl:coreCat', '三合一'), '三合一');
    expect(titleToStore(en, '', ''), '');
    expect(titleToStore(en, 'My title', ' My title '), 'My title');
  });
}
