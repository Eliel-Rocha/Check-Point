import 'package:checkpointapp/Mapa/location_bottom_sheet.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:checkpointapp/BancoDeDados/localizacoes.dart';
import 'package:checkpointapp/Mapa/search_place.dart';

String token =
    "pk.eyJ1IjoiZWxpZWxqdW5pb3IiLCJhIjoiY204M2R6d3N2MG1wMjJqb3Bvejg5M3c0cSJ9.tQgdHOalSYxxPusoxyMpFA";
String urlStyle = "mapbox://styles/elieljunior/cm84uu252007n01qz8nxy5ds7";

class FullMap extends StatefulWidget {
  const FullMap({super.key});

  @override
  State createState() => FullMapState();
}

class FullMapState extends State<FullMap> {
  late final Future<geo.Position?> _posFuture;
  final TextEditingController _descriptionController = TextEditingController();

  final ValueNotifier<double> _sheetOffset = ValueNotifier(
    0.4,
  ); // começa no initialChildSize

  void _moveToLocation(double lat, double lng) {
    _mapboxMap?.setCamera(
      CameraOptions(center: Point(coordinates: Position(lng, lat)), zoom: 14.0),
    );
  }

  MapboxMap? _mapboxMap;
  PointAnnotationManager? _pointAnnotationManager;

  Future<void> _ajustarCameraParaTodosOsPontos() async {
    // Se não há pontos ou mapa não inicializado, aborta
    if (_localizacoesSalvas.isEmpty || _mapboxMap == null) return;

    // Converte cada LocationModel (latitude/lng) em Point do Mapbox
    final List<Point> pontos =
        _localizacoesSalvas.map((loc) {
          return Point(coordinates: Position(loc.longitude, loc.latitude));
        }).toList();

    try {
      // Calcula as opções de câmera que enquadram todos os pontos, com padding
      final CameraOptions cameraOptions = await _mapboxMap!
          .cameraForCoordinates(
            pontos,
            MbxEdgeInsets.decode(
              80,
            ), // margem interna para não colar nos cantos
            0, // bearing (rotação) em graus
            0, // pitch (inclinação) em graus
          );

      // Anima a câmera para esse enquadramento em 1,5s
      await _mapboxMap!.flyTo(
        cameraOptions,
        MapAnimationOptions(duration: 1500),
      );
    } catch (e) {
      // Em caso de erro, imprime no console para debug
      print('Erro ao ajustar câmera: $e');
    }
  }

  Future<void> _atualizarMarcadoresNoMapa() async {
    if (_pointAnnotationManager == null) return;

    // Remove todos os marcadores existentes
    await _pointAnnotationManager!.deleteAll();

    for (var loc in _localizacoesSalvas) {
      final point = Point(coordinates: Position(loc.longitude, loc.latitude));

      await _pointAnnotationManager!.create(await getoptions(point));
    }
    _ajustarCameraParaTodosOsPontos();
  }

  List<LocationModel> _localizacoesSalvas = [];

  Future<void> _carregarLocalizacoes() async {
    final localizacoes = await LocationDatabase.getAllLocations();

    setState(() {
      _localizacoesSalvas = localizacoes;
    });

    // Após atualizar a lista, redesenha os marcadores
    if (_mapboxMap != null && _pointAnnotationManager != null) {
      await _pointAnnotationManager!.deleteAll();

      for (var loc in localizacoes) {
        final point = Point(coordinates: Position(loc.longitude, loc.latitude));

        await _pointAnnotationManager!.create(await getoptions(point));
      }
    }
    _ajustarCameraParaTodosOsPontos();
  }

  @override
  void initState() {
    super.initState();
    _posFuture = _initLocation();
    _requestPermissions();
    _checkLocationServices();
    //_carregarLocalizacoes();
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

  Future<void> _onMapCreated(MapboxMap mapboxMap, geo.Position? pos) async {
    _mapboxMap = mapboxMap;

    await mapboxMap.loadStyleURI(urlStyle);

    await mapboxMap.location.updateSettings(
      LocationComponentSettings(enabled: true, pulsingEnabled: true),
    );

    if (pos != null) {
      await mapboxMap.setCamera(
        CameraOptions(
          center: Point(coordinates: Position(pos.longitude, pos.latitude)),
          zoom: 16.0,
        ),
      );

      await _carregarLocalizacoes();
      await _atualizarMarcadoresNoMapa();
    }

    _pointAnnotationManager =
        await mapboxMap.annotations.createPointAnnotationManager();

    // Adiciona os marcadores com ícone
    for (var loc in _localizacoesSalvas) {
      final point = Point(coordinates: Position(loc.longitude, loc.latitude));

      await _pointAnnotationManager?.create(await getoptions(point));
    }
    _ajustarCameraParaTodosOsPontos();
  }

  Future<PointAnnotationOptions> getoptions(Point point) async {
    final ByteData bytes = await rootBundle.load('assets/CheckPoint.png');
    final Uint8List imageData = bytes.buffer.asUint8List();

    return PointAnnotationOptions(
      geometry: point,
      iconSize: 0.06,
      image: imageData,
    );
  }

  Future<void> _goToUserLocation() async {
    try {
      geo.Position position = await geo.Geolocator.getCurrentPosition(
        desiredAccuracy: geo.LocationAccuracy.high,
      );

      if (_mapboxMap != null) {
        _mapboxMap!.flyTo(
          CameraOptions(
            center: Point(
              coordinates: Position(position.longitude, position.latitude),
            ),
            zoom: 16.0,
          ),
          MapAnimationOptions(duration: 1000),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print("Erro ao mover para localização atual: $e");
      }
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
          return const Center(
            child: Text("Não foi possível obter localização."),
          );
        }

        geo.Position pos = snap.data!;

        return Scaffold(
          body: Stack(
            children: [
              // MAPA
              MapWidget(
                key: const ValueKey("map"),
                styleUri: urlStyle,
                onMapCreated: (map) => _onMapCreated(map, pos),
              ),

              // BARRA DE PESQUISA
              Positioned(
                top: 40,
                left: 16,
                right: 16,
                child: Row(
                  children: [
                    Expanded(child: LocationSearch(onResult: _moveToLocation)),
                    const SizedBox(width: 8),
                    FloatingActionButton(
                      backgroundColor: Colors.white,
                      mini: true,
                      onPressed: _goToUserLocation,
                      child: const Icon(Icons.my_location),
                    ),
                  ],
                ),
              ),

              // BARRA DE LOCALIZAÇOES SALVAS
              DraggableScrollableSheet(
                initialChildSize: 0.4,
                minChildSize: 0.2,
                maxChildSize: 0.6,
                builder: (context, scrollController) {
                  return NotificationListener<DraggableScrollableNotification>(
                    onNotification: (notification) {
                      _sheetOffset.value = notification.extent;
                      return true;
                    },
                    child: LocationBottomSheet(
                      localizacoes: _localizacoesSalvas,
                      descriptionController: _descriptionController,
                      onAdd: (descricao) async {
                        await LocationDatabase.insertLocationGeo(
                          pos,
                          descricao,
                        );
                        await _carregarLocalizacoes();
                        await _atualizarMarcadoresNoMapa();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Localização salva com sucesso!"),
                          ),
                        );
                      },
                      onEdit: (loc, novaDesc) async {
                        final novaLoc = LocationModel(
                          id: loc.id,
                          latitude: loc.latitude,
                          longitude: loc.longitude,
                          timestamp: loc.timestamp,
                          description: novaDesc,
                        );
                        await LocationDatabase.updateLocation(novaLoc);
                        await _carregarLocalizacoes();
                        await _atualizarMarcadoresNoMapa();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Descrição atualizada!"),
                          ),
                        );
                      },
                      onDelete: (id) async {
                        await LocationDatabase.deleteLocationById(id);
                        await _carregarLocalizacoes();
                        await _atualizarMarcadoresNoMapa();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Localização removida."),
                          ),
                        );
                      },
                      scrollController: scrollController,
                    ),
                  );
                },
              ),

              ValueListenableBuilder<double>(
                valueListenable: _sheetOffset,
                builder: (context, extent, child) {
                  final screenHeight = MediaQuery.of(context).size.height;
                  final sheetHeight = extent * screenHeight;

                  // Ajusta a posição do botão com base no topo da folha
                  return Positioned(
                    bottom:
                        sheetHeight -
                        20, // pode ajustar esse "-20" se quiser o botão mais colado
                    right: 16,
                    child: FloatingActionButton(
                      backgroundColor: Colors.white,
                      onPressed: () async {
                        final location = await LocationDatabase.getLocationById(
                          1,
                        ); // troca o 24 pelo ID que quiser

                        if (location != null) {
                          _moveToLocation(
                            location.latitude,
                            location.longitude,
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Localização não encontrada'),
                            ),
                          );
                        }
                      },
                      child: const Icon(Icons.school_rounded),
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
