import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../core/utils/cpf_validator.dart';

class AuthService extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;

  AuthService() {
    // Usuário padrão de demonstração para teste imediato
    _currentUser = UserModel(
      id: 'user_01',
      fullName: 'Carlos Eduardo Oliveira',
      cpf: '345.678.912-34',
      birthDate: DateTime(1988, 7, 24),
      email: 'carlos.oliveira@email.com',
      phone: '(19) 99876-5432',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    );
  }

  Future<bool> register({
    required String fullName,
    required String cpf,
    required DateTime birthDate,
    required String email,
    required String password,
    String? phone,
  }) async {
    _isLoading = true;
    notifyListeners();

    // Simulação de chamada de API/Firebase
    await Future.delayed(const Duration(milliseconds: 600));

    if (!CpfValidator.isValid(cpf)) {
      _isLoading = false;
      notifyListeners();
      throw Exception('CPF inválido. Verifique os números digitados.');
    }

    _currentUser = UserModel(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      fullName: fullName,
      cpf: CpfValidator.format(cpf),
      birthDate: birthDate,
      email: email,
      phone: phone,
      createdAt: DateTime.now(),
    );

    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 600));

    // Demo login
    _currentUser = UserModel(
      id: 'usr_demo',
      fullName: 'Carlos Eduardo Oliveira',
      cpf: '345.678.912-34',
      birthDate: DateTime(1988, 7, 24),
      email: email,
      phone: '(19) 99876-5432',
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    );

    _isLoading = false;
    notifyListeners();
    return true;
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}
