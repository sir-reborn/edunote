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
  List<Class> classes = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    // Simulate loading data
    _loadClasses();
  }

  Future<void> _loadClasses() async {
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
    final result = await Navigator.pushNamed(context, '/record');

    if (result != null && result is Class) {
      setState(() {
        classes.add(result);
        _saveClasses(); // Save after adding
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Added new class: ${result.subject}')),
      );
    }
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
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewClass,
        child: Icon(Icons.add, color: Colors.white),
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
                onPressed: _addNewClass,
                child: const Text('Create class'),
              ),
              const SizedBox(width: 20),
              ElevatedButton(onPressed: () {}, child: const Text('Join class')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildClassList() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: classes.length,
      itemBuilder: (context, index) {
        return _buildClassCard(classes[index]);
      },
    );
  }

  Widget _buildClassCard(Class classItem) {
    return Card(
      elevation: 4,
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
                height: 80,
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
              const Spacer(),
              Text(
                'Last updated: ${classItem.formattedDate}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
