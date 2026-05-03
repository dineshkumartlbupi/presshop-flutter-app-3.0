// import 'package:path/path.dart';
// import 'package:sqflite/sqflite.dart';

// class ChatLocalDataSource {
//   static final ChatLocalDataSource _instance = ChatLocalDataSource._internal();
//   factory ChatLocalDataSource() => _instance;
//   ChatLocalDataSource._internal();

//   Database? _database;

//   Future<Database> get database async {
//     if (_database != null) return _database!;
//     _database = await _initDatabase();
//     return _database!;
//   }

//   Future<Database> _initDatabase() async {
//     String path = join(await getDatabasesPath(), 'slide.db');
//     return await openDatabase(
//       path,
//       version: 1,
//       onCreate: (db, version) async {
//         await db.execute(
//           "CREATE TABLE IF NOT EXISTS CHAT(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,date TEXT, message TEXT, message_type TEXT, readStatus TEXT,receiverImage TEXT, receiverId TEXT, receiverName TEXT, receiverType TEXT, roomId TEXT, senderId TEXT, senderImage TEXT, senderName TEXT, senderType TEXT, uploadPercent REAL,videoThumbnail TEXT ,tempData Text, messageType TEXT, replyType TEXT, replyMessage TEXT, isReply INTEGER, latitude REAL, longitude REAL, isLocal INTEGER, messageId TEXT)",
//         );

//         await db.execute(
//           "CREATE TABLE IF NOT EXISTS USERS(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,date TEXT, message TEXT ,receiverImage TEXT, receiverId TEXT, receiverName TEXT , roomId TEXT, senderId TEXT, senderImage TEXT, senderName TEXT , isSelected INTEGER, isOnline INTEGER)",
//         );

//         await db.execute(
//           "CREATE TABLE IF NOT EXISTS USERLIST(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,email TEXT, firstName TEXT ,lastName TEXT, mobileNumber TEXT, profileImage TEXT , userId TEXT, isSelected TEXT)",
//         );
//       },
//     );
//   }

//   Future<void> saveMessage(Map<String, dynamic> message) async {
//     final db = await database;
//     final data = _prepareDataForSqlite(message);

//     final String? messageId = data['messageId']?.toString();
//     if (messageId != null && messageId.isNotEmpty) {
//       final existing = await db
//           .query('CHAT', where: 'messageId = ?', whereArgs: [messageId]);
//       if (existing.isNotEmpty) {
//         await db.update('CHAT', data,
//             where: 'messageId = ?', whereArgs: [messageId]);
//         return;
//       }
//     }

//     await db.insert('CHAT', data, conflictAlgorithm: ConflictAlgorithm.replace);
//   }

//   Future<void> saveMessages(List<Map<String, dynamic>> messages) async {
//     for (var message in messages) {
//       await saveMessage(message);
//     }
//   }

//   Future<void> clearAllMessages() async {
//     final db = await database;
//     await db.delete('CHAT');
//   }

//   Map<String, dynamic> _prepareDataForSqlite(Map<String, dynamic> message) {
//     final data = Map<String, dynamic>.from(message);

//     // Map API fields to DB fields
//     if (data.containsKey('_id')) {
//       data['messageId'] = data['_id'].toString();
//     } else if (data.containsKey('id') && data['id'] is String) {
//       data['messageId'] = data['id'];
//     }

//     if (data.containsKey('room_id')) data['roomId'] = data['room_id'];
//     if (data.containsKey('sender_id')) data['senderId'] = data['sender_id'];
//     if (data.containsKey('receiver_id'))
//       data['receiverId'] = data['receiver_id'];
//     if (data.containsKey('message_type'))
//       data['message_type'] = data['message_type'];
//     if (data.containsKey('read_status'))
//       data['readStatus'] = data['read_status'];
//     if (data.containsKey('createdAt')) data['date'] = data['createdAt'];
//     if (data.containsKey('sender_name'))
//       data['senderName'] = data['sender_name'];
//     if (data.containsKey('sender_image'))
//       data['senderImage'] = data['sender_image'];
//     if (data.containsKey('receiver_name'))
//       data['receiverName'] = data['receiver_name'];
//     if (data.containsKey('receiver_image'))
//       data['receiverImage'] = data['receiver_image'];

//     // List of valid columns in CHAT table
//     const validColumns = {
//       'date',
//       'message',
//       'message_type',
//       'readStatus',
//       'receiverImage',
//       'receiverId',
//       'receiverName',
//       'receiverType',
//       'roomId',
//       'senderId',
//       'senderImage',
//       'senderName',
//       'senderType',
//       'uploadPercent',
//       'videoThumbnail',
//       'tempData',
//       'messageType',
//       'replyType',
//       'replyMessage',
//       'isReply',
//       'latitude',
//       'longitude',
//       'isLocal',
//       'messageId',
//     };

//     // Filter out keys that are not columns
//     data.removeWhere((key, value) => !validColumns.contains(key));

//     return data;
//   }

//   Future<List<Map<String, dynamic>>> getMessages(String roomId) async {
//     final db = await database;
//     // Use rawQuery to deduplicate by messageId while keeping optimistic messages (where messageId is null/empty)
//     final List<Map<String, dynamic>> maps = await db.rawQuery('''
//       SELECT * FROM CHAT 
//       WHERE roomId = ? 
//       GROUP BY CASE WHEN messageId IS NULL OR messageId = '' THEN id ELSE messageId END
//       ORDER BY date DESC, id DESC
//     ''', [roomId]);

//     return maps.map((map) {
//       final newMap = Map<String, dynamic>.from(map);
//       // Map back to API field names
//       newMap['room_id'] = map['roomId'];
//       newMap['sender_id'] = map['senderId'];
//       newMap['receiver_id'] = map['receiverId'];
//       newMap['message_type'] = map['message_type'] ?? map['messageType'];
//       newMap['read_status'] = map['readStatus'];
//       newMap['createdAt'] = map['date'];
//       newMap['sender_name'] = map['senderName'];
//       newMap['sender_image'] = map['senderImage'];
//       newMap['receiver_name'] = map['receiverName'];
//       newMap['receiver_image'] = map['receiverImage'];

//       if (map['messageId'] != null) newMap['_id'] = map['messageId'];
//       return newMap;
//     }).toList();
//   }
// }
