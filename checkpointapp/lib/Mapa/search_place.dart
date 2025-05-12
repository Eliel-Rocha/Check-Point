import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// Token da Mapbox (idealmente importar de outro arquivo/config)
const String mapboxAccessToken = "pk.eyJ1IjoiZWxpZWxqdW5pb3IiLCJhIjoiY204M2R6d3N2MG1wMjJqb3Bvejg5M3c0cSJ9.tQgdHOalSYxxPusoxyMpFA";

class LocationSearch extends StatefulWidget {
  final void Function(double latitude, double longitude) onResult;

  const LocationSearch({super.key, required this.onResult});

  @override
  State<LocationSearch> createState() => _LocationSearchState();
}

class _LocationSearchState extends State<LocationSearch> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> _results = [];

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) return;

    final uri = Uri.parse(
      "https://api.mapbox.com/geocoding/v5/mapbox.places/${Uri.encodeComponent(query)}.json?access_token=$mapboxAccessToken",
    );

    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final features = data["features"] as List;

      setState(() {
        _results = features.map((f) {
          return {
            "name": f["place_name"],
            "lat": f["center"][1],
            "lng": f["center"][0],
          };
        }).toList();
      });
    } else {
      // erro
      if (kDebugMode) {
        print("Erro ao buscar localização: ${response.statusCode}");
      }
    }
  }

  void _selectResult(Map<String, dynamic> item) {
    widget.onResult(item["lat"], item["lng"]);
    _controller.clear();
    setState(() => _results = []);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(8),
          child: TextField(
            controller: _controller,
            decoration: const InputDecoration(
              hintText: 'Buscar lugar...',
              prefixIcon: Icon(Icons.search),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(12),
            ),
            onChanged: _search,
          ),
        ),
        if (_results.isNotEmpty)
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _results.length,
              itemBuilder: (context, index) {
                final item = _results[index];
                return ListTile(
                  title: Text(item["name"]),
                  onTap: () => _selectResult(item),
                );
              },
            ),
          ),
      ],
    );
  }
}
