import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

String token = "pk.eyJ1IjoiZWxpZWxqdW5pb3IiLCJhIjoiY204M2R6d3N2MG1wMjJqb3Bvejg5M3c0cSJ9.tQgdHOalSYxxPusoxyMpFA";
String urlStyle = "mapbox://styles/elieljunior/cm84uu252007n01qz8nxy5ds7";

class FullMap extends StatefulWidget {
  const FullMap({super.key});

  @override
  State createState() => FullMapState();
}

class FullMapState extends State<FullMap> {
  MapboxMap? mapboxMap;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    await Permission.location.request();
  }

  _onMapCreated(MapboxMap mapboxMap) async {
    this.mapboxMap = mapboxMap;

    await mapboxMap.loadStyleURI(urlStyle);

    await mapboxMap.location.updateSettings(LocationComponentSettings(
      enabled: true,
      locationPuck: LocationPuck(
        locationPuck3D: LocationPuck3D(
          modelUri: "https://raw.githubusercontent.com/KhronosGroup/glTF-Sample-Models/master/2.0/Duck/glTF-Embedded/Duck.gltf",
        ),
      ),
    ));
  }

  var cameraOptions = CameraOptions(
      center: Point(
          coordinates: Position(
            -43.99246, -19.92363,
          )),
      zoom: 16.54);




  @override
  Widget build(BuildContext context) {
    MapboxOptions.setAccessToken(token);

    return Scaffold(
      body: MapWidget(
        key: const ValueKey("mapWidget"),
        cameraOptions: cameraOptions,
        onMapCreated: _onMapCreated,
      ),
    );
  }
}
