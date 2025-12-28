import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:darna/features/delivery/domain/models/navigation_data.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;


class RouteService {
  // TODO: Secure this key properly in production (e.g. valid restrictions)
  // Using the same key found in AndroidManifest.xml
  static const String _googleMapsApiKey = 'AIzaSyAcGHat5hpQeSZBhDgHPauf2_1uJBOyDIs';

  Future<NavigationData?> getRoute(LatLng origin, LatLng destination) async {
    try {
      print('🗺️ Fetching route from $origin to $destination');
      
      // Call Google Directions API directly for full response
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/directions/json'
        '?origin=${origin.latitude},${origin.longitude}'
        '&destination=${destination.latitude},${destination.longitude}'
        '&mode=driving'
        '&key=$_googleMapsApiKey'
      );
      
      final response = await http.get(url);
      
      if (response.statusCode != 200) {
        print('❌ API request failed: ${response.statusCode}');
        return null;
      }
      
      final data = json.decode(response.body);
      
      if (data['status'] != 'OK') {
        print('❌ Directions API error: ${data['status']}');
        return null;
      }
      
      final route = data['routes'][0];
      final leg = route['legs'][0];
      
      // Parse navigation steps
      final steps = (leg['steps'] as List)
          .map((step) => NavigationStep.fromJson(step))
          .toList();
      
      // Get polyline points
      final polylineString = route['overview_polyline']['points'];
      final polylinePoints = PolylinePoints.decodePolyline(polylineString)
          .map((point) => LatLng(point.latitude, point.longitude))
          .toList();
      
      final navigationData = NavigationData(
        polylinePoints: polylinePoints,
        steps: steps,
        totalDistanceMeters: leg['distance']['value'],
        totalDurationSeconds: leg['duration']['value'],
      );
      
      print('🗺️ ✅ Route fetched: ${steps.length} steps, ${navigationData.distanceKm.toStringAsFixed(1)} km, ${navigationData.durationMinutes} min');
      
      return navigationData;
    } catch (e, stackTrace) {
      print('❌ Error fetching route: $e');
      print('Stack trace: $stackTrace');
      return null;
    }
  }
}
