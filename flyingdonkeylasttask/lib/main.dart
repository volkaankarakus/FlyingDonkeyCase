import 'package:flutter/material.dart';
import 'package:flyingdonkeylasttask/page/HomeScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        // title: 'Flying Donkey',
        theme: ThemeData(
          primarySwatch: Colors.blueGrey,
        ),
        home: HomeScreen(),
      );
}
