import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  DatabaseService._internal();

  static DatabaseService get instance => _instance;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'ielts_sat_prep.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create IELTS sessions table
    await db.execute('''
      CREATE TABLE ielts_sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        session_type TEXT NOT NULL,
        completed INTEGER NOT NULL,
        duration INTEGER,
        notes TEXT,
        created_at INTEGER NOT NULL
      )
    ''');

    // Create SAT sessions table
    await db.execute('''
      CREATE TABLE sat_sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        session_type TEXT NOT NULL,
        completed INTEGER NOT NULL,
        duration INTEGER,
        problems_solved INTEGER,
        notes TEXT,
        created_at INTEGER NOT NULL
      )
    ''');

    // Create vocabulary table
    await db.execute('''
      CREATE TABLE vocabulary (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        word TEXT NOT NULL UNIQUE,
        definition TEXT,
        sentence TEXT,
        date_learned TEXT,
        mastered INTEGER DEFAULT 0,
        review_count INTEGER DEFAULT 0,
        last_reviewed TEXT,
        exam_type TEXT NOT NULL
      )
    ''');

    // Create test results table
    await db.execute('''
      CREATE TABLE test_results (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        exam_type TEXT NOT NULL,
        reading_score REAL,
        listening_score REAL,
        writing_task1_score REAL,
        writing_task2_score REAL,
        speaking_score REAL,
        overall_band REAL,
        math_score INTEGER,
        created_at INTEGER NOT NULL
      )
    ''');

    // Create progress table
    await db.execute('''
      CREATE TABLE progress (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        exam_type TEXT NOT NULL,
        total_study_time INTEGER,
        words_learned INTEGER,
        essays_written INTEGER,
        problems_solved INTEGER,
        current_band REAL,
        current_math_score INTEGER,
        created_at INTEGER NOT NULL
      )
    ''');

    // Create achievements table
    await db.execute('''
      CREATE TABLE achievements (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        date_earned TEXT,
        exam_type TEXT NOT NULL,
        icon_name TEXT
      )
    ''');

    // Create error log table
    await db.execute('''
      CREATE TABLE error_log (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        exam_type TEXT NOT NULL,
        section TEXT,
        error_type TEXT,
        question_details TEXT,
        correct_answer TEXT,
        my_answer TEXT,
        explanation TEXT,
        fixed INTEGER DEFAULT 0
      )
    ''');

    // Create indexes for better performance
    await db.execute('CREATE INDEX idx_ielts_sessions_date ON ielts_sessions(date)');
    await db.execute('CREATE INDEX idx_sat_sessions_date ON sat_sessions(date)');
    await db.execute('CREATE INDEX idx_vocabulary_word ON vocabulary(word)');
    await db.execute('CREATE INDEX idx_test_results_date ON test_results(date)');
    await db.execute('CREATE INDEX idx_progress_date ON progress(date)');
  }

  // IELTS Sessions
  Future<int> insertIELTSSession(Map<String, dynamic> session) async {
    final db = await database;
    return await db.insert('ielts_sessions', session);
  }

  Future<List<Map<String, dynamic>>> getIELTSSessionsByDate(String date) async {
    final db = await database;
    return await db.query(
      'ielts_sessions',
      where: 'date = ?',
      whereArgs: [date],
      orderBy: 'session_type ASC',
    );
  }

  // SAT Sessions
  Future<int> insertSATSession(Map<String, dynamic> session) async {
    final db = await database;
    return await db.insert('sat_sessions', session);
  }

  Future<List<Map<String, dynamic>>> getSATSessionsByDate(String date) async {
    final db = await database;
    return await db.query(
      'sat_sessions',
      where: 'date = ?',
      whereArgs: [date],
      orderBy: 'session_type ASC',
    );
  }

  // Vocabulary
  Future<int> insertVocabulary(Map<String, dynamic> vocab) async {
    final db = await database;
    return await db.insert('vocabulary', vocab);
  }

  Future<List<Map<String, dynamic>>> getVocabularyByType(String examType) async {
    final db = await database;
    return await db.query(
      'vocabulary',
      where: 'exam_type = ?',
      whereArgs: [examType],
      orderBy: 'date_learned DESC',
    );
  }

  Future<void> updateVocabulary(int id, Map<String, dynamic> updates) async {
    final db = await database;
    await db.update(
      'vocabulary',
      updates,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Test Results
  Future<int> insertTestResult(Map<String, dynamic> result) async {
    final db = await database;
    return await db.insert('test_results', result);
  }

  Future<List<Map<String, dynamic>>> getTestResultsByType(String examType) async {
    final db = await database;
    return await db.query(
      'test_results',
      where: 'exam_type = ?',
      whereArgs: [examType],
      orderBy: 'date DESC',
    );
  }

  // Progress
  Future<int> insertProgress(Map<String, dynamic> progress) async {
    final db = await database;
    return await db.insert('progress', progress);
  }

  Future<Map<String, dynamic>?> getLatestProgress(String examType) async {
    final db = await database;
    final results = await db.query(
      'progress',
      where: 'exam_type = ?',
      whereArgs: [examType],
      orderBy: 'date DESC',
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }

  // Achievements
  Future<int> insertAchievement(Map<String, dynamic> achievement) async {
    final db = await database;
    return await db.insert('achievements', achievement);
  }

  Future<List<Map<String, dynamic>>> getAchievementsByType(String examType) async {
    final db = await database;
    return await db.query(
      'achievements',
      where: 'exam_type = ?',
      whereArgs: [examType],
      orderBy: 'date_earned DESC',
    );
  }

  // Error Log
  Future<int> insertError(Map<String, dynamic> error) async {
    final db = await database;
    return await db.insert('error_log', error);
  }

  Future<List<Map<String, dynamic>>> getErrorsByType(String examType) async {
    final db = await database;
    return await db.query(
      'error_log',
      where: 'exam_type = ? AND fixed = 0',
      whereArgs: [examType],
      orderBy: 'date DESC',
    );
  }

  // Statistics
  Future<Map<String, dynamic>> getStatistics(String examType) async {
    final db = await database;
    
    // Get total study time
    final studyTimeResult = await db.rawQuery('''
      SELECT SUM(total_study_time) as total_time FROM progress 
      WHERE exam_type = ?
    ''', [examType]);
    
    // Get total sessions completed
    final sessionsResult = await db.rawQuery('''
      SELECT COUNT(*) as total_sessions FROM (
        SELECT * FROM ielts_sessions WHERE exam_type = ? AND completed = 1
        UNION ALL
        SELECT * FROM sat_sessions WHERE exam_type = ? AND completed = 1
      )
    ''', [examType, examType]);
    
    // Get average score
    final scoreResult = await db.rawQuery('''
      SELECT AVG(overall_band) as avg_band FROM test_results 
      WHERE exam_type = ? AND overall_band IS NOT NULL
    ''', [examType]);
    
    return {
      'totalStudyTime': studyTimeResult.first['total_time'] ?? 0,
      'totalSessions': sessionsResult.first['total_sessions'] ?? 0,
      'averageBand': scoreResult.first['avg_band'] ?? 0.0,
    };
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
