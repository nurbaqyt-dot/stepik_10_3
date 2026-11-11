import 'package:flutter/material.dart';
import 'package:stepik_10_3/db_provider.dart';
import 'package:stepik_10_3/model/student.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'SQLite CRUD Demo',
      home: StudentPage(),
    );
  }
}

class StudentPage extends StatefulWidget {
  const StudentPage({super.key});

  @override
  State<StudentPage> createState() => _StudentPageState();
}

class _StudentPageState extends State<StudentPage> {
  final _formStateKey = GlobalKey<FormState>();
  final _studentNameController = TextEditingController();

  late Future<List<Student>> _studentList;
  Student? _editingStudent;

  @override
  void initState() {
    super.initState();
    _updateStudentList();
  }

  @override
  void dispose() {
    _studentNameController.dispose();
    super.dispose();
  }

  void _updateStudentList() {
    setState(() {
      _studentList = DBProvider.db.getStudents();
    });
  }

  void _clearForm() {
    _studentNameController.clear();
    setState(() => _editingStudent = null);
    _formStateKey.currentState?.reset();
  }

  Future<void> _submit() async {
    if (!_formStateKey.currentState!.validate()) return;

    final name = _studentNameController.text.trim();

    if (_editingStudent == null) {
      await DBProvider.db.insertStudent(Student(null, name));
    } else {
      _editingStudent!.name = name;
      await DBProvider.db.updateStudent(_editingStudent!);
    }

    _clearForm();
    _updateStudentList();
  }

  Future<void> _delete(Student student) async {
    await DBProvider.db.deleteStudent(student.id);
    if (_editingStudent?.id == student.id) _clearForm();
    _updateStudentList();
  }

  void _startEdit(Student student) {
    setState(() => _editingStudent = student);
    _studentNameController.text = student.name;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SQLite CRUD Demo',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: <Widget>[
          Form(
            key: _formStateKey,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: TextFormField(
                controller: _studentNameController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please Enter Student Name';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.greenAccent,
                      width: 2,
                    ),
                  ),
                  labelText: 'Student Name',
                  icon: Icon(Icons.people, color: Colors.black),
                  labelStyle: TextStyle(color: Colors.black),
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.black,
                ),
                onPressed: _submit,
                child: Text(_editingStudent == null ? 'ADD' : 'UPDATE'),
              ),
              const Padding(padding: EdgeInsets.all(10)),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed: _clearForm,
                child: const Text('CLEAR'),
              ),
            ],
          ),
          const Divider(height: 5.0),
          Expanded(
            child: FutureBuilder<List<Student>>(
              future: _studentList,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final students = snapshot.data ?? [];
                if (students.isEmpty) {
                  return const Center(child: Text('No students yet'));
                }
                return ListView.builder(
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    final student = students[index];
                    return ListTile(
                      title: Text(student.name),
                      onTap: () => _startEdit(student),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _delete(student),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}