import 'package:flutter/material.dart';

import '../services/measurement_preferences.dart';
import '../widgets/back_aware_app_bar.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const routeName = '/settings';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final prefs = MeasurementPreferences.instance;
    return Scaffold(
      appBar: const BackAwareAppBar(title: Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'Measurements',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Choose how ingredient units are displayed. Recipes using a different '
            'system will be automatically converted to your preference.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 12),
          AnimatedBuilder(
            animation: prefs,
            builder: (context, _) {
              final current = prefs.system;
              return Column(
                children: MeasurementSystem.values.map((system) {
                  return Card(
                    child: RadioListTile<MeasurementSystem>(
                      value: system,
                      // ignore: deprecated_member_use
                      groupValue: current,
                      // ignore: deprecated_member_use
                      onChanged: (value) {
                        if (value != null) {
                          prefs.setSystem(value);
                        }
                      },
                      title: Text(system.displayName),
                      subtitle: Text(
                        system == MeasurementSystem.metric
                            ? 'Ingredients show grams, kilograms, milliliters and liters.'
                            : 'Ingredients show cups, tablespoons, teaspoons, ounces and pounds.',
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

