import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:fsegs_connect/models/diplome.dart';
import 'package:fsegs_connect/models/calendar_note.dart';
import 'package:path_provider/path_provider.dart';


class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('fsegs_connect.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 2, onCreate: _createDB, onUpgrade: _onUpgrade);
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
CREATE TABLE calendar_notes (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  date TEXT NOT NULL,
  note TEXT NOT NULL
  )
''');
    }
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const textNullable = 'TEXT';
    
    await db.execute('''
CREATE TABLE diplomes ( 
  id $idType, 
  titre $textType,
  etablissement $textType,
  date_obtention $textType,
  pdf_path $textNullable
  )
''');

    await db.execute('''
CREATE TABLE calendar_notes (
  id $idType,
  date $textType,
  note $textType
  )
''');
  }

  Future<Diplome> create(Diplome diplome) async {
    final db = await database;
    final id = await db.insert('diplomes', diplome.toMap());
    return Diplome(
      id: id,
      titre: diplome.titre,
      etablissement: diplome.etablissement,
      dateObtention: diplome.dateObtention,
      pdfPath: diplome.pdfPath,
    );
  }

  Future<Diplome> readDiplome(int id) async {
    final db = await database;
    final maps = await db.query(
      'diplomes',
      columns: ['id', 'titre', 'etablissement', 'date_obtention', 'pdf_path'],
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Diplome.fromMap(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<List<Diplome>> readAllDiplomes() async {
    final db = await database;
    final orderBy = 'date_obtention DESC';
    final result = await db.query('diplomes', orderBy: orderBy);

    return result.map((json) => Diplome.fromMap(json)).toList();
  }

  Future<int> update(Diplome diplome) async {
    final db = await database;
    return db.update(
      'diplomes',
      diplome.toMap(),
      where: 'id = ?',
      whereArgs: [diplome.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await database;
    return await db.delete(
      'diplomes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // CALENDAR NOTES CRUD
  Future<CalendarNote> createCalendarNote(CalendarNote note) async {
    final db = await database;
    final id = await db.insert('calendar_notes', note.toMap());
    return CalendarNote(
      id: id,
      date: note.date,
      note: note.note,
    );
  }

  Future<List<CalendarNote>> readAllCalendarNotes() async {
    final db = await database;
    final result = await db.query('calendar_notes');
    return result.map((json) => CalendarNote.fromMap(json)).toList();
  }

  Future<CalendarNote?> readCalendarNoteByDate(String date) async {
    final db = await database;
    final maps = await db.query(
      'calendar_notes',
      where: 'date = ?',
      whereArgs: [date],
    );

    if (maps.isNotEmpty) {
      return CalendarNote.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateCalendarNote(CalendarNote note) async {
    final db = await database;
    return db.update(
      'calendar_notes',
      note.toMap(),
      where: 'date = ?',
      whereArgs: [note.date],
    );
  }

  Future<int> deleteCalendarNote(String date) async {
    final db = await database;
    return await db.delete(
      'calendar_notes',
      where: 'date = ?',
      whereArgs: [date],
    );
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
