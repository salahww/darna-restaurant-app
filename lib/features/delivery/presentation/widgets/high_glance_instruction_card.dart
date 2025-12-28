import 'package:flutter/material.dart';
import 'package:darna/core/theme/app_theme.dart';

/// High-glance instruction card optimized for motorbike delivery drivers
/// - Large fonts (28sp+ for instructions, 48sp for distance)
/// - High contrast colors
/// - Readable in <0.5 seconds
class HighGlanceInstructionCard extends StatelessWidget {
  final String instruction;
  final String? distance;
  final String? roadName;
  final bool isNightMode;

  const HighGlanceInstructionCard({
    super.key,
    required this.instruction,
    this.distance,
    this.roadName,
    this.isNightMode = false,
  });

  @override
  Widget build(BuildContext context) {
    // Extract action and road from instruction
    final lines = instruction.split('\n');
    final action = lines.isNotEmpty ? lines[0] : instruction;
    final road = lines.length > 1 ? lines[1] : roadName;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isNightMode ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary,
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Distance (HUGE - 48sp)
          if (distance != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                distance!,
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                  letterSpacing: -2,
                ),
              ),
            ),
            const SizedBox(width: 20),
          ],
          
          // Instruction (28sp Bold)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  action,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: isNightMode ? Colors.white : Colors.black,
                    height: 1.1,
                  ),
                ),
                if (road != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    road,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: isNightMode ? Colors.grey[400] : Colors.grey[700],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
