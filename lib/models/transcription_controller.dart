import 'package:edunote/models/class_model.dart';
import 'package:get/get.dart';

class TranscriptionController extends GetxController {
  final RxList<Class> _classes = <Class>[].obs;
  final RxMap<String, String> _transcriptionStatus = <String, String>{}.obs;

  List<Class> get classes => _classes;
  Map<String, String> get transcriptionStatus => _transcriptionStatus;

  void addInitialClass(Class newClass) {
    _classes.add(newClass);
    _transcriptionStatus[newClass.id] = 'processing';
    update();
  }

  void updateTranscriptionResult(Class completedClass) {
    final index = _classes.indexWhere((c) => c.id == completedClass.id);
    if (index >= 0) {
      _classes[index] = completedClass;
      _transcriptionStatus[completedClass.id] = 'completed';
      update();
    }
  }

  void markTranscriptionFailed(String classId) {
    _transcriptionStatus[classId] = 'failed';
    update();
  }

  String? getStatus(String classId) {
    return _transcriptionStatus[classId];
  }
}
