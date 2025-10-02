import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:edunote/models/class_model.dart';
import 'package:edunote/utils/colour.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class RecordingScreen extends StatefulWidget {
  const RecordingScreen({super.key});

  @override
  State<RecordingScreen> createState() => _RecordingScreenState();
}

class _RecordingScreenState extends State<RecordingScreen> {
  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isRecording = false;
  bool _isPaused = false;
  String? _recordingPath;
  Timer? _timer;
  int _recordDuration = 0;
  String? _subject;
  String? _teacher;
  bool _isProcessing = false;
  bool _showStopConfirmation = false;

  @override
  void initState() {
    super.initState();
    // Initialize non-widget-dependent things here
    _audioRecorder.dispose(); // Dispose any existing recorder
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Move route-dependent code here
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, String>?;
    if (args != null) {
      _subject = args['subject'];
      _teacher = args['teacher'];
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioRecorder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Recording: $_subject',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colour.purple,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _formatDuration(_recordDuration),
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            if (!_isRecording && !_isProcessing)
              const Text('Tap the mic to start recording'),

            if (_showStopConfirmation) _buildStopConfirmation(),

            if (!_showStopConfirmation) ...[
              AvatarGlow(
                animate: _isRecording,
                glowColor: Colors.red,
                endRadius: 100,
                child: IconButton(
                  iconSize: 60,
                  icon: Icon(_isRecording ? Icons.mic : Icons.mic_none),
                  color: _isRecording ? Colors.red : Colors.grey,
                  onPressed: _isRecording ? null : _startRecording,
                ),
              ),
              const SizedBox(height: 20),
              if (_isRecording && !_isPaused)
                ElevatedButton(
                  onPressed: _pauseRecording,
                  child: const Text('Pause'),
                ),
              if (_isRecording && _isPaused)
                ElevatedButton(
                  onPressed: _resumeRecording,
                  child: const Text('Resume'),
                ),
              if (_isRecording)
                ElevatedButton(
                  onPressed: _requestStopRecording,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text(
                    'Stop',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStopConfirmation() {
    return AlertDialog(
      title: const Text('Confirm Stop'),
      content: const Text('Are you sure you want to stop recording?'),
      actions: [
        TextButton(
          onPressed: () => setState(() => _showStopConfirmation = false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _stopRecording,
          child: const Text('Stop', style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }

  String _formatDuration(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainingSeconds';
  }

  void _startRecording() async {
    if (await _audioRecorder.hasPermission()) {
      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          '${_subject}_${DateTime.now().millisecondsSinceEpoch}.wav';
      final filePath = p.join(directory.path, fileName);

      await _audioRecorder.start(const RecordConfig(), path: filePath);

      setState(() {
        _isRecording = true;
        _recordDuration = 0;
        _recordingPath = filePath;
      });

      _startTimer();
    }
  }

  void _pauseRecording() async {
    await _audioRecorder.pause();
    _timer?.cancel();
    setState(() {
      _isPaused = true;
    });
  }

  void _resumeRecording() async {
    await _audioRecorder.resume();
    _startTimer();
    setState(() {
      _isPaused = false;
    });
  }

  void _requestStopRecording() {
    setState(() => _showStopConfirmation = true);
  }

  void _stopRecording() async {
    setState(() {
      _showStopConfirmation = false;
      _isRecording = false;
      _isProcessing = true;
    });

    _timer?.cancel();
    await _audioRecorder.stop();

    // Notify user that transcription is starting
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Recording saved. Transcription in progress...'),
      ),
    );

    // Create initial class with empty transcript
    final newClass = Class(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      subject: _subject!,
      teacher: _teacher!,
      date: DateTime.now(),
      recordingPath: _recordingPath!,
      transcript: 'Transcription in progress...',
      summary: 'Summary will be available soon',
      duration: _recordDuration,
    );

    // Return immediately to home screen
    Navigator.pop(context, {
      'initialClass': newClass,
      'filePath': _recordingPath!,
    });

    // Start background transcription
    _startBackgroundTranscription(_recordingPath!, newClass);
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _recordDuration++);
    });
  }

  Future<void> _startBackgroundTranscription(
    String filePath,
    Class initialClass,
  ) async {
    try {
      // 1. Upload audio
      final uploadResponse = await http.post(
        Uri.parse('https://api.assemblyai.com/v2/upload'),
        headers: {'authorization': 'e0002e9595d94613b8fb70857b1c0738'},
        body: await File(filePath).readAsBytes(),
      );
      final audioUrl = json.decode(uploadResponse.body)['upload_url'];

      // 2. Start transcription
      final transcriptResponse = await http.post(
        Uri.parse('https://api.assemblyai.com/v2/transcript'),
        headers: {
          'authorization': 'e0002e9595d94613b8fb70857b1c0738',
          'content-type': 'application/json',
        },
        body: json.encode({
          'audio_url': audioUrl,
          'speaker_labels': true,
          'auto_chapters': true,
        }),
      );
      final transcriptId = json.decode(transcriptResponse.body)['id'];

      // 3. Poll for results in background
      final transcriptResult = await _pollForTranscriptionResult(transcriptId);

      // 4. Process results
      final summary = _extractSummary(transcriptResult);
      final transcript = _extractTranscript(transcriptResult);

      // 5. Create completed class
      final completedClass = Class(
        id: initialClass.id,
        subject: initialClass.subject,
        teacher: initialClass.teacher,
        date: initialClass.date,
        recordingPath: initialClass.recordingPath,
        transcript: transcript,
        summary: summary,
        duration: initialClass.duration,
      );

      // 6. Notify home screen (you'll need to implement this)
      _notifyClassCompleted(completedClass);
    } catch (e) {
      // Retry logic could be added here
      debugPrint('Transcription error: $e');
    }
  }

  Future<Map<String, dynamic>> _pollForTranscriptionResult(
    String transcriptId,
  ) async {
    const maxAttempts = 30;
    const delay = Duration(seconds: 5);

    for (var i = 0; i < maxAttempts; i++) {
      await Future.delayed(delay);
      final response = await http.get(
        Uri.parse('https://api.assemblyai.com/v2/transcript/$transcriptId'),
        headers: {'authorization': 'e0002e9595d94613b8fb70857b1c0738'},
      );
      final result = json.decode(response.body) as Map<String, dynamic>;

      if (result['status'] == 'completed') return result;
      if (result['status'] == 'error') throw Exception('Transcription failed');
    }
    throw Exception('Transcription timed out');
  }

  String _extractSummary(Map<String, dynamic> transcriptResult) {
    final chapters = transcriptResult['chapters'] as List<dynamic>?;
    return chapters?.map((c) => c['summary'] as String).join('\n\n') ??
        'No summary available';
  }

  String _extractTranscript(Map<String, dynamic> transcriptResult) {
    final utterances = transcriptResult['utterances'] as List<dynamic>?;
    if (utterances == null)
      return transcriptResult['text'] ?? 'No transcript available';

    return utterances.map((u) => '${u['speaker']}: ${u['text']}').join('\n\n');
  }

  void _notifyClassCompleted(Class completedClass) {
    // You'll need to implement this using your state management solution
    // This could be:
    // - A global event bus
    // - A state management solution like Provider, Riverpod, etc.
    // - A callback passed from the home screen
    debugPrint('Class completed: ${completedClass.subject}');
  }
}
