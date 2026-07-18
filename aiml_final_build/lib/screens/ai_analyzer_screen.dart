import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import '../services/ai_service.dart';
import '../models/ai_models.dart';

class AiAnalyzerScreen extends StatefulWidget {
  const AiAnalyzerScreen({Key? key}) : super(key: key);

  @override
  _AiAnalyzerScreenState createState() => _AiAnalyzerScreenState();
}

class _AiAnalyzerScreenState extends State<AiAnalyzerScreen> {
  final ImagePicker _picker = ImagePicker();
  final AiAnalyzerService _aiService = AiAnalyzerService();
  final TextEditingController _apiKeyController = TextEditingController(text: 'AIzaSyCPzfrpuHX3g51eEPSoL72G_i3143eO6Dk');

  XFile? _imageFile;
  bool _isLoading = false;
  AiAnalysisResult? _result;
  String? _errorMessage;
  bool _obscureApiKey = true;

  Future<void> _pickImage(ImageSource source) async {
    try {
        final XFile? pickedFile = await _picker.pickImage(source: source);
        if (pickedFile != null) {
            setState(() {
                _imageFile = pickedFile;
                _result = null; // Reset results when new image is picked
                _errorMessage = null;
            });
        }
    } catch (e) {
         setState(() {
             _errorMessage = "Failed to pick image: \$e";
         });
    }
  }

  Future<void> _analyzeImage() async {
    if (_imageFile == null) {
      setState(() => _errorMessage = "Please select an image first.");
      return;
    }
    
    // Hardcode an empty fallback or use the user provided key
    final apiKey = _apiKeyController.text.trim();
    if (apiKey.isEmpty) {
      setState(() => _errorMessage = "Please provide your Gemini API Key.");
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _result = null;
    });

    try {
      final result = await _aiService.analyzeBodyImage(_imageFile!, apiKey);
      setState(() {
        _result = result;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Body Analyzer'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // API Key Input
            TextField(
              controller: _apiKeyController,
              decoration: InputDecoration(
                labelText: 'Gemini API Key',
                hintText: 'Enter your API key to use AI analysis',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.key),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureApiKey ? Icons.visibility_off : Icons.visibility,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureApiKey = !_obscureApiKey;
                    });
                  },
                ),
              ),
              obscureText: _obscureApiKey,
            ),
            const SizedBox(height: 16),

            // Image Picker
            if (_imageFile != null)
              Container(
                height: 300,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: kIsWeb
                      ? Image.network(
                          _imageFile!.path,
                          fit: BoxFit.cover,
                        )
                      : Image.file(
                          File(_imageFile!.path),
                          fit: BoxFit.cover,
                        ),
                ),
              )
            else
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade400, style: BorderStyle.none),
                ),
                child: const Center(
                  child: Text('No image selected',
                      style: TextStyle(color: Colors.grey)),
                ),
              ),
            
            const SizedBox(height: 16),

             Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                    ElevatedButton.icon(
                        onPressed: () => _pickImage(ImageSource.camera),
                         icon: const Icon(Icons.camera_alt),
                        label: const Text("Camera"),
                    ),
                     ElevatedButton.icon(
                        onPressed: () => _pickImage(ImageSource.gallery),
                         icon: const Icon(Icons.photo_library),
                        label: const Text("Gallery"),
                    ),
                ]
            ),
            
            const SizedBox(height: 24),
            
            ElevatedButton(
              onPressed: _isLoading ? null : _analyzeImage,
              style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
              ),
              child: _isLoading 
                ? const SizedBox(
                    height: 20, width: 20, 
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                  )
                : const Text('Analyze with AI', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),

            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),

             if (_result != null) ...[
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                
                 Card(
                    color: Colors.blue.shade50,
                    child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                Row(
                                    children: [
                                        const Icon(Icons.monitor_weight_outlined, color: Colors.blue),
                                        const SizedBox(width: 8),
                                        Text("Body Fat Estimate", style: Theme.of(context).textTheme.titleLarge),
                                    ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                     _result!.estimatedBodyFatPercentage > 0 ? "${_result!.estimatedBodyFatPercentage.toStringAsFixed(1)}%" : 'Could not uniquely parse from text.',
                                     style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue),
                                ),
                            ]
                        )
                    )
                ),

                const SizedBox(height: 16),
                Card(
                     child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                                Text("Workout Plan", style: Theme.of(context).textTheme.titleLarge),
                                const SizedBox(height: 8),
                                Text(_result!.workoutPlan.replaceAll('*', '')),
                             ]
                        )
                    )
                ),
                  
                 const SizedBox(height: 16),
                 Card(
                     child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                                Text("Diet Plan", style: Theme.of(context).textTheme.titleLarge),
                                const SizedBox(height: 8),
                                Text(_result!.dietPlan.replaceAll('*', '')),
                             ]
                        )
                    )
                ),
            ]
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }
}
