import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('parking.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ParkingData (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        receipt_id TEXT NOT NULL,
        vehicle_number TEXT NOT NULL,
        vehicle_type TEXT NOT NULL,
        checkin_time TEXT NOT NULL,
        checkout_time TEXT,
        amount REAL DEFAULT 0,
        checkedin_by INTEGER,
        checkedout_by INTEGER
      )
    ''');
  }

  Future<int> insertData(Map<String, dynamic> data) async {
    final db = await instance.database;
    return await db.insert('ParkingData', data);
  }

  Future<int> updateData(String receiptId, Map<String, dynamic> data) async {
    final db = await instance.database;
    return await db.update(
      'ParkingData',
      data,
      where: 'receipt_id = ?',
      whereArgs: [receiptId],
    );
  }

  Future<Map<String, dynamic>?> fetchByReceiptId(String receiptId) async {
    final db = await instance.database;
    final result = await db.query(
      'ParkingData',
      where: 'receipt_id = ?',
      whereArgs: [receiptId],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<bool> isVehicleCheckedOut(String receiptId) async {
    final db = await instance.database;

    final result = await db.query(
      'ParkingData',
      columns: ['checkout_time'],
      where: 'receipt_id = ?',
      whereArgs: [receiptId],
    );

    if (result.isNotEmpty) {
      final checkoutTime = result.first['checkout_time'];
      return checkoutTime != null; // Returns true if checkout_time is NOT null
    }

    return false; // No matching receipt ID found
  }
}
