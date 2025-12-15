import 'package:flutter/material.dart';

import '../../i18n/strings.g.dart';
import '../services/subscription_service.dart';
import '../widgets/back_aware_app_bar.dart';

class UpgradeScreen extends StatelessWidget {
  const UpgradeScreen({super.key});
  static const routeName = '/upgrade';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: BackAwareAppBar(title: Text(context.t.upgrade.title)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              context.t.upgrade.tagline,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              context.t.upgrade.description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 20),
            _Bullet(icon: Icons.speed, text: context.t.upgrade.unlimitedScans),
            _Bullet(icon: Icons.block, text: context.t.upgrade.noAds),
            _Bullet(icon: Icons.straighten, text: context.t.upgrade.smartConversions),
            _Bullet(icon: Icons.event_note, text: context.t.upgrade.mealPlanner),
            const Spacer(),
            FilledButton(
              onPressed: () {
                SubscriptionService.instance.setPremium(true);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(context.t.upgrade.premiumUnlocked)),
                );
              },
              child: Text(context.t.upgrade.startTrial),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(context.t.upgrade.continueFree),
            ),
          ],
        ),
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet({required this.icon, required this.text});
  final IconData icon;
  final String text;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

