import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'services/auth_service.dart';
import 'services/campaign_service.dart';
import 'services/validation_service.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AciaiCuponsApp());
}

class AciaiCuponsApp extends StatefulWidget {
  const AciaiCuponsApp({super.key});

  @override
  State<AciaiCuponsApp> createState() => _AciaiCuponsAppState();
}

class _AciaiCuponsAppState extends State<AciaiCuponsApp> {
  late final AuthService _authService;
  late final CampaignService _campaignService;
  late final ValidationService _validationService;

  @override
  void initState() {
    super.initState();
    _authService = AuthService();
    _campaignService = CampaignService();
    _validationService = ValidationService(campaignService: _campaignService);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cupons ACIAI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: AnimatedBuilder(
        animation: _authService,
        builder: (context, _) {
          if (_authService.isAuthenticated) {
            return HomeScreen(
              authService: _authService,
              campaignService: _campaignService,
              validationService: _validationService,
            );
          }
          return LoginScreen(authService: _authService);
        },
      ),
    );
  }
}
