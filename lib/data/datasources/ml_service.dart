import 'dart:developer';
import 'package:tflite_flutter_plus/tflite_flutter_plus.dart';

class MLService {
  Interpreter? _interpreter;

  // --- 1. MAGIC NUMBERS (From your Jupyter Notebook) ---
  // Replace these with the EXACT numbers your notebook printed out!
  // I have put placeholders here based on standard dataset values.

  // MEANS (The average of the training data)
  static const double meanAge = 55.20091242;
  static const double meanGlucose = 118.84171002;
  static const double meanBMI = 29.44190236;

  // SCALES (Standard Deviation)
  static const double scaleAge = 22.14295135;
  static const double scaleGlucose = 55.1206453;
  static const double scaleBMI = 6.5910676;

  // --- 2. LOAD MODEL ---
  Future<void> initialize() async {
    try {
      // Must match the filename in assets/models/
      _interpreter = await Interpreter.fromAsset('assets/models/stroke_prediction_model.tflite');
      log("✅ ML Model Loaded Successfully");
    } catch (e) {
      log("❌ Failed to load model: $e");
    }
  }

  // --- 3. MAKE PREDICTION ---
  Future<double> predict({
    required double age,
    required double avgGlucose, // We can default this if you don't collect it
    required double bmi,
    required bool isMale,
    required bool isMarried,
    required bool isUrban,
    required bool isSmoker,
    required bool hasHypertension,
    required bool hasHeartDisease,
  }) async {
    if (_interpreter == null) {
      throw Exception("Model not initialized. Call initialize() first.");
    }

    // A. Preprocess Inputs (Scaling)
    // We must scale the continuous values just like we did in Python!
    double scaledAge = (age - meanAge) / scaleAge;
    double scaledGlucose = (avgGlucose - meanGlucose) / scaleGlucose;
    double scaledBMI = (bmi - meanBMI) / scaleBMI;

    // B. Encode Categorical Data (One-Hot / Binary Encoding)
    // The order MUST match exactly what you trained on:
    // [gender, age, hypertension, heart_disease, ever_married, work_type, Residence_type, avg_glucose_level, bmi, smoking_status]

    // For this example, we use simple binary mapping.
    // Note: If you used One-Hot Encoding in Python, you need multiple columns here.
    // Assuming LabelEncoding from your previous snippet:

    double genderVal = isMale ? 0.0 : 1.0; // Male: 0, Female: 1
    double marriedVal = isMarried ? 1.0 : 0.0;
    double workTypeVal = 2.0; // Default to 'Private' (most common) to simplify manual input
    double residenceVal = isUrban ? 1.0 : 0.0;
    double smokingVal = isSmoker ? 1.0 : 0.0; // Smokes: 2, Never: 1... adjusted to your map
    double hypertensionVal = hasHypertension ? 1.0 : 0.0;
    double heartVal = hasHeartDisease ? 1.0 : 0.0;

    // C. Create Input Tensor [1, 10]
    // The shape is 1 row, 10 columns
    var input = [
      [
        genderVal,        // 0
        scaledAge,        // 1
        hypertensionVal,  // 2
        heartVal,         // 3
        marriedVal,       // 4
        workTypeVal,      // 5
        residenceVal,     // 6
        scaledGlucose,    // 7
        scaledBMI,        // 8
        smokingVal        // 9
      ]
    ];

    // D. Create Output Tensor [1, 1]
    // We expect a single probability value between 0 and 1
    var output = List.filled(1 * 1, 0.0).reshape([1, 1]);

    // E. Run Inference
    _interpreter!.run(input, output);

    // F. Return Result
    // The result is in the first list, first element
    double probability = output[0][0];
    log("🧠 Prediction Result: $probability");

    return probability;
  }

  void dispose() {
    _interpreter?.close();
  }
}
