import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/client.dart';
import '../models/observation.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    return openDatabase(
      join(dbPath, 'client_database.db'),
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE clients (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        phone TEXT,
        email TEXT,
        address TEXT,
        dob TEXT,
        preferences TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE observations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        clientId INTEGER,
        content TEXT,
        timestamp TEXT,
        FOREIGN KEY (clientId) REFERENCES clients (id) ON DELETE CASCADE
      )
    ''');
  }

  // CRUD for Clients
  Future<int> insertClient(Client client) async {
    final db = await database;
    return db.insert('clients', client.toMap());
  }

  Future<List<Client>> getClients() async {
    final db = await database;
    final clientMaps = await db.query('clients');

    List<Client> clients = [];
    for (var clientMap in clientMaps) {
      final clientId = clientMap['id'] as int;
      final observations = await getObservations(clientId);

      clients.add(Client.fromMap(clientMap)..observationHistory = observations);
    }

    return clients;
  }

  Future<int> updateClient(Client client) async {
    final db = await database;
    return db.update(
      'clients',
      client.toMap(),
      where: 'id = ?',
      whereArgs: [client.id],
    );
  }

  Future<int> deleteClient(int id) async {
    final db = await database;
    return db.delete(
      'clients',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // CRUD for Observations
  Future<int> insertObservation(Observation observation) async {
    final db = await database;
    return await db.insert('observations', observation.toMap());
  }



  Future<List<Observation>> getObservations(int clientId) async {
    final db = await database;
    final maps = await db.query(
      'observations',
      where: 'clientId = ?',
      whereArgs: [clientId],
      orderBy: 'timestamp DESC', // Most recent observation first
    );

    return List.generate(
      maps.length,
          (index) => Observation.fromMap(maps[index]),
    );
  }

  Future<int> deleteObservation(int id) async {
    final db = await database;
    return db.delete(
      'observations',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
