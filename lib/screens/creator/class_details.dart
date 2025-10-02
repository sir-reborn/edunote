import 'package:flutter/material.dart';
import 'package:edunote/models/class_model.dart';
import 'package:path/path.dart';

class ClassDetailsScreen extends StatelessWidget {
  const ClassDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final classItem = ModalRoute.of(context)!.settings.arguments as Class;

    return Scaffold(
      appBar: AppBar(title: Text(classItem.subject)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildClassInfoSection(classItem),
            const SizedBox(height: 20),
            _buildTranscriptSection(classItem),
          ],
        ),
      ),
    );
  }

  Widget _buildClassInfoSection(Class classItem) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Teacher: ${classItem.teacher}'),
            const SizedBox(height: 8),
            Text('Date: ${classItem.formattedDate}'),
            const SizedBox(height: 8),
            Text('Duration: ${classItem.formattedDuration}'),
            const SizedBox(height: 8),
            Text('Language: ${classItem.language}'),
            const SizedBox(height: 16),
            if (classItem.recordingPath != null)
              ElevatedButton(
                onPressed: () {},
                //_playRecording(classItem.recordingPath!)
                child: const Text('Play Recording'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTranscriptSection(Class classItem) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Transcript',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(classItem.transcript),
            const SizedBox(height: 16),
            const Text(
              'Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(classItem.summary),
          ],
        ),
      ),
    );
  }
}
