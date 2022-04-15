import 'package:flutter/material.dart';
import 'package:flyingdonkeylasttask/api/FirebaseApi.dart';
import 'package:flyingdonkeylasttask/model/FirebaseFile.dart';
import 'package:flyingdonkeylasttask/const/Colors.dart' as colors;

class ImageScreen extends StatelessWidget {
  final FirebaseFile file;

  const ImageScreen({
    Key? key,
    required this.file,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isImage = ['.jpeg', '.jpg', '.png', 'webp'].any(file.name.contains);

    return Scaffold(
      appBar: AppBar(
        title: Text(file.name),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              colors.AppColor.AppbarFirstGradient,
              colors.AppColor.AppbarSecondGradient
            ], begin: Alignment.bottomRight, end: Alignment.topLeft),
          ),
        ),
        elevation: 20,
        actions: [
          IconButton(
            icon: Icon(
              Icons.file_download,
              color: colors.AppColor.IconDownload,
            ),
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
                style: TextStyle(
                    color: colors.AppColor.TextDisplayError,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
            ),
    );
  }
}
