import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:parsing/parsing.dart';
import 'package:shared_ui/shared_ui.dart';
import 'package:core/core.dart';
import 'package:data/data.dart';

import '../navigation/app_drawer.dart';
import '../widgets/back_aware_app_bar.dart';

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
  RecipeParseResult? result;
}

class _DomainDiscoveryScreenState extends State<DomainDiscoveryScreen> {
  final _domainController = TextEditingController();
  final _discovery = DomainRecipeDiscovery();
  final _parser = RecipeParser();
  final List<_DiscoveredUrl> _results = [];
  final Set<Uri> _selectedUrls = {};
  Future<void>? _filterTask;
  bool _cancelFiltering = false;
  int _completedFilters = 0;
  int _successfulFilters = 0;
  bool _isAdding = false;
  bool _isLoading = false;
  bool _isFiltering = false;
  String? _error;
  bool _initializedFromArgs = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initializedFromArgs) {
      return;
    }
    _initializedFromArgs = true;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is String) {
      final trimmed = args.trim();
      if (trimmed.isNotEmpty) {
        _domainController.text = trimmed;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _discover();
          }
        });
      }
    }
  }

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
    final successUrls = successfulResults.map((entry) => entry.url).toSet();
    _selectedUrls.removeWhere((url) => !successUrls.contains(url));
    final hasSelection = _selectedUrls.isNotEmpty;
    return Scaffold(
      appBar:
          const BackAwareAppBar(title: Text('Discover recipes by domain')),
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
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.paste),
                        tooltip: 'Paste domain',
                        onPressed: _pasteDomainFromClipboard,
                      ),
                      if (_domainController.text.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.clear),
                          tooltip: 'Clear domain',
                          onPressed: _clearDomainInput,
                        ),
                    ],
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
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: successUrls.isEmpty
                        ? null
                        : () {
                            setState(() {
                              _selectedUrls
                                ..clear()
                                ..addAll(successUrls);
                            });
                          },
                    icon: const Icon(Icons.done_all),
                    label: const Text('Select all'),
                  ),
                  OutlinedButton.icon(
                    onPressed: hasSelection
                        ? () {
                            setState(_selectedUrls.clear);
                          }
                        : null,
                    icon: const Icon(Icons.clear_all),
                    label: const Text('Clear selection'),
                  ),
                  FilledButton.icon(
                    onPressed:
                        hasSelection && !_isAdding ? _addSelectedToLibrary : null,
                    icon: _isAdding
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.library_add),
                    label: Text(
                      _isAdding
                          ? 'Adding...'
                          : 'Add ${_selectedUrls.length} selected',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: successfulResults.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final entry = successfulResults[index];
                  final url = entry.url;
                  final selected = _selectedUrls.contains(url);
                  return Card(
                    child: CheckboxListTile(
                      value: selected,
                      onChanged: (value) {
                        setState(() {
                          if (value == true) {
                            _selectedUrls.add(url);
                          } else {
                            _selectedUrls.remove(url);
                          }
                        });
                      },
                      title: Text(url.toString()),
                      subtitle: const Text('Tap the icon to parse now'),
                      secondary: IconButton(
                        icon: const Icon(Icons.open_in_new),
                        tooltip: 'Open in parser',
                        onPressed: () => widget.onRecipeDiscovered(
                          context,
                          url.toString(),
                        ),
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
      _selectedUrls.clear();
    });
    try {
      final urls = await _discovery.discoverRecipes(domain, maxUrls: 750);
      if (!mounted) return;
      
      // Normalize domain for lookup (extract host from domain input)
      String normalizedDomain;
      try {
        var domainInput = domain.trim();
        if (!domainInput.startsWith('http')) {
          domainInput = 'https://$domainInput';
        }
        final uri = Uri.parse(domainInput);
        normalizedDomain = uri.host.toLowerCase();
        // Remove www. prefix for consistency
        if (normalizedDomain.startsWith('www.')) {
          normalizedDomain = normalizedDomain.substring(4);
        }
      } catch (_) {
        normalizedDomain = domain.toLowerCase();
      }
      
      // Filter out already imported URLs
      final importedUrls = ImportedUrlStore.instance.getImportedUrlsForDomain(normalizedDomain);
      final importedUrlsSet = importedUrls.map((url) {
        // Normalize for comparison
        String normalized = url.trim();
        if (!normalized.startsWith('http://') && !normalized.startsWith('https://')) {
          normalized = 'https://$normalized';
        }
        return normalized;
      }).toSet();
      
      final newUrls = urls.where((url) {
        final urlString = url.toString();
        String normalized = urlString.trim();
        if (!normalized.startsWith('http://') && !normalized.startsWith('https://')) {
          normalized = 'https://$normalized';
        }
        return !importedUrlsSet.contains(normalized) && 
               !importedUrls.contains(urlString);
      }).toList();
      final skippedCount = urls.length - newUrls.length;
      
      setState(() {
        _isLoading = false;
        _results.addAll(newUrls.map(_DiscoveredUrl.new));
      });
      
      if (newUrls.isEmpty) {
        final message = skippedCount > 0
            ? 'All pages from this domain have already been imported ($skippedCount skipped).'
            : 'No pages found for this domain.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
        return;
      }
      
      if (skippedCount > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Skipped $skippedCount already imported page${skippedCount == 1 ? '' : 's'}.'),
            duration: const Duration(seconds: 3),
          ),
        );
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
        final parseResult = await _parser.parseUrl(entry.url.toString());
        if (_cancelFiltering) {
          break;
        }
        if (!mounted) return;
        setState(() {
          entry.hasRecipe = true;
          entry.error = null;
          entry.result = parseResult;
          _successfulFilters++;
          _completedFilters++;
        });
      } on RecipeParseException catch (error) {
        if (!mounted) return;
        setState(() {
          entry.hasRecipe = false;
          entry.error = error.message;
          entry.result = null;
          _selectedUrls.remove(entry.url);
          _completedFilters++;
        });
      } catch (error) {
        if (!mounted) return;
        setState(() {
          entry.hasRecipe = false;
          entry.error = error.toString();
          entry.result = null;
          _selectedUrls.remove(entry.url);
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

  Future<void> _addSelectedToLibrary() async {
    if (_selectedUrls.isEmpty || _isAdding) {
      return;
    }
    setState(() {
      _isAdding = true;
    });
    final messenger = ScaffoldMessenger.of(context);
    int successCount = 0;
    final failedUrls = <Uri>[];
    for (final url in _selectedUrls.toList()) {
      _DiscoveredUrl entry;
      try {
        entry = _results.firstWhere((element) => element.url == url);
      } catch (_) {
        failedUrls.add(url);
        continue;
      }
      try {
        final result = entry.result ?? await _parser.parseUrl(url.toString());
        entry.result ??= result;
        entry.hasRecipe = true;
        await AppRepositories.instance.recipes.saveParsedRecipe(
          result: result,
          url: url.toString(),
        );
        successCount++;
      } catch (error) {
        failedUrls.add(url);
      }
    }
    if (!mounted) return;
    setState(() {
      _isAdding = false;
      _selectedUrls.removeWhere(failedUrls.contains);
    });
    if (successCount > 0) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Saved $successCount recipe${successCount == 1 ? '' : 's'} to your library.'),
        ),
      );
    }
    if (failedUrls.isNotEmpty) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'Failed to save ${failedUrls.length} URL${failedUrls.length == 1 ? '' : 's'}.',
          ),
        ),
      );
    }
  }

  void _clearDomainInput() {
    _cancelFiltering = true;
    setState(() {
      _domainController.clear();
      _results.clear();
      _selectedUrls.clear();
      _isFiltering = false;
      _completedFilters = 0;
      _successfulFilters = 0;
      _error = null;
    });
  }

  Future<void> _pasteDomainFromClipboard() async {
    _clearDomainInput();
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (!mounted) return;
    final text = data?.text?.trim();
    if (text == null || text.isEmpty) {
      return;
    }
    setState(() {
      _domainController.text = text;
      _domainController.selection =
          TextSelection.collapsed(offset: _domainController.text.length);
    });
  }
}
