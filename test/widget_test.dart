import 'package:exemple_geolocator_app/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows geolocation demo title', (tester) async {
    await tester.pumpWidget(const GeoMapsApp());

    expect(find.text('Ubicació, geocodificació i mapa'), findsOneWidget);
    expect(
      find.text('Obtín la ubicació del dispositiu', skipOffstage: false),
      findsOneWidget,
    );
  });
}
