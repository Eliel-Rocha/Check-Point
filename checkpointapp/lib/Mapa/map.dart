import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'search_place.dart';

String token = "pk.eyJ1IjoiZWxpZWxqdW5pb3IiLCJhIjoiY204M2R6d3N2MG1wMjJqb3Bvejg5M3c0cSJ9.tQgdHOalSYxxPusoxyMpFA";
String urlStyle = "mapbox://styles/elieljunior/cm84uu252007n01qz8nxy5ds7";




class FullMap extends StatefulWidget {
  const FullMap({super.key});

  @override
  State createState() => FullMapState();
}

class FullMapState extends State<FullMap> {
  late final Future<geo.Position?> _posFuture;

  MapboxMap? _mapboxMap;

  void _moveToLocation(double lat, double lng) {
    _mapboxMap?.setCamera(CameraOptions(
      center: Point(coordinates: Position(lng, lat)),
      zoom: 14.0,
    ));
  }





  @override
  void initState() {
    super.initState();
    _posFuture = _initLocation();
    _requestPermissions();
    _checkLocationServices();
  }


  Future<geo.Position?> _initLocation() async {
    final status = await Permission.location.request();
    if (status != PermissionStatus.granted) {
      if (kDebugMode) print("Permissão negada");
      return null;
    }
    if (!await geo.Geolocator.isLocationServiceEnabled()) {
      if (kDebugMode) print("GPS desativado");
    }
    try {
      return await geo.Geolocator.getCurrentPosition(
        desiredAccuracy: geo.LocationAccuracy.high,
      );
    } catch (e) {
      if (kDebugMode) print("Erro ao obter posição: $e");
      return null;
    }
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


  _onMapCreated(MapboxMap mapboxMap, geo.Position? pos) async {
    _mapboxMap =mapboxMap;
    await mapboxMap.loadStyleURI(urlStyle);

    await mapboxMap.location.updateSettings(
      LocationComponentSettings(
        enabled: true,
        pulsingEnabled: true,
      ),
    );

    // se temos posição, centraliza câmera
    if (pos != null) {
      await mapboxMap.setCamera(
        CameraOptions(
          center: Point(coordinates: Position(pos.longitude, pos.latitude)),
          zoom: 16.0,
        ),
      );
    }



  }





  @override
  Widget build(BuildContext context) {
    MapboxOptions.setAccessToken(token);

    return FutureBuilder<geo.Position?>(
      future: _posFuture,
      builder: (context, snap) {
        //Conferindo localização
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.data == null) {
          return const Center(child: Text("Não foi possível obter localização."));
        }

        return Scaffold(
          body: Stack(
            children: [
              MapWidget(
                key: const ValueKey("map"),
                styleUri: urlStyle,
                onMapCreated: (map) => _onMapCreated(map, snap.data),
              ),
              Positioned(
                top: 40,
                left: 16,
                right: 16,
                child: LocationSearch(
                  onResult: _moveToLocation,
                ),
              ),
            ],
          ),
        );

      },
    );
  }
}