import 'package:maplibre_gl/maplibre_gl.dart';

class EVCharger {
  final String id;
  final String name;
  final String address;
  final LatLng location;
  final double powerOutput; // in kW
  final List<String> connectorTypes;
  final bool isAvailable;
  final double pricePerKWh;
  final String operatingHours;
  final int numberOfPorts;
  final String networkOperator;
  final double ratings;

  EVCharger({
    required this.id,
    required this.name,
    required this.address,
    required this.location,
    required this.powerOutput,
    required this.connectorTypes,
    required this.isAvailable,
    required this.pricePerKWh,
    required this.operatingHours,
    required this.numberOfPorts,
    required this.networkOperator,
    required this.ratings,
  });
}
