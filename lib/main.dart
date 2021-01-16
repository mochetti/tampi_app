import 'dart:async';

import 'package:flutter/material.dart';
import 'MenuPage.dart';
import 'websocket.dart';
import 'package:connectivity/connectivity.dart';
import 'instrucoesConexaoPage.dart';
import 'bottle_cap_button_widget.dart';
import 'LogoPainter.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final title = 'tampi';
    return MaterialApp(
      title: title,
      home: LogoAnimator(),
    );
  }
}

class LogoAnimator extends StatefulWidget {
  LogoAnimator({Key key}) : super(key: key);

  _LogoAnimatorState createState() => _LogoAnimatorState();
}

class _LogoAnimatorState extends State<LogoAnimator>
    with SingleTickerProviderStateMixin {
  double _fraction = 0.0;
  Animation<double> animation;
  AnimationController controller;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);

    animation = Tween(begin: 0.0, end: 1.0).animate(controller)
      ..addListener(() {
        setState(() {
          _fraction = animation.value;
        });
      });
    WidgetsBinding.instance.addPostFrameCallback((_) => animacao(context));
  }

  Future<void> animacao(BuildContext context) async {
    await controller.forward();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Home(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: LogoPainter(_fraction, MediaQuery.of(context).size.width,
          MediaQuery.of(context).size.height),
    );
  }

  @override
  dispose() {
    controller.dispose();
    super.dispose();
  }
}

class Home extends StatefulWidget {
  @override
  _Home createState() => _Home();
}

class _Home extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlueAccent,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _onMessageReceived('welcome'),
        child: Icon(Icons.wifi),
      ),
//      appBar: AppBar(
//        title: Text('tampi'),
//      ),
      body: Center(
        child: SizedBox(
          height: 200,
          child: bottleCapButton(
            text: 'conectar',
            leadingIcon: Icon(Icons.settings_remote),
            leadingIconMargin: 5,
            color: Colors.orange,
            onClick: () async {
              print('conectando...');
              // checa se estamos num wifi
              var connectivityResult =
                  await (Connectivity().checkConnectivity());
              if (connectivityResult != ConnectivityResult.wifi) {
                // nao estamos no wifi
                print('nao estamos no wifi');
                faltaConectar();
              }
              // estamos no wifi
              else {
                var SSID = await (Connectivity().getWifiName());
                // checa se estamos no wifi correto
                if (SSID == 'kkkk') {
                  // está retornado null sempre
                  print('rede errada');
                  print(SSID);
                  faltaConectar();
                } else {
                  // tenta abrir o websocket
                  print('tentanto conectar');
                  sockets.initCommunication();
                  sockets.addListener(_onMessageReceived);
                  // debug
//                _onMessageReceived('welcome');
                }
              }
            },
          ),
        ),
      ),
    );
  }

  void faltaConectar() {
    print('falta conectar');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => instrucoesConexao(),
      ),
    );
  }

  void _onMessageReceived(message) {
    // verifica se a msg é pra mim
    if (message.toString() == 'welcome') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MenuPage(),
        ),
      );
    } else if (message.toString() == 'erro') {
      faltaConectar();
    }
  }

  @override
  void dispose() {
    sockets.removeListener(_onMessageReceived);
    super.dispose();
  }
}
