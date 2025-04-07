import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

String token = "pk.eyJ1IjoiZWxpZWxqdW5pb3IiLCJhIjoiY204M2R6d3N2MG1wMjJqb3Bvejg5M3c0cSJ9.tQgdHOalSYxxPusoxyMpFA";
String urlStyle = "mapbox://styles/elieljunior/cm84uu252007n01qz8nxy5ds7";

class FullMap extends StatefulWidget {
  const FullMap({super.key});

  @override
  State createState() => FullMapState();
}

class FullMapState extends State<FullMap> {
  MapboxMap? mapboxMap;

  _onMapCreated(MapboxMap mapboxMap) {
    this.mapboxMap = mapboxMap;
  }

  @override
  Widget build(BuildContext context) {
    MapboxOptions.setAccessToken(token); //token da api do Eliel, dps tem que criptografar a api se quiser fazer algo legal
    mapboxMap?.loadStyleURI(urlStyle); //estilo do mapa
    return Scaffold(
        body: MapWidget(

          key: ValueKey("mapWidget"),
          onMapCreated: _onMapCreated,
        ));
  }
}