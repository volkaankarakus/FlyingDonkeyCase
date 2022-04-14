import 'package:flutter/material.dart';
import 'package:flyingdonkeylasttask/api/FirebaseApi.dart';
import 'package:flyingdonkeylasttask/model/FirebaseFile.dart';

class ImageScreen extends StatelessWidget {
  final FirebaseFile file;

  const ImageScreen({
    Key? key,
    required this.file,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isImage = ['.jpeg', '.jpg', '.png','webp'].any(file.name.contains);

    return Scaffold(
      appBar: AppBar(
        title: Text(file.name),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [Color(0xFF212121),Color(0xFF303030)],
                begin: Alignment.bottomRight,
                end : Alignment.topLeft
            ),
          ),
        ),
        elevation: 20,
        actions: [
          IconButton(
            icon: Icon(Icons.file_download),
            onPressed: () async {
              await FirebaseApi.downloadFile(file.ref);

              final snackBar = SnackBar(
                content: Text('Downloaded ${file.name}'),
              );
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            },
          ),
        ],
      ),
      body: isImage
          ? Image.network(
        file.url,
        width: double.infinity,
        fit: BoxFit.cover,
      )
          : Center(
        child: Text(
          'Cannot be displayed',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}