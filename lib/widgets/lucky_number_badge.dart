import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class LuckyNumberBadge extends StatelessWidget {
  final String number;
  final bool isLarge;

  const LuckyNumberBadge({
    super.key,
    required this.number,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isLarge ? 16 : 10,
        vertical: isLarge ? 10 : 6,
      ),
      decoration: BoxDecoration(
        color: AppTheme.greenBackgroundLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppTheme.primaryGreen.withAlpha(60),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.confirmation_number_outlined,
            size: isLarge ? 20 : 14,
            color: AppTheme.primaryGreen,
          ),
          const SizedBox(width: 6),
          Text(
            number,
            style: TextStyle(
              fontSize: isLarge ? 20 : 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
              color: AppTheme.primaryGreen,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}
