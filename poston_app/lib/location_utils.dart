import 'dart:math' as Math;

class MapCoordinates {
  final double latitude;
  final double longitude;

  const MapCoordinates({
    required this.latitude,
    required this.longitude,
  });
}

double? parseDoubleValue(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

MapCoordinates? extractGoogleMapsCoordinates(String input) {
  final normalized = input.trim();
  if (normalized.isEmpty) return null;

  final candidates = <String>[normalized];
  final uri = Uri.tryParse(normalized);
  if (uri != null) {
    candidates.add(uri.toString());
    candidates.add(uri.toString().replaceAll('%2C', ','));

    final queryLat = uri.queryParameters['query'] ??
        uri.queryParameters['q'] ??
        uri.queryParameters['ll'];
    if (queryLat != null) {
      final queryMatch = RegExp(
        r'^\s*(-?\d+(?:\.\d+)?)\s*,\s*(-?\d+(?:\.\d+)?)\s*$',
      ).firstMatch(queryLat);
      if (queryMatch != null) {
        final latitude = double.tryParse(queryMatch.group(1)!);
        final longitude = double.tryParse(queryMatch.group(2)!);
        if (latitude != null && longitude != null) {
          return MapCoordinates(latitude: latitude, longitude: longitude);
        }
      }
    }
  }

  final patterns = <RegExp>[
    RegExp(r'!3d(-?\d+(?:\.\d+)?)!4d(-?\d+(?:\.\d+)?)'),
    RegExp(r'@(-?\d+(?:\.\d+)?),(-?\d+(?:\.\d+)?)'),
    RegExp(r'[?&](?:query|q|ll)=(-?\d+(?:\.\d+)?),(-?\d+(?:\.\d+)?)'),
    RegExp(r'(-?\d+(?:\.\d+)?),(-?\d+(?:\.\d+)?)'),
  ];

  for (final pattern in patterns) {
    for (final candidate in candidates) {
      final match = pattern.firstMatch(candidate);
      if (match == null) continue;

      final latitude = double.tryParse(match.group(1)!);
      final longitude = double.tryParse(match.group(2)!);
      if (latitude != null && longitude != null) {
        return MapCoordinates(latitude: latitude, longitude: longitude);
      }
    }
  }

  return null;
}

/// Calculate distance between two coordinates in kilometers using Haversine formula
double calculateDistance({
  required double userLatitude,
  required double userLongitude,
  required double serviceLatitude,
  required double serviceLongitude,
}) {
  const earthRadiusKm = 6371.0; // Earth radius in kilometers

  final dLat = _toRadians(serviceLatitude - userLatitude);
  final dLng = _toRadians(serviceLongitude - userLongitude);

  final a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
      Math.cos(_toRadians(userLatitude)) *
          Math.cos(_toRadians(serviceLatitude)) *
          Math.sin(dLng / 2) *
          Math.sin(dLng / 2);

  final c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  final distance = earthRadiusKm * c;

  return distance;
}

/// Convert degrees to radians
double _toRadians(double degrees) {
  return degrees * (Math.pi / 180);
}
