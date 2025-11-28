import 'package:flutter/material.dart';
import '../services/tour_progress.dart';
import '../services/tour_service.dart';
import '../screens/enhanced_tour_screen.dart';

class TourContinueButton extends StatelessWidget {
  const TourContinueButton({super.key});

  @override
  Widget build(BuildContext context) {
    final progress = TourProgress.instance;
    final canResume = TourService.instance.canResume() ||
        (progress.lastScenario != null && progress.lastStep != null);

    if (!canResume) {
      return const SizedBox.shrink();
    }

    return FloatingActionButton.extended(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => EnhancedTourScreen(
              resumeFromStep: {
                'scenario': progress.lastScenario ?? 1,
                'step': progress.lastStep ?? 0,
              },
            ),
          ),
        );
      },
      icon: const Icon(Icons.play_circle_outline),
      label: const Text('Continue Tour'),
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Theme.of(context).colorScheme.onPrimary,
    );
  }
}



