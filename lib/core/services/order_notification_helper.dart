import 'package:darna/core/services/notification_service.dart';

/// Helper class to send notifications for order status changes
class OrderNotificationHelper {
  static final NotificationService _notificationService = NotificationService();

  /// Notify customer when order status changes
  static Future<void> notifyOrderStatusChange({
    required String customerId,
    required String orderId,
    required String status,
    String? driverName,
  }) async {
    String title = '';
    String body = '';

    switch (status) {
      case 'confirmed':
        title = '✅ Order Confirmed';
        body = 'Your order has been confirmed and is being prepared.';
        break;
      case 'preparing':
        title = '👨‍🍳 Preparing Your Order';
        body = 'The restaurant is preparing your delicious meal!';
        break;
      case 'prepared':
        title = '📦 Order Ready';
        body = 'Your order is ready and waiting for pickup.';
        break;
      case 'pickedUp':
        title = '🚗 Driver Picked Up';
        body = driverName != null 
            ? '$driverName has picked up your order and is on the way!'
            : 'Your order is on the way!';
        break;
      case 'delivered':
        title = '🎉 Order Delivered';
        body = 'Your order has been delivered. Enjoy your meal!';
        break;
      default:
        return;
    }

    await _notificationService.sendNotificationToUser(
      userId: customerId,
      title: title,
      body: body,
      data: {'orderId': orderId, 'type': 'order_status'},
    );
  }

  /// Notify driver of new order assignment
  static Future<void> notifyDriverAssignment({
    required String driverId,
    required String orderId,
    required String customerName,
  }) async {
    await _notificationService.sendNotificationToDriver(
      driverId: driverId,
      title: '📦 New Order Assignment',
      body: 'You have a new delivery for $customerName',
      data: {'orderId': orderId, 'type': 'new_assignment'},
    );
  }

  /// Notify driver when order is cancelled
  static Future<void> notifyDriverCancellation({
    required String driverId,
    required String orderId,
  }) async {
    await _notificationService.sendNotificationToDriver(
      driverId: driverId,
      title: '❌ Order Cancelled',
      body: 'The order has been cancelled by the customer',
      data: {'orderId': orderId, 'type': 'cancellation'},
    );
  }

  /// Notify customer when driver is nearby (within 5 minutes)
  static Future<void> notifyDriverNearby({
    required String customerId,
    required String orderId,
    required String driverName,
    required int estimatedMinutes,
  }) async {
    await _notificationService.sendNotificationToUser(
      userId: customerId,
      title: '📍 Driver Nearby',
      body: '$driverName is $estimatedMinutes minutes away!',
      data: {'orderId': orderId, 'type': 'driver_nearby'},
    );
  }
}
