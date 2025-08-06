class Class {
  final String id;
  final String subject;
  final String teacher;
  final DateTime date;
  final String? recordingPath;
  final String? transcript;
  final String? summary;

  Class({
    required this.id,
    required this.subject,
    required this.teacher,
    required this.date,
    this.recordingPath,
    this.transcript,
    this.summary,
  });

  String get formattedDate {
    return '${date.day}/${date.month}/${date.year}';
  }
}
