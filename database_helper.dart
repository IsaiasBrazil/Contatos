import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'models/client.dart'; // Importa o modelo Client

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'clients.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE clients(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            phone TEXT,
            email TEXT,
            address TEXT,
            dob TEXT,
            preferences TEXT,
            observationHistory TEXT
          )
        ''');
      },
    );
  }

  Future<int> insertClient(Client client) async {
    final db = await database;
    return await db.insert('clients', client.toMap());
  }

  Future<List<Client>> getClients() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('clients');
    return List.generate(maps.length, (i) {
      return Client.fromMap(maps[i]);
    });
  }

  Future<int> updateClient(Client client) async {
    final db = await database;
    return await db.update(
      'clients',
      client.toMap(),
      where: 'id = ?',
      whereArgs: [client.id],
    );
  }

  Future<int> deleteClient(int id) async {
    final db = await database;
    return await db.delete(
      'clients',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<bool> insertClientsBatch(BuildContext context,List<Map<String, dynamic>> clients) async {
      final db = await database;
      var batch = db.batch();
      for (var client in clients) {
        batch.insert('clients', client, conflictAlgorithm: ConflictAlgorithm.replace);
      }
      var results =
      await batch.commit();
      if(results.isEmpty){
        showDialog<void>(context: context,
            barrierDismissible:false,
            builder: (BuildContext context){
          return AlertDialog(
            title: Text("Informacao"),
            content: Text('Empty result'),
            actions: [
              TextButton(
                  onPressed: (){
                Navigator.of(context).pop();
              },
                  child: Text('Ok'))
            ],
          );
        });
        return false;
      }
      return true;
  }


}
