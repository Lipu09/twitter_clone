import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitter_clone/firebase_options.dart';
import 'package:twitter_clone/pages/home_page.dart';
import 'package:twitter_clone/pages/login_page.dart';
import 'package:twitter_clone/pages/register_page.dart';
import 'package:twitter_clone/services/auth/auth_gate.dart';
import 'package:twitter_clone/services/auth/login_or_register.dart';
import 'package:twitter_clone/services/database/database_provider.dart';
import 'package:twitter_clone/themes/dark_mode.dart';
import 'package:twitter_clone/themes/light_mode.dart';
import 'package:twitter_clone/themes/theme_provider.dart';

void main() async {

  //firebase setup
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  //run app
  runApp(
    MultiProvider(
        providers: [
          //theme provider
          ChangeNotifierProvider(create: (context) => ThemeProvider(),),

          // database provider
          ChangeNotifierProvider(create: (context) => DatabaseProvider(),),
        ],
      child: MyApp(),
    ),

  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/':(context) => AuthGate(),
      },
      theme: Provider.of<ThemeProvider>(context).themeData,
    );
  }
}
