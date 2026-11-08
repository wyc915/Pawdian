import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/database/app_database.dart';
import '../../core/domain/enums.dart';
import 'demo_data.dart';
import '../../core/notifications/notification_gateway.dart';
import '../../core/notifications/notification_status.dart';
import '../../core/router/app_router.dart';
import '../../core/settings/app_language.dart';
import '../../core/settings/app_settings.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/formatting.dart';
import '../../shared/l10n_labels.dart';
import '../../shared/units.dart';
import '../records/widgets/record_tile.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final language = ref.watch(appLanguageProvider);
    final regionSetting = ref.watch(careRegionSettingProvider);
    final defaultTime = ref.watch(defaultReminderTimeProvider);
    final status = ref.watch(notificationStatusProvider).value;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.navSettings)),
      body: ListView(
        children: [
          ListTile(
            key: const Key('settings.pro'),
            leading: Icon(
              Icons.workspace_premium_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: Text(l10n.settingsPro),
            subtitle: Text(
              ref.watch(isProProvider)
                  ? l10n.settingsProActive
                  : l10n.settingsProFree,
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go(AppRoutes.pro),
          ),
          const Divider(),
          ListTile(
            key: const Key('settings.language'),
            leading: const Icon(Icons.language),
            title: Text(l10n.settingsLanguage),
            subtitle: Text(languageLabel(l10n, language)),
            onTap: () => _pickLanguage(context, ref, language),
          ),
          ListTile(
            leading: const Icon(Icons.public),
            title: Text(l10n.settingsRegion),
            subtitle: Text(
              regionSetting == null
                  ? '${l10n.regionAuto} (${regionLabel(l10n, ref.watch(effectiveCareRegionProvider))})'
                  : regionLabel(l10n, regionSetting),
            ),
            onTap: () => _pickRegion(context, ref, regionSetting),
          ),
          ListTile(
            leading: const Icon(Icons.schedule),
            title: Text(l10n.settingsDefaultTime),
            subtitle: Text(formatMinute(context, defaultTime)),
            onTap: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: TimeOfDay(
                  hour: defaultTime ~/ 60,
                  minute: defaultTime % 60,
                ),
              );
              if (picked != null) {
                await ref
                    .read(defaultReminderTimeProvider.notifier)
                    .set(picked.hour * 60 + picked.minute);
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.monitor_weight_outlined),
            title: Text(l10n.settingsWeightUnit),
            subtitle: Text(
              ref.watch(weightUnitSettingProvider) == null
                  ? '${l10n.regionAuto} (${weightUnitSymbol(ref.watch(effectiveWeightUnitProvider))})'
                  : weightUnitSymbol(ref.watch(weightUnitSettingProvider)!),
            ),
            onTap: () => _pickWeightUnit(context, ref),
          ),
          ListTile(
            key: const Key('settings.quickLog'),
            leading: const Icon(Icons.bolt_outlined),
            title: Text(l10n.settingsQuickLog),
            subtitle: Text(
              ref
                  .watch(quickLogTypesProvider)
                  .map((t) => recordTypeLabel(l10n, t))
                  .join(l10n.localeName.startsWith('zh') ? '、' : ', '),
            ),
            onTap: () => showModalBottomSheet<void>(
              context: context,
              builder: (_) => const _QuickLogPicker(),
            ),
          ),
          const Divider(),
          _SectionHeader(l10n.settingsNotifications),
          if (status != null) ...[
            ListTile(
              leading: Icon(
                status.enabled
                    ? Icons.notifications_active_outlined
                    : Icons.notifications_off_outlined,
              ),
              title: Text(
                status.enabled ? l10n.notifAllowed : l10n.notifBlocked,
              ),
              onTap: status.enabled
                  ? null
                  : () => requestNotificationPermission(ref),
            ),
            ListTile(
              leading: Icon(
                status.exact
                    ? Icons.alarm_on_outlined
                    : Icons.alarm_off_outlined,
              ),
              title: Text(status.exact ? l10n.exactAllowed : l10n.exactBlocked),
              onTap: status.exact
                  ? null
                  : () async {
                      await ref
                          .read(notificationGatewayProvider)
                          .requestExact();
                      ref.invalidate(notificationStatusProvider);
                    },
            ),
          ],
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: Text(l10n.reminderHelpTitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go(AppRoutes.reminderHelp),
          ),
          const Divider(),
          _SectionHeader(l10n.settingsData),
          ListTile(
            key: const Key('settings.backup'),
            leading: const Icon(Icons.backup_outlined),
            title: Text(l10n.backupTitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go(AppRoutes.backup),
          ),
          if (kDebugMode) ...[
            const Divider(),
            SwitchListTile(
              secondary: const Icon(Icons.bug_report_outlined),
              title: Text(l10n.debugPro),
              value: ref.watch(isProProvider),
              onChanged: (v) =>
                  ref.read(isProProvider.notifier).setDebugUnlocked(v),
            ),
            // Not translated: only visible in debug builds.
            ListTile(
              leading: const Icon(Icons.science_outlined),
              title: const Text('Developer: load demo data'),
              onTap: () => loadDemoData(
                ref.read(appDatabaseProvider),
                chinese: l10n.localeName.startsWith('zh'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _pickLanguage(
    BuildContext context,
    WidgetRef ref,
    AppLanguage current,
  ) async {
    final l10n = AppLocalizations.of(context);
    final picked = await _pickOne<AppLanguage>(
      context,
      title: l10n.settingsLanguage,
      options: AppLanguage.values,
      current: current,
      label: (o) => languageLabel(l10n, o),
      keyOf: (o) => 'language.${o.name}',
    );
    if (picked != null) {
      await ref.read(appLanguageProvider.notifier).set(picked);
    }
  }

  Future<void> _pickWeightUnit(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final options = <({WeightUnit? unit})>[
      (unit: null),
      for (final u in WeightUnit.values) (unit: u),
    ];
    final picked = await _pickOne<({WeightUnit? unit})>(
      context,
      title: l10n.settingsWeightUnit,
      options: options,
      current: (unit: ref.read(weightUnitSettingProvider)),
      label: (o) =>
          o.unit == null ? l10n.regionAuto : weightUnitSymbol(o.unit!),
      keyOf: (o) => 'weightUnit.${o.unit?.name ?? 'auto'}',
    );
    if (picked != null) {
      await ref.read(weightUnitSettingProvider.notifier).set(picked.unit);
    }
  }

  Future<void> _pickRegion(
    BuildContext context,
    WidgetRef ref,
    CareRegion? current,
  ) async {
    final l10n = AppLocalizations.of(context);
    // Wrap so "automatic" (null) can be a selectable option.
    final options = <({CareRegion? region})>[
      (region: null),
      for (final r in CareRegion.values) (region: r),
    ];
    final picked = await _pickOne<({CareRegion? region})>(
      context,
      title: l10n.settingsRegion,
      options: options,
      current: (region: current),
      label: (o) =>
          o.region == null ? l10n.regionAuto : regionLabel(l10n, o.region!),
      keyOf: (o) => 'region.${o.region?.name ?? 'auto'}',
    );
    if (picked != null) {
      await ref.read(careRegionSettingProvider.notifier).set(picked.region);
    }
  }
}

Future<T?> _pickOne<T>(
  BuildContext context, {
  required String title,
  required List<T> options,
  required T current,
  required String Function(T) label,
  required String Function(T) keyOf,
}) => showDialog<T>(
  context: context,
  builder: (context) => SimpleDialog(
    title: Text(title),
    children: [
      for (final option in options)
        SimpleDialogOption(
          key: Key(keyOf(option)),
          onPressed: () => Navigator.pop(context, option),
          child: Row(
            children: [
              Expanded(child: Text(label(option))),
              if (option == current) const Icon(Icons.check),
            ],
          ),
        ),
    ],
  ),
);

class _QuickLogPicker extends ConsumerWidget {
  const _QuickLogPicker();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final selected = ref.watch(quickLogTypesProvider).toSet();
    return SafeArea(
      child: ListView(
        shrinkWrap: true,
        children: [
          ListTile(
            title: Text(
              l10n.settingsQuickLog,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          for (final t in kQuickLogTypes)
            CheckboxListTile(
              secondary: Icon(recordIcon(t)),
              title: Text(recordTypeLabel(l10n, t)),
              value: selected.contains(t),
              onChanged: (v) => ref
                  .read(quickLogTypesProvider.notifier)
                  .toggle(t, v ?? false),
            ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
    child: Text(text, style: Theme.of(context).textTheme.titleSmall),
  );
}

String languageLabel(AppLocalizations l10n, AppLanguage language) =>
    switch (language) {
      AppLanguage.system => l10n.languageSystem,
      AppLanguage.english => l10n.languageEnglish,
      AppLanguage.chineseTraditional => l10n.languageChineseTraditional,
    };
