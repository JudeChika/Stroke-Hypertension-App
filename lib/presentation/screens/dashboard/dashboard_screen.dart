import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../../core/theme/app_theme.dart';
import '../manual_input/manual_input_screen.dart'; // We will create this next
import '../auth/login_screen.dart'; // For Logout

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Mock Data (Replace with Riverpod State later)
    const double riskScore = 0.35; // 35% Risk
    const String riskLabel = "Low Risk";
    const Color riskColor = AppTheme.primaryGreen;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Mock Logout
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- 1. Greeting Area ---
              Text(
                "Hello, User 👋",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ).animate().fadeIn(duration: 500.ms).slideX(begin: -0.1),

              const SizedBox(height: 5),

              Text(
                "Here is your latest health analysis.",
                style: Theme.of(context).textTheme.bodyMedium,
              ).animate().fadeIn(delay: 200.ms),

              const SizedBox(height: 25),

              // --- 2. The Risk Score Card (Hero Widget) ---
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
                          const Text(
                            riskLabel,
                            style: TextStyle(
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
                            child: const Text(
                              "Last check: 2 hrs ago",
                              style: TextStyle(color: Colors.white, fontSize: 12),
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
                      percent: riskScore,
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

              const SizedBox(height: 30),

              // --- 3. Quick Actions Grid ---
              Text(
                "Quick Actions",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ).animate().fadeIn(delay: 400.ms),

              const SizedBox(height: 16),

              Row(
                children: [
                  // Manual Input Card
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
                  // History Card
                  Expanded(
                    child: _buildActionCard(
                      context,
                      title: "History",
                      subtitle: "View Trends",
                      icon: Icons.history,
                      color: Colors.blueAccent, // Just for variety
                      onTap: () {
                        // Navigate to History (Future)
                      },
                      delay: 600,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // --- 4. Recent Readings List ---
              Text(
                "Recent Readings",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ).animate().fadeIn(delay: 700.ms),

              const SizedBox(height: 10),

              _buildReadingTile(context, "120/80 mmHg", "Normal", Colors.green, 800),
              _buildReadingTile(context, "145/90 mmHg", "High Risk", Colors.redAccent, 900),
              _buildReadingTile(context, "118/76 mmHg", "Optimal", Colors.green, 1000),
            ],
          ),
        ),
      ),
    );
  }

  // --- Helper Widget: Action Card ---
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

  // --- Helper Widget: Reading List Tile ---
  Widget _buildReadingTile(BuildContext context, String bp, String status, Color statusColor, int delay) {
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
                  Text(bp, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text("Today, 10:00 AM", style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12)),
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
    ).animate().fadeIn(delay: delay.ms).slideX(begin: 0.2);
  }
}