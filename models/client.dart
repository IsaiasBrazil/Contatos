import 'observation.dart';

class Client {
  int? id;
  String name;
  String phone;
  String email;
  String address;
  String dob; // Data de nascimento
  String preferences; // Preferências do cliente
  List<Observation> observationHistory; // Histórico de observações

  Client({
    this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.address,
    required this.dob,
    required this.preferences,
    this.observationHistory = const [],
  });

  // Converte o objeto Client em um Map para salvar no banco de dados
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
      'dob': dob,
      'preferences': preferences,
    };
  }

  // Cria um objeto Client a partir de um Map do banco de dados
  factory Client.fromMap(Map<String, dynamic> map) {
    return Client(
      id: map['id'],
      name: map['name'],
      phone: map['phone'],
      email: map['email'],
      address: map['address'],
      dob: map['dob'],
      preferences: map['preferences'],
    );
  }
}
