import 'dart:async';
import 'package:dio/dio.dart';
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
  final String _markerImageName = 'red_marker';
  final String _markerAssetPath = 'assets/red_marker.png';
  // static const LatLng center = LatLng(-33.86711, 151.1947171);

  bool _isMarkerImageAdded = false;
  PageController? _pageController;
  Map<Symbol, EVCharger> markersMap = {};
  EVCharger? selectedCharger;
  bool isShowChargingStations = false;
  Line? line;

  @override
  void dispose() {
    mapController?.onSymbolTapped.remove(_onMarkerTapped);
    super.dispose();
  }

  Future<void> _loadMarkerImage() async {
    if (_isMarkerImageAdded) return;
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

  void _onMapCreated(MapLibreMapController controller) {
    mapController = controller;
    _loadMarkerImage();
    controller.onSymbolTapped.add(_onMarkerTapped);
  }

  void _onStyleLoadedCallback() {
    // addChargerStations();
  }

  void _onMarkerTapped(Symbol symbol) {
    final charger = markersMap[symbol];
    if (charger != null) {
      setState(() {
        selectedCharger = charger;
      });

      // Animate camera to center on selected charger
      mapController?.animateCamera(
        CameraUpdate.newLatLng(charger.location),
      );
    }
  }

  void addChargerStations() {
    for (var charger in evChargers) {
      final symbol = SymbolOptions(
        geometry: charger.location,
        iconImage: _markerImageName,
        iconSize: 0.05,
        textField: charger.name,
        textSize: 12.5,
        textOffset: const Offset(0, 0.8),
        textAnchor: 'top',
        textColor: '#131313',
        textHaloBlur: 1,
        textHaloColor: '#ffffff',
        textHaloWidth: 0.8,
      );

      mapController?.addSymbol(symbol).then((value) {
        markersMap[value] = charger;
      });

      selectedCharger = evChargers[0];
    }
  }

  Widget _buildInfoWindow() {
    if (!isShowChargingStations) return const SizedBox.shrink();

    return Positioned(
      bottom: 16,
      left: 16,
      right: 16,
      child: SizedBox(
        height: 200,
        child: PageView.builder(
            itemCount: evChargers.length,
            controller: _pageController,
            onPageChanged: (value) => setState(() {
                  selectedCharger = evChargers[value];
                  mapController?.animateCamera(
                    CameraUpdate.newLatLng(selectedCharger!.location),
                  );
                }),
            itemBuilder: (context, index) {
              return Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              selectedCharger!.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              setState(() {
                                selectedCharger = null;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        selectedCharger!.address,
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.bolt, color: Colors.blue),
                          Text(' ${selectedCharger!.powerOutput} kW'),
                          const SizedBox(width: 16),
                          Icon(Icons.attach_money, color: Colors.green),
                          Text('₹${selectedCharger!.pricePerKWh}/kWh'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.access_time, color: Colors.orange),
                          const SizedBox(width: 4),
                          Text(selectedCharger!.operatingHours),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.electric_car, color: Colors.purple),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'Connectors: ${selectedCharger!.connectorTypes.join(", ")}',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text('${selectedCharger!.ratings}'),
                          const SizedBox(width: 16),
                          Icon(Icons.ev_station, color: Colors.green),
                          const SizedBox(width: 4),
                          Text('${selectedCharger!.numberOfPorts} ports'),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
      ),
    );
  }

  Future<Map<String, dynamic>> getRoute() async {
    Dio dio = Dio();
    final String path =
        "https://raptee-navigation-dot-raptee-engine.el.r.appspot.com/maps/getRoute";
    Map<String, dynamic>? queryParameters = {
      "points":
          "80.25815458026206,12.97343302427844;80.25906981525418,12.9795527640236",
    };

    Response response = await dio.get(path, queryParameters: queryParameters);
    // print(response.data);
    return response.data;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
          children: [
            MapLibreMap(
              styleString:
                  "https://maps.raptee.com/styles/test-style/style.json",
              onMapCreated: _onMapCreated,
              onStyleLoadedCallback: _onStyleLoadedCallback,
              initialCameraPosition: const CameraPosition(
                target: LatLng(20.5937, 78.9629), // Center of India
                zoom: 4.0,
              ),
              myLocationEnabled: true,
            ),
            _buildInfoWindow(),
          ],
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
                    // _addMarker(LatLng(13.017882, 80.174146));
                  },
                  child: Text("Marker"),
                ),
                ElevatedButton(
                  onPressed: () {
                    // mapController?.removeSymbol(marker!);
                  },
                  child: Text("Remove Marker"),
                ),
                ElevatedButton(
                  onPressed: () {
                    // _addTappableMarker(LatLng(13.017882, 80.274000), (symbol) {
                    //   _onMarkerTapped(marker);
                    // });
                  },
                  child: Text("Tappable Marker"),
                ),
                ElevatedButton(
                  onPressed: () {
                    // _addTappableMarker(LatLng(13.017882, 80.174146), (symbol) {
                    //   _onMarkerTapped(marker);
                    // });
                  },
                  child: Text("Tappable Marker1"),
                ),
                ElevatedButton(
                  onPressed: () {
                    addChargerStations();
                    setState(() {
                      isShowChargingStations = true;
                    });
                  },
                  child: Text("Charger Stations"),
                ),
                ElevatedButton(
                  onPressed: () {
                    mapController!.removeSymbols(markersMap.keys.toList());
                    setState(() {
                      isShowChargingStations = false;
                    });
                  },
                  child: Text("Remove Chargers"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    line = await mapController!.addLine(LineOptions(
                      geometry: [
                        LatLng(13.017882, 80.174146),
                        LatLng(13.017882, 80.274000)
                      ],
                      lineColor: "#ff0000",
                      lineWidth: 2.0,
                    ));

                    mapController!.animateCamera(
                      CameraUpdate.newLatLngBounds(
                        top: 50,
                        bottom: 50,
                        left: 50,
                        right: 50,
                        LatLngBounds(
                          southwest: LatLng(13.017882, 80.174146),
                          northeast: LatLng(13.017882, 80.274000),
                        ),
                      ),
                    );

                    setState(() {});
                  },
                  child: Text("Add Line"),
                ),
                ElevatedButton(
                  onPressed: () {
                    mapController!.removeLine(line!);

                    setState(() {});
                  },
                  child: Text("Remove Line"),
                ),
                ElevatedButton(
                  onPressed: () {
                    getRoute().then((data) async {
                      // print(data);
                      List<LatLng> points = [];
                      data["data"]["routes"][0]["geometry"]["coordinates"]
                          .forEach((element) {
                        print(element);
                        points.add(LatLng(element[1], element[0]));
                      });
                      line = await mapController!.addLine(LineOptions(
                        geometry: points,
                        lineColor: "#40B5AD",
                        lineWidth: 5.0,
                      ));

                      mapController!.animateCamera(
                          CameraUpdate.newLatLngBounds(
                            top: 50,
                            bottom: 50,
                            left: 50,
                            right: 50,
                            LatLngBounds(
                              southwest: points[0],
                              northeast: points[points.length - 1],
                            ),
                          ),
                          duration: Duration(seconds: 2));
                      setState(() {});
                    });
                  },
                  child: Text("Get Route"),
                ),
              ],
            ),
          ),
        ));
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
