import 'package:flutter/material.dart';
import 'package:quicknote/password/modelspassword/password.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class SQL_Helper {
  static SQL_Helper dbHelper;
  static Database _database;

  SQL_Helper._createInstance();

  factory SQL_Helper() {
    if (dbHelper == null) {
      dbHelper = SQL_Helper._createInstance();
    }
    return dbHelper;
  }

  String tablePassword = "passwords_table";
  String _id = "id";
  String _password = "password";

  Future<Database> get database async {
    if (_database == null) {
      _database = await initializedDatabase();
    }
    return _database;
  }

  Future<Database> initializedDatabase() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + "passwords.db";

    var passwordDB =
        await openDatabase(path, version: 1, onCreate: createDatabase);
    return passwordDB;
  }

  void createDatabase(Database db, int version) async {
    await db.execute(
        "CREATE TABLE $tablePassword($_id INTEGER PRIMARY KEY AUTOINCREMENT, $_password TEXT)");
  }

  Future<List<Map<String, dynamic>>> getPasswordMapList() async {
    Database db = await this.database;

    //var result1 =  await db.rawQuery("SELECT * FROM $tablePassword ORDER BY $_id ASC");
    var result = await db.query(tablePassword, orderBy: "$_id ASC");
    return result;
  }

  Future<int> insertPassword(Password password) async {
    Database db = await this.database;
    var result = await db.insert(tablePassword, password.toMap());
    return result;
  }

  Future<int> updatePassword(Password password) async {
    Database db = await this.database;
    var result = await db.update(tablePassword, password.toMap(),
        where: "$_id = ?", whereArgs: [password.id]);
    return result;
  }

  Future<int> deletePassword(int id) async {
    var db = await this.database;
    int result =
        await db.rawDelete("DELETE FROM $tablePassword WHERE $_id = $id");
    return result;
  }

  Future<int> getCount() async {
    Database db = await this.database;
    List<Map<String, dynamic>> all =
        await db.rawQuery("SELECT COUNT (*) FROM $tablePassword");
    int result = Sqflite.firstIntValue(all);
    return result;
  }

  Future<List<Password>> getPasswordList() async {
    var passwordMapList = await getPasswordMapList();
    int count = passwordMapList.length;

    List<Password> passwords = new List<Password>();

    for (int i = 0; i <= count - 1; i++) {
      passwords.add(Password.getMap(passwordMapList[i]));
    }

    return passwords;
  }
}
