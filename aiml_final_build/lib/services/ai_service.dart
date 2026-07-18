import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import '../models/ai_models.dart';

class AiAnalyzerService {
  Future<AiAnalysisResult> analyzeBodyImage(XFile imageFile, String apiKey) async {
    if (apiKey.isEmpty) {
      throw Exception('API Key is empty. Please provide a valid Gemini API Key.');
    }

    final model = GenerativeModel(
      model: 'gemini-flash-latest',
      apiKey: apiKey,
    );

    try {
      final bytes = await imageFile.readAsBytes();
      final DataPart imagePart = DataPart('image/jpeg', bytes);

      final prompt = TextPart('''
Analyze this image of a person to estimate their body fat percentage. 
Provide your response in this EXACT format for easy parsing:

BODY_FAT: [percentage]%
WORKOUT_PLAN: [plan details]
DIET_PLAN: [diet details]

Be as specific and helpful as possible.
''');

      final response = await model.generateContent([
        Content.multi([prompt, imagePart])
      ]);

      if (response.text == null) {
        throw Exception("Failed to generate content from AI.");
      }

      return AiAnalysisResult.fromText(response.text!);

    } catch (e) {
      throw Exception('AI Analysis Failed: $e');
    }
  }
}
