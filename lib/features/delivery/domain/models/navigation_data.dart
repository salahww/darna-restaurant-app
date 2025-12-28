import 'package:google_maps_flutter/google_maps_flutter.dart';

class NavigationStep {
  final String instruction;
  final String htmlInstruction;
  final LatLng startLocation;
  final LatLng endLocation;
  final int distanceMeters;
  final int durationSeconds;
  final String? maneuver;
  
  NavigationStep({
    required this.instruction,
    required this.htmlInstruction,
    required this.startLocation,
    required this.endLocation,
    required this.distanceMeters,
    required this.durationSeconds,
    this.maneuver,
  });
  
  factory NavigationStep.fromJson(Map<String, dynamic> json) {
    return NavigationStep(
      instruction: json['html_instructions'] ?? '',
      htmlInstruction: json['html_instructions'] ?? '',
      startLocation: LatLng(
        json['start_location']['lat'],
        json['start_location']['lng'],
      ),
      endLocation: LatLng(
        json['end_location']['lat'],
        json['end_location']['lng'],
      ),
      distanceMeters: json['distance']['value'],
      durationSeconds: json['duration']['value'],
      maneuver: json['maneuver'],
    );
  }
}

class NavigationData {
  final List<LatLng> polylinePoints;
  final List<NavigationStep> steps;
  final int totalDistanceMeters;
  final int totalDurationSeconds;
  
  NavigationData({
    required this.polylinePoints,
    required this.steps,
    required this.totalDistanceMeters,
    required this.totalDurationSeconds,
  });
  
  double get distanceKm => totalDistanceMeters / 1000.0;
  int get durationMinutes => (totalDurationSeconds / 60).ceil();
  
  String getEta() {
    final now = DateTime.now();
    final arrival = now.add(Duration(seconds: totalDurationSeconds));
    return '${arrival.hour.toString().padLeft(2, '0')}:${arrival.minute.toString().padLeft(2, '0')}';
  }
}
