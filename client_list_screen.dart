import 'package:flutter/services.dart';
import 'client_detail_screen.dart';
import 'client_registration_screen.dart';
import 'models/client.dart';
import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';


class ClientListScreen extends StatefulWidget {
  const ClientListScreen({super.key});

  @override
  ClientListScreenState createState() => ClientListScreenState();
}

class ClientListScreenState extends State<ClientListScreen> {
  late final List<Client> _clients=[];
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _loadClients();
  }

  Future<void> _importContacts(BuildContext context) async {
    if (await Permission.contacts.request().isGranted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      try {
        Iterable<Contact> contacts = await ContactsService.getContacts();
        List<Map<String, dynamic>> clientsToInsert = contacts
            .where((contact) => contact.displayName != null)
            .map((contact) => {
          'name': contact.displayName,
          'phone': contact.phones?.isNotEmpty == true
              ? _formatPhoneNumber(contact.phones!.first.value!)
              : '',
          'email': contact.emails?.isNotEmpty == true
              ? contact.emails!.first.value!
              : '',
          'address': '',
          'dob': '',
          'preferences': '',
        })
            .toList();

        bool importSuccess = await _dbHelper.insertClientsBatch(context, clientsToInsert);

        Navigator.pop(context); // Fecha o indicador de carregamento

        if (importSuccess) {
          debugPrint("Indo para o load clients");
          _loadClients(); // Atualiza a lista de clientes

          debugPrint("Feito o load clients");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Contatos importados com sucesso!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erro ao salvar contatos importados.')),
          );
        }
      } catch (e) {
        Navigator.pop(context); // Fecha o indicador de carregamento
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao importar contatos: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permissão para acessar contatos foi negada.')),
      );
    }
  }

  void _confirmImport() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar Importação de contatos'),
        content: const Text('Tem certeza de que deseja importar contatos?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            style: ElevatedButton.styleFrom(backgroundColor:Colors.green,),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              _importContacts(context); // Executa a importação de contatos
              Navigator.of(ctx).pop(); // Fecha o diálogo
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Efetivar Importação'),
          ),
        ],
      ),
    );
  }


  void _loadClients() async {
    final clients = await _dbHelper.getClients();
    setState(() {
      _clients.clear(); // Limpa a lista antes de adicionar os dados atualizados
      _clients.addAll(clients); // Adiciona os clientes ao modelo
    });
  }


  void _addClient(Client client) async {
    await _dbHelper.insertClient(client); // Insere no banco de dados
    _loadClients(); // Recarrega todos os clientes para garantir que a lista esteja sincronizada com o banco de dados
  }



  void _editClient(Client client) async {
    await _dbHelper.updateClient(client);
    _loadClients();
  }


  void _deleteClient(int id) async {
    try {
      await _dbHelper.deleteClient(id);
      setState(() {
        _clients.removeWhere((client) => client.id == id);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao excluir cliente: $e')),
      );
    }
  }




  String _searchQuery = '';

  List<Client> get _filteredClients {
    if (_searchQuery.isEmpty) return _clients;
    return _clients.where((client) {
      final query = _searchQuery.toLowerCase();
      return client.name.toLowerCase().contains(query) ||
          client.phone.toLowerCase().contains(query) ||
          client.email.toLowerCase().contains(query) ||
          client.address.toLowerCase().contains(query) ||
          client.preferences.toLowerCase().contains(query);
    }).toList();
  }

  void _navigateToAddClient({Client? client}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ClientRegistrationScreen(client: client),
      ),
    );
    if (result != null && result is Client) {
      setState(() {
        // Verifique se o cliente existe (se ele for passado ou se for um novo cliente)
        if (client != null) {
          // Atualiza o cliente na lista
          final index = _clients.indexOf(client);
          if (index != -1) {
            _clients[index] = result; // Substitui o cliente na lista
          }
          // Chama a função de edição para atualizar no banco de dados
          _editClient(result);
        } else {
          // Se o cliente for nulo (novo cliente), adiciona à lista
          _clients.add(result);
          // Chama a função de adição para salvar no banco de dados
          _addClient(result);
        }
        _searchQuery=''; //Limpa pesquisa
      });
    }
  }


  void _navigateToClientDetails(Client client) async {
    int cod = client.id ?? 0;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ClientDetailScreen(
          client: client,
          onDelete: () => _deleteClient(cod),
        ),
      ),
    );
    setState(() {}); // Atualiza a lista após possíveis alterações
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clientes'),
        actions: [IconButton(
          icon: const Icon(Icons.import_contacts),
          onPressed: _confirmImport,
        ),
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () {
              // Se você quiser fechar o app
              SystemNavigator.pop(); // Fecha o aplicativo no Android
              // exit(0); // No iOS, você pode usar isso, mas precisa importar 'dart:io'
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Pesquisar cliente',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: _filteredClients.isEmpty
                ? const Center(child: Text('Nenhum cliente encontrado.'))
                : ListView.builder(
              itemCount: _filteredClients.length,
              itemBuilder: (context, index) {
                final client = _filteredClients[index];
                return ListTile(
                  title: Text(client.name),
                  subtitle: Text(client.phone),
                  onTap: () => _navigateToClientDetails(client),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _navigateToAddClient(client: client),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddClient(),
        child: const Icon(Icons.add),
      ),
    );
  }

  String _formatPhoneNumber(String phoneNumber) {
    // Remove qualquer coisa que não seja número
    return phoneNumber.replaceAll(RegExp(r'\D'), '');
  }

}
