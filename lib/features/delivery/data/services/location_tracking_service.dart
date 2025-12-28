import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
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
      // 1. Fetch driver data to get activeOrderId
      final driverDoc = await driverRef.get();
      if (!driverDoc.exists) return;

      final data = driverDoc.data();
      final activeOrderId = data?['activeOrderId'] as String?;

      final locationMap = {
        'latitude': position.latitude,
        'longitude': position.longitude,
      };

      // 2. Update Driver Document
      await driverRef.update({
        'currentLocation': locationMap,
        'heading': position.heading,
        'locationUpdatedAt': FieldValue.serverTimestamp(),
      });
      debugPrint('📍 Driver doc updated: $driverId at $locationMap');

      // 3. If Driver has an active order, update the Order document too
      // This allows the Client to track the driver via the Order stream
      if (activeOrderId != null && activeOrderId.isNotEmpty) {
        await _firestore.collection('orders').doc(activeOrderId).update({
          'driverLocation': locationMap,
        });
        debugPrint('✅ Order doc updated: $activeOrderId with driverLocation=$locationMap');
      } else {
        debugPrint('⚠️ No activeOrderId - driver location NOT synced to order');
      }

    } catch (e) {
      debugPrint('Error updating location: $e');
    }
  }
}
