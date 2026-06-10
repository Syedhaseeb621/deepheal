import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../data/models/app_models.dart';

class EmotionAnalysisScreen extends ConsumerStatefulWidget {
  const EmotionAnalysisScreen({super.key});

  @override
  ConsumerState<EmotionAnalysisScreen> createState() => _EmotionAnalysisScreenState();
}

class _EmotionAnalysisScreenState extends ConsumerState<EmotionAnalysisScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isAnalyzing = false;
  bool _isVoiceRecording = false;
  bool _isFaceScanning = false;
  final _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _analyzeText() async {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter some text to analyze.')),
      );
      return;
    }

    setState(() => _isAnalyzing = true);

    try {
      final response = await http.post(
        Uri.parse(ApiConstants.chatEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "user_id": "user_123",
          "message": text,
        }),
      ).timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final emotion = data['emotion'] ?? 'default';
        final responseData = data['response'] ?? {};
        
        final cleanEmotion = emotion.substring(0, 1).toUpperCase() + emotion.substring(1);
        final colorMap = {
          'Stress': Colors.orange,
          'Anxiety': Colors.amber,
          'Sadness': Colors.blue,
          'Anger': Colors.red,
          'Fatigue': Colors.grey,
          'Loneliness': Colors.indigo,
          'Guilt': Colors.deepPurple,
        };
        final themeColor = colorMap[cleanEmotion] ?? AppColors.teal;

        final newResult = EmotionResult(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          emotionName: '$cleanEmotion (Text Analysis)',
          confidence: 0.88,
          insight: 'Your words express signs of $cleanEmotion. Suggestion: ${responseData["text"] ?? ""}',
          timestamp: DateTime.now(),
          suggestions: [
            responseData['suggestion'] ?? 'Take 5 deep breaths.',
            responseData['reflection'] ?? 'What triggers this feeling?'
          ],
          color: themeColor,
        );

        ref.read(emotionHistoryProvider.notifier).addResult(newResult);

        if (mounted) {
          context.push('/result', extra: newResult);
        }
      } else {
        throw Exception('Server returned ${response.statusCode}');
      }
    } catch (e) {
      // Fallback local analysis
      final lowerText = text.toLowerCase();
      String detected = 'Calm';
      Color color = Colors.teal;
      String suggestion = 'Practice self-compassion today.';
      
      if (lowerText.contains('stress') || lowerText.contains('busy') || lowerText.contains('overwhelm')) {
        detected = 'Stress';
        color = Colors.orange;
        suggestion = 'Try 4-7-8 deep breathing.';
      } else if (lowerText.contains('worry') || lowerText.contains('anxious') || lowerText.contains('panic')) {
        detected = 'Anxiety';
        color = Colors.amber;
        suggestion = 'Focus on the present moment.';
      } else if (lowerText.contains('sad') || lowerText.contains('hurt') || lowerText.contains('cry')) {
        detected = 'Sadness';
        color = Colors.blue;
        suggestion = 'Reach out to a trusted friend.';
      }

      final newResult = EmotionResult(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        emotionName: '$detected (Text Analysis)',
        confidence: 0.75,
        insight: 'Sentiment analysis detected $detected from your typed text context. Fallback response applied.',
        timestamp: DateTime.now(),
        suggestions: [suggestion, 'Write down what you are feeling in detail.'],
        color: color,
      );

      ref.read(emotionHistoryProvider.notifier).addResult(newResult);

      if (mounted) {
        context.push('/result', extra: newResult);
      }
    } finally {
      if (mounted) setState(() => _isAnalyzing = false);
    }
  }

  void _analyzeVoice() async {
    setState(() => _isVoiceRecording = true);
    
    // Simulate recording voice for 3 seconds
    await Future.delayed(const Duration(seconds: 3));
    
    if (!mounted) return;
    
    // Dynamic mock voice emotion extraction
    final voiceEmotions = [
      {'name': 'Calm', 'color': Colors.teal, 'insight': 'Acoustic pitch and volume variance indicate stable, calm tone signatures.'},
      {'name': 'Fatigue', 'color': Colors.grey, 'insight': 'Speech pace deceleration and flat pitch intervals suggest exhaustion.'},
      {'name': 'Anxiety', 'color': Colors.amber, 'insight': 'Micro-tremors and speed rate variance suggest high anxiety levels.'},
    ];
    final selected = (voiceEmotions..shuffle()).first;

    final newResult = EmotionResult(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      emotionName: '${selected["name"]} (Voice Analysis)',
      confidence: 0.82,
      insight: selected['insight'] as String,
      timestamp: DateTime.now(),
      suggestions: ['Maintain vocal hydration.', 'Try 3 minutes of rhythmic breathing.'],
      color: selected['color'] as Color,
    );

    ref.read(emotionHistoryProvider.notifier).addResult(newResult);
    
    setState(() => _isVoiceRecording = false);
    context.push('/result', extra: newResult);
  }

  void _analyzeFace() async {
    setState(() => _isFaceScanning = true);
    
    // Simulate camera facial processing for 3 seconds
    await Future.delayed(const Duration(seconds: 3));
    
    if (!mounted) return;
    
    // Dynamic mock face emotion extraction
    final faceEmotions = [
      {'name': 'Peaceful', 'color': Colors.teal, 'insight': 'Micro-expression analysis shows relaxed brow and jaw alignment.'},
      {'name': 'Stressed', 'color': Colors.orange, 'insight': 'Minor tension markers detected in the forehead and eye-corner landmarks.'},
      {'name': 'Anxious', 'color': Colors.amber, 'insight': 'Fast gaze-shift pattern and slight lips compression detected.'},
    ];
    final selected = (faceEmotions..shuffle()).first;

    final newResult = EmotionResult(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      emotionName: '${selected["name"]} (Facial Analysis)',
      confidence: 0.91,
      insight: selected['insight'] as String,
      timestamp: DateTime.now(),
      suggestions: ['Do a quick shoulder roll release.', 'Wash your face with cold water.'],
      color: selected['color'] as Color,
    );

    ref.read(emotionHistoryProvider.notifier).addResult(newResult);
    
    setState(() => _isFaceScanning = false);
    context.push('/result', extra: newResult);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emotion Analysis'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildTabs(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(), // Prevent swipe during active scans
              children: [
                _buildTextAnalysis(),
                _buildVoiceAnalysis(),
                _buildFaceAnalysis(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: AppButton(
              text: _tabController.index == 0 
                  ? 'Start Sentiment Analysis'
                  : (_tabController.index == 1 ? (_isVoiceRecording ? 'Recording...' : 'Start Voice Capture') : (_isFaceScanning ? 'Scanning...' : 'Start Camera Scan')),
              isLoading: _isAnalyzing || _isVoiceRecording || _isFaceScanning,
              onPressed: () {
                if (_tabController.index == 0) {
                  _analyzeText();
                } else if (_tabController.index == 1) {
                  _analyzeVoice();
                } else {
                  _analyzeFace();
                }
              },
            ).animate().fadeIn(delay: 500.ms),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TabBar(
        controller: _tabController,
        onTap: (index) => setState(() {}),
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: AppColors.primary,
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textSecondary,
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: 'Text'),
          Tab(text: 'Voice'),
          Tab(text: 'Face'),
        ],
      ),
    );
  }

  Widget _buildTextAnalysis() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'How are you feeling?',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const Text(
            'Describe your thoughts or feelings in detail. Our AI will analyze the sentiment and core emotions.',
            style: TextStyle(color: AppColors.textSecondary, height: 1.5),
          ),
          const SizedBox(height: 30),
          GlassCard(
            padding: EdgeInsets.zero,
            child: TextField(
              controller: _textController,
              maxLines: 6,
              decoration: InputDecoration(
                hintText: 'Type here...',
                filled: true,
                fillColor: Colors.transparent,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95)),
        ],
      ),
    );
  }

  Widget _buildVoiceAnalysis() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _isVoiceRecording ? 'Listening to your voice...' : 'Speak your mind',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: (_isVoiceRecording ? Colors.redAccent : AppColors.teal).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _isVoiceRecording ? Icons.settings_voice_rounded : Icons.mic_rounded, 
              size: 80, 
              color: _isVoiceRecording ? Colors.redAccent : AppColors.teal
            ),
          )
          .animate(target: _isVoiceRecording ? 1 : 0)
          .scale(begin: const Offset(1, 1), end: const Offset(1.15, 1.15), duration: 600.ms)
          .boxShadow(
            begin: BoxShadow(color: Colors.transparent, blurRadius: 0),
            end: BoxShadow(color: Colors.redAccent.withOpacity(0.3), blurRadius: 20, spreadRadius: 5),
          ),
          const SizedBox(height: 40),
          Text(
            _isVoiceRecording ? 'Analyzing frequency wave signatures...' : 'Tap the button below and start speaking.',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildFaceAnalysis() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _isFaceScanning ? 'Scanning facial coordinates...' : 'Face Emotion Detection',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 40),
          Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              color: AppColors.textDisabled.withOpacity(0.1),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: (_isFaceScanning ? AppColors.primary : AppColors.purple).withOpacity(0.3), width: 2),
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(
                    Icons.face_retouching_natural_rounded, 
                    size: 100, 
                    color: _isFaceScanning ? AppColors.primary : AppColors.textDisabled
                  )
                ),
                if (_isFaceScanning)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 2,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        boxShadow: [
                          BoxShadow(color: AppColors.primary.withOpacity(0.5), blurRadius: 10, spreadRadius: 2),
                        ],
                      ),
                    ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                     .moveY(begin: 0, end: 248, duration: 1500.ms),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          Text(
            _isFaceScanning ? 'Aligning landmarks...' : 'Position your face within the frame.',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    ).animate().fadeIn();
  }
}

