import 'package:item_scanner/objectData.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseAbstraction {
  final Database databaseFile;
  DatabaseAbstraction(this.databaseFile);

  Future<void> insertObjectData(ObjectData objectData) async {
    
    await databaseFile.insert(
      'object_data',
      {
        'imagePath': objectData.imagePath,
        'description': objectData.description,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ObjectData>> getObjectData() async {
    final List<Map<String, dynamic>> maps = await databaseFile.query('object_data');

    return List.generate(maps.length, (i) {
      return ObjectData(
        id: maps[i]['id'],
        imagePath: maps[i]['imagePath'],
        description: maps[i]['description'],
      );
    });
  }

  Future<void> deleteObjectData(int id) async {
    await databaseFile.delete(
      'object_data',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}