import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';


class LocalDB {
static Database? _db;


static Future<Database> get db async {
if (_db != null) return _db!;
_db = await openDatabase(
join(await getDatabasesPath(), 'history.db'),
onCreate: (db, v) {
return db.execute('CREATE TABLE history(id INTEGER PRIMARY KEY, result TEXT)');
},
version: 1,
);
return _db!;
}


static Future<void> insertHistory(String result) async {
final database = await db;
await database.insert('history', {'result': result});
}


static Future<List<Map<String, dynamic>>> getHistory() async {
final database = await db;
return database.query('history');
}
}