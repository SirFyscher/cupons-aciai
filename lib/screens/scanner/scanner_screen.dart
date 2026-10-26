import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/coupon_parser.dart';
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
  final MobileScannerController _cameraController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    formats: const [BarcodeFormat.qrCode, BarcodeFormat.code128],
  );

  bool _isManualInput = false;
  bool _isProcessing = false;
  bool _torchEnabled = false;

  @override
  void dispose() {
    _cameraController.dispose();
    _manualKeyController.dispose();
    _manualValueController.dispose();
    super.dispose();
  }

  Future<double?> _promptForValueIfMissing(ParsedCouponData parsed) async {
    if (parsed.value != null && parsed.value! > 0) {
      return parsed.value;
    }

    final controller = TextEditingController();
    return showDialog<double>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'Confirmar Valor da Nota',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Chave identificada com sucesso!\nCNPJ Emissor: ${parsed.formattedCnpj}',
                style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                autofocus: true,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Valor Total da Compra (R\$)',
                  hintText: 'Ex: 75,90',
                  prefixIcon: Icon(Icons.attach_money_rounded),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(null),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final val = double.tryParse(controller.text.replaceAll(',', '.'));
                Navigator.of(ctx).pop(val);
              },
              child: const Text('Validar'),
            ),
          ],
        );
      },
    );
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

    // Verifica se o QR code possui valor embutido ou se precisa confirmar
    double? finalManualValue = manualValue;
    final parsed = CouponParser.parse(rawText);
    if (parsed != null && finalManualValue == null && parsed.value == null) {
      finalManualValue = await _promptForValueIfMissing(parsed);
      if (finalManualValue == null) {
        setState(() => _isProcessing = false);
        return;
      }
    }

    final result = await widget.validationService.validateAndRegister(
      rawInput: rawText,
      userId: user.id,
      manualValue: finalManualValue,
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
        final randomSuffix = (10000000000000 + DateTime.now().millisecondsSinceEpoch % 89999999999999)
            .toString()
            .padLeft(14, '0')
            .substring(0, 14);
        final key = '352610123456780001906500100001$randomSuffix';
        _processCoupon('https://www.fazenda.sp.gov.br/nfce/qrcode?p=$key|2|1|1|150.00');
        break;

      case 'valor_baixo':
        final randomSuffix = (10000000000000 + DateTime.now().millisecondsSinceEpoch % 89999999999999)
            .toString()
            .padLeft(14, '0')
            .substring(0, 14);
        final key = '352610123456780001906500100001$randomSuffix';
        _processCoupon('https://www.fazenda.sp.gov.br/nfce/qrcode?p=$key|2|1|1|35.00', manualValue: 35.00);
        break;

      case 'loja_nao_participante':
        const key = '35261099999999000199650010001234567890123456';
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
          if (!_isManualInput)
            IconButton(
              tooltip: 'Lanterna',
              icon: Icon(
                _torchEnabled ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                color: _torchEnabled ? AppTheme.primaryGreen : AppTheme.textPrimary,
              ),
              onPressed: () {
                _cameraController.toggleTorch();
                setState(() => _torchEnabled = !_torchEnabled);
              },
            ),
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
              if (!_isManualInput) ...[
                // Visor Real da Câmera com MobileScanner
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    height: 320,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.cardBorder),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        MobileScanner(
                          controller: _cameraController,
                          onDetect: (capture) {
                            if (_isProcessing) return;
                            final List<Barcode> barcodes = capture.barcodes;
                            for (final barcode in barcodes) {
                              final raw = barcode.rawValue;
                              if (raw != null && raw.isNotEmpty) {
                                _processCoupon(raw);
                                break;
                              }
                            }
                          },
                        ),
                        // Mira minimalista em verde sobre a câmera
                        Container(
                          width: 220,
                          height: 220,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppTheme.emeraldAccent.withAlpha(200),
                              width: 2.5,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black.withAlpha(160),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Aponte a câmera para o QR Code da nota',
                              style: TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
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

              const SizedBox(height: 20),
              // Seção de Simulação e Teste de Cenários
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.greenBackgroundLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.primaryGreen.withAlpha(50)),
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
                    const SizedBox(height: 8),
                    const Text(
                      'Toque em um cenário abaixo para simular uma leitura:',
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
}
