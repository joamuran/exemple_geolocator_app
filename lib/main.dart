import 'package:flutter/material.dart';

import 'ui/geo_maps_screen.dart';

void main() {
  runApp(const GeoMapsApp());
}

class GeoMapsApp extends StatelessWidget {
  const GeoMapsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Geolocalitzacio i mapes',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const GeoMapsScreen(),
    );
  }
}
