import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:item_scanner/main.dart';
import 'package:item_scanner/objectData.dart';

class AddImagePage extends StatelessWidget {
  AddImagePage({super.key, required this.image, required this.appState});

  AppStates appState;
  final XFile image;
  ObjectData objectData = ObjectData(imagePath: "", description: "");
  //page where the image is displayed and the user can enter a description for the image or use the ai button to get a description from the ai
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Image")),
      body: Column(
        children: [
          Image.file(File(image.path), width: 300, height: 300),
          TextField(
            decoration: const InputDecoration(hintText: "Description"),
            onChanged: (value) {
              objectData = ObjectData(
                imagePath: image.path,
                description: value,
              );
            },
          ),
          ElevatedButton(
            onPressed: () async{
              //save image to the app directory and reference to it in the database
              if (appState.imageStoragePath != null) {
                String path = appState.imageStoragePath.path + image.name;
                //save as new image from xfile to path
                await image.saveTo(path);
                
                objectData = ObjectData(
                  imagePath: path,
                  description: objectData.description,
                );
                //save the objectData to the database
                appState.databaseAbstranction!.insertObjectData(objectData);
              }
              Navigator.pop(context, objectData);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }
}
