import 'dart:async';
import 'dart:math';
import 'websocket.dart';
import 'bottle_cap_button_widget.dart';
import 'package:bubble/bubble.dart';

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

  List<Widget> bubbles = [];
  ScrollController scrollController = new ScrollController();
  SpeechToText speech = SpeechToText();
  bool playing = false;

  final TextEditingController textEditingController =
      new TextEditingController();

  @override
  void initState() {
    // player.clearCache();
    initSpeechState();
    super.initState();
  }

  Future<void> initSpeechState() async {
    bool hasSpeech = await speech.initialize(
        onError: errorListener, onStatus: statusListener);

    if (!mounted) return;

    setState(() {
      _hasSpeech = hasSpeech;
    });
  }

  @override
  Widget build(BuildContext context) {
    Timer(
      Duration(milliseconds: 300),
      () => scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      ),
    );
    return !_hasSpeech
        ? Container(child: CircularProgressIndicator())
        : MaterialApp(
            home: Scaffold(
              backgroundColor: Colors.grey[100],
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
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    children: <Widget>[
                      Bubble(
                        margin: BubbleEdges.only(
                            top: 10, right: 55, bottom: 10, left: 10),
                        elevation: 1,
                        alignment: Alignment.bottomLeft,
                        nip: BubbleNip.leftTop,
                        child: Text(
                          'Olá! Seja bem-vindo ao meu controle de voz. Fale um comando para eu executar.',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontStyle: FontStyle.normal,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      for (Bubble b in bubbles) b,
                    ],
                  ),
                ),
                Container(
                  constraints: BoxConstraints(minWidth: double.infinity),
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                  ),
                  child: lastWords != ''
                      ? Text(
                          lastWords,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontStyle: FontStyle.normal,
                            letterSpacing: 1.2,
                          ),
                        )
                      : speech.isListening
                          ? Text(
                              'ouvindo...',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontStyle: FontStyle.normal,
                                letterSpacing: 1.2,
                              ),
                            )
                          : Text(
                              'Aperte o botão para falar comigo',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontStyle: FontStyle.normal,
                                letterSpacing: 1.2,
                              ),
                            ),
                ),
                Container(
                    constraints: BoxConstraints(minWidth: double.infinity),
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                    ),
                    child: bottleCapButton(
                      leadingIcon: Icon(Icons.mic),
                      color: Colors.orange,
                      onClick: !_hasSpeech || playing
                          ? null
                          : speech.isListening
                              ? stopListening
                              : startListening,
                    )),
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
    lastWords = result.recognizedWords;

    if (result.finalResult) {
      setState(() {
        bubbles.add(
          Bubble(
            margin: BubbleEdges.only(top: 10, right: 10, bottom: 10),
            elevation: 1,
            alignment: Alignment.bottomRight,
            nip: BubbleNip.rightTop,
            color: Color.fromARGB(255, 225, 255, 199),
            child: Text(
              lastWords,
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontStyle: FontStyle.normal,
                letterSpacing: 1.2,
              ),
            ),
          ),
        );

        if (!playing) switchCommand();
        lastWords = '';
      });
    }
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
