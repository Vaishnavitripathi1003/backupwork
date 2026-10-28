/*
import 'package:flutter/cupertino.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../../data/models/finger_scan_status_model.dart';
import '../../data/models/signUpResponses.dart';
import '../../data/models/user_models.dart';
import '../Global/global_class.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();

  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'app_database.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE user_table (
        userId TEXT PRIMARY KEY NOT NULL,
        adminId TEXT,
        dataName TEXT,
        firstName TEXT,
        lastName TEXT,
        email TEXT,
        mobile TEXT,

        isReportGenerated INTEGER NOT NULL DEFAULT 0,
        reportUpdatedAt TEXT,

        fingerLeftThumbId INTEGER,
        fingerLeftIndexId INTEGER,
        fingerLeftMiddleId INTEGER,
        fingerLeftRingId INTEGER,
        fingerLeftLittleId INTEGER,

        fingerRightThumbId INTEGER,
        fingerRightIndexId INTEGER,
        fingerRightMiddleId INTEGER,
        fingerRightRingId INTEGER,
        fingerRightLittleId INTEGER,

        fingerLeftThumbState INTEGER NOT NULL DEFAULT 0,
        fingerLeftIndexState INTEGER NOT NULL DEFAULT 0,
        fingerLeftMiddleState INTEGER NOT NULL DEFAULT 0,
        fingerLeftRingState INTEGER NOT NULL DEFAULT 0,
        fingerLeftLittleState INTEGER NOT NULL DEFAULT 0,

        fingerRightThumbState INTEGER NOT NULL DEFAULT 0,
        fingerRightIndexState INTEGER NOT NULL DEFAULT 0,
        fingerRightMiddleState INTEGER NOT NULL DEFAULT 0,
        fingerRightRingState INTEGER NOT NULL DEFAULT 0,
        fingerRightLittleState INTEGER NOT NULL DEFAULT 0,

        fingerLeftThumbRaw TEXT,
        fingerLeftIndexRaw TEXT,
        fingerLeftMiddleRaw TEXT,
        fingerLeftRingRaw TEXT,
        fingerLeftLittleRaw TEXT,

        fingerRightThumbRaw TEXT,
        fingerRightIndexRaw TEXT,
        fingerRightMiddleRaw TEXT,
        fingerRightRingRaw TEXT,
        fingerRightLittleRaw TEXT,

        status INTEGER,
        address1 TEXT,
        address2 TEXT,
        landmark TEXT,
        city TEXT,
        state TEXT,
        country TEXT,
        pincode TEXT,

        profileImage TEXT,
        profileImageName TEXT,
        phone TEXT,

        createdAt TEXT,
        updatedAt TEXT,

        isPhotosUploaded INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE fingerprint (
        id INTEGER PRIMARY KEY AUTOINCREMENT,

        fingerprintImagePath TEXT NOT NULL,
        enhancedFingerprintPath TEXT NOT NULL,

        pattern TEXT NOT NULL,
        patternCode TEXT NOT NULL,

        ridgeCount INTEGER NOT NULL,

        core1x REAL,
        core1y REAL,

        core2x REAL,
        core2y REAL,

        core3x REAL,
        core3y REAL,

        delta1x REAL,
        delta1y REAL,

        delta2x REAL,
        delta2y REAL,

        delta3x REAL,
        delta3y REAL
      )
    ''');

    await db.execute('''
      CREATE TABLE temp_photos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,

        userId TEXT NOT NULL,

        leftThumb TEXT,
        leftIndex TEXT,
        leftMiddle TEXT,
        leftRing TEXT,
        leftLittle TEXT,

        rightThumb TEXT,
        rightIndex TEXT,
        rightMiddle TEXT,
        rightRing TEXT,
        rightLittle TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE finger_scan_status (
        userId TEXT PRIMARY KEY NOT NULL,
        fingerScanStatus INTEGER NOT NULL DEFAULT 0,
        scannedAt TEXT
      )
    ''');
  }

  // ======================================================
  // ADMIN USER DATA SQLITE METHODS
  // ======================================================

  /// Insert or Replace Admin User Data into SQLite `user_table`
  Future<int> insertOrUpdateAdminData(SignUpResponseData adminData) async {
    final db = await database;
    final map = {
      'userId': adminData.id ?? 'admin_primary',
      'adminId': adminData.id,
      'firstName': adminData.firstName ?? 'Aarav',
      'lastName': adminData.lastName ?? 'Mahipal',
      'email': adminData.email ?? 'aarav.student@daksh.edu',
      'mobile': adminData.mobile ?? '+91 9815997176',
      'profileImage': adminData.profileImage,
      'createdAt': adminData.createdAt ?? DateTime.now().toIso8601String(),
      'updatedAt': adminData.updatedAt ?? DateTime.now().toIso8601String(),
    };

    return await db.insert(
      'user_table',
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }



  Future<int> updateUserId(String adminId, String newUserId) async {
    final db = await database;

    return await db.update(
      'user_table',
      {'userId': newUserId},
      where: 'adminId = ?',
      whereArgs: [adminId],
    );
  }

  /// Fetch Admin User Data from SQLite `user_table`
  Future<SignUpResponseData?> getAdminData() async {
    final db = await database;
    final maps = await db.query(
      'user_table',
      limit: 1,
    );

    if (maps.isNotEmpty) {
      final map = maps.first;
      return SignUpResponseData(
        id: map['userId']?.toString(),
        firstName: map['firstName']?.toString(),
        lastName: map['lastName']?.toString(),
        email: map['email']?.toString(),
        mobile: map['mobile']?.toString(),
        profileImage: map['profileImage']?.toString(),
        createdAt: map['createdAt']?.toString(),
        updatedAt: map['updatedAt']?.toString(),
      );
    }
    return null;
  }

  // ======================================================
  // CANDIDATE USERS SQLITE METHODS
  // ======================================================

  /// Insert or Replace a List of Candidate Members (`User`) into SQLite `user_table`
  Future<int> insertCandidateMembers(List<User> candidates) async {
    if (candidates.isEmpty) return 0;

    final db = await database;
    final batch = db.batch();

    for (final candidate in candidates) {
      final map = {
        'userId': candidate.id.isNotEmpty
            ? candidate.id
            : DateTime.now().millisecondsSinceEpoch.toString(),
        'adminId': candidate.adminId,
        'dataName': candidate.dataName,
        'firstName': candidate.firstName ?? 'Candidate',
        'lastName': candidate.lastName ?? '',
        'status':candidate.status,
        'email': candidate.email,
        'mobile': candidate.mobile,
        'isReportGenerated': candidate.isReportGenerated ? 1 : 0,
        'profileImage': candidate.profileImage,
        'createdAt': candidate.createdAt ?? DateTime.now().toIso8601String(),
        'updatedAt': candidate.updatedAt ?? DateTime.now().toIso8601String(),
      };

      batch.insert(
        'user_table',
        map,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );




    */
/*  final fingerScanStatusModel = FingerScanStatusModel(
        userId:  candidate.id,
        fingerScanStatus: candidate.isReportGenerated.toString(),
        createdAt: DateTime.now().toIso8601String(),
      );

      await DatabaseHelper.instance.saveFingerScanStatus(fingerScanStatusModel);*//*

    }

    try {
      // noResult: false (default) => har insert ka rowId milta hai
      final results = await batch.commit(continueOnError: false);

      // Har insert ka result rowId hota hai; 0 ya -1 matlab fail
      final inserted =
          results.where((r) => r is int && r > 0).length;

      debugPrint('insertCandidateMembers -> $inserted/${candidates.length} inserted');
      return inserted;
    } catch (e) {
      debugPrint('insertCandidateMembers error: $e');
      return -1;
    }
  }

  /// Update `isReportGenerated` status for a member in SQLite `user_table`
  Future<int> updateReportGeneratedStatus(String userId, bool isReportGenerated) async {
    final db = await database;
    return await db.update(
      'user_table',
      {'isReportGenerated': isReportGenerated ? 1 : 0},
      where: 'userId = ?',
      whereArgs: [userId],
    );
  }

  /// Fetch All Candidate Members from SQLite `user_table`
 */
/* Future<List<User>> getCandidateMembers() async {
    final db = await database;
    final maps = await db.query('user_table');

    return maps.map((map) {
      return User(
        id: map['userId']?.toString() ?? '',
        adminId: map['adminId']?.toString() ?? '',
        dataName: map['dataName']?.toString(),
        firstName: map['firstName']?.toString(),
        lastName: map['lastName']?.toString(),
        email: map['email']?.toString(),
        mobile: map['mobile']?.toString(),
        isReportGenerated: map['isReportGenerated'] == 1,
        profileImage: map['profileImage']?.toString(),
        createdAt: map['createdAt']?.toString(),
        updatedAt: map['updatedAt']?.toString(),
      );
    }).toList();
  }*//*

  Future<List<User>> getCandidateMembers() async {
    final db = await database;
    final maps = await db.query(
      'user_table',
      orderBy: 'createdAt DESC',   // oldest first
    );

    return maps.map((map) {
      return User(
        id: map['userId']?.toString() ?? '',
        adminId: map['adminId']?.toString() ?? '',
        dataName: map['dataName']?.toString(),
        firstName: map['firstName']?.toString(),
        lastName: map['lastName']?.toString(),
        status: map['status'] == 1,
        email: map['email']?.toString(),
        mobile: map['mobile']?.toString(),
        isReportGenerated: map['isReportGenerated'] == 1,
        profileImage: map['profileImage']?.toString(),
        createdAt: map['createdAt']?.toString(),
        updatedAt: map['updatedAt']?.toString(),
      );
    }).toList();
  }

  /// Fetch a Single Candidate Member (`User`) by ID from SQLite `user_table`
  Future<User?> getMemberById(String userId) async {
    final db = await database;
    final maps = await db.query(
      'user_table',
      where: 'userId = ?',
      whereArgs: [userId],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      final map = maps.first;
      return User(
        id: map['userId']?.toString() ?? '',
        adminId: map['adminId']?.toString() ?? '',
        dataName: map['dataName']?.toString(),
        firstName: map['firstName']?.toString(),
        lastName: map['lastName']?.toString(),
        email: map['email']?.toString(),
        mobile: map['mobile']?.toString(),
        isReportGenerated: map['isReportGenerated'] == 1,
        profileImage: map['profileImage']?.toString(),
        createdAt: map['createdAt']?.toString(),
        updatedAt: map['updatedAt']?.toString(),
      );
    }
    return null;
  }

  /// Delete all stored SQLite tables on Sign Out / New Sign In
  Future<void> clearAllData() async {
    try {
      final db = await database;
      await db.delete('user_table');
      await db.delete('fingerprint');
      await db.delete('temp_photos');
      try {
        await db.delete('finger_scan_status');
      } catch (_) {}
      debugPrint('DatabaseHelper -> Cleared all SQLite tables');
    } catch (e) {
      debugPrint('DatabaseHelper clearAllData error: $e');
    }
  }

  // ======================================================
  // FINGER SCAN STATUS MODEL SQLITE METHODS
  // ======================================================



  Future<int> insertOrUpdateAdminDetails(User adminData) async {
    final db = await database;
    final map = {
      'userId': adminData.id ?? 'admin_primary',
      'adminId': adminData.adminId,
      'dataName': adminData.dataName,
      'firstName': adminData.firstName ?? 'Aarav',
      'lastName': adminData.lastName ?? 'Mahipal',
      'email': adminData.email,
      'mobile': adminData.mobile ?? '+91 9815997176',
      'isReportGenerated': adminData.isReportGenerated ? 1 : 0,
      'profileImage': adminData.profileImage,
      'createdAt': adminData.createdAt ?? DateTime.now().toIso8601String(),
      'updatedAt': adminData.updatedAt ?? DateTime.now().toIso8601String(),
    };
//2026-10-13T16:16:03.982Z
    //2026-10-13T10:46:03.981Z

*/
/*'userId': candidate.id.isNotEmpty
            ? candidate.id
            : DateTime.now().millisecondsSinceEpoch.toString(),
        'adminId': candidate.adminId,
        'dataName': candidate.dataName,
        'firstName': candidate.firstName ?? 'Candidate',
        'lastName': candidate.lastName ?? '',
        'email': candidate.email,
        'mobile': candidate.mobile,
        'isReportGenerated': candidate.isReportGenerated ? 1 : 0,
        'profileImage': candidate.profileImage,
        'createdAt': candidate.createdAt ?? DateTime.now().toIso8601String(),
        'updatedAt': candidate.updatedAt ?? DateTime.now().toIso8601String(),*//*


    */
/* 'userId': candidate.id.isNotEmpty
            ? candidate.id
            : DateTime.now().millisecondsSinceEpoch.toString(),
        'adminId': candidate.adminId,
        'dataName': candidate.dataName,
        'firstName': candidate.firstName ?? 'Candidate',
        'lastName': candidate.lastName ?? '',
        'email': candidate.email,
        'mobile': candidate.mobile,
        'isReportGenerated': candidate.isReportGenerated ? 1 : 0,
        'profileImage': candidate.profileImage,
        'createdAt': candidate.createdAt ?? DateTime.now().toIso8601String(),
        'updatedAt': candidate.updatedAt ?? DateTime.now().toIso8601String(),
*//*

    return await db.insert(
      'user_table',
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  Future<User?> getAdmin() async {
    final db = await database;
    final maps = await db.query(
      'user_table',
      orderBy: 'createdAt IS NULL, createdAt ASC', // oldest first, NULLs last
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return _userFromMap(maps.first);
  }
  User _userFromMap(Map<String, Object?> map) {
    return User(
      id: map['userId']?.toString() ?? '',
      adminId: map['adminId']?.toString() ?? '',
      dataName: map['dataName']?.toString(),
      firstName: map['firstName']?.toString(),
      lastName: map['lastName']?.toString(),
      email: map['email']?.toString(),
      mobile: map['mobile']?.toString(),
      isReportGenerated: map['isReportGenerated'] == 1,
      profileImage: map['profileImage']?.toString(),
      createdAt: map['createdAt']?.toString(),
      updatedAt: map['updatedAt']?.toString(),
    );
  }





  /// Update only the finger scan status for a userId.
  /// Returns the number of rows updated (0 means no row exists for this userId).
  /// Insert or Update FingerScanStatusModel after getting saving success
  Future<int> saveFingerScanStatus(FingerScanStatusModel scanStatus) async {
    final db = await database;
    try {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS finger_scan_status (
          userId TEXT PRIMARY KEY NOT NULL,
          fingerScanStatus INTEGER NOT NULL DEFAULT 0,
          scannedAt TEXT
        )
      ''');
    } catch (_) {}

    final inserted = await db.insert(
      'finger_scan_status',
      scanStatus.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    // debugPrint('saveFingerScanStatus -> userId: ${scanStatus.userId}, isFingerScanned: ${scanStatus.fingerScanStatus ? 1 : 0}');
    return inserted;
  }

  /// Get FingerScanStatusModel by userId
  Future<FingerScanStatusModel?> getFingerScanStatus(String userId) async {
    final db = await database;
    try {
      final maps = await db.query(
        'finger_scan_status',
        where: 'userId = ?',
        whereArgs: [userId],
        limit: 1,
      );

      if (maps.isNotEmpty) {
        return FingerScanStatusModel.fromJson(maps.first);
      }
    } catch (_) {}
    return null;
  }

  /// Update only the finger scan status for a userId.
  /// Returns the number of rows updated (0 means no row exists for this userId).
  Future<int> updateFingerScanStatus({
    required String userId,
    required String fingerScanStatus,
  }) async {
    final db = await database;
    return await db.update(
      'finger_scan_status',
      {'isFingerScanned': int.tryParse(fingerScanStatus) ?? 0}, // only this column
      where: 'userId = ?',
      whereArgs: [userId],
    );
  }
}
*/
import 'package:flutter/cupertino.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../../data/models/finger_scan_status_model.dart';
import '../../data/models/signUpResponses.dart';
import '../../data/models/user_models.dart';


class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();

  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'app_database.db');

    return await openDatabase(
      path,
      version: 3,
      onCreate: _onCreate,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 3) {
          final columns = await db.rawQuery(
            'PRAGMA table_info(user_table)',
          );

          final existing = columns
              .map((column) => column['name'])
              .toSet();

          for (final column in [
            'isChecked',
            'isComplete',
            'isSubmitted',
          ]) {
            if (!existing.contains(column)) {
              await db.execute(
                'ALTER TABLE user_table ADD COLUMN $column INTEGER NOT NULL DEFAULT 0',
              );
            }
          }
        }
      },
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE user_table (
        userId TEXT PRIMARY KEY NOT NULL,
        adminId TEXT,
        dataName TEXT,
        firstName TEXT,
        lastName TEXT,
        email TEXT,
        mobile TEXT,

        isReportGenerated INTEGER NOT NULL DEFAULT 0,
        reportUpdatedAt TEXT,

        fingerLeftThumbId INTEGER,
        fingerLeftIndexId INTEGER,
        fingerLeftMiddleId INTEGER,
        fingerLeftRingId INTEGER,
        fingerLeftLittleId INTEGER,

        fingerRightThumbId INTEGER,
        fingerRightIndexId INTEGER,
        fingerRightMiddleId INTEGER,
        fingerRightRingId INTEGER,
        fingerRightLittleId INTEGER,

        fingerLeftThumbState INTEGER NOT NULL DEFAULT 0,
        fingerLeftIndexState INTEGER NOT NULL DEFAULT 0,
        fingerLeftMiddleState INTEGER NOT NULL DEFAULT 0,
        fingerLeftRingState INTEGER NOT NULL DEFAULT 0,
        fingerLeftLittleState INTEGER NOT NULL DEFAULT 0,

        fingerRightThumbState INTEGER NOT NULL DEFAULT 0,
        fingerRightIndexState INTEGER NOT NULL DEFAULT 0,
        fingerRightMiddleState INTEGER NOT NULL DEFAULT 0,
        fingerRightRingState INTEGER NOT NULL DEFAULT 0,
        fingerRightLittleState INTEGER NOT NULL DEFAULT 0,

        fingerLeftThumbRaw TEXT,
        fingerLeftIndexRaw TEXT,
        fingerLeftMiddleRaw TEXT,
        fingerLeftRingRaw TEXT,
        fingerLeftLittleRaw TEXT,

        fingerRightThumbRaw TEXT,
        fingerRightIndexRaw TEXT,
        fingerRightMiddleRaw TEXT,
        fingerRightRingRaw TEXT,
        fingerRightLittleRaw TEXT,

        status INTEGER,
        isChecked INTEGER NOT NULL DEFAULT 0,
        isComplete INTEGER NOT NULL DEFAULT 0,
        isSubmitted INTEGER NOT NULL DEFAULT 0,

        address1 TEXT,
        address2 TEXT,
        landmark TEXT,
        city TEXT,
        state TEXT,
        country TEXT,
        pincode TEXT,

        profileImage TEXT,
        profileImageName TEXT,
        phone TEXT,

        createdAt TEXT,
        updatedAt TEXT,

        isPhotosUploaded INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE fingerprint (
        id INTEGER PRIMARY KEY AUTOINCREMENT,

        fingerprintImagePath TEXT NOT NULL,
        enhancedFingerprintPath TEXT NOT NULL,

        pattern TEXT NOT NULL,
        patternCode TEXT NOT NULL,

        ridgeCount INTEGER NOT NULL,

        core1x REAL,
        core1y REAL,

        core2x REAL,
        core2y REAL,

        core3x REAL,
        core3y REAL,

        delta1x REAL,
        delta1y REAL,

        delta2x REAL,
        delta2y REAL,

        delta3x REAL,
        delta3y REAL
      )
    ''');

    await db.execute('''
      CREATE TABLE temp_photos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,

        userId TEXT NOT NULL,

        leftThumb TEXT,
        leftIndex TEXT,
        leftMiddle TEXT,
        leftRing TEXT,
        leftLittle TEXT,

        rightThumb TEXT,
        rightIndex TEXT,
        rightMiddle TEXT,
        rightRing TEXT,
        rightLittle TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE finger_scan_status (
        userId TEXT PRIMARY KEY NOT NULL,
        fingerScanStatus INTEGER NOT NULL DEFAULT 0,
        scannedAt TEXT
      )
    ''');
  }

  // ======================================================
  // ADMIN USER DATA SQLITE METHODS
  // ======================================================

  /// Insert or Replace Admin User Data into SQLite `user_table`
  Future<int> insertOrUpdateAdminData(
      SignUpResponseData adminData,
      ) async {
    final db = await database;

    final map = {
      'userId': adminData.id ?? 'admin_primary',
      'adminId': adminData.id,
      'firstName': adminData.firstName ?? 'Aarav',
      'lastName': adminData.lastName ?? 'Mahipal',
      'email': adminData.email ?? 'aarav.student@daksh.edu',
      'mobile': adminData.mobile ?? '+91 9815997176',
      'profileImage': adminData.profileImage,
      'createdAt':
      adminData.createdAt ?? DateTime.now().toIso8601String(),
      'updatedAt':
      adminData.updatedAt ?? DateTime.now().toIso8601String(),
    };

    return await db.insert(
      'user_table',
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> updateUserId(
      String adminId,
      String newUserId,
      ) async {
    final db = await database;

    return await db.update(
      'user_table',
      {'userId': newUserId},
      where: 'adminId = ?',
      whereArgs: [adminId],
    );
  }

  /// Fetch Admin User Data from SQLite `user_table`
  Future<SignUpResponseData?> getAdminData() async {
    final db = await database;

    final maps = await db.query(
      'user_table',
      limit: 1,
    );

    if (maps.isNotEmpty) {
      final map = maps.first;

      return SignUpResponseData(
        id: map['userId']?.toString(),
        firstName: map['firstName']?.toString(),
        lastName: map['lastName']?.toString(),
        email: map['email']?.toString(),
        mobile: map['mobile']?.toString(),
        profileImage: map['profileImage']?.toString(),
        createdAt: map['createdAt']?.toString(),
        updatedAt: map['updatedAt']?.toString(),
      );
    }

    return null;
  }

  // ======================================================
  // CANDIDATE USERS SQLITE METHODS
  // ======================================================

  /// Insert or Replace Candidate Members into SQLite
  Future<int> insertCandidateMembers(
      List<User> candidates,
      ) async {
    if (candidates.isEmpty) return 0;

    final db = await database;
    final batch = db.batch();

    for (final candidate in candidates) {
      final map = {
        'userId': candidate.id.isNotEmpty
            ? candidate.id
            : DateTime.now().millisecondsSinceEpoch.toString(),

        'adminId': candidate.adminId,
        'dataName': candidate.dataName,
        'firstName': candidate.firstName ?? 'Candidate',
        'lastName': candidate.lastName ?? '',

        'status': candidate.status == true ? 1 : 0,

        'isChecked': candidate.isChecked == true ? 1 : 0,
        'isComplete': candidate.isComplete == true ? 1 : 0,
        'isSubmitted': candidate.isSubmitted==true ? 1 : 0,

        'email': candidate.email,
        'mobile': candidate.mobile,

        'isReportGenerated':
        candidate.isReportGenerated ? 1 : 0,

        'profileImage': candidate.profileImage,

        'createdAt':
        candidate.createdAt ??
            DateTime.now().toIso8601String(),

        'updatedAt':
        candidate.updatedAt ??
            DateTime.now().toIso8601String(),
      };

      debugPrint(
        'INSERT CANDIDATE => '
            'id: ${candidate.id}, '
            'status: ${candidate.status}, '
            'isChecked: ${candidate.isChecked}, '
            'isComplete: ${candidate.isComplete}, '
            'isSubmitted: ${candidate.isSubmitted}',
      );

      batch.insert(
        'user_table',
        map,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      /*
      final fingerScanStatusModel = FingerScanStatusModel(
        userId: candidate.id,
        fingerScanStatus: candidate.isReportGenerated.toString(),
        createdAt: DateTime.now().toIso8601String(),
      );

      await DatabaseHelper.instance.saveFingerScanStatus(
        fingerScanStatusModel,
      );
      */
    }

    try {
      final results = await batch.commit(
        continueOnError: false,
      );

      final inserted =
          results.where((r) => r is int && r > 0).length;

      debugPrint(
        'insertCandidateMembers -> '
            '$inserted/${candidates.length} inserted',
      );

      return inserted;
    } catch (e) {
      debugPrint('insertCandidateMembers error: $e');
      return -1;
    }
  }

  /// Update isReportGenerated status
  Future<int> updateReportGeneratedStatus(
      String userId,
      bool isReportGenerated,
      ) async {
    final db = await database;

    return await db.update(
      'user_table',
      {
        'isReportGenerated':
        isReportGenerated ? 1 : 0,
      },
      where: 'userId = ?',
      whereArgs: [userId],
    );
  }

  /// Fetch All Candidate Members from SQLite
  Future<List<User>> getCandidateMembers() async {
    final db = await database;

    final maps = await db.query(
      'user_table',
      orderBy: 'createdAt DESC',
    );

    return maps.map((map) {
      debugPrint(
        'GET CANDIDATE => '
            'id: ${map['userId']}, '
            'status: ${map['status']}, '
            'isChecked: ${map['isChecked']}, '
            'isComplete: ${map['isComplete']}, '
            'isSubmitted: ${map['isSubmitted']}',
      );

      return User(
        id: map['userId']?.toString() ?? '',
        adminId: map['adminId']?.toString() ?? '',

        dataName: map['dataName']?.toString(),
        firstName: map['firstName']?.toString(),
        lastName: map['lastName']?.toString(),

        status: map['status'] == 1,

        isChecked: map['isChecked'] == 1,
        isComplete: map['isComplete'] == 1,
        isSubmitted: map['isSubmitted'] == 1,

        email: map['email']?.toString(),
        mobile: map['mobile']?.toString(),

        isReportGenerated:
        map['isReportGenerated'] == 1,

        profileImage: map['profileImage']?.toString(),
        createdAt: map['createdAt']?.toString(),
        updatedAt: map['updatedAt']?.toString(),
      );
    }).toList();
  }

  /// Fetch a Single Candidate Member by ID
  Future<User?> getMemberById(String userId) async {
    final db = await database;

    final maps = await db.query(
      'user_table',
      where: 'userId = ?',
      whereArgs: [userId],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      final map = maps.first;

      debugPrint(
        'GET MEMBER => '
            'id: ${map['userId']}, '
            'isChecked: ${map['isChecked']}, '
            'isComplete: ${map['isComplete']}, '
            'isSubmitted: ${map['isSubmitted']}',
      );

      return User(
        id: map['userId']?.toString() ?? '',
        adminId: map['adminId']?.toString() ?? '',

        dataName: map['dataName']?.toString(),
        firstName: map['firstName']?.toString(),
        lastName: map['lastName']?.toString(),

        status: map['status'] == 1,

        isChecked: map['isChecked'] == 1,
        isComplete: map['isComplete'] == 1,
        isSubmitted: map['isSubmitted'] == 1,

        email: map['email']?.toString(),
        mobile: map['mobile']?.toString(),

        isReportGenerated:
        map['isReportGenerated'] == 1,

        profileImage: map['profileImage']?.toString(),
        createdAt: map['createdAt']?.toString(),
        updatedAt: map['updatedAt']?.toString(),
      );
    }

    return null;
  }

  /// Delete all stored SQLite tables on Sign Out / New Sign In
  Future<void> clearAllData() async {
    try {
      final db = await database;

      await db.delete('user_table');
      await db.delete('fingerprint');
      await db.delete('temp_photos');

      try {
        await db.delete('finger_scan_status');
      } catch (_) {}

      debugPrint(
        'DatabaseHelper -> Cleared all SQLite tables',
      );
    } catch (e) {
      debugPrint(
        'DatabaseHelper clearAllData error: $e',
      );
    }
  }

  // ======================================================
  // FINGER SCAN STATUS MODEL SQLITE METHODS
  // ======================================================

  Future<int> insertOrUpdateAdminDetails(
      User adminData,
      ) async {
    final db = await database;

    final map = {
      'userId': adminData.id,
      'adminId': adminData.adminId,
      'dataName': adminData.dataName,
      'firstName': adminData.firstName ?? 'Aarav',
      'lastName': adminData.lastName ?? 'Mahipal',
      'email': adminData.email,
      'mobile': adminData.mobile ?? '+91 9815997176',

      'isReportGenerated':
      adminData.isReportGenerated ? 1 : 0,

      'isChecked':
      adminData.isChecked == true ? 1 : 0,

      'isComplete':
      adminData.isComplete == true ? 1 : 0,

      'isSubmitted':
      adminData.isSubmitted ==true? 1 : 0,

      'profileImage': adminData.profileImage,

      'createdAt':
      adminData.createdAt ??
          DateTime.now().toIso8601String(),

      'updatedAt':
      adminData.updatedAt ??
          DateTime.now().toIso8601String(),
    };

    //2026-10-13T16:16:03.982Z
    //2026-10-13T10:46:03.981Z

    /*
    'userId': candidate.id.isNotEmpty
        ? candidate.id
        : DateTime.now().millisecondsSinceEpoch.toString(),
    'adminId': candidate.adminId,
    'dataName': candidate.dataName,
    'firstName': candidate.firstName ?? 'Candidate',
    'lastName': candidate.lastName ?? '',
    'email': candidate.email,
    'mobile': candidate.mobile,
    'isReportGenerated': candidate.isReportGenerated ? 1 : 0,
    'profileImage': candidate.profileImage,
    'createdAt': candidate.createdAt ?? DateTime.now().toIso8601String(),
    'updatedAt': candidate.updatedAt ?? DateTime.now().toIso8601String(),
    */

    /*
    'userId': candidate.id.isNotEmpty
        ? candidate.id
        : DateTime.now().millisecondsSinceEpoch.toString(),
    'adminId': candidate.adminId,
    'dataName': candidate.dataName,
    'firstName': candidate.firstName ?? 'Candidate',
    'lastName': candidate.lastName ?? '',
    'email': candidate.email,
    'mobile': candidate.mobile,
    'isReportGenerated': candidate.isReportGenerated ? 1 : 0,
    'profileImage': candidate.profileImage,
    'createdAt': candidate.createdAt ?? DateTime.now().toIso8601String(),
    'updatedAt': candidate.updatedAt ?? DateTime.now().toIso8601String(),
    */

    return await db.insert(
      'user_table',
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<User?> getAdmin() async {
    final db = await database;

    final maps = await db.query(
      'user_table',
      orderBy: 'createdAt IS NULL, createdAt ASC',
      limit: 1,
    );

    if (maps.isEmpty) return null;

    return _userFromMap(maps.first);
  }

  User _userFromMap(Map<String, Object?> map) {
    return User(
      id: map['userId']?.toString() ?? '',
      adminId: map['adminId']?.toString() ?? '',
      dataName: map['dataName']?.toString(),
      firstName: map['firstName']?.toString(),
      lastName: map['lastName']?.toString(),
      email: map['email']?.toString(),
      mobile: map['mobile']?.toString(),

      isReportGenerated:
      map['isReportGenerated'] == 1,

      isChecked: map['isChecked'] == 1,
      isComplete: map['isComplete'] == 1,
      isSubmitted: map['isSubmitted'] == 1,

      profileImage: map['profileImage']?.toString(),
      createdAt: map['createdAt']?.toString(),
      updatedAt: map['updatedAt']?.toString(),
    );
  }

  /// Insert or Update FingerScanStatusModel
  Future<int> saveFingerScanStatus(
      FingerScanStatusModel scanStatus,
      ) async {
    final db = await database;

    try {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS finger_scan_status (
          userId TEXT PRIMARY KEY NOT NULL,
          fingerScanStatus INTEGER NOT NULL DEFAULT 0,
          scannedAt TEXT
        )
      ''');
    } catch (_) {}

    final inserted = await db.insert(
      'finger_scan_status',
      scanStatus.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return inserted;
  }

  /// Get FingerScanStatusModel by userId
  Future<FingerScanStatusModel?> getFingerScanStatus(
      String userId,
      ) async {
    final db = await database;

    try {
      final maps = await db.query(
        'finger_scan_status',
        where: 'userId = ?',
        whereArgs: [userId],
        limit: 1,
      );

      if (maps.isNotEmpty) {
        return FingerScanStatusModel.fromJson(
          maps.first,
        );
      }
    } catch (_) {}

    return null;
  }

  /// Update only finger scan status
  Future<int> updateFingerScanStatus({
    required String userId,
    required String fingerScanStatus,
  }) async {
    final db = await database;

    return await db.update(
      'finger_scan_status',
      {
        'isFingerScanned':
        int.tryParse(fingerScanStatus) ?? 0,
      },
      where: 'userId = ?',
      whereArgs: [userId],
    );
  }

  /// Update isSubmitted after backend confirms submission
  Future<int> updateIsSubmittedStatus(
      String userId,
      bool isSubmitted,
      ) async {
    final db = await database;

    return await db.update(
      'user_table',
      {
        'isSubmitted': isSubmitted ? 1 : 0,
        'updatedAt': DateTime.now().toIso8601String(),
      },
      where: 'userId = ?',
      whereArgs: [userId],
    );
  }
}