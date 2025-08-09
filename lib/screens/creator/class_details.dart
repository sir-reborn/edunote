import 'package:flutter/material.dart';
import 'package:edunote/models/class_model.dart';
import 'package:path/path.dart';

class ClassDetailsScreen extends StatelessWidget {
  const ClassDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final classItem = ModalRoute.of(context)!.settings.arguments as Class;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(classItem.subject, style: TextStyle(color: Colors.white)),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Transcript'),
              Tab(text: 'Summary'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildTranscriptTab(classItem),
            _buildSummaryTab(classItem),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Generate PDF functionality
            _generatePdf(classItem);
          },
          child: const Icon(Icons.picture_as_pdf),
        ),
      ),
    );
  }

  Widget _buildTranscriptTab(Class classItem) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (classItem.recordingPath != null)
            const Text(
              'Audio Recording:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          if (classItem.recordingPath != null)
            ElevatedButton(
              onPressed: () {
                // Play recording
              },
              child: const Text('Play Recording'),
            ),
          const SizedBox(height: 20),
          const Text(
            'Transcript:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(classItem.transcript ?? 'No transcript available'),
        ],
      ),
    );
  }

  Widget _buildSummaryTab(Class classItem) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Summary:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text(classItem.summary ?? 'No summary available'),
        ],
      ),
    );
  }

  void _generatePdf(Class classItem) {
    // Implement PDF generation logic
    ScaffoldMessenger.of(
      context as BuildContext,
    ).showSnackBar(const SnackBar(content: Text('Generating PDF...')));
  }
}
