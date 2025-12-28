import 'dart:async';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:darna/core/theme/app_theme.dart';
import 'package:darna/features/order/domain/entities/order.dart';
import 'package:darna/features/order/presentation/providers/order_tracking_provider.dart';
import 'package:darna/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:darna/features/delivery/presentation/providers/delivery_providers.dart';
import 'package:darna/features/delivery/data/services/route_service.dart';

class OrderTrackingScreen extends ConsumerStatefulWidget {
  final OrderEntity order;
  const OrderTrackingScreen({super.key, required this.order});

  @override
  ConsumerState<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends ConsumerState<OrderTrackingScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  GoogleMapController? _mapController;
  
  // Real Location: Fes City Center (Instance variable for Hot Reload updates)
  final LatLng _restaurantLocation = const LatLng(34.0331, -5.0003); 
  
  LatLng? _userLocation;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  BitmapDescriptor? _driverIcon;
  List<LatLng> _routePoints = [];
  bool _isLoadingRoute = false;
  double _currentZoom = 14.0;

  @override
  void initState() {
    super.initState();
    _loadDriverIcon();
    _parseUserLocation();
  }

  // Calculate icon size based on zoom level (12-18 typical range)
  double _getIconSize() {
    // Base size 85px, scales with zoom
    // Zoom 12: 65px, Zoom 14: 85px, Zoom 16: 105px, Zoom 18: 125px
    final size = 65 + (_currentZoom - 12) * 10;
    return size.clamp(65.0, 125.0);
  }

  Future<void> _loadDriverIcon() async {
    try {
      final size = _getIconSize();
      
      // Load the image asset
      final ByteData data = await rootBundle.load('assets/images/navigation/scooter_marker.png');
      final Uint8List bytes = data.buffer.asUint8List();
      
      // Decode and resize the image
      final ui.Codec codec = await ui.instantiateImageCodec(
        bytes,
        targetWidth: size.toInt(),
        targetHeight: size.toInt(),
      );
      final ui.FrameInfo frameInfo = await codec.getNextFrame();
      final ui.Image image = frameInfo.image;
      
      // Convert back to bytes
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List resizedBytes = byteData!.buffer.asUint8List();
      
      // Create bitmap descriptor from resized bytes
      final icon = BitmapDescriptor.fromBytes(resizedBytes);
      
      setState(() {
        _driverIcon = icon;
      });
      if (mounted) _updateMarkers(widget.order); 
    } catch (e) {
      debugPrint('Error loading driver icon: $e');
    }
  }

  Future<void> _fetchRoute(LatLng driverPos, LatLng destination) async {
    if (_isLoadingRoute) return;
    
    setState(() => _isLoadingRoute = true);
    
    try {
      debugPrint('📍 Requesting Route: $driverPos -> $destination');
      final routeService = ref.read(routeServiceProvider);
      final navData = await routeService.getRoute(driverPos, destination);
      
      if (!mounted) return;

      if (navData != null) {
        debugPrint('✅ Route Received: ${navData.polylinePoints.length} pts');
        setState(() {
          _routePoints = navData.polylinePoints;
          _isLoadingRoute = false;
          _updateMarkers(widget.order); 
        });
      } else {
        debugPrint('❌ Route Service returned NULL');
        ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text('Failed to load route (Service Error)')),
        );
        setState(() => _isLoadingRoute = false);
      }
    } catch (e) {
      debugPrint('❌ Route Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text('Route Error: $e')),
      );
      setState(() => _isLoadingRoute = false);
    }
  }

  void _parseUserLocation() {
    debugPrint('🏠 Parsing delivery address: "${widget.order.deliveryAddress}"');
    
    try {
      if (widget.order.deliveryAddress.contains(',')) {
        final parts = widget.order.deliveryAddress.split(',');
        debugPrint('📍 Split into ${parts.length} parts: $parts');
        
        if (parts.length >= 2) {
          final lat = double.tryParse(parts[0].trim());
          final lng = double.tryParse(parts[1].trim());
          
          debugPrint('📍 Parsed: lat=$lat, lng=$lng');
          
          if (lat != null && lng != null) {
            _userLocation = LatLng(lat, lng);
            debugPrint('✅ User location SET to: $_userLocation');
            _updateMarkers(widget.order);
            return;
          }
        }
      }
    } catch (e) {
      debugPrint('❌ Error parsing location: $e');
    }

    // Fallback: Use a location visibly different from restaurant (2km SE)
    _userLocation = const LatLng(34.0200, -4.9900);
    debugPrint('⚠️ Using FALLBACK location: $_userLocation (Restaurant: $_restaurantLocation)');
    _updateMarkers(widget.order);
  }

  void _updateMarkers(OrderEntity order) {
    if (!mounted) return;
    
    debugPrint('🗺️ Updating markers - UserLoc: $_userLocation, RestaurantLoc: $_restaurantLocation');
    
    final markers = <Marker>{
      Marker(
        markerId: const MarkerId('restaurant'),
        position: _restaurantLocation,
        infoWindow: const InfoWindow(title: 'Darna Restaurant'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
      ),
      Marker(
        markerId: const MarkerId('customer'),
        position: _userLocation!,
        infoWindow: const InfoWindow(title: 'Your Delivery Address'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    };
    
    debugPrint('✅ Created ${markers.length} base markers (restaurant + customer)');

    // Add Driver Marker if location exists
    // Logic: Show driver if they are assigned and location is available
    debugPrint('📍 Order Status: ${order.status}, DriverLoc: ${order.driverLocation}');
    
    if (order.driverLocation != null && 
       (order.status == OrderStatus.pickedUp || order.status == OrderStatus.preparing)) {
      
      debugPrint('🟢 Real Driver Location Loop');
      markers.add(
        Marker(
          markerId: const MarkerId('driver'),
          position: order.driverLocation!,
          icon: _driverIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
          infoWindow: const InfoWindow(title: 'Driver'),
          rotation: 0, 
          anchor: const Offset(0.5, 0.5),
          zIndex: 2, 
        ),
      );
      
      if (_routePoints.isEmpty && _userLocation != null) {
         debugPrint('🚀 Triggering _fetchRoute from REAL location');
         _fetchRoute(order.driverLocation!, _userLocation!);
      }
    } else if (order.status == OrderStatus.pickedUp) {
        debugPrint('🟡 Fallback Mock Location Loop');
        // Fallback mock driver location
        final fallbackPos = LatLng(
          (_restaurantLocation.latitude + _userLocation!.latitude) / 2,
          (_restaurantLocation.longitude + _userLocation!.longitude) / 2,
        );
        
        markers.add(
        Marker(
          markerId: const MarkerId('driver'),
          position: fallbackPos,
          icon: _driverIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
          infoWindow: const InfoWindow(title: 'Driver'),
          anchor: const Offset(0.5, 0.5),
        ),
      );
      
      if (_routePoints.isEmpty && _userLocation != null) {
         debugPrint('🚀 Triggering _fetchRoute from FALLBACK location');
         _fetchRoute(fallbackPos, _userLocation!);
      }
    }

    // Determine route start point
    LatLng? routeStart;
    if (order.driverLocation != null && order.status == OrderStatus.pickedUp) {
      routeStart = order.driverLocation;
    } else {
      routeStart = _restaurantLocation;
    }

    setState(() {
      _markers = markers;
      
      // Trace route logic
      // Note: OSRM route might be failing or empty
      debugPrint('🗺️ Updating Polylines. Points available: ${_routePoints.length}');
      
      final points = _routePoints.isNotEmpty 
          ? _routePoints 
          : [routeStart!, _userLocation!];
      
      if (_routePoints.isEmpty) {
        debugPrint('⚠️ Falling back to straight line route');
      } else {
        debugPrint('✅ Using fetched route with ${_routePoints.length} points');
      }

      _polylines = {
        Polyline(
          polylineId: const PolylineId('route'),
          points: points,
          color: AppColors.primary,
          width: 5,
          jointType: JointType.round,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          geodesic: true, 
        ),
      };
    });
    
    // Animate camera to driver if exists
    if (order.driverLocation != null) {
        _animateToDriver(order.driverLocation!);
    }
  }

  Future<void> _animateToDriver(LatLng pos) async {
    final controller = await _controller.future;
    
    // If we have both driver and user location, fit them both in view
    if (_userLocation != null) {
      final bounds = LatLngBounds(
        southwest: LatLng(
          pos.latitude < _userLocation!.latitude ? pos.latitude : _userLocation!.latitude,
          pos.longitude < _userLocation!.longitude ? pos.longitude : _userLocation!.longitude,
        ),
        northeast: LatLng(
          pos.latitude > _userLocation!.latitude ? pos.latitude : _userLocation!.latitude,
          pos.longitude > _userLocation!.longitude ? pos.longitude : _userLocation!.longitude,
        ),
      );
      controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
    } else {
      controller.animateCamera(CameraUpdate.newLatLng(pos));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    
    // Calculate current order state
    final orderAsync = ref.watch(orderStreamProvider(widget.order.id));
    final currentOrder = orderAsync.value ?? widget.order;

    // Listen for updates to refresh map
    ref.listen(orderStreamProvider(widget.order.id), (previous, next) {
      if (next.value != null) {
        _updateMarkers(next.value!);
      }
    });
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
          decoration: BoxDecoration(
            color: theme.cardColor,
            shape: BoxShape.circle,
            boxShadow: AppShadows.elevation1,
          ),
          child: IconButton(
            icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Map View
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: CameraPosition(
              target: _userLocation ?? _restaurantLocation, // Center on client location
              zoom: 14,
            ),
            markers: _markers,
            polylines: _polylines,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
              _mapController = controller;
            },
            onCameraMove: (CameraPosition position) {
              // Update icon size when zoom changes
              if ((position.zoom - _currentZoom).abs() > 0.5) {
                _currentZoom = position.zoom;
                _loadDriverIcon();
              }
            },
          ),
          
          // Zoom Controls
          Positioned(
            right: 16,
            bottom: 220,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton.small(
                  heroTag: 'zoom_in',
                  backgroundColor: theme.colorScheme.surface,
                  child: Icon(Icons.add, color: theme.colorScheme.onSurface),
                  onPressed: () async {
                    final controller = await _controller.future;
                    controller.animateCamera(CameraUpdate.zoomIn());
                  },
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: 'zoom_out',
                  backgroundColor: theme.colorScheme.surface,
                  child: Icon(Icons.remove, color: theme.colorScheme.onSurface),
                  onPressed: () async {
                    final controller = await _controller.future;
                    controller.animateCamera(CameraUpdate.zoomOut());
                  },
                ),
              ],
            ),
          ),

          // Status Bottom Sheet
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: AppShadows.elevation3,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.orderStatusTitle,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.richGold.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _getStatusLabel(context, currentOrder.status),
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Timeline
                  _buildTimelineItem(
                    theme,
                    title: l10n.orderPlaced,
                    time: '12:30 PM',
                    isCompleted: true,
                    isLast: false,
                    delay: 100.ms,
                  ),
                  _buildTimelineItem(
                    theme,
                    title: l10n.statusPreparing,
                    time: '12:35 PM',
                    isCompleted: currentOrder.status.index >= OrderStatus.preparing.index,
                    isLast: false,
                    delay: 200.ms,
                  ),
                  _buildTimelineItem(
                    theme,
                    title: "Ready for Pickup", // Should use L10n really
                    time: '12:45 PM',
                    isCompleted: currentOrder.status.index >= OrderStatus.prepared.index,
                    isLast: false,
                    delay: 300.ms,
                  ),
                   _buildTimelineItem(
                    theme,
                    title: "On the way",
                    time: '12:50 PM',
                    isCompleted: currentOrder.status.index >= OrderStatus.pickedUp.index,
                    isLast: false,
                    delay: 400.ms,
                  ),
                   _buildTimelineItem(
                    theme,
                    title: l10n.statusDelivered,
                    time: '${l10n.estimatedDelivery} 1:15 PM',
                    isCompleted: currentOrder.status == OrderStatus.delivered,
                    isLast: true,
                    delay: 500.ms,
                  ),
                  
                  // Driver Info (New)
                  if (currentOrder.driverId != null && currentOrder.status == OrderStatus.pickedUp) ...[
                     const Divider(height: 32),
                     ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const CircleAvatar(
                        backgroundColor: AppColors.deepTeal,
                        child: Icon(Icons.motorcycle, color: Colors.white),
                      ),
                      title: const Text('Your Driver'),
                      subtitle: const Text('Is on the way!'),
                      trailing: IconButton(
                        icon: const Icon(Icons.phone, color: AppColors.deepTeal),
                        onPressed: () {
                           // Mock phone call
                           launchUrlString('tel:+212600000000');
                        },
                      ),
                     ).animate().fadeIn(delay: 600.ms),
                  ],
                ],
              ),
            ),
          ).animate().slideY(begin: 1, end: 0, duration: 500.ms, curve: Curves.easeOutBack),
        ],
      ),
    );
  }

  String _getStatusLabel(BuildContext context, OrderStatus status) {
     final l10n = AppLocalizations.of(context)!;
     switch (status) {
       case OrderStatus.pending: return l10n.statusPending;
       case OrderStatus.confirmed: return l10n.statusConfirmed;
       case OrderStatus.preparing: return l10n.statusPreparing;
       case OrderStatus.prepared: return "Ready";
       case OrderStatus.pickedUp: return "Picked Up";
       case OrderStatus.delivered: return l10n.statusDelivered;
       case OrderStatus.cancelled: return l10n.statusCancelled;
     }
  }

  Widget _buildTimelineItem(
    ThemeData theme, {
    required String title,
    required String time,
    required bool isCompleted,
    required bool isLast,
    Duration? delay,
  }) {
    // Determine if this is the ACTIVE step (completed but next one is NOT completed, or it is the very last completed one)
    // Simplified logic: If this item is completed, check if it's the specific status? 
    // For visual simplicity, we pulse if it isCompleted.
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: isCompleted ? AppColors.deepTeal : AppColors.slate.withValues(alpha: 0.3),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isCompleted ? AppColors.deepTeal : AppColors.slate).withValues(alpha: 0.2),
                    blurRadius: 4,
                  ),
                ],
              ),
            ).animate(
              onPlay: (controller) => isCompleted ? controller.repeat() : null,
            ).shimmer(duration: 2.seconds, delay: 1.seconds), // Subtle shimmer for active/completed
            if (!isLast)
              Container(
                width: 2,
                height: 30,
                color: isCompleted ? AppColors.deepTeal.withValues(alpha: 0.5) : AppColors.slate.withValues(alpha: 0.1),
              ).animate(delay: (delay ?? 0.ms) + 200.ms).fadeIn(),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 24.0), // Spacing for height of line
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal,
                    color: theme.textTheme.bodyMedium?.color,
                  ),
                ),
                Text(
                  time,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ).animate(delay: delay).fadeIn().slideX(begin: 0.2, end: 0);
  }
}
