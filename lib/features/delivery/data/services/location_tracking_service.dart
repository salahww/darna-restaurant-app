import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationTrackingService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  StreamSubscription<Position>? _positionSubscription;

  LocationTrackingService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;
        
  /// Expose location stream for UI (e.g. Navigation)
  Stream<LatLng> get locationStream {
    // Basic settings for UI updates
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, 
    );
    return Geolocator.getPositionStream(locationSettings: locationSettings)
        .map((p) => LatLng(p.latitude, p.longitude));
  }

  /// Manually fetch current location (one-shot)
  Future<LatLng?> getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      return LatLng(position.latitude, position.longitude);
    } catch (e) {
      // Return null instead of throwing, let UI handle it
      return null;
    }
  }

  /// Starts tracking the driver's location and updates Firestore.
  /// Returns flase if permissions are denied.
  Future<bool> startTracking() async {
    final user = _auth.currentUser;
    if (user == null) return false;

    // 1. Check Permissions
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    // 2. Start Stream
    // Use low interval to save battery, e.g., 10 seconds or 50 meters
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 20, // Only update if moved 20 meters
    );

    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((Position position) {
      _updateLocationInFirestore(user.uid, position);
    });

    return true;
  }

  /// Stops tracking location.
  Future<void> stopTracking() async {
    await _positionSubscription?.cancel();
    _positionSubscription = null;
  }

  /// Updates driver location in Firestore.
  Future<void> _updateLocationInFirestore(String driverId, Position position) async {
    try {
      final GeoPoint geoPoint = GeoPoint(position.latitude, position.longitude);
      final driverRef = _firestore.collection('drivers').doc(driverId);

      // 1. Update Driver Document
      // We also update 'lastUpdated' to detect stale drivers
      await driverRef.update({
        'currentLocation': {
          'latitude': position.latitude,
          'longitude': position.longitude,
        },
        'heading': position.heading,
        'locationUpdatedAt': FieldValue.serverTimestamp(),
      });

      // 2. Check for active order and update it too (optional but requested in plan)
      // Reading the driver doc to get activeOrderId every time might be expensive/slow.
      // Optimisation: We could assume the UI handles the "State" of active order, 
      // but the background service usually runs independently.
      // For now, let's just do a quick check via transaction or just a get.
      // A lighter way is to just query orders where driverId == driverId AND status == 'outForDelivery'
      final activeOrdersQuery = await _firestore
          .collection('orders')
          .where('driverId', isEqualTo: driverId)
          .where('status', isEqualTo: 'outForDelivery') // Only update if out for delivery
          .limit(1)
          .get();

      if (activeOrdersQuery.docs.isNotEmpty) {
        final orderDoc = activeOrdersQuery.docs.first;
        await orderDoc.reference.update({
          'driverLocation': {
            'latitude': position.latitude,
            'longitude': position.longitude,
          },
        });
      }

    } catch (e) {
      // print('Error updating location: $e'); // Use a logger in production
    }
  }
}
