import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:darna/features/delivery/data/repositories/firestore_driver_repository.dart';
import 'package:darna/features/delivery/domain/repositories/driver_repository.dart';

/// Provider for the driver repository
final driverRepositoryProvider = Provider<DriverRepository>((ref) {
  return FirestoreDriverRepository();
});
