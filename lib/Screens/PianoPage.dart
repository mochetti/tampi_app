import 'package:flutter/material.dart';
// import 'websocket.dart';
import 'package:flutter/services.dart';
import 'package:flutter_midi/flutter_midi.dart';
import 'package:tonic/tonic.dart';

class PianoPage extends StatefulWidget {
  @override
  _PianoPageState createState() => _PianoPageState();
}

class _PianoPageState extends State<PianoPage> {
  List<Nota> notas = [];
  double freq = 200;
  double get keyWidth => 80 + (80 * _widthRatio);
  double _widthRatio = 0.0;
  bool _showLabels = true;
  FlutterMidi midi = new FlutterMidi();

  initState() {
    midi.unmute();
    rootBundle.load("assets/sounds/Piano.SF2").then((sf2) {
      midi.prepare(sf2: sf2, name: "Piano.SF2");
    });
    super.initState();
  }

  Future<bool> _onWillPop() async {
    try {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
      Navigator.pop(context);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    return WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          appBar: AppBar(
            title: Text("Piano"),
          ),
          body: Scaffold(
            drawer: Drawer(
                child: SafeArea(
                    child: ListView(children: <Widget>[
              Container(height: 20.0),
              ListTile(title: Text("Change Width")),
              Slider(
                  activeColor: Colors.redAccent,
                  inactiveColor: Colors.white,
                  min: 0.0,
                  max: 1.0,
                  value: _widthRatio,
                  onChanged: (double value) =>
                      setState(() => _widthRatio = value)),
              Divider(),
              ListTile(
                  title: Text("Show Labels"),
                  trailing: Switch(
                      value: _showLabels,
                      onChanged: (bool value) =>
                          setState(() => _showLabels = value))),
              Divider(),
            ]))),
            body: ListView.builder(
              itemCount: 7,
              controller: ScrollController(initialScrollOffset: 1500.0),
              scrollDirection: Axis.horizontal,
              itemBuilder: (BuildContext context, int index) {
                final int i = index * 12;
                return SafeArea(
                  child: Stack(
                    children: <Widget>[
                      Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                        _buildKey(24 + i, false),
                        _buildKey(26 + i, false),
                        _buildKey(28 + i, false),
                        _buildKey(29 + i, false),
                        _buildKey(31 + i, false),
                        _buildKey(33 + i, false),
                        _buildKey(35 + i, false),
                      ]),
                      Positioned(
                          left: 0.0,
                          right: 0.0,
                          bottom: 100,
                          top: 0.0,
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Container(width: keyWidth * .5),
                                _buildKey(25 + i, true),
                                _buildKey(27 + i, true),
                                Container(width: keyWidth),
                                _buildKey(30 + i, true),
                                _buildKey(32 + i, true),
                                _buildKey(34 + i, true),
                                Container(width: keyWidth * .5),
                              ])),
                    ],
                  ),
                );
              },
            ),
          ),
        ));
  }

  @override
  dispose() {
    super.dispose();
  }

  Widget _buildKey(int m, bool accidental) {
    final pitchName = Pitch.fromMidiNumber(m).toString();
    final pianoKey = Stack(
      children: <Widget>[
        Semantics(
            button: true,
            hint: pitchName,
            child: Material(
                borderRadius: borderRadius,
                color: accidental ? Colors.black : Colors.white,
                child: InkWell(
                  borderRadius: borderRadius,
                  highlightColor: Colors.grey,
                  onTap: () {},
                  onTapDown: (_) => midi.playMidiNote(midi: m),
                ))),
        Positioned(
            left: 0.0,
            right: 0.0,
            bottom: 20.0,
            child: _showLabels
                ? Text(pitchName,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: !accidental ? Colors.black : Colors.white))
                : Container()),
      ],
    );
    if (accidental) {
      return Container(
          width: keyWidth,
          margin: EdgeInsets.symmetric(horizontal: 2.0),
          padding: EdgeInsets.symmetric(horizontal: keyWidth * .1),
          child: Material(
              elevation: 6.0,
              borderRadius: borderRadius,
              shadowColor: Color(0x802196F3),
              child: pianoKey));
    }
    return Container(
        width: keyWidth,
        child: pianoKey,
        margin: EdgeInsets.symmetric(horizontal: 2.0));
  }
}

const BorderRadiusGeometry borderRadius = BorderRadius.only(
    bottomLeft: Radius.circular(10.0), bottomRight: Radius.circular(10.0));

//   void _enviar() {
//     String s = '';
//     s += 'b'; // caracter de inicio de som
//     for (int i = 0; i < notas.length; i++) {
//       s += notas[i].getFreq().toString();
//       s += ':';
//       s += notas[i].getTempo().toString();
//       s += '*';
//     }
//     s += 'e';
//     print(s);
//     sockets.send(s);
//   }
// }

class Nota {
  String nota = 'C';
  String tempo = '1/2';

  int getFreq() {
    switch (nota) {
      case 'C':
        return 262;
        break;
      case 'C#':
        return 277;
        break;
      case 'D':
        return 294;
        break;
      case 'D#':
        return 311;
        break;
      case 'E':
        return 330;
        break;
      case 'F':
        return 349;
        break;
      case 'F#':
        return 370;
        break;
      case 'G':
        return 392;
        break;
      case 'G#':
        return 415;
        break;
      case 'A':
        return 440;
        break;
      case 'A#':
        return 466;
        break;
      case 'B':
        return 494;
        break;
      default:
        return 0;
        break;
    }
  }

  int getTempo() {
    switch (tempo) {
      case '1':
        return 1;
        break;
      case '1/2':
        return 2;
        break;
      case '1/4':
        return 4;
        break;
      case '1/8':
        return 8;
        break;
      case '1/16':
        return 16;
        break;
      default:
        return 0;
        break;
    }
  }
}
