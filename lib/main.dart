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
      backgroundColor: Colors.black45,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: (){
        mdiController.addWindow(
          "Widget",
          Container(
            height: 600,
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade50,
            alignment: Alignment.topLeft,
            child: const Text('''
Lorem Ipsum is simply dummy text of the printing and typesetting industry. 
Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, 
when an unknown printer took a galley of type and scrambled it to make a type specimen book. 
It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. 
It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with 
desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.
            '''))
        );
      },),
      body: MdiManager(onMdiControllerCreated: (controller){
        mdiController=controller;
      }),
    );
  }
}
