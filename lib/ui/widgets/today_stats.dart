// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class TodayStats extends StatelessWidget {
  final double distanceKm;
  final double calories;

  const TodayStats({
    super.key,
    required this.distanceKm,
    required this.calories,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    Widget tile(String label, String value, IconData icon) {
      return Expanded(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0x221C1F28),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(.06)),
          ),
          child: Column(
            children: [
              Icon(icon),
              const SizedBox(height: 8),
              Text(value, style: text.titleLarge),
              const SizedBox(height: 4),
              Text(label, style: text.bodySmall!.copyWith(color: Colors.white70)),
            ],
          ),
        ),
      );
    }

    return Row(
      children: [
        tile('Distance', '${distanceKm.toStringAsFixed(2)} km', Icons.pin_drop_outlined),
        const SizedBox(width: 12),
        tile('Calories', '${calories.toStringAsFixed(0)} kcal', Icons.local_fire_department_outlined),
      ],
    );
  }
}
