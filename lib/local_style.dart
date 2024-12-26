import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:path_provider/path_provider.dart';
import 'page.dart';

class LocalStylePage extends ExamplePage {
  const LocalStylePage({super.key})
      : super(const Icon(Icons.map), 'Local style');

  @override
  Widget build(BuildContext context) {
    return const LocalStyle();
  }
}

class LocalStyle extends StatefulWidget {
  const LocalStyle({super.key});

  @override
  State createState() => LocalStyleState();
}

class LocalStyleState extends State<LocalStyle> {
  MapLibreMapController? mapController;
  String? styleAbsoluteFilePath;

  @override
  void initState() {
    super.initState();
    _prepareStyleFile();
  }

  Future<void> _prepareStyleFile() async {
    // Get the application documents directory
    final dir = await getApplicationDocumentsDirectory();
    final documentDir = dir.path;
    final stylesDir = '$documentDir/styles';

    // Ensure the styles directory exists
    await Directory(stylesDir).create(recursive: true);

    // Read the JSON from assets
    String jsonString;
    try {
      // Load the JSON file from assets
      jsonString =
          await rootBundle.loadString('lib/amjad/local_map_style.json');
      // jsonString = await rootBundle.loadString('lib/amjad/local.json');
      // jsonString =
      //     await rootBundle.loadString('lib/amjad/map_demo_style.json');
      // jsonString =
      // await rootBundle.loadString('lib/amjad/raptee_style.json');
    } catch (e) {
      print('Error loading style JSON from assets: $e');
      return;
    }

    // Write the JSON to a file in the app's documents directory
    final styleFile = File('$stylesDir/style.json');
    await styleFile.writeAsString(jsonString);

    // Update the state with the file path
    setState(() {
      styleAbsoluteFilePath = styleFile.path;
    });
  }

  void _onMapCreated(MapLibreMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    final styleAbsoluteFilePath = this.styleAbsoluteFilePath;
    if (styleAbsoluteFilePath == null) {
      return const Scaffold(
        body: Center(child: Text('Creating local style file...')),
      );
    }

    return Scaffold(
      body: MapLibreMap(
        // styleString: styleAbsoluteFilePath,
        // styleString: MapLibreStyles.demo,
        styleString:
            "http://10.0.0.178:8080/styles/test-style/style.json", //for android emulator
        // styleString:
        //     "http://127.0.0.1::8080/styles/test-style/style.json", //for iOS emulator
        // styleString: "https://maps.raptee.com/styles/test-style/style.json",
        onMapCreated: _onMapCreated,
        initialCameraPosition: const CameraPosition(
          target: LatLng(13.067439, 80.237617), // Default center position
          zoom: 8.0,
        ),
        myLocationEnabled: true,
        onStyleLoadedCallback: onStyleLoadedCallback,
      ),
    );
  }

  void onStyleLoadedCallback() {}
}
