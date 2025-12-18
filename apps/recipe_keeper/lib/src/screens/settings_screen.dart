import 'dart:io';

import 'package:data/data.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../i18n/strings.g.dart';
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
  bool _isDeletingRecipes = false;
  PackageInfo? _packageInfo;

  @override
  void initState() {
    super.initState();
    BackupService.instance.init();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _packageInfo = packageInfo;
      });
    }
  }

  Future<void> _exportData() async {
    setState(() => _isExporting = true);
    final messenger = ScaffoldMessenger.of(context);

    try {
      final file = await BackupService.instance.exportToFile();
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(t.settings.dataManagement.exportSuccess.replaceAll('{path}', file.path)),
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: t.common.ok,
              onPressed: () {},
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(t.settings.dataManagement.exportError.replaceAll('{error}', e.toString())),
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
          SnackBar(
            content: Text(t.settings.dataManagement.importSuccess),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(t.settings.dataManagement.importError.replaceAll('{error}', e.toString())),
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

  Future<void> _deleteAllRecipes() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.settings.dataManagement.deleteAllRecipes),
        content: Text(t.settings.dataManagement.deleteAllRecipesConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(t.common.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(t.common.delete),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    if (!mounted) return;

    setState(() => _isDeletingRecipes = true);

    try {
      await AppRepositories.instance.recipes.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t.settings.dataManagement.deleteAllRecipesSuccess),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t.settings.dataManagement.deleteAllRecipesError.replaceAll('{error}', e.toString())),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isDeletingRecipes = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final prefs = MeasurementPreferences.instance;
    final t = context.t;
    return Scaffold(
      appBar: BackAwareAppBar(title: Text(t.settings.title)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            t.settings.measurements.title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            t.settings.measurements.description,
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
                      title: Text(
                        system == MeasurementSystem.metric
                            ? t.settings.measurements.metric.name
                            : t.settings.measurements.imperial.name,
                      ),
                      subtitle: Text(
                        system == MeasurementSystem.metric
                            ? t.settings.measurements.metric.description
                            : t.settings.measurements.imperial.description,
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
          const SizedBox(height: 32),
          Text(
            t.settings.dataManagement.title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            t.settings.dataManagement.description,
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
                  title: Text(t.settings.dataManagement.exportData),
                  subtitle: Text(
                    t.settings.dataManagement.exportDataDescription,
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
                  title: Text(t.settings.dataManagement.importData),
                  subtitle: Text(
                    t.settings.dataManagement.importDataDescription,
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
                const Divider(height: 1),
                ListTile(
                  leading: Icon(
                    Icons.delete_outline,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  title: Text(
                    t.settings.dataManagement.deleteAllRecipes,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  subtitle: Text(
                    t.settings.dataManagement.deleteAllRecipesDescription,
                  ),
                  trailing: _isDeletingRecipes
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.chevron_right),
                  onTap: _isDeletingRecipes ? null : _deleteAllRecipes,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // Version info section
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                children: [
                  if (_packageInfo != null) ...[
                    Text(
                      t.settings.version.format
                          .replaceAll('{version}', _packageInfo!.version)
                          .replaceAll('{buildNumber}', _packageInfo!.buildNumber),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      t.settings.version.package.replaceAll('{packageName}', _packageInfo!.packageName),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        fontSize: 11,
                      ),
                    ),
                  ] else
                    Text(
                      t.settings.version.loading,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

