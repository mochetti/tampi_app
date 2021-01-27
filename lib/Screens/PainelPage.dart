import 'package:flutter/material.dart';
import 'package:Tampi/Utils/Tampas.dart';
import 'package:Tampi/Utils/websocket.dart';
import 'TampaDialogPage.dart';
import 'package:Tampi/Utils/bottle_cap_button_widget.dart';

class PainelPage extends StatefulWidget {
  @override
  _PainelPageState createState() => _PainelPageState();
}

class _PainelPageState extends State<PainelPage> {
  List<Tampinha> tampinhas = new List.generate(14, (i) => new Tampinha());
  WebSocketsNotifications sockets = new WebSocketsNotifications();

  @override
  void initState() {
    sockets.addListener(comandosServidor);
    super.initState();
  }

  void _addComando(Tampinha t, int id) {
    tampinhas[id] = t;
  }

  Future<void> dialogFuncao(int id) async {
    final List<Tampinha> tesFuncao = new List.filled(3, Tampinha());
    tesFuncao[0] = tampinhas[id * 3 + 8];
    tesFuncao[1] = tampinhas[id * 3 + 9];
    tesFuncao[2] = tampinhas[id * 3 + 10];
    // this will contain the result from Navigator.pop(context, result)
    final List<Tampinha> tRecebidas = await showDialog(
      context: context,
      builder: (context) => FuncaoDialog(id: id, tes: tesFuncao),
    );

    // execution of this code continues when the dialog was closed (popped)
    // note that the result can also be null, so check it
    // (back button or pressed outside of the dialog)
    if (tRecebidas != null) {
      setState(() {
        tampinhas[id * 3 + 8] = tRecebidas[0];
        tampinhas[id * 3 + 9] = tRecebidas[1];
        tampinhas[id * 3 + 10] = tRecebidas[2];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.greenAccent,
      appBar: AppBar(
        title: Text('Painel'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Tampa(_addComando, 0, tampinhas[0]),
                Tampa(_addComando, 1, tampinhas[1]),
                Tampa(_addComando, 2, tampinhas[2]),
              ],
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Tampa(_addComando, 3, tampinhas[7]),
                bottleCapButton(
                  // text: 'enviar',
                  leadingIcon: Icon(Icons.publish),
                  // leadingIconMargin: 10,
                  color: Colors.green,
                  onClick: _enviar,
                ),
                Tampa(_addComando, 4, tampinhas[3]),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Tampa(_addComando, 5, tampinhas[6]),
                Tampa(_addComando, 6, tampinhas[5]),
                Tampa(_addComando, 7, tampinhas[4]),
              ],
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  padding: EdgeInsets.all(4),
                  child: bottleCapButton(
                    text: '0',
                    leadingIcon: Icon(Icons.repeat),
                    leadingIconMargin: 10,
                    color: Colors.orangeAccent,
                    onClick: () {
                      dialogFuncao(0);
                    },
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(4),
                  child: bottleCapButton(
                    text: '1',
                    leadingIcon: Icon(Icons.repeat),
                    leadingIconMargin: 10,
                    color: Colors.blueAccent,
                    onClick: () {
                      dialogFuncao(1);
                    },
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  padding: EdgeInsets.all(4),
                  child: bottleCapButton(
                    text: '2',
                    leadingIcon: Icon(Icons.repeat),
                    leadingIconMargin: 10,
                    color: Colors.redAccent,
                    onClick: () {
                      dialogFuncao(2);
                    },
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(4),
                  child: bottleCapButton(
                    text: '3',
                    leadingIcon: Icon(Icons.repeat),
                    leadingIconMargin: 10,
                    color: Colors.purpleAccent,
                    onClick: () {
                      dialogFuncao(3);
                    },
                  ),
                ),
              ],
            ),
            // ],
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  void _enviar() {
    String comandos = '';
    comandos += 'a'; // caracter de inicio de acao
    // envia as tampinhas
    for (Tampinha t in tampinhas) {
      comandos += t.acao.toString();
      comandos += ':'; // separa as acoes
    }
    comandos += '*'; // separa as acoes dos pots
    for (Tampinha t in tampinhas) {
      comandos += t.getPotRaw().toString();
      comandos += ':'; // separa os pots
    }
    comandos += 'e'; // final da mensagem
    print(comandos);
    sockets.send(comandos);
  }

  void comandosServidor(message) {
    print('servidor diz: ' + message);
  }

  @override
  void dispose() {
    sockets.removeListener(comandosServidor);
    super.dispose();
  }
}
