import 'package:flutter/material.dart';
import 'BoardPage.dart';
import 'JoystickPage.dart';
import 'ConfigPage.dart';
import 'websocket.dart';
import 'ARPage.dart';
import 'BuzzerPage.dart';
import 'VoicePage.dart';

class MenuPage extends StatefulWidget {
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: new Text('Sair'),
            content: new Text('Deseja se desconectar ?'),
            actions: <Widget>[
              new FlatButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: new Text('Não'),
              ),
              new FlatButton(
                onPressed: () => {
                  if (sockets.isOn)
                    {
                      print('ws desconectado'),
                      tentarReconectar = false,
                      sockets.reset(),
                    },
                  Navigator.of(context).popUntil((route) => route.isFirst),
                },
                child: new Text('Sim'),
              ),
            ],
          ),
        )) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.yellowAccent,
        appBar: AppBar(
          title: Text('tampi'),
        ),
        body: GridView.count(
          crossAxisCount: 2,
          children: [
            RaisedButton(
              child: Text(
                'Painel',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20),
              ),
              shape: CircleBorder(),
              color: Colors.green,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BoardPage(),
                  ),
                );
              },
            ),
            RaisedButton(
              child: Text(
                'Joystick',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20),
              ),
              shape: CircleBorder(),
              color: Colors.orange,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => JoystickPage(),
                  ),
                );
              },
            ),
            RaisedButton(
              child: Text(
                'Buzzer',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20),
              ),
              shape: CircleBorder(),
              color: Colors.lightBlueAccent,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BuzzerPage(),
                  ),
                );
              },
            ),
            RaisedButton(
              child: Text(
                'AR',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20),
              ),
              shape: CircleBorder(),
              color: Colors.purple,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ARPage(),
                  ),
                );
              },
            ),
            RaisedButton(
              child: Icon(Icons.mic),
              shape: CircleBorder(),
              color: Colors.orangeAccent,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VoicePage(),
                  ),
                );
              },
            ),
            RaisedButton(
              child: Text(
                'Config',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20),
              ),
              shape: CircleBorder(),
              color: Colors.red,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ConfigPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
