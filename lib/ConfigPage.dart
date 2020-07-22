import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'BuzzerPage.dart';
import 'websocket.dart';
import 'teste.dart';

class ConfigPage extends StatefulWidget {
  @override
  _ConfigPage createState() => _ConfigPage();
}

class _ConfigPage extends State<ConfigPage> {
  Future qrScanner() async {
    String _value = await FlutterBarcodeScanner.scanBarcode(
        "#ff6666", "Cancelar", false, ScanMode.DEFAULT);
    print(_value);
    sockets.send(_value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Config Page"),
      ),
      body: GridView.count(
        crossAxisCount: 2,
        children: [
          RaisedButton(
            child: Text(
              'outro tampi',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20),
            ),
            shape: CircleBorder(),
            color: Colors.green,
            onPressed: qrScanner,
          ),
          RaisedButton(
            child: Text(
              'Buzzer',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20),
            ),
            shape: CircleBorder(),
            color: Colors.orange,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BuzzerTestePage(),
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
            color: Colors.blueAccent,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MyImageTracker(),
                ),
              );
            },
          ),
          RaisedButton(
            child: Text(
              'conexao',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20),
            ),
            shape: CircleBorder(),
            color: Colors.red,
            onPressed: () async {
              var connectivityResult =
                  await (Connectivity().checkConnectivity());
              if (connectivityResult == ConnectivityResult.wifi) {
                // estamos no wifi
                print('estamos no wifi');
              }
            },
          ),
        ],
      ),
    );
  }
}
