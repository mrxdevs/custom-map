import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:maplibre_gl_example/page.dart';

class MapModule extends ExamplePage {
  MapModule(super.leading, super.title);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MapFeaturesScreen();
  }
}

class MapFeaturesScreen extends StatefulWidget {
  const MapFeaturesScreen({super.key});

  @override
  State<MapFeaturesScreen> createState() => _MapFeaturesScreenState();
}

class _MapFeaturesScreenState extends State<MapFeaturesScreen> {
  MapLibreMapController? mapController;
  var isLight = true;

  _onMapCreated(MapLibreMapController controller) {
    mapController = controller;
  }

  _onStyleLoadedCallback() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Style loaded :)"),
        backgroundColor: Theme.of(context).primaryColor,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Future<void> addImageFromAsset(String name, String assetName) async {
    final bytes = await rootBundle.load(assetName);
    final list = bytes.buffer.asUint8List();
    return mapController!.addImage(name, list);
  }

  addMarker() {
    if (mapController != null) {
      mapController!.addSymbol(SymbolOptions(), {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: MapLibreMap(
      styleString: "http://10.0.0.255:8080/styles/test-style/style.json",
      onStyleLoadedCallback: _onStyleLoadedCallback,
      onMapCreated: _onMapCreated,
      initialCameraPosition: const CameraPosition(
        zoom: 8,
        target: LatLng(13.067439, 80.237617),
      ),
      myLocationEnabled: true,
      // gestureRecognizers: null,
      // compassEnabled: true,
      // cameraTargetBounds: CameraTargetBounds(LatLngBounds(
      //     southwest: LatLng(7.798000, 68.14712),
      //     northeast: LatLng(37.090000, 97.34466))),
      // minMaxZoomPreference: MinMaxZoomPreference(3, 20),
      // rotateGesturesEnabled: true,
      // scrollGesturesEnabled: true,
      // zoomGesturesEnabled: true,
      // tiltGesturesEnabled: true,
      // doubleClickZoomEnabled: false,
      // dragEnabled: false,
      // trackCameraPosition: true,
      // myLocationTrackingMode: MyLocationTrackingMode.trackingCompass,
      // myLocationRenderMode: MyLocationRenderMode.gps,
      // logoViewMargins: Point(100, 100),
      // compassViewPosition: CompassViewPosition.topLeft,
      // compassViewMargins: Point(0, 30),
      // attributionButtonPosition: AttributionButtonPosition.topLeft,
      // attributionButtonMargins: Point(0, 0),
      onMapClick: (point, latng) {
        print(" clicked on map----> Point: $point  Lantlng: $latng");
      },

      // onUserLocationUpdated: (_userUpdatedLocation) {
      //   print("User Updated location:------> ${_userUpdatedLocation.position}");
      // },
      onMapLongClick: (point, latng) {
        print(" onLongClicked on map----> Point: $point  Lantlng: $latng");
      },
      onCameraTrackingDismissed: () {
        print("Camera tracing dissmissed");
      },
    ));
  }
}
