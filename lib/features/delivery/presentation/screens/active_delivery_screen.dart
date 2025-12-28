import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:darna/core/theme/app_theme.dart';
import 'package:darna/features/order/domain/entities/order.dart';
import 'package:darna/features/delivery/data/services/route_service.dart';
import 'package:darna/features/delivery/presentation/providers/delivery_providers.dart';
import 'package:geocoding/geocoding.dart';
import 'package:darna/features/delivery/presentation/widgets/instruction_banner.dart';
import 'package:darna/features/delivery/presentation/widgets/navigation_bottom_bar.dart';
import 'package:darna/features/delivery/domain/models/navigation_data.dart';

class ActiveDeliveryScreen extends ConsumerStatefulWidget {
  final Order order;

  const ActiveDeliveryScreen({super.key, required this.order});

  @override
  ConsumerState<ActiveDeliveryScreen> createState() => _ActiveDeliveryScreenState();
}

class _ActiveDeliveryScreenState extends ConsumerState<ActiveDeliveryScreen> {
  GoogleMapController? _mapController;
  // Default to Fes, Morocco
  static const LatLng _center = LatLng(34.0181, -5.0078); 
  
  LatLng? _driverLocation;
  List<LatLng> _routePoints = [];
  NavigationData? _navigationData;
  int _currentStepIndex = 0;
  bool _isFetchingRoute = false;
  bool _isNavigationMode = false; // Toggle between overview and navigation mode

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final order = widget.order;
    
    // Listen to location updates to fetch route and update camera
    ref.listen(driverLocationStreamProvider, (previous, next) {
      next.whenData((location) {
        if (_driverLocation == null || _routePoints.isEmpty) {
             _updateRouteIfNeeded(location, order.deliveryAddress);
        }
        
        setState(() {
          _driverLocation = location;
        });
        
        // Camera behavior depends on mode
        if (_mapController != null) {
          if (_isNavigationMode) {
            // Navigation Mode: Tight zoom, following driver (flat view)
            _mapController!.animateCamera(
              CameraUpdate.newCameraPosition(
                CameraPosition(
                  target: location,
                  zoom: 18.0, // Very close zoom for navigation
                  tilt: 0, // Flat view (no 3D)
                  bearing: 0, // TODO: Use actual heading from location
                ),
              ),
            );
          } else {
            // Overview Mode: Just update marker, don't force zoom
            // (User can manually pan/zoom to see the full route)
          }
        }
      });
    });
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: _isNavigationMode ? null : AppBar(
        title: Text('Active Delivery', style: theme.textTheme.headlineSmall),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          // Main content
          Column(
            children: [
              Expanded(
                flex: _isNavigationMode ? 1 : 3,
                child: _buildMap(_driverLocation, order),
              ),
              
              // Order Details (only in overview mode)
              if (!_isNavigationMode)
                // Order Details & Controls
                Expanded(
                  flex: 4,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                      boxShadow: AppShadows.elevation4,
                    ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Order ID & Status
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Order #${order.id.substring(order.id.length > 6 ? order.id.length - 6 : 0)}',
                          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.primary),
                          ),
                          child: Text(
                            order.status.displayName,
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Customer Info
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.grey,
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Customer Name', // Ideally from order metadata
                                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                order.contactPhone,
                                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.phone, color: AppColors.primary),
                          onPressed: () => launchUrlString('tel:${order.contactPhone}'),
                        ),
                      ],
                    ),
                    
                    const Divider(height: 32),
                    
                    // Delivery Address
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.grey),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            order.deliveryAddress,
                            style: theme.textTheme.bodyLarge,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Start/Stop Navigation Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: Icon(_isNavigationMode ? Icons.stop : Icons.navigation, color: Colors.white),
                        label: Text(_isNavigationMode ? 'Stop Navigation' : 'Start Navigation'),
                        style: ElevatedButton.styleFrom(
                           backgroundColor: _isNavigationMode ? Colors.red : AppColors.primary,
                           foregroundColor: Colors.white,
                           padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () {
                          setState(() {
                            _isNavigationMode = !_isNavigationMode;
                          });
                          
                          // Immediately update camera when entering navigation mode
                          if (_isNavigationMode && _driverLocation != null && _mapController != null) {
                            _mapController!.animateCamera(
                              CameraUpdate.newCameraPosition(
                                CameraPosition(
                                  target: _driverLocation!,
                                  zoom: 18.0,
                                  tilt: 0, // Flat view
                                  bearing: 0,
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.map, color: Colors.white),
                        label: const Text('Open Google Maps (GPS)'),
                        style: ElevatedButton.styleFrom(
                           backgroundColor: Colors.grey[700],
                           foregroundColor: Colors.white,
                           padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () {
                          // Open Google Maps Directions
                          final query = Uri.encodeComponent(order.deliveryAddress);
                          launchUrlString('https://www.google.com/maps/dir/?api=1&destination=$query');
                        },
                      ),
                    ),
                    
                    const Divider(height: 32),
                    
                    // Action Buttons (Status Updates)
                    if (order.status == OrderStatus.preparing || order.status == OrderStatus.confirmed || order.status == OrderStatus.prepared)
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () => _updateStatus(context, widget.order.id, 'pickedUp'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.black,
                          ),
                          child: const Text('Picked Up - Start Delivery'),
                        ),
                      )
                    else if (order.status == OrderStatus.pickedUp)
                        SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () => _updateStatus(context, widget.order.id, 'delivered'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Mark as Delivered'),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            ),
          ],
        ),
          
          // Navigation Mode Overlays
          if (_isNavigationMode && _navigationData != null) ...[
            // Instruction Banner at Top
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              left: 16,
              right: 16,
              child: InstructionBanner(
                instruction: _currentStepIndex < _navigationData!.steps.length
                    ? _stripHtml(_navigationData!.steps[_currentStepIndex].instruction)
                    : 'Continue',
                nextInstruction: _currentStepIndex + 1 < _navigationData!.steps.length
                    ? _stripHtml(_navigationData!.steps[_currentStepIndex + 1].instruction)
                    : null,
              ),
            ),
            
            // Bottom Navigation Bar
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: NavigationBottomBar(
                durationMinutes: _navigationData!.durationMinutes,
                distanceKm: _navigationData!.distanceKm,
                eta: _navigationData!.getEta(),
                onExit: () {
                  setState(() {
                    _isNavigationMode = false;
                  });
                },
              ),
            ),
          ],
        ],
      ),
    );
  }



  void _updateRouteIfNeeded(LatLng driverLoc, String address) {
    if (_isFetchingRoute) return;
    
    // Simple logic: Fetch if no route
    if (_routePoints.isEmpty) {
      _fetchRoute(driverLoc, address);
    }
  }

  Future<void> _fetchRoute(LatLng driverLoc, String address) async {
    setState(() => _isFetchingRoute = true);
    
    LatLng? customerLoc;
    
    // Clean the address by removing phone numbers and extra info
    String cleanAddress = address;
    // Remove anything in parentheses (Phone: XXX)
    cleanAddress = cleanAddress.replaceAll(RegExp(r'\(.*?\)'), '').trim();
    // Remove "Phone:" prefix if it exists
    cleanAddress = cleanAddress.replaceAll(RegExp(r'Phone:.*', caseSensitive: false), '').trim();
    
    print('📍 Original address: $address');
    print('📍 Cleaned address: $cleanAddress');
    
    // First, try to parse as coordinates (lat,lng format)
    try {
      if (cleanAddress.contains(',')) {
          final parts = cleanAddress.split(',');
          // Check if first two parts are numbers
          if (parts.length >= 2) {
            final lat = double.tryParse(parts[0].trim());
            final lng = double.tryParse(parts[1].trim());
            if (lat != null && lng != null && lat.abs() <= 90 && lng.abs() <= 180) {
              customerLoc = LatLng(lat, lng);
              print('📍 ✅ Parsed as coordinates: $customerLoc');
            }
          }
      }
    } catch (e) {
      print('⚠️ Coordinate parsing failed: $e');
    }
    
    // If parsing failed, try geocoding the address string
    if (customerLoc == null && cleanAddress.isNotEmpty) {
      print('📍 Attempting to geocode: "$cleanAddress"');
      try {
        final locations = await locationFromAddress(cleanAddress);
        if (locations.isNotEmpty) {
          customerLoc = LatLng(locations.first.latitude, locations.first.longitude);
          print('📍 ✅ Geocoded to: $customerLoc');
        } else {
          print('📍 ⚠️ Geocoding returned 0 results');
        }
      } catch (e) {
        print('❌ Geocoding error: $e');
      }
    }
    
    // Final fallback
    if (customerLoc == null) {
       print('❌ Using fallback location (Fes center)');
       customerLoc = _center;
    }
    
    // Verify we have different locations
    if (customerLoc.latitude == driverLoc.latitude && 
        customerLoc.longitude == driverLoc.longitude) {
      print('❌ WARNING: Origin and destination are the same! Using offset.');
      // Add small offset to avoid ZERO_RESULTS
      customerLoc = LatLng(customerLoc.latitude + 0.001, customerLoc.longitude + 0.001);
    }

    print('📍 Final - Driver: $driverLoc, Customer: $customerLoc');
    
    final routeService = ref.read(routeServiceProvider);
    final navigationData = await routeService.getRoute(driverLoc, customerLoc);
    
    if (mounted) {
      setState(() {
        _navigationData = navigationData;
        _routePoints = navigationData?.polylinePoints ?? [];
        _isFetchingRoute = false;
        _currentStepIndex = 0; // Reset to first step
      });
      
      if (navigationData == null || _routePoints.isEmpty) {
        print('❌ No route received. Check API key has Directions API enabled!');
      }
    }
  }

  Widget _buildMap(LatLng? driverLoc, Order order) {
     // Parse customer location (Simple mock parsing for now)
    LatLng customerLoc = _center;
    try {
      if (order.deliveryAddress.contains(',')) {
         final parts = order.deliveryAddress.split(',');
         if (parts.length >= 2) {
           final lat = double.tryParse(parts[0].trim());
           final lng = double.tryParse(parts[1].trim());
           if (lat != null && lng != null) {
             customerLoc = LatLng(lat, lng);
           }
         }
      }
    } catch (_) {}

    final Set<Marker> markers = {
      Marker(
        markerId: const MarkerId('customer'),
        position: customerLoc,
        infoWindow: const InfoWindow(title: 'Customer Location'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    };
    
    final Set<Polyline> polylines = {};

    if (driverLoc != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('driver'),
          position: driverLoc,
          infoWindow: const InfoWindow(title: 'My Location'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          rotation: 0, 
        ),
      );
      
      print('🗺️ Building map - Route points in state: ${_routePoints.length}');
      
      if (_routePoints.isNotEmpty) {
        print('🗺️ ✅ Adding polyline with ${_routePoints.length} points');
        print('🗺️ First point: ${_routePoints.first}');
        print('🗺️ Last point: ${_routePoints.last}');
        
        polylines.add(
          Polyline(
            polylineId: const PolylineId('route'),
            points: _routePoints,
            color: AppColors.primary,
            width: 8, // Increased width for visibility
            geodesic: true,
          ),
        );
      } else {
         print('🗺️ ⚠️ Using fallback straight line');
         // Fallback straight line
         polylines.add(
          Polyline(
            polylineId: const PolylineId('route_straight'),
            points: [driverLoc, customerLoc],
            color: AppColors.primary.withOpacity(0.5),
            width: 5,
            patterns: [PatternItem.dash(10), PatternItem.gap(10)],
          ),
        );
      }
    }

    print('🗺️ Total markers: ${markers.length}, Total polylines: ${polylines.length}');

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: driverLoc ?? _center, 
        zoom: 14.0,
      ),
      onMapCreated: (controller) => _mapController = controller,
      markers: markers,
      polylines: polylines,
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
    );
  }

  Future<void> _updateStatus(BuildContext context, String orderId, String status) async {
    final driverRepo = ref.read(driverRepositoryProvider);
    final result = await driverRepo.updateOrderStatus(orderId, status);
    
    result.fold(
      (failure) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${failure.message}')),
          );
        }
      },
      (_) {
        ref.invalidate(activeOrderProvider);
        if (context.mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Order Status Updated: $status')),
          );
          if (status == 'delivered') {
            Navigator.pop(context); // Close screen on delivery completion
          }
        }
      },
    );
  }

  String _stripHtml(String html) {
    return html
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>');
  }
}
