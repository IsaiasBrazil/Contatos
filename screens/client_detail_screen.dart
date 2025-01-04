import 'package:flutter/material.dart';
import '../models/client.dart';
import '../models/observation.dart';
import '../database/database_helper.dart';

class ClientDetailScreen extends StatefulWidget {
  final Client client;

  const ClientDetailScreen({Key? key, required this.client}) : super(key: key);

  @override
  _ClientDetailScreenState createState() => _ClientDetailScreenState();
}

class _ClientDetailScreenState extends State<ClientDetailScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  late List<Observation> _observations;

  @override
  void initState() {
    super.initState();
    _observations = [];
    _loadObservations();
  }

  void _loadObservations() async {
    final observations = await _dbHelper.getObservations(widget.client.id!);
    setState(() {
      _observations = observations;
    });
  }

  void _addObservation(String content) async {
    final newObservation = Observation(
      clientId: widget.client.id!,
      content: content,
      timestamp: DateTime.now(),
    );
    await _dbHelper.insertObservation(newObservation);
    _loadObservations();
  }

  void _deleteObservation(int id) async {
    await _dbHelper.deleteObservation(id);
    _loadObservations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Observações de ${widget.client.name}')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _observations.length,
              itemBuilder: (context, index) {
                final observation = _observations[index];
                return ListTile(
                  title: Text(observation.content),
                  subtitle: Text(observation.timestamp.toString()),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _deleteObservation(observation.id!),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: const InputDecoration(labelText: 'Nova observação'),
              onSubmitted: _addObservation,
            ),
          ),
        ],
      ),
    );
  }
}
