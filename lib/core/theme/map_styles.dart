/// Map Style JSON configurations for Day and Night modes
/// Optimized for delivery navigation with high contrast

class MapStyles {
  /// High Contrast Day Style
  /// - Muted background to make route stand out
  /// - Visible road labels
  /// - Hidden POIs and transit
  static const String dayStyle = '''[
    {
      "featureType": "all",
      "elementType": "geometry",
      "stylers": [{"saturation": -50}, {"lightness": 30}]
    },
    {
      "featureType": "road",
      "elementType": "geometry",
      "stylers": [{"color": "#ffffff"}, {"lightness": 0}]
    },
    {
      "featureType": "road",
      "elementType": "labels.text.fill",
      "stylers": [{"color": "#1a1a1a"}, {"visibility": "on"}]
    },
    {
      "featureType": "road",
      "elementType": "labels.text.stroke",
      "stylers": [{"color": "#ffffff"}, {"visibility": "on"}, {"weight": 3}]
    },
    {
      "featureType": "road.highway",
      "elementType": "geometry",
      "stylers": [{"color": "#f5f5f5"}]
    },
    {
      "featureType": "poi",
      "stylers": [{"visibility": "off"}]
    },
    {
      "featureType": "poi.business",
      "stylers": [{"visibility": "off"}]
    },
    {
      "featureType": "transit",
      "stylers": [{"visibility": "off"}]
    },
    {
      "featureType": "water",
      "elementType": "geometry",
      "stylers": [{"color": "#c9e8f8"}]
    }
  ]''';

  /// Night Mode Style
  /// - Dark background for reduced eye strain
  /// - Bright roads for visibility
  /// - Hidden distractions
  static const String nightStyle = '''[
    {
      "featureType": "all",
      "elementType": "geometry",
      "stylers": [{"color": "#242f3e"}]
    },
    {
      "featureType": "all",
      "elementType": "labels.text.fill",
      "stylers": [{"color": "#746855"}]
    },
    {
      "featureType": "all",
      "elementType": "labels.text.stroke",
      "stylers": [{"color": "#242f3e"}]
    },
    {
      "featureType": "road",
      "elementType": "geometry",
      "stylers": [{"color": "#38414e"}]
    },
    {
      "featureType": "road",
      "elementType": "geometry.stroke",
      "stylers": [{"color": "#212a37"}]
    },
    {
      "featureType": "road.highway",
      "elementType": "geometry",
      "stylers": [{"color": "#505a6b"}]
    },
    {
      "featureType": "road",
      "elementType": "labels.text.fill",
      "stylers": [{"color": "#9ca5b3"}]
    },
    {
      "featureType": "poi",
      "stylers": [{"visibility": "off"}]
    },
    {
      "featureType": "transit",
      "stylers": [{"visibility": "off"}]
    },
    {
      "featureType": "water",
      "elementType": "geometry",
      "stylers": [{"color": "#17263c"}]
    }
  ]''';

  /// Check if current time is night (6PM - 6AM)
  static bool isNightTime() {
    final hour = DateTime.now().hour;
    return hour < 6 || hour >= 18;
  }

  /// Get appropriate map style based on time of day
  static String getStyleForCurrentTime() {
    return isNightTime() ? nightStyle : dayStyle;
  }
}
