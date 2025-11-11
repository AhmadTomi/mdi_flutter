import 'package:flutter/material.dart';
import 'package:flutter_app_mdi/mdi/mdi_style.dart';
import 'package:flutter_app_mdi/mdi/parameter_window.dart';

import 'mdi/mdi_manager/mdi_controller.dart';
import 'mdi/mdi_manager/mdi_manager.dart';

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
      debugShowCheckedModeBanner: false,
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
            String id = count.toString();
            controller.addWindow(
              parameter: ParameterWindow(
                title: "Window $id Syalalalala",
                id: DateTime.now().millisecondsSinceEpoch.toString(),
              ),
              child: (controller) => Builder(builder: (context) => Column(
                children: [
                  controller.dragWidget(
                      child: Container(
                        color: Colors.blue.shade700,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        height: 30,
                        alignment: Alignment.center,
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                "Window $id",
                                style: const TextStyle(color: Colors.white),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              padding: EdgeInsets.zero,
                              iconSize: 16,
                              visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                              onPressed: () => controller.close(), // Close button
                              icon: const Icon(Icons.close, color: Colors.white),
                            )
                          ],
                        ),
                      )
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      alignment: Alignment.topLeft,
                      width: double.infinity, // Ensure it fills the space
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '''
                      ${id.toString()} Lorem Ipsum is simply dummy text...
                                  ''',
                              style: const TextStyle(color: Colors.white),
                            ),
                            // If you need the controller (e.g., for a button):
                            TextButton(
                              onPressed: () {
                                // This is how you access the controller now!
                                controller.close();
                              },
                              child: const Text("Close from inside"),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              )),
            );
            count++;
          }),
      body: MdiManager(
          controller: controller,
        style: MdiStyleConfiguration(
          borderRadius: 4,
          gap: 1,
        ),
      ),
    );
  }
}
