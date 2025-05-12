import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:checkpointapp/BancoDeDados/Localizacoes.dart';

String token = "pk.eyJ1IjoiZWxpZWxqdW5pb3IiLCJhIjoiY204M2R6d3N2MG1wMjJqb3Bvejg5M3c0cSJ9.tQgdHOalSYxxPusoxyMpFA";
String urlStyle = "mapbox://styles/elieljunior/cm84uu252007n01qz8nxy5ds7";




class FullMap extends StatefulWidget {
  const FullMap({super.key});

  @override
  State createState() => FullMapState();
}

class FullMapState extends State<FullMap> {
  late final Future<geo.Position?> _posFuture;
  final TextEditingController _descriptionController = TextEditingController();

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

        geo.Position pos = snap.data!;

        return Scaffold(
          body: Stack(
            children: [
              MapWidget(
                key: const ValueKey("map"),
                styleUri: urlStyle,
                onMapCreated: (map) => _onMapCreated(map, pos),
              ),
              DraggableScrollableSheet(
                initialChildSize: 0.4,
                minChildSize: 0.2,
                maxChildSize: 0.6,
                builder: (context, scrollController) {
                  return Container(
                    color: Colors.white,
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.all(16.0),
                      children: [
                        Text("Adicionar Localização"),
                        TextField(
                          controller: _descriptionController,
                          decoration: const InputDecoration(labelText: "Descrição"),
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => LocationDatabase.insertLocationGeo(pos, _descriptionController.text),
                          child: const Text("Salvar Localização"),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}