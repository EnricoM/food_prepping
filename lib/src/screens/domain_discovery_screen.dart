import 'dart:async';

import 'package:flutter/material.dart';
import 'package:parsing/parsing.dart';
import 'package:shared_ui/shared_ui.dart';

import '../navigation/app_drawer.dart';

class DomainDiscoveryScreen extends StatefulWidget {
  const DomainDiscoveryScreen({
    super.key,
    this.drawer,
    required this.onRecipeDiscovered,
  });

  static const routeName = '/discover';

  final Widget? drawer;
  final void Function(BuildContext context, String url) onRecipeDiscovered;

  @override
  State<DomainDiscoveryScreen> createState() => _DomainDiscoveryScreenState();
}

class _DiscoveredUrl {
  _DiscoveredUrl(this.url);

  final Uri url;
  bool? hasRecipe;
  String? error;
}

class _DomainDiscoveryScreenState extends State<DomainDiscoveryScreen> {
  final _domainController = TextEditingController();
  final _discovery = DomainRecipeDiscovery();
  final _parser = RecipeParser();
  final List<_DiscoveredUrl> _results = [];
  Future<void>? _filterTask;
  bool _cancelFiltering = false;
  int _completedFilters = 0;
  int _successfulFilters = 0;
  bool _isLoading = false;
  bool _isFiltering = false;
  String? _error;

  @override
  void dispose() {
    _cancelFiltering = true;
    _filterTask = null;
    _domainController.dispose();
    _parser.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inset = responsivePageInsets(context);
    final totalResults = _results.length;
    final successfulResults =
        _results.where((entry) => entry.hasRecipe == true).toList();
    final failedCount =
        _results.where((entry) => entry.hasRecipe == false).length;
    final pendingCount =
        _results.where((entry) => entry.hasRecipe == null).length;
    return Scaffold(
      appBar: AppBar(title: const Text('Discover recipes by domain')),
      drawer:
          widget.drawer ??
          const AppDrawer(currentRoute: DomainDiscoveryScreen.routeName),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: inset,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _domainController,
                decoration: InputDecoration(
                  labelText: 'Domain (e.g. example.com)',
                  border: const OutlineInputBorder(),
                  suffixIcon: _domainController.text.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.clear),
                          tooltip: 'Clear domain',
                          onPressed: () {
                        _cancelFiltering = true;
                            setState(() {
                              _domainController.clear();
                          _results.clear();
                          _isFiltering = false;
                          _completedFilters = 0;
                          _successfulFilters = 0;
                              _error = null;
                            });
                          },
                        ),
                ),
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => _discover(),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: _isLoading ? null : _discover,
                icon: _isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.language),
                label: Text(_isLoading ? 'Scanning…' : 'Scan domain'),
              ),
              if (_error != null) ...[
                const SizedBox(height: 16),
                Text(
                  _error!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            if (_isFiltering && totalResults > 0) ...[
              const SizedBox(height: 24),
              LinearProgressIndicator(
                value: totalResults == 0
                    ? null
                    : _completedFilters / totalResults.clamp(1, double.infinity),
              ),
              const SizedBox(height: 8),
              Text(
                'Checking $_completedFilters of $totalResults pages… '
                'Found $_successfulFilters recipe${_successfulFilters == 1 ? '' : 's'}.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              if (pendingCount > 0)
                Text(
                  '$pendingCount page${pendingCount == 1 ? '' : 's'} remaining…',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
            ] else if (!_isFiltering && totalResults > 0) ...[
              const SizedBox(height: 24),
              Text(
                _successfulFilters > 0
                    ? 'Found $_successfulFilters recipe page${_successfulFilters == 1 ? '' : 's'}.'
                    : 'No recipe pages detected yet.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
            if (successfulResults.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Ready to import',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: successfulResults.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final url = successfulResults[index].url;
                  return Card(
                    child: ListTile(
                      title: Text(url.toString()),
                      subtitle: const Text('Tap to open in parser'),
                      trailing: const Icon(Icons.open_in_new),
                      onTap: () => widget.onRecipeDiscovered(
                        context,
                        url.toString(),
                      ),
                    ),
                  );
                },
              ),
            ],
            if (!_isFiltering && failedCount > 0) ...[
              const SizedBox(height: 16),
              Card(
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                  title: Text(
                    '$failedCount page${failedCount == 1 ? '' : 's'} skipped (no recipe detected)',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  children: _results
                      .where((entry) => entry.hasRecipe == false)
                      .take(10)
                      .map(
                        (entry) => ListTile(
                          title: Text(entry.url.toString()),
                          subtitle: entry.error == null
                              ? const Text('No recipe structure found.')
                              : Text(entry.error!),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _discover() async {
    final domain = _domainController.text.trim();
    if (domain.isEmpty) {
      setState(() => _error = 'Enter a domain to scan.');
      return;
    }
    _cancelFiltering = true;
    final previousTask = _filterTask;
    if (previousTask != null) {
      await previousTask;
    }
    if (!mounted) return;
    _cancelFiltering = false;
    setState(() {
      _isLoading = true;
      _error = null;
      _isFiltering = false;
      _completedFilters = 0;
      _successfulFilters = 0;
      _results.clear();
    });
    try {
      final urls = await _discovery.discoverRecipes(domain);
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _results.addAll(urls.map(_DiscoveredUrl.new));
      });
      if (urls.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No pages found for this domain.')),
        );
        return;
      }
      _startFiltering();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = 'Failed to scan domain: $error';
      });
    }
  }

  void _startFiltering() {
    setState(() {
      _isFiltering = true;
      _completedFilters = 0;
      _successfulFilters = 0;
    });
    _cancelFiltering = false;
    final task = _filterDiscoveredUrls();
    _filterTask = task;
    task.whenComplete(() {
      if (identical(_filterTask, task)) {
        _filterTask = null;
      }
    });
  }

  Future<void> _filterDiscoveredUrls() async {
    for (final entry in _results) {
      if (_cancelFiltering) {
        break;
      }
      try {
        await _parser.parseUrl(entry.url.toString());
        if (_cancelFiltering) {
          break;
        }
        if (!mounted) return;
        setState(() {
          entry.hasRecipe = true;
          entry.error = null;
          _successfulFilters++;
          _completedFilters++;
        });
      } on RecipeParseException catch (error) {
        if (!mounted) return;
        setState(() {
          entry.hasRecipe = false;
          entry.error = error.message;
          _completedFilters++;
        });
      } catch (error) {
        if (!mounted) return;
        setState(() {
          entry.hasRecipe = false;
          entry.error = error.toString();
          _completedFilters++;
        });
      }
    }
    if (!mounted) return;
    setState(() {
      _isFiltering = false;
    });
    if (!_cancelFiltering && mounted) {
      final successCount = _successfulFilters;
      final message = successCount > 0
          ? 'Found $successCount recipe page${successCount == 1 ? '' : 's'}.'
          : 'No recipe pages detected.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }
}
