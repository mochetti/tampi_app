import 'package:flutter/material.dart';
import 'package:Tampi/Utils/websocket.dart';

class BuzzerPage extends StatefulWidget {
  @override
  _BuzzerPage createState() => _BuzzerPage();
}

class _BuzzerPage extends State<BuzzerPage> {
  WebSocketsNotifications sockets = new WebSocketsNotifications();
  List<Nota> notas = [];
  double freq = 200;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.greenAccent,
      appBar: AppBar(
        title: Text('Buzzer'),
      ),
      body: ListView(
        physics: ScrollPhysics(),
        shrinkWrap: true,
        children: <Widget>[
          ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: notas.length,
            itemBuilder: (context, index) {
              final item = notas[index];

              return Dismissible(
                // Each Dismissible must contain a Key. Keys allow Flutter to
                // uniquely identify widgets.
                key: UniqueKey(),
                // Provide a function that tells the app
                // what to do after an item has been swiped away.
                onDismissed: (direction) {
                  // Remove the item from the data source.
                  setState(() {
                    notas.removeAt(index);
                  });

                  // Then show a snackbar.
//                  Scaffold.of(context)
//                      .showSnackBar(SnackBar(content: Text("$item dismissed")));
                },
                // Show a red background as the item is swiped away.
                background: Container(color: Colors.red),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Text('Nota:'),
                    DropdownButton<String>(
                      value: item.nota,
                      icon: Icon(Icons.arrow_downward),
                      iconSize: 24,
                      elevation: 16,
                      style: TextStyle(color: Colors.deepPurple),
                      underline: Container(
                        height: 2,
                        color: Colors.deepPurpleAccent,
                      ),
                      onChanged: (String newValue) {
                        setState(() {
                          item.nota = newValue;
                        });
                      },
                      items: <String>[
                        'C',
                        'C#',
                        'D',
                        'D#',
                        'E',
                        'F',
                        'F#',
                        'G',
                        'G#',
                        'A',
                        'A#',
                        'B'
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                    Text('Tempo:'),
                    DropdownButton<String>(
                      value: item.tempo,
                      icon: Icon(Icons.arrow_downward),
                      iconSize: 24,
                      elevation: 16,
                      style: TextStyle(color: Colors.deepPurple),
                      underline: Container(
                        height: 2,
                        color: Colors.deepPurpleAccent,
                      ),
                      onChanged: (String newValue) {
                        setState(() {
                          item.tempo = newValue;
                        });
                      },
                      items: <String>['1/2', '1/4', '1/8', '1/16']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              );
            },
          ),
          Container(
            height: 40,
            color: Colors.deepOrange,
            child: Center(
              child: RaisedButton(
                child: Text(
                  'Add',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20),
                ),
//                shape: CircleBorder(),
                color: Colors.transparent,
                elevation: 0,
                onPressed: () {
                  setState(() {
                    notas.add(new Nota());
                  });
                },
              ),
            ),
          ),
//          Container(
//            height: 40,
//          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _enviar,
        tooltip: 'Enviar',
        child: Icon(Icons.send),
      ),
    );
  }

  void _enviar() {
    String s = '';
    s += 'b'; // caracter de inicio de som
    for (int i = 0; i < notas.length; i++) {
      s += notas[i].getFreq().toString();
      s += ':';
      s += notas[i].getTempo().toString();
      s += '*';
    }
    s += 'e';
    print(s);
    sockets.send(s);
  }
}

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

class BuzzerTestePage extends StatefulWidget {
  @override
  _BuzzerTestePage createState() => _BuzzerTestePage();
}

class _BuzzerTestePage extends State<BuzzerTestePage> {
  WebSocketsNotifications sockets = new WebSocketsNotifications();
  double freq = 200;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.greenAccent,
      appBar: AppBar(
        title: Text('Buzzer Teste'),
      ),
      body: Container(
        child: Slider(
          activeColor: Colors.red,
          inactiveColor: Colors.red.withOpacity(0.5),
          value: freq,
          min: 30,
          max: 5000,
          label: freq.toStringAsFixed(0) + 'Hz',
          divisions: 100,
          onChanged: (value) {
            setState(() {
              freq = value;
              _enviar();
            });
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _enviar,
        tooltip: 'Enviar',
        child: Icon(Icons.send),
      ),
    );
  }

  void _enviar() {
    String s = '';
    s += 's'; // caracter de inicio de som
    s += freq.toStringAsFixed(0);
    s += 'e';
    print(s);
    sockets.send(s);
  }
}
