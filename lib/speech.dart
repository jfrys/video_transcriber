import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:video_transcriber/transcribed_page.dart';

class Speech extends StatefulWidget {
  const Speech({Key? key}) : super(key: key);

  @override
  _SpeechState createState() => _SpeechState();
}

class _SpeechState extends State<Speech> {
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = '';

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  void _startListening() async {
    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {});
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = result.recognizedWords;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transcribinator'),
        actions: [
          _lastWords == '' ? const SizedBox() : TextButton(
            child: const Text('Next', style: TextStyle(color: Colors.white, fontSize: 16),),
            onPressed: () {
              _stopListening();
              Navigator.push(context, MaterialPageRoute(builder: (context) => TranscribedPage(speechText: _lastWords)));
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                _lastWords == '' ? 'Start Transcribing' : 'Recognized words:',
                style: const TextStyle(fontSize: 20.0),
              ),
              const SizedBox(height: 24.0),
              Expanded(
                child: _lastWords == '' ? Text(
                  _speechToText.isListening
                      ? _lastWords
                      : _speechEnabled
                          ? 'Tap the microphone to start...'
                          : 'Speech not available',
                ) : Text(
                  _speechToText.isListening
                      ? _lastWords
                      : _speechEnabled
                      ? '$_lastWords \n\n\nTap the microphone again to start over...'
                      : 'Speech not available',
                )
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _speechToText.isNotListening ? _startListening : _stopListening,
        tooltip: 'Listen',
        child: Icon(_speechToText.isNotListening ? Icons.mic : Icons.mic_off),
      ),
    );
  }
}
