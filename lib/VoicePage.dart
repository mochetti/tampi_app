import 'dart:async';
import 'dart:math';
import 'websocket.dart';

import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';

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
  SpeechToText speech = SpeechToText();
  // AudioCache player = AudioCache();
  // Audio player = new Audio();
  bool playing = false;

  @override
  void initState() {
    // player.clearCache();
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
                Container(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  color: Theme.of(context).backgroundColor,
                  child: Center(
                    child: speech.isListening
                        ? Text(
                            "...",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )
                        : Text(
                            'Aperte o botão',
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
                    onPressed: !_hasSpeech || playing
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
        listenFor: Duration(seconds: 5),
        localeId: _currentLocaleId,
        onSoundLevelChange: soundLevelListener,
        cancelOnError: true,
        listenMode: ListenMode.confirmation);
    setState(() {});
    print('startListening: $playing');
  }

  void stopListening() {
    speech.stop();
    setState(() {
      level = 0.0;
    });
  }

  void cancelListening() {
    speech.cancel();
    setState(() {
      level = 0.0;
    });
  }

  void resultListener(SpeechRecognitionResult result) {
    setState(() {
      // lastWords = "${result.recognizedWords} - ${result.finalResult}";
      lastWords = result.recognizedWords;
      print('lastWords: $lastWords');
    });
    print('resultListener: $playing');
    if (!playing) switchCommand();
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
    print("Received error status: $error, listening: ${speech.isListening}");
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
  void switchCommand() async {
    print('switching command ...');
    String comando = '';
    if (lastWords.contains('frente')) {
      comando = '0';
      playSound('andando_para_frente.mp3');
    } else if (lastWords.contains('vire') || lastWords.contains('Vire')) {
      if (lastWords.contains('direita')) {
        comando = '1';
        playSound('virando_a_direita.mp3');
      } else if (lastWords.contains('esquerda')) {
        comando = '2';
        playSound('virando_a_esquerda.mp3');
      }
    }
    if (comando == null) return;

    comando = 'a' + comando + 'e';
    print('comando: $comando');
    sockets.send(comando);
  }

  void playSound(String file) async {
    AudioPlayer audioPlayer = new AudioPlayer();
    audioPlayer.monitorNotificationStateChanges(audioPlayerHandler);
    AudioCache audioCache = new AudioCache();
    print('playing $file');
    cancelListening();
    await audioCache.play(file);
    setState(() {
      playing = true;
    });
    Timer(Duration(seconds: 3), handleTimer);
  }

  void handleTimer() {
    print('timer off');
    setState(() {
      playing = false;
    });
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

void audioPlayerHandler(AudioPlayerState value) {
  print('state: $value');
}
