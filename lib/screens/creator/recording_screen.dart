//currently desired
import 'dart:async'; // For Timer
import 'dart:convert'; // For JSON encoding/decoding
import 'dart:io'; // For file I/O
import 'package:avatar_glow/avatar_glow.dart';
import 'package:edunote/utils/colour.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart'; // For audio playback
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p; // For file path operations
import 'package:path_provider/path_provider.dart'; // To get app storage paths
import 'package:pdf/widgets.dart' as pw; // For generating PDFs
import 'package:record/record.dart'; // For recording audio
import 'package:flutter_markdown/flutter_markdown.dart';

class RecordingScreen extends StatefulWidget {
  const RecordingScreen({super.key});

  @override
  State<RecordingScreen> createState() => _RecordingScreenState();
}

class _RecordingScreenState extends State<RecordingScreen> {
  final AudioRecorder _audioRecorder = AudioRecorder(); // For recording
  final AudioPlayer _audioPlayer = AudioPlayer(); // For playback
  bool _isRecording = false; // True while recording
  bool _isPaused = false; // True when paused (recording or playing)
  bool _isPlaying = false; // True when playing audio
  String? _recordingPath; // Stores the recorded file path
  Timer? _timer; // Timer to count recording time
  int _recordDuration = 0; // Number of seconds recorded
  final TextEditingController _fileNameController =
      TextEditingController(); // For file naming
  String? _summary;
  List<SpeakerSegment> _speakerSegments = [];
  String _structuredNotes = '';
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    //clean up resources when the sreen is removed
    _timer
        ?.cancel(); // 1. Stop the timer to avoid it running after screen is closed
    _audioRecorder
        .dispose(); // 2. Release mic recording resources (OS audio input stream)
    _audioPlayer
        .dispose(); // 3. Release playback resources (OS audio output stream)
    _fileNameController.dispose(); // 4. Clean up text controller (typical)
    super.dispose(); // 5. Let Flutter clean up the rest
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Record Lecture',
          style: GoogleFonts.poppins(
            fontSize: 30,
            color: Colour.kwhite,
            fontWeight: FontWeight.w500,
          ),
        ),
        elevation: 0,
        backgroundColor: Colour.purple3,
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          height: size.height,
          width: size.width,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colour.purple1, Colour.purple2, Colour.purple3],
                begin: const FractionalOffset(0.0, 0.4),
                end: Alignment.topRight,
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(height: size.height * (1 / 4)),
                    // Timer display
                    Text(
                      _formatDuration(_recordDuration),
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colour.kwhite,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Instruction text (only shows when not recording)
                    if (!_isRecording && !_isPlaying)
                      Text(
                        'Tap to record',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colour.kwhite,
                        ),
                      ),

                    const SizedBox(height: 10),

                    // Microphone icon with pulse animation when recording
                    // Microphone with glow effect when recording
                    AvatarGlow(
                      animate: _isRecording,
                      glowColor: Colors.white,
                      endRadius: 120,
                      duration: const Duration(milliseconds: 2000),
                      repeatPauseDuration: const Duration(milliseconds: 100),
                      repeat: true,
                      showTwoGlows: true,
                      child: CircleAvatar(
                        backgroundColor: _isRecording
                            ? Colour.purple1
                            : Colour.kwhite,
                        radius: 60,
                        child: CircleAvatar(
                          backgroundColor: _isRecording
                              ? Colour.kwhite
                              : Colour.purple1,
                          radius: 55,
                          child: IconButton(
                            onPressed: _isRecording ? null : _startRecording,
                            icon: Icon(
                              Icons.mic_none_rounded,
                              size: 100,
                              color: _isRecording
                                  ? Colour.purple1
                                  : Colour.kwhite,
                            ),
                          ),
                        ),
                      ),
                      //),
                    ),
                    const SizedBox(height: 20),

                    // Control buttons
                    // Control buttons (only show when recording or playing)
                    if (_isRecording || _isPlaying)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FloatingActionButton(
                            heroTag: 'pause-fab',
                            onPressed: _isRecording
                                ? _pauseRecording
                                : _pausePlayback,
                            backgroundColor: Colour.purple3,
                            child: Icon(
                              _isPaused ? Icons.play_arrow : Icons.pause,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 20),
                          FloatingActionButton(
                            heroTag: 'stop-fab',
                            onPressed: _isRecording
                                ? _stopRecording
                                : _stopPlayback,
                            backgroundColor: Colour.purple3,
                            child: const Icon(Icons.stop, color: Colors.white),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
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
    if (_isPaused) {
      await _audioRecorder.resume();
      _startTimer();
    } else {
      await _audioRecorder.pause();
      _timer
          ?.cancel(); //stops the duration timer so it doesn't continue counting while paused. ensures that it only tries to cancel if _timer is not null.
    }

    setState(() {
      _isPaused =
          !_isPaused; //update the UI so the app can reflect the new state (e.g., button label changes to "Resume" when paused).
    });
  }

  void _stopRecording() async {
    _timer?.cancel();
    await _audioRecorder.stop();

    // Show dialog to name the file
    final fileName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save Recording'),
        content: TextField(
          controller: _fileNameController,
          decoration: const InputDecoration(
            labelText: 'File Name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, _fileNameController.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (fileName != null && fileName.isNotEmpty) {
      // Rename the file
      final directory = await getApplicationDocumentsDirectory();
      final newPath = p.join(directory.path, '$fileName.wav');
      await File(_recordingPath!).rename(newPath);

      // Start transcription
      _transcribeAudio(newPath);
    }

    setState(() {
      //called at the end og the function after the dialog box
      _isRecording = false;
      _isPaused = false;
    });
  }

  void _pausePlayback() async {
    if (_isPaused) {
      await _audioPlayer.play();
    } else {
      await _audioPlayer.pause();
    }

    setState(() {
      _isPaused = !_isPaused;
    });
  }

  void _stopPlayback() async {
    await _audioPlayer.stop();
    setState(() {
      _isPlaying = false;
      _isPaused = false;
    });
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _recordDuration++;
      });
    });
  }

  Future<void> _transcribeAudio(String filePath) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('Processing audio...'),
          ],
        ),
      ),
    );

    try {
      // Upload to AssemblyAI
      final uploadResponse = await http.post(
        Uri.parse('https://api.assemblyai.com/v2/upload'),
        headers: {'authorization': 'e0002e9595d94613b8fb70857b1c0738'},
        body: await File(filePath).readAsBytes(),
      );

      final uploadData =
          json.decode(uploadResponse.body) as Map<String, dynamic>;
      final audioUrl = uploadData['upload_url'];

      // Enhanced transcription request with summarization and diarization
      final transcriptResponse = await http.post(
        Uri.parse('https://api.assemblyai.com/v2/transcript'),
        headers: {
          'authorization': 'e0002e9595d94613b8fb70857b1c0738',
          'content-type': 'application/json',
        },
        body: json.encode({
          'audio_url': audioUrl,
          'speaker_labels': true, // Enable speaker diarization
          'auto_chapters': true, // Enable automatic summarization
          'entity_detection': true, // Detect important entities
        }),
      );

      final transcriptData =
          json.decode(transcriptResponse.body) as Map<String, dynamic>;
      final transcriptId = transcriptData['id'];

      // Poll for results
      Map<String, dynamic> transcriptResult = await _pollForTranscriptionResult(
        transcriptId,
      );

      // Process the enhanced results
      _processEnhancedTranscript(transcriptResult);

      // Save as PDF with structured notes
      await _createStructuredPdf();

      Navigator.pop(context); // Close loading dialog

      // Show results screen
      _showResultsScreen();
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
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

      if (transcriptResult['status'] == 'completed') {
        return transcriptResult;
      } else if (transcriptResult['status'] == 'error') {
        throw Exception('Transcription failed');
      }
      //the response map contains a key "status", we use it to know the state of the reuqets
      // i.e "processing", "completed", "queued", "error". Return the entire Map if it is completed
      //throw error if something go wrong
      await Future.delayed(delay);
    }

    throw Exception('Transcription timed out after ${maxAttempts * 2} seconds');
  }

  void _processEnhancedTranscript(Map<String, dynamic> transcriptResult) {
    // Extract summary from chapters
    final chapters = transcriptResult['chapters'] as List<dynamic>?;
    _summary = chapters?.map((c) => c['summary'] as String).join('\n\n');

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
