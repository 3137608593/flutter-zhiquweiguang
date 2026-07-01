# Flutter Working with Data Guide

## 1. Forms and Form Validation

Forms are essential for collecting user input. Flutter provides the `Form` widget and various form field widgets to create and validate forms.

### Example:

```dart
import 'package:flutter/material.dart';

class MyCustomForm extends StatefulWidget {
  @override
  MyCustomFormState createState() {
    return MyCustomFormState();
  }
}

class MyCustomFormState extends State<MyCustomForm> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          TextFormField(
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter some text';
              }
              return null;
            },
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Processing Data')),
                );
              }
            },
            child: Text('Submit'),
          ),
        ],
      ),
    );
  }
}
```

## 2. HTTP Requests and APIs

Flutter uses the `http` package for making HTTP requests. First, add it to your `pubspec.yaml`:

```yaml
dependencies:
  http: ^0.13.3
```

### Example:

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<Album> fetchAlbum() async {
  final response = await http.get(Uri.parse('https://jsonplaceholder.typicode.com/albums/1'));

  if (response.statusCode == 200) {
    return Album.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to load album');
  }
}

class Album {
  final int userId;
  final int id;
  final String title;

  Album({required this.userId, required this.id, required this.title});

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      userId: json['userId'],
      id: json['id'],
      title: json['title'],
    );
  }
}
```

## 3. JSON Serialization/Deserialization

For simple JSON structures, you can use the `dart:convert` library. For more complex structures, consider using packages like `json_serializable`.

### Example (using dart:convert):

```dart
import 'dart:convert';

class User {
  final String name;
  final int age;

  User({required this.name, required this.age});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'],
      age: json['age'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'age': age,
    };
  }
}

// Usage
String jsonString = '{"name": "John Doe", "age": 30}';
Map<String, dynamic> userMap = jsonDecode(jsonString);
var user = User.fromJson(userMap);

String userJson = jsonEncode(user.toJson());
```

## 4. Local Storage (SharedPreferences)

SharedPreferences is used for storing small amounts of data locally. Add the `shared_preferences` package to your `pubspec.yaml`:

```yaml
dependencies:
  shared_preferences: ^2.0.6
```

### Example:

```dart
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  Future<void> saveUserName(String userName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', userName);
  }

  Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userName');
  }
}

// Usage
final prefsService = PreferencesService();
await prefsService.saveUserName('John Doe');
String? userName = await prefsService.getUserName();
```

## 5. SQLite Database

For more complex local data storage, you can use SQLite. Add the `sqflite` package to your `pubspec.yaml`:

```yaml
dependencies:
  sqflite: ^2.0.0+3
  path: ^1.8.0
```

### Example:

```dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'my_database.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        age INTEGER
      )
    ''');
  }

  Future<int> insertUser(User user) async {
    Database db = await database;
    return await db.insert('users', user.toMap());
  }

  Future<List<User>> getUsers() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query('users');
    return List.generate(maps.length, (i) {
      return User(
        id: maps[i]['id'],
        name: maps[i]['name'],
        age: maps[i]['age'],
      );
    });
  }
}

class User {
  final int? id;
  final String name;
  final int age;

  User({this.id, required this.name, required this.age});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'age': age,
    };
  }
}

// Usage
final dbHelper = DatabaseHelper();
await dbHelper.insertUser(User(name: 'John Doe', age: 30));
List<User> users = await dbHelper.getUsers();
```

Remember, when working with data, always consider data validation, error handling, and user feedback. Also, be mindful of performance implications, especially when working with large datasets or complex operations.

