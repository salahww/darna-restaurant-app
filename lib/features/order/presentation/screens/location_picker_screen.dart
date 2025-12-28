import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:darna/core/theme/app_theme.dart';
import 'package:darna/features/order/presentation/providers/location_provider.dart';
import 'package:darna/features/order/presentation/screens/location_search_screen.dart';

class LocationPickerScreen extends ConsumerStatefulWidget {
  const LocationPickerScreen({super.key});

  @override
  ConsumerState<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends ConsumerState<LocationPickerScreen> {
  GoogleMapController? _controller;
  LatLng _initialPosition = const LatLng(34.0181, -5.0078); // Fes
  LatLng _cameraPosition = const LatLng(34.0181, -5.0078);
  
  String _currentAddress = 'Move map to select location';
  bool _isGeocoding = false;
  // bool _isLoadingLocation = true; // Removed blocking loader

  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _loadSavedLocation(); // Only load saved location (instant!)
    // GPS will only update when user taps "Use Current Location" button
  }

  void _loadSavedLocation() {
    // Get saved location from provider for instant load
    final savedLocation = ref.read(locationProvider);
    if (savedLocation.coordinates != null) {
      _initialPosition = savedLocation.coordinates!;
      _cameraPosition = savedLocation.coordinates!;
      _currentAddress = savedLocation.address;
    }
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location services are disabled')),
        );
      }
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permission denied')),
          );
        }
        return;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permission permanently denied')),
        );
      }
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium, 
        timeLimit: const Duration(seconds: 5)
      );
      
      if (mounted) {
        _controller?.animateCamera(CameraUpdate.newLatLng(
          LatLng(position.latitude, position.longitude)
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not get location')),
        );
      }
    }
  }

  Future<void> _getAddressFromLatLng(LatLng position) async {
    if (_isGeocoding) return; // simple limit
    
    setState(() {
      _isGeocoding = true;
      _currentAddress = 'Locating...';
    });

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        // Construct a nice address string
        // e.g. "Street Name, City"
        String address = '';
        if (place.thoroughfare != null && place.thoroughfare!.isNotEmpty) {
           address += place.thoroughfare!;
        } else if (place.subLocality != null && place.subLocality!.isNotEmpty) {
           address += place.subLocality!;
        } else {
           address += 'Unnamed Road';
        }

        if (place.locality != null && place.locality!.isNotEmpty) {
          if (address.isNotEmpty) address += ', ';
          address += place.locality!;
        }
        
        setState(() {
          _currentAddress = address;
        });
      }
    } catch (e) {
      setState(() {
        _currentAddress = 'Unknown Location';
      });
    } finally {
      setState(() => _isGeocoding = false);
    }
  }

  void _onCameraMove(CameraPosition position) {
    _cameraPosition = position.target;
    // Debounce geocoding calls
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 1500), () {
      if (mounted) _getAddressFromLatLng(_cameraPosition);
    });
  }

  void _confirmLocation() {
    // Save to Provider
    ref.read(locationProvider.notifier).setLocation(_currentAddress, _cameraPosition);
    Navigator.pop(context, _currentAddress);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Stack(
        children: [
          // Map
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _initialPosition,
              zoom: 15,
            ),
            onMapCreated: (controller) => _controller = controller,
            myLocationEnabled: true,
            myLocationButtonEnabled: false, // We'll make a custom one or rely on auto
            zoomControlsEnabled: false,
            onCameraMove: _onCameraMove,
            onCameraIdle: () {
               // Triggered when movement stops
               // We rely on the debounce timer from _onCameraMove to fetch the address
               // to avoid rapid API calls or UI freezes during rapid movements.
            },
          ),
          
          // Center Pin
          Center(
             child: Padding(
               padding: const EdgeInsets.only(bottom: 40),
               child: Icon(
                 Icons.location_on,
                 color: AppColors.primary,
                 size: 50,
               ),
             ),
          ),
          
          // Back Button
          Positioned(
            top: 50,
            left: 20,
            child: CircleAvatar(
              backgroundColor: theme.colorScheme.surface,
              child: IconButton(
                icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
          
          // Floating Address Card (Top)
          Positioned(
            top: 100, // Below back button
            left: 20,
            right: 20,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: AppShadows.elevation2,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_isGeocoding)
                      const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    else
                      Icon(Icons.pedal_bike, color: theme.colorScheme.onSurfaceVariant, size: 20),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        _currentAddress,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Use this point',
                      style: TextStyle(
                        color: AppColors.deepTeal,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // My Location Button
          Positioned(
            right: 20,
            bottom: 220, 
            child: FloatingActionButton(
              backgroundColor: theme.colorScheme.surface,
              onPressed: _determinePosition,
              child: Icon(Icons.my_location, color: theme.colorScheme.onSurface),
            ),
          ),
          
          // Bottom Sheet / Action Area
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 20)],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Confirm Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _confirmLocation,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.richGold,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text(
                        'Confirm Location',
                        style: TextStyle(
                          color: AppColors.charcoal,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Search Bar
                  GestureDetector(
                    onTap: () async {
                      // Navigate to full screen search
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LocationSearchScreen(),
                        ),
                      );
                      
                      if (result != null && result is Location) {
                         // Update Map
                         final latLng = LatLng(result.latitude, result.longitude);
                         _controller?.animateCamera(CameraUpdate.newLatLngZoom(latLng, 16));
                         _getAddressFromLatLng(latLng);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search, color: Colors.grey),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Search street, city...',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          
          // if (_isLoadingLocation) ... removed
        ],
      ),
    );
  }
}
