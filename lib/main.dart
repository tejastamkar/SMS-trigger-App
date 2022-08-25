import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:telephony/telephony.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  Telephony telephony = Telephony.instance;
  bool permissionsGranted = false;
  String? deviceId;
  String? phoneNo;
  String? message;

  List<String> deviceIds = <String>['SP1A.210812.016'];

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  void sendSms(String? number, String? message) async {
    if (number == null || message == null) {
      return;
    } else {
      String currentId = await getDeviceId();
      if (deviceIds.contains(currentId)) {
        await telephony.sendSms(to: number, message: message);
      }
    }
  }

  //get deivce id
  Future<String> getDeviceId() async {
    //device info
    await DeviceInfoPlugin().androidInfo.then((value) {
      deviceId = value.id;
    });
    debugPrint(deviceId);
    return deviceId ?? '';
  }

  @override
  void initState() {
    super.initState();
    permissions();
    getDeviceId();
  }

  void permissions() async {
    permissionsGranted = await telephony.requestSmsPermissions ?? false;
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    return StreamBuilder<QuerySnapshot>(
        stream: firestore.collection('Message').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          for (var element in snapshot.data?.docs ?? []) {
            element.reference.delete();
          }

          final List? messagesString = snapshot.data?.docs.map((doc) {
            return doc.data();
          }).toList();

          print(messagesString);

          messagesString?.forEach((element) async {
            sendSms(element["Phone"], element["Msg"]);
          });

          for (var element in snapshot.data?.docs ?? []) {
            element.reference.delete();
          }

          return Scaffold(
            appBar: AppBar(
              // Here we take the value from the MyHomePage object that was created by
              // the App.build method, and use it to set our appbar title.
              title: Text(widget.title),
            ),
            body: Center(
              // Center is a layout widget. It takes a single child and positions it
              // in the middle of the parent.
              child: Column(
                // Column is also a layout widget. It takes a list of children and
                // arranges them vertically. By default, it sizes itself to fit its
                // children horizontally, and tries to be as tall as its parent.
                // Invoke "debug painting" (press "p" in the console, choose the
                // "Toggle Debug Paint" action from the Flutter Inspector in Android
                // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
                // to see the wireframe for each widget.
                //
                // Column has various properties to control how it sizes itself and
                // how it positions its children. Here we use mainAxisAlignment to
                // center the children vertically; the main axis here is the vertical
                // axis because Columns are vertical (the cross axis would be
                // horizontal).
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    '$_counter',
                    style: Theme.of(context).textTheme.headline4,
                  ),
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                sendSms(phoneNo, message);
                snapshot.data?.docs.clear();
              },
              tooltip: 'Increment',
              child: const Icon(Icons.add),
            ), // This trailing comma makes auto-formatting nicer for build methods.
          );
        });
  }
}

final Stream<QuerySnapshot> collectionStream =
    FirebaseFirestore.instance.collection('Messages').snapshots();

//stream builder firestore




