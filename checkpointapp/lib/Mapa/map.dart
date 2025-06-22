import 'package:checkpointapp/Mapa/location_bottom_sheet.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:checkpointapp/BancoDeDados/localizacoes.dart';
import 'package:checkpointapp/Mapa/search_place.dart';


class FullMap extends StatefulWidget {
  const FullMap({super.key});

  @override
  State createState() => FullMapState();
}

class FullMapState extends State<FullMap> {

  String token = '';
  String urlStyle = '';

  late final Future<Map<String, String>> _mapboxDataFuture;
  late final Future<geo.Position?> _posFuture;
  final TextEditingController _descriptionController = TextEditingController();
  late final Future<List<dynamic>> _initFuture;

  Widget? _mapWidget;

  Uint8List? _defaultIcon;
  Uint8List? _selectedIcon;
  LocationModel? _selectedLocation;
  final Map<String, int> _annotationIdToLocationIdMap = {};

  final ValueNotifier<double> _sheetOffset = ValueNotifier(
    0.4,
  ); // começa no initialChildSize

  void _moveToLocation(double lat, double lng) {
    _mapboxMap?.setCamera(
      CameraOptions(center: Point(coordinates: Position(lng, lat)), zoom: 15.0),
    );
  }

  MapboxMap? _mapboxMap;
  PointAnnotationManager? _pointAnnotationManager;


  Future<void> _loadIcons() async {
    _defaultIcon = (await rootBundle.load('assets/CheckPoint.png')).buffer.asUint8List();
    _selectedIcon = (await rootBundle.load('assets/map_marker.png')).buffer.asUint8List();
  }

  // Chamado quando um marcador é clicado
  void _onAnnotationClick(PointAnnotation annotation) {
    final clickedId = _annotationIdToLocationIdMap[annotation.id];
    if (clickedId == null) return;

    final clickedLocation = _localizacoesSalvas.firstWhere((loc) => loc.id == clickedId);

    _selectLocation(clickedLocation);
  }

  // Lógica para selecionar um local
  Future<void> _selectLocation(LocationModel location) async {
    setState(() {
      _selectedLocation = location;
    });
    //_moveToLocation(location.latitude, location.longitude);
    await _atualizarMarcadoresNoMapa();
  }

  // Lógica para limpar a seleção
  Future<void> _deselect() async {
    setState(() {
      _selectedLocation = null;
    });
    await _atualizarMarcadoresNoMapa();
    await _ajustarCameraParaTodosOsPontos();
  }

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
    if (_pointAnnotationManager == null || _defaultIcon == null || _selectedIcon == null) return;

    // Limpa os marcadores antigos do mapa e mapa de associação
    await _pointAnnotationManager!.deleteAll();
    _annotationIdToLocationIdMap.clear();

    // Loop para criar cada marcador com o ícone e associação
    for (var loc in _localizacoesSalvas) {
      final isSelected = loc.id == _selectedLocation?.id;

      // Cria a anotação no mapa
      final newAnnotation = await _pointAnnotationManager!.create(
        PointAnnotationOptions(
          geometry: Point(coordinates: Position(loc.longitude, loc.latitude)),
          image: isSelected ? _selectedIcon! : _defaultIcon!,
          iconSize: 0.06,
        ),
      );

      // Salva a associação: ID do Mapbox -> ID do Banco de Dados
      _annotationIdToLocationIdMap[newAnnotation.id] = loc.id!;
    }
  }

  List<LocationModel> _localizacoesSalvas = [];

  Future<void> _carregarLocalizacoes() async {
    final localizacoes = await LocationDatabase.getAllLocations();
    setState(() {
      _localizacoesSalvas = localizacoes;
    });
    // Chama a função que vai desenhar os marcadores
    await _atualizarMarcadoresNoMapa();
  }

  @override
  void initState() {
    super.initState();
    _mapboxDataFuture = _carregarDadosMapbox();
    _posFuture = _initLocation();

    _initFuture = Future.wait([_posFuture, _mapboxDataFuture]);

    _loadIcons();
    _requestPermissions();
    _checkLocationServices();

    //_carregarLocalizacoes();
  }

    Future<Map<String, String>> _carregarDadosMapbox() async {
    try {
      final doc = await FirebaseFirestore.instance.collection('codigos_API').doc('Mapbox').get();

      // Pega os dados do documento
      final data = doc.data();
      final tokenData = data?['token'] as String? ?? '';
      final styleData = data?['style'] as String? ?? '';

      if (tokenData.isEmpty || styleData.isEmpty) {
        throw Exception("Token ou Style estão vazios no Firebase.");
      }

      return {'token': tokenData, 'style': styleData};
    } catch (e) {
      if (kDebugMode) {
        print("Erro ao carregar dados do Mapbox: $e");
      }
      // Lança o erro para que o FutureBuilder possa capturaro
      rethrow;
    }
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

    _pointAnnotationManager = await mapboxMap.annotations.createPointAnnotationManager();
    _pointAnnotationManager?.addOnPointAnnotationClickListener(
      AnnotationClickListener(this),
    );


    await _carregarLocalizacoes();

    await _goToUserLocation();

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
              coordinates: Position(position.longitude , position.latitude),
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

    return FutureBuilder<List<dynamic>>(
      future: _initFuture,
      builder: (context, snap) {
        //Conferindo localização
        if ((snap.connectionState != ConnectionState.done)) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snap.hasError || !snap.hasData) {
          return Scaffold(
            body: Center(
              child: Text("Erro ao carregar dados: ${snap.error}"),
            ),
          );
        }

        final results = snap.data!;
        final geo.Position? pos = results[0];
        final Map<String, String> mapboxData = results[1];

        if (pos == null || mapboxData['token']!.isEmpty) {
          return const Scaffold(
            body: Center(child: Text("Não foi possível obter a localização ou o token do mapa.")),
          );
        }

        token = mapboxData['token']!;
        urlStyle = mapboxData['style']!;
        MapboxOptions.setAccessToken(token);

        //if (_mapWidget == null) {
        //_mapWidget =
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
                minChildSize: 0.25,
                maxChildSize: 0.85,
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
                      selectedLocation: _selectedLocation,
                      onDeselect: _deselect,
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
                        20, // da pra ajustar se quiser o botão mais colado
                    right: 16,
                    child: FloatingActionButton(
                      backgroundColor: Colors.white,
                      onPressed: () async {

                        _moveToLocation(
                          -19.924037282188802,
                          -43.99294905590356,
                        );

                      },
                      child: const Icon(Icons.school_rounded),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      /*}else{}

        // RETORNA O WIDGET CARREGADO
        return _mapWidget!;*/
      },

    );
  }
}


class AnnotationClickListener extends OnPointAnnotationClickListener {
  final FullMapState _state;
  AnnotationClickListener(this._state);

  @override
  void onPointAnnotationClick(PointAnnotation annotation) {
    _state._onAnnotationClick(annotation);
  }
}