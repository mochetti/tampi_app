import 'package:Tampi/main.dart';
import 'package:flutter/material.dart';
import 'PainelPage.dart';
import 'JoystickPage.dart';
import 'ConfigPage.dart';
import 'websocket.dart';
import 'ARPage.dart';
import 'BuzzerPage.dart';
import 'VoicePage.dart';
import 'bottle_cap_button_widget.dart';
import 'TrajetoPage.dart';

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
                  Navigator.of(context).pop(false),
                  Navigator.of(context).pop(false),
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
          primary: false,
          padding: const EdgeInsets.all(20),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          crossAxisCount: 2,
          children: <Widget>[
            _buildPainelButton(),
            _buildJoystickButton(),
            _buildBuzzerButton(),
            _buildARButton(),
            _buildMicButton(),
            _buildTrajetoButton(),
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
        leadingIconMargin: 10,
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

  Widget _buildBuzzerButton() {
    return bottleCapButton(
        text: 'buzzer',
        leadingIcon: Icon(Icons.volume_up),
        leadingIconMargin: 10,
        color: Colors.pinkAccent,
        onClick: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BuzzerPage(),
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
              builder: (context) => VoicePage(),
            ),
          );
        });
  }

  Widget _buildTrajetoButton() {
    return bottleCapButton(
        text: 'trajeto',
        leadingIcon: Icon(Icons.maximize),
        leadingIconMargin: 10,
        color: Colors.blue,
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
