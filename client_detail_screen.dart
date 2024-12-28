import 'models/client.dart';
import 'package:flutter/material.dart';

class ClientDetailScreen extends StatefulWidget {
  final Client client;
  final VoidCallback onDelete;


  const ClientDetailScreen({super.key, required this.client, required this.onDelete});

  @override
  State<ClientDetailScreen> createState() => _ClientDetailScreenState();
}

class _ClientDetailScreenState extends State<ClientDetailScreen> {

  void _deleteAndReturn(BuildContext context) {
    widget.onDelete(); // Chama a função de exclusão
    Navigator.pop(context); // Retorna para a tela anterior
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: const Text('Tem certeza de que deseja excluir este cliente?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop(); // Fecha o diálogo
              _deleteAndReturn(context); // Executa a exclusão e retorna
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    late final List<String> observationHistory = widget.client.observationHistory;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.client.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Telefone: ${widget.client.phone}'),
            Text('E-mail: ${widget.client.email}'),
            Text('Endereço: ${widget.client.address}'),
            Text('Data de Nascimento: ${widget.client.dob}'),
            Text('Preferências: ${widget.client.preferences}'),
            const SizedBox(height: 20),
            const Text(
              'Histórico de Observações',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            if (observationHistory.isNotEmpty)
              ...observationHistory
                  .map((obs) => ListTile(
                title: Text(obs),
                leading: const Icon(Icons.comment),
              ))
                  .toList()
            else Center(
              child: Text('Nenhuma observação disponível. ${observationHistory.length}'),
            ),
          ],
        ),
      ),
    );
  }
}