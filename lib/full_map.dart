import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

import 'page.dart';

class FullMapPage extends ExamplePage {
  const FullMapPage({super.key})
      : super(const Icon(Icons.map), 'Full screen map');

  @override
  Widget build(BuildContext context) {
    return const FullMap();
  }
}

class FullMap extends StatefulWidget {
  const FullMap({super.key});

  @override
  State createState() => FullMapState();
}

class FullMapState extends State<FullMap> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // TODO: commented out when cherry-picking https://github.com/flutter-mapbox-gl/maps/pull/775
        // needs different dark and light styles in this repo
        // floatingActionButton: Padding(
        // padding: const EdgeInsets.all(32.0),
        // child: FloatingActionButton(
        // child: Icon(Icons.swap_horiz),
        // onPressed: () => setState(
        // () => isLight = !isLight,
        // ),
        // ),
        // ),
        body: MapLibreMap(
      // styleString: MapLibreStyles.demo,

      // styleString: "http://34.93.16.227:8080/styles/test-style/style.json",
      styleString: "http://127.0.0.1:8080/styles/test-style/style.json",
      // styleString:
      //     "https://github.com/openmaptiles/maptiler-3d-gl-style/blob/master/style.json",

      onMapCreated: _onMapCreated,

      initialCameraPosition:
          const CameraPosition(zoom: 8, target: LatLng(0, 0)),
      onStyleLoadedCallback: _onStyleLoadedCallback,
    ));
  }
}
