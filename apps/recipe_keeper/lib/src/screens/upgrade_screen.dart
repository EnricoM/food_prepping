import 'package:flutter/material.dart';

import '../services/subscription_service.dart';
import '../widgets/back_aware_app_bar.dart';

class UpgradeScreen extends StatelessWidget {
  const UpgradeScreen({super.key});
  static const routeName = '/upgrade';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: BackAwareAppBar(title: const Text('Go Premium')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Cook smarter. No ads. Unlimited scans.',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Upgrade to unlock unlimited domain scans, remove ads, and enable smart conversions, translation, planning, and exports.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 20),
            const _Bullet(icon: Icons.speed, text: 'Unlimited scans & faster discovery'),
            const _Bullet(icon: Icons.block, text: 'No ads'),
            const _Bullet(icon: Icons.straighten, text: 'Smart conversions + translate'),
            const _Bullet(icon: Icons.event_note, text: 'Meal planner & PDF export'),
            const Spacer(),
            FilledButton(
              onPressed: () {
                SubscriptionService.instance.setPremium(true);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Premium unlocked')),
                );
              },
              child: const Text('Start 7‑day free trial'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Continue with Free'),
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

