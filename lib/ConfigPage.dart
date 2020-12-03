import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:tampi/ARPage.dart';
import 'BuzzerPage.dart';
import 'websocket.dart';
import 'bottle_cap_button_widget.dart';

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
        title: Text("Configurações"),
      ),
      body: GridView.count(
        primary: false,
        padding: const EdgeInsets.all(20),
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        crossAxisCount: 2,
        children: <Widget>[
          _buildSecondTampiButton(),
          _buildBuzzerButton(),
          _buildARButton(),
          _buildConectionButton(),
        ],
      ),
    );
  }

  Widget _buildSecondTampiButton() {
    return bottleCapButton(
      text: 'tampi 2',
      leadingIcon: Icon(Icons.android),
      leadingIconMargin: 10,
      color: Colors.green,
      onClick: qrScanner,
    );
  }

  Widget _buildBuzzerButton() {
    return bottleCapButton(
      text: 'buzzer',
      leadingIcon: Icon(Icons.volume_up),
      leadingIconMargin: 10,
      color: Colors.orange,
      onClick: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BuzzerTestePage(),
          ),
        );
      },
    );
  }

  Widget _buildARButton() {
    return bottleCapButton(
      text: 'AR',
      leadingIcon: Icon(Icons.visibility),
      leadingIconMargin: 10,
      color: Colors.blueAccent,
      onClick: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ARPage(),
          ),
        );
      },
    );
  }

  Widget _buildConectionButton() {
    return bottleCapButton(
      text: 'conexão',
      leadingIcon: Icon(Icons.sync_alt),
      leadingIconMargin: 10,
      color: Colors.red,
      onClick: () async {
        var connectivityResult =
            await (Connectivity().checkConnectivity());
        if (connectivityResult == ConnectivityResult.wifi) {
          // estamos no wifi
          print('estamos no wifi');
        }
      },
    );
  }
}
