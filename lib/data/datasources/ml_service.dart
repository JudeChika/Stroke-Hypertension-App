import 'dart:developer';

/// Lightweight MLService stub (no tflite dependency).
/// - Use this to unblock builds while you fix/upgrade the tflite plugin.
/// - It returns a heuristic probability [0.0 .. 1.0] based on inputs.
/// - When you re-add tflite, replace this with your Interpreter-based logic.
class MLService {
  bool _initialized = false;

  // --- MAGIC NUMBERS (kept for compatibility with original interface)
  static const double meanAge = 55.20091242;
  static const double meanGlucose = 118.84171002;
  static const double meanBMI = 29.44190236;

  static const double scaleAge = 22.14295135;
  static const double scaleGlucose = 55.1206453;
  static const double scaleBMI = 6.5910676;

  Future<void> initialize() async {
    // No real model to load in the stub.
    _initialized = true;
    log("ℹ️ MLService stub initialized (no tflite)");
  }

  Future<double> predict({
    required double age,
    required double avgGlucose,
    required double bmi,
    required bool isMale,
    required bool isMarried,
    required bool isUrban,
    required bool isSmoker,
    required bool hasHypertension,
    required bool hasHeartDisease,
  }) async {
    if (!_initialized) {
      throw Exception("Model not initialized. Call initialize() first.");
    }

    // Heuristic scoring (deterministic, bounded 0.0 - 1.0).
    // This is only a placeholder — replace with your real model later.
    double score = 0.0;

    // Strong signals
    if (hasHeartDisease) score += 0.18;
    if (hasHypertension) score += 0.22;
    if (isSmoker) score += 0.12;

    // Age factor (normalized between 18 and 100 -> scaled 0..0.25)
    final ageNorm = ((age - 18.0) / (100.0 - 18.0)).clamp(0.0, 1.0);
    score += ageNorm * 0.25;

    // BMI factor: overweight increases risk (normalized 18..50 -> 0..0.15)
    final bmiNorm = ((bmi - 18.0) / (50.0 - 18.0)).clamp(0.0, 1.0);
    score += bmiNorm * 0.15;

    // Avg glucose factor: normalized relative to meanGlucose and scale
    final glucoseZ = ((avgGlucose - meanGlucose) / (scaleGlucose)).clamp(-3.0, 3.0);
    // map z to small positive contribution
    score += ((glucoseZ + 3) / 6) * 0.08; // ranges approx 0..0.08

    // Minor adjustments
    if (!isUrban) score += 0.01; // slight rural/urban bias (example)
    if (isMale) score += 0.01; // small gender bias

    // Clamp to valid probability
    score = score.clamp(0.0, 1.0);

    log("🧠 MLService (stub) prediction -> $score (age:$age, bmi:$bmi, glucose:$avgGlucose, smoker:$isSmoker, htn:$hasHypertension, heart:$hasHeartDisease)");
    return score;
  }

  void dispose() {
    _initialized = false;
    log("ℹ️ MLService stub disposed");
  }
}