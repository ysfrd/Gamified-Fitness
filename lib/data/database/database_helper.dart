import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// SQLite Database helper singleton for local storage
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initialize database with path and version
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'gamified_fitness.db');
    return await openDatabase(
      path,
      version: 3,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Create tables on first run
  Future<void> _onCreate(Database db, int version) async {
    // Users table - stores player profile
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        level INTEGER NOT NULL DEFAULT 1,
        xp INTEGER NOT NULL DEFAULT 0,
        total_workouts INTEGER NOT NULL DEFAULT 0,
        join_date TEXT NOT NULL
      )
    ''');

    // Workout records table - stores exercise history
    await db.execute('''
      CREATE TABLE workout_records (
        id TEXT PRIMARY KEY,
        exercise_type TEXT NOT NULL,
        earned_xp INTEGER NOT NULL,
        completed_units INTEGER NOT NULL,
        timestamp TEXT NOT NULL
      )
    ''');

    // Settings table - stores app preferences and quest bonus dates
    await db.execute('''
      CREATE TABLE settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
  }

  /// Handle database migration when version changes
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      await db.execute('DROP TABLE IF EXISTS users');
      await db.execute('DROP TABLE IF EXISTS workout_records');
      await db.execute('DROP TABLE IF EXISTS settings');
      await _onCreate(db, newVersion);
    }
  }

  // ==================== USER OPERATIONS ====================

  /// Insert new user or replace existing
  Future<void> insertUser(Map<String, dynamic> user) async {
    final db = await database;
    await db.insert('users', user, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Get current user (only one user exists)
  Future<Map<String, dynamic>?> getCurrentUser() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query('users', limit: 1);
    if (result.isEmpty) return null;
    return result.first;
  }

  /// Update existing user
  Future<void> updateUser(Map<String, dynamic> user) async {
    final db = await database;
    await db.update('users', user, where: 'id = ?', whereArgs: [user['id']]);
  }

  /// Get count of users (0 or 1)
  Future<int> getUserCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM users');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // ==================== WORKOUT OPERATIONS ====================

  /// Insert a new workout record
  Future<void> insertWorkoutRecord(Map<String, dynamic> record) async {
    final db = await database;
    await db.insert('workout_records', record);
  }

  /// Get all workout records from today
  Future<List<Map<String, dynamic>>> getTodayWorkoutRecords() async {
    final db = await database;
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day).toIso8601String();
    final endOfDay = DateTime(today.year, today.month, today.day + 1).toIso8601String();

    return await db.query(
      'workout_records',
      where: 'timestamp >= ? AND timestamp < ?',
      whereArgs: [startOfDay, endOfDay],
    );
  }

  /// Get workout history for last N days
  Future<List<Map<String, dynamic>>> getWorkoutHistory({int days = 30}) async {
    final db = await database;
    final cutoffDate = DateTime.now().subtract(Duration(days: days));

    return await db.query(
      'workout_records',
      where: 'timestamp >= ?',
      whereArgs: [cutoffDate.toIso8601String()],
      orderBy: 'timestamp DESC',
    );
  }

  /// Get total completed units for a specific exercise today
  Future<int> getTodayExerciseUnits(String exerciseType) async {
    final records = await getTodayWorkoutRecords();
    int total = 0;
    for (var record in records) {
      if (record['exercise_type'] == exerciseType) {
        total += record['completed_units'] as int;
      }
    }
    return total;
  }

  /// Clear all workout records from today (testing only)
  Future<void> clearTodayWorkouts() async {
    final db = await database;
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day).toIso8601String();
    final endOfDay = DateTime(today.year, today.month, today.day + 1).toIso8601String();

    await db.delete(
      'workout_records',
      where: 'timestamp >= ? AND timestamp < ?',
      whereArgs: [startOfDay, endOfDay],
    );
  }

  // ==================== SETTINGS OPERATIONS ====================

  /// Save a setting value
  Future<void> setSetting(String key, String value) async {
    final db = await database;
    await db.insert('settings', {'key': key, 'value': value}, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Get a setting value
  Future<String?> getSetting(String key) async {
    final db = await database;
    final result = await db.query('settings', where: 'key = ?', whereArgs: [key]);
    if (result.isEmpty) return null;
    return result.first['value'] as String;
  }
}