import 'package:data/data.dart';
import 'package:flutter/material.dart';
import 'package:shared_ui/shared_ui.dart';

import '../navigation/app_drawer.dart';

class VisitedDomainsScreen extends StatelessWidget {
  const VisitedDomainsScreen({super.key, this.drawer});

  static const routeName = '/visited-domains';

  final Widget? drawer;

  @override
  Widget build(BuildContext context) {
    final inset = responsivePageInsets(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Visited Domains')),
      drawer: drawer ?? const AppDrawer(currentRoute: VisitedDomainsScreen.routeName),
      body: SafeArea(
        child: StreamBuilder<List<ImportedUrlEntity>>(
          stream: _watchImportedUrls(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final importedUrls = snapshot.data!;
            if (importedUrls.isEmpty) {
              return Center(
                child: Padding(
                  padding: inset,
                  child: const Text('No domains visited yet.'),
                ),
              );
            }

            // Group by domain
            final domainsMap = <String, List<ImportedUrlEntity>>{};
            for (final entity in importedUrls) {
              domainsMap.putIfAbsent(entity.domain, () => []).add(entity);
            }

            final domains = domainsMap.entries.toList()
              ..sort((a, b) {
                // Sort by most recent import first
                final aLatest = a.value.map((e) => e.importedAt).reduce((a, b) => a.isAfter(b) ? a : b);
                final bLatest = b.value.map((e) => e.importedAt).reduce((a, b) => a.isAfter(b) ? a : b);
                return bLatest.compareTo(aLatest);
              });

            return ListView.separated(
              padding: EdgeInsets.fromLTRB(
                inset.left,
                inset.top,
                inset.right,
                inset.bottom,
              ),
              itemCount: domains.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final entry = domains[index];
                final domain = entry.key;
                final urls = entry.value;
                final count = urls.length;
                final latestImport = urls.map((e) => e.importedAt).reduce((a, b) => a.isAfter(b) ? a : b);

                return Card(
                  child: ExpansionTile(
                    leading: const Icon(Icons.public),
                    title: Text(domain),
                    subtitle: Text(
                      '$count page${count == 1 ? '' : 's'} imported',
                    ),
                    trailing: Text(
                      _formatDate(latestImport),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Imported Pages:',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            const SizedBox(height: 8),
                            ...(() {
                              final sorted = urls.toList()
                                ..sort((a, b) => b.importedAt.compareTo(a.importedAt));
                              return sorted.take(10).map((urlEntity) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.link, size: 16),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          urlEntity.url,
                                          style: Theme.of(context).textTheme.bodySmall,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Text(
                                        _formatDate(urlEntity.importedAt),
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                                            ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList();
                            })(),
                            if (urls.length > 10)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  '... and ${urls.length - 10} more',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                                      ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Stream<List<ImportedUrlEntity>> _watchImportedUrls() {
    final listenable = ImportedUrlStore.instance.listenable();
    return Stream<List<ImportedUrlEntity>>.multi((controller) {
      void emit() => controller.add(ImportedUrlStore.instance.getAllImportedUrls());
      emit();
      void listener() => emit();
      listenable.addListener(listener);
      controller.onCancel = () {
        listenable.removeListener(listener);
      };
    });
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks week${weeks == 1 ? '' : 's'} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months == 1 ? '' : 's'} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years year${years == 1 ? '' : 's'} ago';
    }
  }
}

