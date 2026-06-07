import 'dart:convert';

import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class GeocodingService {
  Future<String?> addressFromCoordinates(LatLng point) async {
    try {
      // Camí preferent: plugin natiu geocoding. Funciona oficialment en
      // Android i iOS.
      final places = await placemarkFromCoordinates(
        point.latitude,
        point.longitude,
      );

      if (places.isNotEmpty) {
        return _formatPlacemark(places.first);
      }
    } on Object {
      // El plugin geocoding nomes te implementacio oficial per a Android i iOS.
      // En Linux, Windows, macOS o web podem caure aci i usar Nominatim.
    }

    return _reverseWithNominatim(point);
  }

  Future<LatLng?> coordinatesFromAddress(String address) async {
    try {
      // Camí preferent: geocodificacio directa amb el plugin natiu.
      final locations = await locationFromAddress(address);

      if (locations.isNotEmpty) {
        final location = locations.first;
        return LatLng(location.latitude, location.longitude);
      }
    } on Object {
      // Mateixa idea: si la plataforma no suporta geocoding natiu,
      // fem una consulta HTTP senzilla a Nominatim.
    }

    return _searchWithNominatim(address);
  }

  String _formatPlacemark(Placemark place) {
    return [
      place.street,
      place.locality,
      place.postalCode,
      place.country,
    ].where((part) => part != null && part.isNotEmpty).join(', ');
  }

  Future<String?> _reverseWithNominatim(LatLng point) async {
    // Fallback HTTP: Nominatim converteix coordenades en una adreca.
    final uri = Uri.https('nominatim.openstreetmap.org', '/reverse', {
      'format': 'jsonv2',
      'lat': point.latitude.toString(),
      'lon': point.longitude.toString(),
      'accept-language': 'ca',
    });

    final response = await _getJson(uri);
    return response?['display_name'] as String?;
  }

  Future<LatLng?> _searchWithNominatim(String address) async {
    // Fallback HTTP: Nominatim busca coordenades a partir d'una adreca.
    final uri = Uri.https('nominatim.openstreetmap.org', '/search', {
      'format': 'jsonv2',
      'q': address,
      'limit': '1',
      'accept-language': 'ca',
    });

    final response = await _getJsonList(uri);
    if (response == null || response.isEmpty) {
      return null;
    }

    final first = response.first as Map<String, dynamic>;
    final lat = double.tryParse(first['lat'] as String? ?? '');
    final lon = double.tryParse(first['lon'] as String? ?? '');

    if (lat == null || lon == null) {
      return null;
    }

    return LatLng(lat, lon);
  }

  Future<Map<String, dynamic>?> _getJson(Uri uri) async {
    final response = await http.get(uri, headers: _headers);
    if (response.statusCode != 200) {
      return null;
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<List<dynamic>?> _getJsonList(Uri uri) async {
    final response = await http.get(uri, headers: _headers);
    if (response.statusCode != 200) {
      return null;
    }

    return jsonDecode(response.body) as List<dynamic>;
  }

  static const _headers = {
    // Nominatim demana identificar les aplicacions que fan peticions HTTP.
    'User-Agent': 'exemple_geolocator_app/1.0 (docencia Flutter)',
  };
}
