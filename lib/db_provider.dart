import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:stepik_10_3/model/student.dart';

class DBProvider {
  DBProvider._();
  static final DBProvider db = DBProvider._();

  static Database? _database;

  final String studentsTable = 'Students';
  final String columnId = 'id';
  final String columnName = 'name';

  Future<Database> get database async {
    _database ??= await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    Directory dir = await getApplicationDocumentsDirectory();
    String path = join(dir.path, 'Student.db');
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute(
      'CREATE TABLE $studentsTable($columnId INTEGER PRIMARY KEY AUTOINCREMENT, $columnName TEXT)',
    );
  }

  // READ
  Future<List<Student>> getStudents() async {
    final db = await database;
    final maps = await db.query(studentsTable);
    return maps.map((m) => Student.fromMap(m)).toList();
  }

  // INSERT
  Future<Student> insertStudent(Student student) async {
    final db = await database;
    student.id = await db.insert(studentsTable, student.toMap());
    return student;
  }

  // UPDATE
  Future<int> updateStudent(Student student) async {
    final db = await database;
    return db.update(
      studentsTable,
      student.toMap(),
      where: '$columnId = ?',
      whereArgs: [student.id],
    );
  }

  // DELETE
  Future<int> deleteStudent(int? id) async {
    final db = await database;
    return db.delete(studentsTable, where: '$columnId = ?', whereArgs: [id]);
  }
}