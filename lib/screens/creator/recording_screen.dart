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
    Size size = MediaQuery.of(context).size;
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
      ),
    );
  }

  String _formatDuration(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(
      2,
      '0',
    ); //return quoteint
    final remainingSeconds = (seconds % 60).toString().padLeft(
      2,
      '0',
    ); // return remainder
    return '$minutes:$remainingSeconds';
  }

  void _startRecording() async {
    if (await _audioRecorder.hasPermission()) {
      //wait till there's permission
      final directory = await getApplicationDocumentsDirectory();
      final filePath = p.join(directory.path, 'temp_recording.wav');

      await _audioRecorder.start(const RecordConfig(), path: filePath);

      setState(() {
        _isRecording = true; //set recording state to true
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
      _isPaused =
          !_isPaused; //update the UI so the app can reflect the new state (e.g., button label changes to "Resume" when paused).
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
  }

    // Start background transcription
    _startBackgroundTranscription(_recordingPath!, newClass);
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _recordDuration++;
      });
    });
  }

  Future<void> _startBackgroundTranscription(
    String filePath,
    Class initialClass,
  ) async {
    try {
      // Upload
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
          'entity_detection': true,
        }),
      );

      final transcriptId = json.decode(transcriptResponse.body)['id'];

      final transcriptResult = await _pollForTranscriptionResult(transcriptId);

      _processEnhancedTranscript(transcriptResult);

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

      return {'notes': _structuredNotes ?? '', 'summary': _summary ?? ''};
    } catch (e) {
      // Retry logic could be added here
      debugPrint('Transcription error: $e');
    }
  }

  //After sending a transcription request, you can’t get the result immediately.
  // we need to wait till it is done.
  Future<Map<String, dynamic>> _pollForTranscriptionResult(
    //return a JSON map, future
    String transcriptId,
  ) async {
    const maxAttempts = 30;
    const delay = Duration(seconds: 2);

    for (var i = 0; i < maxAttempts; i++) {
      final response = await http.get(
        Uri.parse(
          'https://api.assemblyai.com/v2/transcript/$transcriptId',
        ), //returns the current status of the transcription job
        headers: {'authorization': 'e0002e9595d94613b8fb70857b1c0738'},
      );
      //earlier we got ID from our post request, that is the ticket we will be using to ask the server for our response

      final transcriptResult =
          json.decode(response.body) as Map<String, dynamic>;
      //when we get the response, decode it into a map.

      if (result['status'] == 'completed') return result;
      if (result['status'] == 'error') throw Exception('Transcription failed');
    }
    throw Exception('Transcription timed out');
  }

    throw Exception('Transcription timed out after ${maxAttempts * 2} seconds');
  }

  void _processEnhancedTranscript(Map<String, dynamic> transcriptResult) {
    // Extract summary from chapters
    final chapters = transcriptResult['chapters'] as List<dynamic>?;
    return chapters?.map((c) => c['summary'] as String).join('\n\n') ??
        'No summary available';
  }

    // Process speaker segments
    final utterances = transcriptResult['utterances'] as List<dynamic>?;
    _speakerSegments =
        utterances
            ?.map(
              (u) => SpeakerSegment(
                speaker: u['speaker'] as String,
                text: u['text'] as String,
                start: (u['start'] as num).toInt(),
                end: (u['end'] as num).toInt(),
              ),
            )
            .toList() ??
        [];

    // Generate structured notes
    _generateStructuredNotes();
  }

  void _generateStructuredNotes() {
    final buffer = StringBuffer();
    buffer.write('# Lecture Notes\n\n');

    if (_summary != null) {
      buffer.write('## Summary\n$_summary\n\n');
    }

    if (_speakerSegments.isNotEmpty) {
      buffer.write('## Speaker Contributions\n');
      for (final segment in _speakerSegments) {
        buffer.write('- **${segment.speaker}**: ${segment.text}\n');
      }
    }

    _structuredNotes = buffer.toString();
    _notesController.text = _structuredNotes;
  }

  Future<void> _createStructuredPdf() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Header(level: 0, child: pw.Text('Structured Lecture Notes')),
            pw.SizedBox(height: 20),
            pw.Text('File: ${_fileNameController.text}'),
            pw.Text('Date: ${DateTime.now()}'),
            pw.SizedBox(height: 20),

            if (_summary != null) ...[
              pw.Header(level: 1, child: pw.Text('Summary')),
              pw.Text(_summary!),
              pw.SizedBox(height: 20),
            ],

            if (_speakerSegments.isNotEmpty) ...[
              pw.Header(level: 1, child: pw.Text('Speaker Diarization')),
              for (final segment in _speakerSegments)
                pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 8),
                  child: pw.Text('${segment.speaker}: ${segment.text}'),
                ),
              pw.SizedBox(height: 20),
            ],

            pw.Header(level: 1, child: pw.Text('Your Notes')),
            pw.Text(_notesController.text),
          ],
        ),
      ),
    );

    final directory = await getApplicationDocumentsDirectory();
    final pdfPath = p.join(directory.path, '${_fileNameController.text}.pdf');
    await File(pdfPath).writeAsBytes(await pdf.save());
  }

  void _showResultsScreen() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          height: MediaQuery.of(context).size.height * 0.8,
          child: Column(
            children: [
              const Text(
                'Lecture Analysis',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              Expanded(
                child: DefaultTabController(
                  length: 3,
                  child: Column(
                    children: [
                      const TabBar(
                        tabs: [
                          Tab(text: 'Summary'),
                          Tab(text: 'Speakers'),
                          Tab(text: 'Notes'),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            // Summary Tab
                            SingleChildScrollView(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: MarkdownBody(
                                  data: _summary ?? 'No summary available',
                                ),
                              ),
                            ),

                            // Speakers Tab
                            ListView.builder(
                              itemCount: _speakerSegments.length,
                              itemBuilder: (context, index) {
                                final segment = _speakerSegments[index];
                                return ListTile(
                                  title: Text(segment.speaker),
                                  subtitle: Text(segment.text),
                                  trailing: Text(
                                    _formatDuration(segment.start),
                                  ),
                                );
                              },
                            ),

                            // Notes Tab
                            Column(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _notesController,
                                    maxLines: null,
                                    expands: true,
                                    decoration: const InputDecoration(
                                      hintText: 'Add your structured notes...',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    _generateStructuredNotes();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Notes updated'),
                                      ),
                                    );
                                  },
                                  child: const Text('Update Notes'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _createStructuredPdf();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'PDF saved as ${_fileNameController.text}.pdf',
                      ),
                    ),
                  );
                },
                child: const Text('Save as PDF'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //If 30 attempts were made and the transcription still isn’t ready, throw a timeout error.
}

class SpeakerSegment {
  final String speaker;
  final String text;
  final int start;
  final int end;

  SpeakerSegment({
    required this.speaker,
    required this.text,
    required this.start,
    required this.end,
  });
}
