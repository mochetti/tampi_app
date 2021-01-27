import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:Tampi/Screens/PianoPage.dart';
import 'package:Tampi/Screens/PainelPage.dart';
import 'package:Tampi/Screens/JoystickPage.dart';
import 'package:Tampi/Screens/ConfigPage.dart';
import 'package:Tampi/Screens/ARPage.dart';
import 'package:Tampi/Screens/BuzzerPage.dart';
import 'package:Tampi/Screens/VozPage.dart';
import 'package:Tampi/Screens/TrajetoPage.dart';

import 'package:Tampi/Utils/bottle_cap_button_widget.dart';
import 'package:Tampi/Utils/websocket.dart';

class MenuPage extends StatefulWidget {
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  WebSocketsNotifications sockets = new WebSocketsNotifications();

  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: new Text('Sair'),
            content: new Text('Deseja se desconectar?'),
            actions: <Widget>[
              new FlatButton(
                onPressed: () => Navigator.of(context).pop(),
                child: new Text('Não'),
              ),
              new FlatButton(
                onPressed: () {
                  if (sockets.isOn) {
                    print('ws desconectado');
                    tentarReconectar = false;
                    sockets.reset();
                  }
                  Navigator.popUntil(context, ModalRoute.withName('/home'));
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
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.yellowAccent,
        appBar: AppBar(
          title: Text('Tampi'),
        ),
        body: GridView.count(
          primary: false,
          padding: const EdgeInsets.all(20),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          crossAxisCount: 2,
          children: <Widget>[
            _buildPainelButton(),
            _buildJoystickButton(),
            _buildPianoButton(),
            _buildARButton(),
            _buildMicButton(),
            _buildTrajetoButton(),
            _buildSonarButton(),
            _buildConfigButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildPainelButton() {
    return bottleCapButton(
        text: 'painel',
        leadingIcon: Icon(Icons.widgets),
        leadingIconMargin: 10,
        color: Colors.green,
        onClick: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PainelPage(),
            ),
          );
        });
  }

  Widget _buildJoystickButton() {
    return bottleCapButton(
        text: 'joystick',
        leadingIcon: Icon(Icons.games),
        leadingIconMargin: 5,
        color: Colors.orange,
        onClick: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => JoystickPage(),
            ),
          );
        });
  }

  Widget _buildPianoButton() {
    return bottleCapButton(
        text: 'piano',
        leadingIcon: Icon(Icons.music_note),
        leadingIconMargin: 10,
        color: Colors.pinkAccent,
        onClick: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PianoPage(),
            ),
          );
        });
  }

  Widget _buildARButton() {
    return bottleCapButton(
        text: 'AR',
        leadingIcon: Icon(Icons.visibility),
        leadingIconMargin: 10,
        color: Colors.purple,
        onClick: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ARPage(),
            ),
          );
        });
  }

  Widget _buildMicButton() {
    return bottleCapButton(
        text: 'voz',
        leadingIcon: Icon(Icons.mic),
        leadingIconMargin: 10,
        color: Colors.blue,
        onClick: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VozPage(),
            ),
          );
        });
  }

  Widget _buildTrajetoButton() {
    return bottleCapButton(
        text: 'trajeto',
        leadingIcon: Icon(Icons.maximize),
        leadingIconMargin: 10,
        color: Colors.blueGrey,
        onClick: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TrajetoPage(),
            ),
          );
        });
  }

  Widget _buildSonarButton() {
    return bottleCapButton(
        text: 'sonar',
        leadingIcon: Icon(Icons.wifi),
        leadingIconMargin: 10,
        color: Colors.deepOrange,
        onClick: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TrajetoPage(),
            ),
          );
        });
  }

  Widget _buildConfigButton() {
    return bottleCapButton(
        text: 'config',
        leadingIcon: Icon(Icons.settings),
        leadingIconMargin: 10,
        color: Colors.red,
        onClick: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ConfigPage(),
            ),
          );
        });
  }
}
