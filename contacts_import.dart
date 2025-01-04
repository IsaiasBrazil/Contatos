import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'database/database_helper.dart';
import 'models/client.dart';
import 'models/observation.dart';

class ContactsImport {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<void> confirmImport(BuildContext context) async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar Importação de Contatos'),
        content: const Text('Tem certeza de que deseja importar contatos?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _efetivarContatos(context);
              Navigator.of(ctx).pop(); // Fecha o diálogo
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Efetivar Importação'),
          ),
        ],
      ),
    );
  }

  Future<List<Client>> _importContacts(BuildContext context) async {
    List<Client> clientsToInsert = [];
    if (await Permission.contacts.request().isGranted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      try {
        Iterable<Contact> contacts = await ContactsService.getContacts();
        clientsToInsert = contacts
            .where((contact) => contact.displayName != null)
            .map((contact) => Client(
          name: contact.displayName!,
          phone: contact.phones?.isNotEmpty == true
              ? _formatPhoneNumber(contact.phones!.first.value!)
              : '',
          email: contact.emails?.isNotEmpty == true
              ? contact.emails!.first.value!
              : '',
          address: '',
          dob: '',
          preferences: '',
          observationHistory: [
            Observation(
              clientId: 0, // Será atualizado após a inserção do cliente
              content: 'Contato importado.',
              timestamp: DateTime.now(),
            )
          ],
        ))
            .toList();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao importar contatos: $e')),
        );
      } finally {
        Navigator.pop(context); // Fecha o indicador de carregamento
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Permissão para acessar contatos foi negada.')),
      );
    }
    return clientsToInsert;
  }

  Future<void> _efetivarContatos(BuildContext context) async {
    try {
      final importedContacts = await _importContacts(context);
      if (importedContacts.isNotEmpty) {
        for (var client in importedContacts) {
          final clientId = await _dbHelper.insertClient(client); // Obtém o ID do cliente
          for (var observation in client.observationHistory) {
            observation.clientId = clientId; // Atualiza o clientId na observação
            await _dbHelper.insertObservation(observation);
          }
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contatos importados com sucesso!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nenhum contato foi importado.')),
        );
      }
    } catch (e) {
      debugPrint('$e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao efetivar contatos: $e')),
      );
    }
  }

  String _formatPhoneNumber(String phoneNumber) {
    return phoneNumber.replaceAll(RegExp(r'\D'), '');
  }
}
