import 'dart:async';
import 'dart:convert';
import 'package:cskmemp/app_config.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:http/http.dart' as http;

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper.internal();

  factory DatabaseHelper() => _instance;

  static late Database _database;

  DatabaseHelper.internal();

  Future<Database> get database async {
    if (_database != null) {
      return _database;
    }

    _database = await initDatabase();
    return _database;
  }

  Future<Database> initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'cskmemp.db');

    return await openDatabase(path, version: 1, onCreate: _createTable);
  }

  Future<void> _createTable(Database db, int version) async {
    await db.execute(
        'CREATE TABLE IF NOT EXISTS PendingTasks(taskId INTEGER PRIMARY KEY, taskDescription TEXT, creationDate DATE, assignedBy TEXT)');
    await db.execute(
        'CREATE TABLE IF NOT EXISTS AssignedTasks(taskId INTEGER PRIMARY KEY, taskDescription TEXT, creationDate DATE, assignedTo TEXT)');
    await db.execute(
        'CREATE TABLE IF NOT EXISTS CompletedTasks(taskId INTEGER PRIMARY KEY, taskDescription TEXT, creationDate DATE, assignedBy TEXT)');
  }

  Future<int> insertDataToPendingTasks({
    required taskId,
    required taskDescription,
    required creationDate,
    required assignedBy,
  }) async {
    final db = await database;
    final values = {
      'taskId': taskId,
      'taskDescription': taskDescription,
      'creationDate': creationDate,
      'assignedBy': assignedBy,
    };

    return await db.insert('PendingTasks', values);
  }

  Future<int> insertDataToAssignedTasks({
    required taskId,
    required taskDescription,
    required creationDate,
    required assignedTo,
  }) async {
    final db = await database;
    final values = {
      'taskId': taskId,
      'taskDescription': taskDescription,
      'creationDate': creationDate,
      'assignedTo': assignedTo,
    };

    return await db.insert('AssignedTasks', values);
  }

  Future<int> insertDataToCompletedTasks({
    required taskId,
    required taskDescription,
    required creationDate,
    required assignedBy,
  }) async {
    final db = await database;
    final values = {
      'taskId': taskId,
      'taskDescription': taskDescription,
      'creationDate': creationDate,
      'assignedBy': assignedBy,
    };

    return await db.insert('CompletedTasks', values);
  }

  //delete data from PendingTasks table
  Future<int> deleteDataFromPendingTasks({required taskId}) async {
    final db = await database;
    return await db.delete(
      'PendingTasks',
      where: 'taskId = ?',
      whereArgs: [taskId],
    );
  }

  //delete data from AssignedTasks table
  Future<int> deleteDataFromAssignedTasks({required taskId}) async {
    final db = await database;
    return await db.delete(
      'AssignedTasks',
      where: 'taskId = ?',
      whereArgs: [taskId],
    );
  }

  //delete data from CompletedTasks table
  Future<int> deleteDataFromCompletedTasks({required taskId}) async {
    final db = await database;
    return await db.delete(
      'CompletedTasks',
      where: 'taskId = ?',
      whereArgs: [taskId],
    );
  }

  //fetch data from PendingTasks table in the ascending order of taskId
  Future<List<Map<String, dynamic>>> getDataFromPendingTasks() async {
    final db = await database;
    return await db.query('PendingTasks', orderBy: 'taskId ASC');
  }

  //fetch data from AssignedTasks table in the ascending order of taskId
  Future<List<Map<String, dynamic>>> getDataFromAssignedTasks() async {
    final db = await database;
    return await db.query('AssignedTasks', orderBy: 'taskId ASC');
  }

  //fetch data from CompletedTasks table in the ascending order of taskId
  Future<List<Map<String, dynamic>>> getDataFromCompletedTasks() async {
    final db = await database;
    return await db.query('CompletedTasks', orderBy: 'taskId ASC');
  }

  //fetch data in json format from server using http package and store it in PendingTasks table
  Future<void> syncDataToPendingTasks() async {
    final db = await database;
    final dataFromServer = await fetchPendingTasksDataFromServer();

    await db.transaction((txn) async {
      final batch = txn.batch();

      for (var data in dataFromServer) {
        //insert data to PendingTasks table where taskId is not exists in the table
        batch.rawInsert(
            'INSERT OR IGNORE INTO PendingTasks(taskId, taskDescription, creationDate, assignedBy) VALUES(?, ?, ?, ?)',
            [
              data['taskId'],
              data['description'],
              data['date'],
              data['assignedBy'],
            ]);
      }
      await batch.commit();
    });
  }

  Future<List<Map<String, dynamic>>> fetchPendingTasksDataFromServer() async {
    var userNo = await AppConfig().getUserNo().then((String result) => result);
    var response = await http.post(
      Uri.parse('https://www.cskm.com/schoolexpert/cskmemp/fetchTasks.php'),
      body: {
        'secretKey': AppConfig.secreetKey,
        'userNo': userNo,
        'taskType': 'My',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch data from server');
    }
  }

  Future<void> syncDataToAssignedTasks() async {
    final db = await database;
    final dataFromServer = await fetchAssignedTasksDataFromServer();

    await db.transaction((txn) async {
      final batch = txn.batch();

      for (var data in dataFromServer) {
        //insert data to AssignedTasks table where taskId is not exists in the table
        batch.rawInsert(
            'INSERT OR IGNORE INTO AssignedTasks(taskId, taskDescription, creationDate, assignedTo) VALUES(?, ?, ?, ?)',
            [
              data['taskId'],
              data['description'],
              data['date'],
              data['assignedTo'],
            ]);
      }
      await batch.commit();
    });
  }

  Future<List<Map<String, dynamic>>> fetchAssignedTasksDataFromServer() async {
    var userNo = await AppConfig().getUserNo().then((String result) => result);
    var response = await http.post(
      Uri.parse('https://www.cskm.com/schoolexpert/cskmemp/fetchTasks.php'),
      body: {
        'secretKey': AppConfig.secreetKey,
        'userNo': userNo,
        'taskType': 'Assigned',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch data from server');
    }
  }

  Future<void> syncDataToCompletedTasks() async {
    final db = await database;
    final dataFromServer = await fetchCompletedTasksDataFromServer();

    await db.transaction((txn) async {
      final batch = txn.batch();

      for (var data in dataFromServer) {
        //insert data to CompletedTasks table where taskId is not exists in the table
        batch.rawInsert(
            'INSERT OR IGNORE INTO CompletedTasks(taskId, taskDescription, creationDate, assignedBy) VALUES(?, ?, ?, ?)',
            [
              data['taskId'],
              data['description'],
              data['date'],
              data['assignedBy'],
            ]);
      }
      await batch.commit();
    });
  }

  Future<List<Map<String, dynamic>>> fetchCompletedTasksDataFromServer() async {
    var userNo = await AppConfig().getUserNo().then((String result) => result);
    var response = await http.post(
      Uri.parse('https://www.cskm.com/schoolexpert/cskmemp/fetchTasks.php'),
      body: {
        'secretKey': AppConfig.secreetKey,
        'userNo': userNo,
        'taskType': 'Completed',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch data from server');
    }
  }
}
