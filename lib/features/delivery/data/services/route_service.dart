import 'package:flutter/foundation.dart'; // Add this for debugPrint
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:darna/features/delivery/domain/models/navigation_data.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;


class RouteService {
  // TODO: Secure this key properly in production (e.g. valid restrictions)
  // Using the same key found in AndroidManifest.xml
  static const String _googleMapsApiKey = 'AIzaSyAcGHat5hpQeSZBhDgHPauf2_1uJBOyDIs';

  // Using OSRM (Open Source Routing Machine) for free routing without API key issues
  // Note: For production high-volume, you should host your own OSRM server or use a paid service.
  Future<NavigationData?> getRoute(LatLng origin, LatLng destination) async {
    try {
      debugPrint('🗺️ Fetching route from $origin to $destination via OSRM');
      
      // OSRM expects: /route/v1/driving/start_lon,start_lat;end_lon,end_lat
      final url = Uri.parse(
        'https://router.project-osrm.org/route/v1/driving/'
        '${origin.longitude},${origin.latitude};'
        '${destination.longitude},${destination.latitude}'
        '?overview=full&geometries=polyline'
      );
      
      final response = await http.get(url);
      
      if (response.statusCode != 200) {
        debugPrint('❌ OSRM request failed: ${response.statusCode}');
        return null;
      }
      
      final data = json.decode(response.body);
      
      if (data['code'] != 'Ok') {
        debugPrint('❌ OSRM API error: ${data['code']}');
        return null;
      }
      
      final routes = data['routes'] as List;
      if (routes.isEmpty) return null;

      final route = routes[0];
      final geometry = route['geometry'] as String;
      
      // Decode Polyline
      final polylinePoints = PolylinePoints.decodePolyline(geometry)
          .map((point) => LatLng(point.latitude, point.longitude))
          .toList();
      
      final distanceMeters = route['distance'] as num;
      final durationSeconds = route['duration'] as num;
      
      final navigationData = NavigationData(
        polylinePoints: polylinePoints,
        steps: [], // OSRM steps parsing omitted for brevity, we mainly need the line
        totalDistanceMeters: distanceMeters.toInt(),
        totalDurationSeconds: durationSeconds.toInt(),
      );
      
      debugPrint('🗺️ ✅ OSRM Route fetched: ${polylinePoints.length} points, ${navigationData.distanceKm.toStringAsFixed(1)} km');
      
      return navigationData;
    } catch (e, stackTrace) {
      debugPrint('❌ Error fetching route: $e');
      debugPrint('Stack trace: $stackTrace');
      return null;
    }
  }
}
