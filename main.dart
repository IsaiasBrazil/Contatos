import 'package:flutter/material.dart';
import 'client_list_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clientes - Doces e Artes da Lili',
      theme: ThemeData(primarySwatch: Colors.purple),
      home: ClientListScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}






