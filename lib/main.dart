import 'package:flutter/material.dart';
import 'ConectedPage.dart';
import 'websocket.dart';
import 'package:connectivity/connectivity.dart';

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
                faltaConectar();
              }
              // estamos no wifi mas resta verificar se a conexao com o tampi existe
              else {
                sockets.initCommunication();
                sockets.addListener(_onMessageReceived);
                // debug
//                _onMessageReceived('welcome');
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
    if(message.toString() == 'welcome') {
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

class instrucoesConexao extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Conectar'),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Text('Instrucoes de conexao'),
//            RaisedButton(
//              onPressed: () {
//                Navigator.of(context).popUntil((route) => route.isFirst);
//              },
//              child: Text('Entendi!'),
//            )
          ],
        ),
      ),
    );
  }
}
