import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../services/validation_service.dart';
import '../../services/auth_service.dart';
import 'validation_result_dialog.dart';

class ScannerScreen extends StatefulWidget {
  final ValidationService validationService;
  final AuthService authService;

  const ScannerScreen({
    super.key,
    required this.validationService,
    required this.authService,
  });

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final _manualKeyController = TextEditingController();
  final _manualValueController = TextEditingController();
  bool _isManualInput = false;
  bool _isProcessing = false;

  @override
  void dispose() {
    _manualKeyController.dispose();
    _manualValueController.dispose();
    super.dispose();
  }

  Future<void> _processCoupon(String rawText, {double? manualValue}) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    final user = widget.authService.currentUser;
    if (user == null) {
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Faça login para cadastrar cupons.')),
      );
      return;
    }

    final result = await widget.validationService.validateAndRegister(
      rawInput: rawText,
      userId: user.id,
      manualValue: manualValue,
    );

    setState(() => _isProcessing = false);

    if (!mounted) return;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => ValidationResultDialog(result: result),
    );

    if (result.isApproved && mounted) {
      Navigator.of(context).pop();
    }
  }

  void _submitManual() {
    final key = _manualKeyController.text.replaceAll(RegExp(r'\D'), '');
    if (key.length != 44) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A chave de acesso deve conter exatamente 44 dígitos.')),
      );
      return;
    }

    double? value;
    if (_manualValueController.text.isNotEmpty) {
      value = double.tryParse(_manualValueController.text.replaceAll(',', '.'));
    }

    _processCoupon(key, manualValue: value);
  }

  // Exemplos rápidos para testar todas as regras de negócio
  void _simulateScenario(String type) {
    switch (type) {
      case 'aprovado_150':
        // Supermercado Central (CNPJ 12345678000190), R$ 150.00 -> 3 números da sorte
        final randomSuffix = (10000000 + DateTime.now().millisecondsSinceEpoch % 90000000).toString();
        final key = '3526101234567800019065001000$randomSuffix';
        _processCoupon('https://www.fazenda.sp.gov.br/nfce/qrcode?p=$key|2|1|1|150.00');
        break;

      case 'valor_baixo':
        // R$ 35.00 -> Deve rejeitar (< R$ 50)
        final randomSuffix = (10000000 + DateTime.now().millisecondsSinceEpoch % 90000000).toString();
        final key = '3526101234567800019065001000$randomSuffix';
        _processCoupon('https://www.fazenda.sp.gov.br/nfce/qrcode?p=$key|2|1|1|35.00', manualValue: 35.00);
        break;

      case 'loja_nao_participante':
        // CNPJ aleatório não associado à ACIAI
        final key = '35261099999999000199650010001234567890123456';
        _processCoupon('https://www.fazenda.sp.gov.br/nfce/qrcode?p=$key|2|1|1|180.00');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Validar Cupom Fiscal'),
        actions: [
          IconButton(
            tooltip: _isManualInput ? 'Usar Câmera' : 'Digitar Chave',
            icon: Icon(_isManualInput ? Icons.qr_code_scanner : Icons.keyboard_alt_outlined),
            onPressed: () => setState(() => _isManualInput = !_isManualInput),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Alternância entre Visor da Câmera e Digitação Manual
              if (!_isManualInput) ...[
                // Simulação do Visor de Câmera Minimalista
                Container(
                  height: 320,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.cardBorder),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Linhas de mira (Retículo de Leitura de QR Code)
                      Container(
                        width: 220,
                        height: 220,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.emeraldAccent.withOpacity(0.8), width: 2),
                        ),
                        child: Stack(
                          children: [
                            // 4 cantos estilizados em verde
                            Positioned(top: 0, left: 0, child: _buildCorner(0, 0)),
                            Positioned(top: 0, right: 0, child: _buildCorner(0, 1)),
                            Positioned(bottom: 0, left: 0, child: _buildCorner(1, 0)),
                            Positioned(bottom: 0, right: 0, child: _buildCorner(1, 1)),
                            const Center(
                              child: Icon(
                                Icons.qr_code_2_rounded,
                                size: 80,
                                color: Colors.white24,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        bottom: 20,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Aponte para o QR Code do cupom fiscal',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: TextButton.icon(
                    onPressed: () => setState(() => _isManualInput = true),
                    icon: const Icon(Icons.edit_note_rounded, size: 18),
                    label: const Text('O QR Code está danificado? Digite a chave'),
                  ),
                ),
              ] else ...[
                // Entrada Manual da Chave de 44 dígitos
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceWhite,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.cardBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Digitação Manual da Nota',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'A chave de acesso com 44 dígitos numéricos fica localizada logo abaixo do código de barras da sua nota fiscal.',
                        style: TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.4),
                      ),
                      const SizedBox(height: 18),
                      TextFormField(
                        controller: _manualKeyController,
                        keyboardType: TextInputType.number,
                        maxLength: 44,
                        decoration: const InputDecoration(
                          labelText: 'Chave de Acesso (44 dígitos)',
                          hintText: '3526 1012 3456 7800 0190 ...',
                          prefixIcon: Icon(Icons.vpn_key_outlined, color: AppTheme.textSecondary),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _manualValueController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Valor Total da Nota (R\$)',
                          hintText: 'Ex: 154,80',
                          prefixIcon: Icon(Icons.attach_money_rounded, color: AppTheme.textSecondary),
                        ),
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isProcessing ? null : _submitManual,
                          child: _isProcessing
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Text('Validar e Concorrer'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),
              // Seção de Simulação e Teste de Cenários
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.greenBackgroundLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.bolt_rounded, color: AppTheme.primaryGreen, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Testar Validações do Sistema',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primaryGreen,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Clique em um dos cenários abaixo para simular a leitura instantânea:',
                      style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ActionChip(
                          avatar: const Icon(Icons.check_circle_outline, size: 16, color: AppTheme.success),
                          label: const Text('Compra R\$ 150 (3 Números)'),
                          onPressed: () => _simulateScenario('aprovado_150'),
                        ),
                        ActionChip(
                          avatar: const Icon(Icons.cancel_outlined, size: 16, color: AppTheme.error),
                          label: const Text('Compra < R\$ 50 (Recusa)'),
                          onPressed: () => _simulateScenario('valor_baixo'),
                        ),
                        ActionChip(
                          avatar: const Icon(Icons.storefront_outlined, size: 16, color: AppTheme.warning),
                          label: const Text('Loja Não Participante'),
                          onPressed: () => _simulateScenario('loja_nao_participante'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCorner(int topOrBottom, int leftOrRight) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: AppTheme.emeraldAccent,
        borderRadius: BorderRadius.only(
          topLeft: topOrBottom == 0 && leftOrRight == 0 ? const Radius.circular(8) : Radius.zero,
          topRight: topOrBottom == 0 && leftOrRight == 1 ? const Radius.circular(8) : Radius.zero,
          bottomLeft: topOrBottom == 1 && leftOrRight == 0 ? const Radius.circular(8) : Radius.zero,
          bottomRight: topOrBottom == 1 && leftOrRight == 1 ? const Radius.circular(8) : Radius.zero,
        ),
      ),
    );
  }
}
