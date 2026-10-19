
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/expense_transaction.dart';

class DatabaseHelper {
  DatabaseHelper._internal();

  static final DatabaseHelper instance =
      DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();

    final path = join(
      databasePath,
      'ocr_expense_tracker.db',
    );

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE transactions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            merchant TEXT NOT NULL,
            date TEXT NOT NULL,
            amount REAL NOT NULL,
            category TEXT NOT NULL,
            raw_text TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<int> insertTransaction(
    ExpenseTransaction transaction,
  ) async {
    final db = await database;

    return db.insert(
      'transactions',
      transaction.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<List<ExpenseTransaction>> getTransactions() async {
    final db = await database;

    final maps = await db.query(
      'transactions',
      orderBy: 'date DESC, id DESC',
    );

    return maps
        .map((map) => ExpenseTransaction.fromMap(map))
        .toList();
  }

  Future<int> deleteTransaction(int id) async {
    final db = await database;

    return db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateTransaction(
    ExpenseTransaction transaction,
  ) async {
    if (transaction.id == null) {
      throw ArgumentError(
        'Không thể cập nhật giao dịch chưa có ID',
      );
    }

    final db = await database;

    return db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }
}
