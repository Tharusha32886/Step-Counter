// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme.dart';
import 'services/step_repository.dart';
import 'services/pedometer_service.dart';
import 'ui/screens/home_screen.dart';
import 'ui/screens/history_screen.dart';
import 'ui/screens/settings_screen.dart';

class StepCounterApp extends StatefulWidget {
  const StepCounterApp({super.key});
  @override
  State<StepCounterApp> createState() => _StepCounterAppState();
}

class _StepCounterAppState extends State<StepCounterApp> {
  int _index = 0;
  final _screens = const [HomeScreen(), HistoryScreen(), SettingsScreen()];

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => StepRepository()..init()),
        Provider(create: (_) => PedometerService()),
      ],
      child: Builder(builder: (context) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final repo = context.read<StepRepository>();
          context.read<PedometerService>().start(repo);
        });

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Step Counter Pro',
          theme: buildDarkTheme(),
          home: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0F0F12), Color(0xFF12141A)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: _screens[_index],
              ),
              bottomNavigationBar: NavigationBar(
                height: 72,
                indicatorColor: Theme.of(context).colorScheme.primary.withOpacity(.2),
                selectedIndex: _index,
                onDestinationSelected: (i) => setState(() => _index = i),
                destinations: const [
                  NavigationDestination(icon: Icon(Icons.directions_walk_rounded), label: 'Today'),
                  NavigationDestination(icon: Icon(Icons.insights_rounded), label: 'History'),
                  NavigationDestination(icon: Icon(Icons.settings_rounded), label: 'Settings'),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
