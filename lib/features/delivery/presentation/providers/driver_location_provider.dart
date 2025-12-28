import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:darna/features/delivery/presentation/providers/driver_repository_provider.dart';

/// Stream provider for real-time driver location updates
/// Usage: ref.watch(driverLocationStreamProvider(driverId))
final driverLocationStreamProvider = StreamProvider.family<LatLng?, String>((ref, driverId) {
  final repository = ref.watch(driverRepositoryProvider);
  return repository.streamDriverLocation(driverId);
});
