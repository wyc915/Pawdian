import 'dart:async';
import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/reminders/data/reminder_repository.dart';
import '../../features/reminders/domain/notification_planner.dart';
import '../../l10n/app_localizations.dart';
import '../router/app_router.dart';
import '../settings/app_language.dart';
import '../widgets/home_widget_sync.dart';
import 'background_actions.dart';
import 'notification_gateway.dart';

AppLocalizations currentLocalizations(Ref ref) {
  final locale =
      ref.read(appLanguageProvider).locale ??
      resolveAppLocale(PlatformDispatcher.instance.locale);
  return lookupAppLocalizations(locale);
}

/// Re-plans every pending notification from the current database state.
class ReminderScheduler {
  ReminderScheduler(this._ref);

  final Ref _ref;
  Timer? _debounce;

  void scheduleSoon() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), resyncNow);
  }

  Future<void> resyncNow() async {
    final items = await _ref.read(schedulableRemindersProvider.future);
    if (!_ref.mounted) return;
    final l = currentLocalizations(_ref);
    final planned = planNotifications(items, DateTime.now(), l);
    try {
      await _ref.read(notificationGatewayProvider).replaceAll(planned, l);
    } catch (e) {
      debugPrint('Scheduling notifications failed: $e');
    }
    if (!_ref.mounted) return;
    try {
      await _ref
          .read(homeWidgetGatewayProvider)
          .show(nextReminderTexts(items, DateTime.now(), l));
    } catch (e) {
      debugPrint('Updating home widget failed: $e');
    }
  }

  void dispose() => _debounce?.cancel();
}

final reminderSchedulerProvider = Provider<ReminderScheduler>((ref) {
  final scheduler = ReminderScheduler(ref);
  ref.onDispose(scheduler.dispose);
  return scheduler;
});

/// Handles taps and action buttons on reminder notifications.
class NotificationResponseHandler {
  NotificationResponseHandler(this._ref);

  final Ref _ref;

  Future<void> handle(NotificationResponse response) async {
    final ruleId = response.payload;
    if (ruleId == null || ruleId.isEmpty) return;
    final repo = _ref.read(reminderRepositoryProvider);
    // Buttons normally run in the background (background_actions.dart);
    // this covers a tap, or a button on an older notification.
    if (!await applyNotificationAction(repo, response.actionId, ruleId)) {
      final rule = await repo.get(ruleId);
      if (rule != null) {
        _ref.read(appRouterProvider).go(AppRoutes.pet(rule.petId));
      }
    }
    _ref.read(reminderSchedulerProvider).scheduleSoon();
  }
}

final notificationResponseHandlerProvider =
    Provider<NotificationResponseHandler>(NotificationResponseHandler.new);

/// Keeps scheduled notifications in sync with the data, the app language and
/// the app returning to the foreground.
class NotificationSync extends ConsumerStatefulWidget {
  const NotificationSync({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<NotificationSync> createState() => _NotificationSyncState();
}

class _NotificationSyncState extends ConsumerState<NotificationSync> {
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(onResume: _resync);
    ref.listenManual(schedulableRemindersProvider, (_, _) => _resync());
    ref.listenManual(appLanguageProvider, (_, _) => _resync());
  }

  void _resync() => ref.read(reminderSchedulerProvider).scheduleSoon();

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
