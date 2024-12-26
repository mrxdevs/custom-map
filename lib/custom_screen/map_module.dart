import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:maplibre_gl_example/page.dart';

import 'model/charger_model.dart';

class MapModule extends ExamplePage {
  MapModule(super.leading, super.title);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MapFeaturesScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MapFeaturesScreen extends StatefulWidget {
  const MapFeaturesScreen({Key? key}) : super(key: key);

  @override
  State<MapFeaturesScreen> createState() => _MapFeaturesScreenState();
}

class _MapFeaturesScreenState extends State<MapFeaturesScreen> {
  MapLibreMapController? mapController;
  Symbol? marker;

  final String _markerImageName = 'red_marker';
  final String _markerAssetPath = 'assets/red_marker.png';
  static const LatLng center = LatLng(-33.86711, 151.1947171);

  bool _isMarkerImageAdded = false; // To track if the image is loaded
  bool _isSymbolTapListenerAdded = false;
  Map<Symbol, EVCharger> markersMap = {};

  /// Load marker image into the map style once
  Future<void> _loadMarkerImage() async {
    if (_isMarkerImageAdded) return; // Avoid reloading the image
    try {
      final ByteData bytes = await rootBundle.load(_markerAssetPath);
      final Uint8List imageData = bytes.buffer.asUint8List();
      await mapController?.addImage(_markerImageName, imageData);
      setState(() {
        _isMarkerImageAdded = true;
      });
      print("Marker image loaded successfully.");
    } catch (e) {
      print("Error loading marker image: $e");
    }
  }

  /// Add a marker dynamically at the specified location
  void _addMarker(LatLng latLng) async {
    if (_isMarkerImageAdded) {
      marker = await mapController?.addSymbol(
        SymbolOptions(
          geometry: latLng,
          iconRotate: 180,
          // draggable: true,

          iconImage: _markerImageName,
          iconSize: 0.05, // Adjust marker size
          iconAnchor: 'bottom', // Align icon to the bottom
        ),
      );
      print("Marker added at: $latLng");
    } else {
      print("Marker image not loaded yet!");
    }
  }

//Tappable marker with info window
  void _addTappableMarker(
      LatLng ltlng, Function(Symbol? symbol) onMarkerTap) async {
    if (mapController == null) return;

    // Remove existing marker if any
    if (marker != null) {
      await mapController!.removeSymbol(marker!);
    }

    // Add new marker
    await mapController!.addSymbol(
      SymbolOptions(
        geometry: ltlng,
        iconSize: 0.05,
        iconImage: _markerImageName, // Make sure to add this to your assets
        // You can also use a default marker:
        // iconImage: "marker-15",
      ),
    );

    // Add tap listener for the marker
    if (!_isSymbolTapListenerAdded) {
      mapController!.onSymbolTapped.add(onMarkerTap);
      _isSymbolTapListenerAdded = true;
    }
  }

  void _onMarkerTapped(_) {
    // if (symbol == marker) {

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Marker tapped!"),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 1),
      ),
    );
    // }
  }

  //Symbol icon
  SymbolOptions _getSymbolOptions(String iconImage, int symbolCount) {
    final geometry = LatLng(
      center.latitude + sin(symbolCount * pi / 6.0) / 20.0,
      center.longitude + cos(symbolCount * pi / 6.0) / 20.0,
    );
    return iconImage == 'customFont'
        ? SymbolOptions(
            geometry: geometry,
            iconImage: 'custom-marker',
            //'airport-15',
            fontNames: ['DIN Offc Pro Bold', 'Arial Unicode MS Regular'],
            textField: 'Airport',
            textSize: 12.5,
            textOffset: const Offset(0, 0.8),
            textAnchor: 'top',
            textColor: '#000000',
            textHaloBlur: 1,
            textHaloColor: '#ffffff',
            textHaloWidth: 0.8,
          )
        : SymbolOptions(
            geometry: geometry,
            textField: 'Airport',
            textOffset: const Offset(0, 0.8),
            iconImage: iconImage,
          );
  }

  /// Callback when the map is created
  void _onMapCreated(MapLibreMapController controller) {
    mapController = controller;

    _loadMarkerImage(); // Load the marker image when the map is created
  }

  /// Callback when the map style is loaded
  void _onStyleLoadedCallback() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Style loaded successfully!"),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  void dispose() {
    if (_isSymbolTapListenerAdded) {
      mapController?.onSymbolTapped.remove(_onMarkerTapped);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MapLibreMap(
        // styleString: "http://10.0.0.255:8080/styles/test-style/style.json",
        // styleString: "http://10.0.0.143:8080/styles/test-style/style.json",
        // styleString: "http://34.93.16.227:8080/styles/test-style/style.json",
        styleString: "https://maps.raptee.com/styles/test-style/style.json",
        onMapCreated: _onMapCreated,
        onStyleLoadedCallback: _onStyleLoadedCallback,
        initialCameraPosition: const CameraPosition(
          target: LatLng(13.067439, 80.237617), // Default center position
          zoom: 8.0,
        ),
        myLocationEnabled: true,
        onMapClick: (point, latLng) {
          print("Map clicked at: $latLng");
          // _addMarker(latLng);
        },
        onMapLongClick: (point, latLng) {
          print("Map long-clicked at: $latLng");
        },
      ),
      floatingActionButton: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: () {
                  _addMarker(LatLng(13.017882, 80.174146));
                },
                child: Text("Marker"),
              ),
              ElevatedButton(
                onPressed: () {
                  mapController?.removeSymbol(marker!);
                },
                child: Text("Remove Marker"),
              ),
              ElevatedButton(
                onPressed: () {
                  _addTappableMarker(LatLng(13.017882, 80.274000), (symbol) {
                    _onMarkerTapped(marker);
                  });
                },
                child: Text("Tappable Marker"),
              ),
              ElevatedButton(
                onPressed: () {
                  _addTappableMarker(LatLng(13.017882, 80.174146), (symbol) {
                    _onMarkerTapped(marker);
                  });
                },
                child: Text("Tappable Marker1"),
              ),
              ElevatedButton(
                onPressed: () {
                  addChargerStations();
                },
                child: Text("Charger Stations"),
              )
            ],
          ),
        ),
      ),
    );
  }

  addChargerStations() {
    for (var i = 0; i < evChargers.length; i++) {
      final charger = evChargers[i];
      _addTappableMarker(charger.location, (sy) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Charger: ${charger.name}\n'
              'Address: ${charger.address}\n'
              'Power Output: ${charger.powerOutput} kW\n'
              'Connector Types: ${charger.connectorTypes.join(', ')}\n'
              'Price per kWh: ₹${charger.pricePerKWh}\n'
              'Operating Hours: ${charger.operatingHours}\n'
              'Number of Ports: ${charger.numberOfPorts}\n'
              'Network Operator: ${charger.networkOperator}\n'
              'Ratings: ${charger.ratings}',
            ),
            duration: const Duration(seconds: 5),
          ),
        );
      });
    }
    setState(() {});
  }

  final List<EVCharger> evChargers = [
    EVCharger(
      id: 'CHG001',
      name: 'Downtown Express Charging Hub',
      address: '123 Main Street, Mumbai, Maharashtra',
      location: const LatLng(18.9387, 72.8353),
      powerOutput: 150.0,
      connectorTypes: ['CCS2', 'CHAdeMO', 'Type 2'],
      isAvailable: true,
      pricePerKWh: 12.50,
      operatingHours: '24/7',
      numberOfPorts: 6,
      networkOperator: 'Tata Power',
      ratings: 4.5,
    ),
    EVCharger(
      id: 'CHG002',
      name: 'Tech Park Charging Station',
      address: '456 Electronics City, Bangalore, Karnataka',
      location: const LatLng(12.9716, 77.5946),
      powerOutput: 120.0,
      connectorTypes: ['CCS2', 'Type 2'],
      isAvailable: true,
      pricePerKWh: 11.75,
      operatingHours: '6:00 AM - 11:00 PM',
      numberOfPorts: 4,
      networkOperator: 'EESL',
      ratings: 4.2,
    ),
    EVCharger(
      id: 'CHG003',
      name: 'Green Mall Charging Point',
      address: '789 Anna Salai, Chennai, Tamil Nadu',
      location: const LatLng(13.0827, 80.2707),
      powerOutput: 100.0,
      connectorTypes: ['CCS2', 'Type 2', 'AC Type 2'],
      isAvailable: true,
      pricePerKWh: 13.00,
      operatingHours: '8:00 AM - 10:00 PM',
      numberOfPorts: 8,
      networkOperator: 'Ather Grid',
      ratings: 4.7,
    ),
    EVCharger(
      id: 'CHG004',
      name: 'Highway Rest Stop Charger',
      address: 'NH-8, Gurugram, Haryana',
      location: const LatLng(28.4595, 77.0266),
      powerOutput: 180.0,
      connectorTypes: ['CCS2', 'CHAdeMO'],
      isAvailable: true,
      pricePerKWh: 14.50,
      operatingHours: '24/7',
      numberOfPorts: 4,
      networkOperator: 'Fortum',
      ratings: 4.0,
    ),
    EVCharger(
      id: 'CHG005',
      name: 'Metro Station Charging Hub',
      address: 'Sector 18, Noida, Uttar Pradesh',
      location: const LatLng(28.5705, 77.3248),
      powerOutput: 90.0,
      connectorTypes: ['CCS2', 'Type 2'],
      isAvailable: true,
      pricePerKWh: 11.25,
      operatingHours: '6:00 AM - 11:00 PM',
      numberOfPorts: 6,
      networkOperator: 'Energy Efficiency Services',
      ratings: 4.3,
    ),
    EVCharger(
      id: 'CHG006',
      name: 'Beachside Charging Station',
      address: 'Marine Drive, Kochi, Kerala',
      location: const LatLng(9.9312, 76.2673),
      powerOutput: 60.0,
      connectorTypes: ['Type 2', 'AC Type 2'],
      isAvailable: true,
      pricePerKWh: 12.00,
      operatingHours: '7:00 AM - 9:00 PM',
      numberOfPorts: 3,
      networkOperator: 'Kerala State Electricity Board',
      ratings: 4.1,
    ),
    EVCharger(
      id: 'CHG007',
      name: 'Airport Terminal Charger',
      address: 'T3 Terminal, IGI Airport, Delhi',
      location: const LatLng(28.5562, 77.1000),
      powerOutput: 200.0,
      connectorTypes: ['CCS2', 'CHAdeMO', 'Type 2'],
      isAvailable: true,
      pricePerKWh: 15.00,
      operatingHours: '24/7',
      numberOfPorts: 10,
      networkOperator: 'GMR Energy',
      ratings: 4.8,
    ),
    EVCharger(
      id: 'CHG008',
      name: 'City Center Mall Charger',
      address: 'Salt Lake, Kolkata, West Bengal',
      location: const LatLng(22.5726, 88.3639),
      powerOutput: 110.0,
      connectorTypes: ['CCS2', 'Type 2'],
      isAvailable: true,
      pricePerKWh: 12.75,
      operatingHours: '10:00 AM - 10:00 PM',
      numberOfPorts: 5,
      networkOperator: 'West Bengal Power',
      ratings: 4.4,
    ),
    EVCharger(
      id: 'CHG009',
      name: 'Industrial Area Charging Hub',
      address: 'MIDC, Pune, Maharashtra',
      location: const LatLng(18.5204, 73.8567),
      powerOutput: 140.0,
      connectorTypes: ['CCS2', 'CHAdeMO'],
      isAvailable: true,
      pricePerKWh: 13.25,
      operatingHours: '24/7',
      numberOfPorts: 8,
      networkOperator: 'Maharashtra State Power',
      ratings: 4.6,
    ),
    EVCharger(
      id: 'CHG010',
      name: 'Smart City Charging Point',
      address: 'Jubilee Hills, Hyderabad, Telangana',
      location: const LatLng(17.4326, 78.3403),
      powerOutput: 130.0,
      connectorTypes: ['CCS2', 'Type 2', 'AC Type 2'],
      isAvailable: true,
      pricePerKWh: 12.25,
      operatingHours: '6:00 AM - 12:00 AM',
      numberOfPorts: 6,
      networkOperator: 'Telangana Power',
      ratings: 4.3,
    ),
    EVCharger(
      id: 'CHG011',
      name: 'Lake View Charging Station',
      address: 'MG Road, Bhopal, Madhya Pradesh',
      location: const LatLng(23.2599, 77.4126),
      powerOutput: 80.0,
      connectorTypes: ['CCS2', 'Type 2'],
      isAvailable: true,
      pricePerKWh: 11.50,
      operatingHours: '7:00 AM - 11:00 PM',
      numberOfPorts: 4,
      networkOperator: 'MP Power',
      ratings: 4.0,
    ),
    EVCharger(
      id: 'CHG012',
      name: 'Hill Station Charger',
      address: 'Mall Road, Shimla, Himachal Pradesh',
      location: const LatLng(31.1048, 77.1734),
      powerOutput: 70.0,
      connectorTypes: ['CCS2', 'Type 2'],
      isAvailable: true,
      pricePerKWh: 14.00,
      operatingHours: '8:00 AM - 8:00 PM',
      numberOfPorts: 3,
      networkOperator: 'HP State Electricity Board',
      ratings: 4.2,
    ),
    EVCharger(
      id: 'CHG013',
      name: 'Central Station Charger',
      address: 'Rajiv Chowk, New Delhi',
      location: const LatLng(28.6129, 77.2295),
      powerOutput: 160.0,
      connectorTypes: ['CCS2', 'CHAdeMO', 'Type 2'],
      isAvailable: true,
      pricePerKWh: 13.75,
      operatingHours: '24/7',
      numberOfPorts: 8,
      networkOperator: 'Delhi Power Company',
      ratings: 4.7,
    ),
    EVCharger(
      id: 'CHG014',
      name: 'Desert Highway Charger',
      address: 'NH-62, Jaisalmer, Rajasthan',
      location: const LatLng(26.9157, 70.9083),
      powerOutput: 150.0,
      connectorTypes: ['CCS2', 'CHAdeMO'],
      isAvailable: true,
      pricePerKWh: 15.50,
      operatingHours: '24/7',
      numberOfPorts: 4,
      networkOperator: 'Rajasthan Energy',
      ratings: 4.1,
    ),
    EVCharger(
      id: 'CHG015',
      name: 'University Campus Charger',
      address: 'IIT Campus, Kharagpur, West Bengal',
      location: const LatLng(22.3149, 87.3110),
      powerOutput: 90.0,
      connectorTypes: ['Type 2', 'AC Type 2'],
      isAvailable: true,
      pricePerKWh: 11.00,
      operatingHours: '7:00 AM - 10:00 PM',
      numberOfPorts: 5,
      networkOperator: 'IIT Power Grid',
      ratings: 4.5,
    ),
    EVCharger(
      id: 'CHG016',
      name: 'Port Area Charging Hub',
      address: 'Harbor Road, Visakhapatnam, Andhra Pradesh',
      location: const LatLng(17.6868, 83.2185),
      powerOutput: 120.0,
      connectorTypes: ['CCS2', 'Type 2'],
      isAvailable: true,
      pricePerKWh: 12.90,
      operatingHours: '24/7',
      numberOfPorts: 6,
      networkOperator: 'AP Power Generation',
      ratings: 4.3,
    ),
    EVCharger(
      id: 'CHG017',
      name: 'Tourist Spot Charger',
      address: 'Taj Road, Agra, Uttar Pradesh',
      location: const LatLng(27.1751, 78.0421),
      powerOutput: 100.0,
      connectorTypes: ['CCS2', 'Type 2'],
      isAvailable: true,
      pricePerKWh: 13.50,
      operatingHours: '6:00 AM - 10:00 PM',
      numberOfPorts: 4,
      networkOperator: 'UP Power Corporation',
      ratings: 4.4,
    ),
    EVCharger(
      id: 'CHG018',
      name: 'Sports Complex Charger',
      address: 'Sector 16, Chandigarh',
      location: const LatLng(30.7333, 76.7794),
      powerOutput: 85.0,
      connectorTypes: ['CCS2', 'Type 2'],
      isAvailable: true,
      pricePerKWh: 12.30,
      operatingHours: '5:00 AM - 11:00 PM',
      numberOfPorts: 4,
      networkOperator: 'Chandigarh Power',
      ratings: 4.2,
    ),
    EVCharger(
      id: 'CHG019',
      name: 'Business District Charger',
      address: 'BKC, Mumbai, Maharashtra',
      location: const LatLng(19.0560, 72.8369),
      powerOutput: 170.0,
      connectorTypes: ['CCS2', 'CHAdeMO', 'Type 2'],
      isAvailable: true,
      pricePerKWh: 14.25,
      operatingHours: '24/7',
      numberOfPorts: 8,
      networkOperator: 'Tata Power',
      ratings: 4.8,
    ),
    EVCharger(
      id: 'CHG020',
      name: 'Temple Town Charger',
      address: 'RK Beach Road, Puri, Odisha',
      location: const LatLng(19.8135, 85.8312),
      powerOutput: 75.0,
      connectorTypes: ['Type 2', 'AC Type 2'],
      isAvailable: true,
      pricePerKWh: 11.90,
      operatingHours: '6:00 AM - 9:00 PM',
      numberOfPorts: 3,
      networkOperator: 'Odisha Power Generation',
      ratings: 4.0,
    ),
  ];
}
