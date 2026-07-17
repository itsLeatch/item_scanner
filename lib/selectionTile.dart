//here are the displayed tiles for the selection of the object data: They show the image with the description and a delete button to delete the object data from the database
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:item_scanner/main.dart';
import 'package:item_scanner/objectData.dart';

class SelectionTile extends StatelessWidget {
  const SelectionTile({super.key, required this.objectData, required this.appState});

  final ObjectData objectData;
  final AppStates appState;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Image.file(File(objectData.imagePath ?? "")),
      title: Text(objectData.description ?? "No description"),
      trailing: IconButton(
        icon: const Icon(Icons.delete),
        onPressed: () {
          appState.databaseAbstranction!.deleteObjectData(objectData.id!);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Object data deleted')),
          );
        },
      ),
      onTap: (){
        print("TODO: implement onTap for SelectionTile");
      }
    );
  }
}