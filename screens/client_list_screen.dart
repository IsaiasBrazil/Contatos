import 'package:flutter/material.dart';
import '../models/client.dart';
import '../database/database_helper.dart';
import 'client_detail_screen.dart';
import 'import_contacts_screen.dart';  // Adicionei a importação da tela de importação

class ClientListScreen extends StatefulWidget {
  const ClientListScreen({Key? key}) : super(key: key);

  @override
  _ClientListScreenState createState() => _ClientListScreenState();
}

class _ClientListScreenState extends State<ClientListScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Client> _clients = [];
  List<Client> _filteredClients = [];  // Lista filtrada de clientes
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadClients();
    _searchController.addListener(_filterClients);
  }

  void _loadClients() async {
    final clients = await _dbHelper.getClients();
    setState(() {
      _clients = clients;
      _filteredClients = clients;  // Inicializa a lista filtrada com todos os clientes
    });
  }

  void _filterClients() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredClients = _clients
          .where((client) =>
      client.name.toLowerCase().contains(query) ||
          (client.phone != null &&
              client.phone!.replaceAll(RegExp(r'\D'), '').contains(query)))
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterClients);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clientes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ImportContactsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: ClientSearchDelegate(_clients),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Buscar Cliente',
                border: OutlineInputBorder(),
                suffixIcon: const Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredClients.length,
              itemBuilder: (context, index) {
                final client = _filteredClients[index];
                return ListTile(
                  title: Text(client.name),
                  subtitle: Text(client.phone ?? 'Sem número de telefone'),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ClientDetailScreen(client: client),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ClientSearchDelegate extends SearchDelegate {
  final List<Client> clients;

  ClientSearchDelegate(this.clients);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = clients
        .where((client) =>
    client.name.toLowerCase().contains(query.toLowerCase()) ||
        (client.phone != null &&
            client.phone!.replaceAll(RegExp(r'\D'), '').contains(query)))
        .toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final client = results[index];
        return ListTile(
          title: Text(client.name),
          subtitle: Text(client.phone ?? 'Sem número de telefone'),
          onTap: () {
            close(context, null);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ClientDetailScreen(client: client),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = clients
        .where((client) =>
    client.name.toLowerCase().contains(query.toLowerCase()) ||
        (client.phone != null &&
            client.phone!.replaceAll(RegExp(r'\D'), '').contains(query)))
        .toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final client = suggestions[index];
        return ListTile(
          title: Text(client.name),
          subtitle: Text(client.phone ?? 'Sem número de telefone'),
          onTap: () {
            query = client.name;
            showResults(context);
          },
        );
      },
    );
  }
}
