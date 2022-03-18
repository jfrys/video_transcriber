import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:translator/translator.dart';
import 'package:video_transcriber/speech.dart';
import 'dart:io';

class TranscribedPage extends StatefulWidget {
  final String speechText;

  const TranscribedPage({
    Key? key,
    required this.speechText,
  }) : super(key: key);

  @override
  _TranscribedPageState createState() => _TranscribedPageState();
}

class _TranscribedPageState extends State<TranscribedPage> {
  final translator = GoogleTranslator();
  ValueNotifier valueNotifier = ValueNotifier('');
  String dropdownValue = 'en - English';
  bool hasImg = false;
  List<String> transcribedWords = [];
  String keyWord = '';

  splitTranscription() {
    // split transcription into array of Strings
    var arr = valueNotifier.value.toString().split(' ');
    transcribedWords = arr;

    modeTranscribedWords();
    delayIconPreview();
  }

  writeToFile(word) async {
    final file = File('/Users/jamesfrys/Documents/request.txt');
    file.writeAsString(word, mode: FileMode.write, flush: true);
  }

  delayIconPreview() async {
    await writeToFile(keyWord);
    Future.delayed(const Duration(seconds: 3), () async {
      setState(() {
        hasImg = true;
      });
    });
  }

  modeTranscribedWords() {
    var mostUsed = [];
    List<Map<dynamic, dynamic>> data = [];
    var maxOccurrence = 0;

    var i = 0;
    while (i < transcribedWords.length) {
      var number = transcribedWords[i];
      var occurrence = 1;
      for (int j = 0; j < transcribedWords.length; j++) {
        if (j == i) {
          continue;
        }
        else if (number == transcribedWords[j]) {
          occurrence++;
        }
      }
      transcribedWords.removeWhere((it) => it == number);
      data.add({number: occurrence});
      if (maxOccurrence < occurrence) {
        maxOccurrence = occurrence;
      }
    }

    for (var map in data) {
      if (map[map.keys.toList()[0]] == maxOccurrence) {
        mostUsed.add(map.keys.toList()[0]);
      }
    }

    setState(() {
      keyWord = mostUsed[0];
    });
  }

  @override
  void initState() {
    super.initState();
    valueNotifier.value = widget.speechText;
    _editingController = TextEditingController(text: widget.speechText);

    splitTranscription();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        actions: [
          TextButton(
            child: const Text(
              'Start Over',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const Speech()),
                  (route) => false);
            },
          )
        ],
        title: const Text(
          'Transcribinator',
        ),
      ),
      body: SafeArea(
        child: SizedBox(
          height: height,
          width: width,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // dropdown widget to translate text
                Align(
                  alignment: Alignment.centerRight,
                  child: DropdownButton<String>(
                    value: dropdownValue,
                    icon: const Icon(Icons.arrow_drop_down),
                    elevation: 16,
                    style:
                        const TextStyle(fontSize: 20, color: Colors.blueGrey),
                    onChanged: (String? newValue) {
                      setState(() {
                        translator
                            .translate(valueNotifier.value,
                                from: dropdownValue.substring(0, 2),
                                to: newValue!.substring(0, 2))
                            .then((s) {
                          valueNotifier.value = s.toString();
                        });
                        dropdownValue = newValue;
                      });
                    },
                    items: <String>[
                      'en - English',
                      'fr - French',
                      'es - Spanish'
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 12),
                // widget to edit transcribed text
                ValueListenableBuilder(
                  valueListenable: valueNotifier,
                  builder: (context, value, child) {
                    return Expanded(
                      flex: 1,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: _editTitleTextField(),
                      ),
                    );
                  },
                ),
                // display icon
                hasImg ? Image.file(File('/Users/jamesfrys/Documents/$keyWord.png')) : const SizedBox(),
                TextButton(
                  child: const Text(
                    'Advanced Options',
                    style: TextStyle(color: Colors.grey, fontSize: 18),
                  ),
                  onPressed: () {
                    showModalBottomSheet<void>(
                      context: context,
                      builder: (BuildContext context) {
                        return SizedBox(
                          height: 300,
                          child: Column(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              TextButton(
                                child: const Text(
                                  'Share',
                                  style: TextStyle(fontSize: 18),
                                ),
                                onPressed: () => Share.share(
                                    valueNotifier.value.toString()),
                              ),
                              Container(
                                height: 0.5,
                                color: Colors.grey,
                              ),
                              TextButton(
                                child: const Text(
                                  'Edit Text',
                                  style: TextStyle(fontSize: 18),
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                  setState(() {
                                    _isEditingText = true;
                                  });
                                },
                              ),
                              Container(
                                height: 0.5,
                                color: Colors.grey,
                              ),
                              TextButton(
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.grey),
                                ),
                                onPressed: () => Navigator.pop(context),
                              ),
                              const SizedBox(height: 12),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _isEditingText = false;
  late TextEditingController _editingController;

  Widget _editTitleTextField() {
    if (_isEditingText) {
      return Center(
        child: TextField(
          onSubmitted: (newValue) {
            setState(() {
              dropdownValue = 'en - English';
              valueNotifier.value = newValue;
              _isEditingText = false;
              splitTranscription();
            });
          },
          autofocus: true,
          controller: _editingController,
          decoration: const InputDecoration(border: InputBorder.none),
        ),
      );
    }
    return InkWell(
        onTap: () {
          setState(() {
            _isEditingText = true;
            hasImg = false;
          });
        },
        child: Text(valueNotifier.value.toString()));
  }

  @override
  void dispose() {
    super.dispose();
    _editingController.dispose();
  }
}
