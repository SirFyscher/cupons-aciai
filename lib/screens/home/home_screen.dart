import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../../services/campaign_service.dart';
import '../../services/validation_service.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/campaign_card.dart';
import '../scanner/scanner_screen.dart';
import '../coupons/my_coupons_screen.dart';
import '../merchants/merchants_list_screen.dart';

class HomeScreen extends StatelessWidget {
  final AuthService authService;
  final CampaignService campaignService;
  final ValidationService validationService;

  const HomeScreen({
    super.key,
    required this.authService,
    required this.campaignService,
    required this.validationService,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([authService, validationService, campaignService]),
      builder: (context, _) {
        final user = authService.currentUser;
        final campaign = campaignService.activeCampaign;

        return Scaffold(
          appBar: AppBar(
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppTheme.greenBackgroundLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.qr_code_2_rounded, size: 18, color: AppTheme.primaryGreen),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Cupons ACIAI',
                  style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: -0.3),
                ),
              ],
            ),
            actions: [
              IconButton(
                tooltip: 'Sair da Conta',
                icon: const Icon(Icons.logout_rounded, size: 20),
                onPressed: () => authService.logout(),
              ),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Cartão de Saudação e Usuário
                  if (user != null) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceWhite,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.cardBorder),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: AppTheme.greenBackgroundLight,
                            child: Text(
                              user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : 'U',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.primaryGreen,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Olá, ${user.shortName}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'CPF: ${user.cpf}',
                                  style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Botão Gigante de Escanear Cupom (CTA Principal)
                  InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ScannerScreen(
                            validationService: validationService,
                            authService: authService,
                          ),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppTheme.primaryGreen, AppTheme.primaryGreenLight],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryGreen.withOpacity(0.25),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.qr_code_scanner_rounded, size: 36, color: Colors.white),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Validar Cupom Fiscal',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Aponte a câmera para o QR Code da nota',
                                  style: TextStyle(fontSize: 12, color: Colors.white70),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios_rounded, size: 18, color: Colors.white),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Grid de Estatísticas do Participante
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => MyCouponsScreen(validationService: validationService),
                              ),
                            );
                          },
                          child: StatCard(
                            title: 'NÚMEROS DA SORTE',
                            value: validationService.totalLuckyNumbersCount.toString(),
                            subtitle: 'Concorrendo aos sorteios',
                            icon: Icons.confirmation_number_outlined,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => MyCouponsScreen(validationService: validationService),
                              ),
                            );
                          },
                          child: StatCard(
                            title: 'TOTAL EM COMPRAS',
                            value: 'R\$ ${validationService.totalRegisteredValue.toStringAsFixed(0)}',
                            subtitle: '${validationService.validatedCoupons.length} cupons aprovados',
                            icon: Icons.receipt_long_outlined,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Card da Campanha Vigente
                  CampaignCard(campaign: campaign),

                  const SizedBox(height: 20),

                  // Atalhos Rápidos
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceWhite,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.cardBorder),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.storefront_outlined, color: AppTheme.primaryGreen),
                          title: const Text('Lojas Participantes da ACIAI', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                          subtitle: const Text('Consulte os comércios associados', style: TextStyle(fontSize: 11)),
                          trailing: const Icon(Icons.chevron_right, size: 20),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => MerchantsListScreen(campaignService: campaignService),
                              ),
                            );
                          },
                        ),
                        const Divider(height: 1, indent: 56, color: AppTheme.cardBorder),
                        ListTile(
                          leading: const Icon(Icons.receipt_outlined, color: AppTheme.primaryGreen),
                          title: const Text('Extrato de Cupons e Bilhetes', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                          subtitle: const Text('Veja histórico de notas validadas', style: TextStyle(fontSize: 11)),
                          trailing: const Icon(Icons.chevron_right, size: 20),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => MyCouponsScreen(validationService: validationService),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
