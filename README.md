# Exemple de geolocalització, geocodificació i mapes

Aquest projecte mostra en una aplicació Flutter real els conceptes de l'apartat de geolocalització i mapes.

L'app permet:

- demanar permisos de localització;
- obtindre la ubicació actual del dispositiu amb `geolocator`;
- mostrar el punt seleccionat en un mapa amb `flutter_map`;
- convertir coordenades en una adreça amb `geocoding` (*geocodificació inversa*);
- convertir una adreça escrita en coordenades amb `geocoding` (*geocodificació directa*);
- usar Nominatim/OpenStreetMap com a alternativa quan el plugin `geocoding` no està disponible en la plataforma;
- seleccionar manualment un punt tocant el mapa.

> **Serveis depenents de la plataforma**
>
> `geolocator` i `geocoding` són plugins que depenen de serveis de plataforma, permisos i configuració nativa. Per això s'han de provar en una aplicació Flutter real.
>
> El paquet `geocoding` només indica suport oficial per a Android i iOS. En Linux, Windows, macOS o web aquest exemple usa una consulta HTTP a Nominatim/OpenStreetMap com a fallback per poder convertir coordenades i adreces.
>

## Execució de l'aplicació

```bash
flutter pub get
flutter run
```

Per provar la ubicació real, executa l'app en un dispositiu físic o en un emulador amb serveis de localització configurats.

En Linux, `geolocator` pot dependre de serveis del sistema com [GeoClue](https://launchpad.net/ubuntu/+source/geoclue-2.0). Pot ser que no aparega el mateix diàleg de permisos que en Android o iOS, perquè el model de permisos de l'escriptori és diferent.

## Flux de l'aplicació

El mapa comença centrat a València. A partir d'ací es poden provar tres accions:

1. Obtindre la ubicació del dispositiu: l'app comprova si el servei de localització està actiu, revisa els permisos i demana la posició actual.
2. Convertir coordenades en adreça: l'app agafa el punt seleccionat al mapa i intenta obtindre una adreça llegible.
3. Convertir una adreça en coordenades: l'app agafa el text del camp d'adreça, busca les coordenades i mou el marcador al resultat.

També es pot tocar directament el mapa per canviar el punt seleccionat. Això permet provar la geocodificació inversa sense dependre de la ubicació real del dispositiu.

## Estructura del codi

El projecte usa una estructura mínima per separar responsabilitats sense afegir encara estat global, repositoris ni una arquitectura completa:

- `lib/main.dart`: punt d'entrada de l'aplicació i configuració de `MaterialApp`.
- `lib/ui/geo_maps_screen.dart`: pantalla principal amb mapa, botons, estat local i interaccions de l'usuari.
- `lib/ui/widgets/info_row.dart`: widget auxiliar per mostrar parelles etiqueta/valor.
- `lib/services/geolocation_service.dart`: comprovació de servei actiu, permisos i obtenció de la posició amb `geolocator`.
- `lib/services/geocoding_service.dart`: geocodificació directa i inversa amb `geocoding`, amb fallback HTTP a Nominatim/OpenStreetMap.

La pantalla no crida directament `geolocator`, `geocoding` ni `http`; ho fa a través dels serveis. Això manté l'exemple prou simple per seguir-lo en classe, però evita que tota la lògica quede barrejada en el mateix fitxer.

En una aplicació més gran, el següent pas seria afegir repositoris, models propis i gestió d'estat amb `Provider`, `Riverpod` o una alternativa semblant. Per a aquest exemple, la separació en interfície i serveis és suficient per entendre el flux.

## Permisos

Android:

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

iOS:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Necessitem la ubicació per mostrar-la al mapa i convertir-la en una adreça.</string>
```

## Geocodificació

La geocodificació directa converteix una adreça en coordenades:

```text
Plaça de l'Ajuntament, València -> 39.4699, -0.3763
```

La geocodificació inversa fa el contrari:

```text
39.4699, -0.3763 -> Plaça de l'Ajuntament, València
```

Quan l'app use Nominatim, cal recordar que és un servei públic amb polítiques d'ús. És adequat per a proves docents, però una aplicació real hauria de revisar les condicions del servei o usar un proveïdor propi.

## Limitacions i detalls de plataforma

La ubicació del dispositiu depén de la plataforma, els permisos i els serveis del sistema. En Android i iOS és habitual veure un diàleg de permisos. En Linux pot no aparéixer aquest diàleg i el resultat dependrà de la configuració del sistema.

La geocodificació amb el paquet `geocoding` té suport oficial en Android i iOS. Per això el codi captura errors del plugin i, si cal, fa una consulta HTTP a Nominatim. Aquesta part és útil per veure la mateixa idea en plataformes d'escriptori, però convé tractar-la com una alternativa docent i no com una solució de producció sense revisar-ne les condicions d'ús.

## Relació amb els apunts

Aquest exemple complementa l'apartat `5.geolocalitzacio_mapes.md` de la unitat. Els fragments solts dels apunts mostren les peces per separat; aquesta app les combina en un únic flux:

1. obtindre ubicació;
2. mostrar-la al mapa;
3. convertir coordenades en adreça;
4. convertir una adreça en coordenades;
5. seleccionar punts manualment.
