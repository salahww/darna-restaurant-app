import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationState {
  final String address;
  final LatLng? coordinates;
  final bool isLoading;

  const LocationState({
    this.address = 'Select Location',
    this.coordinates,
    this.isLoading = false,
  });

  LocationState copyWith({
    String? address,
    LatLng? coordinates,
    bool? isLoading,
  }) {
    return LocationState(
      address: address ?? this.address,
      coordinates: coordinates ?? this.coordinates,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class LocationNotifier extends StateNotifier<LocationState> {
  LocationNotifier() : super(
    LocationState(
      address: '',
      coordinates: null,
    ),
  );

  /// Call this after widget is built to avoid ANR
  Future<void> initialize() async {
    await _loadSavedLocation();
  }

  Future<void> _loadSavedLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedAddress = prefs.getString('delivery_address');
      final savedLat = prefs.getDouble('delivery_lat');
      final savedLng = prefs.getDouble('delivery_lng');
      
      if (savedAddress != null && savedLat != null && savedLng != null) {
        state = LocationState(
          address: savedAddress,
          coordinates: LatLng(savedLat, savedLng),
        );
      }
    } catch (e) {
      // Fail gracefully - keep default "Select Location"
    }
  }

  Future<void> setLocation(String address, LatLng? coordinates) async {
    state = state.copyWith(address: address, coordinates: coordinates);
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('delivery_address', address);
    if (coordinates != null) {
      await prefs.setDouble('delivery_lat', coordinates.latitude);
      await prefs.setDouble('delivery_lng', coordinates.longitude);
    }
  }
  
  void setAddress(String address) {
    state = state.copyWith(address: address);
  }
}

final locationProvider = StateNotifierProvider<LocationNotifier, LocationState>((ref) {
  return LocationNotifier();
});
