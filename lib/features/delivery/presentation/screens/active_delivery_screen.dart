import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:geolocator/geolocator.dart';
import 'package:darna/core/theme/app_theme.dart';
import 'package:darna/core/theme/map_styles.dart';
import 'package:darna/features/order/domain/entities/order.dart';
import 'package:darna/features/delivery/data/services/route_service.dart';
import 'package:darna/features/delivery/presentation/providers/delivery_providers.dart';
import 'package:geocoding/geocoding.dart';
import 'package:darna/features/delivery/presentation/widgets/delivery_dashboard_overlay.dart';
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
  double _distanceToNextStepMeters = 0.0; // Real-time distance tracking
  double _currentSpeedMps = 0.0; // Current speed in meters per second
  bool _isNightMode = false; // Day/Night mode tracking

  // Local status for instant UI feedback
  late OrderStatus _localStatus;

  @override
  void initState() {
    super.initState();
    _localStatus = widget.order.status;
    _loadScooterMarker(); // Load custom scooter marker
    _isNightMode = MapStyles.isNightTime(); // Check day/night on init
  }

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
        
        // Update location and recalculate distance
        _driverLocation = location;
        _updateDistanceToNextStep(); // Calculate distance first
        
        // Then trigger UI rebuild with updated values
        setState(() {});
        
        // Camera behavior depends on mode
        if (_mapController != null && _isNavigationMode) {
          // Navigation Mode: Smart camera with 45° tilt and speed-based zoom
          _updateSmartCamera(location, _currentSpeedMps, _driverHeading);
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
                        onPressed: () async {
                          final newMode = !_isNavigationMode;
                          setState(() {
                            _isNavigationMode = newMode;
                          });
                          
                          if (newMode) {
                            // Ensure we have a valid driver location
                            if (_driverLocation == null) {
                               debugPrint('📍 Navigation started but location is null. Fetching...');
                               try {
                                 final loc = await ref.read(locationTrackingServiceProvider).getCurrentLocation();
                                 if (loc != null && mounted) {
                                   setState(() => _driverLocation = loc);
                                   debugPrint('📍 ✅ Location fetched manually: $loc');
                                 }
                               } catch (e) {
                                 debugPrint('📍 ❌ Error fetching manual location: $e');
                               }
                            }

                            // Now try to fetch route
                            if (_navigationData == null) {
                               if (_driverLocation != null) {
                                  _fetchRoute(_driverLocation!, order.deliveryAddress);
                               } else if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Waiting for GPS signal to calculate route...'),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                               }
                            }
                          
                            // Update camera if possible
                            if (_driverLocation != null && _mapController != null) {
                              _mapController!.animateCamera(
                                CameraUpdate.newCameraPosition(
                                  CameraPosition(
                                    target: _driverLocation!,
                                    zoom: 19.0,
                                    tilt: 0, // Flat 2D view
                                    bearing: 0,
                                  ),
                                ),
                              );
                            }
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
                    if (_localStatus == OrderStatus.preparing || _localStatus == OrderStatus.confirmed || _localStatus == OrderStatus.prepared)
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () => _updateStatus(context, widget.order.id, 'pickedUp'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Picked Up - Start Delivery'),
                        ),
                      )
                    else if (_localStatus == OrderStatus.pickedUp)
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
            // Navigation Mode Overlays
            if (_isNavigationMode) ...[
                // Exit Button
                // Standalone Back Button removed (integrated into success view or error view below)


                // Case 1: Fetching Route
                if (_isFetchingRoute)
                  const Positioned(
                    top: 120, // Below header area
                    left: 20, 
                    right: 20,
                    child: Center(
                      child: Card(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 16),
                              Text('Calculating optimized route...'),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                // Case 2: Error (No Data & Not Fetching)
                else if (_navigationData == null)
                  Positioned(
                    top: 120,
                    left: 20,
                    right: 20,
                    child: Card(
                       color: Colors.red[50], // Error background
                       child: Padding(
                         padding: const EdgeInsets.all(16.0),
                         child: Column(
                           mainAxisSize: MainAxisSize.min,
                           children: [
                               const Icon(Icons.error_outline, color: Colors.red, size: 48),
                               const SizedBox(height: 8),
                               const Text(
                                 'Unable to calculate route',
                                 style: TextStyle(fontWeight: FontWeight.bold),
                               ),
                               const Text('Please check internet or location'),
                               const SizedBox(height: 16),
                               ElevatedButton.icon(
                                 onPressed: () {
                                    if (_driverLocation != null) {
                                      _fetchRoute(_driverLocation!, widget.order.deliveryAddress);
                                    }
                                 },
                                 icon: const Icon(Icons.refresh),
                                 label: const Text('Retry'),
                               )
                           ],
                         ),
                       ),
                    ),
                  )
                // Case 3: Success (Data Available)
                // Case 3: Success (Data Available)
                else if (_navigationData != null) ...[
                    // Navigation Dashboard Overlay (High-Glance UI)
                    DeliveryDashboardOverlay(
                      instruction: _currentStepIndex < _navigationData!.steps.length
                          ? _simplifyInstruction(_navigationData!.steps[_currentStepIndex].htmlInstruction)
                          : 'CONTINUE',
                      distance: _distanceToNextStepMeters > 0 
                          ? _formatDistance(_distanceToNextStepMeters)
                          : null,
                      etaMinutes: _navigationData!.durationMinutes,
                      distanceKm: _navigationData!.distanceKm,
                      eta: _navigationData!.getEta(),
                      isNightMode: _isNightMode,
                      showArrivedButton: _localStatus == OrderStatus.pickedUp,
                      onArrived: () {
                        // Mark as delivered
                        _updateStatus(context, order.id, 'delivered');
                      },
                      onRecenter: () {
                        if (_driverLocation != null && _mapController != null) {
                          _updateSmartCamera(_driverLocation!, _currentSpeedMps, _driverHeading);
                        }
                      },
                      onExit: () {
                        setState(() {
                          _isNavigationMode = false;
                        });
                      },
                    ),
                ],
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

  BitmapDescriptor? _scooterMarker;
  double _driverHeading = 0.0;

  /// Load custom scooter marker from SVG asset
  Future<void> _loadScooterMarker() async {
    try {
      // Try to load PNG first (more reliable)
      _scooterMarker = await BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(64, 64)),
        'assets/images/navigation/scooter_marker.png',
      );
      debugPrint('🛵 ✅ Scooter PNG marker loaded');
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('🛵 ⚠️ PNG failed, using default red marker: $e');
      // Fallback to default red marker
      _scooterMarker = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
      if (mounted) setState(() {});
    }
  }

  /// Calculate zoom level based on current speed
  double _calculateZoomForSpeed(double speedKmh) {
    if (speedKmh < 5) {
      return 19.0; // Stopped/slow - maximum detail
    } else if (speedKmh < 20) {
      return 18.0; // City slow traffic
    } else if (speedKmh < 40) {
      return 17.0; // Normal city driving
    } else if (speedKmh < 60) {
      return 16.0; // Fast city/suburban
    } else {
      return 15.0; // Highway - see far ahead
    }
  }

  /// Update camera with smart zoom and 45° tilt
  void _updateSmartCamera(LatLng location, double speedMps, double heading) {
    if (_mapController == null || !_isNavigationMode) return;
    
    final speedKmh = speedMps * 3.6;
    final targetZoom = _calculateZoomForSpeed(speedKmh);
    
    _mapController!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: location,
          zoom: targetZoom,
          tilt: 45, // 2.5D perspective for road-ahead view
          bearing: heading, // Rotate map with driver direction
        ),
      ),
    );
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
          icon: _scooterMarker ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          rotation: _driverHeading, // Rotate with GPS heading
          anchor: const Offset(0.5, 0.5), // Center the marker
          flat: true, // Flat against map surface
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
            width: 10, // Premium thickness
            geodesic: true,
            startCap: Cap.roundCap, // Smooth rounded ends
            endCap: Cap.roundCap,
            jointType: JointType.round, // Smooth corners
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
      onMapCreated: (controller) {
        _mapController = controller;
        // Apply custom map style for navigation
        controller.setMapStyle(_getMapStyle());
      },
      markers: markers,
      polylines: polylines,
      myLocationEnabled: false, // Disabled - we show our own driver marker
      myLocationButtonEnabled: false, // Hide default button (we have custom recenter)
    );
  }

  // Custom map styling using MapStyles for day/night modes
  String _getMapStyle() {
    return _isNightMode ? MapStyles.nightStyle : MapStyles.dayStyle;
  }

  Future<void> _updateStatus(BuildContext context, String orderId, String status) async {
    // Optimistic Update: Update UI immediately
    setState(() {
       if (status == 'pickedUp') {
         _localStatus = OrderStatus.pickedUp;
       } else if (status == 'delivered') {
         _localStatus = OrderStatus.delivered;
       }
    });

    try {
      final driverRepo = ref.read(driverRepositoryProvider);
      await driverRepo.updateOrderStatus(orderId, status);
      
      // Invalidate providers to ensure global state consistency eventually
      ref.invalidate(activeOrderProvider);
      
      if (status == 'delivered') {
        ref.invalidate(driverStatsProvider);
        ref.invalidate(pendingOrdersProvider);
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order Status Updated: $status'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 1),
          ),
        );
        
        if (status == 'delivered') {
           Navigator.pop(context); // Return to dashboard
        }
      }
    } catch (e) {
      if (mounted) {
        // Revert local state on error
        setState(() {
          _localStatus = widget.order.status;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating status: $e')),
        );
      }
    }
  }

  /// Calculate distance from current location to next navigation step
  void _updateDistanceToNextStep() {
    if (_driverLocation != null && 
        _navigationData != null && 
        _currentStepIndex < _navigationData!.steps.length) {
      final nextStep = _navigationData!.steps[_currentStepIndex];
      _distanceToNextStepMeters = Geolocator.distanceBetween(
        _driverLocation!.latitude,
        _driverLocation!.longitude,
        nextStep.endLocation.latitude,
        nextStep.endLocation.longitude,
      );
      
      debugPrint('📏 Distance to next step: ${_distanceToNextStepMeters.round()}m');
      
      // Auto-advance to next step if within 20 meters
      if (_distanceToNextStepMeters < 20 && _currentStepIndex < _navigationData!.steps.length - 1) {
        setState(() {
          _currentStepIndex++;
        });
        debugPrint('🗺️ Auto-advanced to step ${_currentStepIndex + 1}');
      }
    } else {
      _distanceToNextStepMeters = 0.0;
      debugPrint('📏 Distance calc skipped: driver=${_driverLocation != null}, nav=${_navigationData != null}, step=$_currentStepIndex');
    }
  }

  /// Simplify verbose navigation instruction text
  String _simplifyInstruction(String htmlInstruction) {
    // 1. Strip HTML tags
    String text = _stripHtml(htmlInstruction);
    
    // 2. Extract core action (first significant phrase)
    final actionPatterns = [
      RegExp(r'^(Head\s+\w+)'),
      RegExp(r'^(Turn\s+(?:left|right|slight\s+left|slight\s+right))'),
      RegExp(r'^(Exit\s+(?:the\s+)?roundabout)'),
      RegExp(r'^(Continue\s+(?:on|onto|straight))'),
      RegExp(r'^(Keep\s+(?:left|right))'),
    ];
    
    String action = text;
    for (final pattern in actionPatterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        action = match.group(1)!;
        break;
      }
    }
    
    // 3. Extract road name (after "on" or "onto")
    String? roadName;
    final roadPattern = RegExp(r'(?:on|onto)\s+([^/,\.]+?)(?:\s+(?:toward|Go|,)|$)', caseSensitive: false);
    final roadMatch = roadPattern.firstMatch(text);
    if (roadMatch != null) {
      roadName = roadMatch.group(1)?.trim();
      // Simplify: use shortest part if slash exists
      if (roadName != null && roadName.contains('/')) {
        final parts = roadName.split('/');
        roadName = parts.reduce((a, b) => a.length < b.length ? a : b).trim();
      }
    }
    
    return action.toUpperCase() + (roadName != null ? '\n$roadName' : '');
  }

  String _formatDistance(double meters) {
    if (meters < 100) {
      return '${meters.round()} m';
    } else if (meters < 1000) {
      return '${(meters / 100).round() * 100} m';
    } else {
      return '${(meters / 1000).toStringAsFixed(1)} km';
    }
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
