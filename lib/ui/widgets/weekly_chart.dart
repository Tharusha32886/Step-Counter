// ignore_for_file: deprecated_member_use

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../data/models/step_day.dart';
import 'package:intl/intl.dart';

class WeeklyChart extends StatelessWidget {
  final List<StepDay> days;
  const WeeklyChart({super.key, required this.days});

  @override
  Widget build(BuildContext context) {
    final maxSteps = (days.map((d) => d.steps).fold<int>(0, (a, b) => a > b ? a : b)).clamp(1, 100000);
    final df = DateFormat('E');

    return SizedBox(
      height: 220,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          backgroundColor: const Color(0x00000000),
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (v, _) {
                  final i = v.toInt();
                  if (i < 0 || i >= days.length) return const SizedBox.shrink();
                  return Text(df.format(days[i].date));
                },
              ),
            ),
          ),
          barGroups: List.generate(days.length, (i) {
            final d = days[i];
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: d.steps.toDouble(),
                  width: 18,
                  borderRadius: BorderRadius.circular(8),
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Theme.of(context).colorScheme.primary.withOpacity(.35),
                      Theme.of(context).colorScheme.primary,
                    ],
                  ),
                ),
              ],
            );
          }),
          maxY: (maxSteps.toDouble() * 1.1),
        ),
        swapAnimationDuration: const Duration(milliseconds: 500),
        swapAnimationCurve: Curves.easeOutCubic,
      ),
    );
  }
}
