/// Browser helpers; no-ops outside the web edition.
void reloadPage() {}

/// Calls [action] now if the page is visible, otherwise when it next becomes
/// visible (the phone was locked or another app was in front).
void whenVisible(void Function() action) => action();
