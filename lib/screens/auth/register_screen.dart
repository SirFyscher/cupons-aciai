import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/cpf_validator.dart';
import '../../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  final AuthService authService;

  const RegisterScreen({super.key, required this.authService});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _cpfController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();

  DateTime? _selectedBirthDate;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _cpfController.dispose();
    _birthDateController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _onCpfChanged(String value) {
    final formatted = CpfValidator.format(value);
    if (formatted != value) {
      _cpfController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 1, 1),
      firstDate: DateTime(1920),
      lastDate: now,
      helpText: 'SELECIONE SUA DATA DE NASCIMENTO',
      cancelText: 'CANCELAR',
      confirmText: 'CONFIRMAR',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryGreen,
              onPrimary: Colors.white,
              onSurface: AppTheme.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedBirthDate = picked;
        _birthDateController.text =
            '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedBirthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, informe sua data de nascimento.')),
      );
      return;
    }

    try {
      await widget.authService.register(
        fullName: _nameController.text.trim(),
        cpf: _cpfController.text.trim(),
        birthDate: _selectedBirthDate!,
        email: _emailController.text.trim(),
        password: _passwordController.text,
        phone: _phoneController.text.trim(),
      );

      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppTheme.success,
          content: Text('Cadastro realizado com sucesso!'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppTheme.error,
          content: Text(e.toString().replaceAll('Exception: ', '')),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Conta ACIAI'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Cabeçalho simples
                const Text(
                  'Cadastre-se para participar',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Seus dados são necessários para vincular as compras e os números da sorte aos sorteios oficiais.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),

                // Nome Completo
                TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Nome Completo',
                    hintText: 'Ex: Carlos Alberto da Silva',
                    prefixIcon: Icon(Icons.person_outline, color: AppTheme.textSecondary),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Informe seu nome completo';
                    if (!val.trim().contains(' ')) return 'Informe nome e sobrenome';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // CPF
                TextFormField(
                  controller: _cpfController,
                  keyboardType: TextInputType.number,
                  onChanged: _onCpfChanged,
                  decoration: const InputDecoration(
                    labelText: 'CPF',
                    hintText: '000.000.000-00',
                    prefixIcon: Icon(Icons.badge_outlined, color: AppTheme.textSecondary),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Informe seu CPF';
                    if (!CpfValidator.isValid(val)) return 'CPF inválido';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Data de Nascimento
                TextFormField(
                  controller: _birthDateController,
                  readOnly: true,
                  onTap: _pickBirthDate,
                  decoration: const InputDecoration(
                    labelText: 'Data de Nascimento',
                    hintText: 'DD/MM/AAAA',
                    prefixIcon: Icon(Icons.calendar_today_outlined, color: AppTheme.textSecondary),
                    suffixIcon: Icon(Icons.arrow_drop_down, color: AppTheme.textSecondary),
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Selecione sua data de nascimento';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // E-mail
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'E-mail',
                    hintText: 'seu.email@exemplo.com',
                    prefixIcon: Icon(Icons.email_outlined, color: AppTheme.textSecondary),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Informe seu e-mail';
                    if (!val.contains('@') || !val.contains('.')) return 'E-mail inválido';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Celular / WhatsApp
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Telefone / WhatsApp (Opcional)',
                    hintText: '(00) 00000-0000',
                    prefixIcon: Icon(Icons.phone_outlined, color: AppTheme.textSecondary),
                  ),
                ),
                const SizedBox(height: 16),

                // Senha
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Senha',
                    hintText: 'Mínimo de 6 caracteres',
                    prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.textSecondary),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: AppTheme.textSecondary,
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Crie uma senha';
                    if (val.length < 6) return 'A senha deve ter no mínimo 6 caracteres';
                    return null;
                  },
                ),
                const SizedBox(height: 28),

                // Botão de Cadastro
                ElevatedButton(
                  onPressed: widget.authService.isLoading ? null : _submit,
                  child: widget.authService.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Concluir Cadastro'),
                ),
                const SizedBox(height: 16),

                // Termos e Segurança
                const Center(
                  child: Text(
                    'Seus dados estão protegidos sob a LGPD e serão utilizados unicamente para validação das premiações da ACIAI.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
