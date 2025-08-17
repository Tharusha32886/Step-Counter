import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/step_repository.dart';
import '../../data/hive_boxes.dart';
import '../../data/models/settings.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final TextEditingController _goalCtrl;
  late final TextEditingController _heightCtrl;
  late final TextEditingController _weightCtrl;

  @override
  void initState() {
    super.initState();
    final s = settingsBox.get('settings') ?? Settings(dailyGoal: 8000);
    _goalCtrl = TextEditingController(text: s.dailyGoal.toString());
    _heightCtrl = TextEditingController(text: s.heightCm?.toStringAsFixed(0) ?? '');
    _weightCtrl = TextEditingController(text: s.weightKg?.toStringAsFixed(0) ?? '');
  }

  @override
  void dispose() {
    _goalCtrl.dispose();
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<StepRepository>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: _goalCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Daily Step Goal', hintText: 'e.g. 8000'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _heightCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Height (cm)',
                      hintText: 'Improves distance estimate',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _weightCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Weight (kg)'),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () async {
                            final goal = int.tryParse(_goalCtrl.text.trim());
                            if (goal == null || goal <= 0) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(content: Text('Enter a valid goal')));
                              return;
                            }
                            await repo.setGoal(goal);
                            await repo.setProfile(
                              heightCm: double.tryParse(_heightCtrl.text.trim()),
                              weightKg: double.tryParse(_weightCtrl.text.trim()),
                            );
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Settings saved')),
                              );
                            }
                          },
                          icon: const Icon(Icons.save_rounded),
                          label: const Text('Save'),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Card(
            child: ListTile(
              leading: Icon(Icons.info_outline_rounded),
              title: Text('About'),
              subtitle: Text('Attractive dark UI • Offline • Hive storage • Goals & weekly chart'),
            ),
          ),
        ],
      ),
    );
  }
}
