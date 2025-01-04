import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/client.dart';
import '../models/observation.dart';

class ClientRegistrationScreen extends StatefulWidget {
  final Client? client;

  ClientRegistrationScreen({this.client});

  @override
  _ClientRegistrationScreenState createState() =>
      _ClientRegistrationScreenState();
}

class _ClientRegistrationScreenState extends State<ClientRegistrationScreen> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  late TextEditingController _dobController;
  late TextEditingController _preferencesController;
  late List<Observation> _observationHistory = [];

  late TextEditingController _observationController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.client?.name ?? '');
    _phoneController = TextEditingController(text: widget.client?.phone ?? '');
    _emailController = TextEditingController(text: widget.client?.email ?? '');
    _addressController =
        TextEditingController(text: widget.client?.address ?? '');
    _dobController = TextEditingController(text: widget.client?.dob ?? '');
    _preferencesController =
        TextEditingController(text: widget.client?.preferences ?? '');
    _observationController = TextEditingController();

    if (widget.client != null) {
      _loadObservations(widget.client!.id!);
    }
  }

  void _loadObservations(int clientId) async {
    final observations = await DatabaseHelper().getObservations(clientId);
    setState(() {
      _observationHistory = observations;
    });
  }

  void _addObservation() {
    if (_observationController.text.isNotEmpty) {
      final newObservation = Observation(
        clientId: widget.client?.id ?? 0, // Substitua "0" por um valor apropriado
        content: _observationController.text,
        timestamp: DateTime.now(),
      );
      setState(() {
        _observationHistory.add(newObservation);
      });
      _observationController.clear();
    }
  }


  void _saveClient() {
    final newClient = Client(
      id: widget.client?.id,
      name: _nameController.text,
      phone: _phoneController.text,
      email: _emailController.text,
      address: _addressController.text,
      dob: _dobController.text,
      preferences: _preferencesController.text,
      observationHistory: _observationHistory,
    );
    Navigator.pop(context, newClient);
  }

  void _confirmDeleteObservation(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmação'),
        content: Text('Você tem certeza de que deseja excluir esta observação?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _observationHistory.removeAt(index);
              });
              Navigator.pop(context);
            },
            child: Text('Excluir'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.client == null ? 'Cadastrar Cliente' : 'Editar Cliente'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Nome completo'),
              ),
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: 'Telefone'),
                keyboardType: TextInputType.phone,
              ),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'E-mail'),
                keyboardType: TextInputType.emailAddress,
              ),
              TextField(
                controller: _addressController,
                decoration: InputDecoration(labelText: 'Endereço'),
              ),
              TextField(
                controller: _dobController,
                decoration: InputDecoration(labelText: 'Data de nascimento'),
                keyboardType: TextInputType.datetime,
              ),
              TextField(
                controller: _preferencesController,
                decoration:
                InputDecoration(labelText: 'Preferências (ex: doces favoritos)'),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _observationController,
                decoration: InputDecoration(labelText: 'Nova observação'),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _addObservation,
                child: Text('Adicionar Observação'),
              ),
              SizedBox(height: 10),
              if (_observationHistory.isNotEmpty)
                ..._observationHistory
                    .asMap()
                    .entries
                    .map(
                      (entry) => ListTile(
                    title: Text(entry.value.content),
                    subtitle: Text(entry.value.timestamp.toString()),
                    leading: Icon(Icons.comment),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => _confirmDeleteObservation(entry.key),
                    ),
                  ),
                )
                    .toList(),
              ElevatedButton(
                onPressed: _saveClient,
                child: Text('Salvar Cliente'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
