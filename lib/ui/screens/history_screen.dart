// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../services/step_repository.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<StepRepository>();
    final df = DateFormat('EEE, d MMM');

    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
        itemCount: repo.last7.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, i) {
          final d = repo.last7[i];
          final pct = d.goal == 0 ? 0.0 : (d.steps / d.goal).clamp(0, 1.0);
          final hit = d.steps >= d.goal;
          return Card(
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              leading: CircleAvatar(
                radius: 22,
                backgroundColor: hit
                    ? Theme.of(context).colorScheme.primary.withOpacity(.25)
                    : const Color(0xFF252839),
                child: Icon(hit ? Icons.emoji_events_rounded : Icons.calendar_today_rounded),
              ),
              title: Text(df.format(d.date)),
              subtitle: Text(
                'Steps ${d.steps} • ${d.distanceKm.toStringAsFixed(2)} km • ${d.calories.toStringAsFixed(0)} kcal',
              ),
              trailing: SizedBox(
                width: 66,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(value: pct.toDouble(), minHeight: 10),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
