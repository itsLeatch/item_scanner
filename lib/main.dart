import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:item_scanner/addImagePage.dart';
import 'package:item_scanner/databaseAbstraction.dart';
import 'package:item_scanner/objectData.dart';
import 'package:item_scanner/selectionTile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class AppStates {
  init() async{
    Database db = await openDatabase(
      'object_data.db',
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE object_data(id INTEGER PRIMARY KEY, imagePath TEXT, description TEXT)',
        );
      },
    );
    databaseAbstranction = DatabaseAbstraction(db);
    var appPath = await getApplicationDocumentsDirectory();
    imageStoragePath = Directory(appPath.path + "/images");
    sharedPreferences = await SharedPreferences.getInstance();
    apiKey = sharedPreferences!.getString("apiKey") ?? "";
  }

  ImagePicker picker = ImagePicker();
  DatabaseAbstraction? databaseAbstranction;
  late Directory imageStoragePath;
  late SharedPreferences sharedPreferences;
  late String apiKey;
}

var appState = AppStates();

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await appState.init();
  runApp(const ItemScannerApp());
}

class ItemScannerApp extends StatelessWidget {
  const ItemScannerApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.cyan)),
      home: const MyHomePage(title: 'item Scanner'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController apiKeyController = TextEditingController(
    text: appState.apiKey,
  );

  void _takeFoto() async {
    final XFile? image = await appState.picker.pickImage(
      source: ImageSource.camera,
    );
    //navigate to the add image page and pass the image to it
    if (image != null) {
      ObjectData? result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddImagePage(image: image, appState: appState),
        ),
      );
    }
  }

  void openAPIKeyDialog() {
    //Textfield to enter API key
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Enter API Key"),
          content: TextField(
            controller: apiKeyController,
            decoration: const InputDecoration(hintText: "API Key"),
            onChanged: (value) {
              // Store the API key in a variable
            },
          ),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Save"),
              onPressed: () {
                appState.sharedPreferences!.setString(
                  "apiKey",
                  apiKeyController.text,
                );
                appState.apiKey = apiKeyController.text;
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
        actions: [
          IconButton(
            onPressed: () => openAPIKeyDialog(),
            icon: Icon(Icons.key),
            tooltip: "API Key",
          ),
        ],
      ),
      body: Center(
        //show in a listview the object data from the database with the image and the description
        child: FutureBuilder<List<ObjectData>>(
          future: appState.databaseAbstranction!.getObjectData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Text('No object data found');
            } else {
              final objectDataList = snapshot.data!;
              return ListView.builder(
                itemCount: objectDataList.length,
                itemBuilder: (context, index) {
                  final objectData = objectDataList[index];
                  return SelectionTile(
                    objectData: objectData,
                    appState: appState,
                  );
                },
              );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _takeFoto,
        tooltip: 'Take Foto',
        child: const Icon(Icons.camera),
      ),
    );
  }
}
