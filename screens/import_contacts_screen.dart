import 'package:flutter/material.dart';
import '../contacts_import.dart';

class ImportContactsScreen extends StatelessWidget {
  const ImportContactsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Importar Contatos')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            ContactsImport().confirmImport(context);
          },
          child: const Text('Importar Contatos'),
        ),
      ),
    );
  }
}
