class CampaignModel {
  final String id;
  final String title;
  final String subtitle;
  final String prizeSummary; // Ex: "1 Carro 0km + 10 Smart TVs"
  final DateTime startDate;
  final DateTime endDate;
  final double minValue; // Mínimo de R$ 50,00
  final double valuePerLuckyNumber; // A cada R$ 50,00 = 1 cupom/número da sorte
  final bool isActive;
  final String bannerUrl;

  CampaignModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.prizeSummary,
    required this.startDate,
    required this.endDate,
    this.minValue = 50.00,
    this.valuePerLuckyNumber = 50.00,
    this.isActive = true,
    this.bannerUrl = '',
  });

  bool get isOngoing {
    final now = DateTime.now();
    return isActive && now.isAfter(startDate) && now.isBefore(endDate);
  }
}
