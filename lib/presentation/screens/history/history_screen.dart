import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/reading_provider.dart';
import '../../../data/models/reading_model.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  String _formatDate(DateTime dt) => DateFormat.yMMMd().add_jm().format(dt);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readingsAsync = ref.watch(readingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('History & Trends')),
      body: readingsAsync.when(
        data: (readings) {
          if (readings.isEmpty) {
            return const Center(child: Text('No readings yet.'));
          }

          // Compute a simple trend summary
          final avgRisk = (readings.map((r) => r.riskScore).fold(0.0, (a, b) => a + b) / readings.length) * 100;
          final latest = readings.first;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Card(
                  elevation: 2,
                  child: ListTile(
                    title: const Text('Latest Risk'),
                    subtitle: Text('${(latest.riskScore * 100).toStringAsFixed(1)}% — ${_formatDate(latest.timestamp)}'),
                    trailing: Text(
                      '${(avgRisk).toStringAsFixed(1)}%\navg',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.separated(
                    itemCount: readings.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (_, idx) {
                      final ReadingModel r = readings[idx];
                      final status = r.riskScore > 0.7 ? 'High' : (r.riskScore > 0.4 ? 'Moderate' : 'Low');
                      final color = r.riskScore > 0.7 ? Colors.redAccent : (r.riskScore > 0.4 ? AppTheme.secondaryYellow : AppTheme.primaryGreen);
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: color,
                          child: Text('${(r.riskScore * 100).toInt()}%', style: const TextStyle(color: Colors.white)),
                        ),
                        title: Text('${r.systolic.toInt()}/${r.diastolic.toInt()} mmHg'),
                        subtitle: Text(_formatDate(r.timestamp)),
                        trailing: Text(status, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error loading history: $e')),
      ),
    );
  }
}