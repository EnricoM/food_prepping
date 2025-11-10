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

class _DomainDiscoveryScreenState extends State<DomainDiscoveryScreen> {
  final _domainController = TextEditingController();
  final _discovery = DomainRecipeDiscovery();
  final _urls = <Uri>[];
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _domainController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inset = responsivePageInsets(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Discover recipes by domain')),
      drawer: widget.drawer ??
          const AppDrawer(currentRoute: DomainDiscoveryScreen.routeName),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: inset,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _domainController,
                decoration: const InputDecoration(
                  labelText: 'Domain (e.g. example.com)',
                  border: OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => _discover(),
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
              if (_urls.isNotEmpty) ...[
                const SizedBox(height: 24),
                Text(
                  '${_urls.length} recipes found',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: _urls.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final url = _urls[index];
                    return Card(
                      child: ListTile(
                        title: Text(url.toString()),
                        trailing: IconButton(
                          icon: const Icon(Icons.open_in_new),
                          onPressed: () =>
                              widget.onRecipeDiscovered(context, url.toString()),
                        ),
                      ),
                    );
                  },
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
    setState(() {
      _isLoading = true;
      _error = null;
      _urls.clear();
    });
    try {
      final urls = await _discovery.discoverRecipes(domain);
      if (!mounted) return;
      setState(() => _urls.addAll(urls));
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = 'Failed to scan domain: $error');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
