import 'package:flutter/material.dart';

import 'app/init_firebase.dart';
import 'app/views/list_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  /*==================================================
    Inicialização do Firebase
   =================================================*/
  await InitFirebase.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: ListPage());
  }
}
