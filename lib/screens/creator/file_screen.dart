import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

import '../../utils/colour.dart';

class FilesScreen extends StatefulWidget {
  const FilesScreen({super.key});

  @override
  State<FilesScreen> createState() => _FilesScreenState();
}

class _FilesScreenState extends State<FilesScreen> {
  //Store lists of .wav and .pdf files respectively that were previously s
  // saved to the device's app documents directory.
  //List<FileSystemEntity> is a list of file system entities — that is, files or directories
  List<FileSystemEntity> audioFiles = [];
  List<FileSystemEntity> pdfFiles = [];
  final AudioPlayer _audioPlayer = AudioPlayer();
  int?
  _currentlyPlayingIndex; //Keeps track of which audio file is currently being played

  @override
  void initState() {
    super.initState();
    _loadFiles(); //load audio and PDF files from the local directory as soon as the screen opens.
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _loadFiles() async {
    final directory =
        await getApplicationDocumentsDirectory(); //get the directory files are stored
    final files = directory.listSync(); //lists all files in that directory.

    setState(() {
      audioFiles = files.where((file) => file.path.endsWith('.wav')).toList();
      pdfFiles = files.where((file) => file.path.endsWith('.pdf')).toList();
    });
    //You then filter and separate them into audioFiles and pdfFiles using .where(...).
    // setState ensures the UI is updated with the new lists.
  }

  Future<void> _playAudio(String path, int index) async {
    if (_currentlyPlayingIndex == index) {
      if (_audioPlayer.playing) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.play();
      }
      setState(
        () => _currentlyPlayingIndex = _audioPlayer.playing ? index : null,
      );
    } else {
      await _audioPlayer.setFilePath(path); // load the new file
      await _audioPlayer.play(); // start playing it
      setState(
        () => _currentlyPlayingIndex = index,
      ); // update current playing index

      // This resets the playing index when the audio finishes.
      _audioPlayer.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          setState(() => _currentlyPlayingIndex = null);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Files'),
          bottom: const TabBar(
            tabs: [
              Tab(
                text: 'Recordings',
                icon: Icon(Icons.audiotrack, color: Colors.white),
              ),
              Tab(
                text: 'Transcripts',
                icon: Icon(Icons.text_snippet, color: Colors.white),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [_buildAudioFileList(), _buildPdfFileList()],
        ),
      ),
    );
  }

  //TabBar is in the appBar, while the body is the TabBarview, which contain actual widget
  Widget _buildAudioFileList() {
    if (audioFiles.isEmpty) {
      return const Center(child: Text('No audio recordings found'));
    }

    return ListView.builder(
      itemCount: audioFiles.length,
      itemBuilder: (context, index) {
        final file = audioFiles[index];
        final fileName = p.basename(file.path);

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: ListTile(
            leading: Icon(Icons.audiotrack, color: Colour.purple),
            title: Text(
              fileName,
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.black.withOpacity(0.7),
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    _currentlyPlayingIndex == index
                        ? Icons.pause
                        : Icons.play_arrow,
                    color: Colour.purple,
                  ),
                  onPressed: () => _playAudio(file.path, index),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.grey),
                  onPressed: () => _deleteFile(file),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPdfFileList() {
    if (pdfFiles.isEmpty) {
      return const Center(child: Text('No transcriptions found'));
    }

    return ListView.builder(
      itemCount: pdfFiles.length,
      itemBuilder: (context, index) {
        final file = pdfFiles[index];
        final fileName = p.basename(file.path);

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: ListTile(
            leading: const Icon(Icons.picture_as_pdf, color: Colour.purple1),
            title: Text(
              fileName,
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.black.withOpacity(0.7),
              ),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.grey),
              onPressed: () => _deleteFile(file),
            ),
            onTap: () => _openFile(file),
          ),
        );
      },
    );
  }

  Future<void> _deleteFile(FileSystemEntity file) async {
    await file.delete();
    _loadFiles();
  }

  Future<void> _openFile(FileSystemEntity file) async {
    if (file.path.endsWith('.pdf')) {
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async {
          return await File(file.path).readAsBytes();
        },
      );
    }
  }
}
