import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:Tampi/Screens/MenuPage.dart';
import 'package:Tampi/Utils/websocket.dart';
import 'package:connectivity/connectivity.dart';
import 'package:Tampi/Screens/instrucoesConexaoPage.dart';
import 'package:Tampi/Utils/bottle_cap_button_widget.dart';
import 'package:Tampi/Utils/Animations.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      home: new LogoAnimator(),
      routes: <String, WidgetBuilder>{
        '/logo': (BuildContext context) => new LogoAnimator(),
        '/home': (BuildContext context) => new Home(),
        '/menu': (BuildContext context) => new MenuPage(),
      },
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
    // Navigator.of(context).push(
    //   MaterialPageRoute(
    //     // settings: RouteSettings(name: Home.routeName),
    //     builder: (context) => Home(),
    //   ),
    // );
    Navigator.pushReplacementNamed(context, "/home");
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomPaint(
        painter: LogoPainter(_fraction, MediaQuery.of(context).size.width,
            MediaQuery.of(context).size.height),
      ),
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

class _Home extends State<Home> with SingleTickerProviderStateMixin {
  bool conectado = false;
  bool conectando = false;
  WebSocketsNotifications sockets = new WebSocketsNotifications();

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return Scaffold(
      backgroundColor: Colors.lightBlueAccent,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _onMessageReceived('welcome'),
        child: Icon(Icons.wifi),
      ),
      body: Center(
        child: SizedBox(
          height: 200,
          child: bottleCapButton(
            text: 'conectar',
            leadingIcon: Icon(Icons.wifi),
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
                return;
              }

              print("animacao");
              showDialog(
                context: context,
                builder: (_) => LoadingAlert(
                  onCancel: () {
                    sockets.removeListener(_onMessageReceived);
                    Navigator.pop(context);
                  },
                ),
              );

              // estamos no wifi
              var ssid = await (Connectivity().getWifiName());
              // checa se estamos no wifi correto
              if (ssid == 'kkkk') {
                // está retornado null sempre
                print('rede errada');
                print(ssid);
                faltaConectar();
                return;
              } else {
                // tenta abrir o websocket
                print('tentando conectar');
                sockets.initCommunication();
                sockets.addListener(_onMessageReceived);
                // debug
                // _onMessageReceived('welcome');
              }
            },
          ),
        ),
      ),
    );
  }

  void faltaConectar() {
    print('falta conectar');
    Navigator.pop(context);
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
      Navigator.pushNamed(context, "/menu");
    } else if (message.toString() == 'erro') {
      sockets.removeListener(_onMessageReceived);
      faltaConectar();
    }
  }

  @override
  void dispose() {
    sockets.removeListener(_onMessageReceived);
    super.dispose();
  }
}
