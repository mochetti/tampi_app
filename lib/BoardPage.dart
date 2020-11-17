import 'package:flutter/material.dart';
import 'Tampas.dart';
import 'websocket.dart';
import 'TampaDialogPage.dart';

class BoardPage extends StatefulWidget {
  @override
  _BoardPageState createState() => _BoardPageState();
}

class _BoardPageState extends State<BoardPage> {
  List<Tampinha> tampinhas = new List.generate(14, (i) => new Tampinha());

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
        title: Text('Controle'),
      ),
      body: Column(children: [
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          children: <Widget>[
            Tampa(_addComando, 0, tampinhas[0]),
            Tampa(_addComando, 1, tampinhas[1]),
            Tampa(_addComando, 2, tampinhas[2]),
            Tampa(_addComando, 3, tampinhas[7]),
            RaisedButton(
              shape: CircleBorder(),
              onPressed: _enviar,
              color: Colors.green,
              child: Text(
                'Enviar',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 30),
              ),
            ),
            Tampa(_addComando, 4, tampinhas[3]),
            Tampa(_addComando, 5, tampinhas[6]),
            Tampa(_addComando, 6, tampinhas[5]),
            Tampa(_addComando, 7, tampinhas[4]),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Container(
              height: 150,
              padding: EdgeInsets.all(4),
              child: RaisedButton(
                shape: CircleBorder(),
                onPressed: () => dialogFuncao(0),
                color: Colors.orangeAccent,
                child: Text(
                  'Funcao 0',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
            Container(
              height: 150,
              padding: EdgeInsets.all(4),
              child: RaisedButton(
                shape: CircleBorder(),
                onPressed: () => dialogFuncao(1),
                color: Colors.blueAccent,
                child: Text(
                  'Funcao 1',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
          ],
        )
      ]),
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
