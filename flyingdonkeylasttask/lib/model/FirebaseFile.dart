import 'package:firebase_storage/firebase_storage.dart';

class FirebaseFile{
  final Reference ref;
  final String name;
  final String url;
  // final String lastModified,

  const FirebaseFile({
    required this.ref,
    required this.name,
    required this.url,
});
}