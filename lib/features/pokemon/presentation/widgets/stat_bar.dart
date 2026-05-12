import 'package:flutter/material.dart';
import '../../domain/entities/pokemon_detail.dart';

class StatBar extends StatelessWidget {
  final Stat stat;
  final Color color;

  const StatBar({
    super.key,
    required this.stat,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final maxStat = 255.0;
    final percentage = (stat.value / maxStat).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              stat.name,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 40,
            child: Text(
              stat.value.toString(),
              style: Theme.of(context).textTheme.labelSmall,
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Stack(
              children: [
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOut,
                  height: 8,
                  width: MediaQuery.of(context).size.width * percentage * 0.4,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
