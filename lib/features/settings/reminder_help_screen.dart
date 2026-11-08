import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

class ReminderHelpScreen extends StatelessWidget {
  const ReminderHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final steps = [
      l.reminderHelpStep1,
      l.reminderHelpStep2,
      l.reminderHelpStep3,
      l.reminderHelpStep4,
    ];
    return Scaffold(
      appBar: AppBar(title: Text(l.reminderHelpTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l.reminderHelpIntro),
          const SizedBox(height: 12),
          for (var i = 0; i < steps.length; i++)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(radius: 14, child: Text('${i + 1}')),
              title: Text(steps[i]),
            ),
        ],
      ),
    );
  }
}
