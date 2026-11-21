import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  AppDatabase._();
  static final AppDatabase instance = AppDatabase._();

  Database? _db;

  Future<Database> get database async => _db ??= await _open();

  Future<Database> _open() async {
    final path = join(await getDatabasesPath(), 'teukucash.db');
    return openDatabase(path, version: 1, onCreate: (db, _) async {
      await db.execute('''
        CREATE TABLE transactions (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          amount REAL NOT NULL CHECK (amount > 0),
          type TEXT NOT NULL CHECK (type IN ('income','expense')),
          category TEXT NOT NULL,
          date TEXT NOT NULL,
          note TEXT,
          created_at TEXT,
          updated_at TEXT
        )''');
      await db.execute('CREATE INDEX idx_tx_date ON transactions(date)');
      await db.execute('CREATE INDEX idx_tx_type ON transactions(type)');
      await db.execute('''
        CREATE TABLE budgets (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          month TEXT NOT NULL UNIQUE,
          amount REAL NOT NULL CHECK (amount > 0),
          created_at TEXT,
          updated_at TEXT
        )''');
    });
  }
}
