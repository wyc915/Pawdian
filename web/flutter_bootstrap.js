{{flutter_js}}
{{flutter_build_config}}

// No Flutter service worker: Pawdian registers its own (push_sw.js) for
// Web Push. Flutter's deprecated worker would take over the same scope,
// unregister it and reload the page in a loop.
_flutter.loader.load();
