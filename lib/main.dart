import 'package:flutter/material.dart';
import 'ConectedPage.dart';
import 'websocket.dart';
import 'package:connectivity/connectivity.dart';
import 'instrucoesConexaoPage.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final title = 'tampi';
    return MaterialApp(
      title: title,
      home: Home(),
    );
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
          child: RaisedButton(
            child: Text(
              'Conectar',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 30),
            ),
            shape: CircleBorder(),
            color: Colors.orange,
            onPressed: () async {
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
                if (SSID == 'kkkk') {                                     // está retornado null sempre
                  print('rede errada');
                  print(SSID);
                  faltaConectar();
                }
                else {
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
          builder: (context) => ConectedPage(),
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
