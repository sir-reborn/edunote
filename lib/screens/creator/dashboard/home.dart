import 'package:flutter/material.dart';
import 'package:edunote/models/class_model.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_storage/get_storage.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final storage = GetStorage();
  bool _isFabOpen = false;
  List<Class> classes = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadClasses();
  }

  void _loadClasses() {
    setState(() => isLoading = true);

    final storedData = storage.read<List>('classes') ?? [];
    classes = storedData
        .map((e) => Class.fromMap(Map<String, dynamic>.from(e)))
        .toList();

    setState(() => isLoading = false);
  }

  void _saveClasses() {
    storage.write('classes', classes.map((c) => c.toMap()).toList());
  }

  void _addNewClass() async {
    // First navigate to class info screen
    final result = await Navigator.pushNamed(context, '/class-info');
  }

  // Handle the recording result when returning from recording screen
  void _handleRecordingResult(dynamic result) {
    if (result != null && result is Map<String, dynamic>) {
      final initialClass = result['initialClass'] as Class;

      // Add initial class immediately
      setState(() {
        classes.add(initialClass);
        _saveClasses();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Recording saved for ${initialClass.subject}')),
      );
    }
  }

  void _createClass() async {
    // Navigate to recording screen with callback
    final result = await Navigator.pushNamed(
      context,
      '/record',
      arguments: {
        'subject':
            'New Lecture', // Default values if not from class-info screen
        'teacher': 'Professor',
      },
    );

    _handleRecordingResult(result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EduNote', style: TextStyle(color: Colors.white)),
      ),
      drawer: _buildDrawer(),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : classes.isEmpty
          ? _buildEmptyState()
          : _buildClassList(),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (_isFabOpen) ...[
            FloatingActionButton.extended(
              heroTag: 'join-class',
              onPressed: () {
                _joinClass();
                setState(() => _isFabOpen = false);
              },
              label: const Text(
                'Join Class',
                style: TextStyle(color: Colors.white),
              ),
              icon: const Icon(Icons.group_add, color: Colors.white),
            ),
            const SizedBox(height: 16),
            FloatingActionButton.extended(
              heroTag: 'create-class',
              onPressed: () {
                _createClass();
                setState(() => _isFabOpen = false);
              },
              label: const Text(
                'Create Class',
                style: TextStyle(color: Colors.white),
              ),
              icon: const Icon(Icons.add, color: Colors.white),
            ),
            const SizedBox(height: 16),
          ],
          FloatingActionButton(
            onPressed: () {
              setState(() => _isFabOpen = !_isFabOpen);
            },
            child: Icon(
              _isFabOpen ? Icons.close : Icons.add,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            height: 120.h,
            child: DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF4B0082)),
              child: Text(
                'EduNote',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Downloads'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/downloads');
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/profile');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/illustration.png', height: 200, width: 200),
          const SizedBox(height: 20),
          const Text("Don't see your classes?", style: TextStyle(fontSize: 16)),
          const SizedBox(height: 30),
          const Text(
            "Add a class to get started",
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _createClass,
                child: const Text('Create class'),
              ),
              const SizedBox(width: 20),
              ElevatedButton(
                onPressed: _joinClass,
                child: const Text('Join class'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildClassList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: classes.length,
      itemBuilder: (context, index) {
        return _buildClassCard(classes[index]);
      },
    );
  }

  Widget _buildClassCard(Class classItem) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.pushNamed(context, '/class-details', arguments: classItem);
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    classItem.subject.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4B0082),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                classItem.subject,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                classItem.teacher,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Text(
                'Last updated: ${classItem.formattedDate}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              if (classItem.transcript == 'Transcription in progress...')
                const LinearProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }

  void _joinClass() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Join Class'),
        content: const TextField(
          decoration: InputDecoration(
            labelText: 'Enter class code',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Class joined successfully')),
              );
            },
            child: const Text('Join'),
          ),
        ],
      ),
    );
  }
}
