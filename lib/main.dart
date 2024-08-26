import 'package:flutter/material.dart';
import 'package:flutter_app_mdi/mdi/mdi_manager.dart';

import 'mdi/mdi_controller.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter MDI Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  late MdiController mdiController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: (){
        mdiController.addWindow(
          "Widget ${UniqueKey()}",
          const Placeholder()
        );
      },),
      body: MdiManager(onMdiControllerCreated: (controller){
        mdiController=controller;
      }),
    );
  }
}
