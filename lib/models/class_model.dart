class Class {
  String id;
  String subject;
  String teacher;
  DateTime date;
  String? recordingPath;
  String transcript;
  String summary;

  Class({
    required this.id,
    required this.subject,
    required this.teacher,
    required this.date,
    this.recordingPath,
    required this.transcript,
    required this.summary,
  });

  String get formattedDate => "${date.year}-${date.month}-${date.day}";

  // Convert Class → Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subject': subject,
      'teacher': teacher,
      'date': date.toIso8601String(),
      'recordingPath': recordingPath,
      'transcript': transcript,
      'summary': summary,
    };
  }

  // Convert Map → Class
  factory Class.fromMap(Map<String, dynamic> map) {
    return Class(
      id: map['id'],
      subject: map['subject'],
      teacher: map['teacher'],
      date: DateTime.parse(map['date']),
      recordingPath: map['recordingPath'],
      transcript: map['transcript'],
      summary: map['summary'],
    );
  }
}
