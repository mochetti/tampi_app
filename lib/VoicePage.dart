import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class VoicePage extends StatefulWidget {
  @override
  _VoicePageState createState() => _VoicePageState();
}

class _VoicePageState extends State<VoicePage> {
  bool _hasSpeech = false;
  double level = 0.0;
  double minSoundLevel = 50000;
  double maxSoundLevel = -50000;
  String lastWords = "";
  String lastError = "";
  String lastStatus = "";
  String _currentLocaleId = "pt-BR";
  List<LocaleName> _localeNames = [];
  final SpeechToText speech = SpeechToText();

  @override
  void initState() {
    initSpeechState();
    super.initState();
  }

  Future<void> initSpeechState() async {
    bool hasSpeech = await speech.initialize(
        onError: errorListener, onStatus: statusListener);
    if (hasSpeech) {
      _localeNames = await speech.locales();

      // var systemLocale = await speech.systemLocale();
      // _currentLocaleId = systemLocale.localeId;
    }

    if (!mounted) return;

    setState(() {
      _hasSpeech = hasSpeech;
    });
  }

  @override
  Widget build(BuildContext context) {
    return !_hasSpeech
        ? Container(child: CircularProgressIndicator())
        : MaterialApp(
            home: Scaffold(
              appBar: AppBar(
                title: const Text('Voice Page'),
                actions: [
                  IconButton(
                    icon: Icon(Icons.info),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VoiceInfoPage(),
                        ),
                      );
                    },
                  )
                ],
              ),
              body: Column(children: [
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Text('Language: '),
                    DropdownButton(
                      onChanged: (selectedVal) => _switchLang(selectedVal),
                      value: _currentLocaleId,
                      items: _localeNames
                          .map(
                            (localeName) => DropdownMenuItem(
                              value: localeName.localeId,
                              child: Text(localeName.name),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),

                Expanded(
                  child: Stack(
                    children: <Widget>[
                      Container(
                        color: Theme.of(context).selectedRowColor,
                        child: Center(
                          child: Text(
                            lastWords,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Expanded(
                //   flex: 1,
                //   child: Column(
                //     children: <Widget>[
                //       Center(
                //         child: Text(
                //           'Error Status',
                //           style: TextStyle(fontSize: 22.0),
                //         ),
                //       ),
                //       Center(
                //         child: Text(lastError),
                //       ),
                //     ],
                //   ),
                // ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  color: Theme.of(context).backgroundColor,
                  child: Center(
                    child: speech.isListening
                        ? Text(
                            "I'm listening...",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )
                        : Text(
                            'Not listening',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
                Container(
                  width: 100,
                  height: 100,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                          blurRadius: .26,
                          spreadRadius: level * 1.5,
                          color: Colors.black.withOpacity(.05))
                    ],
                    color: Colors.orangeAccent,
                    borderRadius: BorderRadius.all(Radius.circular(50)),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.mic),
                    onPressed: !_hasSpeech
                        ? null
                        : speech.isListening
                            ? stopListening
                            : startListening,
                  ),
                ),
              ]),
            ),
          );
  }

  void startListening() {
    lastWords = "";
    lastError = "";
    speech.listen(
        onResult: resultListener,
        listenFor: Duration(seconds: 10),
        localeId: _currentLocaleId,
        onSoundLevelChange: soundLevelListener,
        cancelOnError: true,
        listenMode: ListenMode.confirmation);
    setState(() {});
  }

  void stopListening() {
    speech.stop();
    setState(() {
      level = 0.0;
    });
  }

  // void cancelListening() {
  //   speech.cancel();
  //   setState(() {
  //     level = 0.0;
  //   });
  // }

  void resultListener(SpeechRecognitionResult result) {
    setState(() {
      // lastWords = "${result.recognizedWords} - ${result.finalResult}";
      lastWords = result.recognizedWords;
      print('lastWords: $lastWords');
    });
    switchCommand();
  }

  void soundLevelListener(double level) {
    minSoundLevel = min(minSoundLevel, level);
    maxSoundLevel = max(maxSoundLevel, level);
    // print("sound level $level: $minSoundLevel - $maxSoundLevel ");
    setState(() {
      this.level = level;
    });
  }

  void errorListener(SpeechRecognitionError error) {
    // print("Received error status: $error, listening: ${speech.isListening}");
    setState(() {
      lastError = "${error.errorMsg} - ${error.permanent}";
    });
  }

  void statusListener(String status) {
    // print(
    // "Received listener status: $status, listening: ${speech.isListening}");
    setState(() {
      lastStatus = "$status";
    });
  }

  _switchLang(selectedVal) {
    setState(() {
      _currentLocaleId = selectedVal;
    });
    print(selectedVal);
  }

  // Check if last words form a valid command
  void switchCommand() {
    String comando = 'none';
    if (lastWords.contains('vire')) {
      if (lastWords.contains('direita')) {
        comando = 'virar a direita';
      }
    }
    print('comando: $comando');
  }
}

class VoiceInfoPage extends StatefulWidget {
  @override
  _VoiceInfoPageState createState() => _VoiceInfoPageState();
}

class _VoiceInfoPageState extends State<VoiceInfoPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('Exemplos de frases')),
    );
  }
}
