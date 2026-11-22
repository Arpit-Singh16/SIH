import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unlisted2/Bottomnavigation.dart';
import 'package:unlisted2/Homepage.dart';
import 'package:unlisted2/Spalshpage.dart';
import 'package:unlisted2/selectlanguage.dart';
import 'LoginPage.dart';
import 'Profilepage.dart';
import 'Requetsform.dart';
import 'Serivce/language provider.dart';
import 'Serivce/test.dart';

void main() {
  runApp( ChangeNotifierProvider(
    create: (_) => LanguageProvider(),
    child: Start(),));
}

class Start extends StatefulWidget {
  const Start({super.key});

  @override
  State<Start> createState() => _StartState();
}

class _StartState extends State<Start> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Loginpage(),
    );
  }
}
