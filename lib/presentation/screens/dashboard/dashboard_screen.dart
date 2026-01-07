import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../../core/theme/app_theme.dart';
import '../manual_input/manual_input_screen.dart';
import '../../providers/reading_provider.dart';
import '../../providers/user_provider.dart';
import '../history/history_screen.dart';
import '../../../data/models/reading_model.dart';
import '../../../data/repositories/auth_repository.dart'; // Import AuthRepository

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Read readings stream (existing)
    final readingsAsync = ref.watch(readingsProvider);

    // Read user stream to get the name
    final userAsync = ref.watch(userStreamProvider);
    final firstName = userAsync.value?.fullName.trim().split(' ').first ?? 'User';

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        actions: [
          // LOGOUT BUTTON WITH CONFIRMATION
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: "Logout",
            onPressed: () async {
              final shouldLogout = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Log Out"),
                  content: const Text("Are you sure you want to log out?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text("Log Out", style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );

              if (shouldLogout == true) {
                // This triggers the AuthGate to rebuild and show LoginScreen automatically
                await ref.read(authRepositoryProvider).logout();
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: readingsAsync.when(
        data: (readings) {
          final ReadingModel? latest = readings.isNotEmpty ? readings.first : null;
          final riskScore = latest?.riskScore ?? 0.0;
          final riskLabel = riskScore > 0.7 ? 'High Risk' : (riskScore > 0.4 ? 'Moderate Risk' : 'Low Risk');
          // Color logic
          final riskColor = riskScore > 0.7 ? Colors.redAccent : (riskScore > 0.4 ? AppTheme.secondaryYellow : AppTheme.primaryGreen);

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Greeting Area — personalized with waving emoji
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Hello, $firstName 👋",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ).animate().fadeIn(duration: 500.ms).slideX(begin: -0.1),
                      CircleAvatar(
                        backgroundColor: AppTheme.primaryGreenLight,
                        child: Text(
                          firstName.isNotEmpty ? firstName[0].toUpperCase() : 'U',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ).animate().fadeIn(delay: 200.ms),
                    ],
                  ),

                  const SizedBox(height: 5),

                  Text(
                    "Here is your latest health analysis.",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ).animate().fadeIn(delay: 200.ms),

                  const SizedBox(height: 25),

                  // Hero Risk Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [AppTheme.primaryGreenDark, AppTheme.primaryGreen]
                            : [AppTheme.primaryGreen, AppTheme.primaryGreenLight],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryGreen.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Text Column
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Stroke Risk",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                riskLabel,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  latest != null ? "Last check: ${_formatDate(latest.timestamp)}" : "No checks yet",
                                  style: const TextStyle(color: Colors.white, fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Circular Indicator
                        CircularPercentIndicator(
                          radius: 60.0,
                          lineWidth: 10.0,
                          animation: true,
                          percent: riskScore.clamp(0.0, 1.0),
                          center: Text(
                            "${(riskScore * 100).toInt()}%",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20.0,
                              color: Colors.white,
                            ),
                          ),
                          circularStrokeCap: CircularStrokeCap.round,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          progressColor: AppTheme.secondaryYellow,
                        ).animate().scale(delay: 300.ms, duration: 600.ms, curve: Curves.easeOutBack),
                      ],
                    ),
                  ).animate().slideY(begin: 0.2, duration: 600.ms, curve: Curves.easeOut),

                  const SizedBox(height: 20),

                  // NEW: Hypertension Analysis Card (uses recent readings)
                  _buildHypertensionAnalysisCard(context, readings),

                  const SizedBox(height: 20),

                  // Quick Actions Grid
                  Text(
                    "Quick Actions",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ).animate().fadeIn(delay: 400.ms),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: _buildActionCard(
                          context,
                          title: "Log BP",
                          subtitle: "Manual Entry",
                          icon: Icons.edit_note,
                          color: AppTheme.secondaryYellow,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const ManualInputScreen()),
                            );
                          },
                          delay: 500,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildActionCard(
                          context,
                          title: "History",
                          subtitle: "View Trends",
                          icon: Icons.history,
                          color: Colors.blueAccent,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const HistoryScreen()),
                            );
                          },
                          delay: 600,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // Recent Readings List (from Firestore)
                  Text(
                    "Recent Readings",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ).animate().fadeIn(delay: 700.ms),

                  const SizedBox(height: 10),

                  if (readings.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: const Center(child: Text('No readings yet. Tap "Log BP" to add your first reading.')),
                    )
                  else
                    Column(
                      children: readings.take(5).map((r) {
                        final status = r.riskScore > 0.7 ? 'High Risk' : (r.riskScore > 0.4 ? 'Moderate' : 'Low');
                        final statusColor = r.riskScore > 0.7 ? Colors.redAccent : (r.riskScore > 0.4 ? AppTheme.secondaryYellow : Colors.green);
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    height: 40,
                                    width: 4,
                                    decoration: BoxDecoration(
                                      color: statusColor,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('${r.systolic.toInt()}/${r.diastolic.toInt()} mmHg', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                      Text(_formatDate(r.timestamp), style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12)),
                                    ],
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  status,
                                  style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(delay: 800.ms).slideX(begin: 0.2);
                      }).toList(),
                    ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Failed to load readings: $e')),
      ),
    );
  }

  // --- Hypertension Analysis Card ---
  Widget _buildHypertensionAnalysisCard(BuildContext context, List<ReadingModel> readings) {
    // Use up to last 5 readings for the analysis
    final recent = readings.take(5).toList();
    if (recent.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Hypertension Analysis", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 8),
            Text("No blood pressure readings yet. Tap 'Log BP' to add readings and see analysis."),
          ],
        ),
      );
    }

    // Compute averages
    final avgSys = recent.map((r) => r.systolic).reduce((a, b) => a + b) / recent.length;
    final avgDia = recent.map((r) => r.diastolic).reduce((a, b) => a + b) / recent.length;

    // Count abnormal readings (systolic >= 130 or diastolic >= 80)
    final abnormalCount = recent.where((r) => r.systolic >= 130 || r.diastolic >= 80).length;

    // Heuristic risk percent: proportion of abnormal readings, weighted by severity
    double severitySum = 0;
    for (var r in recent) {
      final s = r.systolic;
      final d = r.diastolic;
      if (s >= 180 || d >= 120) {
        severitySum += 1.0; // crisis
      } else if (s >= 140 || d >= 90) {
        severitySum += 0.9; // stage 2
      } else if (s >= 130 || d >= 80) {
        severitySum += 0.6; // stage 1
      } else if (s >= 120 && d < 80) {
        severitySum += 0.2; // elevated
      } else {
        severitySum += 0.0; // normal
      }
    }
    final riskPercent = (severitySum / recent.length).clamp(0.0, 1.0);

    // Classify based on averages (AHA-like)
    final classification = _classifyBP(avgSys, avgDia);
    final classColor = _colorForClassification(classification);

    // Short recommendation text
    final recommendation = _recommendationForClassification(classification);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Hypertension Analysis", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Row(
            children: [
              // Percent indicator (small)
              CircularPercentIndicator(
                radius: 42,
                lineWidth: 6,
                percent: riskPercent,
                center: Text('${(riskPercent * 100).toInt()}%'),
                progressColor: classColor,
                backgroundColor: Colors.grey.shade200,
              ),
              const SizedBox(width: 12),
              // Summary column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      classification,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: classColor),
                    ),
                    const SizedBox(height: 6),
                    Text("Average: ${avgSys.toStringAsFixed(0)}/${avgDia.toStringAsFixed(0)} mmHg"),
                    const SizedBox(height: 4),
                    Text("Recent abnormal: $abnormalCount of ${recent.length} readings"),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(recommendation, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                // Quick action: navigate to Log BP screen
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ManualInputScreen()));
              },
              child: const Text("Log new reading"),
            ),
          ),
        ],
      ),
    );
  }

  // Classify average BP using AHA-like categories
  String _classifyBP(double sys, double dia) {
    if (sys > 180 || dia > 120) return 'Hypertensive Crisis';
    if (sys >= 140 || dia >= 90) return 'Stage 2 Hypertension';
    if (sys >= 130 || dia >= 80) return 'Stage 1 Hypertension';
    if (sys >= 120 && dia < 80) return 'Elevated';
    return 'Normal';
  }

  Color _colorForClassification(String cls) {
    switch (cls) {
      case 'Hypertensive Crisis':
        return Colors.red.shade700;
      case 'Stage 2 Hypertension':
        return Colors.redAccent;
      case 'Stage 1 Hypertension':
        return Colors.orange;
      case 'Elevated':
        return AppTheme.secondaryYellow;
      default:
        return AppTheme.primaryGreen;
    }
  }

  String _recommendationForClassification(String cls) {
    switch (cls) {
      case 'Hypertensive Crisis':
        return 'This is an emergency. Seek urgent medical attention or call emergency services if you have symptoms (chest pain, severe headache, vision changes).';
      case 'Stage 2 Hypertension':
        return 'High blood pressure detected across recent readings. Please contact your healthcare provider promptly.';
      case 'Stage 1 Hypertension':
        return 'Elevated readings. Schedule a check with your provider and continue monitoring. Lifestyle changes may help.';
      case 'Elevated':
        return 'Slightly elevated blood pressure. Re-check in a few days and make lifestyle adjustments (reduce salt, exercise).';
      default:
        return 'Your recent readings are within the normal range. Keep monitoring and maintain a healthy lifestyle.';
    }
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildActionCard(BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required int delay,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: delay.ms).slideY(begin: 0.2);
  }
}