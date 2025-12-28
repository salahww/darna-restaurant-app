import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:darna/core/theme/app_theme.dart';
import 'package:darna/core/theme/moroccan_decorations.dart';
import 'package:flutter_animate/flutter_animate.dart';

class BottomNavItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final int? badgeCount;

  const BottomNavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    this.badgeCount,
  });
}

class AnimatedBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<BottomNavItem> items;

  const AnimatedBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    // Use SafeArea to respect bottom notch/home indicator
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: MoroccanDecorations.cardShadow(elevation: 4),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        child: Container(
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isActive = index == currentIndex;

              return GestureDetector(
                onTap: () {
                    if (!isActive) {
                        HapticFeedback.lightImpact();
                        onTap(index);
                    }
                },
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  padding: EdgeInsets.symmetric(
                    horizontal: isActive ? 16 : 12,
                    vertical: 8,
                  ),
                  decoration: isActive
                      ? BoxDecoration(
                          gradient: AppColors.royalRedGradient,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                             BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            )
                          ],
                        )
                      : null,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Icon(
                            isActive ? item.activeIcon : item.icon,
                            color: isActive ? Colors.white : AppColors.secondaryText,
                            size: 24,
                          ),
                          if (item.badgeCount != null && item.badgeCount! > 0)
                            Positioned(
                              top: -8,
                              right: -8,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  item.badgeCount! > 9 ? '9+' : item.badgeCount.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ).animate(
                                key: ValueKey(item.badgeCount),
                                onPlay: (controller) => controller.forward(from: 0),
                              ).scale(
                                duration: const Duration(milliseconds: 300), 
                                curve: Curves.elasticOut,
                                begin: const Offset(0.5, 0.5),
                                end: const Offset(1, 1),
                              ),
                            ),
                        ],
                      ),
                      if (isActive) ...[
                        const SizedBox(width: 8),
                        Text(
                          item.label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            fontFamily: 'Outfit', 
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
