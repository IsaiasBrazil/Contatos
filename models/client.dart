class Client {
  int? id; // ID será gerado automaticamente pelo banco de dados
  String name;
  String phone;
  String email;
  String address;
  String dob;
  String preferences;
  List<String> observationHistory;

  Client({
    this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.address,
    required this.dob,
    required this.preferences,
    List<String>? observationHistory,
  }) : observationHistory = observationHistory ?? [];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
      'dob': dob,
      'preferences': preferences,
      'observationHistory': observationHistory.join(';'), // Salva como string separada por ";"
    };
  }

  factory Client.fromMap(Map<String, dynamic> map) {
    return Client(
      id: map['id'],
      name: map['name'],
      phone: map['phone'],
      email: map['email'],
      address: map['address'],
      dob: map['dob'],
      preferences: map['preferences'],
      observationHistory: (map['observationHistory']??"").split(';'),
    );
  }
}
