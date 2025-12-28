import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:darna/core/theme/app_theme.dart';
import 'package:darna/features/delivery/presentation/widgets/high_glance_instruction_card.dart';

/// Delivery Dashboard Overlay for Motorbike Navigation Mode
/// Optimized for: sunlight glare, gloves, speed reading
class DeliveryDashboardOverlay extends StatelessWidget {
  final String instruction;
  final String? distance;
  final String? roadName;
  final int etaMinutes;
  final double distanceKm;
  final String eta;
  final VoidCallback onArrived;
  final VoidCallback onRecenter;
  final VoidCallback onExit;
  final bool isNightMode;
  final bool showArrivedButton;

  const DeliveryDashboardOverlay({
    super.key,
    required this.instruction,
    this.distance,
    this.roadName,
    required this.etaMinutes,
    required this.distanceKm,
    required this.eta,
    required this.onArrived,
    required this.onRecenter,
    required this.onExit,
    this.isNightMode = false,
    this.showArrivedButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Top instruction card removed as requested
        // Arrived button removed as requested

        // Bottom: Action Bar only
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: _buildActionBar(context),
        ),
      ],
    );
  }

  /// Massive 80x80dp button - easy to tap with gloves
  Widget _buildArrivedButton() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.heavyImpact(); // Strong haptic for glove feedback
        onArrived();
      },
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2ECC71), Color(0xFF27AE60)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 4),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2ECC71).withOpacity(0.5),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: const Icon(
          Icons.check,
          color: Colors.white,
          size: 48,
        ),
      ),
    );
  }

  Widget _buildActionBar(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: isNightMode ? const Color(0xFF1A1A1A) : const Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // ETA Info
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '$etaMinutes min',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: Color(0xFF2ECC71),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${distanceKm.toStringAsFixed(1)} km · $eta',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            // Recenter Button (56dp - glove friendly)
            Container(
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                shape: BoxShape.circle,
              ),
              child: IconButton(
                iconSize: 28,
                padding: const EdgeInsets.all(14),
                icon: const Icon(Icons.my_location, color: Colors.white),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  onRecenter();
                },
              ),
            ),

            // Exit Button (Large, obvious)
            ElevatedButton(
              onPressed: () {
                HapticFeedback.mediumImpact();
                onExit();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Exit',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
