import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class SqliteDataBase {
  late Database _db;
  final int _databaseVersion = 1;
  String databaseName = "slide.db";

  Future<Database> getDataBase() async {
    _db = await _initDatabase();
    return _db;
  }

  Future<Database> _initDatabase() async {
    return await openDatabase(
      join(await getDatabasesPath(), databaseName),
      onCreate: (db, version) {
        db.execute(
            "CREATE TABLE IF NOT EXISTS CHAT(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,date TEXT, message TEXT, message_type TEXT, readStatus TEXT,receiverImage TEXT, receiverId TEXT, receiverName TEXT, receiverType TEXT, roomId TEXT, senderId TEXT, senderImage TEXT, senderName TEXT, senderType TEXT, uploadPercent REAL,videoThumbnail TEXT ,tempData Text, messageType TEXT, replyType TEXT, replyMessage TEXT, isReply INTEGER, latitude REAL, longitude REAL, isLocal INTEGER, messageId TEXT)");

        db.execute(
            "CREATE TABLE IF NOT EXISTS USERS(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,date TEXT, message TEXT ,receiverImage TEXT, receiverId TEXT, receiverName TEXT , roomId TEXT, senderId TEXT, senderImage TEXT, senderName TEXT , isSelected INTEGER, isOnline INTEGER)");

        db.execute(
            "CREATE TABLE IF NOT EXISTS USERLIST(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,email TEXT, firstName TEXT ,lastName TEXT, mobileNumber TEXT, profileImage TEXT , userId TEXT, isSelected TEXT)");
      },
      version: _databaseVersion,
    );
  }
}
