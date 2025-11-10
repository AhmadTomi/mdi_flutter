import 'package:flutter/material.dart';
import 'package:flutter_app_mdi/mdi/parameter_window.dart';

import 'mdi/mdi_controller.dart';
import 'mdi/mdi_manager.dart';

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

  MdiController controller = MdiController();

  int count =1;

  @override
  void dispose() {
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    if(MediaQuery.sizeOf(context).width<=600){
      return Scaffold(
          backgroundColor: Colors.white60,
          body: TextFormField()
      );
    }
    return Scaffold(
      backgroundColor: Colors.white60,
      floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.blue,
          onPressed: (){
            final String id = count.toString();
            controller.addWindow(
              parameter: ParameterWindow(title: "Window $id Syalalalala",id: DateTime.now().millisecondsSinceEpoch.toString()),
              child: (controller) => Column(
                children: [
                  controller.dragWidget(
                    child: Container(
                        color: Colors.blue,
                        padding: EdgeInsets.symmetric(vertical: 4,horizontal: 12),
                        alignment: Alignment.center,
                        child: Row(
                          children: [
                            Expanded(child: Text("data $id")),
                            IconButton(
                                padding: EdgeInsets.zero,
                                iconSize: 16,
                                visualDensity: VisualDensity(horizontal: -4,vertical: -4),
                                onPressed: (){
                                  controller.close();
                                }, icon: const Icon(Icons.close))
                          ],
                        )
                    ),
                  ),
                  Expanded(
                    child: Container(
                        padding: const EdgeInsets.all(16),
                        alignment: Alignment.topLeft,
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Text('''
 ${id.toString()} Lorem Ipsum is simply dummy text of the printing and typesetting industry. 
Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, 
when an unknown printer took a galley of type and scrambled it to make a type specimen book. 
It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. 
It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with 
desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.
            ''',style: TextStyle(color: Colors.white),),
                            ],
                          ),
                        )),
                  ),
                ],
              ),
            );
            count++;
          }),
      body: MdiManager(controller: controller),
    );
  }
}
