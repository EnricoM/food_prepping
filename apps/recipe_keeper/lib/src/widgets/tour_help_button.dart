import 'package:flutter/material.dart';
import '../screens/enhanced_tour_screen.dart';

class TourHelpButton extends StatelessWidget {
  const TourHelpButton({
    super.key,
    required this.scenario,
    required this.step,
    this.tooltip = 'Get help',
  });

  final int scenario;
  final int step;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.help_outline),
      tooltip: tooltip,
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => EnhancedTourScreen(
              resumeFromStep: {'scenario': scenario, 'step': step},
            ),
          ),
        );
      },
    );
  }
}



