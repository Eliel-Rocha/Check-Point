import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:checkpointapp/BancoDeDados/Localizacoes.dart';
import 'package:checkpointapp/Mapa/search_place.dart';

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


  void _moveToLocation(double lat, double lng) {
    _mapboxMap?.setCamera(CameraOptions(
      center: Point(coordinates: Position(lng, lat)),
      zoom: 14.0,
    ));

  }


  MapboxMap? _mapboxMap;
  PointAnnotationManager? _pointAnnotationManager;

  Future<void> _ajustarCameraParaTodosOsPontos() async {
    // Se não há pontos ou mapa não inicializado, aborta
    if (_localizacoesSalvas.isEmpty || _mapboxMap == null) return;

    // Converte cada LocationModel (latitude/lng) em Point do Mapbox
    final List<Point> pontos = _localizacoesSalvas.map((loc) {
      return Point(coordinates: Position(loc.longitude, loc.latitude));
    }).toList();

    try {
      // Calcula as opções de câmera que enquadram todos os pontos, com padding
      final CameraOptions cameraOptions = await _mapboxMap!.cameraForCoordinates(
        pontos,
        MbxEdgeInsets.decode(80),  // margem interna para não colar nos cantos
        0,                   // bearing (rotação) em graus
        0,                   // pitch (inclinação) em graus
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
      final point = Point(
        coordinates: Position(loc.longitude, loc.latitude),
      );

      final ByteData bytes = await rootBundle.load('assets/CheckPoint.png');
      final Uint8List imageData = bytes.buffer.asUint8List();

      final options = PointAnnotationOptions(
        geometry: point,
        image: imageData,
        iconSize: 0.06, // Ajuste de tamanho
      );

      await _pointAnnotationManager!.create(options);
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
        final point = Point(
          coordinates: Position(loc.longitude, loc.latitude),
        );


        await _pointAnnotationManager!.create(await getoptions(point));
      }
    }
    //TODO: aquii!!
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
      LocationComponentSettings(
        enabled: true,
        pulsingEnabled: true,
      ),
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

    // Carrega o ícone da imagem personalizada
    final ByteData bytes = await rootBundle.load('assets/CheckPoint.png');
    final Uint8List imageData = bytes.buffer.asUint8List();

    // Adiciona os marcadores com ícone
    for (var loc in _localizacoesSalvas) {
      final point = Point(
        coordinates: Position(loc.longitude, loc.latitude),
      );


      await _pointAnnotationManager?.create(await getoptions(point));
    }
    _ajustarCameraParaTodosOsPontos();
  }

  Future<PointAnnotationOptions> getoptions(Point point) async{
    final ByteData bytes = await rootBundle.load('assets/CheckPoint.png');
    final Uint8List imageData = bytes.buffer.asUint8List();

    return PointAnnotationOptions(
      geometry: point,
      iconSize: 0.06,
      image: imageData,
    );
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

              Positioned(
                  top: 40,
                  left: 16,
                  right: 16,
                  child: LocationSearch(
                  onResult: _moveToLocation,
                  ),
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
                          onPressed: () async {
                            String descricao = _descriptionController.text.trim();

                            if (descricao.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Por favor, insira uma descrição.")),
                              );
                              return;
                            }

                            await LocationDatabase.insertLocationGeo(pos, descricao);
                            _descriptionController.clear();


                            await _carregarLocalizacoes();
                            await _atualizarMarcadoresNoMapa();

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Localização salva com sucesso!")),
                            );
                          },
                          child: const Text("Salvar Localização"),
                        ),


                        SizedBox(height: 16),
                        ..._localizacoesSalvas.map((loc) {
                          return ListTile(
                            title: Text(loc.description),
                            subtitle: Text(
                              'Lat: ${loc.latitude.toStringAsFixed(5)}, '
                                  'Lng: ${loc.longitude.toStringAsFixed(5)}\n'
                                  'Data: ${loc.timestamp.toLocal()}',
                            ),
                            isThreeLine: true,
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () async {
                                    final controller = TextEditingController(text: loc.description);

                                    await showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: Text("Editar Descrição"),
                                          content: TextField(
                                            controller: controller,
                                            decoration: InputDecoration(hintText: "Nova descrição"),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(context),
                                              child: Text("Cancelar"),
                                            ),
                                            ElevatedButton(
                                              onPressed: () async {
                                                final novaDescricao = controller.text.trim();
                                                if (novaDescricao.isNotEmpty) {
                                                  final novaLoc = LocationModel(
                                                    id: loc.id,
                                                    latitude: loc.latitude,
                                                    longitude: loc.longitude,
                                                    timestamp: loc.timestamp,
                                                    description: novaDescricao,
                                                  );
                                                  await LocationDatabase.updateLocation(novaLoc);
                                                  Navigator.pop(context);
                                                  await _carregarLocalizacoes();
                                                  await _atualizarMarcadoresNoMapa();
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(content: Text("Descrição atualizada!")),
                                                  );
                                                }
                                              },
                                              child: Text("Salvar"),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () async {
                                    await LocationDatabase.deleteLocationById(loc.id!);
                                    await _carregarLocalizacoes();
                                    await _atualizarMarcadoresNoMapa();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text("Localização removida.")),
                                    );
                                  },
                                ),
                              ],
                            ),
                          );
                        }).toList(),


                        SizedBox(height: 50),


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