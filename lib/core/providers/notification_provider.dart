import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:darna/core/services/notification_service.dart';

/// Provider for notification service
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

/// Provider to initialize notifications on app start
final notificationInitProvider = FutureProvider<void>((ref) async {
  final notificationService = ref.read(notificationServiceProvider);
  await notificationService.initialize();
});
