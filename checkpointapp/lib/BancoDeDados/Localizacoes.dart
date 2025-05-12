import 'package:geolocator/geolocator.dart' as geo;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocationModel {
  final int? id;
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final String description;

  LocationModel({
    this.id,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    required this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp.toIso8601String(), // ISO 8601 é o formato ideal para armazenar datas
      'description': description,
    };
  }

  factory LocationModel.fromMap(Map<String, dynamic> map) {
    return LocationModel(
      id: map['id'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      timestamp: DateTime.parse(map['timestamp']),
      description: map['description'],
    );
  }
}

class LocationDatabase {
  static Database? _database;

  static Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'locations.db');

    return openDatabase(
      path,
      version: 2,
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE locations (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            latitude REAL,
            longitude REAL,
            timestamp TEXT,
            description TEXT
          )
        ''');
      },
    );
  }

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  // Insere ou atualiza (substitui se o ID já existir)
  static Future<void> insertLocation(LocationModel location) async {
    final db = await database;
    await db.insert(
      'locations',
      location.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> insertLocationGeo(geo.Position position, String description) async {
    final db = await database;
    await db.insert(
      'locations',
      {
        'latitude': position.latitude,
        'longitude': position.longitude,
        'timestamp': DateTime.now().toIso8601String(),
        'description': description
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Retorna todas as localizações salvas
  static Future<List<LocationModel>> getAllLocations() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('locations');
    return maps.map((map) => LocationModel.fromMap(map)).toList();
  }

  // Retorna uma localização específica pelo ID
  static Future<LocationModel?> getLocationById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
    await db.query('locations', where: 'id = ?', whereArgs: [id]);

    if (maps.isNotEmpty) {
      return LocationModel.fromMap(maps.first);
    } else {
      return null;
    }
  }

  // Atualiza uma localização
  static Future<void> updateLocation(LocationModel location) async {
    final db = await database;
    await db.update(
      'locations',
      location.toMap(),
      where: 'id = ?',
      whereArgs: [location.id],
    );
  }

  // Deleta uma localização específica
  static Future<void> deleteLocationById(int id) async {
    final db = await database;
    await db.delete('locations', where: 'id = ?', whereArgs: [id]);
  }

  // Deleta todas as localizações
  static Future<void> deleteAllLocations() async {
    final db = await database;
    await db.delete('locations');
  }
}