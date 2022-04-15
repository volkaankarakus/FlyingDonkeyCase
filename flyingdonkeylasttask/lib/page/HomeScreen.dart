import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

import 'package:flyingdonkeylasttask/api/FirebaseApi.dart';
import 'package:flyingdonkeylasttask/model/FirebaseFile.dart';
import 'package:flyingdonkeylasttask/page/ImageScreen.dart';
import 'package:flyingdonkeylasttask/const/Colors.dart' as colors;

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String fileType = 'All';
  var fileTypeList = ['All', 'Image', 'Video', 'Audio'];
  FilePickerResult? result;
  PlatformFile? file;

  UploadTask? task;
  File? savedFile;

  late Future<List<FirebaseFile>> futureFiles;

  bool visibleUploadFirebase = true;

  @override
  void initState() {
    super.initState();

    futureFiles = FirebaseApi.listAll('files/');
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: Text('Flying Donkey Task'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => super.widget));
            },
            icon: Icon(Icons.refresh),
          ),
        ],
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              colors.AppColor.AppbarFirstGradient,
              colors.AppColor.AppbarSecondGradient
            ], begin: Alignment.bottomRight, end: Alignment.topLeft),
          ),
        ),
        elevation: 20,
      ),
      body: FutureBuilder<List<FirebaseFile>>(
          future: futureFiles,
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return Center(child: CircularProgressIndicator());
              default:
                if (snapshot.hasError) {
                  return Center(child: Text('Some error occurred!'));
                } else {
                  final files = snapshot.data!;

                  return Container(
                    decoration: BoxDecoration(
                      color: colors.AppColor.BackgroundColor,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        buildHeader(files.length),
                        const SizedBox(height: 12),
                        Container(
                          padding: EdgeInsets.only(top: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Selected File Type:  ',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20),
                              ),
                              DropdownButton(
                                value: fileType,
                                items: fileTypeList.map((String type) {
                                  return DropdownMenuItem(
                                      value: type,
                                      child: Text(
                                        type,
                                        style: TextStyle(fontSize: 20),
                                      ));
                                }).toList(),
                                onChanged: (String? value) {
                                  setState(() {
                                    fileType = value!;
                                    file = null;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        Container(
                          child: ElevatedButton(
                            onPressed: () async {
                              pickFiles(fileType);
                            },
                            child: Text('Pick file'),
                          ),
                        ),
                        if (file != null) buildFileUpload(file!),
                        if (file != null)
                          Container(
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Container(
                                    child: ElevatedButton.icon(
                                      icon: Icon(
                                        Icons.upload_file,
                                        color: colors.AppColor.IconAppStorage,
                                        size: 24,
                                      ),
                                      label: Text('appStorage',
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: colors
                                                  .AppColor.TextAppStorage)),
                                      style: ElevatedButton.styleFrom(
                                        elevation: 10,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10)),
                                        ),
                                      ),
                                      onPressed: () async {
                                        final file = result!.files.first;
                                        final savedFile =
                                            await saveFilePermanently(file);
                                        final oldPath = file.path!;
                                        final newPath = savedFile.path;
                                        print('From path : $oldPath');
                                        print('To path : $newPath');
                                        final snackBar = SnackBar(
                                          content:
                                              Text('Uploaded to appStorage.'),
                                        );
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(snackBar);
                                      },
                                    ),
                                  ),
                                  if (file != null)
                                    ElevatedButton.icon(
                                      icon: Icon(
                                        Icons.cloud_upload,
                                        color:
                                            colors.AppColor.IconFirebaseStorage,
                                        size: 24,
                                      ),
                                      label: Text('Firebase',
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: colors.AppColor
                                                  .TextFirebaseStorage)),
                                      style: ElevatedButton.styleFrom(
                                        elevation: 10,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10)),
                                        ),
                                      ),
                                      onPressed: uploadFile,
                                    ),
                                  task != null
                                      ? buildUploadStatus(task!)
                                      : Container(),
                                ]),
                          ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: files.length,
                            itemBuilder: (context, index) {
                              final file = files[index];

                              return buildFileDownload(context, file);
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                }
            }
          }));

  Widget buildHeader(int length) => Container(
        decoration: BoxDecoration(
            color: Color(0xDD000000),
            borderRadius:
                BorderRadius.only(bottomRight: Radius.circular(22.0))),
        child: ListTile(
          leading: Container(
            width: 52,
            height: 52,
            child: Icon(
              Icons.file_copy,
              color: Color(0xFFFFFFFF),
            ),
          ),
          title: Text(
            '$length Files',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Color(0x4DFFFFFF),
            ),
          ),
        ),
      );

  Widget buildFileDownload(BuildContext context, FirebaseFile file) =>
      Container(
        padding: EdgeInsets.all(8),
        margin: EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
              colors: [Color(0xFF424242), Color(0XFF212121)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight),
        ),
        child: ListTile(
          leading: ClipOval(
            child: Image.network(
              file.url,
              width: 52,
              height: 52,
              fit: BoxFit.cover,
            ),
          ),
          title: Text(
            file.name,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFFFAFAFA),
            ),
          ),
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => ImageScreen(file: file),
          )),
        ),
      );

  Future<void> pickFiles(String? filetype) async {
    switch (filetype) {
      case 'Image':
        result = await FilePicker.platform.pickFiles(type: FileType.image);
        if (result == null) return;
        file = result!.files.first;
        setState(() {});
        break;
      case 'Video':
        result = await FilePicker.platform.pickFiles(type: FileType.video);
        if (result == null) return;
        file = result!.files.first;
        setState(() {});
        break;
      case 'Audio':
        result = await FilePicker.platform.pickFiles(type: FileType.audio);
        if (result == null) return;
        file = result!.files.first;
        setState(() {});
        break;
      case 'All':
        result = await FilePicker.platform.pickFiles();
        if (result == null) return;
        file = result!.files.first;
        setState(() {});
        break;
    }
  }

  Widget buildFileUpload(PlatformFile file) {
    final kb = file.size / 1024;
    final mb = kb / 1024;
    final size = (mb >= 1)
        ? '${mb.toStringAsFixed(2)} MB'
        : '${kb.toStringAsFixed(2)} KB';
    return InkWell(
      onTap: () => viewFile(file),
      child: ListTile(
        leading: (file.extension == 'jpg' || file.extension == 'png')
            ? Image.file(
                File(file.path.toString()),
                width: 80,
                height: 80,
              )
            : Container(
                alignment: Alignment.center,
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: colors.AppColor.ContainerUploadExtension,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '.${file.extension}',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: colors.AppColor.TextUploadExtension,
                  ),
                ),
              ),
        title: Text('${file.name}'),
        subtitle: Text('${file.extension}'),
        trailing: Text(
          '$size',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  // open the picked file
  void viewFile(PlatformFile file) {
    OpenFile.open(file.path);
  }

  // saving file permanently with path_provider
  Future<File> saveFilePermanently(PlatformFile file) async {
    final appStorage = await getApplicationDocumentsDirectory();
    final savedFile = File('${appStorage.path}/${file.name}');
    return File(file.path!).copy(savedFile.path);
  }

  // upload file to firebase
  Future uploadFile() async {
    if (file == null) return;
    final fileName = file!.name;
    final destination = 'files/$fileName';

    task = FirebaseApi.uploadFile(destination, File(file!.path!));
    setState(() {});

    if (task == null) return;

    final snapshot = await task!.whenComplete(() {});
    final urlDownload = await snapshot.ref.getDownloadURL();
    print('Download-link : $urlDownload');
  }

  Widget buildUploadStatus(UploadTask task) => StreamBuilder<TaskSnapshot>(
        stream: task.snapshotEvents,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final snap = snapshot.data!;
            final progress = snap.bytesTransferred / snap.totalBytes;
            final percentage = (progress * 100).toStringAsFixed(2);

            return Column(
              children: [
                '$percentage%' != '100.00%'
                    ? Text(
                        '$percentage%',
                        style: TextStyle(
                            color: colors.AppColor.TextUploadPercentage,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      )
                    : Container(
                        child: Icon(
                          Icons.check,
                          color: colors.AppColor.IconUploadedCheck,
                          size: 24,
                        ),
                      ),
              ],
            );
          } else {
            return Container();
          }
        },
      );
}
