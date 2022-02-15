import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:video_transcriber/preview_video.dart';
import 'package:video_transcriber/speech.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: Speech(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String dropdownValue = 'English';

  @override
  void initState() {
    super.initState();
  }

  _pickFile() async {

    // opens storage to pick files and the picked file or files
    // are assigned into result and if no file is chosen result is null.
    // you can also toggle "allowMultiple" true or false depending on your need
    final result = await FilePicker.platform.pickFiles(allowMultiple: false);

    // if no file is picked
    if (result == null) return;

    // we will log the name, size and path of the
    // first picked file (if multiple are selected)
    print(result.files.first.name);
    print(result.files.first.size);
    print(result.files.first.path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          TextButton(
            child: const Text('Next', style: TextStyle(color: Colors.white, fontSize: 16),),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => PreviewVideo(file: '', language: dropdownValue,)));
            },
          )
        ],
        title: const Text(
          'Transcribinator',
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Hello, Welcome to Transcribinator!\n\nPlease enter or select a video file:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 48),
              const TextField(
                decoration: InputDecoration(
                    hintText: 'Enter file...', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              const Center(
                child: Text(
                  'or',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: OutlinedButton(
                  onPressed: () async {
                    _pickFile();
                  },
                  child: const Text(
                    'Search for file',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ),
              const SizedBox(height: 48),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select Language:',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: DropdownButton<String>(
                      value: dropdownValue,
                      icon: const Icon(Icons.arrow_drop_down),
                      elevation: 16,
                      style: const TextStyle(fontSize: 20, color: Colors.blueGrey),
                      onChanged: (String? newValue) {
                        setState(() {
                          dropdownValue = newValue!;
                        });
                      },
                      items: <String>['English', 'Spanish', 'Chinese']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
