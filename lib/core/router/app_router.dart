import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/home/home_screen.dart';
import '../../features/pets/pet_detail_screen.dart';
import '../../features/pets/pet_form_screen.dart';
import '../../features/pets/pets_screen.dart';
import '../../features/records/record_form_screen.dart';
import '../../features/records/timeline_screen.dart';
import '../../features/reminders/reminder_form_screen.dart';
import '../../features/weight/weight_screen.dart';
import '../domain/enums.dart';
import '../../features/settings/reminder_help_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/templates/template_picker_screen.dart';
import '../../l10n/app_localizations.dart';

abstract final class AppRoutes {
  static const home = '/home';
  static const pets = '/pets';
  static const newPet = '/pets/new';
  static const settings = '/settings';
  static const reminderHelp = '/settings/reminder-help';

  static String pet(String id) => '/pets/$id';
  static String editPet(String id) => '/pets/$id/edit';
  static String petTemplates(String id, {bool isNew = false}) =>
      '/pets/$id/templates${isNew ? '?new=1' : ''}';
  static String newReminder(String petId) => '/pets/$petId/reminders/new';
  static String editReminder(String petId, String ruleId) =>
      '/pets/$petId/reminders/$ruleId';
  static String newRecord(String petId, {RecordType? type}) =>
      '/pets/$petId/records/new${type == null ? '' : '?type=${type.name}'}';
  static String editRecord(String petId, String recordId) =>
      '/pets/$petId/records/$recordId';
  static String timeline(String petId) => '/pets/$petId/timeline';
  static String weight(String petId) => '/pets/$petId/weight';
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.pets,
                builder: (context, state) => const PetsScreen(),
                routes: [
                  GoRoute(
                    path: 'new',
                    builder: (context, state) => const PetFormScreen(),
                  ),
                  GoRoute(
                    path: ':petId',
                    builder: (context, state) => PetDetailScreen(
                      petId: state.pathParameters['petId']!,
                    ),
                    routes: [
                      GoRoute(
                        path: 'edit',
                        builder: (context, state) => PetFormScreen(
                          petId: state.pathParameters['petId'],
                        ),
                      ),
                      GoRoute(
                        path: 'templates',
                        builder: (context, state) => TemplatePickerScreen(
                          petId: state.pathParameters['petId']!,
                          isNewPet: state.uri.queryParameters['new'] == '1',
                        ),
                      ),
                      GoRoute(
                        path: 'reminders/new',
                        builder: (context, state) => ReminderFormScreen(
                          petId: state.pathParameters['petId']!,
                        ),
                      ),
                      GoRoute(
                        path: 'reminders/:ruleId',
                        builder: (context, state) => ReminderFormScreen(
                          petId: state.pathParameters['petId']!,
                          ruleId: state.pathParameters['ruleId'],
                        ),
                      ),
                      GoRoute(
                        path: 'records/new',
                        builder: (context, state) => RecordFormScreen(
                          petId: state.pathParameters['petId']!,
                          initialType: RecordType.values
                              .where(
                                (t) =>
                                    t.name == state.uri.queryParameters['type'],
                              )
                              .firstOrNull,
                        ),
                      ),
                      GoRoute(
                        path: 'records/:recordId',
                        builder: (context, state) => RecordFormScreen(
                          petId: state.pathParameters['petId']!,
                          recordId: state.pathParameters['recordId'],
                        ),
                      ),
                      GoRoute(
                        path: 'timeline',
                        builder: (context, state) => TimelineScreen(
                          petId: state.pathParameters['petId']!,
                        ),
                      ),
                      GoRoute(
                        path: 'weight',
                        builder: (context, state) =>
                            WeightScreen(petId: state.pathParameters['petId']!),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.settings,
                builder: (context, state) => const SettingsScreen(),
                routes: [
                  GoRoute(
                    path: 'reminder-help',
                    builder: (context, state) => const ReminderHelpScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: (index) => shell.goBranch(
          index,
          initialLocation: index == shell.currentIndex,
        ),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.today_outlined),
            selectedIcon: const Icon(Icons.today),
            label: l10n.navHome,
          ),
          NavigationDestination(
            icon: const Icon(Icons.pets_outlined),
            selectedIcon: const Icon(Icons.pets),
            label: l10n.navPets,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: l10n.navSettings,
          ),
        ],
      ),
    );
  }
}
