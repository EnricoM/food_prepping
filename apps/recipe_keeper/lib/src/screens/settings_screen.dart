import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../services/backup_service.dart';
import '../services/measurement_preferences.dart';
import '../widgets/back_aware_app_bar.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  static const routeName = '/settings';

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isExporting = false;
  bool _isImporting = false;

  @override
  void initState() {
    super.initState();
    BackupService.instance.init();
  }

  Future<void> _exportData() async {
    setState(() => _isExporting = true);
    final messenger = ScaffoldMessenger.of(context);

    try {
      final file = await BackupService.instance.exportToFile();
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('Data exported successfully to:\n${file.path}'),
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'OK',
              onPressed: () {},
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('Failed to export data: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  Future<void> _importData() async {
    setState(() => _isImporting = true);
    final messenger = ScaffoldMessenger.of(context);

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.single.path == null) {
        // User cancelled
        if (mounted) {
          setState(() => _isImporting = false);
        }
        return;
      }

      final file = File(result.files.single.path!);
      await BackupService.instance.importFromFile(file);

      if (mounted) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Data imported successfully!'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('Failed to import data: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isImporting = false);
      }
    }
  }

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
          const SizedBox(height: 32),
          Text(
            'Data Management',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Export your recipes, meal plans, shopping list, and inventory to a JSON file. '
            'You can import this file later to restore your data.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.file_download_outlined),
                  title: const Text('Export Data'),
                  subtitle: const Text(
                    'Save all your data to a JSON file',
                  ),
                  trailing: _isExporting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.chevron_right),
                  onTap: _isExporting ? null : _exportData,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.file_upload_outlined),
                  title: const Text('Import Data'),
                  subtitle: const Text(
                    'Restore data from a JSON backup file',
                  ),
                  trailing: _isImporting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.chevron_right),
                  onTap: _isImporting ? null : _importData,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

