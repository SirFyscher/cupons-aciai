import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../services/campaign_service.dart';

class MerchantsListScreen extends StatefulWidget {
  final CampaignService campaignService;

  const MerchantsListScreen({super.key, required this.campaignService});

  @override
  State<MerchantsListScreen> createState() => _MerchantsListScreenState();
}

class _MerchantsListScreenState extends State<MerchantsListScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final merchants = widget.campaignService.searchMerchants(_query);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lojas Participantes ACIAI'),
      ),
      body: Column(
        children: [
          // Barra de Pesquisa
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _query = val),
              decoration: InputDecoration(
                hintText: 'Buscar loja por nome, CNPJ ou categoria...',
                prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
              ),
            ),
          ),

          Expanded(
            child: merchants.isEmpty
                ? const Center(
                    child: Text(
                      'Nenhuma loja encontrada para a pesquisa.',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: merchants.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final merchant = merchants[index];
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceWhite,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppTheme.cardBorder),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppTheme.greenBackgroundLight,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.storefront_outlined,
                                color: AppTheme.primaryGreen,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          merchant.tradeName,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: AppTheme.textPrimary,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppTheme.greenBackgroundLight,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: const Text(
                                          'Participante',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: AppTheme.primaryGreen,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    merchant.category,
                                    style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    merchant.address,
                                    style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'CNPJ: ${merchant.formattedCnpj}',
                                    style: const TextStyle(fontSize: 10, color: AppTheme.textMuted, fontFamily: 'monospace'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
