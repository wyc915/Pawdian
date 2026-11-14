import 'dart:js_interop';

import 'package:web/web.dart' as web;

void reloadPage() => web.window.location.reload();

void whenVisible(void Function() action) {
  if (web.document.visibilityState == 'visible') {
    action();
    return;
  }
  late final JSFunction listener;
  listener = ((web.Event _) {
    if (web.document.visibilityState != 'visible') return;
    web.document.removeEventListener('visibilitychange', listener);
    action();
  }).toJS;
  web.document.addEventListener('visibilitychange', listener);
}
