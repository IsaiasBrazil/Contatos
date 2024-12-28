import 'package:flutter/material.dart';
import 'models/client.dart';

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
  late List<String> _observationHistory = [];

  late TextEditingController _observationController;

  void _addObservation() {
    if (_observationController.text.isNotEmpty) {
      setState(() {
        _observationHistory.add(
            "${_observationController.text} - ${DateTime.now().toString()}");
        //_observationController.clear();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.client?.name ?? '');
    _phoneController =
        TextEditingController(text: widget.client?.phone ?? '');
    _emailController =
        TextEditingController(text: widget.client?.email ?? '');
    _addressController =
        TextEditingController(text: widget.client?.address ?? '');
    _dobController =
        TextEditingController(text: widget.client?.dob ?? '');
    _preferencesController =
        TextEditingController(text: widget.client?.preferences ?? '');
    _observationController = TextEditingController(
      text: '',
    );
    _observationHistory = widget.client?.observationHistory??[];
  }

  void _saveClient() {
    final newClient = Client(
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
                decoration: InputDecoration(
                    labelText: 'Preferências (ex: doces favoritos)'),
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
          .asMap() // Para obter o índice da observação
          .entries
              .map(
            (entry) => ListTile(
          title: Text(entry.value),
          leading: Icon(Icons.comment),
          trailing: IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
                _confirmDeleteObservation(entry.key); // Remove a observação pelo índice
            },
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

    void _confirmDeleteObservation(int key) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Confirmação'),
          content: Text('Você tem certeza de que deseja excluir esta observação?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Fecha o diálogo sem excluir
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _observationHistory.removeAt(key); // Remove a observação
                _saveClient();
                });
                Navigator.pop(context); // Fecha o diálogo
              },
              child: Text('Excluir'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
          ],
        ),
      );
    }


}
