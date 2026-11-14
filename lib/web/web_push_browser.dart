import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:web/web.dart' as web;

import '../features/reminders/domain/notification_planner.dart';
import '../l10n/app_localizations.dart';
import '../server/web_push.dart' show b64url, b64urlDecode;
import 'server_api.dart';
import 'web_push.dart';

WebPushGateway createWebPushGateway(ServerApi api) => _BrowserPushGateway(api);

class _BrowserPushGateway implements WebPushGateway {
  _BrowserPushGateway(this.api);

  final ServerApi api;

  @override
  bool get supported =>
      globalContext.has('PushManager') &&
      globalContext.has('Notification') &&
      web.window.navigator.has('serviceWorker');

  bool get _standalone =>
      web.window.matchMedia('(display-mode: standalone)').matches ||
      (web.window.navigator.getProperty('standalone'.toJS) as JSBoolean?)
              ?.toDart ==
          true;

  bool get _isIos => RegExp(
    r'iPhone|iPad|iPod',
  ).hasMatch(web.window.navigator.userAgent);

  @override
  bool get needsInstall => _isIos && !_standalone;

  Future<web.ServiceWorkerRegistration?> _registration() async {
    if (!supported) return null;
    return web.window.navigator.serviceWorker.ready.toDart;
  }

  @override
  Future<void> init(void Function(NotificationResponse) onResponse) async {}

  /// A notification tap opens the app at `/?rule=<id>`.
  @override
  Future<NotificationResponse?> launchResponse() async {
    final rule = Uri.base.queryParameters['rule'];
    if (rule == null || rule.isEmpty) return null;
    web.window.history.replaceState(null, '', '/');
    return NotificationResponse(
      notificationResponseType: NotificationResponseType.selectedNotification,
      payload: rule,
    );
  }

  @override
  Future<bool> notificationsEnabled() async {
    if (!supported || web.Notification.permission != 'granted') return false;
    final reg = await _registration();
    final sub = await reg?.pushManager.getSubscription().toDart;
    if (sub == null) return false;
    // Re-send the subscription in case the server lost it.
    await _send(sub);
    return true;
  }

  @override
  Future<bool> requestNotifications() async {
    if (!supported) return false;
    final result = (await web.Notification.requestPermission().toDart).toDart;
    if (result != 'granted') return false;
    final reg = await _registration();
    if (reg == null) return false;
    var sub = await reg.pushManager.getSubscription().toDart;
    sub ??= await reg.pushManager
        .subscribe(
          web.PushSubscriptionOptionsInit(
            userVisibleOnly: true,
            applicationServerKey: b64urlDecode(await api.pushKey()).toJS,
          ),
        )
        .toDart;
    await _send(sub);
    return true;
  }

  Future<void> _send(web.PushSubscription sub) async {
    String key(String name) {
      final buf = sub.getKey(name);
      return buf == null ? '' : b64url(buf.toDart.asUint8List());
    }

    await api.subscribe({
      'endpoint': sub.endpoint,
      'keys': {'p256dh': key('p256dh'), 'auth': key('auth')},
    });
  }

  @override
  Future<bool> canScheduleExact() async => true;

  @override
  Future<void> requestExact() async {}

  @override
  Future<void> replaceAll(
    List<PlannedNotification> planned,
    AppLocalizations l,
  ) => uploadSchedule(api, planned);

  @override
  Future<int> sendTest(String title, String body) => api.testPush(title, body);
}

