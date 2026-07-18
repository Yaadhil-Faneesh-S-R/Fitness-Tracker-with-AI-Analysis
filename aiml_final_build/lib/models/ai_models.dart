class AiAnalysisResult {
  final double estimatedBodyFatPercentage;
  final String workoutPlan;
  final String dietPlan;
  final String rawResponse;

  AiAnalysisResult({
    required this.estimatedBodyFatPercentage,
    required this.workoutPlan,
    required this.dietPlan,
    required this.rawResponse,
  });

  factory AiAnalysisResult.fromText(String aiResponse) {
    // Basic parser to attempt extracting body fat percentage
    double bodyFat = 0.0;
    
    try {
      // Robust regex that allows for optional percentage sign and various spaces
      final RegExp bfRegex = RegExp(r"BODY_FAT:\s*([0-9]+(?:\.[0-9]+)?)\s*%?", caseSensitive: false);
      final match = bfRegex.firstMatch(aiResponse);
      if (match != null) {
        bodyFat = double.tryParse(match.group(1) ?? '0') ?? 0.0;
      } else {
        // More inclusive fallback search
        final RegExp fallbackRegex = RegExp(r"(?:body fat|bf|percentage|estimation)[^0-9:]*[:\s]*([0-9]+(?:\.[0-9]+)?)\s*%?", caseSensitive: false);
        final fallbackMatch = fallbackRegex.firstMatch(aiResponse);
        if (fallbackMatch != null) {
          bodyFat = double.tryParse(fallbackMatch.group(1) ?? '0') ?? 0.0;
        }
      }
    } catch (e) {
      print("Error parsing body fat: $e");
    }

    String workout = "Please see the full response below for the workout plan.";
    String diet = "Please see the full response below for the diet plan.";

    final responseLower = aiResponse.toLowerCase();
    
    // Attempt to split based on our new clear markers
    if (responseLower.contains("workout_plan:") && responseLower.contains("diet_plan:")) {
      final workoutStartIndex = responseLower.indexOf("workout_plan:");
      final dietStartIndex = responseLower.indexOf("diet_plan:");
      
      if (workoutStartIndex < dietStartIndex) {
        // Extract content between markers
        workout = aiResponse.substring(workoutStartIndex + "workout_plan:".length, dietStartIndex).trim();
        diet = aiResponse.substring(dietStartIndex + "diet_plan:".length).trim();
      } else {
        diet = aiResponse.substring(dietStartIndex + "diet_plan:".length, workoutStartIndex).trim();
        workout = aiResponse.substring(workoutStartIndex + "workout_plan:".length).trim();
      }
    } else if (responseLower.contains("workout plan") && responseLower.contains("diet plan")) {
      // Fallback to old splitting if markers are missing but standard headers exist
      final workoutIndex = responseLower.indexOf("workout plan");
      final dietIndex = responseLower.indexOf("diet plan");
      
      if (workoutIndex < dietIndex) {
        workout = aiResponse.substring(workoutIndex, dietIndex).trim();
        diet = aiResponse.substring(dietIndex).trim();
      } else {
        diet = aiResponse.substring(dietIndex, workoutIndex).trim();
        workout = aiResponse.substring(workoutIndex).trim();
      }
    } else {
        workout = aiResponse;
        diet = aiResponse;
    }

    return AiAnalysisResult(
      estimatedBodyFatPercentage: bodyFat,
      workoutPlan: workout,
      dietPlan: diet,
      rawResponse: aiResponse,
    );
  }
}
