class UserModel {
  final String id;
  final String fullName;
  final String cpf;
  final DateTime birthDate;
  final String email;
  final String? phone;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.fullName,
    required this.cpf,
    required this.birthDate,
    required this.email,
    this.phone,
    required this.createdAt,
  });

  String get shortName {
    final parts = fullName.trim().split(' ');
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts.first;
    return '${parts.first} ${parts.last}';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'cpf': cpf,
      'birthDate': birthDate.toIso8601String(),
      'email': email,
      'phone': phone,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      fullName: map['fullName'] ?? '',
      cpf: map['cpf'] ?? '',
      birthDate: DateTime.parse(map['birthDate']),
      email: map['email'] ?? '',
      phone: map['phone'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
