import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/datasources/ml_service.dart';
import '../../../data/repositories/reading_repository.dart';

class ManualInputScreen extends ConsumerStatefulWidget {
  const ManualInputScreen({super.key});

  @override
  ConsumerState<ManualInputScreen> createState() => _ManualInputScreenState();
}

class _ManualInputScreenState extends ConsumerState<ManualInputScreen> {
  final MLService _mlService = MLService();

  double _systolic = 120;
  double _diastolic = 80;
  double _age = 30;
  double _bmi = 22;
  bool _isSmoker = false;
  bool _isCalculating = false;

  @override
  void initState() {
    super.initState();
    _mlService.initialize();
  }

  @override
  void dispose() {
    _mlService.dispose();
    super.dispose();
  }

  Future<void> _calculateRisk() async {
    setState(() => _isCalculating = true);

    try {
      final riskProbability = await _mlService.predict(
        age: _age,
        bmi: _bmi,
        isMale: true,
        isMarried: true,
        isUrban: true,
        isSmoker: _isSmoker,
        hasHypertension: _systolic > 140,
        hasHeartDisease: false,
        avgGlucose: 100.0,
      );

      await ref.read(readingRepositoryProvider).saveReading(
        systolic: _systolic,
        diastolic: _diastolic,
        riskScore: riskProbability,
        age: _age,
        bmi: _bmi,
      );

      if (mounted) {
        setState(() => _isCalculating = false);
        // Show confirmation and pop back so dashboard (stream) updates automatically
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Reading saved ✓'),
            backgroundColor: AppTheme.primaryGreen,
            duration: const Duration(seconds: 2),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isCalculating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Log Vitals"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Enter your current readings",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.textGrey,
              ),
            ).animate().fadeIn(),

            const SizedBox(height: 24),

            // BP sliders
            _buildSectionCard(
              title: "Blood Pressure",
              icon: Icons.favorite_outline,
              child: Column(
                children: [
                  _buildSlider(
                    label: "Systolic (Top)",
                    value: _systolic,
                    min: 80,
                    max: 200,
                    unit: "mmHg",
                    color: Colors.redAccent,
                    onChanged: (val) => setState(() => _systolic = val),
                  ),
                  const Divider(height: 30),
                  _buildSlider(
                    label: "Diastolic (Bottom)",
                    value: _diastolic,
                    min: 50,
                    max: 130,
                    unit: "mmHg",
                    color: AppTheme.secondaryYellowDark,
                    onChanged: (val) => setState(() => _diastolic = val),
                  ),
                ],
              ),
            ).animate().slideY(begin: 0.2, duration: 400.ms),

            const SizedBox(height: 20),

            // Age & BMI (now editable and saved)
            _buildSectionCard(
              title: "Risk Factors",
              icon: Icons.person_outline,
              child: Column(
                children: [
                  // Age slider
                  _buildSlider(
                    label: "Age",
                    value: _age,
                    min: 18,
                    max: 100,
                    unit: "years",
                    color: AppTheme.primaryGreen,
                    onChanged: (val) => setState(() => _age = val),
                  ),
                  const Divider(height: 30),
                  // BMI slider
                  _buildSlider(
                    label: "BMI",
                    value: _bmi,
                    min: 10,
                    max: 50,
                    unit: "",
                    color: Colors.blueGrey,
                    onChanged: (val) => setState(() => _bmi = val),
                  ),
                  const Divider(height: 30),
                  // Smoking Switch
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text("Do you smoke?", style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text("Includes occasional usage"),
                    activeColor: AppTheme.secondaryYellow,
                    value: _isSmoker,
                    onChanged: (val) => setState(() => _isSmoker = val),
                  ),
                ],
              ),
            ).animate().slideY(begin: 0.2, delay: 100.ms, duration: 400.ms),

            const SizedBox(height: 30),

            SizedBox(
              height: 55,
              child: ElevatedButton(
                onPressed: _isCalculating ? null : _calculateRisk,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  foregroundColor: Colors.white,
                  elevation: 4,
                ),
                child: _isCalculating
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.analytics_outlined),
                    SizedBox(width: 10),
                    Text("ANALYZE RISK"),
                  ],
                ),
              ),
            ).animate().slideY(begin: 0.5, delay: 200.ms),
          ],
        ),
      ),
    );
  }

  // Helper widget implementations (same logic as earlier)
  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.primaryGreen),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required String unit,
    required Color color,
    required Function(double) onChanged,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
            Text(
              "${value.toInt()} $unit",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: color,
            thumbColor: color,
            inactiveTrackColor: color.withValues(alpha: 0.1),
            overlayColor: color.withValues(alpha: 0.1),
            trackHeight: 6.0,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10.0),
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: (max - min).toInt(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}