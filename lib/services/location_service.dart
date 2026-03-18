import 'dart:convert';
import 'package:http/http.dart' as http;

class LocationSuggestion {
  final String name;
  final double latitude;
  final double longitude;

  LocationSuggestion({
    required this.name,
    required this.latitude,
    required this.longitude,
  });
}

class LocationService {
  static const String _baseUrl = 'https://photon.komoot.io/api/';

  Future<List<LocationSuggestion>> searchLocations(String query) async {
    if (query.length < 3) return [];

    try {
      final response = await http.get(Uri.parse('$_baseUrl?q=$query&limit=5'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final features = data['features'] as List;

        return features.map((f) {
          final props = f['properties'];
          final coords = f['geometry']['coordinates'] as List;
          
          String name = props['name'] ?? '';
          if (props['city'] != null) name += ', ${props['city']}';
          if (props['country'] != null) name += ', ${props['country']}';

          return LocationSuggestion(
            name: name,
            latitude: coords[1],
            longitude: coords[0],
          );
        }).toList();
      }
    } catch (e) {
      print('Location search error: $e');
    }
    return [];
  }
}
