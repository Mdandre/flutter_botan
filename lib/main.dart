import 'dart:ffi';
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(
        storage: DataStorage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.storage}) : super(key: key);
  final DataStorage storage;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String musicPath =
      "/Users/marco/Library/Containers/fm.brandtrack.Player/Data/Library/Application Support/Brandtrack/Brandtrack Player/music/0a7c6f26b0dbd2fa73404f052cfc23820de477bf";

  final dylib = DynamicLibrary.open("/Users/marco/Development/BRANDTRACK/flutter_botan/lib/library/botan/amalgamation_darwin/botan_all.cpp");
  final textControllerInput = TextEditingController();
  var textControllerOutput = TextEditingController();
  Future<Directory?>? _appDocumentsDirectory;

  @override
  void initState() {
    super.initState();
    _requestAppDocumentsDirectory();
    widget.storage.readData().then((value) {
      setState(() {
        textControllerOutput.text = value;
      });
    });
  }

  void _requestAppDocumentsDirectory() {
    setState(() {
      _appDocumentsDirectory = getApplicationDocumentsDirectory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("BOTAN"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            textBoxExtension("Input", textControllerInput, false),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: 400,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.black,
                    shape: const ContinuousRectangleBorder(),
                    elevation: 15,
                  ),
                  child: const Text(
                    'Encriptar',
                    style: TextStyle(fontSize: 15, color: Colors.white),
                  ),
                  onPressed: () {
                    widget.storage.writeFile(textControllerInput.text);
                  },
                ),
              ),
            ),
            textBoxExtension("Output", textControllerOutput, true),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: 400,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.black,
                    shape: const ContinuousRectangleBorder(),
                    elevation: 15,
                  ),
                  child: const Text(
                    'Desencriptar',
                    style: TextStyle(fontSize: 15, color: Colors.white),
                  ),
                  onPressed: () async {
                    var value = await widget.storage.readData();
                    setState(() {
                      textControllerOutput.text = value;
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget textBoxExtension(String hintText, TextEditingController textController, bool readOnly) {
    return Container(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
      width: 500,
      height: 200,
      child: TextField(
        readOnly: readOnly,
        controller: textController,
        maxLength: 300,
        maxLines: 10,
        style: const TextStyle(fontSize: 14, color: Colors.black),
        buildCounter: (context, {required currentLength, required isFocused, maxLength}) {
          return Container(
            transform: Matrix4.translationValues(25, 0, 0),
            child: Text(
              "$currentLength/$maxLength",
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          );
        },
        decoration: InputDecoration(
          counterStyle: const TextStyle(fontSize: 14, color: Colors.grey),
          isCollapsed: true,
          filled: true,
          border: const UnderlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(15)),
          ),
          fillColor: Colors.grey.shade400,
          contentPadding: const EdgeInsets.only(left: 20, right: 25, top: 15, bottom: 10),
          hintMaxLines: 3,
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.black38,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class DataStorage {
  Future<File> get _localFile async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    return File('$path/data.txt').create(recursive: true);
  }

  Future<File> writeFile(String textInFile) async {
    final file = await _localFile;
    // Write the file
    return file.writeAsString(textInFile);
  }

  Future<String> readData() async {
    try {
      final file = await _localFile;
      // Read the file
      final contents = await file.readAsString();
      return contents;
    } catch (e) {
      // If encountering an error, return 0
      return "null";
    }
  }
}
