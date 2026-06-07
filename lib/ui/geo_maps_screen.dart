import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../services/geocoding_service.dart';
import '../services/geolocation_service.dart';
import 'widgets/info_row.dart';

class GeoMapsScreen extends StatefulWidget {
  const GeoMapsScreen({super.key});

  @override
  State<GeoMapsScreen> createState() => _GeoMapsScreenState();
}

class _GeoMapsScreenState extends State<GeoMapsScreen> {
  static const _defaultPoint = LatLng(39.4699, -0.3763);

  final _mapController = MapController();
  final _addressController = TextEditingController(
    text: 'Plaça de l\'Ajuntament, València',
  );
  final _geolocationService = GeolocationService();
  final _geocodingService = GeocodingService();

  LatLng _selectedPoint = _defaultPoint;
  String? _address;
  String? _statusMessage;
  bool _isLoading = false;

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _locateDevice() async {
    await _runGeoOperation(() async {
      // 1. Geolocalitzacio: demanem al sistema la posicio actual.
      final result = await _geolocationService.getCurrentPosition();

      if (result == null) {
        _statusMessage =
            'No s\'ha pogut obtindre la ubicació. Revisa permisos o serveis de localització.';
        return;
      }

      _selectedPoint = LatLng(result.latitude, result.longitude);

      // 2. Geocodificacio inversa: transformem coordenades en adreca.
      _address = await _geocodingService.addressFromCoordinates(_selectedPoint);
      _statusMessage = 'Ubicació del dispositiu actualitzada.';
      _moveMapToSelectedPoint();
    });
  }

  Future<void> _reverseGeocodeSelectedPoint() async {
    await _runGeoOperation(() async {
      // Converteix el punt seleccionat al mapa en una adreca llegible.
      _address = await _geocodingService.addressFromCoordinates(_selectedPoint);
      _statusMessage = _address == null
          ? 'No s\'ha pogut obtindre una adreça per a aquest punt.'
          : 'Adreça obtinguda a partir de les coordenades.';
    });
  }

  Future<void> _geocodeAddress() async {
    await _runGeoOperation(() async {
      final address = _addressController.text.trim();

      if (address.isEmpty) {
        _statusMessage = 'Escriu una adreça per geocodificar-la.';
        return;
      }

      // Geocodificacio directa: transformem una adreca escrita en coordenades.
      final point = await _geocodingService.coordinatesFromAddress(address);

      if (point == null) {
        _statusMessage = 'No s\'han trobat coordenades per a aquesta adreça.';
        return;
      }

      _selectedPoint = point;
      _address = await _geocodingService.addressFromCoordinates(point);
      _statusMessage = 'Coordenades obtingudes a partir de l\'adreça.';
      _moveMapToSelectedPoint();
    });
  }

  Future<void> _runGeoOperation(Future<void> Function() operation) async {
    setState(() {
      _isLoading = true;
      _statusMessage = null;
    });

    try {
      // Centralitzem el tractament d'errors de les operacions geoespacials.
      await operation();
    } on PermissionDeniedException {
      _statusMessage = 'Permís de localització denegat.';
    } on LocationServiceDisabledException {
      _statusMessage = 'El servei de localització està desactivat.';
    } on Exception catch (error) {
      _statusMessage = 'S\'ha produït un error: $error';
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _selectPoint(LatLng point) {
    setState(() {
      _selectedPoint = point;
      _address = null;
      _statusMessage =
          'Punt seleccionat manualment. Pots fer geocodificació inversa.';
    });
  }

  void _moveMapToSelectedPoint() {
    _mapController.move(_selectedPoint, 16);
  }

  @override
  Widget build(BuildContext context) {
    final coordinates =
        '${_selectedPoint.latitude.toStringAsFixed(6)}, '
        '${_selectedPoint.longitude.toStringAsFixed(6)}';

    return Scaffold(
      appBar: AppBar(title: const Text('Geolocalització i mapes')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Ubicació, geocodificació i mapa',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          const Text(
            'Aquesta app mostra la ubicació del dispositiu, converteix coordenades en una adreça i també converteix una adreça en coordenades.',
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 320,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _selectedPoint,
                  initialZoom: 13,
                  onTap: (_, point) => _selectPoint(point),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    // flutter_map demana un user agent identificable quan usem
                    // tessel.les d'OpenStreetMap.
                    userAgentPackageName: 'net.joamuran.exemple_geolocator_app',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _selectedPoint,
                        width: 48,
                        height: 48,
                        child: const Icon(
                          Icons.location_pin,
                          color: Colors.red,
                          size: 44,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InfoRow(label: 'Coordenades', value: coordinates),
                  InfoRow(
                    label: 'Adreça',
                    value: _address ?? 'Encara no calculada',
                  ),
                  if (_statusMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _statusMessage!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _isLoading ? null : _locateDevice,
            icon: const Icon(Icons.my_location),
            label: const Text('Obtín la ubicació del dispositiu'),
          ),
          const SizedBox(height: 8),
          FilledButton.tonalIcon(
            onPressed: _isLoading ? null : _reverseGeocodeSelectedPoint,
            icon: const Icon(Icons.place),
            label: const Text('Converteix coordenades en adreça'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _addressController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Adreça',
              helperText:
                  'Prova amb una adreça i converteix-la en coordenades.',
            ),
            minLines: 1,
            maxLines: 2,
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _isLoading ? null : _geocodeAddress,
            icon: const Icon(Icons.search),
            label: const Text('Converteix adreça en coordenades'),
          ),
          if (_isLoading) ...[
            const SizedBox(height: 16),
            const LinearProgressIndicator(),
          ],
        ],
      ),
    );
  }
}
