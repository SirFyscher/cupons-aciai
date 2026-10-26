import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../services/validation_service.dart';
import '../../widgets/lucky_number_badge.dart';

class ValidationResultDialog extends StatelessWidget {
  final ValidationResult result;

  const ValidationResultDialog({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final isApproved = result.isApproved;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: AppTheme.surfaceWhite,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Ícone de Status
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: isApproved ? AppTheme.greenBackgroundLight : const Color(0xFFFEF2F2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isApproved ? Icons.check_circle_outline_rounded : Icons.highlight_off_rounded,
                size: 38,
                color: isApproved ? AppTheme.success : AppTheme.error,
              ),
            ),
            const SizedBox(height: 16),

            // Título
            Text(
              result.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: isApproved ? AppTheme.primaryGreen : AppTheme.error,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 10),

            // Mensagem explicativa
            Text(
              result.message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
                height: 1.4,
              ),
            ),

            if (isApproved && result.coupon != null) ...[
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundLight,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.cardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Loja Participante:', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                        Text(
                          result.coupon!.merchant.tradeName,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Valor da Compra:', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                        Text(
                          'R\$ ${result.coupon!.totalValue.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.primaryGreen),
                        ),
                      ],
                    ),
                    const Divider(height: 20, color: AppTheme.cardBorder),
                    const Text(
                      'SEUS NÚMEROS DA SORTE:',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: result.generatedLuckyNumbers.map((num) {
                        return LuckyNumberBadge(number: num, isLarge: true);
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK, Entendido'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
