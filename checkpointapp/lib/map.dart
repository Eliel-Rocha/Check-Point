import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart' as geo;

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
    _checkLocationServices();
  }

  Future<void> _requestPermissions() async {
    var status = await Permission.location.request();
    if (status != PermissionStatus.granted) {
      // Exibe um alerta, retorna, ou lida com a falta de permissão
      if (kDebugMode) {
        print("Permissão de localização negada");
      }
    }
  }

  //parte experimental para usar localização com api geolocator
  Future<void> _checkLocationServices() async {
    bool serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Peça para o usuário ativar o GPS
      if (kDebugMode) {
        print("Serviços de localização desativados.");
      }
    }
  }


  _onMapCreated(MapboxMap mapboxMap) async {
    this.mapboxMap = mapboxMap;

    await mapboxMap.loadStyleURI(urlStyle);


    geo.Position position = await geo.Geolocator.getCurrentPosition();
    await mapboxMap.setCamera(CameraOptions(
      center: Point(coordinates: Position(position.longitude, position.latitude)),
      zoom: 16.0,
    ));


    await mapboxMap.location.updateSettings(LocationComponentSettings(
      enabled: true, // necessário para ativar a exibição da localização
      pulsingEnabled: true,
      locationPuck: LocationPuck(
        locationPuck3D: LocationPuck3D(
          modelUri: "https://raw.githubusercontent.com/KhronosGroup/glTF-Sample-Models/master/2.0/Duck/glTF-Embedded/Duck.gltf",
        ),
      ),
    ));




  }





  @override
  Widget build(BuildContext context) {
    MapboxOptions.setAccessToken(token);

    return Scaffold(
      body: MapWidget(
        key: const ValueKey("mapWidget"),
        onMapCreated: _onMapCreated,
      ),
    );
  }
}
