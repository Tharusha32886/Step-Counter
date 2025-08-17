// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../services/step_repository.dart';
import '../widgets/step_ring.dart';
import '../widgets/weekly_chart.dart';
import '../widgets/today_stats.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<StepRepository>();
    final date = DateFormat('EEEE, d MMM').format(DateTime.now());

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          title: const Text('Step Counter Pro'),
          actions: [
            IconButton(
              tooltip: 'Refresh',
              onPressed: () {}, // placeholder if you want manual refresh
              icon: const Icon(Icons.refresh_rounded),
            )
          ],
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary.withOpacity(.25),
                    const Color(0xFF1C2030),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(color: Colors.white.withOpacity(.06)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Today', style: Theme.of(context).textTheme.titleMedium!.copyWith(color: Colors.white70)),
                        const SizedBox(height: 6),
                        Text(date, style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 10),
                        Text(
                          repo.todaySteps >= repo.goal
                              ? "Great job! Goal reached 🎉"
                              : "Keep going — ${repo.goal - repo.todaySteps} to go",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Mini stat chip
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF222534),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.flag_rounded, size: 18),
                        const SizedBox(height: 6),
                        Text('${repo.goal}', style: Theme.of(context).textTheme.titleMedium),
                        Text('Goal', style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  StepRing(
                    progress: repo.progress,
                    steps: repo.todaySteps,
                    goal: repo.goal,
                  ),
                  const SizedBox(height: 16),
                  TodayStats(distanceKm: repo.todayDistanceKm, calories: repo.todayCalories),
                ],
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Last 7 Days', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  WeeklyChart(days: repo.last7),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 12)),
      ],
    );
  }
}
