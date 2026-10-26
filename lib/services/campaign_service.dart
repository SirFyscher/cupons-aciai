import 'package:flutter/foundation.dart';
import '../models/campaign_model.dart';
import '../models/merchant_model.dart';

class CampaignService extends ChangeNotifier {
  // Lista de lojas associadas à ACIAI participantes da campanha
  final List<MerchantModel> _merchants = [
    MerchantModel(
      cnpj: '12345678000190',
      tradeName: 'Supermercado Central ACIAI',
      legalName: 'Comércio de Alimentos Central Ltda',
      category: 'Supermercado',
      address: 'Rua do Comércio, 120 - Centro',
    ),
    MerchantModel(
      cnpj: '98765432000110',
      tradeName: 'Moda & Estilo Boutique',
      legalName: 'Confecções Estilo Ltda',
      category: 'Vestuário e Calçados',
      address: 'Av. Brasil, 450 - Centro',
    ),
    MerchantModel(
      cnpj: '11223344000155',
      tradeName: 'Drogaria Vida e Saúde',
      legalName: 'Farmácia Vida Ltda',
      category: 'Farmácias',
      address: 'Rua XV de Novembro, 88 - Bairro Alto',
    ),
    MerchantModel(
      cnpj: '55667788000122',
      tradeName: 'Ótica Visão Perfeita',
      legalName: 'Comércio Ótico Ltda',
      category: 'Óticas',
      address: 'Praça Matriz, 14 - Centro',
    ),
    MerchantModel(
      cnpj: '99887766000133',
      tradeName: 'Eletro Lar & Cia',
      legalName: 'Magazine Eletro Móveis Ltda',
      category: 'Eletrodomésticos',
      address: 'Rua São Paulo, 210 - Centro',
    ),
  ];

  // Campanhas sazonais
  final List<CampaignModel> _campaigns = [
    CampaignModel(
      id: 'camp_natal_2026',
      title: 'Natal Encantado ACIAI',
      subtitle: 'Compre no comércio local e concorra a grandes prêmios!',
      prizeSummary: '1 Carro 0km + 5 Motos + R\$ 20 mil em vales-compra',
      startDate: DateTime(2026, 11, 1),
      endDate: DateTime(2026, 12, 31, 23, 59, 59),
      minValue: 50.00,
      valuePerLuckyNumber: 50.00,
      isActive: true,
    ),
    CampaignModel(
      id: 'camp_dia_maes_2026',
      title: 'Mês das Mães Premiado',
      subtitle: 'Sua mãe merece o melhor presente do comércio associado',
      prizeSummary: '10 Vales-compra de R\$ 1.000 + 1 Viagem',
      startDate: DateTime(2026, 4, 1),
      endDate: DateTime(2026, 5, 31, 23, 59, 59),
      minValue: 50.00,
      valuePerLuckyNumber: 50.00,
      isActive: false,
    ),
    CampaignModel(
      id: 'camp_dia_pais_2026',
      title: 'Dia dos Pais ACIAI',
      subtitle: 'Presenteie seu herói e concorra a prêmios especiais',
      prizeSummary: 'Smart TVs + Kits Churrasco + Vales-compra',
      startDate: DateTime(2026, 7, 15),
      endDate: DateTime(2026, 8, 30, 23, 59, 59),
      minValue: 50.00,
      valuePerLuckyNumber: 50.00,
      isActive: false,
    ),
  ];

  List<MerchantModel> get merchants => List.unmodifiable(_merchants);
  List<CampaignModel> get campaigns => List.unmodifiable(_campaigns);

  CampaignModel get activeCampaign =>
      _campaigns.firstWhere((c) => c.isActive, orElse: () => _campaigns.first);

  MerchantModel? findMerchantByCnpj(String cleanCnpj) {
    try {
      return _merchants.firstWhere((m) => m.cnpj == cleanCnpj && m.isActive);
    } catch (_) {
      return null;
    }
  }

  List<MerchantModel> searchMerchants(String query) {
    if (query.trim().isEmpty) return _merchants;
    final lower = query.toLowerCase();
    return _merchants.where((m) {
      return m.tradeName.toLowerCase().contains(lower) ||
          m.cnpj.contains(lower) ||
          m.category.toLowerCase().contains(lower);
    }).toList();
  }
}
