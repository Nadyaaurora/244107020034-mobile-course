import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/optimized/optimized_view.dart';
import 'features/unoptimized/unoptimized_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: PerformanceOptimizationApp()));
}

class PerformanceOptimizationApp extends StatelessWidget {
  const PerformanceOptimizationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Performance Optimization Lab',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
      ),
      home: const MainPerformanceScreen(),
    );
  }
}

class MainPerformanceScreen extends StatefulWidget {
  const MainPerformanceScreen({super.key});

  @override
  State<MainPerformanceScreen> createState() => _MainPerformanceScreenState();
}

class _MainPerformanceScreenState extends State<MainPerformanceScreen> {
  bool _isOptimized = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Optimasi Performa Flutter',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              _isOptimized
                  ? 'Mode SESUDAH Optimasi (60 FPS)'
                  : 'Mode SEBELUM Optimasi (Jank Demo)',
              style: TextStyle(
                fontSize: 12,
                color: _isOptimized ? Colors.green[800] : Colors.red[800],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          Row(
            children: [
              Text(
                _isOptimized ? 'Optimized' : 'Unoptimized',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Switch(
                value: _isOptimized,
                activeThumbColor: Colors.green,
                inactiveThumbColor: Colors.red,
                onChanged: (val) {
                  setState(() {
                    _isOptimized = val;
                  });
                },
              ),
            ],
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: _isOptimized
            ? const OptimizedView(key: ValueKey('optimized'))
            : const UnoptimizedView(key: ValueKey('unoptimized')),
      ),
    );
  }
}
